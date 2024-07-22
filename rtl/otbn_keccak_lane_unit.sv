// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module otbn_keccak_lane_unit
  import otbn_pq_pkg::*;
  (
    input keccak_lane_operation_t operation_i,
    input keccak_lane_predec_pq_t keccak_lane_predec_pq_i,
    output logic[255:0] rd_o,
    output logic keccak_lane_predec_error_o
  );
  
  logic [63:0] operand_a;
  logic [63:0] operand_b;
  logic [63:0] rd;

  always_comb begin
    operand_a = '0;
    operand_b = '0;

    unique case (operation_i.operand_a_w_sel)
      2'd0: begin
        operand_a = operation_i.operand_a[PQLEN*0+:2*PQLEN];
      end
      2'd1: begin
        operand_a = operation_i.operand_a[PQLEN*2+:2*PQLEN];
      end
      2'd2: begin
        operand_a = operation_i.operand_a[PQLEN*4+:2*PQLEN];
      end
      2'd3: begin
        operand_a = operation_i.operand_a[PQLEN*6+:2*PQLEN];
      end
      default: operand_a = '0;
    endcase

    unique case (operation_i.operand_b_w_sel)
      2'd0: begin
        operand_b = operation_i.operand_b[PQLEN*0+:2*PQLEN];
      end
      2'd1: begin
        operand_b = operation_i.operand_b[PQLEN*2+:2*PQLEN];
      end
      2'd2: begin
        operand_b = operation_i.operand_b[PQLEN*4+:2*PQLEN];
      end
      2'd3: begin
        operand_b = operation_i.operand_b[PQLEN*6+:2*PQLEN];
      end
      default: operand_b = '0;
    endcase

    unique case (operation_i.d_w_sel)
      2'd0: begin
        rd_o = {192'b0, rd};
      end
      2'd1: begin
        rd_o = {128'b0, rd, 64'b0};
      end
      2'd2: begin
        rd_o = {64'b0, rd, 128'b0};
      end
      2'd3: begin
        rd_o = {rd, 192'b0};
      end
    endcase


  end
  
  
  logic [63:0] lane_xor;
  logic [63:0] xor_operand;
  logic [4:0][4:0][63:0] lane_xor_rho;
  logic [4:0][63:0] lane_xor_rho_y;
  logic [63:0] lane_xorr;
  
  // Select operand for XOR operation
  assign xor_operand = (operation_i.op[1]) ? operation_i.rc : operand_b; 


  // Blanking for Subtractor
  logic [63:0] xor_op_a_blanked;
  logic [63:0] xor_op_b_blanked;

  // SEC_CM: DATA_REG_SW.SCA
  prim_blanker #(.Width(64)) u_xor_operand_a_blanker (
    .in_i (operand_a),
    .en_i (keccak_lane_predec_pq_i.op_en),
    .out_o(xor_op_a_blanked)
  );

  // SEC_CM: DATA_REG_SW.SCA
  prim_blanker #(.Width(64)) u_xor_operand_b_blanker (
    .in_i (xor_operand),
    .en_i (keccak_lane_predec_pq_i.op_en),
    .out_o(xor_op_b_blanked)
  );

  // Execution of XOR operation
  assign lane_xor = xor_op_a_blanked ^ xor_op_b_blanked;
  
  
  // RHO offset table for SHA3 
    /////////////////////////////////////////////
    // y\x  3   4   0   1   2
    ////////////////////////////////////////////
    // 2   25  39   3  10  43
    // 1   55  20  36  44   6
    // 0   28  27   0   1  62
    // 4   56  14  18   2  61
    // 3   21   8  41  45  15
    ////////////////////////////////////////////
  
  // Rotation for all possible rho offset values
  assign lane_xor_rho[3][2] = {lane_xor[63-25:0], lane_xor[63:63-25+1]};
  assign lane_xor_rho[4][2] = {lane_xor[63-39:0], lane_xor[63:63-39+1]};
  assign lane_xor_rho[0][2] = {lane_xor[63-3:0],  lane_xor[63:63-3+1]};
  assign lane_xor_rho[1][2] = {lane_xor[63-10:0], lane_xor[63:63-10+1]};
  assign lane_xor_rho[2][2] = {lane_xor[63-43:0], lane_xor[63:63-43+1]};

  assign lane_xor_rho[3][1] = {lane_xor[63-55:0], lane_xor[63:63-55+1]};
  assign lane_xor_rho[4][1] = {lane_xor[63-20:0], lane_xor[63:63-20+1]};
  assign lane_xor_rho[0][1] = {lane_xor[63-36:0], lane_xor[63:63-36+1]};
  assign lane_xor_rho[1][1] = {lane_xor[63-44:0], lane_xor[63:63-44+1]};
  assign lane_xor_rho[2][1] = {lane_xor[63-6:0],  lane_xor[63:63-6+1]};

  assign lane_xor_rho[3][0] = {lane_xor[63-28:0], lane_xor[63:63-28+1]};
  assign lane_xor_rho[4][0] = {lane_xor[63-27:0], lane_xor[63:63-27+1]};
  assign lane_xor_rho[0][0] = lane_xor[63:0];
  assign lane_xor_rho[1][0] = {lane_xor[63-1:0],  lane_xor[63:63-1+1]};
  assign lane_xor_rho[2][0] = {lane_xor[63-62:0], lane_xor[63:63-62+1]};
  
  assign lane_xor_rho[3][4] = {lane_xor[63-56:0], lane_xor[63:63-56+1]};
  assign lane_xor_rho[4][4] = {lane_xor[63-14:0], lane_xor[63:63-14+1]};
  assign lane_xor_rho[0][4] = {lane_xor[63-18:0], lane_xor[63:63-18+1]};
  assign lane_xor_rho[1][4] = {lane_xor[63-2:0],  lane_xor[63:63-2+1]};
  assign lane_xor_rho[2][4] = {lane_xor[63-61:0], lane_xor[63:63-61+1]};
  
  assign lane_xor_rho[3][3] = {lane_xor[63-21:0], lane_xor[63:63-21+1]};
  assign lane_xor_rho[4][3] = {lane_xor[63-8:0],  lane_xor[63:63-8+1]};
  assign lane_xor_rho[0][3] = {lane_xor[63-41:0], lane_xor[63:63-41+1]};
  assign lane_xor_rho[1][3] = {lane_xor[63-45:0], lane_xor[63:63-45+1]};
  assign lane_xor_rho[2][3] = {lane_xor[63-15:0], lane_xor[63:63-15+1]};
  
  // Selection of column (x coordinate)
  always_comb begin
  
    unique case(operation_i.x)
      3'b000: begin
        lane_xor_rho_y[2] = lane_xor_rho[0][2];
        lane_xor_rho_y[1] = lane_xor_rho[0][1];
        lane_xor_rho_y[0] = lane_xor_rho[0][0];
        lane_xor_rho_y[4] = lane_xor_rho[0][4];
        lane_xor_rho_y[3] = lane_xor_rho[0][3];
      end
      3'b001: begin
        lane_xor_rho_y[2] = lane_xor_rho[1][2];
        lane_xor_rho_y[1] = lane_xor_rho[1][1];
        lane_xor_rho_y[0] = lane_xor_rho[1][0];
        lane_xor_rho_y[4] = lane_xor_rho[1][4];
        lane_xor_rho_y[3] = lane_xor_rho[1][3];
      end
      3'b010: begin
        lane_xor_rho_y[2] = lane_xor_rho[2][2];
        lane_xor_rho_y[1] = lane_xor_rho[2][1];
        lane_xor_rho_y[0] = lane_xor_rho[2][0];
        lane_xor_rho_y[4] = lane_xor_rho[2][4];
        lane_xor_rho_y[3] = lane_xor_rho[2][3];
      end
      3'b011: begin
        lane_xor_rho_y[2] = lane_xor_rho[3][2];
        lane_xor_rho_y[1] = lane_xor_rho[3][1];
        lane_xor_rho_y[0] = lane_xor_rho[3][0];
        lane_xor_rho_y[4] = lane_xor_rho[3][4];
        lane_xor_rho_y[3] = lane_xor_rho[3][3];
      end
      3'b100: begin
        lane_xor_rho_y[2] = lane_xor_rho[4][2];
        lane_xor_rho_y[1] = lane_xor_rho[4][1];
        lane_xor_rho_y[0] = lane_xor_rho[4][0];
        lane_xor_rho_y[4] = lane_xor_rho[4][4];
        lane_xor_rho_y[3] = lane_xor_rho[4][3];
      end
      default: begin
        lane_xor_rho_y[2] = lane_xor_rho[4][2];
        lane_xor_rho_y[1] = lane_xor_rho[4][1];
        lane_xor_rho_y[0] = lane_xor_rho[4][0];
        lane_xor_rho_y[4] = lane_xor_rho[4][4];
        lane_xor_rho_y[3] = lane_xor_rho[4][3];   
      end
    endcase
  end
 
  // Selection of row (y coordinate) 
  always_comb begin
  
    unique case(operation_i.y)
      3'b000: begin
        lane_xorr = lane_xor_rho_y[0];
      end
      3'b001: begin
        lane_xorr = lane_xor_rho_y[1];
      end
      3'b010: begin
        lane_xorr = lane_xor_rho_y[2];
      end
      3'b011: begin
        lane_xorr = lane_xor_rho_y[3];
      end
      3'b100: begin
        lane_xorr = lane_xor_rho_y[4];
      end
      default: begin
        lane_xorr = lane_xor_rho_y[0]; 
      end
    endcase
  end
  
  // Select XOR or XORR operation
  assign rd = (operation_i.op[0]) ? lane_xorr : lane_xor;

  logic expected_op_en;
  always_comb begin
    expected_op_en = 1'b0;

    unique case(operation_i.op)  

      KeccakLaneOpXOR: begin
        expected_op_en = 1'b1;
      end

      KeccakLaneOpXORR: begin
        expected_op_en = 1'b1;
      end

      KeccakLaneOpXORi: begin
        expected_op_en = 1'b1;
      end

      KeccakLaneOpNone: ;
      default: ;
    endcase
  end

assign keccak_lane_predec_error_o = 
|{expected_op_en != keccak_lane_predec_pq_i.op_en};

endmodule

