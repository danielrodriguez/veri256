module point_add_jaco (clk, rst_n, in_ready, 
px, py, pz, qx, qy, qz, m,
rx, ry, rz, ready); // r=p+q
    input clk, rst_n;
    input in_ready;
    input [255:0] m;
    input [255:0] px;
    input [255:0] py;
    input [255:0] pz;
    input [255:0] qx;
    input [255:0] qy;
    input [255:0] qz;
    output [255:0] rx;
    output [255:0] ry;
    output [255:0] rz;
    output ready;
    
    reg [255:0] x3,y3, z3;
    reg rxReady, ryReady, rzReady;
    reg [255:0] i1, i2, j1, j2, u1,u2,k1,k2, h, f, fsq, v,g, r, rsq, t2, 
    k1g, t2r, z1z2, z1z2sq, t7, t8;
    reg ri1, ri2, rj1, rj2, ru1, ru2, rk1,rk2, 
    rh_f, rfsq, rv, rg,rr, rrsq, rt2, rk1g, rk1_g, rt2r, rz1z2, rz1z2sq, rt7, rt7_h, rt8;

    // modmul z1z2multiplier (clk, rst_n, in_ready, pz, qz, m, z1z2, rz1z2);//z1*z2
    modmul z1z2sqmultiplier (clk, rst_n, rz1z2, z1z2, z1z2, m, z1z2sq, rz1z2sq);//(z1*z2)**2
    
    modmul t7sqmultiplier (clk, rst_n, rt7_h, t7, h, m, t8, rt8);

    // j1 = pz*pz*pz
    // u2 =qz*pz*pz
    modtrimul j1multiplier(clk, rst_n, in_ready, pz, pz, pz, m, i1, j1, ri1, rj1);
    // modmul i1multiplier (clk, rst_n, in_ready, pz, pz, m, i1, ri1);//z1*z1
    // modmul j1multiplier (clk, rst_n, ri1, i1, pz, m, j1, rj1); // i1*z1

    modmul u2multiplier (clk, rst_n, ri1, qx, i1, m, u2, ru2); // i1*x2
    modmul k2multiplier (clk, rst_n, rj1, j1, qy, m, k2, rk2); // y2*j1


    modtrimul j2multiplier(clk, rst_n, in_ready, qz, qz, qz, m, i2, j2, ri2, rj2);
    // modmul i2multiplier (clk, rst_n, in_ready, qz, qz, m, i2, ri2); // z2*z2
    // modmul j2multiplier (clk, rst_n, ri2, i2, qz, m, j2, rj2); // i2*z2

    modmul u1multiplier (clk, rst_n, ri2, px, i2, m, u1, ru1); // i2*x1
    modmul k1multiplier (clk, rst_n, rj2, j2, py, m, k1, rk1); // y1*j2


    modmul fsqmultiplier (clk, rst_n, rh_f, f, f, m, fsq, rfsq);  //f*f
    modmul vmultiplier (clk, rst_n, rfsq, fsq, u1, m, v, rv);  //f*u1
    modmul gmultiplier (clk, rst_n, rfsq, fsq, h, m, g, rg);  //f*h

    modmul rsqmultiplier (clk, rst_n, rr, r, r, m, rsq, rrsq);  //r*r

    modmul k1gmultiplier (clk, rst_n, rk1_g, k1, g, m, k1g, rk1g);  //k1*g
    modmul t2rmultiplier (clk, rst_n, rt2, t2, r, m, t2r, rt2r);  //t2*r
    
    assign rk1_g = rk1 & rg;
    assign rt7_h = rt7 & rh_f;
    always @(posedge clk or negedge rst_n) begin
       
        if (!rst_n) begin
           rxReady=0;
           ryReady =0;
           rzReady =0;
           rr = 0;
           rh_f = 0;
           rt7= 0;
           rt2 = 0;
           rz1z2=0;
        end else begin

            if (!rz1z2 & in_ready) begin
                z1z2 = addMod(pz, qz, m);
                rz1z2 = 1;
            end
            if (!rh_f & in_ready & ru1 & ru2) begin
                 
                h = subMod(u1, u2, m);
                f = addMod(h, h, m);
                rh_f = 1;
            end
            if (!rr & in_ready & rk1 & rk2) begin
                r = subMod(k1, k2, m);
                r = addMod(r, r, m);
                rr = 1;
            end
            if (in_ready & qz == 0) begin
                x3 = px;
                y3 = py;
                z3 = pz;
                rxReady = 1;
                ryReady = 1;
                rzReady = 1;
            end
            if (in_ready & pz == 0) begin
                x3 = qx;
                y3 = qy;
                z3 = qz;
                rxReady = 1;
                ryReady = 1;
                rzReady = 1;
            end
            if (in_ready & pz != 0 & qz != 0 ) begin

                if (!rxReady & rrsq & rg & rv) begin
                    x3 = addMod(rsq, g, m);
                    x3 = subMod(x3, addMod(v,v, m), m);
                    t2 = subMod(v, x3, m);
                    rt2 = 1;
                    rxReady = 1;
                end
                if (!ryReady & rk1g & rt2r) begin
                    y3 = subMod(t2r, addMod(k1g, k1g, m), m);
                    ryReady = 1;
                end
                if (!rt7 & rz1z2sq & ri1 & ri2) begin
                    t7 = subMod(z1z2sq, addMod(i1, i2, m), m);
                    rt7 = 1;
                end
                if (!rzReady & rt8) begin
                    // $display("h= %0h, t7 = %0h", h, t7);
                    z3 = t8;
                    rzReady = 1;
                end

            end

        end
    end 
    
    assign ready = rxReady & ryReady & rzReady;
    assign rx = x3;
    assign ry = y3;
    assign rz = z3;
endmodule


module point_double_jaco_vitis (clk, rst_n, in_ready, 
px, py, pz, m,
rx, ry, rz, ready); 
    input clk, rst_n;
    input in_ready;
    input [255:0] m;
    input [255:0] px;
    input [255:0] py;
    input [255:0] pz;
    output [255:0] rx;
    output [255:0] ry;
    output [255:0] rz;
    output ready;


    reg [255:0] N,E,B,L,M,S;
    reg NReady, EReady, BReady, LReady,  MReady, SReady;
    reg tmp1n2Ready, tmp1sqReady, /*tmp4Ready , tmp4Ready2,*/ tmp6Ready, tmp7Ready, tmp8Ready, tmp9Ready, tmp10Ready, tmp10sqReady, tmp8MReady;
    reg rxReady, ryReady, rzReady;
    reg [255:0] tmp1, tmp1sq, tmp2, tmp3, /*tmp4, tmp4a,*/ tmp5, tmp5sq, tmp6, tmp7, tmp8, tmp8M, tmp9_L, tmp9_2, tmp9_4, tmp10, tmp10sq, tmp11, X2, Y2, Z2;

    modmul nmult (clk, rst_n, in_ready, pz, pz, m, N, NReady);
    modmul emult (clk, rst_n, in_ready, py, py, m, E, EReady); 
    modmul bmult (clk, rst_n, in_ready, px, px, m, B, BReady);
    modmul lmult (clk, rst_n, EReady, E, E, m, L, LReady);
    modmul tmp1mult (clk, rst_n, tmp1n2Ready, tmp1, tmp1, m, tmp1sq, tmp1sqReady);
    // modmul tmp4mult (clk, rst_n, NReady, N, N, m, tmp4, tmp4Ready);
    // modmul tmp4mult2 (clk, rst_n, tmp4Ready, tmp4, 256'h0, m, tmp4a, tmp4Ready2); // this feels idiotic, this is 0
    modmul tmp7mult (clk, rst_n, MReady, M, M, m, tmp7, tmp7Ready);
    modmul tmp8mult (clk, rst_n, tmp8Ready, tmp8, M, m, tmp8M, tmp8MReady);
    modmul tmp10Mult2 (clk, rst_n, tmp10Ready, tmp10, tmp10, m, tmp10sq, tmp10sqReady);

    always @(posedge clk or negedge rst_n) begin
       
        if (!rst_n) begin
           tmp6Ready= 0;
           tmp1n2Ready= 0;
           rxReady=0;
           ryReady=0;
           rzReady=0;
           SReady=0;
           MReady=0;
           tmp8Ready=0;
           tmp10Ready=0;
        end else begin
            if (in_ready & px == 1 & py == 1 & pz == 0) begin
                X2 = 1;
                Y2 = 1;
                Z2 = 0;
                rzReady = 1;
                rxReady = 1;
                ryReady = 1;
            end
            if (!tmp1n2Ready & in_ready & LReady & EReady & BReady) begin
                tmp1= addMod(px, E, m);
                tmp2= addMod(B, L, m);
                tmp1n2Ready= 1;
            end
            if (!SReady & in_ready & tmp1sqReady & tmp1n2Ready) begin
                tmp3 = subMod(tmp1sq, tmp2, m);
                S = addMod(tmp3, tmp3, m);
                SReady = 1;
            end
            if (!tmp6Ready & in_ready & SReady) begin
                tmp6 = addMod(S, S, m);
                tmp6Ready = 1;
            end
            if (!MReady & in_ready &  BReady) begin 
                tmp5 = addMod(B, B, m);
                tmp5sq = addMod(tmp5, B, m);
                M = tmp5sq;
                MReady = 1;
            end
            if (!rxReady & in_ready & tmp7Ready & tmp6Ready) begin 
                // $display("tmp7Ready", tmp7, tmp6);
                X2 = subMod(tmp7, tmp6, m);
                rxReady = 1;
            end
            if (in_ready & rxReady) begin 
                tmp8 = subMod(S, X2, m);
                tmp8Ready = 1;
            end 
            if (!ryReady & in_ready && LReady && tmp8MReady) begin
                tmp9_L = addMod(L, L, m); // can it be combined?
                tmp9_2 = addMod(tmp9_L, tmp9_L, m);
                tmp9_4 = addMod(tmp9_2, tmp9_2, m);
                Y2 = subMod(tmp8M, tmp9_4, m);
                ryReady = 1;
            end
            if (!tmp10Ready & in_ready) begin
                tmp10 = addMod(py, pz, m);
                tmp10Ready = 1;
            end
            if (!rzReady & in_ready && tmp10sqReady & EReady & NReady) begin
                tmp11 = addMod(E, N, m);
                // $display(" %0d %0d %0d",tmp10, tmp10sq, tmp11);
                Z2 = subMod(tmp10sq, tmp11, m);
                rzReady = 1;
            end
        end
    end 
    assign ready = rxReady & ryReady & rzReady;
    assign rx = X2;
    assign ry = Y2;
    assign rz = Z2;
endmodule

    
module point_scalar_mult (clk, rst_n, in_ready, 
px, py, pz, m,
d, qx, qy, qz, ready); 
    input clk, rst_n;
    input in_ready;
    input [255:0] m;
    input [255:0] px;
    input [255:0] py;
    input [255:0] pz;
    input [255:0] d;
    output [255:0] qx;
    output [255:0] qz;
    output [255:0] qy;
    output ready;
    reg [255:0] tmpx, tmpy, tmpz; 
    reg doubler_ready, adder_start, doubler_start, double_rst_n, adder_rst_n, adder_ready;
    reg [255:0] k; // copy of d
    reg [255:0] rx, ry, rz; // point that we keep doubling, r
    reg [255:0] rxd, ryd, rzd; // 2r
    reg [255:0] tmpxa, tmpya, tmpza; 
    t_point_scalar_mult_state state;

    point_double_jaco_vitis dbler (clk, double_rst_n, doubler_start, rx, ry, rz, m, rxd, ryd, rzd, doubler_ready);
    point_add_jaco adder (clk, adder_rst_n, adder_start, rx, ry, rz, tmpx, tmpy, tmpz, m, tmpxa, tmpya, tmpza, adder_ready);
   initial begin
            double_rst_n = 0;
            adder_rst_n = 0;
    end
    always @(posedge clk ) begin
        if (!rst_n) begin
            state = M__INIT;
            k = d;
            // Q
            tmpx = 1;
            tmpy = 1;
            tmpz = 0;
            // R
            rx = px;
            ry = py;
            rz = pz;
            double_rst_n = 0;
            adder_rst_n = 0;
        end else begin
            case (state)
                M__INIT: begin
                    // Q = 0
                    tmpx = 1;
                    tmpy = 1;
                    tmpz = 0;

                        // k = d
                        k = d;
                        // R = P
                        rx = px;
                        ry = py;
                        rz = pz;
                 


                    if (in_ready)
                        state = M__DOUBLING;
                end
                M__DOUBLING: begin
                    if (!double_rst_n) begin // if im holding the reset, stop that and signal ready
                        double_rst_n = 1;
                        doubler_start = 1;
                    end else begin
                        if (doubler_ready) begin

                            doubler_start = 0;
                            state = M__ADDING;
                        end
                    end
                end
                M__ADDING: begin
                    // invariant: rd = 2r
                   if (!adder_rst_n) begin // if im holding the reset stop that and signal ready
                        adder_rst_n = 1;
                        adder_start = k[0];
                    end else begin
                        if (adder_ready | !adder_start ) begin
                            if (k[0] == 1) begin
                                
                                // $display("adder: %0h, %0h, %0h + %0h, %0h, %0h = %0h, %0h, %0h", 
                                // rx, ry, rz, tmpx, tmpy, tmpz, tmpxa, tmpya, tmpza);
                                tmpx = tmpxa;
                                tmpy = tmpya;
                                tmpz = tmpza;
                            end 
                            state = M__SWAP;
                            adder_start = 0;

                        end

                    end

                end
                M__SWAP: begin
                    // $strobe("swapping %0b", k);
                    // k = {1'b0, k[254:0]};
                    k = k >> 1;
                    rx = rxd;
                    ry = ryd;
                    rz = rzd;
                    adder_rst_n = 0;
                    double_rst_n = 0;
                    if (k == 0)
                        state = M__IDLE;
                    else
                        state = M__DOUBLING;
                end
                M__IDLE: state = M__IDLE ;
                default : state = M__INIT ;
            endcase
        end
    end
    
    assign ready = (in_ready && k == 0 && state == M__IDLE);

    assign qx = tmpx;
    assign qy = tmpy;
    assign qz = tmpz;
endmodule


module modinv (clk, rst_n, start, b, a, m, c, ready); // c = b * a^{-1} mod m
    input clk, rst_n;
    input start;
    input [255:0] b, a, m;
    output [255:0] c;
    output ready;
    reg busy;
    reg done, started;
    assign ready = done;
    reg [259:0] u, v, x, y, q, result;
    wire [259:0] x_plus_m = x + q; // x + m
    wire [259:0] y_plus_m = y + q; // y + m
    wire [259:0] u_minus_v = u - v; // u - v
    wire [259:0] r_plus_m = result + q; // r + m
    wire [259:0] r_minus_m = result - q; // r - m
    wire [259:0] r_minus_2m = result - {q[258:0],1'b0}; // r - 2m

    assign c = r_minus_2m[259] ? 
        r_minus_m[259] ? result[259] ? r_plus_m[255:0] 
        : result[255:0] : r_minus_m[255:0] : r_minus_2m[255:0]; // c = b * a^{-1} mod m
    always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                done = 0;
                started = 0;
                busy = 0;
            end else begin
                if (start && !started) begin
                // $display("*********** modinv starts");
                    u = {4'b0,a}; // u = a
                    v = {4'b0,m}; // v = m
                    x = {4'b0,b}; // x = b
                    y = {260'b0}; // y = 0
                    q = {4'b0,m}; // q = m
                    done = 0;
                    started = 1;
                    busy = 1;
                end else begin
                    if (busy && ((u == 1) || (v == 1))) begin // finished
                        done = 1;
                        busy = 0;
                        if (u == 1) begin // if u == 1
                            if (x[259]) begin // if x < 0
                                result = x_plus_m; // c = x + m
                            end else begin // else
                                result = x; // c = x
                            end
                        end else begin // else
                            if (y[259]) begin // if y < 0
                                result = y_plus_m; // c = y + m
                            end else begin // else
                                result = y; // c = y
                            end
                        end
                    end else begin // not finished
                        if (!u[0]) begin // while u & 1 == 0
                            u = {u[259],u[259:1]}; // u = u >> 1
                            if (!x[0]) begin // if x & 1 == 0
                                x = {x[259],x[259:1]}; // x = x >> 1
                            end else begin // else
                                x = {x_plus_m[259],x_plus_m[259:1]}; // x = (x + m) >> 1
                            end
                        end
                        if (!v[0]) begin // while v & 1 == 0
                            v = {v[259],v[259:1]}; // v = v >> 1
                            if (!y[0]) begin // if y & 1 == 0
                                y = {y[259],y[259:1]}; // y = y >> 1
                            end else begin // else
                                y = {y_plus_m[259],y_plus_m[259:1]}; // y = (y + m) >> 1
                            end
                        end
                        if ((u[0]) && (v[0])) begin // two while loops finished
                            if (u_minus_v[259]) begin // if u < v
                                v = v - u; // v = v - u
                                y = y - x; // y = y - x
                            end else begin // else
                                u = u - v; // u = u - v
                                x = x - y; // x = x - y
                            end
                        end
                    end
                end
        end
    end
endmodule

module modtrimul (clk, rst_n, start, a, b, c, m, p1, p2, ready1, ready2); // p = a * b * c mod m
    input clk, rst_n;
    input start;
    input [255:0] a, b, c, m;
    output [255:0] p1,p2;
    output ready1, ready2 ;
    reg [255:0] tmp1, tmp2, tmp3;
    reg  en,  pr, prst_n;
    reg st;

    modmul triw (clk, prst_n, en, tmp1, tmp2, m, tmp3, pr);
    
    assign ready1 = st == 1 & pr;
    assign ready2 = st == 1 & pr;
    assign p1 = tmp1;
    assign p2 = tmp3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prst_n = 0;
            en = 0;
            st = 0;
        end
        else begin
            if (start & ~(ready1 & ready2)) begin
               case(st)
                default:
                    st =0;
                0: begin
                    if (!en) begin
                        // $display("st = 0, en");
                        prst_n = 1;
                        tmp1 = a;
                        tmp2 = b;
                        en = 1;
                    end else begin
                        if (pr) begin
                            prst_n = 0; //reset that mf
                            en = 0;
                            tmp1 = tmp3;
                            st = 1;
                        end 
                    end
                end
                1: begin
                    if (!en) begin
                        // $display("st = 1, en");
                        prst_n = 1;
                        tmp2 = c;
                        en = 1;
                    end 
                end
               endcase 
            end
        end
    end

endmodule

module modmul (clk, rst_n, start, a, b, m, p, ready); // p = a * b mod m
    input clk, rst_n;
    input start;
    input [255:0] a, b, m;
    output [255:0] p;
    output ready;
    // reg busy;
    reg ready0, started;
    assign ready = ready0 & started;
    reg [257:0] u, s;
    reg [7:0] cnt;
    wire [7:0] next_cnt = cnt + 8'd1;
    wire bi_is_1 = b[cnt];
    wire [257:0] plus_u = s + u; // s + u
    wire [257:0] minus_m = plus_u - {2'b00,m}; // s + u - m
    wire [257:0] new_s = bi_is_1 ? minus_m[257] ? plus_u : minus_m : s; // new s
    wire [257:0] two_u = {u[256:0],1'b0}; // 2u
    wire [257:0] two_u_m = two_u - {2'b00,m}; // 2u - m
    wire [257:0] new_u = two_u_m[257] ? two_u : two_u_m; // new u
    assign p = s[255:0];
    initial begin
        ready0 = 0;
        // busy = 0;
        started =0 ;
    end
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ready0 = 0;
            // busy = 0;
            started =0 ;
        end else begin
            if (start && !started) begin
                u = {2'b0,a}; // u = a
                s = 0; // s = 0
                ready0 = 0;
                started = 1;
                // busy = 1;
                cnt = 0;
            end else begin
                if (!ready0) begin
                    s = new_s; // s = new_s;
                    if (cnt == 8'd255) begin // finished
                        ready0 = 1;
                        // busy = 0;
                    end else begin 
                        u = new_u; 
                        cnt = next_cnt; 
                    end
                end
            end
        end
    end
endmodule

module point_scalar_mult_c (clk, rst_n, start, px, py, m, d, rx, ry, ready);
    input clk, rst_n, start;
    input [255:0] px, py, m, d;
    output [255:0] rx, ry;
    output ready;

    wire [255:0] qx, qy, qz;
    wire ready_scalar_mult, readyzi, readyqz2, readyqz3, readyrx, readyry;
    reg start_z2mult, start_z3mult, start_rxmult, start_rymult;
    wire [255:0] zi, qz2, qz3;

    // Use registered start signals for each module
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_z2mult <= 0;
            start_z3mult <= 0;
            start_rxmult <= 0;
            start_rymult <= 0;
        end else begin
            start_z2mult <= readyzi;
            start_z3mult <= readyqz2;
            start_rxmult <= readyqz2;
            start_rymult <= readyqz3;
        end
    end

    point_scalar_mult inst (
        .clk(clk), 
        .rst_n(rst_n), 
        .in_ready(start), 
        .px(px), 
        .py(py), 
        .pz(256'b1), 
        .m(m), 
        .d(d), 
        .qx(qx), 
        .qy(qy), 
        .qz(qz), 
        .ready(ready_scalar_mult)
    );

    modinv zinv (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(ready_scalar_mult), 
        .b(256'b1), 
        .a(qz), 
        .m(m), 
        .c(zi), 
        .ready(readyzi)
    );

    modmul z2mult (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start_z2mult), 
        .a(zi), 
        .b(zi), 
        .m(m), 
        .p(qz2), 
        .ready(readyqz2)
    );

    modmul z3mult (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start_z3mult), 
        .a(zi), 
        .b(qz2), 
        .m(m), 
        .p(qz3), 
        .ready(readyqz3)
    );

    modmul rxmult (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start_rxmult), 
        .a(qx), 
        .b(qz2), 
        .m(m), 
        .p(rx), 
        .ready(readyrx)
    );

    modmul rymult (
        .clk(clk), 
        .rst_n(rst_n), 
        .start(start_rymult), 
        .a(qy), 
        .b(qz3), 
        .m(m), 
        .p(ry), 
        .ready(readyry)
    );

    assign ready = readyrx & readyry;
endmodule
