// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

  $fwrite(f,"----------------------------------------------------------------\n");   
  $fwrite(f,"-- PQ-SHAKE-256 \n");
  $fwrite(f,"----------------------------------------------------------------\n");   
     
  // Write IMEM from File
  write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_pq_shake256.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

  $fwrite(f,"-- IMEM\n");
  // Read IMEM  
  for (int i=0 ; i<129 ; i++) begin 
      //read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
  end     

   // Write DMEM from File
  write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_pq_shake256.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

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
  cc_count_shake256 = cc_stop - cc_start;        
       
  // Read DMEM  
  for (int i=0 ; i<52 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+544), .tl_o(tl_o), .tl_i(tl_i_d) );
    case(i)
	0   :   assert (rdbk == 32'he53f3fd8) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'h5f89d9bf) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'hb5dca3f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'h6199c96a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'h7217318c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'h13dda9d3) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'headcf1d5) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'hc7dff8e0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'hcda21c1b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'ha247f277) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'h17519af8) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'hb902c417) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'hb18ac713) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'h7062b631) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'h3be04b1b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'h70a88210) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'hcf51cb7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'h57549cc7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'h1e183186) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'h98311536) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'h8fb45b7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	33   :   assert (rdbk == 32'h47be662b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'hecf9eab4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'h56024506) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'hca636cd8) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'h484cf58c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'h3715dd0e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'h582248e2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'h73b2acfd) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'hd28bf528) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'hea5580cd) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'had3bbe13) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'h5e53d169) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'heae0f3f9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      endcase
    end
  for (int i=0 ; i<52 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+544+4*74+4*6), .tl_o(tl_o), .tl_i(tl_i_d) );
    case(i)
	0   :   assert (rdbk == 32'h12c24afc) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'h295a9c10) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'h5c8d6425) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'h2f05dae) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'h4d860300) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'h16c05758) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'h7d2bf5c3) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'h372f8ef6) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'h28005c8e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'hd5e70b3a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'h799c9d2c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'h3089a8ab) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'h19f0d777) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'ha386dd80) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'h9fe77835) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'h76aef626) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'ha1bc67fd) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'h21085cd5) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'h209ffc0a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'ha5fd96d9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'h55a80c4f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end               
	33   :   assert (rdbk == 32'h55b2d7ba) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'hf8064391) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'h51874d6f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'hca873192) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'h6eee8232) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'hc20320d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'h3cbc156b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'h3962dda) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'h370e835) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'h55278307) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'h8afe9852) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'h3e0642de) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'hc4f9b749) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
       endcase
    end
  for (int i=0 ; i<52 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+544+2*(4*74+4*6)), .tl_o(tl_o), .tl_i(tl_i_d) );
    case(i)
	0   :   assert (rdbk == 32'hcd6e47f9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'h85c04ea2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'h2fcaf7e0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'hf553f83e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'hef203c99) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'h9fc43cb0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'h5c0b9b78) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'h3868ad83) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'h69709b98) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'hf7882b74) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'hd61cadab) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'h80c712e9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'hc9e58929) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'hf5bebb14) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'h944162b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'h69dd9e48) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'h42a0de6b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'h72c24bb1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'h71d66e83) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'hb892fb25) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'h23df79e3) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	33   :   assert (rdbk == 32'he0b8524b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'he1287070) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'hacb9e91c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'hff687664) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'h13616346) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'hd60811f9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'h1369c45) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'h34a2c459) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'hc855c272) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'h1d1df251) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'h645826d3) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'h165b9355) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'he4ebe985) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      endcase
    end

