class apb_sequence extends uvm_sequence#(apb_seq_item);
  `uvm_object_utils(apb_sequence)
  
  apb_seq_item tx;
  
  function new(string path = "apb_sequence");
    super.new(path);
  endfunction
  
  virtual task body();
    
    for (int i = 0; i < 500; i++) begin
      tx = apb_seq_item::type_id::create("tx"); // avoiding the over writing of field values in randomization by the time end component utilizes the data(scoreboard)
      start_item(tx);
      `uvm_info("GEN", $sformatf("Starting of transaction %0d", i + 1), UVM_NONE)
      
      assert(tx.randomize())
        else `uvm_fatal("GEN", "Randomization Failed")
      `uvm_info("GEN", $sformatf("Data sent to Driver: PADDR = %0h, PWDATA = %0h, PWRITE = %0d", tx.addr, tx.data, tx.rw), UVM_NONE)
      finish_item(tx);
      `uvm_info("GEN", $sformatf("End of transaction %0d", i + 1), UVM_NONE)
    end
  endtask
endclass