module shifter(in,shift,sout);

    input [15:0] in;            // Binary value to shift
    input [1:0] shift;          // Shift type
    output [15:0] sout;         // Shifted value to output

    reg[15:0] sout;

    // Combination logic for determining output
    always_comb begin 
        case (shift)
            2'b00: sout = in;       // Shift by 0 (input is unchanged)
            2'b01: sout = in << 1;  // Logical shift left (fills with 0)
            2'b10: sout = in >> 1;  // Logical shift right (fills with 0)
            2'b11: sout = {in[15], in[15:1]}; // Shift right, keeping MSB unchanged
            default: sout = {16{1'bX}};
        endcase
    end
endmodule