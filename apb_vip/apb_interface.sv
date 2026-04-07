interface apb_interface #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 32);
  
  // Global Signals
  logic PCLK;
  logic PRESETn;
  
  // Control Signals
  logic PSEL;    // Requester Signal
  logic PENABLE; // Requester Signal
  logic PREADY;  // Completer Signal
  logic PWRITE;  // Requester Signal
  logic [((DATA_WIDTH / 8) - 1) : 0] PSTRB;   // Requester Signal
  logic PSLVERR; // Completer Signal
  
  // Data Signals
  logic [ADDR_WIDTH - 1:0] PADDR;  // Requester Signal, Should be constrained based on the memory size we are dealing with
  logic [DATA_WIDTH - 1:0] PWDATA; // Requester Signal, Can be 8, 16 or 32 bits wide
  logic [DATA_WIDTH - 1:0] PRDATA; // Completer Signal, Can be 8, 16 or 32 bits wide
  
  modport APB_MASTER(
    input PCLK, PRESETn,
    input PRDATA, PREADY, PSLVERR, 
    output PSEL, PENABLE, PWRITE, PADDR, PWDATA
  );
  
  modport APB_SLAVE(
    input PCLK, PRESETn,
    input PSEL, PENABLE, PWRITE, PADDR, PWDATA,
    output PRDATA, PREADY, PSLVERR
  );
endinterface