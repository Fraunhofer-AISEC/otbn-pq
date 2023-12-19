/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

package tb_tl_ul_pkg;


  task automatic write_tl_ul(
    input integer log_filehandle, 
    ref logic clk,
    ref integer clk_cycles,
    input logic [31:0] data,
    input logic [31:0] address,
    ref tlul_pkg::tl_d2h_t tl_o,
    ref tlul_pkg::tl_h2d_t tl_i);
    
    
    begin 

      @(negedge clk);
      $fwrite(log_filehandle,"     BUS WRITE\n");
      $fwrite(log_filehandle,"     CC: %d CC\n",clk_cycles);
      tl_i.a_address = address;
      tl_i.a_data = data;
      tl_i.a_mask = 4'hF;
      tl_i.a_opcode = tlul_pkg::PutFullData;
      tl_i.a_size = 2'b10;
      tl_i.a_source = 7'h0;
      tl_i.a_valid = 1'b1;
      tl_i.a_user = tlul_pkg::TL_A_USER_DEFAULT;
      $fwrite(log_filehandle,"     ADDR: 0x%h\n",tl_i.a_address);
      $fwrite(log_filehandle,"     DATA: 0x%h\n\n",tl_i.a_data);
      @(negedge clk);
    
      tl_i.a_address = 32'h0;
      tl_i.a_data = 32'h0;
      tl_i.a_mask = 4'hF;
      tl_i.a_opcode = tlul_pkg::PutFullData;
      tl_i.a_size = 2'b10;
      tl_i.a_source = 7'h0;
      tl_i.a_valid = 1'b0;
      tl_i.a_user = tlul_pkg::TL_A_USER_DEFAULT;

    end
    
    
  endtask : write_tl_ul

  task automatic read_tl_ul(
    input integer log_filehandle,
    output logic [31:0] data, 
    ref logic clk,
    ref integer clk_cycles,
    input logic [31:0] address,
    ref tlul_pkg::tl_d2h_t tl_o,
    ref tlul_pkg::tl_h2d_t tl_i);
    
    
    begin 

      @(negedge clk);
      $fwrite(log_filehandle,"     BUS READ\n");
      $fwrite(log_filehandle,"     CC: %d CC\n",clk_cycles);
      tl_i.a_address = address;
      tl_i.a_data = 32'h0;
      tl_i.a_mask = 4'hF;
      tl_i.a_opcode = tlul_pkg::Get;
      tl_i.a_size = 2'b10;
      tl_i.a_source = 7'h0;
      tl_i.a_valid = 1'b1;
      tl_i.a_user = tlul_pkg::TL_A_USER_DEFAULT;
      $fwrite(log_filehandle,"     ADDR: 0x%h\n",tl_i.a_address);
    
      @(negedge clk);
    
      tl_i.a_address = 32'h0;
      tl_i.a_data = 32'h0;
      tl_i.a_mask = 4'hF;
      tl_i.a_opcode = tlul_pkg::PutFullData;
      tl_i.a_size = 2'b10;
      tl_i.a_source = 7'h0;
      tl_i.a_valid = 1'b0;
      tl_i.a_user = tlul_pkg::TL_A_USER_DEFAULT;
        
      $fwrite(log_filehandle,"     DATA: 0x%h\n\n",tl_o.d_data);
      data = tl_o.d_data;
    end
    
    
  endtask : read_tl_ul



  task automatic write_imem_from_file_tl_ul(
    input integer log_filehandle, 
    ref logic clk,
    ref integer clk_cycles,
    input string imem_file_path, 
    input logic [31:0] start_address,
    ref tlul_pkg::tl_d2h_t tl_o,
    ref tlul_pkg::tl_h2d_t tl_i);

    integer imem_filehandle;
    logic [31:0] instr;
    integer rel_addr;
    
    rel_addr = 0;
    imem_filehandle=$fopen(imem_file_path,"rb"); 
    while (! $feof(imem_filehandle)) begin 
      $fscanf(imem_filehandle,"%b\n",instr); 
      write_tl_ul(.log_filehandle(log_filehandle), .clk(clk), .clk_cycles(clk_cycles), .data(instr), .address(otbn_reg_pkg::OTBN_IMEM_OFFSET+start_address+4*rel_addr), .tl_o(tl_o), .tl_i(tl_i) );
      rel_addr = rel_addr + 1;
    end 

    $fclose(imem_filehandle);

  endtask : write_imem_from_file_tl_ul


  task automatic write_dmem_from_file_tl_ul(
    input integer log_filehandle, 
    ref logic clk,
    ref integer clk_cycles,
    input string dmem_file_path, 
    input logic [31:0] start_address,
    ref tlul_pkg::tl_d2h_t tl_o,
    ref tlul_pkg::tl_h2d_t tl_i);

    integer dmem_filehandle;
    logic [31:0] data;
    integer rel_addr;
    
    rel_addr = 0;
    dmem_filehandle=$fopen(dmem_file_path,"rb"); 
    while (! $feof(dmem_filehandle)) begin 
      $fscanf(dmem_filehandle,"%b\n",data); 
      write_tl_ul(.log_filehandle(log_filehandle), .clk(clk), .clk_cycles(clk_cycles), .data(data), .address(otbn_reg_pkg::OTBN_DMEM_OFFSET+start_address+4*rel_addr), .tl_o(tl_o), .tl_i(tl_i) );
      rel_addr = rel_addr + 1;
    end 

    $fclose(dmem_filehandle);

  endtask : write_dmem_from_file_tl_ul


endpackage
