module instructDecoder (
    instructRegBus, nsel,                               // Inputs to decoder 
    opcode, op,                                         // Outputs to datapath
    ALUop, sximm5, sximm8, shift, readnum, writenum     // Outputs to Controller FSM 
);

    // Decoder inputs 
    input [15:0] instructRegBus;
    input [2:0] nsel;

    // Outputs to Controller FSM
    output [2:0] opcode;
    output [1:0] op;

    // Outputs to Datapath
    output [1:0] ALUop;
    output reg [15:0] sximm5;
    output reg [15:0] sximm8;
    output [1:0] shift; 
    output reg [2:0] readnum, writenum; 

    /* Simple assign statements for direct outputs */

    assign opcode = instructRegBus[15:13];  // To controller FSM
    assign op = instructRegBus[12:11];      // To controller FSM

    assign ALUop = instructRegBus[12:11];
    assign shift = instructRegBus[4:3];


    /* Combinational Logic for sign extending imm5 and imm8 */

    reg sign5;
    reg sign8;
    wire [4:0] imm5;
    wire [7:0] imm8;
    
    assign imm5 = instructRegBus[4:0];
    assign imm8 = instructRegBus[7:0];

    /* Sign extend computation */
    always_comb begin

        if(imm5[4] == 1'b1) begin
            sign5 = 1'b1;
        end else begin
            sign5 = 1'b0;
        end

        if(imm8[7] == 1'b1) begin
            sign8 = 1'b1;
        end else begin
            sign8 = 1'b0;
        end


        sximm5 = {{11{sign5}}, imm5};
        sximm8 = {{8{sign8}}, imm8};
        
    end

    /* Combinational logic for readnum & writenum */

    always_comb begin 
        case (nsel)
            2'b00: 
                begin
                    readnum = instructRegBus[10:8];     // Rn
                    writenum = instructRegBus[10:8];    // Rn
                end
            2'b01: 
                begin
                    readnum = instructRegBus[7:5];      // Rd
                    writenum = instructRegBus[7:5];     // Rd
                end
            2'b10: 
                begin
                    readnum = instructRegBus[2:0];      // Rm 
                    writenum = instructRegBus[2:0];     // Rm
                end
            default:
                begin
                    readnum = 3'bXXX;   
                    writenum = 3'bXXX;
                end
        endcase

    end


    
endmodule