/* if "ack" is 1, then current input has been used. */
`define vslice(k)    (k-1)
// `define K_LEN (512)
// `define K_RATE (576)
`define K_LEN (256)
`define K_RATE (1088)

module f_permutation(clk, reset, in, in_ready, ack, out, out_ready);
    input               clk, reset;
    input      [`vslice(`K_RATE):0]  in;
    input               in_ready;
    output              ack;
    output reg [1599:0] out;
    output reg          out_ready;

    reg        [22:0]   i; /* select round constant */
    wire       [1599:0] round_in, round_out;
    wire       [63:0]   rc; /* round constant */
    wire                update;
    wire                accept;
    reg                 calc; /* == 1: calculating rounds */

    assign accept = in_ready & (~ calc); // in_ready & (i == 0)
    
    always @ (posedge clk)
      if (reset) i <= 0;
      else       i <= {i[21:0], accept};
    
    always @ (posedge clk)
      if (reset) calc <= 0;
      else       calc <= (calc & (~ i[22])) | accept;
    
    assign update = calc | accept;

    assign ack = accept;

    always @ (posedge clk)
      if (reset)
        out_ready <= 0;
      else if (accept)
        out_ready <= 0;
      else if (i[22]) // only change at the last round
        out_ready <= 1;

    assign round_in = accept ? {in ^ out[1599:1599-`K_RATE-1], out[1599-`K_RATE:0]} : out;

    rconst
      rconst_ ({i, accept}, rc);

    round
      round_ (round_in, rc, round_out);

    always @ (posedge clk)
      if (reset)
        out <= 0;
      else if (update)
        out <= round_out;
endmodule
