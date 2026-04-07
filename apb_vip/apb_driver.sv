class apb_driver extends uvm_driver#(apb_seq_item);
  
  `uvm_component_utils(apb_driver)
  
  apb_seq_item transaction;
  virtual apb_interface apb_vif;
  
  logic [31:0] rdata;
  shortint wait_state_counter;
  
  function new(string path = "uvm_driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // Accessing the interface from config db, using get method
    if (!uvm_config_db#(virtual apb_interface) ::get(this, "", "apb_vif", apb_vif))
      `uvm_error("DRV", "Failed to retrieve interface from config db");
  endfunction
  
  // ----------------------------------------
  // APB Write Task
  // ----------------------------------------
  task apb_write(apb_seq_item transaction);
    // SETUP phase
    @(posedge apb_vif.PCLK);
    apb_vif.PSEL   <= 1;
    apb_vif.PWRITE <= 1;
    apb_vif.PADDR  <= transaction.addr;
    apb_vif.PWDATA <= transaction.data;
    apb_vif.PSTRB  <= 4'hF;
    
    // ACCESS phase
    @(posedge apb_vif.PCLK);
    apb_vif.PENABLE <= 1;
    wait_state_counter = 0;
    
    // Handling the wait states - Poll PREADY
    do begin
      @(posedge apb_vif.PCLK); // This will ensure that the PREADY is checked once ACCESS phase has been started
      if (!apb_vif.PREADY) 
        wait_state_counter++;
    end
    while (!apb_vif.PREADY);
    
    // IDLE 
    apb_vif.PSEL    <= 0;
    apb_vif.PENABLE <= 0;
    apb_vif.PWRITE  <= 0;
  endtask
  
  // ----------------------------------------
  // APB Read Task
  // ----------------------------------------
  task apb_read(apb_seq_item transaction);
    // SETUP phase
    @(posedge apb_vif.PCLK);
    apb_vif.PSEL   <= 1;
    apb_vif.PWRITE <= 0;
    apb_vif.PADDR  <= transaction.addr;
    apb_vif.PWDATA <= 0;
    apb_vif.PSTRB  <= 0;
    
    // ACCESS phase
    @(posedge apb_vif.PCLK);
    apb_vif.PENABLE <= 1;
    wait_state_counter = 0;
    
    // Poll PREADY
    do begin
      @(posedge apb_vif.PCLK); // This will ensure that the PREADY is checked once ACCESS phase has been started
      if (!apb_vif.PREADY) 
        wait_state_counter++;
    end
    while (!apb_vif.PREADY);
    
    transaction.read_data = apb_vif.PRDATA; // Capturing data from DUT
    transaction.pslverr   = apb_vif.PSLVERR;
    
    // IDLE 
    apb_vif.PSEL    <= 0;
    apb_vif.PENABLE <= 0;
  endtask
  
//   Different way to handle the reset phase
//   virtual task reset_phase(uvm_phase phase);
//     @(posedge apb_vif.PCLK);
//     apb_vif.PSEL    <= 0;
//     apb_vif.PENABLE <= 0;
//     apb_vif.PADDR   <= 32'h00;
//     apb_vif.PWDATA  <= 32'h00;
//     apb_vif.PWRITE  <= 0;
//   endtask
  
  virtual task run_phase(uvm_phase phase);
    
    forever begin
      seq_item_port.get_next_item(transaction);
      if (!apb_vif.PRESETn) begin
        apb_vif.PSEL    <= 0;
        apb_vif.PENABLE <= 0;
        apb_vif.PWRITE  <= 0;
        apb_vif.PADDR   <= 0;
        apb_vif.PWDATA  <= 0;
        apb_vif.PSTRB   <= 0;
        @(posedge apb_vif.PRESETn); // wait for reset to deassert
      end
      else if (transaction.rw == WRITE) begin
        apb_write(transaction);
      end
      else if (transaction.rw == READ) begin
        apb_read(transaction);
      end
      seq_item_port.item_done();
    end
  endtask
  
endclass