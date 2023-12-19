// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module keccak_plane_unit
  import otbn_pq_pkg::*;
  (
    input  keccak_plane_operation_t operation_i,
    output logic   [PQLEN*8-1:0]    rs0_o,
    output logic   [PQLEN*8-1:0]    rs1_o
  );
  
  logic [4:0][63:0] operand;
  
  assign operand[0]   = operation_i.operand_a[0+:64];
  assign operand[1]   = operation_i.operand_a[64+:64];
  assign operand[2]   = operation_i.operand_a[128+:64];
  assign operand[3]   = operation_i.operand_a[192+:64];
  assign operand[4]   = operation_i.operand_b[0+:64];
  
  
  
  logic [4:0][63:0] result;
    
  logic [4:0][63:0] rotated_plane;
  logic [4:0][63:0] theta_parity_plane;
  logic [4:0][63:0] chi_plane;
  
  assign rotated_plane[0] = {operand[0][62:0], operand[0][63]};
  assign rotated_plane[1] = {operand[1][62:0], operand[1][63]};
  assign rotated_plane[2] = {operand[2][62:0], operand[2][63]};
  assign rotated_plane[3] = {operand[3][62:0], operand[3][63]};
  assign rotated_plane[4] = {operand[4][62:0], operand[4][63]};
  
  assign theta_parity_plane[0] = operand[4] ^ rotated_plane[1];
  assign theta_parity_plane[1] = operand[0] ^ rotated_plane[2];
  assign theta_parity_plane[2] = operand[1] ^ rotated_plane[3];
  assign theta_parity_plane[3] = operand[2] ^ rotated_plane[4];
  assign theta_parity_plane[4] = operand[3] ^ rotated_plane[0];
  
  assign chi_plane[0] = operand[0] ^(~operand[1] & operand[2]);
  assign chi_plane[1] = operand[1] ^(~operand[2] & operand[3]);
  assign chi_plane[2] = operand[2] ^(~operand[3] & operand[4]);
  assign chi_plane[3] = operand[3] ^(~operand[4] & operand[0]);
  assign chi_plane[4] = operand[4] ^(~operand[0] & operand[1]);
  
  assign result = (operation_i.op) ? chi_plane : theta_parity_plane;
  
  assign rs0_o[63:0]    = result[0];
  assign rs0_o[127:64]  = result[1];
  assign rs0_o[191:128] = result[2];
  assign rs0_o[255:192] = result[3];
  assign rs1_o[63:0]    = result[4];
  
  // unused
  assign rs1_o[127:64]  = operation_i.operand_b[127:64];
  assign rs1_o[191:128] = operation_i.operand_b[191:128];
  assign rs1_o[255:192] =  operation_i.operand_b[255:192];
  
endmodule
