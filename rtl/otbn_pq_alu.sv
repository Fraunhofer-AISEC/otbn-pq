// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module otbn_pq_alu
  import otbn_pq_pkg::*;
(
    input  alu_pq_operation_t               operation_i,
    output logic              [PQLEN*8-1:0] rs0_o,
    output logic              [PQLEN*8-1:0] rs1_o,
    output logic              [PQLEN*8-1:0] rd_o
);
  //logic   [DATA_WIDTH-1:0]    gs_bf_add;
  logic [PQLEN-1:0] gs_bf_sub;
  logic [PQLEN-1:0] gs_bf_mux;

  logic [PQLEN-1:0] mul_2_sub_mux;
  logic [PQLEN-1:0] mul_op_mux;
  logic [PQLEN-1:0] foward_operandb_mux;
  logic [PQLEN-1:0] scale_mux;
  logic [PQLEN-1:0] mul_2_mux;
  logic [PQLEN-1:0] imm_rs1_mux;
  logic [PQLEN-1:0] ct_bf_add;
  logic [PQLEN-1:0] ct_bf_sub;
  logic [PQLEN-1:0] ct_bf_mux0;
  logic [PQLEN-1:0] ct_bf_mux1;

  logic             sel_gs_subtractor;
  logic             sel_ct_mux0;
  logic             sel_ct_mux1;
  logic             sel_twiddle;
  logic             sel_scale;
  logic             sel_forward_rs0;
  logic             sel_forward_rs1;
  logic             sel_rd;

  logic [PQLEN-1:0] alu_op_a;
  logic [PQLEN-1:0] alu_op_b;
  logic [PQLEN-1:0] alu_op_imm;
  
  logic [PQLEN-1:0] rs0;
  logic [PQLEN-1:0] rs1;
  logic [PQLEN-1:0] rd;
  logic sel_imm;
  
  always_comb begin
    alu_op_a = '0;
    alu_op_b = '0;
    alu_op_imm = operation_i.imm;
    
    unique case (operation_i.operand_a_w_sel)
      3'd0: begin
        alu_op_a = operation_i.operand_a[PQLEN*0+:PQLEN];
        rs0_o = {224'b0, rs0};
      end
      3'd1: begin
        alu_op_a = operation_i.operand_a[PQLEN*1+:PQLEN];
        rs0_o = {192'b0, rs0, 32'b0};
      end
      3'd2: begin
        alu_op_a = operation_i.operand_a[PQLEN*2+:PQLEN];
        rs0_o = {160'b0, rs0, 64'b0};
      end
      3'd3: begin
        alu_op_a = operation_i.operand_a[PQLEN*3+:PQLEN];
        rs0_o = {128'b0, rs0, 96'b0};
      end
      3'd4: begin
        alu_op_a = operation_i.operand_a[PQLEN*4+:PQLEN];
        rs0_o = {96'b0, rs0, 128'b0};
      end
      3'd5: begin
        alu_op_a = operation_i.operand_a[PQLEN*5+:PQLEN];
        rs0_o = {64'b0, rs0, 160'b0};
      end
      3'd6: begin
        alu_op_a = operation_i.operand_a[PQLEN*6+:PQLEN];
        rs0_o = {32'b0, rs0, 192'b0};
      end
      3'd7: begin
        alu_op_a = operation_i.operand_a[PQLEN*7+:PQLEN];
        rs0_o = {rs0, 224'b0};
      end
      default: alu_op_a = '0;
    endcase

    unique case (operation_i.operand_b_w_sel)
      3'd0: begin
        alu_op_b = operation_i.operand_b[PQLEN*0+:PQLEN];
        rs1_o = {224'b0, rs1};
      end
      3'd1: begin
        alu_op_b = operation_i.operand_b[PQLEN*1+:PQLEN];
        rs1_o = {192'b0, rs1, 32'b0};
      end
      3'd2: begin
        alu_op_b = operation_i.operand_b[PQLEN*2+:PQLEN];
        rs1_o = {160'b0, rs1, 64'b0};
      end
      3'd3: begin
        alu_op_b = operation_i.operand_b[PQLEN*3+:PQLEN];
        rs1_o = {128'b0, rs1, 96'b0};
      end
      3'd4: begin
        alu_op_b = operation_i.operand_b[PQLEN*4+:PQLEN];
        rs1_o = {96'b0, rs1, 128'b0};
      end
      3'd5: begin
        alu_op_b = operation_i.operand_b[PQLEN*5+:PQLEN];
        rs1_o = {64'b0, rs1, 160'b0};
      end
      3'd6: begin
        alu_op_b = operation_i.operand_b[PQLEN*6+:PQLEN];
        rs1_o = {32'b0, rs1, 192'b0};
      end
      3'd7: begin
        alu_op_b = operation_i.operand_b[PQLEN*7+:PQLEN];
        rs1_o = {rs1, 224'b0};
      end
      default: alu_op_b = '0;
    endcase

    unique case (operation_i.d_w_sel)
      3'd0: begin
        rd_o = {224'b0, rd};
      end
      3'd1: begin
        rd_o = {192'b0, rd, 32'b0};
      end
      3'd2: begin
        rd_o = {160'b0, rd, 64'b0};
      end
      3'd3: begin
        rd_o = {128'b0, rd, 96'b0};
      end
      3'd4: begin
        rd_o = {96'b0, rd, 128'b0};
      end
      3'd5: begin
        rd_o = {64'b0, rd, 160'b0};
      end
      3'd6: begin
        rd_o = {32'b0, rd, 192'b0};
      end
      3'd7: begin
        rd_o = {rd, 224'b0};
      end
    endcase


  end

  assign sel_gs_subtractor = operation_i.op[7];
  assign sel_ct_mux0       = operation_i.op[6];
  assign sel_ct_mux1       = operation_i.op[5];
  assign sel_twiddle       = operation_i.op[4];
  assign sel_scale         = operation_i.op[3];
  assign sel_forward_rs0   = operation_i.op[2];
  assign sel_forward_rs1   = operation_i.op[1];
  assign sel_rd            = operation_i.op[0];
  
  assign sel_imm            = operation_i.imm_sel;
  
  
  otbn_subtractor #(
      .DATA_WIDTH(PQLEN)
  ) U_GS_SUBTRACTOR (
      .op0_i(alu_op_a),
      .op1_i(alu_op_b),
      .q_i  (operation_i.prime),
      .res_o(gs_bf_sub)
  );

  // SCALE_OPERAND_MUX
  assign scale_mux = (sel_scale == 1'b1) ? operation_i.scale : alu_op_b;

  // GS_BF_MUX
  assign gs_bf_mux  = (sel_gs_subtractor == 1'b1) ? gs_bf_sub : scale_mux;

  // MUL_OP_MUX
  assign mul_op_mux = (sel_twiddle == 1'b1) ? operation_i.twiddle : alu_op_a;


  otbn_multiplier #(
      .DATA_WIDTH(PQLEN),
      .LOG_R(LOG_R)
  ) U_MULTIPLIER (
      .op0_i(gs_bf_mux),
      .op1_i(mul_op_mux),
      .q_i(operation_i.prime),
      .q_dash_i(operation_i.prime_dash),
      .res_o(mul_2_mux)
  );

  assign imm_rs1_mux = (sel_imm == 1'b1) ? alu_op_imm : alu_op_b;
  
  assign foward_operandb_mux = (sel_forward_rs1 == 1'b1) ? imm_rs1_mux : mul_2_mux;

  assign mul_2_sub_mux  = (sel_forward_rs0 == 1'b1) ? alu_op_a : mul_2_mux;

  otbn_adder #(
      .DATA_WIDTH(PQLEN)
  ) U_CT_ADDER (
      .op0_i(alu_op_a),
      .op1_i(foward_operandb_mux),
      .q_i  (operation_i.prime),
      .res_o(ct_bf_add)
  );

  otbn_subtractor #(
      .DATA_WIDTH(PQLEN)
  ) U_CT_SUBTRACTOR (
      .op0_i(mul_2_sub_mux),
      .op1_i(foward_operandb_mux),
      .q_i  (operation_i.prime),
      .res_o(ct_bf_sub)
  );

  assign ct_bf_mux0 = (sel_ct_mux0 == 1'b1) ? ct_bf_add : alu_op_a;

  assign ct_bf_mux1 = (sel_ct_mux1 == 1'b1) ? ct_bf_sub : mul_2_sub_mux;

  assign rs0 = ct_bf_mux0;

  assign rs1 = ct_bf_mux1;

  assign rd = (sel_rd == 1'b1) ? ct_bf_mux1 : ct_bf_mux0;

endmodule : otbn_pq_alu
