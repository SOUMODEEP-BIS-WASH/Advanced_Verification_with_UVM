`timescale 1ns/1ps

module SRAM(
	
  input clk,rst,wr_en,rd_en,
  input [7:0]wr_addr,rd_addr,wr_data,
  output reg [7:0]rd_data

);
  integer i;
  reg [7:0]mem[0:255];
  
  always @(posedge clk or posedge rst) begin
    if(rst) begin
      for(i=0;i<256;i=i+1) mem[i]<=0;
      rd_data<=0;
    end
    else begin
      if(rd_en && wr_en && (rd_addr!=wr_addr)) begin 
        mem[wr_addr]<=wr_data;
        rd_data<=mem[rd_addr];
      end
      else if(wr_en) mem[wr_addr]<=wr_data;
      else if(rd_en) rd_data<=mem[rd_addr];
      else rd_data<=rd_data;
    end
  end
  
  
endmodule