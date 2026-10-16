`timescale 1ns/1ps
module tb_uart;
  reg clk=0, rst=1, start=0; reg [7:0] din;
  wire line, busy, valid; wire [7:0] dout;
  integer errors=0;
  uart_tx #(16) u_tx(.clk(clk),.rst(rst),.start(start),.data(din),.tx(line),.busy(busy));
  uart_rx #(16) u_rx(.clk(clk),.rst(rst),.rx(line),.data(dout),.valid(valid));
  always #5 clk = ~clk;

  task send_check(input [7:0] b);
    begin
      @(posedge clk); din=b; start=1;
      @(posedge clk); start=0;
      wait(valid); @(posedge clk);
      if (dout===b) $display("PASS: sent %h got %h", b, dout);
      else begin $display("FAIL: sent %h got %h", b, dout); errors=errors+1; end
      wait(!busy);
    end
  endtask

  initial begin
    $dumpfile("uart.vcd"); $dumpvars(0, tb_uart);
    repeat(4) @(posedge clk); rst=0; repeat(4) @(posedge clk);
    send_check(8'hA5); send_check(8'h3C); send_check(8'h00);
    send_check(8'hFF); send_check(8'h55);
    if (errors==0) $display("ALL TESTS PASSED"); else $display("%0d TESTS FAILED", errors);
    $finish;
  end
endmodule
