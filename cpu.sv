`define ALUadd 2'b00

module cpu(clk, reset, s, in, N, V, Z, w,
            mem_addr, mem_cmd,
            write_data);

    /* CPU inputs */    
    input clk, reset, s; 
    input [15:0] in; // aka read_data

    /* CPU outputs */
    output reg [8:0] mem_addr;
    output [1:0] mem_cmd;
    output N, V, Z, w;
    output [15:0] write_data;

    /**         Internal wires          **/
    
    /* For use in lab 7 */
    wire [15:0] instruction;                // Encoded instruction 
    wire [15:0] mdata;                      // mdata
    
    /* State machine outputs */
    wire [2:0] nsel;                        // Selector for Rn, Rm, Rd 
    wire asel, bsel;                        // Selectors for A & B registers
    wire [1:0] vsel;                        // Selectors for for input to datapath
    wire loada, loadb, loadc, loads;        // Load signals for A, B, C and signal registers
    wire write;                             // Load enable write signal for datapath

    /* NEW state machine outputs */
    wire load_pc;
    wire reset_pc;
    wire load_ir;
    wire addr_sel;

    /* Instruction Decoder outputs */
    wire [2:0] opcode;
    wire [1:0] op;

    wire [1:0] ALUop;
    wire [15:0] sximm5;
    wire [15:0] sximm8;
    wire [1:0] shift; 
    wire [2:0] readnum, writenum; 

    /* Datapath output */
    wire [2:0] Z_out;
    wire [8:0] PCdep;

    /* Program Counter Logic */
    wire [8:0] PC;
    reg [8:0] next_pc;

    /* (3) in Figure 4 */
    vDFFE #(9) programcounter (clk, load_pc, next_pc, PC);

    /* Stage 2 Stuff */
    wire [8:0] dataAddress; // Output o daatAddress_Reg
    wire load_addr; // Output of state machine 
    assign mdata = in; // mdata = in = read_data
    
    vDFFE #(9) dataAddress_Reg (clk, load_addr, write_data[8:0], dataAddress);

    /*------------------------------*/

    // Multiplexer for next_pc
    always_comb begin
        if(reset_pc) begin
            next_pc = 9'b0;
        end else begin
            next_pc = PC + 9'd1;
        end
    end

    // Multiplexer for mem_addr
    always_comb begin
        if(addr_sel) begin
            mem_addr = PC;
        end else begin
            mem_addr = dataAddress; 
        end
    end


    vDFFE insReg (clk, load_ir, in, instruction);  // Instruction register 
    
    instructDecoder insDecoder(                 // Decoder for instruction (encoded in 16 bits)
        .instructRegBus     (instruction),
        .nsel               (nsel),
        .opcode             (opcode),
        .op                 (op),
        .ALUop              (ALUop),
        .sximm5             (sximm5),
        .sximm8             (sximm8),
        .shift              (shift),
        .readnum            (readnum),
        .writenum           (writenum)
    );              
        
    datapath DP(                          // Datapath 
        .clk         (clk),
        .readnum     (readnum),
        .vsel        (vsel),
        .loada       (loada),
        .loadb       (loadb),

        .shift       (shift),
        .asel        (asel),
        .bsel        (bsel),
        .ALUop       (ALUop),
        .loadc       (loadc),
        .loads       (loads),

        .writenum    (writenum),
        .write       (write),

        .PC          (PCdep),
        .sximm5      (sximm5),
        .sximm8      (sximm8),
        .mdata       (mdata),       // Memory data

        // outputs
        .Z_out       (Z_out),
        .datapath_out(write_data)
    );

    
    /* Flag assignments from status register */
    assign Z = Z_out[0];
    assign N = Z_out[1];
    assign V = Z_out[2];    

    statemachine fsm (                          // Controller FSM for datapath 
                    .s( s ), 
                    .clk( clk ), 
                    .reset( reset ),
                    .opcode( opcode ), 
                    .op( op ), 
                    .nsel( nsel ), 
                    .w( w ), 
                    .asel( asel ), 
                    .bsel( bsel ), 
                    .vsel( vsel ),
                    .loada( loada ), 
                    .loadb( loadb ), 
                    .loadc( loadc ), 
                    .loads( loads ), 
                    .write( write ),

                    /* new outputs */
                    .load_pc (load_pc),
                    .reset_pc (reset_pc),
                    .load_ir (load_ir),
                    .addr_sel (addr_sel),
                    .mem_cmd (mem_cmd),
                    .load_addr (load_addr)
    );           


    

    




endmodule