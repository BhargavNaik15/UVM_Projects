class apb_test01 extends uvm_test;
  `uvm_component_utils(apb_test01)
  
  function new(input string path = "TEST", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  apb_sequence seq;
  apb_env      env;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = apb_sequence::type_id::create("seq");
    env = apb_env::type_id::create("env", this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.agt.seqr);
    #50;
    phase.drop_objection(this);
  endtask
  
endclass