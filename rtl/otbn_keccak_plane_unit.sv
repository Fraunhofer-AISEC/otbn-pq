// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module otbn_keccak_plane_unit
  import otbn_pq_pkg::*;
  (
    input  keccak_plane_operation_t operation_i,
    input  keccak_lane_predec_pq_t  keccak_plane_predec_pq_i,
    output logic   [PQLEN*8-1:0]    rs0_o,
    output logic   [PQLEN*8-1:0]    rs1_o,
    output logic                    keccak_plane_predec_error_o
  );
  
  logic [63:0] operand [7:0];

  assign operand[0]   = operation_i.operand_a[0+:64];
  assign operand[1]   = operation_i.operand_a[64+:64];
  assign operand[2]   = operation_i.operand_a[128+:64];
  assign operand[3]   = operation_i.operand_a[192+:64];
  assign operand[4]   = operation_i.operand_b[0+:64];
  assign operand[5]   = operation_i.operand_b[127:64];
  assign operand[6]   = operation_i.operand_b[191:128];
  assign operand[7]   = operation_i.operand_b[255:192];

  // Blanking for Plane
  logic [63:0] operand_blanked [7:0];
  
  for (genvar i=0; i<8; ++i) begin
    // SEC_CM: DATA_REG_SW.SCA
    prim_blanker #(.Width(64)) u_operand_blanker (
      .in_i (operand[i]),
      .en_i (keccak_plane_predec_pq_i.op_en),
      .out_o(operand_blanked[i])
    );    
  end

  logic [63:0] result [4:0];
    
  logic [63:0] rotated_plane [4:0];
  logic [63:0] theta_parity_plane [4:0];
  logic [63:0] chi_plane [4:0];
  
  assign rotated_plane[0] = {operand_blanked[0][62:0], operand_blanked[0][63]};
  assign rotated_plane[1] = {operand_blanked[1][62:0], operand_blanked[1][63]};
  assign rotated_plane[2] = {operand_blanked[2][62:0], operand_blanked[2][63]};
  assign rotated_plane[3] = {operand_blanked[3][62:0], operand_blanked[3][63]};
  assign rotated_plane[4] = {operand_blanked[4][62:0], operand_blanked[4][63]};
  
  assign theta_parity_plane[0] = operand_blanked[4] ^ rotated_plane[1];
  assign theta_parity_plane[1] = operand_blanked[0] ^ rotated_plane[2];
  assign theta_parity_plane[2] = operand_blanked[1] ^ rotated_plane[3];
  assign theta_parity_plane[3] = operand_blanked[2] ^ rotated_plane[4];
  assign theta_parity_plane[4] = operand_blanked[3] ^ rotated_plane[0];
  
  assign chi_plane[0] = operand_blanked[0] ^(~operand_blanked[1] & operand_blanked[2]);
  assign chi_plane[1] = operand_blanked[1] ^(~operand_blanked[2] & operand_blanked[3]);
  assign chi_plane[2] = operand_blanked[2] ^(~operand_blanked[3] & operand_blanked[4]);
  assign chi_plane[3] = operand_blanked[3] ^(~operand_blanked[4] & operand_blanked[0]);
  assign chi_plane[4] = operand_blanked[4] ^(~operand_blanked[0] & operand_blanked[1]);
  
  assign result = (operation_i.op[0]) ? chi_plane : theta_parity_plane;
  
  assign rs0_o[63:0]    = result[0];
  assign rs0_o[127:64]  = result[1];
  assign rs0_o[191:128] = result[2];
  assign rs0_o[255:192] = result[3];
  assign rs1_o[63:0]    = result[4];
  
  // unused
  assign rs1_o[127:64]  = operand_blanked[5];
  assign rs1_o[191:128] = operand_blanked[6];
  assign rs1_o[255:192] =  operand_blanked[7];


  logic expected_op_en;
  always_comb begin
    expected_op_en = 1'b0;

    unique case(operation_i.op)  

      KeccakPlaneOpParity: begin
        expected_op_en = 1'b1;
      end

      KeccakPlaneOpChi: begin
        expected_op_en = 1'b1;
      end
      
      KeccakPlaneOpNone: ;
      default: ;
    endcase
  end

assign keccak_plane_predec_error_o = 
|{expected_op_en != keccak_plane_predec_pq_i.op_en};

endmodule
