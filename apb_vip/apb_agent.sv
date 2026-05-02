class apb_agent extends uvm_agent;
  
  `uvm_component_utils(apb_agent)
  
  function new(input string inst = "AGENT", uvm_component parent = null);
    super.new(inst, parent);
  endfunction
  
  apb_monitor mon;
  apb_driver drv;
  uvm_sequencer #(apb_seq_item) seqr;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = apb_monitor::type_id::create("mon", this);
    drv = apb_driver::type_id::create("drv", this);
    seqr = uvm_sequencer #(apb_seq_item)::type_id::create("seqr", this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass