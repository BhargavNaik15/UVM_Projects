class apb_monitor extends uvm_monitor;
  
  `uvm_component_utils(apb_monitor)
  uvm_analysis_port #(apb_seq_item) send;
  
  function new(string path = "apb_monitor", uvm_component parent = null);
    super.new(path, parent);
    send = new("send", this);
  endfunction
  
  apb_seq_item transaction;
  virtual apb_interface apb_vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!uvm_config_db #(virtual apb_interface)::get(this, "", "apb_vif", apb_vif))
      `uvm_error("MON", "Failed to retrieve interface from config db")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin 
      transaction = apb_seq_item::type_id::create("transaction"); // Evrytime a new handle is created for transaction
      if (!apb_vif.PRESETn) begin////////////////////////
        // Doesn't have to read the slave pins as reset has been asserted by the Master
        ////////////////////////////////////////////////////////
        @(posedge apb_vif.PRESETn);
      end
      else begin
        @(posedge apb_vif.PCLK);
        if (apb_vif.PSEL) begin
          transaction.addr      = apb_vif.PADDR;
          transaction.data      = apb_vif.PWDATA;
          transaction.rw        = apb_txn_type_e'(apb_vif.PWRITE);
          
          @(posedge apb_vif.PCLK);
          if (apb_vif.PENABLE) begin
            do
              @(posedge apb_vif.PCLK);
            while (!apb_vif.PREADY);
          end
          else begin
            // Wait for PENABLE if not already high
            if (!apb_vif.PENABLE)
              @(posedge apb_vif.PCLK iff apb_vif.PENABLE);

            // Now wait for completion of the ACCESS phase 
            do
              @(posedge apb_vif.PCLK);
            while (!(apb_vif.PSEL && apb_vif.PENABLE && apb_vif.PREADY));
          end
          transaction.pslverr   = apb_vif.PSLVERR;
          transaction.read_data = apb_vif.PRDATA;
          send.write(transaction);
          `uvm_info("MON", $sformatf("Data send to Scoreboard PADDR = %0h, PWDATA = %0h, PWRITE = %0h, PRDATA = %0h, PSLVERR = %0h", transaction.addr, transaction.data, transaction.rw, transaction.pslverr, transaction.read_data), UVM_NONE)
        end
      end
    end
  endtask
endclass