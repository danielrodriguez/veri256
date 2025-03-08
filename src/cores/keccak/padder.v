/* "is_last" == 0 means byte number is 4, no matter what value "byte_num" is. */
/* if "in_ready" == 0, then "is_last" should be 0. */
/* the user switch to next "in" only if "ack" == 1. */
`define vslice(k)    (k-1)
`define blocks(k)    (k/32)
`define K_LEN (256)
`define K_RATE (1088)
module padder(clk, reset, in, in_ready, is_last, byte_num, buffer_full, out, out_ready, f_ack);
    input              clk, reset;
    input      [543:0]  in;
    input              in_ready, is_last;
    input      [7:0]   byte_num;
    output             buffer_full; /* to "user" module */
    output reg [`vslice(`K_RATE):0] out;         /* to "f_permutation" module */
    output             out_ready;   /* to "f_permutation" module */
    input              f_ack;       /* from "f_permutation" module */
    
    reg                state;       /* state == 0: user will send more input data
                                     * state == 1: user will not send any data */
    reg                done;        /* == 1: out_ready should be 0 */
    reg        [1:0]  i;           /* length of "out" buffer */
    wire       [543:0]  v0;          /* output of module "padder1" */
    reg        [543:0]  v1;          /* to be shifted into register "out" */
    wire               accept,      /* accept user input? */
                       update;
    
    assign buffer_full = i[1];
    assign out_ready = buffer_full;
    assign accept = (~ state) & in_ready & (~ buffer_full); // if state == 1, do not eat input
    assign update = (accept | (state & (~ buffer_full))) & (~ done); // don't fill buffer if done

    always @ (posedge clk) begin
      // if (in_ready) begin
      // $display("update? %d (accept(%d) | (state(%d) & !buffer_full(%d)) )", update, accept, state, ~buffer_full);
      // end
      if (reset)
        out <= 0;
      else if (update) begin
        // $display(" in %0h, %0d, appending %h to out, %h -> %h", in, byte_num, v1,  out, {out[`vslice(`K_RATE)-544:0], v1});
        out <= {out[`vslice(`K_RATE)-544:0], v1};
      end
    end

    always @ (posedge clk) begin
      if (reset) begin
        i <= 0;
      end
      else if (f_ack | update) begin
        i <= {i[0], 1'b1} & {2{~ f_ack}};
            // $display("i %b",  i);
      end
    end
/*    if (f_ack)  i <= 0; */
/*    if (update) i <= {i[16:0], 1'b1}; // increase length */

    always @ (posedge clk)
      if (reset)
        state <= 0;
      else if (is_last) begin
        // $display("state on");
        state <= 1;
      end

    always @ (posedge clk)
      if (reset)
        done <= 0;
      else if (state & out_ready)
        done <= 1;

    padder1 p0 (in, byte_num, v0);
    
    always @ (*)
      begin
        if (state)
          begin
            // $display("v1 = 0 state (%b)",  i);
            v1 = 0;
            v1[7] = v1[7] | i[0]; // "v1[7]" is the MSB of the last byte of "v1"
          end
        else if (is_last == 0) begin
        
          // $display("v1 = in (%h)", in);
          v1 = in;
        end
        else
          begin
            // $display("v1 = v0 (%h)", v0);
            v1 = v0;
            v1[7] = v1[7] | i[0];
          end
      end
endmodule
