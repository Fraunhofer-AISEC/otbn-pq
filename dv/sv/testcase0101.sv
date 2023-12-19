// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

  $fwrite(f,"----------------------------------------------------------------\n");   
  $fwrite(f,"-- PQ-SampleInBall \n");
  $fwrite(f,"----------------------------------------------------------------\n");   
     
  // Write IMEM from File
  write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_pq_sampleinball.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

  $fwrite(f,"-- IMEM\n");
  // Read IMEM  
  for (int i=0 ; i<129 ; i++) begin 
      //read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
  end     

   // Write DMEM from File
  write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_pq_sampleinball.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

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
  cc_count_sampleinball = cc_stop - cc_start;        
       
  // Read DMEM  
  for (int i=0 ; i<256 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+1024), .tl_o(tl_o), .tl_i(tl_i_d) );
    case(i)
	0   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	10   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	11   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	12   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	13   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	14   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	15   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	26   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	27   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	28   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	29   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	30   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	31   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	33   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	42   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	43   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	44   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	45   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	46   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	47   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	52   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	53   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	54   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	55   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	56   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	57   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	58   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	59   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	60   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	61   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	62   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	63   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	64   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	65   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	66   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	67   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	68   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	69   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	70   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	71   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	72   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	73   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	74   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	75   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	76   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	77   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	78   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	79   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	80   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	81   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	82   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	83   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	84   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	85   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	86   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	87   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	88   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	89   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	90   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	91   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	92   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	93   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	94   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	95   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	96   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	97   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	98   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	99   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	100   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	101   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	102   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	103   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	104   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	105   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	106   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	107   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	108   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	109   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	110   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	111   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	112   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	113   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	114   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	115   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	116   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	117   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	118   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	119   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	120   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	121   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	122   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	123   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	124   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	125   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	126   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	127   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	128   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	129   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	130   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	131   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	132   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	133   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	134   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	135   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	136   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	137   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	138   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	139   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	140   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	141   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	142   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	143   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	144   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	145   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	146   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	147   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	148   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	149   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	150   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	151   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	152   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	153   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	154   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	155   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	156   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	157   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	158   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	159   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	160   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	161   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	162   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	163   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	164   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	165   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	166   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	167   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	168   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	169   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	170   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	171   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	172   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	173   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	174   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	175   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	176   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	177   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	178   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	179   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	180   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	181   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	182   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	183   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	184   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	185   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	186   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	187   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	188   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	189   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	190   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	191   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	192   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	193   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	194   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	195   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	196   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	197   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	198   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	199   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	200   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	201   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	202   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	203   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	204   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	205   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	206   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	207   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	208   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	209   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	210   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	211   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	212   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	213   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	214   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	215   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	216   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	217   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	218   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	219   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	220   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	221   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	222   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	223   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	224   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	225   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	226   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	227   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	228   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	229   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	230   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	231   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	232   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	233   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	234   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	235   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	236   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	237   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	238   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	239   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	240   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	241   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	242   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	243   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	244   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	245   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	246   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	247   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	248   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	249   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	250   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	251   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	252   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	253   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	254   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	255   :   assert (rdbk == 32'hffffffff) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
    endcase
  end
  for (int i=0 ; i<74 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+2048), .tl_o(tl_o), .tl_i(tl_i_d) );
    case(i)
	0   :   assert (rdbk == 32'h1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'h1f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	33   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'h80000000) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	52   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	53   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	54   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	55   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	56   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	57   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	64   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	65   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	66   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	67   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	68   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	69   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	70   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	71   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	72   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	73   :   assert (rdbk == 32'h0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	
      endcase
    end

