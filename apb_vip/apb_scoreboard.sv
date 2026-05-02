class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)
  
  uvm_analysis_imp #(apb_seq_item, apb_scoreboard) recv;
  
  bit [31:0] virtual_memory [bit [31:0]];
  
  function new(string path = "apb_scoreboard", uvm_component parent = null);
    super.new(path, parent);
    recv = new("recv", this);
  endfunction
  
  virtual function void write(input apb_seq_item tx);
    
    `uvm_info("SCO",$sformatf("Data recieved from Monitor : PADDR = %0h, PWDATA = %0h, PWRITE = %0d, PRDATA = %0h, PSLVERR = %0d", tx.addr, tx.data, tx.rw, tx.read_data, tx.pslverr), UVM_NONE);
    if (tx.pslverr) begin
      `uvm_error("SCO", $sformatf("PSLVERR at ADDR=%0h", tx.addr))
    end
    else if (tx.rw ==WRITE) begin
      virtual_memory[tx.addr] = tx.data;
      `uvm_info("SCO", $sformatf("WRITE transaction stored: PADDR=%0h PWDATA=%0h", tx.addr, tx.data), UVM_NONE)
    end
    else begin
      if (!virtual_memory.exists(tx.addr)) begin
        `uvm_error("SCO", $sformatf("Read from uninitialized ADDR=%0h", tx.addr))
      end
      else if (virtual_memory[tx.addr] == tx.read_data) begin
        `uvm_info("SCO", $sformatf("PASSED: PADDR=%0h expected=%0h got=%0h", tx.addr, virtual_memory[tx.addr], tx.read_data), UVM_NONE)
      end
      else begin
        `uvm_error("SCO", $sformatf("FAILED: ADDR=%0h expected=%0h got=%0h", tx.addr, virtual_memory[tx.addr], tx.read_data))
      end
    end
  endfunction
endclass