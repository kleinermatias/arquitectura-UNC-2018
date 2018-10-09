
module address_calculator
#(
  parameter PC_CANT_BITS = 11,
  parameter SUM_DIR = 1
)

(
  input i_clock,
  input i_reset,
  input i_wrPC,
  output [PC_CANT_BITS-1:0] o_addr
);

  wire ena = 1 ;                  // RAM Enable, for additional power savings, disable port when not in use
  wire rsta = 0 ;                 // Output reset (does not affect memory contents)


  reg [PC_CANT_BITS-1:0] reg_PC;
  reg reg_aux_wrPC;



  always @(posedge i_clock)
    if (~i_reset) begin
      reg_PC <= 0;
      reg_aux_wrPC <= 0;
    end
    else begin
      reg_aux_wrPC <= i_wrPC;
      if (i_wrPC && ~reg_aux_wrPC) begin
        reg_PC <= reg_PC + SUM_DIR;
      end
      else begin
        reg_PC <= reg_PC;
      end
    end

    assign o_addr = reg_PC;

endmodule