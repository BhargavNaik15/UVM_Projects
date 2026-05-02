// In apb_slave_bfm — add an input flag
module apb_slave_bfm (apb_interface.APB_SLAVE apb, input logic inject_error = 0);
  // Simple 256-depth memory
  logic [31:0] mem [0:255];
  
  always @(posedge apb.PCLK or negedge apb.PRESETn) begin
    if (!apb.PRESETn) begin
      apb.PREADY  <= 0;
      apb.PSLVERR <= 0;
    end 
    else begin
      apb.PREADY  <= 0;
      apb.PSLVERR <= 0;
      if (apb.PSEL && apb.PENABLE) begin
        apb.PREADY  <= 1;
        apb.PSLVERR <= inject_error;
        if (apb.PWRITE && !inject_error)
          mem[apb.PADDR[7:0]] <= apb.PWDATA;
      end
    end
  end
  
  // Separate combinational read — no clock delay
  assign apb.PRDATA = (!apb.PWRITE && apb.PSEL) ? mem[apb.PADDR[7:0]] : '0;
endmodule