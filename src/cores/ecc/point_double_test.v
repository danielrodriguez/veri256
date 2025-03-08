
module point_double_jaco_test;
reg clk, rst_n, start;
reg [255:0] px, py, pz, m;
wire [255:0] rx, ry, rz;
wire ready;


    point_double_jaco_vitis inst (clk, rst_n, start, px, py, pz, m, rx, ry, rz, ready);
    
    always #1 clk = ~ clk;

    initial begin
        clk = 0;
        rst_n = 0;
        start = 0;
    end

    initial begin
    #1;
        rst_n = 0;
        #1;
        rst_n = 1;
        m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        px = 256'h79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798;
        py = 256'h483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8;
        pz = 256'h1;
        start = 1;
        #1
        while(!ready) 
          #1;
        check(256'h7d152c041ea8e1dc2191843d1fa9db55b68f88fef695e2c791d40444b365afc2,
        256'h56915849f52cc8f76f5fd7e4bf60db4a43bf633e1b1383f85fe89164bfadcbdb,
        256'h9075b4ee4d4788cabb49f7f81c221151fa2f68914d0aa833388fa11ff621a970);
        
      #1;
        rst_n = 0;
        #1;
        rst_n = 1;
        m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        px = 256'h1;
        py = 256'h1;
        pz = 256'h0;
        start = 1;
        #1
        while(!ready) 
          #1;
        // {'__name__': '__main__', '__doc__': None, '__package__': None, '__loader__': <_frozen_importlib_external.SourceFileLoader object at 0x1050291d0>, '__spec__': None, '__annotations__': {}, '__builtins__': <module 'builtins' (built-in)>, '__file__': '/Users/drodriguez/src/veri/ecpt4o/ref_pdouble.py', '__cached__': None, 'random': <module 'random' from '/Users/drodriguez/src/oss-cad-suite/lib/python3.11/random.py'>, 'm': 115792089237316195423570985008687907853269984665640564039457584007908834671663, 'verihex': <function verihex at 0x104fcc4a0>, 'mod': <function mod at 0x10504a480>, 'double': <function double at 0x10504a5c0>, 'x': 1, 'y': 1, 'z': 0, 'rx': 1, 'ry': 1, 'rz': 0}
        check(256'h1,
        256'h1,
        256'h0);
        
        $display("✅ double 0x1,0x1 ok");

        #1;
        rst_n = 0;
        #1;
        rst_n = 1;
        m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        px = 256'hf7072b58fef33f7ba024a7294b143df6d19;
        py = 256'hfffffffffffc355b863727530de4658788d263bcf1bbd0280401559cc8758e2c;
        pz = 256'hb69113dfc8;
        start = 1;
        #1
        while(!ready) 
          #1;
        // {'__name__': '__main__', '__doc__': None, '__package__': None, '__loader__': <_frozen_importlib_external.SourceFileLoader object at 0x10292f9e0>, '__spec__': None, '__annotations__': {}, '__builtins__': <module 'builtins' (built-in)>, '__file__': '/Users/drodriguez/src/veri/ecpt4o/ref_pdouble.py', '__cached__': None, 'random': <module 'random' from '/opt/homebrew/Cellar/python@3.12/3.12.3/Frameworks/Python.framework/Versions/3.12/lib/python3.12/random.py'>, 'm': 115792089237316195423570985008687907853269984665640564039457584007908834671663, 'verihex': <function verihex at 0x102938e00>, 'mod': <function mod at 0x1029b9c60>, 'double': <function double at 0x102a74a40>, 'x': 1344948388788135870202247051131777223453977, 'y': 115792089237314635661237220555372791626992580259960665894929926170694429019692, 'z': 784118046664, 'rx': 47141462073518426428657112526647047665910711643894202097833193737984136584131, 'ry': 105331053273593564832407443472495702860357740454467864440607743203868451472979, 'rz': 113346013648493265128917475783149166289850864790630515560436290437464991522175}
        check(256'h68391f3ac142aa64b47d6867c72645823b20c60ea2ba621d4a2eeff08cfa1bc3,
        256'he8df43729ba461c468f6b2d06ea716b69db5f310b96287bb6ec0eacbafdb0653,
        256'hfa9791fdcf1523a979814b9ac4033902e16da0f2d67acd090eeb2e555198dd7f);
        
        $display("✅ double 0xf7072b58fef33f7ba024a7294b143df6d19,0xfffffffffffc355b863727530de4658788d263bcf1bbd0280401559cc8758e2c ok");
          

           #1;
        rst_n = 0;
        #5;
        rst_n = 1;
        m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        px = 256'h20031c44b921cbfb2606e60c946a7e2a4afb0300;
        py = 256'hfffff4ae0a79804101a4858ce81933050aca4886bcf8858a01a38d3d0389f42f;
        pz = 256'h1db61518158;
        start = 1;
        #1
        while(!ready) 
          #1;
        // {'__name__': '__main__', '__doc__': None, '__package__': None, '__loader__': <_frozen_importlib_external.SourceFileLoader object at 0x1011139e0>, '__spec__': None, '__annotations__': {}, '__builtins__': <module 'builtins' (built-in)>, '__file__': '/Users/drodriguez/src/veri/ecpt4o/ref_pdouble.py', '__cached__': None, 'random': <module 'random' from '/opt/homebrew/Cellar/python@3.12/3.12.3/Frameworks/Python.framework/Versions/3.12/lib/python3.12/random.py'>, 'm': 115792089237316195423570985008687907853269984665640564039457584007908834671663, 'verihex': <function verihex at 0x10111ce00>, 'mod': <function mod at 0x10119dc60>, 'double': <function double at 0x101258a40>, 'x': 182757069431248158799335020695878596893318251264, 'y': 115792011108493859546682954339412827258807793960021623767363193312306780566575, 'z': 2041742197080, 'rx': 5453496769282951014412408192903265448913842609304506862297392351513598788070, 'ry': 32979918275075870593210589589555642249426723940665482766411709303973470857659, 'rz': 64009801497031461629758154825819875363558551334089632135306667168548966069615}
        check(256'hc0e91dd98022a339cf2f3cc9b3f1ab46d67378ce2c369e9bdeecb8a3ee881e6,
        256'h48e9f8e5269ac56a8238803e30fb8dfd7bf18211b674807e663762d35acce9bb,
        256'h8d8443862bb3008f8845201b1cc56b508ae11fad8cf20331768aaab0ca57756f);
        
        $display("✅ double 0x20031c44b921cbfb2606e60c946a7e2a4afb0300,0xfffff4ae0a79804101a4858ce81933050aca4886bcf8858a01a38d3d0389f42f ok");
          
          

           #1;
        rst_n = 0;
        #5;
        rst_n = 1;
        m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        px = 256'h199be6054b76bef9ed15398d3ca55bec063d00e0;
        py = 256'hfffff7e67ab5a3729d6a221931e0c7c2c92c8172ab64fe436d1e6a99aa45b047;
        pz = 256'h1e2977d4cc6;
        start = 1;
        #1
        while(!ready) 
          #1;
        // {'__name__': '__main__', '__doc__': None, '__package__': None, '__loader__': <_frozen_importlib_external.SourceFileLoader object at 0x1029af9e0>, '__spec__': None, '__annotations__': {}, '__builtins__': <module 'builtins' (built-in)>, '__file__': '/Users/drodriguez/src/veri/ecpt4o/ref_pdouble.py', '__cached__': None, 'random': <module 'random' from '/opt/homebrew/Cellar/python@3.12/3.12.3/Frameworks/Python.framework/Versions/3.12/lib/python3.12/random.py'>, 'm': 115792089237316195423570985008687907853269984665640564039457584007908834671663, 'verihex': <function verihex at 0x1029b8e00>, 'mod': <function mod at 0x102a39c60>, 'double': <function double at 0x102af4a40>, 'x': 146201422403853038326374240638242494746868908256, 'y': 115792033335309629068277418608694544428231815544810946621382983595235771527239, 'z': 2072715807942, 'rx': 17359310463694682780783936330435450825673118677807424675451400040091593725227, 'ry': 78590962750607996258284582375253370865279251286840231177532703759750702270036, 'rz': 4957615343677245758548237421206046174278341044245182802777997582727385537648}
        check(256'h266105836fb0971b08d84e263cf4eff34d42c09d7fa1e888e458a9cb2867d52b,
        256'hadc0e8983ae211c21ec16645c06da7c9e8aa1f25d963b96140c51ea18b438654,
        256'haf5e92d414e37815c4dcf3f077312bab62e4d9fd64d38f6989cdf8e81a55c70);
        
        $display("✅ double 0x199be6054b76bef9ed15398d3ca55bec063d00e0,0xfffff7e67ab5a3729d6a221931e0c7c2c92c8172ab64fe436d1e6a99aa45b047 ok");
          
          

        // mine, leave here
        #1;
        rst_n = 0;
        #10;
        rst_n = 1;
        m = 256'hfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;
        px = 256'hfed5b7e864ae24ed502e69af8acfe4c97190cbac30c2728c0d87afc60791219a;
        py = 256'h51898bfdf1b316664d1265ce8910b2177b522cdbf385e75f84c6059cdf3d0ca6;
        pz = 256'd1;
        start = 1;
        #1
        while(!ready) 
          #5;
        
        check(256'hfd15b0a9c566cba7317e8c0826356ca9fd88cc6d49d48c180bded20418f92715,
        256'h7124f3c9f53b546921ab91834a6c099a6556abda6c89306c6ff86f48683a5645,
        256'ha31317fbe3662ccc9a24cb9d1221642ef6a459b7e70bcebf098c0b39be7a194c);


        $display("✅all good!");
        $finish;
    end

      task check;
        input [256:0] wishx, wishy, wishz;
        begin
          if (rx !== wishx)
            begin
              $display("❌ x actual: %0h", rx); 
              $display("❌ x expect: %0h", wishx); 
            end
          if (ry !== wishy)
            begin
              $display("❌ y actual: %0h ", ry);
              $display("❌ y expect: %0h", wishy); 
            end
          if (rz !== wishz)
            begin
              $display("❌ z actual: %0h", rz); 
              $display("❌ z expect: %0h", wishz); 
            end

            if (rx !== wishx | ry !== wishy | rz !== wishz)
              $finish;
        end
    endtask
endmodule
          
          