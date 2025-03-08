
    typedef enum {M__INIT, M__DOUBLING, M__ADDING, M__SWAP, M__IDLE} t_point_scalar_mult_state;

    function [255:0] addMod;
        input [255:0] a;
        input [255:0] b;
        input [255:0] mod;
        reg [257:0] sum;
        begin
            sum = a + b;
            addMod = (sum >= mod) ? (sum - mod) : sum;
        end
    endfunction    
    function [255:0] subMod;
        input [255:0] a;
        input [255:0] b;
        input [255:0] mod;
        begin
            subMod = (a >= b) ? a-b : a+mod-b;
        end
    endfunction
