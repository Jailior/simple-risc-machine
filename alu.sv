module ALU(Ain,Bin,ALUop,out,Z);

    /* ALU inputs */
    input [15:0] Ain, Bin;  // Operand(s)
    input [1:0] ALUop;      // Specifies the type of operation to do 

    /* ALU outputs  */
    output [15:0] out;      // Output of computation
    output [2:0] Z;               // Contains flags (Z, V, N)
    
    reg [2:0] Z;
    reg [15:0] out;

    wire hasOverFlow;
    
    // Combinational logic for ALU operations on input(s)
    always_comb begin
        case (ALUop)
            2'b00: out = Ain + Bin;  
            2'b01: out = Ain - Bin;  
            2'b10: out = Ain & Bin;  
            2'b11: out = ~Bin;
            default: out = {16{1'bX}};  
        endcase

        // Case logic for status register
        // Checking overflow ONLY for CMP (subtraction)
        if(ALUop == 2'b01) begin
            casex (out)
            16'd0:
                begin
                    Z[0] = 1'b1;
                    Z[1] = 1'b0;
                end
            16'b1xxxxxxxxxxxxxxx: 
                begin
                    Z[0] = 1'b0;
                    Z[1] = 1'b1;
                end
            default:
                begin
                    Z[0] = 1'b0;
                    Z[1] = 1'b0;
                end
            endcase 


            if (Ain[15] == 1'b0 && Bin[15] == 1'b1) begin
                case(out[15])
                    1'b0: Z[2] = 1'b0;
                    1'b1: Z[2] = 1'b1;
                endcase
            end else begin
                Z[2] =  1'b0;
            end

            if (Ain[15] == 1'b1 && Bin[15] == 1'b0) begin
                case(out[15])
                    1'b0: Z[2] = 1'b1;
                    1'b1: Z[2] = 1'b0;
                endcase
            end else begin
                Z[2] = 1'b0;
            end
        end else begin
            Z = 3'bxxx;
        end
    
    end
    
endmodule