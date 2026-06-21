`timescale 1ns/1ps

//IMPORT UVM LIBRARY AND MACROS

`include "uvm_macros.svh"
import uvm_pkg::*;

//INTERFACE

interface intfc(input bit clk,rst);
  logic wr_en,rd_en;
  logic [7:0]wr_addr,rd_addr,wr_data;
  logic [7:0]rd_data;
endinterface

//SEQUENCE ITEM

class transaction extends uvm_sequence_item;
  
  `uvm_object_utils(transaction)
  
  function new(string name="transaction");
    super.new(name);
  endfunction
  
  bit wr_en,rd_en;
  randc bit [7:0]wr_addr,rd_addr,wr_data;
  byte rd_data;
  
  constraint C1{rd_en||wr_en;}
  constraint C2{if(rd_en && wr_en) rd_addr!=wr_addr;}
  //constraint C3{rd_addr inside {[0:255]};wr_addr inside {[0:255]};}
  
endclass

//READ SEQUENCE

class rd_seq extends uvm_sequence #(transaction);
  
  `uvm_object_utils(rd_seq)
  transaction t_h1;
  
  function new(string name="rd_seq");
    super.new(name);
  endfunction
  
  task body();
      t_h1=transaction::type_id::create("t_h1");
      start_item(t_h1);
      t_h1.rd_en=1;
      t_h1.wr_en=0;
      assert(t_h1.randomize());
      finish_item(t_h1);
  endtask
  
endclass

//WRITE SEQUENCE

class wr_seq extends uvm_sequence #(transaction);
  
  `uvm_object_utils(wr_seq)
  transaction t_h1;
  
  function new(string name="wr_seq");
    super.new(name);
  endfunction
  
  task body();
      t_h1=transaction::type_id::create("t_h1");
      start_item(t_h1);
      t_h1.rd_en=0;
      t_h1.wr_en=1;
      assert(t_h1.randomize());
      finish_item(t_h1);
  endtask
  
endclass

//DRIVER

class driver extends uvm_driver #(transaction);
  
  `uvm_component_utils(driver)
  
  transaction t_h1;
  virtual intfc intf;
  
  function new(string name="driver",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual intfc)::get(this,".","intf",intf)) $display("INTERFACE NOT SET AT UVM CONFIG DB");
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      //@(posedge intf.clk)
      seq_item_port.get_next_item(t_h1);
      intf.rd_en<=t_h1.rd_en;
      intf.wr_en<=t_h1.wr_en;
      intf.rd_addr<=t_h1.rd_addr;
      intf.wr_addr<=t_h1.wr_addr;
      intf.wr_data<=t_h1.wr_data;
      @(negedge intf.clk)
      seq_item_port.item_done();
    end
  endtask
  
endclass

//MONITOR

class monitor extends uvm_monitor;
  
  `uvm_component_utils(monitor)
  
  transaction t_h2;
  virtual intfc intf;
  uvm_analysis_port #(transaction) col_port;
  
  covergroup cvg;
    C1:coverpoint intf.rd_addr{bins zero={0};bins LOW={[1:127]};bins HIGH={[128:254]};bins max={255};}
    C2:coverpoint intf.rd_data{bins zero={0};bins LOW={[1:127]};bins HIGH={[128:254]};bins max={255};}
    C3:coverpoint intf.wr_addr{bins zero={0};bins LOW={[1:127]};bins HIGH={[128:254]};bins max={255};}
    C4:coverpoint intf.wr_data{bins zero={0};bins LOW={[1:127]};bins HIGH={[128:254]};bins max={255};}
    //C5:coverpoint intf.rd_en{bins en={1};}
    //C6:coverpoint intf.wr_en{bins en={1};}
    cross C1,C3;
  endgroup
  
  function new(string name="monitor",uvm_component parent = null);
    super.new(name,parent);
    cvg=new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    col_port=new("col_port",this);
    if(!uvm_config_db #(virtual intfc)::get(this,".","intf",intf)) $display("INTERFACE NOT SET AT UVM CONFIG DB");
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      t_h2=transaction::type_id::create("t_h2");
      t_h2.rd_en=intf.rd_en;
      t_h2.wr_en=intf.wr_en;
      t_h2.rd_addr=intf.rd_addr;
      t_h2.wr_addr=intf.wr_addr;
      t_h2.wr_data=intf.wr_data;
      @(posedge intf.clk)
      t_h2.rd_data=intf.rd_data;
      cvg.sample();
      col_port.write(t_h2);
    end
  endtask
  
endclass

//AGENT

class agent extends uvm_agent;
  
  `uvm_component_utils(agent)
  
  driver dvr;
  monitor mon;
  uvm_sequencer #(transaction) sqr;
  
  function new(string name="agent",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dvr=driver::type_id::create("dvr",this);
    mon=monitor::type_id::create("mon",this);
    sqr=uvm_sequencer #(transaction)::type_id::create("sqr",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dvr.seq_item_port.connect(sqr.seq_item_export);
  endfunction
  
endclass

//SCOREBOARD

class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp #(transaction,scoreboard) col_imp;
  transaction t_h2[$];
  bit [7:0]ref_mem[255:0];
  bit [7:0]ref_data;
  
  function new(string name="scoreboard",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    col_imp=new("col_imp",this);
  endfunction
  
  function void write(transaction t);
    t_h2.push_back(t);
  endfunction
  
  function ref_model(input transaction t);
    if(t.wr_en) begin ref_mem[t.wr_addr]=t.wr_data; end
    else if(t.rd_en) begin ref_data=ref_mem[t.rd_addr]; return ref_data; end
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      transaction ref_t;
      wait(t_h2.size()>0);
      ref_t=t_h2.pop_front();
      ref_model(ref_t);
      $display("TIME = %t | WR_DATA = %8b | RD_DATA = %8b | RD_ADDR = %8b | WR_ADDR = %8b | RD_EN = %b | WR_EN = %b |",$time,ref_t.wr_data,ref_t.rd_data,ref_t.rd_addr,ref_t.wr_addr,ref_t.rd_en,ref_t.wr_en);
      if(ref_t.rd_en && (ref_data==ref_t.rd_data)) begin `uvm_info("PASS", "PASS", UVM_LOW)
 $display("| TIME = %4t | READ PASS FOR : | RD_ADDR = %8b | RD_DATA = %8b | REF_DATA =%8b |",$time,ref_t.rd_addr,ref_t.rd_data,ref_data); end
      else if(ref_t.rd_en && (ref_data!=ref_t.rd_data)) begin `uvm_info("FAIL", "FAIL", UVM_LOW)
        $display("| TIME = %4t | READ FAIL FOR : | RD_ADDR = %8b | RD_DATA = %8b | REF_DATA =%8b |",$time,ref_t.rd_addr,ref_t.rd_data,ref_data); end
      $display("----------------------------------------------------------------------------------------");    
    end
  endtask
endclass

//ENVIRONMENT

class env extends uvm_env;
  
  `uvm_component_utils(env)
  
  agent agt;
  scoreboard sb;
  
  function new(string name="env",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt=agent::type_id::create("agt",this);
    sb=scoreboard::type_id::create("sb",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.col_port.connect(sb.col_imp);
  endfunction
  
endclass

//TEST

class test extends uvm_test;
  
  `uvm_component_utils(test)
  
  env env1;
  rd_seq rd_seq1;
  wr_seq wr_seq1;
  
  function new(string name="test",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env1=env::type_id::create("env1",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    $display("================================START OF SIMULATION=====================================");
    $display("====================================SCOREBOARD==========================================");
    $display("----------------------------------------------------------------------------------------");
    repeat(300) begin
      rd_seq1=rd_seq::type_id::create("rd_seq1");
      rd_seq1.start(env1.agt.sqr);
      #10;
      wr_seq1=wr_seq::type_id::create("wr_seq1");
      wr_seq1.start(env1.agt.sqr);
      #10;
    end
    $display("=====================================COVERAGE===========================================");
	$display("FUNCTIONAL COVERAGE = %0.2f %%",$get_coverage());
    $display("=================================END OF SIMULATION======================================");
    phase.drop_objection(this);
  endtask
  
endclass

//TOP

module tb;
  
  bit clk=0,rst=0;
  intfc intf(clk,rst);
  
  SRAM dut(.clk(intf.clk),.rst(intf.rst),.wr_en(intf.wr_en),.rd_en(intf.rd_en),.wr_addr(intf.wr_addr),.rd_addr(intf.rd_addr),.wr_data(intf.wr_data),.rd_data(intf.rd_data));
  
  always #5 clk=~clk;
  
  initial begin
    uvm_config_db #(virtual intfc)::set(null,"*","intf",intf);
  
    run_test("test");
  end
  
endmodule