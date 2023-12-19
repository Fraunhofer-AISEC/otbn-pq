// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

  $fwrite(f,"----------------------------------------------------------------\n");   
  $fwrite(f,"-- PQ-POLY_PACKW1-II \n");
  $fwrite(f,"----------------------------------------------------------------\n");   
     
  // Write IMEM from File
  write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_pq_packw1-2.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

  $fwrite(f,"-- IMEM\n");
  // Read IMEM  
  for (int i=0 ; i<129 ; i++) begin 
      //read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
  end     

   // Write DMEM from File
  write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_pq_packw1-2.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

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
  cc_count_packw12 = cc_stop - cc_start;        
       
  // Read DMEM with Deompose Results
  for (int i=0 ; i<192 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+16384), .tl_o(tl_o), .tl_i(tl_i_d) );
    case(i)
	0   :   assert (rdbk == 32'ha214529a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'h70c1aab9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'h76828b7c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'hc00b9e6) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'ha5a57a35) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'h84836112) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'h689172d1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'h28476087) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'h48731488) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'h9d818841) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	10   :   assert (rdbk == 32'h10629a10) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	11   :   assert (rdbk == 32'h19714242) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	12   :   assert (rdbk == 32'h1d3eb10d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	13   :   assert (rdbk == 32'he7e91df0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	14   :   assert (rdbk == 32'h3210ce9c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	15   :   assert (rdbk == 32'hd7a04305) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'hf4c86559) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'h7428ca90) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'he6103898) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'h171e3151) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'h265a840d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'h662d7a91) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'h31c94887) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'h36a5d00d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'h5a88c8dc) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'h1486a843) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	26   :   assert (rdbk == 32'h15d94826) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	27   :   assert (rdbk == 32'he4aa0212) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	28   :   assert (rdbk == 32'he71f7c30) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	29   :   assert (rdbk == 32'hd44a145) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	30   :   assert (rdbk == 32'h17794a12) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	31   :   assert (rdbk == 32'h51203a72) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'h149d6d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	33   :   assert (rdbk == 32'h21dea92) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'hea497068) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'h1971d638) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'h8f0643e6) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'h6a29295a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'h56806a0c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'h894c46d1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'h96e00ca5) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'h5171677c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	42   :   assert (rdbk == 32'h1e2de8a8) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	43   :   assert (rdbk == 32'h422b10e6) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	44   :   assert (rdbk == 32'h2a3ac636) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	45   :   assert (rdbk == 32'h19645793) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	46   :   assert (rdbk == 32'ha2a16002) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	47   :   assert (rdbk == 32'h2ca61d45) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'h4d58a009) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'h6167683) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'h80109c51) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'hd044c488) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	52   :   assert (rdbk == 32'h234a6824) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	53   :   assert (rdbk == 32'ha09572e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	54   :   assert (rdbk == 32'h3259112) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	55   :   assert (rdbk == 32'h81c72006) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	56   :   assert (rdbk == 32'h84325a86) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	57   :   assert (rdbk == 32'hd871159c) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	58   :   assert (rdbk == 32'h3667ac53) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	59   :   assert (rdbk == 32'h7141283d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	60   :   assert (rdbk == 32'h8f50ba13) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	61   :   assert (rdbk == 32'h54261136) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	62   :   assert (rdbk == 32'h65342745) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	63   :   assert (rdbk == 32'h1354e422) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	64   :   assert (rdbk == 32'hb9480d35) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	65   :   assert (rdbk == 32'h18b3d278) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	66   :   assert (rdbk == 32'h259d781f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	67   :   assert (rdbk == 32'h8e480a9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	68   :   assert (rdbk == 32'h99115925) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	69   :   assert (rdbk == 32'h9f160286) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	70   :   assert (rdbk == 32'hc1e05ce9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	71   :   assert (rdbk == 32'h20e14f08) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	72   :   assert (rdbk == 32'h1f25964f) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	73   :   assert (rdbk == 32'h28023838) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	74   :   assert (rdbk == 32'h7695529a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	75   :   assert (rdbk == 32'h4018e94d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	76   :   assert (rdbk == 32'hb68488b6) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	77   :   assert (rdbk == 32'h5468e965) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	78   :   assert (rdbk == 32'h9e8ab893) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	79   :   assert (rdbk == 32'h119ba4b2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	80   :   assert (rdbk == 32'h84945331) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	81   :   assert (rdbk == 32'h18a0f954) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	82   :   assert (rdbk == 32'h23d4911a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	83   :   assert (rdbk == 32'ha967e852) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	84   :   assert (rdbk == 32'h8931d30e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	85   :   assert (rdbk == 32'hd80e9243) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	86   :   assert (rdbk == 32'h840324ac) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	87   :   assert (rdbk == 32'h1ea1b397) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	88   :   assert (rdbk == 32'hf9207e29) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	89   :   assert (rdbk == 32'h953aab58) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	90   :   assert (rdbk == 32'ha07028e7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	91   :   assert (rdbk == 32'h27cd2904) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	92   :   assert (rdbk == 32'ha2b2d616) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	93   :   assert (rdbk == 32'h18a52306) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	94   :   assert (rdbk == 32'ha30f7d18) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	95   :   assert (rdbk == 32'h7e515fae) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	96   :   assert (rdbk == 32'h91c4000) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	97   :   assert (rdbk == 32'h16cc5d88) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	98   :   assert (rdbk == 32'h102a1ead) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	99   :   assert (rdbk == 32'he08ca206) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	100   :   assert (rdbk == 32'h2a8f7cf3) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	101   :   assert (rdbk == 32'h52861c79) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	102   :   assert (rdbk == 32'h1f30a8a1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	103   :   assert (rdbk == 32'h9a880853) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	104   :   assert (rdbk == 32'h8c65b26) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	105   :   assert (rdbk == 32'h435c26c3) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	106   :   assert (rdbk == 32'hb7606a50) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	107   :   assert (rdbk == 32'ha9f311a2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	108   :   assert (rdbk == 32'h828116eb) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	109   :   assert (rdbk == 32'ha081982) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	110   :   assert (rdbk == 32'h62b926ad) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	111   :   assert (rdbk == 32'h58019748) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	112   :   assert (rdbk == 32'h44034805) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	113   :   assert (rdbk == 32'h9c762836) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	114   :   assert (rdbk == 32'h93195a4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	115   :   assert (rdbk == 32'h164911c2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	116   :   assert (rdbk == 32'h7512278e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	117   :   assert (rdbk == 32'h1452a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	118   :   assert (rdbk == 32'hb38d9e14) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	119   :   assert (rdbk == 32'h64014185) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	120   :   assert (rdbk == 32'ha92ab5d7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	121   :   assert (rdbk == 32'h970e0572) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	122   :   assert (rdbk == 32'h1872583a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	123   :   assert (rdbk == 32'h618de595) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	124   :   assert (rdbk == 32'h21ca2a53) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	125   :   assert (rdbk == 32'h85a31856) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	126   :   assert (rdbk == 32'h1b18110e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	127   :   assert (rdbk == 32'ha2806c63) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	128   :   assert (rdbk == 32'h98e0111e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	129   :   assert (rdbk == 32'h825eb217) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	130   :   assert (rdbk == 32'hc46b8511) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	131   :   assert (rdbk == 32'h15736049) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	132   :   assert (rdbk == 32'h1e01d8e1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	133   :   assert (rdbk == 32'hf7e26a02) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	134   :   assert (rdbk == 32'h3c71dea9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	135   :   assert (rdbk == 32'h93880206) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	136   :   assert (rdbk == 32'h87c60105) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	137   :   assert (rdbk == 32'h42940702) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	138   :   assert (rdbk == 32'hc2201116) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	139   :   assert (rdbk == 32'h87e4acd6) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	140   :   assert (rdbk == 32'h9cb7c335) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	141   :   assert (rdbk == 32'h2a195910) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	142   :   assert (rdbk == 32'h4a295593) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	143   :   assert (rdbk == 32'h29964a9d) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	144   :   assert (rdbk == 32'hc9cc40b) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	145   :   assert (rdbk == 32'h5411ac4a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	146   :   assert (rdbk == 32'h14364442) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	147   :   assert (rdbk == 32'haa9013d0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	148   :   assert (rdbk == 32'h38545499) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	149   :   assert (rdbk == 32'h81680b0e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	150   :   assert (rdbk == 32'h5d2dd0d4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	151   :   assert (rdbk == 32'h60a56d64) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	152   :   assert (rdbk == 32'h5c7a2218) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	153   :   assert (rdbk == 32'h8ea50827) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	154   :   assert (rdbk == 32'hb7891659) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	155   :   assert (rdbk == 32'h58d8ce7e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	156   :   assert (rdbk == 32'h624499cd) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	157   :   assert (rdbk == 32'ha8c36cc3) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	158   :   assert (rdbk == 32'h31c80b86) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	159   :   assert (rdbk == 32'h1b6cf2c9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	160   :   assert (rdbk == 32'h589f2e00) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	161   :   assert (rdbk == 32'h6c3a6504) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	162   :   assert (rdbk == 32'h456880e4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	163   :   assert (rdbk == 32'h666339f0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	164   :   assert (rdbk == 32'h21e0a711) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	165   :   assert (rdbk == 32'hd22aa5a4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	166   :   assert (rdbk == 32'h320080f5) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	167   :   assert (rdbk == 32'h4e25711) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	168   :   assert (rdbk == 32'heb68c7cf) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	169   :   assert (rdbk == 32'hb28b7238) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	170   :   assert (rdbk == 32'h9d831a39) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	171   :   assert (rdbk == 32'h64024999) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	172   :   assert (rdbk == 32'h75de1178) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	173   :   assert (rdbk == 32'h39686051) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	174   :   assert (rdbk == 32'hd8030c9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	175   :   assert (rdbk == 32'h30eb71a8) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	176   :   assert (rdbk == 32'h6467d095) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	177   :   assert (rdbk == 32'h9569788) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	178   :   assert (rdbk == 32'hcf1e25) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	179   :   assert (rdbk == 32'ha4f98a30) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	180   :   assert (rdbk == 32'h1214d74e) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	181   :   assert (rdbk == 32'hb4653216) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	182   :   assert (rdbk == 32'h869ac248) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	183   :   assert (rdbk == 32'h9e8697d5) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	184   :   assert (rdbk == 32'h73eba626) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	185   :   assert (rdbk == 32'h1c318730) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	186   :   assert (rdbk == 32'hd5243953) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	187   :   assert (rdbk == 32'hb3e2517a) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	188   :   assert (rdbk == 32'h38831e34) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	189   :   assert (rdbk == 32'h65d0501) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	190   :   assert (rdbk == 32'h781a129) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	191   :   assert (rdbk == 32'h4107e068) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
		    
    endcase
  end   
