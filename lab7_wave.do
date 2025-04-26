onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Top Level}
add wave -noupdate {/lab7_stage3_tb/KEY[1]}
add wave -noupdate {/lab7_stage3_tb/KEY[0]}
add wave -noupdate -radix decimal /lab7_stage3_tb/SW
add wave -noupdate -radix decimal /lab7_stage3_tb/LEDR
add wave -noupdate /lab7_stage3_tb/err
add wave -noupdate -divider Instruction
add wave -noupdate /lab7_stage3_tb/DUT/CPU/instruction
add wave -noupdate -divider Registers
add wave -noupdate -radix decimal /lab7_stage3_tb/DUT/CPU/PC
add wave -noupdate -radix hexadecimal /lab7_stage3_tb/DUT/CPU/DP/REGFILE/R0
add wave -noupdate -radix hexadecimal /lab7_stage3_tb/DUT/CPU/DP/REGFILE/R1
add wave -noupdate -radix decimal /lab7_stage3_tb/DUT/CPU/DP/REGFILE/R2
add wave -noupdate -radix decimal /lab7_stage3_tb/DUT/CPU/DP/REGFILE/R3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {107 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
