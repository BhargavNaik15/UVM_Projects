`include "uvm_macros.svh"
import uvm_pkg::*;
`include "apb_interface.sv"
`include "apb_seq_item.sv"
`include "apb_sequence.sv"
`include "apb_monitor.sv"
`include "apb_driver.sv"
`include "apb_scoreboard.sv"
`include "apb_agent.sv"
`include "apb_env.sv"
`include "apb_test01.sv"

module apb_tb();
  apb_interface apb_vif();
  
  // Clock setting
  initial begin
    apb_vif.PCLK = 0;
  end
  
  always #5 apb_vif.PCLK = ~apb_vif.PCLK;
  
  // Applying PRESETn to the DUT
  initial begin
    apb_vif.PRESETn = 0;
    repeat(4) @(posedge apb_vif.PCLK);
    apb_vif.PRESETn = 1;
  end
  
  apb_slave_bfm dut(.apb(apb_vif.APB_SLAVE), .inject_error(0));
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  initial begin
    uvm_config_db #(virtual apb_interface)::set(null, "*", "apb_vif", apb_vif);
    run_test("apb_test01");
  end
endmodule