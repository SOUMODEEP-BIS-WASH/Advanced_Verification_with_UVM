`timescale 1ns/1ps

//IMPORT UVM LIBRARY AND MACROS

`include "uvm_macros.svh"
import uvm_pkg::*;

//INTERFACE

interface intfc(input bit clk);
  	logic rst;
    logic rd_en,wr_en;
  	logic [7:0]Din;
  	logic [7:0]Dout;
  	logic empty,full;
endinterface

//TRANSACTION OR SEQUENCE ITEM

class transaction extends uvm_sequence_item;
  bit rd_en,wr_en;
  randc bit [7:0]Din;
  bit [7:0]Dout;
  bit empty,full;
  
  `uvm_object_utils(transaction)
  
  function new(string name="transaction");
    super.new(name);
  endfunction
  
  constraint C1{Din inside {0,[25:50],[51:75],[100:150],[175:200],[210:230],255};}
  
endclass

//REFERENCE TRANSACTION

class ref_trans extends uvm_sequence_item;
  bit [7:0]ref_data;
  bit ref_emp, ref_full;
  
  `uvm_object_utils(ref_trans)
  
  function new(string name="ref_trans");
    super.new(name);
  endfunction
  
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
    assert(t_h1.randomize());
    t_h1.rd_en=1;
  	t_h1.wr_en=0;
    finish_item(t_h1);
  endtask
  
endclass

//WRITE SEQUENCE SEQUENCE

class wr_seq extends uvm_sequence #(transaction);
  
  `uvm_object_utils(wr_seq)
  
  transaction t_h1;
  
  function new(string name="wr_seq");
    super.new(name);
  endfunction
    
  task body();

    t_h1=transaction::type_id::create("t_h1");
    start_item(t_h1);
    assert(t_h1.randomize());
    t_h1.rd_en=0;
  	t_h1.wr_en=1;
    finish_item(t_h1);
  endtask
  
endclass

//DRIVER

class driver extends uvm_driver #(transaction);
	
  `uvm_component_utils(driver)
  
  transaction t_h1;
  virtual intfc intf;
  
  function new(string name="driver",uvm_component parent=null);
    super.new(name,parent);
  endfunction
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual intfc) :: get(this,".","intf",intf)) $display("INTERFACE NOT SET AT UVM_CONFIG DB");
  endfunction

  task run_phase(uvm_phase phase);
    // Apply reset first
  	intf.rst = 1;
  	repeat(5) @(posedge intf.clk);
  	intf.rst = 0;

  	forever begin
    seq_item_port.get_next_item(t_h1);
    intf.Din<=t_h1.Din;
    intf.rd_en<=t_h1.rd_en;
    intf.wr_en<=t_h1.wr_en;
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
    
    C1: coverpoint intf.wr_en{bins b={1};}
    C2: coverpoint intf.Din{bins ZERO={0};bins LOW={[1:25]};bins MID={[26:229]};bins HIGH={[230:255]}; }
    cross C1,C1;
  endgroup
  
  function new(string name="monitor",uvm_component parent=null);
    super.new(name,parent);
    cvg=new();
  endfunction
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    col_port=new("col_port",this);
    if(!uvm_config_db #(virtual intfc) :: get(this,".","intf",intf)) $display("INTERFACE NOT SET AT UVM_CONFIG DB");
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
    t_h2=transaction::type_id::create("t_h2");
    t_h2.Din=intf.Din;
    t_h2.wr_en=intf.wr_en;
    t_h2.rd_en=intf.rd_en;
      @(posedge intf.clk)
    t_h2.Dout=intf.Dout;
    t_h2.empty=intf.empty;
    t_h2.full=intf.full;
      cvg.sample();
    col_port.write(t_h2);
    end
  endtask
  
endclass
  
//AGENT

class agent extends uvm_agent;
  
  `uvm_component_utils(agent)
  
  driver drv;
  monitor mon;
  uvm_sequencer #(transaction) sqcr;
  
  function new(string name="agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv=driver::type_id::create("drv",this);
    mon=monitor::type_id::create("mon",this);
    sqcr=uvm_sequencer #(transaction)::type_id::create("sqcr",this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(sqcr.seq_item_export);
  endfunction
  
endclass

//SCOREBOARD

class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  transaction t_h2[$];
  uvm_analysis_imp #(transaction,scoreboard) col_imp;

  ref_trans ref_t;
  bit [7:0]ref_fifo[$];
  bit [5:0]ref_ptr;
  
  function new(string name="scoreboard",uvm_component parent=null);
    super.new(name,parent);
  endfunction
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    col_imp=new("col_imp",this);
    ref_t=ref_trans::type_id::create("ref_t");
  endfunction
  
  function void write(transaction t);
    t_h2.push_back(t);
  endfunction
  
  task ref_model(input transaction t);
    if(t.wr_en) begin
      if(!ref_t.ref_full) begin
        ref_fifo.push_back(t.Din);
          if(ref_ptr<63) begin
          	ref_ptr=ref_ptr+1;
            ref_t.ref_emp=0; ref_t.ref_full=0;
            //return ref_t;
          end
          else begin
            ref_t.ref_emp=0;
            ref_t.ref_full=1;
            //return ref_t;
          end
        end
      end
    if(t.rd_en) begin
      if(!ref_t.ref_emp) begin
          ref_t.ref_data=ref_fifo.pop_front();
          if(ref_ptr>0) begin
          	ref_ptr=ref_ptr -1;
            ref_t.ref_emp=0; ref_t.ref_full=0;
            //return ref_t;
          end
          else begin
          	ref_t.ref_emp=1;
            ref_t.ref_full=0;
            //return ref_t;
          end
        end
      end

  endtask
  
    task run_phase(uvm_phase phase);
    forever begin
      transaction tr;
      wait(t_h2.size()>0);
      tr=t_h2.pop_front();
      ref_model(tr);
      $display("TIME = %t | WR_DATA = %8b | RD_DATA = %8b | RD_EN = %b | WR_EN = %b | FULL_FLAG = %b | EMPTY_FLAG =%b |",$time,tr.Din,tr.Dout,tr.rd_en,tr.wr_en,tr.full,tr.empty);
      
      if(tr.rd_en && (ref_t.ref_data==tr.Dout) && (ref_t.ref_emp == tr.empty)) begin `uvm_info("PASS", "PASS", UVM_LOW)
        $display("| TIME = %4t | READ PASS FOR : | RD_DATA = %8b | REF_DATA =%8b | EMPTY_FLAG = %b | EMPTY_REF =  %b",$time,tr.Dout,ref_t.ref_data,tr.empty,ref_t.ref_emp); end
     
      else if(tr.rd_en && (ref_t.ref_data!=tr.Dout)) begin `uvm_info("FAIL", "FAIL", UVM_LOW)
        $display("| TIME = %4t | READ FAIL FOR : | RD_DATA = %8b | REF_DATA =%8b | EMPTY_FLAG = %b | EMPTY_REF =  %b",$time,tr.Dout,ref_t.ref_data,tr.empty,ref_t.ref_emp); end
          
      else if(tr.rd_en && (ref_t.ref_emp != tr.empty)) begin `uvm_info("FAIL_FLAG", "FAIL", UVM_LOW)
        $display("| TIME = %4t | EMPTY FLAG FAIL FOR : | RD_DATA = %8b | REF_DATA =%8b | EMPTY_FLAG = %b | EMPTY_REF =  %b",$time,tr.Dout,ref_t.ref_data,tr.empty,ref_t.ref_emp); end
          
      else if(tr.wr_en && (ref_t.ref_full == tr.full)) begin `uvm_info("PASS_FLAG", "PASS", UVM_LOW)
        $display("| TIME = %4t | FULL FLAG PASS FOR : | RD_DATA = %8b | REF_DATA =%8b | FULL_FLAG = %b | FULL_REF =  %b",$time,tr.Dout,ref_t.ref_data,tr.full,ref_t.ref_full); end
          
      else if(tr.wr_en && (ref_t.ref_full != tr.full)) begin `uvm_info("FAIL_FLAG", "FAIL", UVM_LOW)
        $display("| TIME = %4t | FULL FLAG FAIL FOR : | RD_DATA = %8b | REF_DATA =%8b | FULL_FLAG = %b | FULL_REF =  %b",$time,tr.Dout,ref_t.ref_data,tr.full,ref_t.ref_full); end
          
      
      $display("-------------------------------------------------------------------------------------------");    
    end
  endtask
  
endclass

//ENVIRONMENT

class environment extends uvm_env;
  `uvm_component_utils(environment)
  
  agent agt;
  scoreboard sb;
  
  function new(string name="environment",uvm_component parent = null);
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
  
  environment env1;
  rd_seq rd_seq1;
  wr_seq wr_seq1;
  
  function new(string name="test",uvm_component parent = null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env1=environment::type_id::create("env1",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    $display("================================START OF SIMULATION=====================================");
    $display("====================================SCOREBOARD==========================================");
    $display("----------------------------------------------------------------------------------------");
    repeat(33) begin
      wr_seq1=wr_seq::type_id::create("wr_seq1");
      wr_seq1.start(env1.agt.sqcr);
      #10;
    end
    repeat(33) begin
      rd_seq1=rd_seq::type_id::create("rd_seq1");
      rd_seq1.start(env1.agt.sqcr);
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
  
  sync_fifo dut(.clk(intf.clk),.rst(intf.rst),.wr_en(intf.wr_en),.rd_en(intf.rd_en),.Din(intf.Din),.Dout(intf.Dout),.empty(intf.empty),.full(intf.full));
  
  always #5 clk=~clk;
  

  
  initial begin
  
    uvm_config_db #(virtual intfc)::set(null,"*","intf",intf);
  
    run_test("test");
  end

  
endmodule