module uart_tx #(parameter CLKS_PER_BIT = 434)(
  input clk, input rst, input start, input [7:0] data,
  output reg tx, output reg busy);
  localparam IDLE=0, START=1, DATA=2, STOP=3;
  reg [1:0] state; reg [15:0] cnt; reg [2:0] idx; reg [7:0] sh;
  always @(posedge clk) begin
    if (rst) begin state<=IDLE; tx<=1; busy<=0; cnt<=0; idx<=0; end
    else case (state)
      IDLE:  begin tx<=1; cnt<=0; idx<=0;
               if (start) begin sh<=data; busy<=1; state<=START; end
               else busy<=0; end
      START: begin tx<=0;
               if (cnt==CLKS_PER_BIT-1) begin cnt<=0; state<=DATA; end
               else cnt<=cnt+1; end
      DATA:  begin tx<=sh[idx];
               if (cnt==CLKS_PER_BIT-1) begin cnt<=0;
                 if (idx==7) state<=STOP; else idx<=idx+1; end
               else cnt<=cnt+1; end
      STOP:  begin tx<=1;
               if (cnt==CLKS_PER_BIT-1) begin cnt<=0; state<=IDLE; busy<=0; end
               else cnt<=cnt+1; end
    endcase
  end
endmodule
