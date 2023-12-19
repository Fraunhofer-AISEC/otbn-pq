// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

$fwrite(f,"----------------------------------------------------------------\n");   
$fwrite(f,"-- PQ Basecase-Multiplication (Kyber)\n");
$fwrite(f,"----------------------------------------------------------------\n");   
     
// Write IMEM from File
write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_pq_mul_kyber.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- IMEM\n");
// Read IMEM  
for (int i=0 ; i<129 ; i++) begin 
    //read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end     

 // Write DMEM from File
write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_pq_mul_kyber.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

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
cc_count_kyber_base_mul = cc_stop - cc_start;        
       
// Read DMEM  
for (int i=0 ; i<256 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+256), .tl_o(tl_o), .tl_i(tl_i_d) );
    
    case(i)
	0   :   assert (rdbk == 32'd17) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'd0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'd3180) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'd12) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'd2461) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'd40) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'd1236) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'd84) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'd681) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'd144) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	10   :   assert (rdbk == 32'd2795) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	11   :   assert (rdbk == 32'd220) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	12   :   assert (rdbk == 32'd1739) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	13   :   assert (rdbk == 32'd312) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	14   :   assert (rdbk == 32'd62) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	15   :   assert (rdbk == 32'd420) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'd631) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'd544) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'd1929) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'd684) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'd2988) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'd840) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'd852) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'd1012) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'd2435) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'd1200) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	26   :   assert (rdbk == 32'd553) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	27   :   assert (rdbk == 32'd1404) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	28   :   assert (rdbk == 32'd422) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	29   :   assert (rdbk == 32'd1624) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	30   :   assert (rdbk == 32'd2422) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	31   :   assert (rdbk == 32'd1860) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'd756) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	33   :   assert (rdbk == 32'd2112) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'd2882) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'd2380) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'd319) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'd2664) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'd606) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'd2964) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'd808) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'd3280) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	42   :   assert (rdbk == 32'd633) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	43   :   assert (rdbk == 32'd283) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	44   :   assert (rdbk == 32'd1043) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	45   :   assert (rdbk == 32'd631) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	46   :   assert (rdbk == 32'd85) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	47   :   assert (rdbk == 32'd995) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'd3155) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'd1375) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'd254) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'd1771) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	52   :   assert (rdbk == 32'd128) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	53   :   assert (rdbk == 32'd2183) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	54   :   assert (rdbk == 32'd2527) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	55   :   assert (rdbk == 32'd2611) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	56   :   assert (rdbk == 32'd1624) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	57   :   assert (rdbk == 32'd3055) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	58   :   assert (rdbk == 32'd1157) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	59   :   assert (rdbk == 32'd186) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	60   :   assert (rdbk == 32'd760) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	61   :   assert (rdbk == 32'd662) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	62   :   assert (rdbk == 32'd2638) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	63   :   assert (rdbk == 32'd1154) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	64   :   assert (rdbk == 32'd1973) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	65   :   assert (rdbk == 32'd1662) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	66   :   assert (rdbk == 32'd2973) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	67   :   assert (rdbk == 32'd2186) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	68   :   assert (rdbk == 32'd1937) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	69   :   assert (rdbk == 32'd2726) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	70   :   assert (rdbk == 32'd1380) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	71   :   assert (rdbk == 32'd3282) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	72   :   assert (rdbk == 32'd451) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	73   :   assert (rdbk == 32'd525) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	74   :   assert (rdbk == 32'd270) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	75   :   assert (rdbk == 32'd1113) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	76   :   assert (rdbk == 32'd3234) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	77   :   assert (rdbk == 32'd1717) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	78   :   assert (rdbk == 32'd3072) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	79   :   assert (rdbk == 32'd2337) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	80   :   assert (rdbk == 32'd349) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	81   :   assert (rdbk == 32'd2973) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	82   :   assert (rdbk == 32'd2850) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	83   :   assert (rdbk == 32'd296) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	84   :   assert (rdbk == 32'd884) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	85   :   assert (rdbk == 32'd964) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	86   :   assert (rdbk == 32'd2335) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	87   :   assert (rdbk == 32'd1648) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	88   :   assert (rdbk == 32'd2063) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	89   :   assert (rdbk == 32'd2348) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	90   :   assert (rdbk == 32'd487) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	91   :   assert (rdbk == 32'd3064) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	92   :   assert (rdbk == 32'd1920) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	93   :   assert (rdbk == 32'd467) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	94   :   assert (rdbk == 32'd439) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	95   :   assert (rdbk == 32'd1215) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	96   :   assert (rdbk == 32'd2443) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	97   :   assert (rdbk == 32'd1979) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	98   :   assert (rdbk == 32'd1163) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	99   :   assert (rdbk == 32'd2759) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	100   :   assert (rdbk == 32'd1233) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	101   :   assert (rdbk == 32'd226) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	102   :   assert (rdbk == 32'd2969) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	103   :   assert (rdbk == 32'd1038) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	104   :   assert (rdbk == 32'd395) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	105   :   assert (rdbk == 32'd1866) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	106   :   assert (rdbk == 32'd385) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	107   :   assert (rdbk == 32'd2710) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	108   :   assert (rdbk == 32'd438) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	109   :   assert (rdbk == 32'd241) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	110   :   assert (rdbk == 32'd1267) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	111   :   assert (rdbk == 32'd1117) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	112   :   assert (rdbk == 32'd1086) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	113   :   assert (rdbk == 32'd2009) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	114   :   assert (rdbk == 32'd3132) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	115   :   assert (rdbk == 32'd2917) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	116   :   assert (rdbk == 32'd2972) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	117   :   assert (rdbk == 32'd512) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	118   :   assert (rdbk == 32'd3269) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	119   :   assert (rdbk == 32'd1452) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	120   :   assert (rdbk == 32'd3310) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	121   :   assert (rdbk == 32'd2408) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	122   :   assert (rdbk == 32'd1718) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	123   :   assert (rdbk == 32'd51) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	124   :   assert (rdbk == 32'd724) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	125   :   assert (rdbk == 32'd1039) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	126   :   assert (rdbk == 32'd416) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	127   :   assert (rdbk == 32'd2043) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	128   :   assert (rdbk == 32'd61) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	129   :   assert (rdbk == 32'd3063) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	130   :   assert (rdbk == 32'd1845) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	131   :   assert (rdbk == 32'd770) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	132   :   assert (rdbk == 32'd3011) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	133   :   assert (rdbk == 32'd1822) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	134   :   assert (rdbk == 32'd2410) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	135   :   assert (rdbk == 32'd2890) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	136   :   assert (rdbk == 32'd739) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	137   :   assert (rdbk == 32'd645) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	138   :   assert (rdbk == 32'd960) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	139   :   assert (rdbk == 32'd1745) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	140   :   assert (rdbk == 32'd3105) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	141   :   assert (rdbk == 32'd2861) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	142   :   assert (rdbk == 32'd2030) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	143   :   assert (rdbk == 32'd664) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	144   :   assert (rdbk == 32'd2065) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	145   :   assert (rdbk == 32'd1812) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	146   :   assert (rdbk == 32'd753) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	147   :   assert (rdbk == 32'd2976) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	148   :   assert (rdbk == 32'd2608) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	149   :   assert (rdbk == 32'd827) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	150   :   assert (rdbk == 32'd459) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	151   :   assert (rdbk == 32'd2023) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	152   :   assert (rdbk == 32'd1627) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	153   :   assert (rdbk == 32'd3235) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	154   :   assert (rdbk == 32'd2799) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	155   :   assert (rdbk == 32'd1134) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	156   :   assert (rdbk == 32'd1418) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	157   :   assert (rdbk == 32'd2378) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	158   :   assert (rdbk == 32'd284) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	159   :   assert (rdbk == 32'd309) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	160   :   assert (rdbk == 32'd2187) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	161   :   assert (rdbk == 32'd1585) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	162   :   assert (rdbk == 32'd1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	163   :   assert (rdbk == 32'd2877) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	164   :   assert (rdbk == 32'd3007) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	165   :   assert (rdbk == 32'd856) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	166   :   assert (rdbk == 32'd2750) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	167   :   assert (rdbk == 32'd2180) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	168   :   assert (rdbk == 32'd1006) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	169   :   assert (rdbk == 32'd191) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	170   :   assert (rdbk == 32'd1428) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	171   :   assert (rdbk == 32'd1547) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	172   :   assert (rdbk == 32'd2031) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	173   :   assert (rdbk == 32'd2919) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	174   :   assert (rdbk == 32'd346) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	175   :   assert (rdbk == 32'd978) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	176   :   assert (rdbk == 32'd2849) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	177   :   assert (rdbk == 32'd2382) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	178   :   assert (rdbk == 32'd122) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	179   :   assert (rdbk == 32'd473) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	180   :   assert (rdbk == 32'd1951) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	181   :   assert (rdbk == 32'd1909) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	182   :   assert (rdbk == 32'd1381) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	183   :   assert (rdbk == 32'd32) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	184   :   assert (rdbk == 32'd2608) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	185   :   assert (rdbk == 32'd1500) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	186   :   assert (rdbk == 32'd2168) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	187   :   assert (rdbk == 32'd2984) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	188   :   assert (rdbk == 32'd2942) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	189   :   assert (rdbk == 32'd1155) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	190   :   assert (rdbk == 32'd1250) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	191   :   assert (rdbk == 32'd2671) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	192   :   assert (rdbk == 32'd2395) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	193   :   assert (rdbk == 32'd874) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	194   :   assert (rdbk == 32'd129) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	195   :   assert (rdbk == 32'd2422) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	196   :   assert (rdbk == 32'd3055) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	197   :   assert (rdbk == 32'd657) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	198   :   assert (rdbk == 32'd2003) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	199   :   assert (rdbk == 32'd2237) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	200   :   assert (rdbk == 32'd2845) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	201   :   assert (rdbk == 32'd504) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	202   :   assert (rdbk == 32'd2010) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	203   :   assert (rdbk == 32'd2116) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	204   :   assert (rdbk == 32'd2110) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	205   :   assert (rdbk == 32'd415) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	206   :   assert (rdbk == 32'd2188) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	207   :   assert (rdbk == 32'd2059) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	208   :   assert (rdbk == 32'd2357) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	209   :   assert (rdbk == 32'd390) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	210   :   assert (rdbk == 32'd414) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	211   :   assert (rdbk == 32'd2066) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	212   :   assert (rdbk == 32'd1988) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	213   :   assert (rdbk == 32'd429) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	214   :   assert (rdbk == 32'd2735) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	215   :   assert (rdbk == 32'd2137) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	216   :   assert (rdbk == 32'd2117) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	217   :   assert (rdbk == 32'd532) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	218   :   assert (rdbk == 32'd2563) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	219   :   assert (rdbk == 32'd2272) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	220   :   assert (rdbk == 32'd1249) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	221   :   assert (rdbk == 32'd699) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	222   :   assert (rdbk == 32'd2099) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	223   :   assert (rdbk == 32'd2471) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	224   :   assert (rdbk == 32'd3297) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	225   :   assert (rdbk == 32'd930) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	226   :   assert (rdbk == 32'd2698) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	227   :   assert (rdbk == 32'd2734) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	228   :   assert (rdbk == 32'd3273) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	229   :   assert (rdbk == 32'd1225) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	230   :   assert (rdbk == 32'd1916) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	231   :   assert (rdbk == 32'd3061) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	232   :   assert (rdbk == 32'd577) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	233   :   assert (rdbk == 32'd1584) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	234   :   assert (rdbk == 32'd1794) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	235   :   assert (rdbk == 32'd123) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	236   :   assert (rdbk == 32'd2235) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	237   :   assert (rdbk == 32'd2007) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	238   :   assert (rdbk == 32'd2695) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	239   :   assert (rdbk == 32'd578) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	240   :   assert (rdbk == 32'd1440) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	241   :   assert (rdbk == 32'd2494) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	242   :   assert (rdbk == 32'd3064) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	243   :   assert (rdbk == 32'd1097) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	244   :   assert (rdbk == 32'd2309) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	245   :   assert (rdbk == 32'd3045) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	246   :   assert (rdbk == 32'd2760) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	247   :   assert (rdbk == 32'd1680) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	248   :   assert (rdbk == 32'd560) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	249   :   assert (rdbk == 32'd331) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	250   :   assert (rdbk == 32'd785) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	251   :   assert (rdbk == 32'd2327) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	252   :   assert (rdbk == 32'd1775) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	253   :   assert (rdbk == 32'd1010) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	254   :   assert (rdbk == 32'd1761) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	255   :   assert (rdbk == 32'd3038) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
    endcase
end

