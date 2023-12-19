// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module reg_addr_unit
    import otbn_pq_pkg::*;
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
    

    logic   [7:0]       idx0_d;
    logic   [7:0]       idx0_q;
    logic               idx0_wr_en;

    logic   [7:0]       idx1_d;
    logic   [7:0]       idx1_q;
    logic               idx1_wr_en;
        
    logic   [7:0]       j2_d;
    logic   [7:0]       j2_q;
    logic               j2_wr_en;
        
    logic   [7:0]       m_d;
    logic   [7:0]       m_q;
    logic               m_wr_en;

    logic               mode_d;
    logic               mode_q;
    logic               mode_wr_en;

    logic   [2:0]       x_d;
    logic   [2:0]       x_q;
    logic               x_wr_en;
    logic   [2:0]       x_inc;
    
    logic   [2:0]       y_d;
    logic   [2:0]       y_q;
    logic               y_wr_en;
    logic   [2:0]       y_inc;
    
    logic   [7:0]       j_d;
    logic   [7:0]       j_q;
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
    
    assign ispr_base_wr_en = |ispr_base_wr_en_i;
        
    assign m_srl = {1'b0, m_q[7:1]};
    assign m_sll = {m_q[6:0], 1'b0};
    
    assign j2_sll = {j2_q[6:0], 1'b0};
    assign j2_srl = {1'b0, j2_q[7:1]};
    
    assign m_sl = mode_q ? m_sll : m_srl;
    assign j2_sl = mode_q ? j2_srl : j2_sll;
    
    assign j_inc = j_q + 1;
    
    assign jbr = {j_q[0], j_q[1], j_q[2], j_q[3], j_q[4], j_q[5], j_q[6], j_q[7]};
    
    assign idx0_inc = idx0_q + 1;
    
    assign idx1_inc = idx1_q + 1;
    
    assign add_m_jbr = jbr + m_q;

    adder #(
      .DATA_WIDTH(3)
    ) u_x_inc(
      .op0_i(x_q),
      .op1_i(3'd1),
      .q_i  (3'd5),
      .res_o(x_inc)
    );

    adder #(
      .DATA_WIDTH(3)
    ) u_y_inc(
      .op0_i(y_q),
      .op1_i(3'd1),
      .q_i  (3'd5),
      .res_o(y_inc)
    );
    
    // m Register

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            m_q <= '0;
        end else if (m_wr_en) begin
            m_q <= m_d;
        end
    end

    always_comb begin
    m_d= ispr_base_wdata_i[0+:8];

    unique case (1'b1)
        ispr_init_i:               m_d = '0;
        ispr_base_wr_en:           m_d = ispr_base_wdata_i[7:0];
        sl_m_i:                    m_d = m_sl;
    default: ;
        endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))

    assign m_wr_en =    ispr_init_i |
                        sl_m_i |
                        ((ispr_addr_i == IsprM) & (ispr_base_wr_en));

    // j2 Register

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            j2_q <= '0;
        end else if (j2_wr_en) begin
            j2_q <= j2_d;
        end
    end

    always_comb begin
    j2_d= ispr_base_wdata_i[0+:8];

    unique case (1'b1)
        ispr_init_i:               j2_d = '0;
        ispr_base_wr_en:           j2_d = ispr_base_wdata_i[7:0];
        sl_j2_i:                   j2_d = j2_sl;
    default: ;
        endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign j2_wr_en =   ispr_init_i |
                        sl_j2_i |
                        ((ispr_addr_i == IsprJ2) & (ispr_base_wr_en));

    // j Register
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            j_q <= '0;
        end else if (j_wr_en) begin
            j_q <= j_d;
        end
    end

    always_comb begin
    j_d= ispr_base_wdata_i[0+:8];

    unique case (1'b1)
        ispr_init_i:               j_d = '0;
        ispr_base_wr_en:           j_d = ispr_base_wdata_i[7:0];
        inc_j_i:                   j_d = j_inc;
    default: ;
        endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign j_wr_en =    ispr_init_i |
                        inc_j_i | 
                        ((ispr_addr_i == IsprJ) & (ispr_base_wr_en));

    // idx0 Register

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            idx0_q <= '0;
        end else if (idx0_wr_en) begin
            idx0_q <= idx0_d;
        end
    end

    always_comb begin
    idx0_d= ispr_base_wdata_i[0+:8];

    unique case (1'b1)
        ispr_init_i:               idx0_d = '0;
        ispr_base_wr_en:           idx0_d = ispr_base_wdata_i[7:0];
        set_idx_i:                 idx0_d = jbr;
        inc_idx_i:                 idx0_d = idx0_inc;
    default: ;
        endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign idx0_wr_en = ispr_init_i |
                        set_idx_i | inc_idx_i |
                        ((ispr_addr_i == IsprIdx0) & (ispr_base_wr_en));

    // idx1 Register
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            idx1_q <= '0;
        end else if (idx1_wr_en) begin
            idx1_q <= idx1_d;
        end
    end

    always_comb begin
    idx1_d= ispr_base_wdata_i[0+:8];

    unique case (1'b1)
        ispr_init_i:               idx1_d = '0;
        ispr_base_wr_en:           idx1_d = ispr_base_wdata_i[7:0];
        set_idx_i:                 idx1_d = add_m_jbr;
        inc_idx_i:                 idx1_d = idx1_inc;
    default: ;
        endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign idx1_wr_en = ispr_init_i |
                        set_idx_i | inc_idx_i |
                        ((ispr_addr_i == IsprIdx1) & (ispr_base_wr_en));


    // Mode Register
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            mode_q <= '0;
        end else if (mode_wr_en) begin
            mode_q <= mode_d;
        end
    end

    always_comb begin
    mode_d= ispr_base_wdata_i[0];

    unique case (1'b1)
        ispr_init_i:               mode_d = '0;
        ispr_base_wr_en:           mode_d = ispr_base_wdata_i[0];
    default: ;
        endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign mode_wr_en = ispr_init_i |
                        ((ispr_addr_i == IsprMode) & (ispr_base_wr_en));


    assign wdr0_o = idx0_q[7:3];
    assign wsel0_o = idx0_q[2:0];
    
    assign wdr1_o = idx1_q[7:3];
    assign wsel1_o = idx1_q[2:0];
    
    // X Register
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            x_q <= '0;
        end else if (x_wr_en) begin
            x_q <= x_d;
        end
    end

    always_comb begin
    x_d= ispr_base_wdata_i[2:0];

    unique case (1'b1)
        ispr_init_i:               x_d = '0;
        ispr_base_wr_en:           x_d = ispr_base_wdata_i[2:0];
        inc_x_i:                   x_d = x_inc;
    default: ;
        endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign x_wr_en = ispr_init_i |
                     inc_x_i |
                     ((ispr_addr_i == IsprX) & (ispr_base_wr_en));

    assign x_o = x_q;

    // Y Register
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            y_q <= '0;
        end else if (y_wr_en) begin
            y_q <= y_d;
        end
    end

    always_comb begin
    y_d= ispr_base_wdata_i[2:0];

    unique case (1'b1)
        ispr_init_i:               y_d = '0;
        ispr_base_wr_en:           y_d = ispr_base_wdata_i[2:0];
        inc_y_i:                   y_d = y_inc;
    default: ;
        endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en[i_word]}))

    assign y_wr_en = ispr_init_i |
                     inc_y_i |
                     ((ispr_addr_i == IsprY) & (ispr_base_wr_en));

    assign y_o = y_q;

     always_comb begin
        ispr_rdata_o = {24'b0, m_q};
        
        unique case (ispr_addr_i)
          IsprM:           ispr_rdata_o = {24'b0, m_q};
          IsprJ2:          ispr_rdata_o = {24'b0, j2_q};
          IsprJ:           ispr_rdata_o = {24'b0, j_q};
          IsprIdx0:        ispr_rdata_o = {24'b0, idx0_q};
          IsprIdx1:        ispr_rdata_o = {24'b0, idx1_q};
          IsprMode:        ispr_rdata_o = {31'b0, mode_q};
          IsprX:           ispr_rdata_o = {29'b0, x_q};
          IsprY:           ispr_rdata_o = {29'b0, y_q};
        default: ;
        endcase
    end   

endmodule: reg_addr_unit
