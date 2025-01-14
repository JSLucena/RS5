/*!\file testbench.sv
 * RS5 VERSION - 1.1.0 - Pipeline Simplified and Core Renamed
 *
 * Distribution:  July 2023
 *
 * Willian Nunes   <willian.nunes@edu.pucrs.br>
 * Marcos Sartori  <marcos.sartori@acad.pucrs.br>
 * Ney calazans    <ney.calazans@pucrs.br>
 *
 * Research group: GAPH-PUCRS  <>
 *
 * \brief
 * Testbench for RS5 simulation.
 *
 * \detailed
 * Testbench for RS5 simulation.
 */

`timescale 1ns/1ps

import RS5_pkg::*;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CPU TESTBENCH IMPLEMENTATION
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module Testbench_FPGA_Platform ();

    logic           clk=1, rstCPU;
    logic           BTND;

//////////////////////////////////////////////////////////////////////////////
// PARAMETERS FOR CORE INSTANTIATION
//////////////////////////////////////////////////////////////////////////////
    
    localparam int              i_cnt = 1;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// RESET CPU 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    initial begin
        rstCPU = 0;
        #1000 
        rstCPU = 1; 
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Clock generator
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    always begin
        #5.0 clk = 0;
        #5.0 clk = 1;
    end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CPU INSTANTIATION 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    RS5_FPGA_Platform #(
        .i_cnt      (i_cnt),
    ) dut (
        .clk        (clk), 
        .reset      (rstCPU), 
        .BTND       (BTND)
    );

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interrupt Emulation
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   /* 
    initial begin
        BTND  = 0;
        #3000
        BTND  = 1; 
    end
    */

endmodule
