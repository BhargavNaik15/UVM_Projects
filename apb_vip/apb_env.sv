class apb_env extends uvm_env;
  
  `uvm_component_utils(apb_env)
  
  function new(input string path = "ENV", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  apb_scoreboard sco;
  apb_agent agt;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sco = apb_scoreboard::type_id::create("sco", this);
    agt = apb_agent::type_id::create("agt", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.send.connect(sco.recv);
  endfunction
endclass