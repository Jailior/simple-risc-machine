module lab7_stage3_tb;
  reg [3:0] KEY;
  reg [9:0] SW;
  wire [9:0] LEDR; 
  wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  reg err;

  lab7_top DUT(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5);

  initial forever begin
    KEY[0] = 0; #5;
    KEY[0] = 1; #5;
  end

  initial begin
    err = 0;
    KEY[1] = 1'b0; // Reset asserted

    // Check if program from Figure 8 in Lab 7 handout can be found loaded in memory (just checking first 3 lines)
    if (DUT.MEM.mem[0] !== 16'b1101000000001000) begin err = 1; $display("FAILED: mem[0] wrong; please set data.txt using Figure 8"); $stop; end
    if (DUT.MEM.mem[1] !== 16'b0110000000000000) begin err = 1; $display("FAILED: mem[1] wrong; please set data.txt using Figure 8"); $stop; end
    if (DUT.MEM.mem[2] !== 16'b0110000001000000) begin err = 1; $display("FAILED: mem[2] wrong; please set data.txt using Figure 8"); $stop; end

    @(negedge KEY[0]); //Wait until next falling edge of clock

    KEY[1] = 1'b1; // Reset de-asserted, PC still undefined if as in Figure 4

    /* Input assigned for IO testing */
    SW = {2'h0, 8'd15};

    #10; // Waiting for RST state to cause reset of PC

    if (DUT.CPU.PC !== 9'b0) begin err = 1; $display("FAILED: PC is not reset to zero."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  // Wait here until PC changes; autograder expects PC set to 1 *before* executing MOV R0, X

    if (DUT.CPU.PC !== 9'h1) begin err = 1; $display("FAILED: PC should be 1."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  

    /* After MOV R0, SW_BASE */
    if (DUT.CPU.PC !== 9'h2) begin err = 1; $display("FAILED: PC should be 2."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h8) begin err = 1; $display("FAILED: R0 should be 8."); $stop; end  // because MOV R0, #7 should have occurred

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC); 

    /* After LDR R0, [R0] */
    if (DUT.CPU.PC !== 9'h3) begin err = 1; $display("FAILED: PC should be 3."); $stop; end
    if (DUT.CPU.DP.REGFILE.R0 !== 16'h140) begin err = 1; $display("FAILED: R0 should be 140."); $stop; end  // because MOV R1, #2 should have occurred

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  

    /* After LDR R2, [R0] */
    if (DUT.CPU.PC !== 9'h4) begin err = 1; $display("FAILED: PC should be 4."); $stop; end
    if (DUT.CPU.DP.REGFILE.R2 !== 16'd15) begin err = 1; $display("FAILED: R2 should be 15."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  

    /* After MOV R3, R2, LSL #1 */
    if (DUT.CPU.PC !== 9'h5) begin err = 1; $display("FAILED: PC should be 5."); $stop; end
    if (DUT.CPU.DP.REGFILE.R3 !== 16'd30) begin err = 1; $display("FAILED: R3 should be 30."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  

    /* After MOV R1, LEDR_BASE */
    if (DUT.CPU.PC !== 9'h6) begin err = 1; $display("FAILED: PC should be 6."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'd9) begin err = 1; $display("FAILED: R1 should be 10."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  

    /* After LDR R1, [R1] */
    if (DUT.CPU.PC !== 9'h7) begin err = 1; $display("FAILED: PC should be 7."); $stop; end
    if (DUT.CPU.DP.REGFILE.R1 !== 16'h100) begin err = 1; $display("FAILED: R1 should be 100."); $stop; end

    @(posedge DUT.CPU.PC or negedge DUT.CPU.PC);  

    /* After STR R3, [R1] */
    if (DUT.CPU.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 8."); $stop; end
    if (LEDR[7:0] !== 8'd30) begin err = 1; $display("FAILED: LEDR should display 30., Actual Value %b", LEDR); $stop; end

    #10;  // Wait for clock cycle to finish 

    /* Program Counter should NOT update (HALT) */
    if (DUT.CPU.PC !== 9'h8) begin err = 1; $display("FAILED: PC should be 8. (HALT FAILED)"); $stop; end

    if (~err) $display("PASSED");
    $stop;
    
  end
endmodule