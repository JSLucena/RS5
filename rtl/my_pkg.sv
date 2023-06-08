/*!\file pkg.sv
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
 * Package definition.
 *
 * \detailed
 * Defines the package used in the processor units, it defines some types
 * for instruction formats, instruction types and execute units.
 */

package my_pkg;

    // `define PROTO 1
    // `define DEBUG 1
    // `define BRANCH_PREDICTION 1
    // `define XOSVM 1

    typedef enum  logic[5:0] {
        R_TYPE = 6'b000001, 
        I_TYPE = 6'b000010, 
        S_TYPE = 6'b000100, 
        B_TYPE = 6'b001000, 
        U_TYPE = 6'b010000, 
        J_TYPE = 6'b100000
    } formatType_e;

    typedef enum  logic[38:0] {
        NOP     = 39'b000000000000000000000000000000000000000,
        LUI     = 39'b000000000000000000000000000000000000001,
        SRET    = 39'b000000000000000000000000000000000000010,
        MRET    = 39'b000000000000000000000000000000000000100,
        WFI     = 39'b000000000000000000000000000000000001000,
        ECALL   = 39'b000000000000000000000000000000000010000,
        EBREAK  = 39'b000000000000000000000000000000000100000,
        INVALID = 39'b000000000000000000000000000000001000000,
        ADD     = 39'b000000000000000000000000000000010000000,
        SUB     = 39'b000000000000000000000000000000100000000,
        SLTU    = 39'b000000000000000000000000000001000000000,
        SLT     = 39'b000000000000000000000000000010000000000,
        XOR     = 39'b000000000000000000000000000100000000000,
        OR      = 39'b000000000000000000000000001000000000000,
        AND     = 39'b000000000000000000000000010000000000000,
        SLL     = 39'b000000000000000000000000100000000000000,
        SRL     = 39'b000000000000000000000001000000000000000,
        SRA     = 39'b000000000000000000000010000000000000000,
        BEQ     = 39'b000000000000000000000100000000000000000,
        BNE     = 39'b000000000000000000001000000000000000000,
        BLT     = 39'b000000000000000000010000000000000000000,
        BLTU    = 39'b000000000000000000100000000000000000000,
        BGE     = 39'b000000000000000001000000000000000000000,
        BGEU    = 39'b000000000000000010000000000000000000000,
        JAL     = 39'b000000000000000100000000000000000000000,
        JALR    = 39'b000000000000001000000000000000000000000,
        LB      = 39'b000000000000010000000000000000000000000,
        LBU     = 39'b000000000000100000000000000000000000000,
        LH      = 39'b000000000001000000000000000000000000000,
        LHU     = 39'b000000000010000000000000000000000000000,
        LW      = 39'b000000000100000000000000000000000000000,
        SB      = 39'b000000001000000000000000000000000000000,
        SH      = 39'b000000010000000000000000000000000000000,
        SW      = 39'b000000100000000000000000000000000000000,
        CSRRW   = 39'b000001000000000000000000000000000000000,
        CSRRS   = 39'b000010000000000000000000000000000000000,
        CSRRC   = 39'b000100000000000000000000000000000000000,
        CSRRWI  = 39'b001000000000000000000000000000000000000,
        CSRRSI  = 39'b010000000000000000000000000000000000000,
        CSRRCI  = 39'b100000000000000000000000000000000000000
    } iType_e;

    typedef enum  logic[1:0] {
        USER, SUPERVISOR, HYPERVISOR, MACHINE = 3
    } privilegeLevel_e;

    typedef enum  logic[1:0] {
        NONE, WRITE, SET, CLEAR
    } csrOperation_e;

    typedef enum  logic[1:0] {DIRECT, VECTORED} trapMode_e;

    typedef enum  logic[11:0] { 
        MVENDORID = 12'hF11, MARCHID, MIMPID, MHARTID, MCONFIGPTR, 
        MSTATUS = 12'h300, MISA, MEDELEG, MIDELEG, MIE, MTVEC, MCOUNTEREN, MSTATUSH = 12'h310, 
        MSCRATCH = 12'h340, MEPC, MCAUSE, MTVAL, MIP, MTINST = 12'h34A, MTVAL2,
    `ifdef XOSVM
        MVMDO = 12'h7C0, MVMDS, MVMIO, MVMIS, MVMCTL,
    `endif
        MCYCLE = 12'hB00, MINSTRET = 12'hB02, MCYCLEH = 12'hB80, MINSTRETH = 12'hB82,
        CYCLE = 12'hC00, TIME, INSTRET, CYCLEH=12'hC80, TIMEH, INSTRETH
    } CSRs;

    typedef enum  logic[4:0] {  
        INSTRUCTION_ADDRESS_MISALIGNED, INSTRUCTION_ACCESS_FAULT, ILLEGAL_INSTRUCTION, 
        BREAKPOINT, LOAD_ADDRESS_MISALIGNED, LOAD_ACCESS_FAULT, STORE_AMO_ADDRESS_MISALIGNED, 
        STORE_AMO_ACCESS_FAULT, ECALL_FROM_UMODE, ECALL_FROM_SMODE, ECALL_FROM_MMODE = 11, 
        INSTRUCTION_PAGE_FAULT, LOAD_PAGE_FAULT, STORE_AMO_PAGE_FAULT = 15, NE
    } exceptionCode_e;

    typedef enum  logic[4:0] {
        S_SW_INT = 1, M_SW_INT = 3, S_TIM_INT = 5, M_TIM_INT = 7, S_EXT_INT = 9, 
        M_EXT_INT = 11
    } interruptionCode_e;

endpackage

