#!/usr/bin/env python3
"""RoPE 테스트 데이터 생성 (stdlib only)

호스트가 cos/sin 을 사전 계산해 메모리에 두는 v5 규약을 그대로 모사.
  - cos/sin 은 d/2 개만 저장 (cos[j+d/2] = cos[j] 이므로 중복 불필요)
  - golden 은 HW 와 동일한 BF16 반올림 순서로 에뮬레이션 → bit-exact 기대
  - 참고용으로 float64 진값 RoPE 도 함께 출력

usage: python3 gen_rope_data.py [outdir]
"""
import math, struct, os, sys, random

D    = 128          # head_dim (3B)
BASE = 500000.0
M    = 1000         # token position
LANE = 32

def f2bf16(x):
    if x == 0.0: return 0
    u = struct.unpack('>I', struct.pack('>f', x))[0]
    lo, hi = u & 0xFFFF, u >> 16
    if lo > 0x8000 or (lo == 0x8000 and (hi & 1)): hi += 1
    return hi & 0xFFFF

def bf16_2f(b): return struct.unpack('>f', struct.pack('>I', (b & 0xFFFF) << 16))[0]
def bf(x): return bf16_2f(f2bf16(x))

# ---------------- 호스트 사전계산: cos/sin (d/2 개) ----------------
inv_freq = [BASE ** (-2*j/D) for j in range(D//2)]
cos_h = [bf(math.cos(M * f)) for f in inv_freq]      # BF16 로 양자화해 메모리에 저장
sin_h = [bf(math.sin(M * f)) for f in inv_freq]

# ---------------- 입력 Q ----------------
rnd = random.Random(42)
Q = [bf(rnd.uniform(-2.0, 2.0)) for _ in range(D)]

# ---------------- golden: HW 연산 순서 그대로 (BF16 단계별 반올림) ----------------
Qo = [0.0]*D
for j in range(D//2):
    t1 = bf(Q[j]      * cos_h[j])     # EMUL
    t2 = bf(Q[j+D//2] * sin_h[j])     # EMUL
    Qo[j]      = bf(t1 - t2)          # ESUB
    t3 = bf(Q[j+D//2] * cos_h[j])     # EMUL
    t4 = bf(Q[j]      * sin_h[j])     # EMUL
    Qo[j+D//2] = bf(t3 + t4)          # EADD

# ---------------- 참값 (float64, 양자화 없음) ----------------
Qt = [0.0]*D
for j in range(D//2):
    c, s = math.cos(M*inv_freq[j]), math.sin(M*inv_freq[j])
    Qt[j]      = Q[j]*c - Q[j+D//2]*s
    Qt[j+D//2] = Q[j+D//2]*c + Q[j]*s

outdir = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__))

def emit_line(f, addr, vals):
    for i, v in enumerate(vals):
        f.write(f"        fake_cache[{addr}][{i}*16+:16] = 16'h{f2bf16(v):04X};\n")

with open(f"{outdir}/rope_data.vh", "w") as f:
    f.write(f"// rope_data.vh - generated. d={D}, base={BASE:g}, m={M}\n")
    f.write(f"    localparam ROPE_D = {D};\n")
    f.write("    reg [15:0] rope_gold [0:%d];   // HW 연산순서 BF16 golden\n" % (D-1))
    f.write("    reg [15:0] rope_true [0:%d];   // float64 진값 (BF16 로 표시용)\n" % (D-1))
    f.write("    task set_rope_input; begin\n")
    f.write("        // Q: 캐시 0~3 (32 elem/line)\n")
    for e in range(D//LANE):
        emit_line(f, f"8'd{e}", Q[e*LANE:(e+1)*LANE])
    f.write("        // cos: 캐시 8,9   sin: 캐시 10,11   (d/2 = %d 개만)\n" % (D//2))
    emit_line(f, "8'd8",  cos_h[0:LANE])
    emit_line(f, "8'd9",  cos_h[LANE:2*LANE])
    emit_line(f, "8'd10", sin_h[0:LANE])
    emit_line(f, "8'd11", sin_h[LANE:2*LANE])
    f.write("    end endtask\n")
    f.write("    task set_rope_gold; begin\n")
    for i, v in enumerate(Qo):
        f.write(f"        rope_gold[{i}] = 16'h{f2bf16(v):04X};\n")
    for i, v in enumerate(Qt):
        f.write(f"        rope_true[{i}] = 16'h{f2bf16(v):04X};\n")
    f.write("    end endtask\n")

# ---------------- 통계 ----------------
maxe = max(abs(Qo[i]-Qt[i]) for i in range(D))
nrm_in  = [math.hypot(Q[j],  Q[j+D//2])  for j in range(D//2)]
nrm_out = [math.hypot(Qo[j], Qo[j+D//2]) for j in range(D//2)]
nrm_err = max(abs(a-b) for a,b in zip(nrm_in, nrm_out))
print(f"생성 완료: {outdir}/rope_data.vh")
print(f"  d={D}, base={BASE:g}, m={M}")
print(f"  golden vs float64 진값 : max err {maxe:.3e}")
print(f"  회전 노름 보존 |Q'|=|Q| : max err {nrm_err:.3e}  (회전이므로 이론상 0)")
