`define MREAD   2'b01
`define MWRITE  2'b10
`define MNONE   2'b11

module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2, HEX3,HEX4,HEX5);
    input [3:0] KEY;
    input [9:0] SW;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire clk, reset;

    /* Internal Wires */
        // Negated because active-low
    assign clk = ~KEY[0];   
    assign reset = ~KEY[1];

    /* Ram Connections */
    wire [7:0] read_address, write_address;
    wire ram_write;
    wire [15:0] ram_din;
    wire [15:0] ram_dout;

    /* CPU outputs */
    wire [1:0] mem_cmd;
    wire [8:0] mem_addr;

    /* CPU Inputs */
    reg [15:0] read_data;

    /* read data logic */
    reg read_data_enable;
    reg msel;
    wire circuit1_out;      // IO Controller Output

    /* msel equivalent block logic */
    assign msel = (mem_addr[8] == 1'b0);

    /* AND gate for tri-state driver enable */
    assign read_data_enable = (mem_cmd == `MREAD) && msel;

    /* Tri-state driver for dout -> read_data */
    // assign read_data = read_data_enable ? ram_dout : {16{1'bz}};
    always_comb begin
        if (read_data_enable) begin
            read_data = ram_dout;
        end else if (circuit1_out) begin
            read_data = {8'h00, SW[7:0]};
        end else begin
            read_data = {16{1'bz}};
        end
    end

    /* write data logic */
    assign ram_write = (mem_cmd == `MWRITE) && msel;

    /* Ram instance */
    RAM #(.data_width (16), .addr_width (8)) MEM(
        .clk    (clk),
        .read_address   (read_address),
        .write_address  (write_address),
        .write          (ram_write),
        .din            (ram_din), // used to be ram_din
        .dout           (ram_dout)
    );

    /* RAM read and write address */
    assign read_address = mem_addr[7:0];
    assign write_address = mem_addr[7:0];

    /* RAM din */
    // assign ram_din = {16{1'b0}};

    /*temporary out wire*/
    // wire [15:0] out;        // cpu output 
    wire s, N, V, Z, w;

    /* CPU instance */
    cpu CPU (
        .clk    (clk),
        .reset  (reset),
        .s      (s),    // Delete later 
        .in     (read_data),
        .N      (N),
        .V      (V),
        .Z      (Z),
        .w      (w),
        .mem_addr   (mem_addr),
        .mem_cmd    (mem_cmd),
        .write_data (ram_din)       // Goes into RAM, used to b
    );

    // Controller for Memory-Mapped IO
    MappedIO IOController(
        .clk(clk), 
        .SW(SW), 
        .mem_cmd(mem_cmd), .mem_addr(mem_addr), 
        .write_data(ram_din), 
        .LEDR(LEDR),
        .circuit1_out(circuit1_out));

endmodule

