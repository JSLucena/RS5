/*!\file retire.sv
 * PUC-RS5 VERSION - 1.0.0 - Public Release
 *
 * Distribution:  March 2023
 *
 * Willian Nunes   <willian.nunes@edu.pucrs.br>
 * Marcos Sartori  <marcos.sartori@acad.pucrs.br>
 * Ney calazans    <ney.calazans@pucrs.br>
 *
 * Research group: GAPH-PUCRS  <>
 *
 * \brief
 * Retire is the last stage of the PUC-RS5 processor core.
 *
 * \detailed
 * Retire is the last stage of the PUC-RS5 processor core and is reponsible for closing the loops.
 * First compares the instruction tag with the internal tag, if they do not match then the 
 * instruction is killed and no operation is performed, otherwise it sends the data received 
 * for the given output, they are: 
 * 1) Register bank - data and write enable
 * 2) Branch - jump target
 * 3) Memory write - memory signals (Data, address and operation enable)
 * 4) Manage Exceptions and Interrupts and Privilege Switch.
 */

module retire
    import my_pkg::*;
(
    input   logic [31:0]    instruction_i,
    input   logic [31:0]    pc_i,
    input   logic [31:0]    results_i [1:0],
    input   logic           killed_i,
    input   logic           write_enable_i,
    input   logic           jump_i,
    input   iType_e         instruction_operation_i,
    input   logic [31:0]    mem_data_i,
    
    input   logic           exc_ilegal_inst_i,
    input   logic           exc_misaligned_fetch_i,
`ifdef XOSVM
    input   logic           exc_inst_access_fault_i,
    input   logic           exc_load_access_fault_i,
`endif

`ifdef BRANCH_PREDICTION
    input   logic           predicted_branch_i,
`endif

    output  logic           regbank_write_enable_o,     // Write Enable to Register Bank
    output  logic [31:0]    regbank_data_o,             // WriteBack data to Register Bank
    output  logic [31:0]    jump_target_o,              // Branch target to fetch Unit
    output  logic           jump_o,                     // Jump signal to Fetch Unit
    output  logic           jumped_o,

    output  exceptionCode_e exception_code_o,
    output  logic           raise_exception_o,
    output  logic           machine_return_o,
    output  logic           interrupt_ack_o,
    input   logic           interrupt_pending_i
);

    logic [31:0]    memory_data;

//////////////////////////////////////////////////////////////////////////////
// Assign to Register Bank Write Back
//////////////////////////////////////////////////////////////////////////////

    assign regbank_data_o = (instruction_operation_i inside {LB,LBU,LH,LHU,LW}) 
                            ? memory_data 
                            : results_i[0];

//////////////////////////////////////////////////////////////////////////////
// Jumped signal generation
//////////////////////////////////////////////////////////////////////////////
    assign jumped_o = jump_o | machine_return_o | raise_exception_o | interrupt_ack_o;

//////////////////////////////////////////////////////////////////////////////
// RegBank Write Enable Generation
//////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (killed_i) begin
            regbank_write_enable_o = 0;
        end 
        else begin
            regbank_write_enable_o = write_enable_i;
        end
    end

//////////////////////////////////////////////////////////////////////////////
// PC Flow control signal generation
//////////////////////////////////////////////////////////////////////////////
`ifdef BRANCH_PREDICTION
    always_comb begin
        // If should have jumped and predicted not jump then jump
        if (jump_i && !predicted_branch_i && !killed_i) begin
            jump_o          = 1;
            jump_target_o   = results_i[1];
        end
        // If should not have jumped and predicted jump then return
        else if (!jump_i && predicted_branch_i && !killed_i) begin
            jump_o          = 1;
            jump_target_o   = pc_i + 4;
        end
        // Predicted Right or not a Jump
        else begin
            jump_o          = 0;
            jump_target_o   = '0;
        end
    end
`else
    always_comb begin
        if (jump_i && !killed_i) begin
            jump_target_o = results_i[1];
            jump_o        = 1;
        end 
        else begin
            jump_target_o = '0;
            jump_o        = '0;
        end
    end
`endif

//////////////////////////////////////////////////////////////////////////////
// Memory Signal Generation
//////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (instruction_operation_i == LB || instruction_operation_i == LBU) begin
            case (results_i[0][1:0])
                2'b11:   begin 
                            memory_data[7:0]  = mem_data_i[31:24]; 
                            memory_data[31:8] = (mem_data_i[31] && instruction_operation_i == LB) 
                                                ? '1 
                                                : '0;
                        end
                2'b10:   begin 
                            memory_data[7:0]  = mem_data_i[23:16]; 
                            memory_data[31:8] = (mem_data_i[23] && instruction_operation_i == LB) 
                                                ? '1 
                                                : '0; 
                        end
                2'b01:   begin 
                            memory_data[7:0]  = mem_data_i[15:8];
                            memory_data[31:8] = (mem_data_i[15] && instruction_operation_i == LB) 
                                                ? '1 
                                                : '0; 
                        end
                default: begin 
                            memory_data[7:0]  = mem_data_i[7:0]; 
                            memory_data[31:8] = (mem_data_i[7] && instruction_operation_i == LB) 
                                                ? '1 
                                                : '0; 
                        end
            endcase
        end
        else if (instruction_operation_i == LH || instruction_operation_i == LHU) begin
            case (results_i[0][1])
                1'b1:    begin 
                            memory_data[15:0]  = mem_data_i[31:16]; 
                            memory_data[31:16] = (mem_data_i[31] && instruction_operation_i == LH) 
                                                ? '1 
                                                : '0; 
                        end
                default: begin  
                            memory_data[15:0]  = mem_data_i[15:0]; 
                            memory_data[31:16] = (mem_data_i[15] && instruction_operation_i == LH) 
                                                ? '1 
                                                : '0; 
                        end
            endcase
        end 
        else begin
            memory_data = mem_data_i;
        end
    end

//////////////////////////////////////////////////////////////////////////////
// Privileged Architecture Control
//////////////////////////////////////////////////////////////////////////////

    always_comb begin
        if (!killed_i) begin
        `ifdef XOSVM
            if (exc_inst_access_fault_i) begin
                raise_exception_o = 1;
                exception_code_o  = ILLEGAL_INSTRUCTION;
                machine_return_o  = 0;
                interrupt_ack_o   = 0;
                exception_code_o  = INSTRUCTION_ACCESS_FAULT;
                $write("[%0d] EXCEPTION - INSTRUCTION ACCESS FAULT: %8h %8h\n", $time, pc_i, instruction_i);
            end
            else
        `endif
            if (exc_ilegal_inst_i) begin
                raise_exception_o = 1;
                machine_return_o  = 0;
                interrupt_ack_o   = 0;
                exception_code_o  = ILLEGAL_INSTRUCTION;
                $write("[%0d] EXCEPTION - ILLEGAL INSTRUCTION: %8h %8h\n", $time, pc_i, instruction_i);
            end 
            else if (exc_misaligned_fetch_i) begin
                raise_exception_o = 1;
                machine_return_o  = 0;
                interrupt_ack_o   = 0;
                exception_code_o  = INSTRUCTION_ADDRESS_MISALIGNED;
                $write("[%0d] EXCEPTION - INSTRUCTION ADDRESS MISALIGNED: %8h %8h\n", $time, pc_i, instruction_i);
            end 
            else if (instruction_operation_i == ECALL) begin
                raise_exception_o = 1;
                exception_code_o  = ECALL_FROM_MMODE;
                machine_return_o  = 0;
                interrupt_ack_o   = 0;
                $write("[%0d] EXCEPTION - ECALL_FROM_MMODE: %8h %8h\n", $time, pc_i, instruction_i);
            end 
            else if (instruction_operation_i == EBREAK) begin
                raise_exception_o = 1;
                exception_code_o  = BREAKPOINT;
                machine_return_o  = 0;
                interrupt_ack_o   = 0;
                $write("[%0d] EXCEPTION - EBREAK: %8h %8h\n", $time, pc_i, instruction_i);
            end
        `ifdef XOSVM
            else if (exc_load_access_fault_i) begin
                raise_exception_o = 1;
                machine_return_o  = 0;
                interrupt_ack_o   = 0;
                exception_code_o  = LOAD_ACCESS_FAULT;
                $write("[%0d] EXCEPTION - LOAD ACCESS FAULT: %8h %8h\n", $time, pc_i, instruction_i);
            end 
        `endif
            else if (instruction_operation_i == MRET) begin
                raise_exception_o = 0;
                exception_code_o  = NE;
                machine_return_o  = 1;
                interrupt_ack_o   = 0;
                $write("[%0d] MRET: %8h %8h\n", $time, pc_i, instruction_i);
            end 
            else if (interrupt_pending_i) begin
                raise_exception_o = 0;
                exception_code_o  = NE;
                machine_return_o  = 0;
                interrupt_ack_o   = 1;
                $write("[%0d] Interrupt Acked\n", $time);
            end
            else begin
                raise_exception_o = 0;
                exception_code_o  = NE;
                machine_return_o  = 0;
                interrupt_ack_o   = 0;
            end
        end
        else begin
            raise_exception_o = 0;
            exception_code_o  = NE;
            machine_return_o  = 0;
            interrupt_ack_o   = 0;
        end
    end
endmodule
