// all_luts.vh - generated from learned_luts_wm_ent_N4.xlsx
// word0-4 = x0..x4 (knots), word5-8 = a0..a3, word9-12 = b0..b3
    task set_silu_lut; input [7:0] caddr; input integer idx; begin
        fake_cache[caddr] = 512'd0;
        case (idx)
        0: begin // layer0
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF55;
            fake_cache[caddr][2*16 +: 16] = 16'hBBC4;
            fake_cache[caddr][3*16 +: 16] = 16'h3F82;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD56;
            fake_cache[caddr][6*16 +: 16] = 16'h3EAA;
            fake_cache[caddr][7*16 +: 16] = 16'h3F11;
            fake_cache[caddr][8*16 +: 16] = 16'h3F95;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA8;
            fake_cache[caddr][10*16 +: 16] = 16'hBC15;
            fake_cache[caddr][11*16 +: 16] = 16'hBBFC;
            fake_cache[caddr][12*16 +: 16] = 16'hBF1D;
        end
        1: begin // layer1
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF69;
            fake_cache[caddr][2*16 +: 16] = 16'hBD19;
            fake_cache[caddr][3*16 +: 16] = 16'h3F82;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD8F;
            fake_cache[caddr][6*16 +: 16] = 16'h3E9D;
            fake_cache[caddr][7*16 +: 16] = 16'h3F18;
            fake_cache[caddr][8*16 +: 16] = 16'h3F99;
            fake_cache[caddr][9*16 +: 16] = 16'hBEB7;
            fake_cache[caddr][10*16 +: 16] = 16'hBC7D;
            fake_cache[caddr][11*16 +: 16] = 16'hBB97;
            fake_cache[caddr][12*16 +: 16] = 16'hBF1F;
        end
        2: begin // layer2
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF6B;
            fake_cache[caddr][2*16 +: 16] = 16'hBD33;
            fake_cache[caddr][3*16 +: 16] = 16'h3F7E;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD78;
            fake_cache[caddr][6*16 +: 16] = 16'h3E90;
            fake_cache[caddr][7*16 +: 16] = 16'h3F17;
            fake_cache[caddr][8*16 +: 16] = 16'h3F8F;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA9;
            fake_cache[caddr][10*16 +: 16] = 16'hBC8D;
            fake_cache[caddr][11*16 +: 16] = 16'hBB70;
            fake_cache[caddr][12*16 +: 16] = 16'hBF06;
        end
        3: begin // layer3
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF65;
            fake_cache[caddr][2*16 +: 16] = 16'hBDA7;
            fake_cache[caddr][3*16 +: 16] = 16'h3F79;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD5B;
            fake_cache[caddr][6*16 +: 16] = 16'h3E8C;
            fake_cache[caddr][7*16 +: 16] = 16'h3F16;
            fake_cache[caddr][8*16 +: 16] = 16'h3F8D;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA5;
            fake_cache[caddr][10*16 +: 16] = 16'hBCE9;
            fake_cache[caddr][11*16 +: 16] = 16'hBB47;
            fake_cache[caddr][12*16 +: 16] = 16'hBF01;
        end
        4: begin // layer4
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF66;
            fake_cache[caddr][2*16 +: 16] = 16'hBDB4;
            fake_cache[caddr][3*16 +: 16] = 16'h3F79;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD53;
            fake_cache[caddr][6*16 +: 16] = 16'h3E8C;
            fake_cache[caddr][7*16 +: 16] = 16'h3F1C;
            fake_cache[caddr][8*16 +: 16] = 16'h3F8E;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA5;
            fake_cache[caddr][10*16 +: 16] = 16'hBD01;
            fake_cache[caddr][11*16 +: 16] = 16'hBB08;
            fake_cache[caddr][12*16 +: 16] = 16'hBEFA;
        end
        5: begin // layer5
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF62;
            fake_cache[caddr][2*16 +: 16] = 16'hBDA5;
            fake_cache[caddr][3*16 +: 16] = 16'h3F78;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD3C;
            fake_cache[caddr][6*16 +: 16] = 16'h3E8D;
            fake_cache[caddr][7*16 +: 16] = 16'h3F17;
            fake_cache[caddr][8*16 +: 16] = 16'h3F8C;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA0;
            fake_cache[caddr][10*16 +: 16] = 16'hBCE3;
            fake_cache[caddr][11*16 +: 16] = 16'hBB27;
            fake_cache[caddr][12*16 +: 16] = 16'hBEF9;
        end
        6: begin // layer6
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF63;
            fake_cache[caddr][2*16 +: 16] = 16'hBDAD;
            fake_cache[caddr][3*16 +: 16] = 16'h3F7C;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD39;
            fake_cache[caddr][6*16 +: 16] = 16'h3E8D;
            fake_cache[caddr][7*16 +: 16] = 16'h3F1A;
            fake_cache[caddr][8*16 +: 16] = 16'h3F8F;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA1;
            fake_cache[caddr][10*16 +: 16] = 16'hBD01;
            fake_cache[caddr][11*16 +: 16] = 16'hBB84;
            fake_cache[caddr][12*16 +: 16] = 16'hBF04;
        end
        7: begin // layer7
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF66;
            fake_cache[caddr][2*16 +: 16] = 16'hBDAF;
            fake_cache[caddr][3*16 +: 16] = 16'h3F7A;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD4C;
            fake_cache[caddr][6*16 +: 16] = 16'h3E8E;
            fake_cache[caddr][7*16 +: 16] = 16'h3F1B;
            fake_cache[caddr][8*16 +: 16] = 16'h3F91;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA6;
            fake_cache[caddr][10*16 +: 16] = 16'hBD03;
            fake_cache[caddr][11*16 +: 16] = 16'hBB78;
            fake_cache[caddr][12*16 +: 16] = 16'hBF05;
        end
        8: begin // layer8
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF65;
            fake_cache[caddr][2*16 +: 16] = 16'hBDA9;
            fake_cache[caddr][3*16 +: 16] = 16'h3F6D;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD25;
            fake_cache[caddr][6*16 +: 16] = 16'h3E8B;
            fake_cache[caddr][7*16 +: 16] = 16'h3F1C;
            fake_cache[caddr][8*16 +: 16] = 16'h3F88;
            fake_cache[caddr][9*16 +: 16] = 16'hBE9F;
            fake_cache[caddr][10*16 +: 16] = 16'hBD06;
            fake_cache[caddr][11*16 +: 16] = 16'hBB98;
            fake_cache[caddr][12*16 +: 16] = 16'hBED7;
        end
        9: begin // layer9
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF68;
            fake_cache[caddr][2*16 +: 16] = 16'hBDB7;
            fake_cache[caddr][3*16 +: 16] = 16'h3F64;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD40;
            fake_cache[caddr][6*16 +: 16] = 16'h3E89;
            fake_cache[caddr][7*16 +: 16] = 16'h3F1E;
            fake_cache[caddr][8*16 +: 16] = 16'h3F87;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA4;
            fake_cache[caddr][10*16 +: 16] = 16'hBD16;
            fake_cache[caddr][11*16 +: 16] = 16'hBBB6;
            fake_cache[caddr][12*16 +: 16] = 16'hBECC;
        end
        10: begin // layer10
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF60;
            fake_cache[caddr][2*16 +: 16] = 16'hBDA6;
            fake_cache[caddr][3*16 +: 16] = 16'h3F6D;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD10;
            fake_cache[caddr][6*16 +: 16] = 16'h3E8D;
            fake_cache[caddr][7*16 +: 16] = 16'h3F1E;
            fake_cache[caddr][8*16 +: 16] = 16'h3F87;
            fake_cache[caddr][9*16 +: 16] = 16'hBE9C;
            fake_cache[caddr][10*16 +: 16] = 16'hBD09;
            fake_cache[caddr][11*16 +: 16] = 16'hBBC2;
            fake_cache[caddr][12*16 +: 16] = 16'hBED3;
        end
        11: begin // layer11
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF5A;
            fake_cache[caddr][2*16 +: 16] = 16'hBDA0;
            fake_cache[caddr][3*16 +: 16] = 16'h3F6A;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD24;
            fake_cache[caddr][6*16 +: 16] = 16'h3E92;
            fake_cache[caddr][7*16 +: 16] = 16'h3F23;
            fake_cache[caddr][8*16 +: 16] = 16'h3F89;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA0;
            fake_cache[caddr][10*16 +: 16] = 16'hBD0A;
            fake_cache[caddr][11*16 +: 16] = 16'hBBC5;
            fake_cache[caddr][12*16 +: 16] = 16'hBECD;
        end
        12: begin // layer12
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF59;
            fake_cache[caddr][2*16 +: 16] = 16'hBD50;
            fake_cache[caddr][3*16 +: 16] = 16'h3F5C;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD6B;
            fake_cache[caddr][6*16 +: 16] = 16'h3E9A;
            fake_cache[caddr][7*16 +: 16] = 16'h3F23;
            fake_cache[caddr][8*16 +: 16] = 16'h3F87;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA9;
            fake_cache[caddr][10*16 +: 16] = 16'hBCDA;
            fake_cache[caddr][11*16 +: 16] = 16'hBC1C;
            fake_cache[caddr][12*16 +: 16] = 16'hBEBC;
        end
        13: begin // layer13
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF4E;
            fake_cache[caddr][2*16 +: 16] = 16'hBC0A;
            fake_cache[caddr][3*16 +: 16] = 16'h3F59;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD4A;
            fake_cache[caddr][6*16 +: 16] = 16'h3EA6;
            fake_cache[caddr][7*16 +: 16] = 16'h3F2B;
            fake_cache[caddr][8*16 +: 16] = 16'h3F87;
            fake_cache[caddr][9*16 +: 16] = 16'hBEA5;
            fake_cache[caddr][10*16 +: 16] = 16'hBCA9;
            fake_cache[caddr][11*16 +: 16] = 16'hBC92;
            fake_cache[caddr][12*16 +: 16] = 16'hBEB3;
        end
        14: begin // layer14
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF5E;
            fake_cache[caddr][2*16 +: 16] = 16'hBD7B;
            fake_cache[caddr][3*16 +: 16] = 16'h3F3B;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD86;
            fake_cache[caddr][6*16 +: 16] = 16'h3E9C;
            fake_cache[caddr][7*16 +: 16] = 16'h3F25;
            fake_cache[caddr][8*16 +: 16] = 16'h3F85;
            fake_cache[caddr][9*16 +: 16] = 16'hBEB4;
            fake_cache[caddr][10*16 +: 16] = 16'hBCF0;
            fake_cache[caddr][11*16 +: 16] = 16'hBC0C;
            fake_cache[caddr][12*16 +: 16] = 16'hBE97;
        end
        15: begin // layer15
            fake_cache[caddr][0*16 +: 16] = 16'hC080;
            fake_cache[caddr][1*16 +: 16] = 16'hBF5D;
            fake_cache[caddr][2*16 +: 16] = 16'hBC28;
            fake_cache[caddr][3*16 +: 16] = 16'h3F3B;
            fake_cache[caddr][4*16 +: 16] = 16'h4080;
            fake_cache[caddr][5*16 +: 16] = 16'hBD83;
            fake_cache[caddr][6*16 +: 16] = 16'h3EA6;
            fake_cache[caddr][7*16 +: 16] = 16'h3F2A;
            fake_cache[caddr][8*16 +: 16] = 16'h3F82;
            fake_cache[caddr][9*16 +: 16] = 16'hBEB6;
            fake_cache[caddr][10*16 +: 16] = 16'hBCA4;
            fake_cache[caddr][11*16 +: 16] = 16'hBC88;
            fake_cache[caddr][12*16 +: 16] = 16'hBE8E;
        end
        endcase
    end endtask

    task set_exp_lut; input [7:0] caddr; input integer idx; begin
        fake_cache[caddr] = 512'd0;
        case (idx)
        0: begin // global
            fake_cache[caddr][0*16 +: 16] = 16'hC100;
            fake_cache[caddr][1*16 +: 16] = 16'hC0A2;
            fake_cache[caddr][2*16 +: 16] = 16'hC03A;
            fake_cache[caddr][3*16 +: 16] = 16'hBF9E;
            fake_cache[caddr][4*16 +: 16] = 16'h0000;
            fake_cache[caddr][5*16 +: 16] = 16'h3B07;
            fake_cache[caddr][6*16 +: 16] = 16'h3CB9;
            fake_cache[caddr][7*16 +: 16] = 16'h3E11;
            fake_cache[caddr][8*16 +: 16] = 16'h3F13;
            fake_cache[caddr][9*16 +: 16] = 16'h3C8A;
            fake_cache[caddr][10*16 +: 16] = 16'h3DF6;
            fake_cache[caddr][11*16 +: 16] = 16'h3EEE;
            fake_cache[caddr][12*16 +: 16] = 16'h3F80;
        end
        endcase
    end endtask

    task set_rsqrt_lut; input [7:0] caddr; input integer idx; begin
        fake_cache[caddr] = 512'd0;
        case (idx)
        0: begin // model.layers.0.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h397C;
            fake_cache[caddr][1*16 +: 16] = 16'h39C0;
            fake_cache[caddr][2*16 +: 16] = 16'h39FE;
            fake_cache[caddr][3*16 +: 16] = 16'h3A2A;
            fake_cache[caddr][4*16 +: 16] = 16'h3A5F;
            fake_cache[caddr][5*16 +: 16] = 16'hC7A1;
            fake_cache[caddr][6*16 +: 16] = 16'hC775;
            fake_cache[caddr][7*16 +: 16] = 16'hC717;
            fake_cache[caddr][8*16 +: 16] = 16'hC6FC;
            fake_cache[caddr][9*16 +: 16] = 16'h42AA;
            fake_cache[caddr][10*16 +: 16] = 16'h429C;
            fake_cache[caddr][11*16 +: 16] = 16'h4284;
            fake_cache[caddr][12*16 +: 16] = 16'h4278;
        end
        1: begin // model.layers.0.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h39A5;
            fake_cache[caddr][1*16 +: 16] = 16'h3A04;
            fake_cache[caddr][2*16 +: 16] = 16'h3A42;
            fake_cache[caddr][3*16 +: 16] = 16'h3A86;
            fake_cache[caddr][4*16 +: 16] = 16'h3ABC;
            fake_cache[caddr][5*16 +: 16] = 16'hC74C;
            fake_cache[caddr][6*16 +: 16] = 16'hC6FF;
            fake_cache[caddr][7*16 +: 16] = 16'hC6C1;
            fake_cache[caddr][8*16 +: 16] = 16'hC663;
            fake_cache[caddr][9*16 +: 16] = 16'h4292;
            fake_cache[caddr][10*16 +: 16] = 16'h427C;
            fake_cache[caddr][11*16 +: 16] = 16'h4265;
            fake_cache[caddr][12*16 +: 16] = 16'h423B;
        end
        2: begin // model.layers.1.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h39D5;
            fake_cache[caddr][1*16 +: 16] = 16'h3B3B;
            fake_cache[caddr][2*16 +: 16] = 16'h3C9E;
            fake_cache[caddr][3*16 +: 16] = 16'h3E30;
            fake_cache[caddr][4*16 +: 16] = 16'h3FC3;
            fake_cache[caddr][5*16 +: 16] = 16'hC62C;
            fake_cache[caddr][6*16 +: 16] = 16'hC431;
            fake_cache[caddr][7*16 +: 16] = 16'hC1D9;
            fake_cache[caddr][8*16 +: 16] = 16'hBF88;
            fake_cache[caddr][9*16 +: 16] = 16'h4246;
            fake_cache[caddr][10*16 +: 16] = 16'h41A0;
            fake_cache[caddr][11*16 +: 16] = 16'h40DF;
            fake_cache[caddr][12*16 +: 16] = 16'h401F;
        end
        3: begin // model.layers.1.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3A84;
            fake_cache[caddr][1*16 +: 16] = 16'h3BB3;
            fake_cache[caddr][2*16 +: 16] = 16'h3D05;
            fake_cache[caddr][3*16 +: 16] = 16'h3E44;
            fake_cache[caddr][4*16 +: 16] = 16'h3F95;
            fake_cache[caddr][5*16 +: 16] = 16'hC56D;
            fake_cache[caddr][6*16 +: 16] = 16'hC389;
            fake_cache[caddr][7*16 +: 16] = 16'hC1C1;
            fake_cache[caddr][8*16 +: 16] = 16'hBF8B;
            fake_cache[caddr][9*16 +: 16] = 16'h4208;
            fake_cache[caddr][10*16 +: 16] = 16'h416B;
            fake_cache[caddr][11*16 +: 16] = 16'h40D2;
            fake_cache[caddr][12*16 +: 16] = 16'h400A;
        end
        4: begin // model.layers.2.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3A8A;
            fake_cache[caddr][1*16 +: 16] = 16'h3C35;
            fake_cache[caddr][2*16 +: 16] = 16'h3EBE;
            fake_cache[caddr][3*16 +: 16] = 16'h4147;
            fake_cache[caddr][4*16 +: 16] = 16'h43C1;
            fake_cache[caddr][5*16 +: 16] = 16'hC513;
            fake_cache[caddr][6*16 +: 16] = 16'hC147;
            fake_cache[caddr][7*16 +: 16] = 16'hBDE7;
            fake_cache[caddr][8*16 +: 16] = 16'hB9D0;
            fake_cache[caddr][9*16 +: 16] = 16'h4200;
            fake_cache[caddr][10*16 +: 16] = 16'h40C5;
            fake_cache[caddr][11*16 +: 16] = 16'h3FCD;
            fake_cache[caddr][12*16 +: 16] = 16'h3E55;
        end
        5: begin // model.layers.2.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3AE4;
            fake_cache[caddr][1*16 +: 16] = 16'h3C96;
            fake_cache[caddr][2*16 +: 16] = 16'h3F01;
            fake_cache[caddr][3*16 +: 16] = 16'h415F;
            fake_cache[caddr][4*16 +: 16] = 16'h43C1;
            fake_cache[caddr][5*16 +: 16] = 16'hC488;
            fake_cache[caddr][6*16 +: 16] = 16'hC0FD;
            fake_cache[caddr][7*16 +: 16] = 16'hBD8D;
            fake_cache[caddr][8*16 +: 16] = 16'hB9B6;
            fake_cache[caddr][9*16 +: 16] = 16'h41C7;
            fake_cache[caddr][10*16 +: 16] = 16'h40A3;
            fake_cache[caddr][11*16 +: 16] = 16'h3F92;
            fake_cache[caddr][12*16 +: 16] = 16'h3E3B;
        end
        6: begin // model.layers.3.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3AF9;
            fake_cache[caddr][1*16 +: 16] = 16'h3CA7;
            fake_cache[caddr][2*16 +: 16] = 16'h3F0A;
            fake_cache[caddr][3*16 +: 16] = 16'h4164;
            fake_cache[caddr][4*16 +: 16] = 16'h43C1;
            fake_cache[caddr][5*16 +: 16] = 16'hC469;
            fake_cache[caddr][6*16 +: 16] = 16'hC0E6;
            fake_cache[caddr][7*16 +: 16] = 16'hBD82;
            fake_cache[caddr][8*16 +: 16] = 16'hB9BE;
            fake_cache[caddr][9*16 +: 16] = 16'h41BF;
            fake_cache[caddr][10*16 +: 16] = 16'h409E;
            fake_cache[caddr][11*16 +: 16] = 16'h3F8C;
            fake_cache[caddr][12*16 +: 16] = 16'h3E45;
        end
        7: begin // model.layers.3.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3B3E;
            fake_cache[caddr][1*16 +: 16] = 16'h3CD8;
            fake_cache[caddr][2*16 +: 16] = 16'h3F25;
            fake_cache[caddr][3*16 +: 16] = 16'h417C;
            fake_cache[caddr][4*16 +: 16] = 16'h43C1;
            fake_cache[caddr][5*16 +: 16] = 16'hC415;
            fake_cache[caddr][6*16 +: 16] = 16'hC09E;
            fake_cache[caddr][7*16 +: 16] = 16'hBD59;
            fake_cache[caddr][8*16 +: 16] = 16'hB9AF;
            fake_cache[caddr][9*16 +: 16] = 16'h419E;
            fake_cache[caddr][10*16 +: 16] = 16'h4085;
            fake_cache[caddr][11*16 +: 16] = 16'h3F81;
            fake_cache[caddr][12*16 +: 16] = 16'h3E35;
        end
        8: begin // model.layers.4.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3B34;
            fake_cache[caddr][1*16 +: 16] = 16'h3CEA;
            fake_cache[caddr][2*16 +: 16] = 16'h3F2D;
            fake_cache[caddr][3*16 +: 16] = 16'h4180;
            fake_cache[caddr][4*16 +: 16] = 16'h43C1;
            fake_cache[caddr][5*16 +: 16] = 16'hC40A;
            fake_cache[caddr][6*16 +: 16] = 16'hC09E;
            fake_cache[caddr][7*16 +: 16] = 16'hBD4E;
            fake_cache[caddr][8*16 +: 16] = 16'hB9B9;
            fake_cache[caddr][9*16 +: 16] = 16'h419F;
            fake_cache[caddr][10*16 +: 16] = 16'h408A;
            fake_cache[caddr][11*16 +: 16] = 16'h3F7D;
            fake_cache[caddr][12*16 +: 16] = 16'h3E42;
        end
        9: begin // model.layers.4.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3B96;
            fake_cache[caddr][1*16 +: 16] = 16'h3D15;
            fake_cache[caddr][2*16 +: 16] = 16'h3F4D;
            fake_cache[caddr][3*16 +: 16] = 16'h418D;
            fake_cache[caddr][4*16 +: 16] = 16'h43C1;
            fake_cache[caddr][5*16 +: 16] = 16'hC3AF;
            fake_cache[caddr][6*16 +: 16] = 16'hC050;
            fake_cache[caddr][7*16 +: 16] = 16'hBD2B;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A8;
            fake_cache[caddr][9*16 +: 16] = 16'h4181;
            fake_cache[caddr][10*16 +: 16] = 16'h405E;
            fake_cache[caddr][11*16 +: 16] = 16'h3F67;
            fake_cache[caddr][12*16 +: 16] = 16'h3E2F;
        end
        10: begin // model.layers.5.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3B61;
            fake_cache[caddr][1*16 +: 16] = 16'h3D0A;
            fake_cache[caddr][2*16 +: 16] = 16'h3F3E;
            fake_cache[caddr][3*16 +: 16] = 16'h4184;
            fake_cache[caddr][4*16 +: 16] = 16'h43C1;
            fake_cache[caddr][5*16 +: 16] = 16'hC3CF;
            fake_cache[caddr][6*16 +: 16] = 16'hC086;
            fake_cache[caddr][7*16 +: 16] = 16'hBD2D;
            fake_cache[caddr][8*16 +: 16] = 16'hB9B6;
            fake_cache[caddr][9*16 +: 16] = 16'h418E;
            fake_cache[caddr][10*16 +: 16] = 16'h407D;
            fake_cache[caddr][11*16 +: 16] = 16'h3F61;
            fake_cache[caddr][12*16 +: 16] = 16'h3E40;
        end
        11: begin // model.layers.5.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3BA5;
            fake_cache[caddr][1*16 +: 16] = 16'h3D37;
            fake_cache[caddr][2*16 +: 16] = 16'h3F6B;
            fake_cache[caddr][3*16 +: 16] = 16'h4197;
            fake_cache[caddr][4*16 +: 16] = 16'h43C1;
            fake_cache[caddr][5*16 +: 16] = 16'hC385;
            fake_cache[caddr][6*16 +: 16] = 16'hC031;
            fake_cache[caddr][7*16 +: 16] = 16'hBD1C;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A7;
            fake_cache[caddr][9*16 +: 16] = 16'h4171;
            fake_cache[caddr][10*16 +: 16] = 16'h4058;
            fake_cache[caddr][11*16 +: 16] = 16'h3F62;
            fake_cache[caddr][12*16 +: 16] = 16'h3E30;
        end
        12: begin // model.layers.6.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3B8F;
            fake_cache[caddr][1*16 +: 16] = 16'h3D2A;
            fake_cache[caddr][2*16 +: 16] = 16'h3F60;
            fake_cache[caddr][3*16 +: 16] = 16'h4194;
            fake_cache[caddr][4*16 +: 16] = 16'h43C2;
            fake_cache[caddr][5*16 +: 16] = 16'hC396;
            fake_cache[caddr][6*16 +: 16] = 16'hC049;
            fake_cache[caddr][7*16 +: 16] = 16'hBD1A;
            fake_cache[caddr][8*16 +: 16] = 16'hB9AF;
            fake_cache[caddr][9*16 +: 16] = 16'h417F;
            fake_cache[caddr][10*16 +: 16] = 16'h4066;
            fake_cache[caddr][11*16 +: 16] = 16'h3F60;
            fake_cache[caddr][12*16 +: 16] = 16'h3E3B;
        end
        13: begin // model.layers.6.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3BC6;
            fake_cache[caddr][1*16 +: 16] = 16'h3D46;
            fake_cache[caddr][2*16 +: 16] = 16'h3F77;
            fake_cache[caddr][3*16 +: 16] = 16'h419B;
            fake_cache[caddr][4*16 +: 16] = 16'h43C2;
            fake_cache[caddr][5*16 +: 16] = 16'hC365;
            fake_cache[caddr][6*16 +: 16] = 16'hC019;
            fake_cache[caddr][7*16 +: 16] = 16'hBD10;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A5;
            fake_cache[caddr][9*16 +: 16] = 16'h4161;
            fake_cache[caddr][10*16 +: 16] = 16'h4048;
            fake_cache[caddr][11*16 +: 16] = 16'h3F58;
            fake_cache[caddr][12*16 +: 16] = 16'h3E2E;
        end
        14: begin // model.layers.7.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3BAC;
            fake_cache[caddr][1*16 +: 16] = 16'h3D40;
            fake_cache[caddr][2*16 +: 16] = 16'h3F71;
            fake_cache[caddr][3*16 +: 16] = 16'h4198;
            fake_cache[caddr][4*16 +: 16] = 16'h43C2;
            fake_cache[caddr][5*16 +: 16] = 16'hC378;
            fake_cache[caddr][6*16 +: 16] = 16'hC034;
            fake_cache[caddr][7*16 +: 16] = 16'hBCF1;
            fake_cache[caddr][8*16 +: 16] = 16'hB9AC;
            fake_cache[caddr][9*16 +: 16] = 16'h416E;
            fake_cache[caddr][10*16 +: 16] = 16'h4057;
            fake_cache[caddr][11*16 +: 16] = 16'h3F3C;
            fake_cache[caddr][12*16 +: 16] = 16'h3E38;
        end
        15: begin // model.layers.7.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3BE1;
            fake_cache[caddr][1*16 +: 16] = 16'h3D5E;
            fake_cache[caddr][2*16 +: 16] = 16'h3F86;
            fake_cache[caddr][3*16 +: 16] = 16'h41A1;
            fake_cache[caddr][4*16 +: 16] = 16'h43C2;
            fake_cache[caddr][5*16 +: 16] = 16'hC33D;
            fake_cache[caddr][6*16 +: 16] = 16'hC006;
            fake_cache[caddr][7*16 +: 16] = 16'hBD05;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A4;
            fake_cache[caddr][9*16 +: 16] = 16'h4152;
            fake_cache[caddr][10*16 +: 16] = 16'h403E;
            fake_cache[caddr][11*16 +: 16] = 16'h3F51;
            fake_cache[caddr][12*16 +: 16] = 16'h3E2E;
        end
        16: begin // model.layers.8.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3BDF;
            fake_cache[caddr][1*16 +: 16] = 16'h3D60;
            fake_cache[caddr][2*16 +: 16] = 16'h3F88;
            fake_cache[caddr][3*16 +: 16] = 16'h41A6;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC340;
            fake_cache[caddr][6*16 +: 16] = 16'hC005;
            fake_cache[caddr][7*16 +: 16] = 16'hBD00;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A9;
            fake_cache[caddr][9*16 +: 16] = 16'h4156;
            fake_cache[caddr][10*16 +: 16] = 16'h403F;
            fake_cache[caddr][11*16 +: 16] = 16'h3F52;
            fake_cache[caddr][12*16 +: 16] = 16'h3E37;
        end
        17: begin // model.layers.8.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3BFD;
            fake_cache[caddr][1*16 +: 16] = 16'h3D6C;
            fake_cache[caddr][2*16 +: 16] = 16'h3F8C;
            fake_cache[caddr][3*16 +: 16] = 16'h41A5;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC32A;
            fake_cache[caddr][6*16 +: 16] = 16'hBFF2;
            fake_cache[caddr][7*16 +: 16] = 16'hBCFA;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A2;
            fake_cache[caddr][9*16 +: 16] = 16'h4149;
            fake_cache[caddr][10*16 +: 16] = 16'h4035;
            fake_cache[caddr][11*16 +: 16] = 16'h3F4B;
            fake_cache[caddr][12*16 +: 16] = 16'h3E2D;
        end
        18: begin // model.layers.9.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3BE6;
            fake_cache[caddr][1*16 +: 16] = 16'h3D80;
            fake_cache[caddr][2*16 +: 16] = 16'h3F96;
            fake_cache[caddr][3*16 +: 16] = 16'h41B1;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC31E;
            fake_cache[caddr][6*16 +: 16] = 16'hBFF2;
            fake_cache[caddr][7*16 +: 16] = 16'hBCE7;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A6;
            fake_cache[caddr][9*16 +: 16] = 16'h414C;
            fake_cache[caddr][10*16 +: 16] = 16'h403F;
            fake_cache[caddr][11*16 +: 16] = 16'h3F4B;
            fake_cache[caddr][12*16 +: 16] = 16'h3E35;
        end
        19: begin // model.layers.9.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3C2B;
            fake_cache[caddr][1*16 +: 16] = 16'h3D9C;
            fake_cache[caddr][2*16 +: 16] = 16'h3FA8;
            fake_cache[caddr][3*16 +: 16] = 16'h41B5;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC2DB;
            fake_cache[caddr][6*16 +: 16] = 16'hBFB1;
            fake_cache[caddr][7*16 +: 16] = 16'hBCD2;
            fake_cache[caddr][8*16 +: 16] = 16'hB99D;
            fake_cache[caddr][9*16 +: 16] = 16'h412C;
            fake_cache[caddr][10*16 +: 16] = 16'h4021;
            fake_cache[caddr][11*16 +: 16] = 16'h3F3D;
            fake_cache[caddr][12*16 +: 16] = 16'h3E29;
        end
        20: begin // model.layers.10.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3C22;
            fake_cache[caddr][1*16 +: 16] = 16'h3DB7;
            fake_cache[caddr][2*16 +: 16] = 16'h3FBC;
            fake_cache[caddr][3*16 +: 16] = 16'h41C1;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC2B3;
            fake_cache[caddr][6*16 +: 16] = 16'hBFA6;
            fake_cache[caddr][7*16 +: 16] = 16'hBCD6;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A8;
            fake_cache[caddr][9*16 +: 16] = 16'h4129;
            fake_cache[caddr][10*16 +: 16] = 16'h402A;
            fake_cache[caddr][11*16 +: 16] = 16'h3F4D;
            fake_cache[caddr][12*16 +: 16] = 16'h3E37;
        end
        21: begin // model.layers.10.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3C4D;
            fake_cache[caddr][1*16 +: 16] = 16'h3DC0;
            fake_cache[caddr][2*16 +: 16] = 16'h3FC1;
            fake_cache[caddr][3*16 +: 16] = 16'h41C2;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC29F;
            fake_cache[caddr][6*16 +: 16] = 16'hBF90;
            fake_cache[caddr][7*16 +: 16] = 16'hBCBA;
            fake_cache[caddr][8*16 +: 16] = 16'hB999;
            fake_cache[caddr][9*16 +: 16] = 16'h411B;
            fake_cache[caddr][10*16 +: 16] = 16'h4017;
            fake_cache[caddr][11*16 +: 16] = 16'h3F35;
            fake_cache[caddr][12*16 +: 16] = 16'h3E26;
        end
        22: begin // model.layers.11.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3C68;
            fake_cache[caddr][1*16 +: 16] = 16'h3DF7;
            fake_cache[caddr][2*16 +: 16] = 16'h3FE0;
            fake_cache[caddr][3*16 +: 16] = 16'h41CB;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC25F;
            fake_cache[caddr][6*16 +: 16] = 16'hBF85;
            fake_cache[caddr][7*16 +: 16] = 16'hBC72;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A3;
            fake_cache[caddr][9*16 +: 16] = 16'h410F;
            fake_cache[caddr][10*16 +: 16] = 16'h4015;
            fake_cache[caddr][11*16 +: 16] = 16'h3F0B;
            fake_cache[caddr][12*16 +: 16] = 16'h3E34;
        end
        23: begin // model.layers.11.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3C68;
            fake_cache[caddr][1*16 +: 16] = 16'h3DED;
            fake_cache[caddr][2*16 +: 16] = 16'h3FDE;
            fake_cache[caddr][3*16 +: 16] = 16'h41D0;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC25F;
            fake_cache[caddr][6*16 +: 16] = 16'hBF72;
            fake_cache[caddr][7*16 +: 16] = 16'hBCA9;
            fake_cache[caddr][8*16 +: 16] = 16'hB993;
            fake_cache[caddr][9*16 +: 16] = 16'h410A;
            fake_cache[caddr][10*16 +: 16] = 16'h4013;
            fake_cache[caddr][11*16 +: 16] = 16'h3F30;
            fake_cache[caddr][12*16 +: 16] = 16'h3E21;
        end
        24: begin // model.layers.12.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3C8C;
            fake_cache[caddr][1*16 +: 16] = 16'h3E1B;
            fake_cache[caddr][2*16 +: 16] = 16'h4004;
            fake_cache[caddr][3*16 +: 16] = 16'h41DF;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC21A;
            fake_cache[caddr][6*16 +: 16] = 16'hBF44;
            fake_cache[caddr][7*16 +: 16] = 16'hBC8A;
            fake_cache[caddr][8*16 +: 16] = 16'hB9A4;
            fake_cache[caddr][9*16 +: 16] = 16'h40FD;
            fake_cache[caddr][10*16 +: 16] = 16'h400C;
            fake_cache[caddr][11*16 +: 16] = 16'h3F24;
            fake_cache[caddr][12*16 +: 16] = 16'h3E37;
        end
        25: begin // model.layers.12.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3C89;
            fake_cache[caddr][1*16 +: 16] = 16'h3E19;
            fake_cache[caddr][2*16 +: 16] = 16'h4004;
            fake_cache[caddr][3*16 +: 16] = 16'h41E3;
            fake_cache[caddr][4*16 +: 16] = 16'h43C4;
            fake_cache[caddr][5*16 +: 16] = 16'hC215;
            fake_cache[caddr][6*16 +: 16] = 16'hBF44;
            fake_cache[caddr][7*16 +: 16] = 16'hBC95;
            fake_cache[caddr][8*16 +: 16] = 16'hB991;
            fake_cache[caddr][9*16 +: 16] = 16'h40F5;
            fake_cache[caddr][10*16 +: 16] = 16'h400D;
            fake_cache[caddr][11*16 +: 16] = 16'h3F2A;
            fake_cache[caddr][12*16 +: 16] = 16'h3E20;
        end
        26: begin // model.layers.13.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3CB8;
            fake_cache[caddr][1*16 +: 16] = 16'h3E4E;
            fake_cache[caddr][2*16 +: 16] = 16'h4020;
            fake_cache[caddr][3*16 +: 16] = 16'h41F9;
            fake_cache[caddr][4*16 +: 16] = 16'h43C4;
            fake_cache[caddr][5*16 +: 16] = 16'hC1C8;
            fake_cache[caddr][6*16 +: 16] = 16'hBF10;
            fake_cache[caddr][7*16 +: 16] = 16'hBC72;
            fake_cache[caddr][8*16 +: 16] = 16'hB99C;
            fake_cache[caddr][9*16 +: 16] = 16'h40DD;
            fake_cache[caddr][10*16 +: 16] = 16'h3FFF;
            fake_cache[caddr][11*16 +: 16] = 16'h3F1F;
            fake_cache[caddr][12*16 +: 16] = 16'h3E30;
        end
        27: begin // model.layers.13.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3CAE;
            fake_cache[caddr][1*16 +: 16] = 16'h3E47;
            fake_cache[caddr][2*16 +: 16] = 16'h401D;
            fake_cache[caddr][3*16 +: 16] = 16'h41F8;
            fake_cache[caddr][4*16 +: 16] = 16'h43C4;
            fake_cache[caddr][5*16 +: 16] = 16'hC1BE;
            fake_cache[caddr][6*16 +: 16] = 16'hBEE1;
            fake_cache[caddr][7*16 +: 16] = 16'hBCE2;
            fake_cache[caddr][8*16 +: 16] = 16'hB98B;
            fake_cache[caddr][9*16 +: 16] = 16'h40D1;
            fake_cache[caddr][10*16 +: 16] = 16'h4000;
            fake_cache[caddr][11*16 +: 16] = 16'h3F7F;
            fake_cache[caddr][12*16 +: 16] = 16'h3E1B;
        end
        28: begin // model.layers.14.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3CFD;
            fake_cache[caddr][1*16 +: 16] = 16'h3E87;
            fake_cache[caddr][2*16 +: 16] = 16'h4041;
            fake_cache[caddr][3*16 +: 16] = 16'h420A;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC180;
            fake_cache[caddr][6*16 +: 16] = 16'hBED9;
            fake_cache[caddr][7*16 +: 16] = 16'hBC42;
            fake_cache[caddr][8*16 +: 16] = 16'hB98F;
            fake_cache[caddr][9*16 +: 16] = 16'h40BD;
            fake_cache[caddr][10*16 +: 16] = 16'h3FE6;
            fake_cache[caddr][11*16 +: 16] = 16'h3F0E;
            fake_cache[caddr][12*16 +: 16] = 16'h3E22;
        end
        29: begin // model.layers.14.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3CEA;
            fake_cache[caddr][1*16 +: 16] = 16'h3E86;
            fake_cache[caddr][2*16 +: 16] = 16'h403F;
            fake_cache[caddr][3*16 +: 16] = 16'h4209;
            fake_cache[caddr][4*16 +: 16] = 16'h43C3;
            fake_cache[caddr][5*16 +: 16] = 16'hC16C;
            fake_cache[caddr][6*16 +: 16] = 16'hBE99;
            fake_cache[caddr][7*16 +: 16] = 16'hBCCB;
            fake_cache[caddr][8*16 +: 16] = 16'hB98E;
            fake_cache[caddr][9*16 +: 16] = 16'h40B3;
            fake_cache[caddr][10*16 +: 16] = 16'h3FE8;
            fake_cache[caddr][11*16 +: 16] = 16'h3F7D;
            fake_cache[caddr][12*16 +: 16] = 16'h3E1D;
        end
        30: begin // model.layers.15.input_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3D57;
            fake_cache[caddr][1*16 +: 16] = 16'h3EC5;
            fake_cache[caddr][2*16 +: 16] = 16'h407A;
            fake_cache[caddr][3*16 +: 16] = 16'h421E;
            fake_cache[caddr][4*16 +: 16] = 16'h43C0;
            fake_cache[caddr][5*16 +: 16] = 16'hC10D;
            fake_cache[caddr][6*16 +: 16] = 16'hBE75;
            fake_cache[caddr][7*16 +: 16] = 16'hBC20;
            fake_cache[caddr][8*16 +: 16] = 16'hB98C;
            fake_cache[caddr][9*16 +: 16] = 16'h4097;
            fake_cache[caddr][10*16 +: 16] = 16'h3FB7;
            fake_cache[caddr][11*16 +: 16] = 16'h3F08;
            fake_cache[caddr][12*16 +: 16] = 16'h3E21;
        end
        31: begin // model.layers.15.post_attention_layernorm
            fake_cache[caddr][0*16 +: 16] = 16'h3D1F;
            fake_cache[caddr][1*16 +: 16] = 16'h3EB0;
            fake_cache[caddr][2*16 +: 16] = 16'h4063;
            fake_cache[caddr][3*16 +: 16] = 16'h4212;
            fake_cache[caddr][4*16 +: 16] = 16'h43C0;
            fake_cache[caddr][5*16 +: 16] = 16'hC119;
            fake_cache[caddr][6*16 +: 16] = 16'hBE53;
            fake_cache[caddr][7*16 +: 16] = 16'hBCBF;
            fake_cache[caddr][8*16 +: 16] = 16'hB968;
            fake_cache[caddr][9*16 +: 16] = 16'h409B;
            fake_cache[caddr][10*16 +: 16] = 16'h3FD0;
            fake_cache[caddr][11*16 +: 16] = 16'h3F7B;
            fake_cache[caddr][12*16 +: 16] = 16'h3E0A;
        end
        32: begin // model.norm
            fake_cache[caddr][0*16 +: 16] = 16'h3D8B;
            fake_cache[caddr][1*16 +: 16] = 16'h3E64;
            fake_cache[caddr][2*16 +: 16] = 16'h3F15;
            fake_cache[caddr][3*16 +: 16] = 16'h40C0;
            fake_cache[caddr][4*16 +: 16] = 16'h427F;
            fake_cache[caddr][5*16 +: 16] = 16'hC11F;
            fake_cache[caddr][6*16 +: 16] = 16'hC015;
            fake_cache[caddr][7*16 +: 16] = 16'hBE32;
            fake_cache[caddr][8*16 +: 16] = 16'hBB3D;
            fake_cache[caddr][9*16 +: 16] = 16'h408A;
            fake_cache[caddr][10*16 +: 16] = 16'h4027;
            fake_cache[caddr][11*16 +: 16] = 16'h3FAD;
            fake_cache[caddr][12*16 +: 16] = 16'h3EA7;
        end
        endcase
    end endtask

    task set_recip_lut; input [7:0] caddr; input integer idx; begin
        fake_cache[caddr] = 512'd0;
        case (idx)
        0: begin // layer0
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h4034;
            fake_cache[caddr][2*16 +: 16] = 16'h4105;
            fake_cache[caddr][3*16 +: 16] = 16'h41D4;
            fake_cache[caddr][4*16 +: 16] = 16'h4301;
            fake_cache[caddr][5*16 +: 16] = 16'hBEB0;
            fake_cache[caddr][6*16 +: 16] = 16'hBD0B;
            fake_cache[caddr][7*16 +: 16] = 16'hBB70;
            fake_cache[caddr][8*16 +: 16] = 16'hB9B8;
            fake_cache[caddr][9*16 +: 16] = 16'h3FA0;
            fake_cache[caddr][10*16 +: 16] = 16'h3EC2;
            fake_cache[caddr][11*16 +: 16] = 16'h3E01;
            fake_cache[caddr][12*16 +: 16] = 16'h3D1D;
        end
        1: begin // layer1
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h403E;
            fake_cache[caddr][2*16 +: 16] = 16'h4101;
            fake_cache[caddr][3*16 +: 16] = 16'h41E0;
            fake_cache[caddr][4*16 +: 16] = 16'h4304;
            fake_cache[caddr][5*16 +: 16] = 16'hBE96;
            fake_cache[caddr][6*16 +: 16] = 16'hBD25;
            fake_cache[caddr][7*16 +: 16] = 16'hBB79;
            fake_cache[caddr][8*16 +: 16] = 16'hB991;
            fake_cache[caddr][9*16 +: 16] = 16'h3F97;
            fake_cache[caddr][10*16 +: 16] = 16'h3EDC;
            fake_cache[caddr][11*16 +: 16] = 16'h3E08;
            fake_cache[caddr][12*16 +: 16] = 16'h3D0D;
        end
        2: begin // layer2
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h400D;
            fake_cache[caddr][2*16 +: 16] = 16'h408A;
            fake_cache[caddr][3*16 +: 16] = 16'h4135;
            fake_cache[caddr][4*16 +: 16] = 16'h4205;
            fake_cache[caddr][5*16 +: 16] = 16'hBF07;
            fake_cache[caddr][6*16 +: 16] = 16'hBE00;
            fake_cache[caddr][7*16 +: 16] = 16'hBCAA;
            fake_cache[caddr][8*16 +: 16] = 16'hBAE6;
            fake_cache[caddr][9*16 +: 16] = 16'h3FD1;
            fake_cache[caddr][10*16 +: 16] = 16'h3F42;
            fake_cache[caddr][11*16 +: 16] = 16'h3E9D;
            fake_cache[caddr][12*16 +: 16] = 16'h3DBC;
        end
        3: begin // layer3
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h400D;
            fake_cache[caddr][2*16 +: 16] = 16'h4090;
            fake_cache[caddr][3*16 +: 16] = 16'h4147;
            fake_cache[caddr][4*16 +: 16] = 16'h421E;
            fake_cache[caddr][5*16 +: 16] = 16'hBEE3;
            fake_cache[caddr][6*16 +: 16] = 16'hBDD7;
            fake_cache[caddr][7*16 +: 16] = 16'hBC8C;
            fake_cache[caddr][8*16 +: 16] = 16'hBA87;
            fake_cache[caddr][9*16 +: 16] = 16'h3FB5;
            fake_cache[caddr][10*16 +: 16] = 16'h3F2A;
            fake_cache[caddr][11*16 +: 16] = 16'h3E8A;
            fake_cache[caddr][12*16 +: 16] = 16'h3D90;
        end
        4: begin // layer4
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h4013;
            fake_cache[caddr][2*16 +: 16] = 16'h4097;
            fake_cache[caddr][3*16 +: 16] = 16'h4162;
            fake_cache[caddr][4*16 +: 16] = 16'h4235;
            fake_cache[caddr][5*16 +: 16] = 16'hBEC6;
            fake_cache[caddr][6*16 +: 16] = 16'hBDC4;
            fake_cache[caddr][7*16 +: 16] = 16'hBC75;
            fake_cache[caddr][8*16 +: 16] = 16'hB93C;
            fake_cache[caddr][9*16 +: 16] = 16'h3FA7;
            fake_cache[caddr][10*16 +: 16] = 16'h3F22;
            fake_cache[caddr][11*16 +: 16] = 16'h3E82;
            fake_cache[caddr][12*16 +: 16] = 16'h3D36;
        end
        5: begin // layer5
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h4019;
            fake_cache[caddr][2*16 +: 16] = 16'h409E;
            fake_cache[caddr][3*16 +: 16] = 16'h4150;
            fake_cache[caddr][4*16 +: 16] = 16'h4228;
            fake_cache[caddr][5*16 +: 16] = 16'hBEC1;
            fake_cache[caddr][6*16 +: 16] = 16'hBDB6;
            fake_cache[caddr][7*16 +: 16] = 16'hBC6B;
            fake_cache[caddr][8*16 +: 16] = 16'hBB03;
            fake_cache[caddr][9*16 +: 16] = 16'h3FA8;
            fake_cache[caddr][10*16 +: 16] = 16'h3F1F;
            fake_cache[caddr][11*16 +: 16] = 16'h3E81;
            fake_cache[caddr][12*16 +: 16] = 16'h3DBA;
        end
        6: begin // layer6
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h402B;
            fake_cache[caddr][2*16 +: 16] = 16'h40B0;
            fake_cache[caddr][3*16 +: 16] = 16'h4166;
            fake_cache[caddr][4*16 +: 16] = 16'h4257;
            fake_cache[caddr][5*16 +: 16] = 16'hBE95;
            fake_cache[caddr][6*16 +: 16] = 16'hBD89;
            fake_cache[caddr][7*16 +: 16] = 16'hBC49;
            fake_cache[caddr][8*16 +: 16] = 16'hBA8D;
            fake_cache[caddr][9*16 +: 16] = 16'h3F90;
            fake_cache[caddr][10*16 +: 16] = 16'h3F07;
            fake_cache[caddr][11*16 +: 16] = 16'h3E69;
            fake_cache[caddr][12*16 +: 16] = 16'h3D88;
        end
        7: begin // layer7
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h402C;
            fake_cache[caddr][2*16 +: 16] = 16'h40AF;
            fake_cache[caddr][3*16 +: 16] = 16'h4142;
            fake_cache[caddr][4*16 +: 16] = 16'h4243;
            fake_cache[caddr][5*16 +: 16] = 16'hBE92;
            fake_cache[caddr][6*16 +: 16] = 16'hBD86;
            fake_cache[caddr][7*16 +: 16] = 16'hBC65;
            fake_cache[caddr][8*16 +: 16] = 16'hBB12;
            fake_cache[caddr][9*16 +: 16] = 16'h3F8E;
            fake_cache[caddr][10*16 +: 16] = 16'h3F05;
            fake_cache[caddr][11*16 +: 16] = 16'h3E75;
            fake_cache[caddr][12*16 +: 16] = 16'h3DC6;
        end
        8: begin // layer8
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h402D;
            fake_cache[caddr][2*16 +: 16] = 16'h40AB;
            fake_cache[caddr][3*16 +: 16] = 16'h4134;
            fake_cache[caddr][4*16 +: 16] = 16'h421C;
            fake_cache[caddr][5*16 +: 16] = 16'hBE91;
            fake_cache[caddr][6*16 +: 16] = 16'hBD88;
            fake_cache[caddr][7*16 +: 16] = 16'hBC82;
            fake_cache[caddr][8*16 +: 16] = 16'hBB39;
            fake_cache[caddr][9*16 +: 16] = 16'h3F8E;
            fake_cache[caddr][10*16 +: 16] = 16'h3F06;
            fake_cache[caddr][11*16 +: 16] = 16'h3E83;
            fake_cache[caddr][12*16 +: 16] = 16'h3DDE;
        end
        9: begin // layer9
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h402F;
            fake_cache[caddr][2*16 +: 16] = 16'h40B1;
            fake_cache[caddr][3*16 +: 16] = 16'h4152;
            fake_cache[caddr][4*16 +: 16] = 16'h4247;
            fake_cache[caddr][5*16 +: 16] = 16'hBE92;
            fake_cache[caddr][6*16 +: 16] = 16'hBD84;
            fake_cache[caddr][7*16 +: 16] = 16'hBC4D;
            fake_cache[caddr][8*16 +: 16] = 16'hBAF7;
            fake_cache[caddr][9*16 +: 16] = 16'h3F90;
            fake_cache[caddr][10*16 +: 16] = 16'h3F05;
            fake_cache[caddr][11*16 +: 16] = 16'h3E6A;
            fake_cache[caddr][12*16 +: 16] = 16'h3DB7;
        end
        10: begin // layer10
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h4012;
            fake_cache[caddr][2*16 +: 16] = 16'h4087;
            fake_cache[caddr][3*16 +: 16] = 16'h410D;
            fake_cache[caddr][4*16 +: 16] = 16'h41EC;
            fake_cache[caddr][5*16 +: 16] = 16'hBED3;
            fake_cache[caddr][6*16 +: 16] = 16'hBDDE;
            fake_cache[caddr][7*16 +: 16] = 16'hBCD9;
            fake_cache[caddr][8*16 +: 16] = 16'hBB96;
            fake_cache[caddr][9*16 +: 16] = 16'h3FAF;
            fake_cache[caddr][10*16 +: 16] = 16'h3F2E;
            fake_cache[caddr][11*16 +: 16] = 16'h3EAA;
            fake_cache[caddr][12*16 +: 16] = 16'h3E0D;
        end
        11: begin // layer11
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h4003;
            fake_cache[caddr][2*16 +: 16] = 16'h4074;
            fake_cache[caddr][3*16 +: 16] = 16'h4110;
            fake_cache[caddr][4*16 +: 16] = 16'h41C6;
            fake_cache[caddr][5*16 +: 16] = 16'hBEE4;
            fake_cache[caddr][6*16 +: 16] = 16'hBE08;
            fake_cache[caddr][7*16 +: 16] = 16'hBCEC;
            fake_cache[caddr][8*16 +: 16] = 16'hBB47;
            fake_cache[caddr][9*16 +: 16] = 16'h3FB1;
            fake_cache[caddr][10*16 +: 16] = 16'h3F3F;
            fake_cache[caddr][11*16 +: 16] = 16'h3EB2;
            fake_cache[caddr][12*16 +: 16] = 16'h3DED;
        end
        12: begin // layer12
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h400D;
            fake_cache[caddr][2*16 +: 16] = 16'h407C;
            fake_cache[caddr][3*16 +: 16] = 16'h4106;
            fake_cache[caddr][4*16 +: 16] = 16'h41AA;
            fake_cache[caddr][5*16 +: 16] = 16'hBEDA;
            fake_cache[caddr][6*16 +: 16] = 16'hBE07;
            fake_cache[caddr][7*16 +: 16] = 16'hBCFC;
            fake_cache[caddr][8*16 +: 16] = 16'hBBB4;
            fake_cache[caddr][9*16 +: 16] = 16'h3FB4;
            fake_cache[caddr][10*16 +: 16] = 16'h3F42;
            fake_cache[caddr][11*16 +: 16] = 16'h3EB9;
            fake_cache[caddr][12*16 +: 16] = 16'h3E19;
        end
        13: begin // layer13
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h4009;
            fake_cache[caddr][2*16 +: 16] = 16'h4073;
            fake_cache[caddr][3*16 +: 16] = 16'h4102;
            fake_cache[caddr][4*16 +: 16] = 16'h4197;
            fake_cache[caddr][5*16 +: 16] = 16'hBED2;
            fake_cache[caddr][6*16 +: 16] = 16'hBE0C;
            fake_cache[caddr][7*16 +: 16] = 16'hBD07;
            fake_cache[caddr][8*16 +: 16] = 16'hBBC2;
            fake_cache[caddr][9*16 +: 16] = 16'h3FAD;
            fake_cache[caddr][10*16 +: 16] = 16'h3F44;
            fake_cache[caddr][11*16 +: 16] = 16'h3EBF;
            fake_cache[caddr][12*16 +: 16] = 16'h3E1D;
        end
        14: begin // layer14
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h4011;
            fake_cache[caddr][2*16 +: 16] = 16'h408D;
            fake_cache[caddr][3*16 +: 16] = 16'h4126;
            fake_cache[caddr][4*16 +: 16] = 16'h41DE;
            fake_cache[caddr][5*16 +: 16] = 16'hBEB9;
            fake_cache[caddr][6*16 +: 16] = 16'hBDC6;
            fake_cache[caddr][7*16 +: 16] = 16'hBC9D;
            fake_cache[caddr][8*16 +: 16] = 16'hBB56;
            fake_cache[caddr][9*16 +: 16] = 16'h3F9C;
            fake_cache[caddr][10*16 +: 16] = 16'h3F1F;
            fake_cache[caddr][11*16 +: 16] = 16'h3E8F;
            fake_cache[caddr][12*16 +: 16] = 16'h3DEA;
        end
        15: begin // layer15
            fake_cache[caddr][0*16 +: 16] = 16'h3F80;
            fake_cache[caddr][1*16 +: 16] = 16'h400E;
            fake_cache[caddr][2*16 +: 16] = 16'h4080;
            fake_cache[caddr][3*16 +: 16] = 16'h410E;
            fake_cache[caddr][4*16 +: 16] = 16'h41A6;
            fake_cache[caddr][5*16 +: 16] = 16'hBED1;
            fake_cache[caddr][6*16 +: 16] = 16'hBDF1;
            fake_cache[caddr][7*16 +: 16] = 16'hBCE1;
            fake_cache[caddr][8*16 +: 16] = 16'hBB6E;
            fake_cache[caddr][9*16 +: 16] = 16'h3FAC;
            fake_cache[caddr][10*16 +: 16] = 16'h3F32;
            fake_cache[caddr][11*16 +: 16] = 16'h3EAB;
            fake_cache[caddr][12*16 +: 16] = 16'h3DFC;
        end
        endcase
    end endtask

