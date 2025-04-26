module datapath (
    clk, readnum, vsel, loada, loadb,       // Used for fetching operand(s) for ALU
    shift, asel, bsel, ALUop, loadc, loads, // Used for computation/execution stage 
    writenum, write,                        // Used for writing back to register file instance
    PC, sximm8, sximm5, mdata,              // Lab 6: new inputs
    Z_out, datapath_out                     // Datapath outputs 
);

    // module parameters
    input clk;
    input [2:0] readnum, writenum;          // instruction decoder
    input asel, bsel;                       // controller
    input [1:0] vsel;                       // controller
    input loada, loadb, loadc, loads;       // controller
    input write;                            // controller
    input [1:0] ALUop;                      // instruction decoder
    input [1:0] shift;                      // instruction decoder

    input [8:0] PC;
    input [15:0] sximm8;                    // instruction decoder
    input [15:0] sximm5;                    // instruction decoder
    input [15:0] mdata;

    output [2:0] Z_out;
    output [15:0] datapath_out;
    


    // Internal signals 
    wire [15:0] aout, bout;                 // outputs of A, B registers
    reg [15:0] data_in;                    // input to regfile
    wire [15:0] data_out;                   // output of regfile
    wire [15:0] Ain, Bin, Cin;              // inputs of A, B and C registers
    wire [2:0]  Z;                          // Z output of ALU
    wire [15:0] shift_out;                  // output of shifter

    
    // assign PC = 8'd0;                       // temporary assign for lab 7
    
    // Multiplexer for data_in
    always_comb begin
        case (vsel)
            2'b00: data_in =  datapath_out;
            2'b01: data_in = {7'd0, PC};        // LAB 7 BONUS
            2'b10: data_in = sximm8;
            2'b11: data_in = mdata;
            default: data_in = {16{1'bx}};
        endcase
    end

    regfile REGFILE(data_in, writenum, write, readnum, clk, data_out);    // regfile instance
    shifter SHIFTER(bout, shift, shift_out);                    // shifter instance
    ALU     alu(Ain, Bin, ALUop, Cin, Z);                       // alu instance

    // Multiplexers for inputs into Arithmetic Logic Unit (ALU)
    assign Ain = asel ? 16'b0 : aout;
    assign Bin = bsel ? sximm5 : shift_out;

    vDFFE loadaREG(clk, loada, data_out, aout); // A register instance
    vDFFE loadbREG(clk, loadb, data_out, bout); // B register instance
    vDFFE loadcREG(clk, loadc, Cin, datapath_out); // C register instance
    vDFFE #(3) statusREG(clk, loads, Z, Z_out); // Status register instance, Parameterized 3-bit load-enabled register for status
    
    
endmodule