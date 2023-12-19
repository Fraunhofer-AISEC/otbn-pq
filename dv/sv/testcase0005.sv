// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0



$fwrite(f,"----------------------------------------------------------------\n");   
$fwrite(f,"-- PQ-BF\n");
$fwrite(f,"----------------------------------------------------------------\n");   
     
// Write IMEM from File
write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_pq_bf.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- IMEM\n");
// Read IMEM  
for (int i=0 ; i<129 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end     

 // Write DMEM from File
write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_pq_bf.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- DMEM\n");
// Read DMEM  
for (int i=0 ; i<16 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end   
	   
$fwrite(f,"----------------------------------------------------------------\n");   

// Set Instruction Counter to zero (optional)
write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(32'h0), .address(OTBN_INSN_CNT_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );

// Start Programm in IMEM
write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(CmdExecute), .address(OTBN_CMD_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );

// Poll on Status Register until Programm is finished
rdbk = '1;
while (rdbk != '0) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_STATUS_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
end 
	
// Read DMEM  
for (int i=0 ; i<16 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+512), .tl_o(tl_o), .tl_i(tl_i_d) );
    
    case(i)
	0   :   assert (rdbk == 32'd8023823) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'd4949942) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'd5503697) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'd7227518) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'd4077164) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'd903461)  else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'd2287113) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'd3389395) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'd2840445) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'd1776347) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	10  :   assert (rdbk == 32'd712249) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	11  :   assert (rdbk == 32'd8028568) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	12  :   assert (rdbk == 32'd6964470) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	13  :   assert (rdbk == 32'd5900372) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	14  :   assert (rdbk == 32'd4836274) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	15  :   assert (rdbk == 32'd3772176) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
    endcase
end   




