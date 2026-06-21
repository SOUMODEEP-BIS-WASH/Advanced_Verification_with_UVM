`timescale 1ns/1ps

module sync_fifo(
  input clk,rst,rd_en,wr_en,
  input [7:0]Din,
  output reg [7:0]Dout,
  output reg empty,full
);
  reg [7:0]mem[63:0];
  reg [5:0]pointer;
  integer i;
  
  always @(posedge clk or rst) begin
    if(rst) begin
      for(i=0;i<64;i=i+1) mem[i]<=0;
      pointer <=0;
      full<=0;
      empty<=0;
    end
    else begin
      if(wr_en) begin
        if(!full) begin
          mem[pointer]<=Din;
          if(pointer<63) begin
          	pointer<=pointer+1;
            empty<=0; full<=0;
          end
          else begin
          	empty<=0;
            full<=1;
          end
        end
      end
      if(rd_en) begin
        if(!empty) begin
          Dout<=mem[0];
          for(i=0;i<63;i=i+1) mem[i]<=mem[i+1];
          if(pointer>0) begin
          	pointer <=pointer -1;
            empty<=0; full<=0;
          end
          else begin
          	empty<=1;
            full<=0;
          end
        end
      end
    end
  end
  
endmodule