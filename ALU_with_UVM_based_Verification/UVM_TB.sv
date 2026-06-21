`timescale 1ns/1ps

//IMPORT UVM LIBRARY AND MACROS

`include "uvm_macros.svh"
import uvm_pkg::*;

//INTERFACE

interface intfc (input bit clk);
  logic [3:0]a,b;
  logic [2:0]s;
  logic [7:0]y;
endinterface

//SEQUENCE ITEM

class transaction extends uvm_sequence_item;
  
  `uvm_object_utils(transaction)
  
  randc bit [3:0]a,b;
  randc bit [2:0]s;
  bit [7:0]y;
  
  function new(string name="transaction");
    super.new(name);
  endfunction
  
  constraint C1 {a inside {[1:15]};b inside {[1:15]};s inside {[0:7]};}
  
endclass

//SEQUENCE

class seq extends uvm_sequence #(transaction);
  
 `uvm_object_utils(seq)
 transaction t_h1;
  
  function new(string name="seq");
    super.new(name);
  endfunction
  
  task body();
    repeat(15)begin
      t_h1=transaction::type_id::create("t_h1");
      start_item(t_h1);
      assert(t_h1.randomize());
      finish_item(t_h1);
    end
  endtask
  
endclass

//SEQUENCER 

class sqcr extends uvm_sequencer #(transaction);
  
  `uvm_component_utils(sqcr)
  
  function new(string name="sqcr",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
endclass

//DRIVER

class driver extends uvm_driver #(transaction);
  
  `uvm_component_utils(driver)
  
  virtual intfc intf;
  transaction t_h1;
  
  function new(string name="driver",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!(uvm_config_db #(virtual intfc) :: get(this,".","intf",intf))) 			$display("CONFIG_DB NOT SET FOR VIRTUAL INTERFACE");
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge intf.clk)
    seq_item_port.get_next_item(t_h1);
    intf.a<=t_h1.a;
    intf.b<=t_h1.b;
    intf.s<=t_h1.s;
    seq_item_port.item_done();
    end
  endtask
  
endclass

//MONITOR

class monitor extends uvm_monitor;

  `uvm_component_utils(monitor)
  
  virtual intfc intf;
  transaction t_h2;
  uvm_analysis_port #(transaction) col_port;
 
  covergroup cvg;
    C1: coverpoint intf.a{bins one={1}; bins low={[2:5]}; bins mid={[6:10]}; bins high={[11:14]}; bins max={15};}
    C2: coverpoint intf.b{bins one={1}; bins low={[2:5]}; bins mid={[6:10]}; bins high={[11:14]}; bins max={15};}
    C3: coverpoint intf.s;
    cross C1,C3;
    cross C2,C3;
  endgroup
  
  function new(string name="monitor",uvm_component parent = null);
    super.new(name,parent);
    cvg=new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    col_port=new("col_port",this);
    if(!(uvm_config_db #(virtual intfc) :: get(this,".","intf",intf))) 			$display("CONFIG_DB NOT SET FOR VIRTUAL INTERFACE");
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      @(negedge intf.clk)
      t_h2=transaction::type_id::create("t_h2");
      t_h2.a=intf.a;
      t_h2.b=intf.b;
      t_h2.s=intf.s;
      t_h2.y=intf.y;
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
  sqcr sqr;
  
  function new(string name="agent",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dvr=driver::type_id::create("dvr",this);
    mon=monitor::type_id::create("mon",this);
    sqr=sqcr::type_id::create("sqr",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dvr.seq_item_port.connect(sqr.seq_item_export);
  endfunction
  
endclass

//SCOREBOARD

class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  bit [7:0]exp;
  
  transaction t_h2[$];
  uvm_analysis_imp #(transaction,scoreboard) col_imp;
  	  
  
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
  
  function int ref_model(input transaction t);
    case(t.s)
      3'b000: begin exp=t.a+t.b; return exp; end
      3'b001: begin exp[5:0]=t.a-t.b; return exp; end
      3'b010: begin exp=t.a*t.b; return exp; end
      3'b011: begin exp=t.a/t.b; return exp; end
      3'b100: begin exp=t.a&t.b; return exp; end
      3'b101: begin exp=t.a|t.b; return exp; end
      3'b110: begin exp=~(t.a&t.b); return exp; end
      3'b111: begin exp=~(t.a|t.b); return exp; end
      default: begin exp=8'b0000_0000; return exp; end
    endcase
  endfunction
  
  task run_phase(uvm_phase phase);
    transaction ref_t;
    forever begin
      wait(t_h2.size>0);
      ref_t=t_h2.pop_front();
      ref_model(ref_t);
      if(exp==ref_t.y) $display("|TIME = %t | PASS FOR: | A = %4b | B = %4b | S = %3b | Y = %8b | EXPECTED = %8b |",$time,ref_t.a,ref_t.b,ref_t.s,ref_t.y,exp);
    else $display("|TIME = %t | FAIL FOR: | A = %4b | B = %4b | S = %3b | Y = %8b | EXPECTED = %8b |",$time,ref_t.a,ref_t.b,ref_t.s,ref_t.y,exp);
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
    agt=agent::type_id::create("dvr",this);
    sb=scoreboard::type_id::create("sb",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.col_port.connect(sb.col_imp);
  endfunction
  
endclass

// TEST

class test extends uvm_test;
  
  `uvm_component_utils(test)
  
  env env1;
  seq seq1;
  
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
    repeat(20) begin
    seq1=seq::type_id::create("seq1");
    seq1.start(env1.agt.sqr);
    #10;  
    end
    $display("=====================================COVERAGE===========================================");
	$display("FUNCTIONAL COVERAGE = %0.2f %%",$get_coverage());
    $display("=================================END OF SIMULATION======================================");
    phase.drop_objection(this);
  endtask
  
endclass

//TOP MODULE

module tb;
  
  bit clk=0;
  
  intfc intf(clk);
  
  ALU DUT(.a(intf.a),.b(intf.b),.s(intf.s),.y(intf.y));
  
  always #5 clk=~clk;
  
  initial begin
    uvm_config_db #(virtual intfc) :: set(null,"*","intf",intf);
    run_test("test");
    
  end
  
endmodule