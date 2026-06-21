`timescale 1ns/1ps 

`include "uvm_macros.svh"
import uvm_pkg::*;

//INTERFACE 

interface intf(input clk);
    logic [3:0]a,b;
    logic cin;
    logic [3:0]sum;
    logic cout;
endinterface


//SEQUENCE ITEM

class transaction extends uvm_sequence_item;
  
  `uvm_object_utils(transaction)
  
  	randc bit [3:0]a,b;
    randc bit cin;
    bit [3:0]sum;
    bit cout;
  
  function new(string name="transaction");
    super.new(name);
  endfunction
  
endclass

//SEQUENCE

class seq extends uvm_sequence #(transaction);
  
  `uvm_object_utils(seq)
  
  transaction t_h1;
  
  function new(string name="seq");
    super.new(name);
  endfunction
  
  task body();
    repeat(10) begin
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
  
  function new(string name="sqcr",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //uvm_config_db #(virtual intf) :: get(this,".","intfc",intfc);
  endfunction
  
  
endclass

//DRIVER

class driver extends uvm_driver #(transaction);
  
  `uvm_component_utils(driver)
  
  virtual intf intfc;
  transaction t_h1;
  
  function new(string name="driver",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	if (!uvm_config_db #(virtual intf)::get(this,".","intfc",intfc))
  		`uvm_fatal("CFG", "Virtual interface not found")
  endfunction
  
  task run_phase(uvm_phase phase);
    //super.run_phase(phase);
    forever begin
      
      seq_item_port.get_next_item(t_h1);
      @(posedge intfc.clk);
      intfc.a<=t_h1.a;
      intfc.b<=t_h1.b;
      intfc.cin<=t_h1.cin;
      seq_item_port.item_done();
    end
  endtask
  
endclass

//MONITOR

class monitor extends uvm_monitor;
  
  `uvm_component_utils(monitor)
  
  transaction t_h2;
  virtual intf intfc;
  uvm_analysis_port #(transaction) col_port;
  
  function new(string name="monitor",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	if (!uvm_config_db #(virtual intf)::get(this,".","intfc",intfc))
  	`uvm_error("CFG", "Virtual interface not found")

    col_port = new("col_port",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    //super.run_phase(phase);
    forever begin
      @(posedge intfc.clk)
      t_h2 = transaction::type_id::create("t_h2", this);
      t_h2.a=intfc.a;
      t_h2.b=intfc.b;
      t_h2.cin=intfc.cin;
      //@(posedge intfc.clk)
      t_h2.sum=intfc.sum;
      t_h2.cout=intfc.cout;
      col_port.write(t_h2);
    end
  endtask
  
endclass

//AGENT

class agent extends uvm_agent;
  
  `uvm_component_utils(agent) 
   driver dvr;
   monitor mon;
   sqcr sqrh;
  
  function new(string name="agent",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     sqrh = sqcr::type_id::create("sqrh",this);
     dvr = driver::type_id::create("dvr",this);
     mon = monitor::type_id::create("mon",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dvr.seq_item_port.connect(sqrh.seq_item_export);
  endfunction
  
endclass

//SCOREBOARD
    
class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp #(transaction,scoreboard) col_imp;
  transaction t_h2[$];
  
  function new(string name="scoreboard",uvm_component parent=null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     col_imp = new("col_imp",this); 
  endfunction
  
  function void write(transaction t);
    t_h2.push_back(t);
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
    transaction tref;
    wait (t_h2.size() > 0);
    tref=t_h2.pop_front();
    
        if(tref.a+tref.b+tref.cin==tref.sum) $display("||TIME = %t|| PASS FOR: | A = %4b | B = %4b | Cin =%b | SUM = %4b | Cout = %b |",$time,tref.a,tref.b,tref.cin,tref.sum,tref.cout);
        else  $display("||TIME = %t|| FAIL FOR: | A = %4b | B = %4b | Cin =%b | SUM = %4b | Cout = %b |",$time,tref.a,tref.b,tref.cin,tref.sum,tref.cout); 
      $display("------------------------------------------------------");
        end
    
  endtask
  
endclass

//ENVIRONMENT

class env extends uvm_env;
  `uvm_component_utils(env)
  agent agt;
  scoreboard sb;
 
  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = agent::type_id::create("agt", this);
    sb = scoreboard::type_id::create("sb", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    agt.mon.col_port.connect(sb.col_imp);
  endfunction
endclass

//TEST

class test extends uvm_test;
  
  `uvm_component_utils(test)
  
  env env1;
  seq seq1;
  
  function new(string name = "test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env1 = env::type_id::create("env1", this);
  endfunction
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    repeat(5) begin    
      seq1=seq::type_id::create("seq1",this);
      #5;
      seq1.start(env1.agt.sqrh);
     end
    phase.drop_objection(this);
  endtask
  
endclass

//TOP MODULE

module tb;
  
  bit clk=0;
  intf intfc(clk);
  adder DUT(.a(intfc.a),.b(intfc.b),.cin(intfc.cin),.sum(intfc.sum),.cout(intfc.cout));
  
  always #5 clk=~clk;
  
  initial begin
    // set interface in config_db
    uvm_config_db #(virtual intf)::set(uvm_root::get(), "*", "intfc", intfc);
  end
  initial begin
    run_test("test");
  end
endmodule