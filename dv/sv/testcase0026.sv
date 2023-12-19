// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

$fwrite(f,"----------------------------------------------------------------\n");   
$fwrite(f,"-- PQ-NTT-Indirect (Kyber)\n");
$fwrite(f,"----------------------------------------------------------------\n");   
     
// Write IMEM from File
write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_pq_ntt_indirect_kyber.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- IMEM\n");
// Read IMEM  
for (int i=0 ; i<129 ; i++) begin 
    //read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end     

 // Write DMEM from File
write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_pq_ntt_indirect_kyber.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

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
cc_count_kyber_indirect = cc_stop - cc_start;        
       
// Read DMEM  
for (int i=0 ; i<256 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+544), .tl_o(tl_o), .tl_i(tl_i_d) );
    
    case(i)
	0   :   assert (rdbk == 32'd2429) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'd2845) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'd425) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'd795) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'd1865) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'd1356) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'd624) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'd31) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'd2483) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'd2197) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	10   :   assert (rdbk == 32'd2725) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	11   :   assert (rdbk == 32'd2668) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	12   :   assert (rdbk == 32'd2707) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	13   :   assert (rdbk == 32'd517) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	14   :   assert (rdbk == 32'd1488) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	15   :   assert (rdbk == 32'd2194) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'd1971) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'd803) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'd922) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'd231) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'd2319) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'd613) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'd1075) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'd606) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'd306) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'd3143) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	26   :   assert (rdbk == 32'd1380) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	27   :   assert (rdbk == 32'd2718) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	28   :   assert (rdbk == 32'd1155) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	29   :   assert (rdbk == 32'd531) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	30   :   assert (rdbk == 32'd818) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	31   :   assert (rdbk == 32'd1586) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'd2874) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	33   :   assert (rdbk == 32'd155) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'd304) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'd1442) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'd2619) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'd1712) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'd2169) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'd2159) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'd1479) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'd2634) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	42   :   assert (rdbk == 32'd2864) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	43   :   assert (rdbk == 32'd2014) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	44   :   assert (rdbk == 32'd1679) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	45   :   assert (rdbk == 32'd3200) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	46   :   assert (rdbk == 32'd102) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	47   :   assert (rdbk == 32'd1923) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'd1603) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'd558) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'd681) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'd316) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	52   :   assert (rdbk == 32'd517) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	53   :   assert (rdbk == 32'd931) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	54   :   assert (rdbk == 32'd1732) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	55   :   assert (rdbk == 32'd1999) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	56   :   assert (rdbk == 32'd2024) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	57   :   assert (rdbk == 32'd1094) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	58   :   assert (rdbk == 32'd2276) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	59   :   assert (rdbk == 32'd2159) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	60   :   assert (rdbk == 32'd2187) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	61   :   assert (rdbk == 32'd1973) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	62   :   assert (rdbk == 32'd2637) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	63   :   assert (rdbk == 32'd2158) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	64   :   assert (rdbk == 32'd2373) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	65   :   assert (rdbk == 32'd198) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	66   :   assert (rdbk == 32'd2986) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	67   :   assert (rdbk == 32'd247) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	68   :   assert (rdbk == 32'd1482) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	69   :   assert (rdbk == 32'd449) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	70   :   assert (rdbk == 32'd1157) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	71   :   assert (rdbk == 32'd1290) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	72   :   assert (rdbk == 32'd1057) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	73   :   assert (rdbk == 32'd2220) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	74   :   assert (rdbk == 32'd1124) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	75   :   assert (rdbk == 32'd1019) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	76   :   assert (rdbk == 32'd400) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	77   :   assert (rdbk == 32'd2206) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	78   :   assert (rdbk == 32'd1225) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	79   :   assert (rdbk == 32'd2233) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	80   :   assert (rdbk == 32'd1376) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	81   :   assert (rdbk == 32'd2880) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	82   :   assert (rdbk == 32'd2664) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	83   :   assert (rdbk == 32'd614) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	84   :   assert (rdbk == 32'd1960) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	85   :   assert (rdbk == 32'd1974) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	86   :   assert (rdbk == 32'd2934) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	87   :   assert (rdbk == 32'd2679) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	88   :   assert (rdbk == 32'd2860) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	89   :   assert (rdbk == 32'd2217) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	90   :   assert (rdbk == 32'd2897) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	91   :   assert (rdbk == 32'd3234) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	92   :   assert (rdbk == 32'd1905) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	93   :   assert (rdbk == 32'd36) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	94   :   assert (rdbk == 32'd2306) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	95   :   assert (rdbk == 32'd2145) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	96   :   assert (rdbk == 32'd219) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	97   :   assert (rdbk == 32'd581) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	98   :   assert (rdbk == 32'd3000) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	99   :   assert (rdbk == 32'd1378) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	100   :   assert (rdbk == 32'd2392) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	101   :   assert (rdbk == 32'd2835) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	102   :   assert (rdbk == 32'd1685) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	103   :   assert (rdbk == 32'd1091) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	104   :   assert (rdbk == 32'd1054) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	105   :   assert (rdbk == 32'd2150) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	106   :   assert (rdbk == 32'd543) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	107   :   assert (rdbk == 32'd3192) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	108   :   assert (rdbk == 32'd2518) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	109   :   assert (rdbk == 32'd3246) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	110   :   assert (rdbk == 32'd2277) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	111   :   assert (rdbk == 32'd570) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	112   :   assert (rdbk == 32'd239) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	113   :   assert (rdbk == 32'd2522) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	114   :   assert (rdbk == 32'd838) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	115   :   assert (rdbk == 32'd1990) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	116   :   assert (rdbk == 32'd126) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	117   :   assert (rdbk == 32'd2637) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	118   :   assert (rdbk == 32'd126) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	119   :   assert (rdbk == 32'd818) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	120   :   assert (rdbk == 32'd3232) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	121   :   assert (rdbk == 32'd1075) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	122   :   assert (rdbk == 32'd940) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	123   :   assert (rdbk == 32'd742) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	124   :   assert (rdbk == 32'd2617) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	125   :   assert (rdbk == 32'd630) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	126   :   assert (rdbk == 32'd650) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	127   :   assert (rdbk == 32'd2776) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	128   :   assert (rdbk == 32'd2606) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	129   :   assert (rdbk == 32'd482) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	130   :   assert (rdbk == 32'd2208) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	131   :   assert (rdbk == 32'd868) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	132   :   assert (rdbk == 32'd1949) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	133   :   assert (rdbk == 32'd2149) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	134   :   assert (rdbk == 32'd3066) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	135   :   assert (rdbk == 32'd1896) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	136   :   assert (rdbk == 32'd2996) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	137   :   assert (rdbk == 32'd2306) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	138   :   assert (rdbk == 32'd63) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	139   :   assert (rdbk == 32'd883) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	140   :   assert (rdbk == 32'd2463) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	141   :   assert (rdbk == 32'd1313) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	142   :   assert (rdbk == 32'd1951) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	143   :   assert (rdbk == 32'd2999) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	144   :   assert (rdbk == 32'd97) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	145   :   assert (rdbk == 32'd1806) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	146   :   assert (rdbk == 32'd2830) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	147   :   assert (rdbk == 32'd2104) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	148   :   assert (rdbk == 32'd1771) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	149   :   assert (rdbk == 32'd2453) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	150   :   assert (rdbk == 32'd370) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	151   :   assert (rdbk == 32'd2605) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	152   :   assert (rdbk == 32'd871) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	153   :   assert (rdbk == 32'd1467) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	154   :   assert (rdbk == 32'd2426) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	155   :   assert (rdbk == 32'd1985) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	156   :   assert (rdbk == 32'd2363) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	157   :   assert (rdbk == 32'd658) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	158   :   assert (rdbk == 32'd1015) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	159   :   assert (rdbk == 32'd655) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	160   :   assert (rdbk == 32'd501) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	161   :   assert (rdbk == 32'd664) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	162   :   assert (rdbk == 32'd1249) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	163   :   assert (rdbk == 32'd3120) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	164   :   assert (rdbk == 32'd106) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	165   :   assert (rdbk == 32'd3100) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	166   :   assert (rdbk == 32'd1274) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	167   :   assert (rdbk == 32'd1919) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	168   :   assert (rdbk == 32'd1890) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	169   :   assert (rdbk == 32'd2147) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	170   :   assert (rdbk == 32'd1961) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	171   :   assert (rdbk == 32'd1949) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	172   :   assert (rdbk == 32'd1738) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	173   :   assert (rdbk == 32'd461) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	174   :   assert (rdbk == 32'd2772) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	175   :   assert (rdbk == 32'd1270) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	176   :   assert (rdbk == 32'd3095) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	177   :   assert (rdbk == 32'd2089) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	178   :   assert (rdbk == 32'd1051) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	179   :   assert (rdbk == 32'd2576) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	180   :   assert (rdbk == 32'd1628) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	181   :   assert (rdbk == 32'd1735) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	182   :   assert (rdbk == 32'd3195) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	183   :   assert (rdbk == 32'd2034) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	184   :   assert (rdbk == 32'd655) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	185   :   assert (rdbk == 32'd524) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	186   :   assert (rdbk == 32'd3195) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	187   :   assert (rdbk == 32'd901) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	188   :   assert (rdbk == 32'd2007) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	189   :   assert (rdbk == 32'd1419) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	190   :   assert (rdbk == 32'd157) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	191   :   assert (rdbk == 32'd2334) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	192   :   assert (rdbk == 32'd2344) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	193   :   assert (rdbk == 32'd2825) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	194   :   assert (rdbk == 32'd634) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	195   :   assert (rdbk == 32'd850) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	196   :   assert (rdbk == 32'd2523) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	197   :   assert (rdbk == 32'd2642) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	198   :   assert (rdbk == 32'd672) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	199   :   assert (rdbk == 32'd1604) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	200   :   assert (rdbk == 32'd216) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	201   :   assert (rdbk == 32'd3280) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	202   :   assert (rdbk == 32'd1317) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	203   :   assert (rdbk == 32'd905) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	204   :   assert (rdbk == 32'd1165) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	205   :   assert (rdbk == 32'd1532) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	206   :   assert (rdbk == 32'd3059) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	207   :   assert (rdbk == 32'd777) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	208   :   assert (rdbk == 32'd242) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	209   :   assert (rdbk == 32'd1752) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	210   :   assert (rdbk == 32'd2052) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	211   :   assert (rdbk == 32'd533) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	212   :   assert (rdbk == 32'd1006) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	213   :   assert (rdbk == 32'd1858) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	214   :   assert (rdbk == 32'd2336) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	215   :   assert (rdbk == 32'd1183) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	216   :   assert (rdbk == 32'd1656) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	217   :   assert (rdbk == 32'd1668) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	218   :   assert (rdbk == 32'd2037) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	219   :   assert (rdbk == 32'd2946) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	220   :   assert (rdbk == 32'd2184) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	221   :   assert (rdbk == 32'd1048) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	222   :   assert (rdbk == 32'd104) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	223   :   assert (rdbk == 32'd2825) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	224   :   assert (rdbk == 32'd877) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	225   :   assert (rdbk == 32'd111) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	226   :   assert (rdbk == 32'd1363) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	227   :   assert (rdbk == 32'd1989) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	228   :   assert (rdbk == 32'd1995) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	229   :   assert (rdbk == 32'd659) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	230   :   assert (rdbk == 32'd12) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	231   :   assert (rdbk == 32'd506) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	232   :   assert (rdbk == 32'd1551) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	233   :   assert (rdbk == 32'd2022) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	234   :   assert (rdbk == 32'd3212) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	235   :   assert (rdbk == 32'd1591) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	236   :   assert (rdbk == 32'd1637) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	237   :   assert (rdbk == 32'd2330) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	238   :   assert (rdbk == 32'd1625) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	239   :   assert (rdbk == 32'd2795) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	240   :   assert (rdbk == 32'd774) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	241   :   assert (rdbk == 32'd70) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	242   :   assert (rdbk == 32'd1002) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	243   :   assert (rdbk == 32'd3194) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	244   :   assert (rdbk == 32'd928) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	245   :   assert (rdbk == 32'd987) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	246   :   assert (rdbk == 32'd2717) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	247   :   assert (rdbk == 32'd3005) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	248   :   assert (rdbk == 32'd2883) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	249   :   assert (rdbk == 32'd149) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	250   :   assert (rdbk == 32'd2594) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	251   :   assert (rdbk == 32'd3105) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	252   :   assert (rdbk == 32'd2502) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	253   :   assert (rdbk == 32'd2134) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	254   :   assert (rdbk == 32'd2717) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	255   :   assert (rdbk == 32'd2303) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
    endcase
end


