# VECTOR_ENGINE_v5

[VECTOR_ENGINE_v4](../VECTOR_ENGINE_v4/README.md) 파생. **RoPE 회전 지원** 버전.

v4의 non-uniform learned LUT 구조는 그대로 유지하고, RoPE 회전에 필요한
elementwise 벡터-벡터 뺄셈 opcode 하나만 추가했다.

---

## 1. v4 대비 변경점 (diff)

| 항목 | v4 | v5 |
|---|---|---|
| opcode | 18개 (0~17) | **19개** — `ESUB`(18) 추가 |
| 신규 게이트 | — | **0** |
| 수정 파일 | — | **`OP_CONTROL.v` 한 개** |

`ALU_LANE`에 뺄셈 경로(`OP_SUB`, `MINUS_X`)가 v2부터 이미 있었으나
`(V_ALU, alu_op=2'b10)` 조합을 쓰는 opcode가 없었다. `alu_op=2'b10`은
`VSSUB`(벡터−브로드캐스트 스칼라, V_SCALE 모드)에서만 쓰이고 있었음.
따라서 v5의 변경은 **디코드 테이블 추가뿐**이며 데이터패스는 무손이다.

**무변경**: `ALU_LANE` `V_ALU` `V_PWL` `SEG_SEL` `LUT_REGS` `VRF` `SRF`
`REDUCE` `SALU` `SCALAR_DATAPATH` `VEC_DATAPATH` `VEC_LSU` `INSTR_FIFO` `BF16_*`

## 2. 신규 명령

| opcode | 니모닉 | 동작 | 사이클 |
|---|---|---|---|
| 18 | `ESUB` | `VRF[dst] ← VRF[src1] − VRF[src2]` (elementwise) | 5 |

기존 연산 FSM 경로(FETCH→DECODE→READ→COMP→WRITE) 그대로. 새 상태 없음.

## 3. RoPE 설계 규약

### 3.1 cos/sin은 호스트가 사전 계산

NPU는 삼각함수를 계산하지 않는다. 각도 생성기·삼각함수 LUT·INT32 경로 없음.
(vLLM / TensorRT / ONNX 표준이 cos/sin을 외부 입력으로 규정)

### 3.2 cos/sin은 d/2 개만 저장

HF LLaMA는 `cat(freqs, freqs)`로 길이 d 배열을 만들지만, 이 엔진의 엔트리
분할 방식에서는 **d/2 개면 충분**하다 — 그룹이 `cos[j+d/2] = cos[j]`인 두
엔트리를 같은 cos 엔트리로 처리하기 때문.

| | 길이 d (HF 원형) | **길이 d/2 (v5 규약)** |
|---|---|---|
| VRF 엔트리 (cos+sin) | 8 | **4** |
| 토큰당 DRAM 읽기 | 512 B | **256 B** |

### 3.3 엔트리 인덱싱 (d=128, lane=32)

```
E0 = Q[  0: 32]  ┐ 그룹 A (j = 0..31)   ← cos[0:32],  sin[0:32]
E2 = Q[ 64: 96]  ┘
E1 = Q[ 32: 64]  ┐ 그룹 B (j = 32..63)  ← cos[32:64], sin[32:64]
E3 = Q[ 96:128]  ┘
```

**lane i끼리 짝** (`Q[j]` ↔ `Q[j+d/2]`) → cross-lane 셔플 회로 불필요.
`rotate_half`는 **명령의 src 필드에서 엔트리 번호를 바꾸는 것**으로 흡수되며
주소 조작 회로도 부호 XOR 회로도 쓰지 않는다.

d=64 (1B 모델)이면 head당 그룹 1개. 명령은 동일, 컴파일러가 엔트리만 다르게 발행.

## 4. 회전 프로그램 (그룹 1개 = 6명령)

```
EMUL T1, Q_lo, cos      ; T1 = Q_lo · cos
EMUL T2, Q_hi, sin      ; T2 = Q_hi · sin
ESUB O_lo, T1, T2       ; Q'_lo = Q_lo·cos − Q_hi·sin
EMUL T1, Q_hi, cos
EMUL T2, Q_lo, sin
EADD O_hi, T1, T2       ; Q'_hi = Q_hi·cos + Q_lo·sin
```

전부 2-피연산자라 VRF 2R 포트로 충족. 임시 VRF 2엔트리(T1, T2) 사용.

### VRF 배치 (뱅크 충돌 회피)

VRF는 `addr[0]`으로 2뱅크 인터리브. rd1/rd2가 다른 뱅크에 오도록 배치:

```
Q 입력·임시·출력 → 짝수 주소 (bank0)
cos / sin        → 홀수 주소 (bank1)
```

TB 예: `E0=0 E1=2 E2=4 E3=6 / CA=1 CB=3 SA=5 SB=7 / T1=8 T2=9 / O0=10 O1=12 O2=14 O3=16`

## 5. 사이클 예산 (레이어 1개, 토큰 1개)

| | 3B (d=128, Q24+K8) | 1B (d=64, Q32+K8) |
|---|---|---|
| 회전 | 64그룹 × 6명령 × 5 = 1,920 | 40그룹 × 6 × 5 = 1,200 |
| LDV + STV | 256명령 × 5 = 1,280 | 160 × 5 = 800 |
| **합계** | **3,200** | **2,000** |

(캐시 1-cycle 응답 가정)

VRF 엔트리 예산: 입력 4 + 출력 4 + cos/sin 4 + 임시 2 = **14 / 32**

## 6. 설계 대안 (미채택)

전용 512b `VTMP` 레지스터 + `VMULT`/`VMADDT` 2명령 방식이면 그룹당 6→4명령으로
줄어 3B 기준 640 cycle/layer/token (RoPE의 25%, 벡터엔진 전체의 약 2% — 추정)
절약되나, 512 FF + 512b mux + `VEC_DATAPATH` 수정이 필요하다.

파이프라인화(로드맵 2번, 처리량 5배)가 훨씬 큰 레버이므로 **v5에서는 미채택**.
v5의 명령 시퀀스는 VTMP 방식과 상위 호환이므로 나중에 얹을 수 있다.

## 7. TB

```
tb/gen_rope_data.py       → rope_data.vh  (Q 입력, cos/sin, golden, 진값)
tb/tb_rope_v5.v           RoPE 회전 실행 + 검증
tb/tb_top_v4.v            v4 기능 회귀
tb/tb_sweep_v4.v          v4 전 LUT 스윕 회귀
```

golden은 HW 연산 순서(EMUL→EMUL→ESUB)를 BF16 반올림 단계까지 에뮬레이션하므로
bit-exact 판정이 가능하다.

**검증 결과** (iverilog, d=128 / base=500000 / m=1000):

| 항목 | 결과 |
|---|---|
| golden bit 일치 | **128/128 (bit-exact)** |
| float64 진값 대비 최대 오차 | 1.56e-2 (≈ Q 최대값 2.0의 BF16 1 ulp) |
| 회전 불변량 `‖Q'‖²−‖Q‖²` | 6.18e-2 (BF16 누적 오차) |
| v4 회귀 (tb_top_v4) | PASS |
| v4 회귀 (tb_sweep_v4, 2112 포인트) | PASS |

## 8. 주의

- `ESUB`는 `VSSUB`(opcode 11)와 다르다. `VSSUB`는 벡터 − **브로드캐스트 스칼라**,
  `ESUB`는 벡터 − **벡터** (elementwise)
- cos/sin VRF 엔트리는 토큰 단위로 상주시키는 것이 유리하다 (레이어에 무관하므로).
  컴파일러가 4엔트리를 예약할 것
- V는 회전하지 않는다. Q와 K만 처리
