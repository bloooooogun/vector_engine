#!/usr/bin/env python3
"""learned_luts xlsx → v4 TB include 생성 (stdlib only, pandas 불필요)

usage: python3 gen_luts_from_xlsx.py <learned_luts_wm_ent_N4.xlsx> [outdir]

생성물:
  all_luts.vh  - LUT 라인 staging task (set_silu_lut / set_exp_lut / set_rsqrt_lut / set_recip_lut)
                 fake_cache[caddr] 에 512b 라인 적재 (word0-4=knot x0..x4, 5-8=a0..3, 9-12=b0..3)
  v4_data.vh   - 테스트 입력 + LUT-emulated golden (RMSNorm/Softmax/SiLU)

LUT 라인 포맷은 LUT_REGS.v 와 일치해야 함.
"""
import sys, os, zipfile, struct, math, random
import xml.etree.ElementTree as ET

NS = {'m': 'http://schemas.openxmlformats.org/spreadsheetml/2006/main'}

def f2bf16(x):
    if x == 0.0: return 0
    u = struct.unpack('>I', struct.pack('>f', x))[0]
    lo, hi = u & 0xFFFF, u >> 16
    if lo > 0x8000 or (lo == 0x8000 and (hi & 1)): hi += 1
    return hi & 0xFFFF

def bf16_2f(b):
    return struct.unpack('>f', struct.pack('>I', (b & 0xFFFF) << 16))[0]

def bf(x): return bf16_2f(f2bf16(x))

def cellval(c):
    if c.get('t') == 'inlineStr':
        t = c.find('.//m:t', NS)
        return t.text if t is not None else ''
    v = c.find('m:v', NS)
    return v.text if v is not None else ''

def read_sheet(z, idx):
    root = ET.fromstring(z.read(f'xl/worksheets/sheet{idx}.xml'))
    return [[cellval(c) for c in row.findall('m:c', NS)] for row in root.findall('.//m:row', NS)]

def parse_luts(rows):
    """rows → [(module_name, [seg0..seg3])], seg = dict(xl,xr,a_hex,b_hex)"""
    luts, cur_name, cur = [], None, []
    for r in rows[2:]:                     # skip title + column header
        if len(r) < 10 or r[1] == '': continue
        name, seg = r[0], int(r[1])
        if seg == 0:
            if cur: luts.append((cur_name, cur))
            cur_name, cur = name, []
        cur.append(dict(xl=float(r[2]), xr=float(r[3]),
                        a=int(r[8], 16), b=int(r[9], 16)))
    if cur: luts.append((cur_name, cur))
    return luts

def lut_words(segs):
    """LUT_REGS 라인 포맷: 13 words (BF16)"""
    knots = [segs[0]['xl']] + [s['xr'] for s in segs]      # x0..x4
    w = [f2bf16(k) for k in knots]
    w += [s['a'] for s in segs]
    w += [s['b'] for s in segs]
    return w  # 13 words

def lut_eval(segs, x, silu=False):
    """HW 동작 에뮬레이션: BF16 knot 비교 + 범위 밖 정책 + BF16 madd (mul/add 각각 라운딩)
    silu=True: lo → 0, hi → x (identity). 그 외 함수: 끝점 연장 (x_eff 클램프)"""
    knots = [bf16_2f(f2bf16(k)) for k in ([segs[0]['xl']] + [s['xr'] for s in segs])]
    xb = bf(x)
    if silu:
        if xb < knots[0]: return 0.0
        if xb > knots[4]: return xb
    seg = 0 if xb < knots[1] else 1 if xb < knots[2] else 2 if xb < knots[3] else 3
    x_eff = knots[0] if xb < knots[0] else knots[4] if xb > knots[4] else xb
    a, b = bf16_2f(segs[seg]['a']), bf16_2f(segs[seg]['b'])
    return bf(bf(a * x_eff) + b)

def emit_case_task(f, tname, luts):
    f.write(f"    task {tname}; input [7:0] caddr; input integer idx; begin\n")
    f.write("        fake_cache[caddr] = 512'd0;\n        case (idx)\n")
    for i, (name, segs) in enumerate(luts):
        ws = lut_words(segs)
        f.write(f"        {i}: begin // {name}\n")
        for j, w in enumerate(ws):
            f.write(f"            fake_cache[caddr][{j}*16 +: 16] = 16'h{w:04X};\n")
        f.write("        end\n")
    f.write("        endcase\n    end endtask\n\n")

def main():
    xlsx = sys.argv[1]
    outdir = sys.argv[2] if len(sys.argv) > 2 else os.path.dirname(os.path.abspath(__file__))
    z = zipfile.ZipFile(xlsx)
    wb = ET.fromstring(z.read('xl/workbook.xml'))
    names = [s.get('name') for s in wb.findall('.//m:sheet', NS)]
    sheet_of = {n: i + 1 for i, n in enumerate(names)}

    rsqrt = parse_luts(read_sheet(z, sheet_of['rsqrt']))
    silu  = parse_luts(read_sheet(z, sheet_of['silu']))
    expf  = parse_luts(read_sheet(z, sheet_of['exp']))
    oos   = parse_luts(read_sheet(z, sheet_of['1_over_S']))
    print(f"parsed: rsqrt={len(rsqrt)} silu={len(silu)} exp={len(expf)} 1_over_S={len(oos)}")
    for i, (n, _) in enumerate(rsqrt): print(f"  rsqrt[{i}] = {n}")

    # ---------------- all_luts.vh ----------------
    with open(f"{outdir}/all_luts.vh", "w") as f:
        f.write(f"// all_luts.vh - generated from {os.path.basename(xlsx)}\n")
        f.write("// word0-4 = x0..x4 (knots), word5-8 = a0..a3, word9-12 = b0..b3\n")
        emit_case_task(f, "set_silu_lut", silu)
        emit_case_task(f, "set_exp_lut", expf)
        emit_case_task(f, "set_rsqrt_lut", rsqrt)
        emit_case_task(f, "set_recip_lut", oos)

    # ---------------- v4_data.vh (입력 + LUT-emulated golden) ----------------
    # rsqrt 모듈 선택: [x0,x4] 가 [0.5, 4.0] 을 덮는 첫 모듈 (RMS mean + rsqrt(4) 테스트)
    RSQ = next(i for i, (n, s) in enumerate(rsqrt)
               if s[0]['xl'] <= 0.5 and s[3]['xr'] >= 4.0)
    print(f"TB rsqrt module: idx {RSQ} = {rsqrt[RSQ][0]}")
    SIL, EXPG, OOS_L = 0, 0, 0   # silu layer0, exp global, 1_over_S layer0

    def emit_vec(f, addr, vals):
        for j, v in enumerate(vals):
            f.write(f"        fake_cache[{addr}][{j}*16+:16]=16'h{f2bf16(v):04X};\n")
    def emit_gold(f, nm, vals):
        for j, v in enumerate(vals):
            f.write(f"        {nm}[{j}]=16'h{f2bf16(v):04X};\n")

    with open(f"{outdir}/v4_data.vh", "w") as f:
        f.write("// v4_data.vh - generated: inputs + LUT-emulated golden\n")
        f.write(f"    localparam TB_RSQRT_IDX = {RSQ};  // {rsqrt[RSQ][0]}\n")
        f.write(f"    localparam TB_SILU_IDX  = {SIL};\n")
        f.write(f"    localparam TB_EXP_IDX   = {EXPG};\n")
        f.write(f"    localparam TB_RECIP_IDX = {OOS_L};\n")

        # basic goldens (LUT-emulated)
        f.write(f"    localparam [15:0] G_SILU_1   = 16'h{f2bf16(lut_eval(silu[SIL][1], 1.0, silu=True)):04X};   // silu_lut(1.0)\n")
        f.write(f"    localparam [15:0] G_EXP_M2   = 16'h{f2bf16(lut_eval(expf[EXPG][1], -2.0)):04X};   // exp_lut(-2)\n")
        f.write(f"    localparam [15:0] G_RSQRT_4  = 16'h{f2bf16(lut_eval(rsqrt[RSQ][1], 4.0)):04X};   // rsqrt_lut(4)\n")

        # RMSNorm (seed 3)
        rnd = random.Random(3)
        x = [bf(rnd.uniform(-1.5, 1.5)) for _ in range(32)]
        g = [bf(rnd.uniform(0.8, 1.2)) for _ in range(32)]
        mean = bf(sum(v * v for v in x) / 32)          # HW: reduce 후 SMUL 1/32
        r = lut_eval(rsqrt[RSQ][1], mean)
        gold = [bf(bf(v * r) * gv) for v, gv in zip(x, g)]
        f.write("    reg [15:0] rms_gold [0:31];\n    task set_rms_input; begin\n")
        emit_vec(f, "8'd0", x); emit_vec(f, "8'd1", g)
        f.write("        set_cache(2,16'h3D00);  // 1/32\n    end endtask\n")
        f.write("    task set_rms_gold; begin\n")
        emit_gold(f, "rms_gold", gold)
        f.write("    end endtask\n")

        # Softmax (seed 7)
        rnd = random.Random(7)
        x = [bf(rnd.uniform(-3, 3)) for _ in range(32)]
        mx = max(x)
        e = [lut_eval(expf[EXPG][1], bf(v - mx)) for v in x]
        S = sum(e)                                      # reduce (float 근사)
        rc = lut_eval(oos[OOS_L][1], S)
        gold = [bf(v * rc) for v in e]
        f.write("    reg [15:0] sm_gold [0:31];\n    task set_sm_input; begin\n")
        emit_vec(f, "8'd3", x)
        f.write("    end endtask\n    task set_sm_gold; begin\n")
        emit_gold(f, "sm_gold", gold)
        f.write("    end endtask\n")

        # SiLU (seed 11) — 범위 밖 정책 확인 위해 ±4 밖 값 2개 포함 (-5→0, +5→5)
        rnd = random.Random(11)
        x = [bf(rnd.uniform(-3.5, 3.5)) for _ in range(30)] + [bf(-5.0), bf(5.0)]
        gold = [lut_eval(silu[SIL][1], v, silu=True) for v in x]
        f.write("    reg [15:0] silu_gold [0:31];\n    task set_silu_input; begin\n")
        emit_vec(f, "8'd4", x)
        f.write("    end endtask\n    task set_silu_gold; begin\n")
        emit_gold(f, "silu_gold", gold)
        f.write("    end endtask\n")

        # LUT swap 검증용: 같은 입력, silu layer1 LUT 기준 golden
        gold_l1 = [lut_eval(silu[1][1], v, silu=True) for v in x]
        f.write("    reg [15:0] silu_gold_l1 [0:31];\n    task set_silu_gold_l1; begin\n")
        emit_gold(f, "silu_gold_l1", gold_l1)
        f.write("    end endtask\n")

    # ---------------- v4_sweep.vh (전 LUT 스윕: 66개 전부 bit-exact 검증) ----------------
    #   함수마다 테스트 입력 32개: 32-2개는 [x0,x4] 로그 분포, 양끝 2개는 범위 밖 (클램프)
    def sweep_points(segs, log=True):
        x0, x4 = segs[0]['xl'], segs[3]['xr']
        pts = []
        for j in range(30):
            t = j / 29.0
            v = x0 * (x4 / x0) ** t if log and x0 > 0 else x0 + (x4 - x0) * t
            pts.append(bf(v))
        pts.append(bf(x0 * 0.5 if x0 > 0 else x0 - abs(x0) * 0.5 - 1.0))  # 하한 밖
        pts.append(bf(x4 * 2.0 if x4 > 0 else x4 + 1.0))                  # 상한 밖 (x4<=0 대응)
        return pts

    def f2f32(x):
        """float → IEEE754 32b 비트 (진값 저장용)"""
        return struct.unpack('>I', struct.pack('>f', x))[0]

    # 실제 함수 (CPU double precision — pytorch CPU 연산과 동일 정밀도)
    TRUE_FN = {
        "silu": lambda x: x / (1.0 + math.exp(-x)),
        "exp":  math.exp,
        "rsq":  lambda x: 1.0 / math.sqrt(x),
        "oos":  lambda x: 1.0 / x,
    }

    with open(f"{outdir}/v4_sweep.vh", "w") as f:
        f.write("// v4_sweep.vh - generated: 전 LUT (66개) 스윕 입력 + bit-exact golden + 진값(f32)\n")
        f.write(f"    localparam N_SILU = {len(silu)}, N_EXP = {len(expf)}, N_RSQ = {len(rsqrt)}, N_OOS = {len(oos)};\n")

        def emit_sweep(fn_name, luts, is_silu, log):
            # 입력 라인 task (모듈별 case) + golden(BF16) + 진값(f32) 배열 task
            f.write(f"    reg [15:0] sw_{fn_name}_gold [0:{len(luts)*32-1}];\n")
            f.write(f"    reg [31:0] sw_{fn_name}_true [0:{len(luts)*32-1}];\n")
            f.write(f"    task set_{fn_name}_in; input [7:0] caddr; input integer idx; begin\n")
            f.write("        case (idx)\n")
            golds, trues = [], []
            for m, (name, segs) in enumerate(luts):
                pts = sweep_points(segs, log)
                golds.append([lut_eval(segs, v, silu=is_silu) for v in pts])
                trues.append([TRUE_FN[fn_name](v) for v in pts])
                f.write(f"        {m}: begin // {name}\n")
                for j, v in enumerate(pts):
                    f.write(f"            fake_cache[caddr][{j}*16+:16]=16'h{f2bf16(v):04X};\n")
                f.write("        end\n")
            f.write("        endcase\n    end endtask\n")
            f.write(f"    task set_{fn_name}_gold; begin\n")
            for m, gl in enumerate(golds):
                for j, v in enumerate(gl):
                    f.write(f"        sw_{fn_name}_gold[{m*32+j}]=16'h{f2bf16(v):04X};\n")
            for m, tl in enumerate(trues):
                for j, v in enumerate(tl):
                    f.write(f"        sw_{fn_name}_true[{m*32+j}]=32'h{f2f32(v):08X};\n")
            f.write("    end endtask\n\n")

        emit_sweep("silu", silu, True,  False)   # silu 도메인 ±4: 선형 분포
        emit_sweep("exp",  expf, False, False)   # exp [-8,0]: 선형 분포
        emit_sweep("rsq",  rsqrt, False, True)   # rsqrt: 양수 로그 분포
        emit_sweep("oos",  oos,   False, True)   # 1/S: 양수 로그 분포

    print("written:", f"{outdir}/all_luts.vh", f"{outdir}/v4_data.vh", f"{outdir}/v4_sweep.vh")

if __name__ == "__main__":
    main()
