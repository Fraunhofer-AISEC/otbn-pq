// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


$fwrite(f,"----------------------------------------------------------------\n");   
$fwrite(f,"-- PQ-Keccak \n");
$fwrite(f,"----------------------------------------------------------------\n");   
     
// Write IMEM from File
write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_pq_keccak.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- IMEM\n");
// Read IMEM  
for (int i=0 ; i<129 ; i++) begin 
    //read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end     

 // Write DMEM from File
write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_pq_keccak.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- DMEM\n");
// Read DMEM  
for (int i=0 ; i<16 ; i++) begin 
    //read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end   
	   
$fwrite(f,"----------------------------------------------------------------\n");   

// Set Instruction Counter to zero (optional)
write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(32'h0), .address(OTBN_INSN_CNT_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );

// Start Programm in IMEM
write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(CmdExecute), .address(OTBN_CMD_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
cc_start = cc;
// Poll on Status Register until Programm is finished
rdbk = '1;
while (rdbk != '0) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_STATUS_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
end 

// Measure CC
cc_stop = cc; 
cc_count_keccak = cc_stop - cc_start;        
       
// Read DMEM  
for (int i=0 ; i<50 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+544), .tl_o(tl_o), .tl_i(tl_i_d) );
    case(i)
	0   :   assert (rdbk == 32'h40e1dde7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'hf1258f79) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'h33c0478a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'h84d5ccf9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'ha65aa9ee) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'hd598261e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'h6f80494d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'hbd154730) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'h6253d057) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'h8b284e05) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'h7f8e6fd4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'hff97a42d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'ha44647c4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'h90fee5a0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'hd6192e76) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'h8c5bda0c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'h1b19059c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'had30a6f7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'hd08ffc64) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'h30935ab7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'h2317d635) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	33   :   assert (rdbk == 32'heb5aa93f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'hd712103) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'ha9a6e626) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'hdbcf555f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'h81a57c16) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'h347c826) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'h43b831cd) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'h11a5569f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'h1f22f1a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'h21d9ae61) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'h5e5635a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'h8cc970f2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'h64befef2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	52   :   assert (rdbk == 32'h7bc46611) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	53   :   assert (rdbk == 32'h61367095) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	54   :   assert (rdbk == 32'h4fd00ecb) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	55   :   assert (rdbk == 32'hb87c5a55) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	56   :   assert (rdbk == 32'h1ccf32c8) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	57   :   assert (rdbk == 32'h8c3ee88a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	64   :   assert (rdbk == 32'hae3a2614) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	65   :   assert (rdbk == 32'h940c7922) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	66   :   assert (rdbk == 32'ha2c509e4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	67   :   assert (rdbk == 32'h1841f924) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	68   :   assert (rdbk == 32'he70465c2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	69   :   assert (rdbk == 32'h16f53526) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	70   :   assert (rdbk == 32'h7f30a13b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	71   :   assert (rdbk == 32'h75f644e9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	72   :   assert (rdbk == 32'h5ceca249) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	73   :   assert (rdbk == 32'heaf1ff7b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
    endcase
end


