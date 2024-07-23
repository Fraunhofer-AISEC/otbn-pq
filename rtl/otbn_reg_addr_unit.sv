// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

/* verilator lint_off UNUSED */

module otbn_reg_addr_unit
    import otbn_pq_pkg::*;
    import otbn_pkg::*;

(
    input   logic                       clk_i,
    input   logic                       rst_ni,
    
    input   logic                       sl_j2_i,
    input   logic                       sl_m_i,
    input   logic                       inc_j_i,
    input   logic                       inc_idx_i,
    input   logic                       set_idx_i,
    
    output  logic[4:0]                  wdr0_o,
    output  logic[2:0]                  wsel0_o,
    
    output  logic[4:0]                  wdr1_o,
    output  logic[2:0]                  wsel1_o,    
    
    output  logic[2:0]                  x_o,
    output  logic[2:0]                  y_o,
    input   logic                       inc_x_i,
    input   logic                       inc_y_i,
        
    input  ipqspr_e                     ispr_addr_i,
    input  logic [31:0]                 ispr_base_wdata_i,
    input  logic [7:0]                  ispr_base_wr_en_i,
    input  logic                        ispr_init_i,
    output logic [31:0]                 ispr_rdata_o
    );
    

    logic   [ExtPQLEN-1:0]       idx0_intg_d;
    logic   [ExtPQLEN-1:0]       idx0_intg_q;
    logic               idx0_wr_en;

    logic   [ExtPQLEN-1:0]       idx1_intg_d;
    logic   [ExtPQLEN-1:0]       idx1_intg_q;
    logic               idx1_wr_en;
        
    logic   [ExtPQLEN-1:0]       j2_intg_d;
    logic   [ExtPQLEN-1:0]       j2_intg_q;
    logic               j2_wr_en;
        
    logic   [ExtPQLEN-1:0]       m_intg_d;
    logic   [ExtPQLEN-1:0]       m_intg_q;
    logic               m_wr_en;

    logic [ExtPQLEN-1:0]         mode_intg_d;
    logic [ExtPQLEN-1:0]         mode_intg_q;
    logic               mode_wr_en;

    logic   [ExtPQLEN-1:0]       x_intg_d;
    logic   [ExtPQLEN-1:0]       x_intg_q;
    logic               x_wr_en;
    logic   [2:0]       x_inc;
    
    logic   [ExtPQLEN-1:0]       y_intg_d;
    logic   [ExtPQLEN-1:0]       y_intg_q;
    logic               y_wr_en;
    logic   [2:0]       y_inc;
    
    logic   [ExtPQLEN-1:0]       j_intg_d;
    logic   [ExtPQLEN-1:0]       j_intg_q;
    logic               j_wr_en;
    
    logic   [7:0]       m_srl;
    logic   [7:0]       j2_sll; 
    
    logic   [7:0]       m_sll;
    logic   [7:0]       j2_srl; 

    logic   [7:0]       m_sl;
    logic   [7:0]       j2_sl; 
    
    logic   [7:0]       j_inc;  
    logic   [7:0]       idx0_inc;
    logic   [7:0]       idx1_inc; 
    logic   [7:0]       jbr;
    
    logic               ispr_base_wr_en;
    
    logic   [7:0]       add_m_jbr;
    
    logic  [23:0]       unused_base_data;

  // Integrity Signals
  logic [PQLEN-1:0]                m_no_intg_d;
  logic [PQLEN-1:0]                m_no_intg_q;
  logic [ExtPQLEN-1:0]             m_intg_calc;
  logic [1:0]                      m_intg_err;

  logic [PQLEN-1:0]                j2_no_intg_d;
  logic [PQLEN-1:0]                j2_no_intg_q;
  logic [ExtPQLEN-1:0]             j2_intg_calc;
  logic [1:0]                      j2_intg_err;

  logic [PQLEN-1:0]                j_no_intg_d;
  logic [PQLEN-1:0]                j_no_intg_q;
  logic [ExtPQLEN-1:0]             j_intg_calc;
  logic [1:0]                      j_intg_err;

  logic [PQLEN-1:0]                idx0_no_intg_d;
  logic [PQLEN-1:0]                idx0_no_intg_q;
  logic [ExtPQLEN-1:0]             idx0_intg_calc;
  logic [1:0]                      idx0_intg_err;

  logic [PQLEN-1:0]                idx1_no_intg_d;
  logic [PQLEN-1:0]                idx1_no_intg_q;
  logic [ExtPQLEN-1:0]             idx1_intg_calc;
  logic [1:0]                      idx1_intg_err;

  logic [PQLEN-1:0]                x_no_intg_d;
  logic [PQLEN-1:0]                x_no_intg_q;
  logic [ExtPQLEN-1:0]             x_intg_calc;
  logic [1:0]                      x_intg_err;

  logic [PQLEN-1:0]                y_no_intg_d;
  logic [PQLEN-1:0]                y_no_intg_q;
  logic [ExtPQLEN-1:0]             y_intg_calc;
  logic [1:0]                      y_intg_err;

  logic [PQLEN-1:0]                mode_no_intg_d;
  logic [PQLEN-1:0]                mode_no_intg_q;
  logic [ExtPQLEN-1:0]             mode_intg_calc;
  logic [1:0]                      mode_intg_err;

    //assign unused_base_data = ispr_base_wdata_i[31:8];
    assign ispr_base_wr_en = |ispr_base_wr_en_i;
        
    assign m_srl = {1'b0, m_no_intg_q[7:1]};
    assign m_sll = {m_no_intg_q[6:0], 1'b0};
    
    assign j2_sll = {j2_no_intg_q[6:0], 1'b0};
    assign j2_srl = {1'b0, j2_no_intg_q[7:1]};
    
    assign m_sl = mode_no_intg_q[0] ? m_sll : m_srl;
    assign j2_sl = mode_no_intg_q[0] ? j2_srl : j2_sll;
    
    assign j_inc = j_no_intg_q + 1;
    
    assign jbr = {j_no_intg_q[0], j_no_intg_q[1], j_no_intg_q[2], j_no_intg_q[3], j_no_intg_q[4], j_no_intg_q[5], j_no_intg_q[6], j_no_intg_q[7]};
    
    assign idx0_inc = idx0_no_intg_q[7:0] + 1;
    
    assign idx1_inc = idx1_no_intg_q[7:0] + 1;
    
    assign add_m_jbr = jbr + m_no_intg_q[7:0];

    otbn_adder #(
      .DATA_WIDTH(3)
    ) u_x_inc(
      .op0_i(x_no_intg_q[2:0]),
      .op1_i(3'd1),
      .q_i  (3'd5),
      .res_o(x_inc)
    );

    otbn_adder #(
      .DATA_WIDTH(3)
    ) u_y_inc(
      .op0_i(y_no_intg_q[2:0]),
      .op1_i(3'd1),
      .q_i  (3'd5),
      .res_o(y_inc)
    );
    
    // m Register
    prim_secded_inv_39_32_enc i_secded_enc_m (
      .data_i (m_no_intg_d),
      .data_o (m_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_m (
      .data_i     (m_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (m_intg_err)
    );
    assign m_no_intg_q = m_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (m_wr_en) begin
            m_intg_q <= m_intg_d;
        end
    end

    always_comb begin
      m_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: m_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            m_no_intg_d = {24'b0, ispr_base_wdata_i[0+:8]};
            m_intg_d = m_intg_calc;
          end
          sl_m_i: begin
            m_no_intg_d = {24'b0, m_sl};
            m_intg_d = m_intg_calc;            
          end
        default: ;
      endcase
    end

    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))

    assign m_wr_en =    ispr_init_i |
                        sl_m_i |
                        ((ispr_addr_i == IsprM) & (ispr_base_wr_en));

    // j2 Register
    prim_secded_inv_39_32_enc i_secded_enc_j2 (
      .data_i (j2_no_intg_d),
      .data_o (j2_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_j2 (
      .data_i     (j2_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (j2_intg_err)
    );
    assign j2_no_intg_q = j2_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (j2_wr_en) begin
            j2_intg_q <= j2_intg_d;
        end
    end

    always_comb begin
      j2_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: j2_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            j2_no_intg_d = {24'b0, ispr_base_wdata_i[0+:8]};
            j2_intg_d = j2_intg_calc;
          end
          sl_j2_i: begin
            j2_no_intg_d = {24'b0, j2_sl};
            j2_intg_d = j2_intg_calc;            
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign j2_wr_en =   ispr_init_i |
                        sl_j2_i |
                        ((ispr_addr_i == IsprJ2) & (ispr_base_wr_en));

    // j Register
    prim_secded_inv_39_32_enc i_secded_enc_j (
      .data_i (j_no_intg_d),
      .data_o (j_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_j (
      .data_i     (j_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (j_intg_err)
    );
    assign j_no_intg_q = j_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (j_wr_en) begin
            j_intg_q <= j_intg_d;
        end
    end

    always_comb begin
      j_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: j_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            j_no_intg_d = {24'b0, ispr_base_wdata_i[0+:8]};
            j_intg_d = j_intg_calc;
          end
          inc_j_i: begin
            j_no_intg_d = {24'b0, j_inc};
            j_intg_d = j_intg_calc;            
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign j_wr_en =    ispr_init_i |
                        inc_j_i | 
                        ((ispr_addr_i == IsprJ) & (ispr_base_wr_en));

    // idx0 Register
    prim_secded_inv_39_32_enc i_secded_enc_idx0 (
      .data_i (idx0_no_intg_d),
      .data_o (idx0_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_idx0 (
      .data_i     (idx0_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (idx0_intg_err)
    );
    assign idx0_no_intg_q = idx0_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (idx0_wr_en) begin
            idx0_intg_q <= idx0_intg_d;
        end
    end

    always_comb begin
      idx0_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: idx0_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            idx0_no_intg_d = {24'b0, ispr_base_wdata_i[0+:8]};
            idx0_intg_d = idx0_intg_calc;
          end
          set_idx_i: begin
            idx0_no_intg_d = {24'b0, jbr};
            idx0_intg_d = idx0_intg_calc;            
          end
          inc_idx_i: begin
            idx0_no_intg_d = {24'b0, idx0_inc};
            idx0_intg_d = idx0_intg_calc;            
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign idx0_wr_en = ispr_init_i |
                        set_idx_i | inc_idx_i |
                        ((ispr_addr_i == IsprIdx0) & (ispr_base_wr_en));

    // idx1 Register
    prim_secded_inv_39_32_enc i_secded_enc_idx1 (
      .data_i (idx1_no_intg_d),
      .data_o (idx1_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_idx1 (
      .data_i     (idx1_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (idx1_intg_err)
    );
    assign idx1_no_intg_q = idx1_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (idx1_wr_en) begin
            idx1_intg_q <= idx1_intg_d;
        end
    end

    always_comb begin
      idx1_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: idx1_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            idx1_no_intg_d = {24'b0, ispr_base_wdata_i[0+:8]};
            idx1_intg_d = idx1_intg_calc;
          end
          set_idx_i: begin
            idx1_no_intg_d = {24'b0, add_m_jbr};
            idx1_intg_d = idx1_intg_calc;            
          end
          inc_idx_i: begin
            idx1_no_intg_d = {24'b0, idx1_inc};
            idx1_intg_d = idx1_intg_calc;            
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign idx1_wr_en = ispr_init_i |
                        set_idx_i | inc_idx_i |
                        ((ispr_addr_i == IsprIdx1) & (ispr_base_wr_en));


    // Mode Register
    prim_secded_inv_39_32_enc i_secded_enc_mode (
      .data_i (mode_no_intg_d),
      .data_o (mode_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_mode (
      .data_i     (mode_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (mode_intg_err)
    );
    assign mode_no_intg_q = mode_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (mode_wr_en) begin
            mode_intg_q <= mode_intg_d;
        end
    end

    always_comb begin
      mode_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: mode_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            mode_no_intg_d = {30'b0, ispr_base_wdata_i[0]};
            mode_intg_d = mode_intg_calc;
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign mode_wr_en = ispr_init_i |
                        ((ispr_addr_i == IsprMode) & (ispr_base_wr_en));


    assign wdr0_o = idx0_no_intg_q[7:3];
    assign wsel0_o = idx0_no_intg_q[2:0];
    
    assign wdr1_o = idx1_no_intg_q[7:3];
    assign wsel1_o = idx1_no_intg_q[2:0];
    
    // X Register
    prim_secded_inv_39_32_enc i_secded_enc_x (
      .data_i (x_no_intg_d),
      .data_o (x_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_x (
      .data_i     (x_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (x_intg_err)
    );
    assign x_no_intg_q = x_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (x_wr_en) begin
            x_intg_q <= x_intg_d;
        end
    end

    always_comb begin
      x_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: x_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            x_no_intg_d = {29'b0, ispr_base_wdata_i[0+:3]};
            x_intg_d = x_intg_calc;
          end
          inc_x_i: begin
            x_no_intg_d = {29'b0, x_inc};
            x_intg_d = x_intg_calc;            
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign x_wr_en = ispr_init_i |
                     inc_x_i |
                     ((ispr_addr_i == IsprX) & (ispr_base_wr_en));

    assign x_o = x_no_intg_q[2:0];

    // Y Register
    prim_secded_inv_39_32_enc i_secded_enc_y (
      .data_i (y_no_intg_d),
      .data_o (y_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_y (
      .data_i     (y_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (y_intg_err)
    );
    assign y_no_intg_q = y_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (y_wr_en) begin
            y_intg_q <= y_intg_d;
        end
    end

    always_comb begin
      y_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: y_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            y_no_intg_d = {29'b0, ispr_base_wdata_i[0+:3]};
            y_intg_d = y_intg_calc;
          end
          inc_y_i: begin
            y_no_intg_d = {29'b0, y_inc};
            y_intg_d = y_intg_calc;            
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign y_wr_en = ispr_init_i |
                     inc_y_i |
                     ((ispr_addr_i == IsprY) & (ispr_base_wr_en));

    assign y_o = y_no_intg_q[2:0];

     always_comb begin
        ispr_rdata_o = {24'b0, m_no_intg_q[7:0]};
        
        unique case (ispr_addr_i)
          IsprM:           ispr_rdata_o = {24'b0, m_no_intg_q[7:0]};
          IsprJ2:          ispr_rdata_o = {24'b0, j2_no_intg_q[7:0]};
          IsprJ:           ispr_rdata_o = {24'b0, j_no_intg_q[7:0]};
          IsprIdx0:        ispr_rdata_o = {24'b0, idx0_no_intg_q[7:0]};
          IsprIdx1:        ispr_rdata_o = {24'b0, idx1_no_intg_q[7:0]};
          IsprMode:        ispr_rdata_o = {31'b0, mode_no_intg_q[0]};
          IsprX:           ispr_rdata_o = {29'b0, x_no_intg_q[2:0]};
          IsprY:           ispr_rdata_o = {29'b0, y_no_intg_q[2:0]};
        default: ;
        endcase
    end   

endmodule: otbn_reg_addr_unit
