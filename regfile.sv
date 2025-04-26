module regfile (data_in,writenum,write,readnum,clk,data_out);
    input [15:0] data_in;
    input [2:0] writenum, readnum;
    input write, clk;
    output [15:0] data_out;
    reg [15:0] data_out;

    wire [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
    reg [7:0] en;

    // register file instansiation
    vDFFE rg0 (clk, en[0], data_in, R0);
    vDFFE rg1 (clk, en[1], data_in, R1);
    vDFFE rg2 (clk, en[2], data_in, R2);
    vDFFE rg3 (clk, en[3], data_in, R3);
    vDFFE rg4 (clk, en[4], data_in, R4);
    vDFFE rg5 (clk, en[5], data_in, R5);
    vDFFE rg6 (clk, en[6], data_in, R6);
    vDFFE rg7 (clk, en[7], data_in, R7);

    // combinational readnum (3:8 decoder + multiplexer)
    always_comb begin
        case(readnum)
            3'b000: data_out = R0;
            3'b001: data_out = R1;
            3'b010: data_out = R2;
            3'b011: data_out = R3;
            3'b100: data_out = R4;
            3'b101: data_out = R5;
            3'b110: data_out = R6;
            3'b111: data_out = R7;
        endcase
    end

    // write to a register (3:8 decoder for writenum)
    always_comb begin
        if (write) begin
            case(writenum)
                3'b000: en = 8'b00000001;
                3'b001: en = 8'b00000010;
                3'b010: en = 8'b00000100;
                3'b011: en = 8'b00001000;
                3'b100: en = 8'b00010000;
                3'b101: en = 8'b00100000;
                3'b110: en = 8'b01000000;
                3'b111: en = 8'b10000000;
            endcase
        end
        else begin
            en = 8'b00000000;
        end
    end


endmodule

// register with load enable
module vDFFE(clk, en, in, out);
    parameter n = 16; // default width
    input clk, en;
    input  [n-1:0] in;
	output [n-1:0] out;
	reg    [n-1:0] out;
	wire   [n-1:0] next_out;

	assign next_out = en ? in : out;

	always @(posedge clk)
		out = next_out;

endmodule