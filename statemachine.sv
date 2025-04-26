/* State encoding for all states */  
`define wait        6'b000000    // DEPRECATED STATE

/* New states (Stage 1) */
`define RST         6'b010001
`define IF1         6'b010010
`define IF2         6'b010011
`define UpdatePC    6'b010100

/* New states (Stage 2) */
`define HALT        6'b111111

// LDR Instruction Branch
`define getAAdd_LDR 6'b010101
`define getB_LDR    6'b010110
`define ADD_LDR     6'b010111
`define READ        6'b011000
`define Write_MDATA1 6'b111001
`define Write_MDATA2 6'b111010

// STR Instruction Branch
`define getAAdd_STR 6'b011010
`define getB_STR    6'b011011
`define ADD_STR     6'b011100
`define getADD_Rd   6'b011101
`define addZero_STR 6'b011110
`define write       6'b011111


`define decodeState 6'b000001    // Decode 

// MOV (immediate) Instruction Branch
`define writeImmed  6'b000010    // WriteImmed for Mov operation

// MOV (between register) Instruction Branch
`define getB_Mov    6'b000011    
`define addZero_Mov 6'b000100
`define WriteReg    6'b000101

// ADD Instruction Branch
`define getA_Add    6'b000110
`define getB_Add    6'b000111
`define Add         6'b001000

// CMP Instruction Branch
`define getA_CMP    6'b001001
`define getB_CMP    6'b001010
`define CMP         6'b001011

// AND Instruction Branch
`define getA_And    6'b001100
`define getB_And    6'b001101
`define And         6'b001110

// MVN Instruction Branch
`define getB_Not    6'b001111
`define NOT_B       6'b010000

// Decoding Constants  
`define ALUop_ADD 2'b00
`define ALUop_CMP 2'b01
`define ALUop_AND 2'b10
`define ALUop_NOT 2'b11

`define MREAD   2'b01
`define MWRITE  2'b10
`define MNONE   2'b11

module statemachine (s, clk, reset, opcode, op, nsel, w, asel, bsel, vsel,
    loada, loadb, loadc, loads, write,
    load_pc, reset_pc, load_ir, addr_sel,
    mem_cmd, load_addr);

    input s, clk, reset;
    input [2:0] opcode;
    input [1:0] op;

    output reg w;                               // Signal for indicating wait 
    output reg [2:0] nsel;                      // Selector for Rn, Rm, Rd 

    output reg asel, bsel;                       // Selectors for A & B registers
    output reg [1:0] vsel;                       // Selectors for for input to datapath
    output reg loada, loadb, loadc, loads;       // Load signals for A, B, C and signal registers
    output reg write;                            // Load enable write signal for datapath

    output reg load_pc;
    output reg reset_pc;
    output reg load_ir;
    output reg addr_sel;
    output reg [1:0] mem_cmd;
    output reg load_addr;


    reg [5:0] present_state;
 

    always_ff @(posedge clk) begin
        if(reset) present_state = `RST;
        else begin
            case (present_state)
                // USE RST->IF1->IF2->Decode instead
                `RST:
                begin
                    present_state = `IF1;
                end
                `IF1:
                begin
                    present_state = `IF2;
                end
                `IF2:
                begin
                    present_state = `UpdatePC;
                end
                `UpdatePC:
                begin
                    present_state = `decodeState;
                end
                `decodeState:
                    begin
                        if(opcode == 3'b110) begin
                            case (op)
                                2'b10: present_state = `writeImmed;     // MOV Immediate branch
                                2'b00: present_state = `getB_Mov;       // MOV Register  branch        
                                default: present_state = 6'bXXXXX;
                            endcase
                        end else if (opcode == 3'b101) begin
                            case (op)
                                `ALUop_ADD: present_state = `getA_Add;  // ADD operation branch
                                `ALUop_CMP: present_state = `getA_CMP;  // CMP operation branch
                                `ALUop_AND: present_state = `getA_And;  // AND operation branch
                                `ALUop_NOT: present_state = `getB_Not;  // MVN operation branch
                                default: present_state = 6'bXXXXX;
                            endcase
                        end else if (opcode == 3'b011) begin
                            present_state = `getAAdd_LDR;               // LDR operation branch
                        end else if (opcode == 3'b100) begin
                            present_state = `getAAdd_STR;               // STR operation branch
                        end else if (opcode == 3'b111) begin
                            present_state = `HALT;                      // HALT
                        end
                        else begin
                            present_state = 6'bXXXXX; //Not sure
                        end
                    end
                `HALT:
                    begin
                        present_state = `HALT;
                    end
                `getAAdd_LDR:
                    begin
                        present_state = `getB_LDR;
                    end
                `getB_LDR:
                    begin
                        present_state = `ADD_LDR;
                    end
                `ADD_LDR:
                    begin
                        present_state = `READ;
                    end
                `READ:
                    begin
                        present_state = `Write_MDATA1;
                    end
                `Write_MDATA1:
                    begin
                        present_state = `Write_MDATA2;
                    end
                `Write_MDATA2:
                    begin
                        present_state = `IF1;
                    end
                `getAAdd_STR:
                    begin
                        present_state = `getB_STR;
                    end
                `getB_STR:
                    begin
                        present_state = `ADD_STR;
                    end
                `ADD_STR:
                    begin
                        present_state = `getADD_Rd;
                    end
                `getADD_Rd:
                    begin
                        present_state = `addZero_STR;
                    end
                `addZero_STR:
                    begin
                        present_state = `write;
                    end
                `write:
                    begin
                        present_state = `IF1;
                    end
                `writeImmed:
                    begin
                        present_state = `IF1;               // Back to IF1
                    end
                `getB_Mov:
                    begin
                        present_state = `addZero_Mov;           // Next state
                    end
                `addZero_Mov:
                    begin
                        present_state = `WriteReg;           // Next state
                    end
                    
                `WriteReg:
                    begin
                        present_state = `IF1;                // Back to IF1
                    end
                
                `getA_Add:
                    begin
                        present_state = `getB_Add;                // Next state
                    end
                `getB_Add:
                    begin
                        present_state = `Add;                // Next state
                    end
                `Add:
                    begin
                        present_state = `WriteReg;                // Next state
                    end
                `getA_CMP:
                    begin
                        present_state = `getB_CMP;                // Next state
                    end
                `getB_CMP:
                    begin
                        present_state = `CMP;                // Next state
                    end
                `CMP:
                    begin
                        present_state = `IF1;                // Back to IF1
                    end
                `getA_And:
                    begin
                        present_state = `getB_And;                // Next state
                    end
                `getB_And:
                    begin
                        present_state = `And;                // Next state
                    end
                `And:
                    begin
                        present_state = `WriteReg;
                    end
                `getB_Not:
                    begin
                        present_state = `NOT_B;                // Next state
                    end
                `NOT_B:
                    begin
                        present_state = `WriteReg;
                    end
                default:
                    begin
                        present_state = `IF1;  // Goes back to IF1 state
                        // MAYBE MAKE PRESENT STATE = 6'bXXXXX
                    end 
            endcase
        end
    end

    always_comb begin
        case (present_state)
            `RST:
                begin
                    reset_pc = 1'b1;
                    load_pc = 1'b1;

                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                    
                    // include other controls as zero??
                    nsel = 2'b00;
                    write = 1'b0;
                    vsel = 2'b00;
                    

                    asel = 1'b0; bsel = 1'b0;
                    loada = 1'b0; loadb = 1'b0;
                    loadc = 1'b0; loads = 1'b0;
                end
            `IF1:
                begin
                    addr_sel = 1'b1;
                    mem_cmd = `MREAD;

                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;

                    // include other controls as zero??
                    nsel = 2'b00;
                    write = 1'b0;
                    vsel = 2'b00;

                    asel = 1'b0; bsel = 1'b0;
                    loada = 1'b0; loadb = 1'b0;
                    loadc = 1'b0; loads = 1'b0;
                end
            `IF2:
                begin
                    addr_sel = 1'b1;
                    load_ir = 1'b1;
                    mem_cmd = `MREAD;

                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    load_addr = 0;

                    // include other controls as zero??
                    nsel = 2'b00;
                    write = 1'b0;
                    vsel = 2'b00;

                    asel = 1'b0; bsel = 1'b0;
                    loada = 1'b0; loadb = 1'b0;
                    loadc = 1'b0; loads = 1'b0;
                end
            `UpdatePC:
                begin
                    load_pc = 1'b1;

                    reset_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;

                    // include other controls as zero??
                    nsel = 2'b00;
                    write = 1'b0;
                    vsel = 2'b00;

                    asel = 1'b0; bsel = 1'b0;
                    loada = 1'b0; loadb = 1'b0;
                    loadc = 1'b0; loads = 1'b0;
                end
            `writeImmed:
                begin
                    vsel = 2'b10;
                    nsel = 2'b00;
                    write = 1;
                    asel = 0; bsel = 0;
                    loada = 0; loadb = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `getB_Mov:
                begin
                    loadb = 1; 
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loada = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            
            `addZero_Mov:
                begin
                    asel = 1; bsel = 0;
                    loadc = 1;
                    loads = 0;
                    
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    loada = 0; loadb = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `WriteReg:
                begin
                    nsel = 2'b01;
                    write = 1;
                    vsel = 2'b00;   // Reading/writing from output 

                    asel = 0; bsel = 0;
                    loada = 0; loadb = 0;
                    loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `getA_Add:
                begin
                    loada = 1; 
                    nsel = 2'b00;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loadb = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `getB_Add:
                begin
                    loadb = 1; 
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loada = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `Add:
                begin
                    asel = 0; bsel = 0;
                    loadc = 1;
                    loads = 0;
                    
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    loada = 0; loadb = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `getA_CMP:
                begin
                    loada = 1; 
                    nsel = 2'b00;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loadb = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `getB_CMP:
                begin
                    loadb = 1; 
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loada = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `CMP:
                begin
                    asel = 0;
                    bsel = 0;
                    loadc = 1;
                    loads = 1;
                    loada = 0; loadb = 0;
                    vsel = 2'bxx; nsel = 2'bxx;
                    write = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `getA_And:
                begin
                    loada = 1; 
                    nsel = 2'b00;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loadb = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `getB_And:
                begin
                    loadb = 1; 
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loada = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0; 
                end
            `And:
                begin
                    asel = 0;
                    bsel = 0;
                    loadc = 1;
                    loads = 0;
                    loada = 0; loadb = 0;
                    vsel = 2'bxx; nsel = 2'bxx;
                    write = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0; 
                    load_addr = 0;
                end
            `getB_Not:
                begin
                    loadb = 1; 
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loada = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                    
                end
            `NOT_B:
                begin
                    asel = 1;
                    bsel = 0;
                    loadc = 1;
                    loads = 0;
                    
                    loada = 0; loadb = 0;
                    write = 0; nsel = 2'b00; vsel = 2'b00;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            

            `getAAdd_LDR:
                begin
                    loada = 1; 
                    nsel = 2'b00; // Choose Rn
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loadb = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `getB_LDR:
                begin
                    loadb = 0; // dont load b register
                    bsel = 1;   // choose sximm5
                    
                    nsel = 2'b00;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; 
                    loada = 0; loadc = 1; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `ADD_LDR:
                begin
                    load_addr = 1;

                    asel = 0; bsel = 1;
                    loadc = 0;
                    loads = 0;
                    
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    loada = 0; loadb = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                end
            `READ:
                begin
                    addr_sel = 1'b0;
                    mem_cmd = `MREAD;
                    
                    nsel = 2'b00;
                    write = 1'b0;
                    vsel = 2'b00;
                    asel = 1'b0; bsel = 1'b0;
                    loada = 1'b0; loadb = 1'b0;
                    loadc = 1'b0; loads = 1'b0;
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `Write_MDATA1:
                begin
                    vsel = 2'b11;
                    nsel = 2'b01;
                    write = 1;
                    asel = 0; bsel = 0;
                    loada = 0; loadb = 0; loadc = 0; loads = 0;

                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MREAD;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `Write_MDATA2:
                begin
                    vsel = 2'b11;
                    nsel = 2'b01;
                    write = 1;
                    asel = 0; bsel = 0;
                    loada = 0; loadb = 0; loadc = 0; loads = 0;

                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MREAD;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end

            `getAAdd_STR:
                begin
                    loada = 1; 
                    nsel = 2'b00;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; bsel = 0;
                    loadb = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `getB_STR:
                begin
                    loadb = 1; 
                    bsel = 1;
                    
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; 
                    loada = 0; loadc = 1; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `ADD_STR:   
                begin
                    load_addr = 1;

                    asel = 0; bsel = 0;
                    loadc = 0;
                    loads = 0;
                    
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    loada = 0; loadb = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                end
            `getADD_Rd:
                begin
                    loadb = 1; 
                    bsel = 0;
                    
                    nsel = 2'b01;
                    write = 0;
                    vsel = 2'b00;
                    asel = 0; 
                    loada = 0; loadc = 0; loads = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `addZero_STR:
                begin
                    asel = 1; bsel = 0;
                    loadc = 1;
                    loads = 0;
                    
                    nsel = 2'b10;
                    write = 0;
                    vsel = 2'b00;
                    loada = 0; loadb = 0;

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MWRITE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end
            `write:
                begin
                    addr_sel = 0;
                    mem_cmd = `MWRITE;
                    nsel = 2'b01;
                    write = 1'b0;
                    vsel = 2'b00;

                    asel = 1'b0; bsel = 1'b0;
                    loada = 1'b0; loadb = 1'b0;
                    loadc = 1'b0; loads = 1'b0; // Bug fix

                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end

        
            default:
                begin
                    nsel = 2'b00;
                    write = 1'b0;
                    vsel = 2'b00;

                    asel = 1'b0; bsel = 1'b0;
                    loada = 1'b0; loadb = 1'b0;
                    loadc = 1'b0; loads = 1'b0; // Bug fix


                    /* maybe */
                    reset_pc = 1'b0;
                    load_pc = 1'b0;
                    mem_cmd = `MNONE;
                    addr_sel = 1'b0;
                    load_ir = 1'b0;
                    load_addr = 0;
                end 
        endcase
    end


    /* Combinational logic for w output */
    // always_comb begin
    //     if (present_state == `wait) begin
    //         w = 1;
    //     end
    //     else begin
    //         w = 0;
    //     end
    // end


endmodule