module uart_rx #(parameter CLKS_PER_BIT = 434)(
  input clk, input rst, input rx,
  output reg [7:0] data, output reg valid);
  localparam IDLE=0, START=1, DATA=2, STOP=3;
  reg [1:0] state; reg [15:0] cnt; reg [2:0] idx; reg s1, s2;
  always @(posedge clk) begin s1<=rx; s2<=s1; end  // synchronizer
  always @(posedge clk) begin
    if (rst) begin state<=IDLE; valid<=0; cnt<=0; idx<=0; data<=0; end
    else begin
      valid<=0;
      case (state)
        IDLE:  begin cnt<=0; idx<=0; if (!s2) state<=START; end
        START: if (cnt==(CLKS_PER_BIT-1)/2) begin  // sample mid-bit
                 cnt<=0; state <= s2 ? IDLE : DATA; end
               else cnt<=cnt+1;
        DATA:  if (cnt==CLKS_PER_BIT-1) begin cnt<=0; data[idx]<=s2;
                 if (idx==7) state<=STOP; else idx<=idx+1; end
               else cnt<=cnt+1;
        STOP:  if (cnt==CLKS_PER_BIT-1) begin cnt<=0; valid<=1; state<=IDLE; end
               else cnt<=cnt+1;
      endcase
    end
  end
endmodule
