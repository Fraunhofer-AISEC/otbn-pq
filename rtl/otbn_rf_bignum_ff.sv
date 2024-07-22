// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/**
 * ExtWLEN (312b) Wide Register File (WDRs)
 *
 * ExtWLEN allows bits to provide integrity checking to WLEN words on a 32-bit granule. Integrity
 * generation/checking implemented in wrapping otbn_rf_bignum module
 *
 * Features:
 * - 2 read ports
 * - 1 write port
 * - Half (WLEN) word write enables
 */
module otbn_rf_bignum_ff
  import otbn_pkg::*;
(
  input  logic             clk_i,
  input  logic             rst_ni,

  input  logic [WdrAw-1:0]   wr_addr_a_i,
  input  logic [WdrAw-1:0]   wr_addr_b_i,
  input  logic [7:0]         wr_en_a_i,
  input  logic [7:0]         wr_en_b_i,
  input  logic [ExtWLEN-1:0] wr_data_a_i,
  input  logic [ExtWLEN-1:0] wr_data_b_i, 

  input  logic [WdrAw-1:0]   rd_addr_a_i,
  output logic [ExtWLEN-1:0] rd_data_a_o,

  input  logic [WdrAw-1:0]   rd_addr_b_i,
  output logic [ExtWLEN-1:0] rd_data_b_o,

  // Indicates whether a spurious WE has been seen in the last cycle.
  output logic               we_err_o,

  input  rf_predec_bignum_t  rf_predec_bignum_i
);
  logic [ExtWLEN-1:0] rf [NWdr];
  logic [7:0]         we_a_onehot [NWdr];
  logic [7:0]         we_b_onehot [NWdr];

  logic unused_addr;

  for (genvar i = 0; i < NWdr; i++) begin : g_rf
    logic [ExtWLEN-1:0] wr_data_a_blanked;
    logic [ExtWLEN-1:0] wr_data_b_blanked;
    assign we_a_onehot[i] = wr_en_a_i & {8{wr_addr_a_i == i}};
    assign we_b_onehot[i] = wr_en_b_i & {8{wr_addr_b_i == i}};

    // SEC_CM: DATA_REG_SW.SCA
    prim_blanker #(.Width(ExtWLEN)) u_wdata_a_blanker(
      .in_i (wr_data_a_i),
      .en_i (rf_predec_bignum_i.rf_we_a[i]),
      .out_o(wr_data_a_blanked)
    );
    prim_blanker #(.Width(ExtWLEN)) u_wdata_b_blanker(
      .in_i (wr_data_b_i),
      .en_i (rf_predec_bignum_i.rf_we_b[i]),
      .out_o(wr_data_b_blanked)
    );

    // Split registers into halves for clear seperation for the enable terms
    always_ff @(posedge clk_i) begin
      if (rf_predec_bignum_i.rf_we_a[i] & we_a_onehot[i][0]) begin
        rf[i][0+:ExtWLEN/8] <= wr_data_a_blanked[0+:ExtWLEN/8];
      end else if (rf_predec_bignum_i.rf_we_b[i] & we_b_onehot[i][0]) begin
        rf[i][0+:ExtWLEN/8] <= wr_data_b_blanked[0+:ExtWLEN/8];
      end
    end

    always_ff @(posedge clk_i) begin
      if (rf_predec_bignum_i.rf_we_a[i] & we_a_onehot[i][1]) begin
        rf[i][ExtWLEN/8+:ExtWLEN/8] <= wr_data_a_blanked[ExtWLEN/8+:ExtWLEN/8];
      end else if (rf_predec_bignum_i.rf_we_b[i] & we_b_onehot[i][1]) begin
        rf[i][ExtWLEN/8+:ExtWLEN/8] <= wr_data_b_blanked[ExtWLEN/8+:ExtWLEN/8];
      end
    end

    always_ff @(posedge clk_i) begin
      if (rf_predec_bignum_i.rf_we_a[i] & we_a_onehot[i][2]) begin
        rf[i][2*ExtWLEN/8+:ExtWLEN/8] <= wr_data_a_blanked[2*ExtWLEN/8+:ExtWLEN/8];
      end else if (rf_predec_bignum_i.rf_we_b[i] & we_b_onehot[i][2]) begin
        rf[i][2*ExtWLEN/8+:ExtWLEN/8] <= wr_data_b_blanked[2*ExtWLEN/8+:ExtWLEN/8];
      end
    end

    always_ff @(posedge clk_i) begin
      if (rf_predec_bignum_i.rf_we_a[i] & we_a_onehot[i][3]) begin
        rf[i][3*ExtWLEN/8+:ExtWLEN/8] <= wr_data_a_blanked[3*ExtWLEN/8+:ExtWLEN/8];
      end else if (rf_predec_bignum_i.rf_we_b[i] & we_b_onehot[i][3]) begin
        rf[i][3*ExtWLEN/8+:ExtWLEN/8] <= wr_data_b_blanked[3*ExtWLEN/8+:ExtWLEN/8];
      end
    end
    
    always_ff @(posedge clk_i) begin
      if (rf_predec_bignum_i.rf_we_a[i] & we_a_onehot[i][4]) begin
        rf[i][4*ExtWLEN/8+:ExtWLEN/8] <= wr_data_a_blanked[4*ExtWLEN/8+:ExtWLEN/8];
      end else if (rf_predec_bignum_i.rf_we_b[i] & we_b_onehot[i][4]) begin
        rf[i][4*ExtWLEN/8+:ExtWLEN/8] <= wr_data_b_blanked[4*ExtWLEN/8+:ExtWLEN/8];
      end
    end   

    always_ff @(posedge clk_i) begin
      if (rf_predec_bignum_i.rf_we_a[i] & we_a_onehot[i][5]) begin
        rf[i][5*ExtWLEN/8+:ExtWLEN/8] <= wr_data_a_blanked[5*ExtWLEN/8+:ExtWLEN/8];
      end else if (rf_predec_bignum_i.rf_we_b[i] & we_b_onehot[i][5]) begin
        rf[i][5*ExtWLEN/8+:ExtWLEN/8] <= wr_data_b_blanked[5*ExtWLEN/8+:ExtWLEN/8];
      end
    end 
    
    always_ff @(posedge clk_i) begin
      if (rf_predec_bignum_i.rf_we_a[i] & we_a_onehot[i][6]) begin
        rf[i][6*ExtWLEN/8+:ExtWLEN/8] <= wr_data_a_blanked[6*ExtWLEN/8+:ExtWLEN/8];
      end else if (rf_predec_bignum_i.rf_we_b[i] & we_b_onehot[i][6]) begin
        rf[i][6*ExtWLEN/8+:ExtWLEN/8] <= wr_data_b_blanked[6*ExtWLEN/8+:ExtWLEN/8];
      end
    end

    always_ff @(posedge clk_i) begin
      if (rf_predec_bignum_i.rf_we_a[i] & we_a_onehot[i][7]) begin
        rf[i][7*ExtWLEN/8+:ExtWLEN/8] <= wr_data_a_blanked[7*ExtWLEN/8+:ExtWLEN/8];
      end else if (rf_predec_bignum_i.rf_we_b[i] & we_b_onehot[i][7]) begin
        rf[i][7*ExtWLEN/8+:ExtWLEN/8] <= wr_data_b_blanked[7*ExtWLEN/8+:ExtWLEN/8];
      end
    end

  `ASSERT(BlankingBignumRegWData_A, !(|we_a_onehot[i]) |-> wr_data_a_blanked inside {'0, 'x})
  `ASSERT(BlankingBignumRegWData_B, !(|we_b_onehot[i]) |-> wr_data_b_blanked inside {'0, 'x})
  end

  // SEC_CM: DATA_REG_SW.SCA
  prim_onehot_mux #(
    .Width(ExtWLEN),
    .Inputs(NWdr)
  ) u_rd_mux_a (
    .clk_i,
    .rst_ni,
    .in_i  (rf),
    .sel_i (rf_predec_bignum_i.rf_ren_a),
    .out_o (rd_data_a_o)
  );

  prim_onehot_mux  #(
    .Width(ExtWLEN),
    .Inputs(NWdr)
  ) u_rd_mux_b (
    .clk_i,
    .rst_ni,
    .in_i  (rf),
    .sel_i (rf_predec_bignum_i.rf_ren_b),
    .out_o (rd_data_b_o)
  );

  assign unused_addr = ^rd_addr_a_i ^ ^rd_addr_b_i ^ ^wr_addr_a_i;

  logic we_err, we_err_d;
  logic [7:0][NWdr-1:0] we_a_onehot_unbuf, we_a_onehot_buf;
  logic [7:0][NWdr-1:0] we_b_onehot_unbuf, we_b_onehot_buf;

  for (genvar k = 0; k < 8; k++) begin : g_check
    for (genvar i = 0; i < NWdr; i++) begin : g_reshape
      assign we_a_onehot_unbuf[k][i] = we_a_onehot[i][k];
      assign we_b_onehot_unbuf[k][i] = we_b_onehot[i][k];
    end
  end

  // Buffer the decoded write enable bits so that the checker
  // is not optimized into the address decoding logic.
  prim_buf #(
    .Width(8*NWdr)
  ) u_prim_buf_a (
    .in_i(we_a_onehot_unbuf),
    .out_o(we_a_onehot_buf)
  );
  prim_buf #(
    .Width(8*NWdr)
  ) u_prim_buf_b (
    .in_i(we_b_onehot_unbuf),
    .out_o(we_b_onehot_buf)
  );

  // SEC_CM: RF_BIGNUM.DATA_REG_SW.GLITCH_DETECT
  // This checks for spurious WE strobes on the regfile.
  prim_onehot_check #(
    .AddrWidth(WdrAw),
    .OneHotWidth(NWdr),
    .AddrCheck(1),
    .EnableCheck(1)
  ) u_prim_onehot_check_a (
    .clk_i,
    .rst_ni,
    // OR the two register halves.
    .oh_i(we_a_onehot_buf[0] | we_a_onehot_buf[1] | we_a_onehot_buf[2] | we_a_onehot_buf[3] | we_a_onehot_buf[4] | we_a_onehot_buf[5] | we_a_onehot_buf[6] | we_a_onehot_buf[7]),
    .addr_i(wr_addr_a_i),
    .en_i(|wr_en_a_i),
    .err_o(we_err)
  );
  
  prim_onehot_check #(
    .AddrWidth(WdrAw),
    .OneHotWidth(NWdr),
    .AddrCheck(1),
    .EnableCheck(1)
  ) u_prim_onehot_check_b (
    .clk_i,
    .rst_ni,
    // OR the two register halves.
    .oh_i(we_b_onehot_buf[0] | we_b_onehot_buf[1] | we_b_onehot_buf[2] | we_b_onehot_buf[3] | we_b_onehot_buf[4] | we_b_onehot_buf[5] | we_b_onehot_buf[6] | we_b_onehot_buf[7]),
    .addr_i(wr_addr_b_i),
    .en_i(|wr_en_b_i),
    .err_o()
  );

  assign we_err_d = we_err | we_err_o;

  prim_flop #(
    .Width(1),
    .ResetValue('0)
  ) u_we_err_flop (
    .clk_i,
    .rst_ni,

    .d_i(we_err_d),
    .q_o(we_err_o)
  );

endmodule
