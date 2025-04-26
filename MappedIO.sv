`define MREAD   2'b01
`define MWRITE  2'b10
`define MNONE   2'b11

module MappedIO(
    clk,                     // Used for register in circuit 2
    SW,                     // External input
    mem_cmd, mem_addr,      // Memory control inputs
    write_data,   // Data read/write inputs
    LEDR,                    // External output
    circuit1_out            // Tri-state driver enable for SW / read_data 
);

    /* Module inputs & outputs */
    input clk;

    input [9:0] SW;
    input [1:0] mem_cmd;
    input [8:0] mem_addr;
    input [15:0] write_data;
     
    output reg [9:0] LEDR;
    output reg circuit1_out;            // Enable signal for tri-state drivers for SW
    
    // CHANGE: changed to always block
    // always_comb begin
    //     // CHANGE: changed read_data into a single assign statement
    //     // assign read_data[15:8] = circuit1_out ? 8'h00 : {8{1'bz}};
    //     // assign read_data[7:0] = circuit1_out ? SW[7:0] : {8{1'bz}};
    //     assign read_data = {{circuit1_out ? 8'h00 : {8{1'bz}}}, {circuit1_out ? SW[7:0] : {8{1'bz}}}};
    // end

    // Reading input for LDR instruction
    always_comb begin : Input_Circuit
        if((mem_cmd == `MREAD) && (mem_addr == 9'h140)) begin
            circuit1_out = 1;
        end else begin
            circuit1_out = 0;
        end
    end

    reg circuit2_out;
    reg [7:0] circuit2_reg_out;
    
    vDFFE #(8) circuit2_reg (clk, circuit2_out, write_data[7:0], circuit2_reg_out);

    // Output to LEDs for STR instruction
    always_comb begin : Output_Circuit
        if((mem_cmd == `MWRITE) && (mem_addr == 9'h100)) begin
            circuit2_out = 1;
        end else begin
            circuit2_out = 0;
        end
    end

    assign LEDR = {{2{1'b0}}, circuit2_reg_out};

endmodule