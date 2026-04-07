`include "uvm_macros.svh"
import uvm_pkg::*;

typedef enum bit {READ = 0, WRITE = 1} apb_txn_type_e;

class apb_seq_item extends uvm_sequence_item;
  
  `uvm_object_utils(apb_seq_item)
  
  rand bit [31:0]     addr;
  rand bit [31:0]     data;
  rand apb_txn_type_e rw;
  bit                 pslverr;
  bit [31:0]          read_data;
  
  function new (input string path = "apb_seq_item");
    super.new(path);
  endfunction
  
  constraint addr_constraint {
    addr[1:0] == 0;
  }
  
  constraint addr_range {
    addr inside {[0:'hFF]}; 
  }
  
  function void print_txn();
    $display ("PADDR = %0h, PWDATA = %0h, PWRITE = %0h", this.addr, this.data, this.rw);
  endfunction
endclass