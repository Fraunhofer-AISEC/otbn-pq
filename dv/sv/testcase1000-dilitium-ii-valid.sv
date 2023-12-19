// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

  $fwrite(f,"----------------------------------------------------------------\n");   
  $fwrite(f,"-- Dilithium-II Verify \n");
  $fwrite(f,"----------------------------------------------------------------\n");   
  cc_start = cc;   
  // Write IMEM from File
  write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_pq_dilithium-2-valid.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

  $fwrite(f,"-- IMEM\n");
  // Read IMEM  
  for (int i=0 ; i<129 ; i++) begin 
      //read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
  end     

   // Write DMEM from File
  write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_pq_dilithium-2-valid.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

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
  
  // Poll on Status Register until Programm is finished
  rdbk = '1;
  while (rdbk != '0) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_STATUS_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
  end 

  // Measure CC
  cc_stop = cc; 
  cc_count_dilithium_2 = cc_stop - cc_start;        

  for (int i=0 ; i<1 ; i++) begin 
      read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+0), .tl_o(tl_o), .tl_i(tl_i_d) );
      case(i)
	    0   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end

      endcase
  end  

       
  for (int i=0 ; i<8 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+21504), .tl_o(tl_o), .tl_i(tl_i_d) );
    case(i)
      0   :   assert (rdbk == 32'hc5eb439f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      1   :   assert (rdbk == 32'h4d8ec3b0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      2   :   assert (rdbk == 32'hf6c6ac1c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      3   :   assert (rdbk == 32'h5607d332) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      4   :   assert (rdbk == 32'h80304dab) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      5   :   assert (rdbk == 32'hda08a239) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      6   :   assert (rdbk == 32'h8ce17103) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
      7   :   assert (rdbk == 32'hf4c2d7b6) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
    endcase
  end  


