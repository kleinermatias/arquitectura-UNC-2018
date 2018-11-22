`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////////////////////
// Trabajo Practico Nro. 4. MIPS.
// Memoria de programa.
// Integrantes: Kleiner Matias, Lopez Gaston.
// Materia: Arquitectura de Computadoras.
// FCEFyN. UNC.
// Anio 2018.
//////////////////////////////////////////////////////////////////////////////////////////////////


//  Xilinx Single Port No Change RAM
//  This code implements a parameterizable single-port no-change memory where when data is written
//  to the memory, the output remains unchanged.  This is the most power efficient write mode.
//  If a reset or enable is not necessary, it may be tied off or removed from the code.

module memoria_programa
#(
  parameter RAM_WIDTH = 16,                       // Specify RAM data width
  parameter RAM_DEPTH = 2048,                     // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
  parameter INIT_FILE = "",                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  parameter CANT_BIT_RAM_DEPTH = clogb2(RAM_DEPTH)
)
(
  input [clogb2(RAM_DEPTH) - 1 : 0] i_addr,   // Address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] dina,           // RAM input data (0)
  input i_clk,                            // Clock
  input wea,                            // Write enable (0)
  input ena,                            // RAM Enable, for additional power savings, disable port when not in use (1)
  input rsta,                           // Output reset (does not affect memory contents) (0)
  input regcea,                         // Output register enable (1)
  input soft_reset,
  output [RAM_WIDTH - 1 : 0] o_data,       // RAM output data
  output reg o_reset_ack
);

  reg [RAM_WIDTH - 1 : 0] BRAM [RAM_DEPTH - 1 : 0];
  reg [RAM_WIDTH - 1 : 0] ram_data = {RAM_WIDTH {1'b0}};
  reg [clogb2(RAM_DEPTH-1)-1 : 0] reg_contador;

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemb(INIT_FILE, BRAM, 0, RAM_DEPTH - 1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH {1'b0}};
    end
  endgenerate

  always @(posedge i_clk) begin
    if (~soft_reset) begin
      BRAM [reg_contador] <= 0;

      if (reg_contador == (CANT_BIT_RAM_DEPTH-1)) begin
        reg_contador <= reg_contador + 1;
        o_reset_ack <= 0;
      end
      else begin
        reg_contador <= reg_contador;
        o_reset_ack <= 1;
      end
    end
    else begin
      reg_contador <= 0;
      o_reset_ack <= 1;
      if (ena)
        if (wea)
          BRAM [i_addr] <= dina;
        else
          ram_data <= BRAM [i_addr];
    end
  end

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign o_data = ram_data;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH - 1 : 0] reg_data_out = {RAM_WIDTH {1'b0}};

      always @(posedge i_clk)
        if (rsta)
          reg_data_out <= {RAM_WIDTH {1'b0}};
        else if (regcea)
          reg_data_out <= ram_data;

      assign o_data = reg_data_out;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2 = 0; depth > 0; clogb2 = clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule

// The following is an instantiation template for xilinx_single_port_ram_no_change
/*
  //  Xilinx Single Port No Change RAM
  xilinx_single_port_ram_no_change #(
    .RAM_WIDTH(18),                       // Specify RAM data width
    .RAM_DEPTH(1024),                     // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
    .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
  ) your_instance_name (
    .addra(addra),    // Address bus, width determined from RAM_DEPTH
    .dina(dina),      // RAM input data, width determined from RAM_WIDTH
    .clka(clka),      // Clock
    .wea(wea),        // Write enable
    .ena(ena),        // RAM Enable, for additional power savings, disable port when not in use
    .rsta(rsta),      // Output reset (does not affect memory contents)
    .regcea(regcea),  // Output register enable
    .douta(douta)     // RAM output data, width determined from RAM_WIDTH
  );

*/
