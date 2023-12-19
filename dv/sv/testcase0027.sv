// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

$fwrite(f,"----------------------------------------------------------------\n");   
$fwrite(f,"-- PQ-INVNTT Indirect (Kyber)\n");
$fwrite(f,"----------------------------------------------------------------\n");   
     
// Write IMEM from File
write_imem_from_file_tl_ul(.log_filehandle(f), .imem_file_path({mem_path, "imem_pq_ntt_inv_indirect_kyber.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

$fwrite(f,"-- IMEM\n");
// Read IMEM  
for (int i=0 ; i<129 ; i++) begin 
    //read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
end     

 // Write DMEM from File
write_dmem_from_file_tl_ul(.log_filehandle(f), .dmem_file_path({mem_path, "dmem_pq_ntt_inv_indirect_kyber.txt"}), .clk(clk_i), .clk_cycles(cc), .start_address(0), .tl_o(tl_o), .tl_i(tl_i_d) );

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
cc_count_kyber_inv_indirect = cc_stop - cc_start;        
       
// Read DMEM  
for (int i=0 ; i<256 ; i++) begin 
    read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_DMEM_OFFSET+4*i+544), .tl_o(tl_o), .tl_i(tl_i_d) );
    
    case(i)
	0   :   assert (rdbk == 32'd0) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	1   :   assert (rdbk == 32'd1) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	2   :   assert (rdbk == 32'd2) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	3   :   assert (rdbk == 32'd3) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	4   :   assert (rdbk == 32'd4) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	5   :   assert (rdbk == 32'd5) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	6   :   assert (rdbk == 32'd6) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	7   :   assert (rdbk == 32'd7) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	8   :   assert (rdbk == 32'd8) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	9   :   assert (rdbk == 32'd9) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	10   :   assert (rdbk == 32'd10) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	11   :   assert (rdbk == 32'd11) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	12   :   assert (rdbk == 32'd12) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	13   :   assert (rdbk == 32'd13) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	14   :   assert (rdbk == 32'd14) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	15   :   assert (rdbk == 32'd15) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	16   :   assert (rdbk == 32'd16) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	17   :   assert (rdbk == 32'd17) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	18   :   assert (rdbk == 32'd18) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	19   :   assert (rdbk == 32'd19) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	20   :   assert (rdbk == 32'd20) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	21   :   assert (rdbk == 32'd21) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	22   :   assert (rdbk == 32'd22) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	23   :   assert (rdbk == 32'd23) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	24   :   assert (rdbk == 32'd24) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	25   :   assert (rdbk == 32'd25) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	26   :   assert (rdbk == 32'd26) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	27   :   assert (rdbk == 32'd27) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	28   :   assert (rdbk == 32'd28) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	29   :   assert (rdbk == 32'd29) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	30   :   assert (rdbk == 32'd30) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	31   :   assert (rdbk == 32'd31) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	32   :   assert (rdbk == 32'd32) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	33   :   assert (rdbk == 32'd33) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	34   :   assert (rdbk == 32'd34) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	35   :   assert (rdbk == 32'd35) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	36   :   assert (rdbk == 32'd36) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	37   :   assert (rdbk == 32'd37) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	38   :   assert (rdbk == 32'd38) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	39   :   assert (rdbk == 32'd39) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	40   :   assert (rdbk == 32'd40) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	41   :   assert (rdbk == 32'd41) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	42   :   assert (rdbk == 32'd42) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	43   :   assert (rdbk == 32'd43) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	44   :   assert (rdbk == 32'd44) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	45   :   assert (rdbk == 32'd45) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	46   :   assert (rdbk == 32'd46) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	47   :   assert (rdbk == 32'd47) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	48   :   assert (rdbk == 32'd48) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	49   :   assert (rdbk == 32'd49) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	50   :   assert (rdbk == 32'd50) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	51   :   assert (rdbk == 32'd51) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	52   :   assert (rdbk == 32'd52) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	53   :   assert (rdbk == 32'd53) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	54   :   assert (rdbk == 32'd54) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	55   :   assert (rdbk == 32'd55) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	56   :   assert (rdbk == 32'd56) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	57   :   assert (rdbk == 32'd57) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	58   :   assert (rdbk == 32'd58) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	59   :   assert (rdbk == 32'd59) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	60   :   assert (rdbk == 32'd60) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	61   :   assert (rdbk == 32'd61) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	62   :   assert (rdbk == 32'd62) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	63   :   assert (rdbk == 32'd63) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	64   :   assert (rdbk == 32'd64) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	65   :   assert (rdbk == 32'd65) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	66   :   assert (rdbk == 32'd66) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	67   :   assert (rdbk == 32'd67) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	68   :   assert (rdbk == 32'd68) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	69   :   assert (rdbk == 32'd69) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	70   :   assert (rdbk == 32'd70) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	71   :   assert (rdbk == 32'd71) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	72   :   assert (rdbk == 32'd72) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	73   :   assert (rdbk == 32'd73) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	74   :   assert (rdbk == 32'd74) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	75   :   assert (rdbk == 32'd75) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	76   :   assert (rdbk == 32'd76) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	77   :   assert (rdbk == 32'd77) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	78   :   assert (rdbk == 32'd78) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	79   :   assert (rdbk == 32'd79) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	80   :   assert (rdbk == 32'd80) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	81   :   assert (rdbk == 32'd81) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	82   :   assert (rdbk == 32'd82) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	83   :   assert (rdbk == 32'd83) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	84   :   assert (rdbk == 32'd84) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	85   :   assert (rdbk == 32'd85) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	86   :   assert (rdbk == 32'd86) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	87   :   assert (rdbk == 32'd87) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	88   :   assert (rdbk == 32'd88) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	89   :   assert (rdbk == 32'd89) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	90   :   assert (rdbk == 32'd90) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	91   :   assert (rdbk == 32'd91) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	92   :   assert (rdbk == 32'd92) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	93   :   assert (rdbk == 32'd93) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	94   :   assert (rdbk == 32'd94) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	95   :   assert (rdbk == 32'd95) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	96   :   assert (rdbk == 32'd96) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	97   :   assert (rdbk == 32'd97) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	98   :   assert (rdbk == 32'd98) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	99   :   assert (rdbk == 32'd99) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	100   :   assert (rdbk == 32'd100) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	101   :   assert (rdbk == 32'd101) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	102   :   assert (rdbk == 32'd102) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	103   :   assert (rdbk == 32'd103) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	104   :   assert (rdbk == 32'd104) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	105   :   assert (rdbk == 32'd105) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	106   :   assert (rdbk == 32'd106) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	107   :   assert (rdbk == 32'd107) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	108   :   assert (rdbk == 32'd108) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	109   :   assert (rdbk == 32'd109) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	110   :   assert (rdbk == 32'd110) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	111   :   assert (rdbk == 32'd111) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	112   :   assert (rdbk == 32'd112) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	113   :   assert (rdbk == 32'd113) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	114   :   assert (rdbk == 32'd114) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	115   :   assert (rdbk == 32'd115) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	116   :   assert (rdbk == 32'd116) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	117   :   assert (rdbk == 32'd117) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	118   :   assert (rdbk == 32'd118) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	119   :   assert (rdbk == 32'd119) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	120   :   assert (rdbk == 32'd120) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	121   :   assert (rdbk == 32'd121) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	122   :   assert (rdbk == 32'd122) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	123   :   assert (rdbk == 32'd123) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	124   :   assert (rdbk == 32'd124) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	125   :   assert (rdbk == 32'd125) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	126   :   assert (rdbk == 32'd126) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	127   :   assert (rdbk == 32'd127) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	128   :   assert (rdbk == 32'd128) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	129   :   assert (rdbk == 32'd129) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	130   :   assert (rdbk == 32'd130) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	131   :   assert (rdbk == 32'd131) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	132   :   assert (rdbk == 32'd132) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	133   :   assert (rdbk == 32'd133) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	134   :   assert (rdbk == 32'd134) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	135   :   assert (rdbk == 32'd135) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	136   :   assert (rdbk == 32'd136) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	137   :   assert (rdbk == 32'd137) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	138   :   assert (rdbk == 32'd138) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	139   :   assert (rdbk == 32'd139) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	140   :   assert (rdbk == 32'd140) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	141   :   assert (rdbk == 32'd141) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	142   :   assert (rdbk == 32'd142) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	143   :   assert (rdbk == 32'd143) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	144   :   assert (rdbk == 32'd144) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	145   :   assert (rdbk == 32'd145) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	146   :   assert (rdbk == 32'd146) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	147   :   assert (rdbk == 32'd147) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	148   :   assert (rdbk == 32'd148) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	149   :   assert (rdbk == 32'd149) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	150   :   assert (rdbk == 32'd150) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	151   :   assert (rdbk == 32'd151) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	152   :   assert (rdbk == 32'd152) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	153   :   assert (rdbk == 32'd153) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	154   :   assert (rdbk == 32'd154) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	155   :   assert (rdbk == 32'd155) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	156   :   assert (rdbk == 32'd156) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	157   :   assert (rdbk == 32'd157) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	158   :   assert (rdbk == 32'd158) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	159   :   assert (rdbk == 32'd159) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	160   :   assert (rdbk == 32'd160) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	161   :   assert (rdbk == 32'd161) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	162   :   assert (rdbk == 32'd162) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	163   :   assert (rdbk == 32'd163) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	164   :   assert (rdbk == 32'd164) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	165   :   assert (rdbk == 32'd165) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	166   :   assert (rdbk == 32'd166) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	167   :   assert (rdbk == 32'd167) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	168   :   assert (rdbk == 32'd168) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	169   :   assert (rdbk == 32'd169) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	170   :   assert (rdbk == 32'd170) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	171   :   assert (rdbk == 32'd171) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	172   :   assert (rdbk == 32'd172) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	173   :   assert (rdbk == 32'd173) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	174   :   assert (rdbk == 32'd174) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	175   :   assert (rdbk == 32'd175) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	176   :   assert (rdbk == 32'd176) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	177   :   assert (rdbk == 32'd177) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	178   :   assert (rdbk == 32'd178) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	179   :   assert (rdbk == 32'd179) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	180   :   assert (rdbk == 32'd180) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	181   :   assert (rdbk == 32'd181) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	182   :   assert (rdbk == 32'd182) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	183   :   assert (rdbk == 32'd183) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	184   :   assert (rdbk == 32'd184) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	185   :   assert (rdbk == 32'd185) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	186   :   assert (rdbk == 32'd186) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	187   :   assert (rdbk == 32'd187) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	188   :   assert (rdbk == 32'd188) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	189   :   assert (rdbk == 32'd189) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	190   :   assert (rdbk == 32'd190) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	191   :   assert (rdbk == 32'd191) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	192   :   assert (rdbk == 32'd192) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	193   :   assert (rdbk == 32'd193) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	194   :   assert (rdbk == 32'd194) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	195   :   assert (rdbk == 32'd195) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	196   :   assert (rdbk == 32'd196) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	197   :   assert (rdbk == 32'd197) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	198   :   assert (rdbk == 32'd198) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	199   :   assert (rdbk == 32'd199) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	200   :   assert (rdbk == 32'd200) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	201   :   assert (rdbk == 32'd201) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	202   :   assert (rdbk == 32'd202) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	203   :   assert (rdbk == 32'd203) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	204   :   assert (rdbk == 32'd204) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	205   :   assert (rdbk == 32'd205) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	206   :   assert (rdbk == 32'd206) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	207   :   assert (rdbk == 32'd207) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	208   :   assert (rdbk == 32'd208) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	209   :   assert (rdbk == 32'd209) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	210   :   assert (rdbk == 32'd210) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	211   :   assert (rdbk == 32'd211) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	212   :   assert (rdbk == 32'd212) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	213   :   assert (rdbk == 32'd213) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	214   :   assert (rdbk == 32'd214) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	215   :   assert (rdbk == 32'd215) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	216   :   assert (rdbk == 32'd216) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	217   :   assert (rdbk == 32'd217) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	218   :   assert (rdbk == 32'd218) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	219   :   assert (rdbk == 32'd219) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	220   :   assert (rdbk == 32'd220) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	221   :   assert (rdbk == 32'd221) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	222   :   assert (rdbk == 32'd222) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	223   :   assert (rdbk == 32'd223) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	224   :   assert (rdbk == 32'd224) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	225   :   assert (rdbk == 32'd225) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	226   :   assert (rdbk == 32'd226) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	227   :   assert (rdbk == 32'd227) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	228   :   assert (rdbk == 32'd228) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	229   :   assert (rdbk == 32'd229) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	230   :   assert (rdbk == 32'd230) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	231   :   assert (rdbk == 32'd231) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	232   :   assert (rdbk == 32'd232) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	233   :   assert (rdbk == 32'd233) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	234   :   assert (rdbk == 32'd234) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	235   :   assert (rdbk == 32'd235) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	236   :   assert (rdbk == 32'd236) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	237   :   assert (rdbk == 32'd237) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	238   :   assert (rdbk == 32'd238) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	239   :   assert (rdbk == 32'd239) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	240   :   assert (rdbk == 32'd240) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	241   :   assert (rdbk == 32'd241) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	242   :   assert (rdbk == 32'd242) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	243   :   assert (rdbk == 32'd243) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	244   :   assert (rdbk == 32'd244) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	245   :   assert (rdbk == 32'd245) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	246   :   assert (rdbk == 32'd246) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	247   :   assert (rdbk == 32'd247) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	248   :   assert (rdbk == 32'd248) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	249   :   assert (rdbk == 32'd249) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	250   :   assert (rdbk == 32'd250) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	251   :   assert (rdbk == 32'd251) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	252   :   assert (rdbk == 32'd252) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	253   :   assert (rdbk == 32'd253) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	254   :   assert (rdbk == 32'd254) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
	255   :   assert (rdbk == 32'd255) else begin $fwrite(f,"Wrong Result!\n"); error_count ++; end
    endcase
end

