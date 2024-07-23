// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module otbn_twiddle_update
    import otbn_pq_pkg::*;
    import otbn_pkg::*;
(   
    input   logic                       clk_i,
    input   logic                       rst_ni,

    input   trcu_predec_pq_t            trcu_predec_pq_i,

    input   logic                       update_omega_i,
    input   logic                       update_psi_i,
    input   logic                       set_twiddle_as_psi_i,
    input   logic                       update_twiddle_i,
    input   logic                       invert_twiddle_i,
    input   logic                       omega_idx_inc_i,
    input   logic                       psi_idx_inc_i,
    
    input   logic                       rc_idx_inc_i,
    
    output  logic   [PQLEN-1:0]         twiddle_o,
    output  logic   [PQLEN-1:0]         psi_o,
    output  logic   [PQLEN-1:0]         omega_o,
    
    output  logic   [PQLEN-1:0]         prime_o,
    output  logic   [PQLEN-1:0]         prime_dash_o,    
    
    output  logic   [PQLEN-1:0]         const_o,
    
    output  logic   [63:0]              rc_o,
    
    input  ipqspr_e                         ispr_addr_i,
    input  logic [31:0]                     ispr_base_wdata_i,
    input  logic [BaseWordsPerPQLEN-1:0]    ispr_base_wr_en_i,
    input  logic [8*PQLEN-1:0]              ispr_pq_wdata_i,
    input  logic                            ispr_pq_wr_en_i,
    input  logic                            ispr_init_i,
    output logic [8*PQLEN-1:0]              ispr_rdata_o
);

    logic   [PQLEN-1:0]    twiddle_mul;
    
    logic   [PQLEN-1:0]    omega_mul;
    
    logic   [PQLEN-1:0]    twiddle_inv;
    
    logic [ExtPQLEN-1:0]            prime_intg_q;
    logic [ExtPQLEN-1:0]            prime_intg_d;
    logic                           prime_wr_en;
    
    logic [ExtPQLEN-1:0]            prime_dash_intg_q;
    logic [ExtPQLEN-1:0]            prime_dash_intg_d;
    logic                           prime_dash_wr_en;
    
    logic [ExtPQLEN-1:0]            twiddle_intg_q;
    logic [ExtPQLEN-1:0]            twiddle_intg_d;
    logic                           twiddle_wr_en;
    
    logic [ExtWLEN-1:0]             omega_intg_q;
    logic [ExtWLEN-1:0]             omega_intg_d;
    logic [BaseWordsPerPQLEN-1:0]   omega_wr_en;
    
    logic [ExtWLEN-1:0]             psi_intg_q;
    logic [ExtWLEN-1:0]             psi_intg_d;
    logic [BaseWordsPerPQLEN-1:0]   psi_wr_en;
    
    logic [ExtPQLEN:0]                     psi_idx_intg_q;
    logic [ExtPQLEN:0]                     psi_idx_intg_d;
    logic [2:0]                     psi_idx_inc;
    logic                           psi_idx_wr_en;
    logic [7:0]                     psi_onehot;
    
    logic [ExtPQLEN-1:0]            omega_idx_intg_q;
    logic [ExtPQLEN-1:0]            omega_idx_intg_d;
    logic [2:0]                     omega_idx_inc;
    logic                           omega_idx_wr_en;
    logic [7:0]                     omega_onehot;
    
    logic [ExtPQLEN-1:0]            const_intg_q;
    logic [ExtPQLEN-1:0]            const_intg_d;
    logic                           const_wr_en;
    
    
    logic [PQLEN-1:0]               psi;
    logic [PQLEN-1:0]               omega;
    
    logic [2*PQLEN-1:0]             rc;
    logic [ExtWLEN-1:0]             rc_intg_q;
    logic [ExtWLEN-1:0]             rc_intg_d;
    logic [BaseWordsPerPQLEN-1:0]   rc_wr_en;
    
    logic [ExtPQLEN-1:0]                     rc_idx_intg_q;
    logic [ExtPQLEN-1:0]                     rc_idx_intg_d;
    logic [1:0]                     rc_idx_inc;
    logic                           rc_idx_wr_en;
    
    always_comb begin
        omega = '0;
        psi = '0;
        omega_onehot = 8'b00000000;
        psi_onehot = 8'b00000000;
        
        unique case (psi_idx_no_intg_q[0+:3])
          3'd0: begin
                    psi = psi_no_intg_q[PQLEN*0+:PQLEN];
                end
          3'd1: begin
                    psi = psi_no_intg_q[PQLEN*1+:PQLEN];
                end
          3'd2: begin 
                    psi = psi_no_intg_q[PQLEN*2+:PQLEN];
                end
          3'd3: begin 
                    psi = psi_no_intg_q[PQLEN*3+:PQLEN];
                end
          3'd4: begin 
                    psi = psi_no_intg_q[PQLEN*4+:PQLEN];
                end
          3'd5: begin 
                    psi = psi_no_intg_q[PQLEN*5+:PQLEN];
                end
          3'd6: begin 
                    psi = psi_no_intg_q[PQLEN*6+:PQLEN]; 
                end 
          3'd7: begin 
                    psi = psi_no_intg_q[PQLEN*7+:PQLEN];    
                end
          default: psi = '0;
        endcase
        
        unique case (omega_idx_no_intg_q[0+:3])
          3'd0: begin
                    omega = omega_no_intg_q[PQLEN*0+:PQLEN];
                end
          3'd1: begin
                    omega = omega_no_intg_q[PQLEN*1+:PQLEN];
                end
          3'd2: begin 
                    omega = omega_no_intg_q[PQLEN*2+:PQLEN];
                end
          3'd3: begin 
                    omega = omega_no_intg_q[PQLEN*3+:PQLEN];
                end
          3'd4: begin 
                    omega = omega_no_intg_q[PQLEN*4+:PQLEN];
                end
          3'd5: begin 
                    omega = omega_no_intg_q[PQLEN*5+:PQLEN];
                end
          3'd6: begin 
                    omega = omega_no_intg_q[PQLEN*6+:PQLEN]; 
                end 
          3'd7: begin 
                    omega = omega_no_intg_q[PQLEN*7+:PQLEN];    
                end
          default: omega = '0;
        endcase
        
        unique case (rc_idx_no_intg_q[0+:2])
          2'd0: begin
                    rc = rc_no_intg_q[PQLEN*0+:2*PQLEN];
                end
          2'd1: begin
                    rc = rc_no_intg_q[PQLEN*2+:2*PQLEN];
                end
          2'd2: begin 
                    rc = rc_no_intg_q[PQLEN*4+:2*PQLEN];
                end
          2'd3: begin 
                    rc = rc_no_intg_q[PQLEN*6+:2*PQLEN];
                end
          default: rc = '0;
        endcase
        
        
        unique case (psi_idx_no_intg_q[0+:3])
            3'd0: psi_onehot = 8'b00000001;
            3'd1: psi_onehot = 8'b00000010;
            3'd2: psi_onehot = 8'b00000100;
            3'd3: psi_onehot = 8'b00001000;
            3'd4: psi_onehot = 8'b00010000;
            3'd5: psi_onehot = 8'b00100000;
            3'd6: psi_onehot = 8'b01000000;
            3'd7: psi_onehot = 8'b10000000;
            default: psi_onehot = 8'b00000000;
        endcase
        
        unique case (omega_idx_no_intg_q[0+:3])
            3'd0: omega_onehot = 8'b00000001;
            3'd1: omega_onehot = 8'b00000010;
            3'd2: omega_onehot = 8'b00000100;
            3'd3: omega_onehot = 8'b00001000;
            3'd4: omega_onehot = 8'b00010000;
            3'd5: omega_onehot = 8'b00100000;
            3'd6: omega_onehot = 8'b01000000;
            3'd7: omega_onehot = 8'b10000000;
            default: omega_onehot = 8'b00000000;
        endcase   
    end

  // Integrity Signals
  logic [PQLEN-1:0]                prime_no_intg_d;
  logic [PQLEN-1:0]                prime_no_intg_q;
  logic [ExtPQLEN-1:0]             prime_intg_calc;
  logic [1:0]                      prime_intg_err;

  logic [PQLEN-1:0]                prime_dash_no_intg_d;
  logic [PQLEN-1:0]                prime_dash_no_intg_q;
  logic [ExtPQLEN-1:0]             prime_dash_intg_calc;
  logic [1:0]                      prime_dash_intg_err;

  logic [PQLEN-1:0]                twiddle_no_intg_d;
  logic [PQLEN-1:0]                twiddle_no_intg_q;
  logic [ExtPQLEN-1:0]             twiddle_intg_calc;
  logic [1:0]                      twiddle_intg_err;

  logic [WLEN-1:0]                omega_no_intg_d;
  logic [WLEN-1:0]                omega_no_intg_q;
  logic [ExtWLEN-1:0]             omega_intg_calc;
  logic [2*BaseWordsPerWLEN-1:0]  omega_intg_err;

  logic [WLEN-1:0]                psi_no_intg_d;
  logic [WLEN-1:0]                psi_no_intg_q;
  logic [ExtWLEN-1:0]             psi_intg_calc;
  logic [2*BaseWordsPerWLEN-1:0]  psi_intg_err;

  logic [PQLEN-1:0]                const_no_intg_d;
  logic [PQLEN-1:0]                const_no_intg_q;
  logic [ExtPQLEN-1:0]             const_intg_calc;
  logic [1:0]                      const_intg_err;

  logic [WLEN-1:0]                rc_no_intg_d;
  logic [WLEN-1:0]                rc_no_intg_q;
  logic [ExtWLEN-1:0]             rc_intg_calc;
  logic [2*BaseWordsPerWLEN-1:0]  rc_intg_err;

  logic [PQLEN-1:0]                omega_idx_no_intg_d;
  logic [PQLEN-1:0]                omega_idx_no_intg_q;
  logic [ExtPQLEN-1:0]             omega_idx_intg_calc;
  logic [1:0]                      omega_idx_intg_err;

  logic [PQLEN-1:0]                psi_idx_no_intg_d;
  logic [PQLEN-1:0]                psi_idx_no_intg_q;
  logic [ExtPQLEN-1:0]             psi_idx_intg_calc;
  logic [1:0]                      psi_idx_intg_err;

  logic [PQLEN-1:0]                rc_idx_no_intg_d;
  logic [PQLEN-1:0]                rc_idx_no_intg_q;
  logic [ExtPQLEN-1:0]             rc_idx_intg_calc;
  logic [1:0]                      rc_idx_intg_err;

  // Blanking for Update Twiddle
  logic [PQLEN-1:0] upd_twiddle_op_a_blanked;
  logic [PQLEN-1:0] upd_twiddle_op_b_blanked;

  // SEC_CM: DATA_REG_SW.SCA
  prim_blanker #(.Width(PQLEN)) u_upd_twiddle_operand_a_blanker (
    .in_i (twiddle_intg_q),
    .en_i (trcu_predec_pq_i.mul_twiddle_op_en),
    .out_o(upd_twiddle_op_a_blanked)
  );

  // SEC_CM: DATA_REG_SW.SCA
  prim_blanker #(.Width(PQLEN)) u_upd_twiddle_operand_b_blanker (
    .in_i (omega),
    .en_i (trcu_predec_pq_i.mul_twiddle_op_en),
    .out_o(upd_twiddle_op_b_blanked)
  );

    otbn_multiplier #(.DATA_WIDTH(PQLEN), .LOG_R(LOG_R)) U_UPDATE_TWIDDLE(
        .op0_i(upd_twiddle_op_a_blanked),
        .op1_i(upd_twiddle_op_b_blanked),
        .q_i(prime_no_intg_q),
        .q_dash_i(prime_dash_no_intg_q),
        .res_o(twiddle_mul)  
    ); 
    // Blanking for Update Omega
    logic [PQLEN-1:0] upd_omega_op_blanked;

    // SEC_CM: DATA_REG_SW.SCA
    prim_blanker #(.Width(PQLEN)) u_upd_omega_operand_b_blanker (
      .in_i (omega),
      .en_i (trcu_predec_pq_i.mul_omega_op_en),
      .out_o(upd_omega_op_blanked)
    );

    otbn_multiplier #(.DATA_WIDTH(PQLEN), .LOG_R(LOG_R)) U_UPDATE_OMEGA(
        .op0_i(upd_omega_op_blanked),
        .op1_i(upd_omega_op_blanked),
        .q_i(prime_no_intg_q),
        .q_dash_i(prime_dash_no_intg_q),
        .res_o(omega_mul)  
    );   


    // Blanking for Update Twiddle
    logic [PQLEN-1:0] inv_twiddle_op_a_blanked;
    logic [PQLEN-1:0] inv_twiddle_op_b_blanked;

    // SEC_CM: DATA_REG_SW.SCA
    prim_blanker #(.Width(PQLEN)) u_inv_twiddle_operand_a_blanker (
      .in_i (prime_no_intg_q),
      .en_i (trcu_predec_pq_i.sub_op_en),
      .out_o(inv_twiddle_op_a_blanked)
    );

    // SEC_CM: DATA_REG_SW.SCA
    prim_blanker #(.Width(PQLEN)) u_inv_twiddle_operand_b_blanker (
      .in_i (twiddle_intg_q),
      .en_i (trcu_predec_pq_i.sub_op_en),
      .out_o(inv_twiddle_op_b_blanked)
    );

    assign twiddle_inv = inv_twiddle_op_a_blanked - inv_twiddle_op_b_blanked;


  // Prime Register

    prim_secded_inv_39_32_enc i_secded_enc (
      .data_i (prime_no_intg_d),
      .data_o (prime_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec (
      .data_i     (prime_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (prime_intg_err)
    );
    assign prime_no_intg_q = prime_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (prime_wr_en) begin
            prime_intg_q <= prime_intg_d;
        end
    end

    always_comb begin
      prime_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: prime_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            prime_no_intg_d = ispr_base_wdata_i[0+:PQLEN];
            prime_intg_d = prime_intg_calc;
          end
          ispr_pq_wr_en_i: begin
            prime_no_intg_d = ispr_pq_wdata_i[0+:PQLEN];
            prime_intg_d = prime_intg_calc;            
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))
    assign prime_wr_en = ispr_init_i |
                         ((ispr_addr_i == IsprPrime) & (ispr_base_wr_en_i[0] | ispr_pq_wr_en_i));



    // Prime Dash Register
    prim_secded_inv_39_32_enc i_secded_enc_prime_dash (
      .data_i (prime_dash_no_intg_d),
      .data_o (prime_dash_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_prime_dash (
      .data_i     (prime_dash_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (prime_dash_intg_err)
    );
    assign prime_dash_no_intg_q = prime_dash_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (prime_dash_wr_en) begin
            prime_dash_intg_q <= prime_dash_intg_d;
        end
    end

    always_comb begin
      prime_dash_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: prime_dash_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            prime_dash_no_intg_d = ispr_base_wdata_i[0+:PQLEN];
            prime_dash_intg_d = prime_dash_intg_calc;
          end
          ispr_pq_wr_en_i: begin
            prime_dash_no_intg_d = ispr_pq_wdata_i[0+:PQLEN];
            prime_dash_intg_d = prime_dash_intg_calc;            
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))

    assign prime_dash_wr_en = ispr_init_i |
                              ((ispr_addr_i == IsprPrimeDash) & (ispr_base_wr_en_i[0] | ispr_pq_wr_en_i));


    // Twiddle Register
    prim_secded_inv_39_32_enc i_secded_enc_twiddle (
      .data_i (twiddle_no_intg_d),
      .data_o (twiddle_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_twiddle (
      .data_i     (twiddle_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (twiddle_intg_err)
    );
    assign twiddle_no_intg_q = twiddle_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (twiddle_wr_en) begin
            twiddle_intg_q <= twiddle_intg_d;
        end
    end

    always_comb begin
      twiddle_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: twiddle_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            twiddle_no_intg_d = ispr_base_wdata_i[0+:PQLEN];
            twiddle_intg_d = twiddle_intg_calc;
          end
          ispr_pq_wr_en_i: begin
            twiddle_no_intg_d = ispr_pq_wdata_i[0+:PQLEN];
            twiddle_intg_d = twiddle_intg_calc;            
          end
          update_twiddle_i : begin
            twiddle_no_intg_d = twiddle_mul[0+:PQLEN];
            twiddle_intg_d = twiddle_intg_calc;    
          end
          invert_twiddle_i: begin
            twiddle_no_intg_d = twiddle_inv[0+:PQLEN];
            twiddle_intg_d = twiddle_intg_calc;    
          end
          set_twiddle_as_psi_i: begin
            twiddle_no_intg_d = psi[0+:PQLEN];
            twiddle_intg_d = twiddle_intg_calc;    
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))

    assign twiddle_wr_en = ispr_init_i |
                           update_twiddle_i | 
                           invert_twiddle_i | 
                           set_twiddle_as_psi_i |
                           ((ispr_addr_i == IsprTwiddle) & (ispr_base_wr_en_i[0] | ispr_pq_wr_en_i));


    // Omega Register

    for (genvar i_word = 0; i_word < BaseWordsPerPQLEN; i_word++) begin : g_omega_words
      prim_secded_inv_39_32_enc i_secded_enc (
        .data_i (omega_no_intg_d[i_word*32+:32]),
        .data_o (omega_intg_calc[i_word*39+:39])
      );
      prim_secded_inv_39_32_dec i_secded_dec (
        .data_i     (omega_intg_q[i_word*39+:39]),
        .data_o     (/* unused because we abort on any integrity error */),
        .syndrome_o (/* unused */),
        .err_o      (omega_intg_err[i_word*2+:2])
      );
      assign omega_no_intg_q[i_word*32+:32] = omega_intg_q[i_word*39+:32];

      always_ff @(posedge clk_i) begin
        if (omega_wr_en[i_word]) begin
          omega_intg_q[i_word*39+:39] <= omega_intg_d[i_word*39+:39];
        end
      end

      always_comb begin
        omega_no_intg_d[i_word*32+:32] = '0;

        unique case (1'b1)
            ispr_init_i: omega_intg_d[i_word*32+:32] = EccZeroWord; 
            ispr_base_wr_en_i[i_word]: begin
              omega_no_intg_d[i_word*32+:32] = ispr_base_wdata_i;
              omega_intg_d[i_word*39+:39]  = omega_intg_calc[i_word*39+:39] ;
            end
            ispr_pq_wr_en_i: begin
              omega_no_intg_d[i_word*32+:32] = ispr_pq_wdata_i[i_word*32+:32];
              omega_intg_d[i_word*39+:39]  = omega_intg_calc[i_word*39+:39] ;            
            end
            update_omega_i : begin
              omega_no_intg_d[i_word*32+:32] = omega_mul;
              omega_intg_d[i_word*39+:39]  = omega_intg_calc[i_word*39+:39] ;    
            end
          default: ;
        endcase
      end

    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))

        assign omega_wr_en[i_word] = ispr_init_i |
                                     (omega_onehot[i_word] & update_omega_i) | 
                                     ((ispr_addr_i == IsprOmega) & (ispr_base_wr_en_i[i_word] | ispr_pq_wr_en_i));
    end


    // Psi Register
    for (genvar i_word = 0; i_word < BaseWordsPerPQLEN; i_word++) begin : g_psi_words
      prim_secded_inv_39_32_enc i_secded_enc (
        .data_i (psi_no_intg_d[i_word*32+:32]),
        .data_o (psi_intg_calc[i_word*39+:39])
      );
      prim_secded_inv_39_32_dec i_secded_dec (
        .data_i     (psi_intg_q[i_word*39+:39]),
        .data_o     (/* unused because we abort on any integrity error */),
        .syndrome_o (/* unused */),
        .err_o      (psi_intg_err[i_word*2+:2])
      );
      assign psi_no_intg_q[i_word*32+:32] = psi_intg_q[i_word*39+:32];

      always_ff @(posedge clk_i) begin
        if (psi_wr_en[i_word]) begin
          psi_intg_q[i_word*39+:39] <= psi_intg_d[i_word*39+:39];
        end
      end

      always_comb begin
        psi_no_intg_d[i_word*32+:32] = '0;

        unique case (1'b1)
            ispr_init_i: psi_intg_d[i_word*32+:32] = EccZeroWord; 
            ispr_base_wr_en_i[i_word]: begin
              psi_no_intg_d[i_word*32+:32] = ispr_base_wdata_i;
              psi_intg_d[i_word*39+:39]  = psi_intg_calc[i_word*39+:39] ;
            end
            ispr_pq_wr_en_i: begin
              psi_no_intg_d[i_word*32+:32] = ispr_pq_wdata_i[i_word*32+:32];
              psi_intg_d[i_word*39+:39]  = psi_intg_calc[i_word*39+:39] ;            
            end
            update_psi_i : begin
              psi_no_intg_d[i_word*32+:32] = omega;
              psi_intg_d[i_word*39+:39]  = psi_intg_calc[i_word*39+:39] ;    
            end
          default: ;
        endcase
      end
        
        //TODO Enable ASSERTs
        //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))
    
        assign psi_wr_en[i_word] = ispr_init_i |
                                   (psi_onehot[i_word] & update_psi_i) | 
                                   ((ispr_addr_i == IsprPsi) & (ispr_base_wr_en_i[i_word] | ispr_pq_wr_en_i));
    end

    // Omega Idx Register
    prim_secded_inv_39_32_enc i_secded_enc_omega_idx (
      .data_i (omega_idx_no_intg_d),
      .data_o (omega_idx_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_omega_idx (
      .data_i     (omega_idx_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (omega_idx_intg_err)
    );
    assign omega_idx_no_intg_q = omega_idx_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (omega_idx_wr_en) begin
            omega_idx_intg_q <= omega_idx_intg_d;
        end
    end

    assign omega_idx_inc = omega_idx_no_intg_q[0+:3] + 1;

    always_comb begin
      omega_idx_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: omega_idx_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            omega_idx_no_intg_d = {29'b0,ispr_base_wdata_i[0+:3]};
            omega_idx_intg_d = omega_idx_intg_calc;
          end
          ispr_pq_wr_en_i: begin
            omega_idx_no_intg_d = {29'b0,ispr_pq_wdata_i[0+:3]};
            omega_idx_intg_d = omega_idx_intg_calc;            
          end
          omega_idx_inc_i: begin
            omega_idx_no_intg_d = {29'b0,omega_idx_inc[0+:3]};
            omega_idx_intg_d = omega_idx_intg_calc;              
          end
        default: ;
      endcase
    end  
        
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))
    
    assign omega_idx_wr_en = ispr_init_i |
                             omega_idx_inc_i | 
                             ((ispr_addr_i == IsprOmegaIdx) & (ispr_base_wr_en_i[0] | ispr_pq_wr_en_i));
    
    
    // Psi Idx Register
    prim_secded_inv_39_32_enc i_secded_enc_psi_idx (
      .data_i (psi_idx_no_intg_d),
      .data_o (psi_idx_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_psi_idx (
      .data_i     (psi_idx_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (psi_idx_intg_err)
    );
    assign psi_idx_no_intg_q = psi_idx_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (psi_idx_wr_en) begin
            psi_idx_intg_q <= psi_idx_intg_d;
        end
    end

    assign psi_idx_inc = psi_idx_no_intg_q[0+:3] + 1;

    always_comb begin
      psi_idx_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: psi_idx_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            psi_idx_no_intg_d = {29'b0,ispr_base_wdata_i[0+:3]};
            psi_idx_intg_d = psi_idx_intg_calc;
          end
          ispr_pq_wr_en_i: begin
            psi_idx_no_intg_d = {29'b0,ispr_pq_wdata_i[0+:3]};
            psi_idx_intg_d = psi_idx_intg_calc;            
          end
          psi_idx_inc_i: begin
            psi_idx_no_intg_d = {29'b0,psi_idx_inc[0+:3]};
            psi_idx_intg_d = psi_idx_intg_calc;              
          end
        default: ;
      endcase
    end  
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))
    
    assign psi_idx_wr_en = ispr_init_i |
                           psi_idx_inc_i | 
                           ((ispr_addr_i == IsprPsiIdx) & (ispr_base_wr_en_i[0] | ispr_pq_wr_en_i));


    // Const Register
    prim_secded_inv_39_32_enc i_secded_enc_const (
      .data_i (const_no_intg_d),
      .data_o (const_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_const (
      .data_i     (const_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (const_intg_err)
    );
    assign const_no_intg_q = const_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (const_wr_en) begin
            const_intg_q <= const_intg_d;
        end
    end

    always_comb begin
      const_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: const_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            const_no_intg_d = ispr_base_wdata_i[0+:PQLEN];
            const_intg_d = const_intg_calc;
          end
          ispr_pq_wr_en_i: begin
            const_no_intg_d = ispr_pq_wdata_i[0+:PQLEN];
            const_intg_d = const_intg_calc;            
          end
        default: ;
      endcase
    end
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))

    assign const_wr_en = ispr_init_i |
                         ((ispr_addr_i == IsprConst) & (ispr_base_wr_en_i[0] | ispr_pq_wr_en_i));


    // RC Register
    for (genvar i_word = 0; i_word < BaseWordsPerPQLEN; i_word++) begin : g_rc_words
      prim_secded_inv_39_32_enc i_secded_enc (
        .data_i (rc_no_intg_d[i_word*32+:32]),
        .data_o (rc_intg_calc[i_word*39+:39])
      );
      prim_secded_inv_39_32_dec i_secded_dec (
        .data_i     (rc_intg_q[i_word*39+:39]),
        .data_o     (/* unused because we abort on any integrity error */),
        .syndrome_o (/* unused */),
        .err_o      (rc_intg_err[i_word*2+:2])
      );
      assign rc_no_intg_q[i_word*32+:32] = rc_intg_q[i_word*39+:32];

      always_ff @(posedge clk_i) begin
        if (rc_wr_en[i_word]) begin
          rc_intg_q[i_word*39+:39] <= rc_intg_d[i_word*39+:39];
        end
      end

      always_comb begin
        rc_no_intg_d[i_word*32+:32] = '0;

        unique case (1'b1)
            ispr_init_i: rc_intg_d[i_word*32+:32] = EccZeroWord; 
            ispr_base_wr_en_i[i_word]: begin
              rc_no_intg_d[i_word*32+:32] = ispr_base_wdata_i;
              rc_intg_d[i_word*39+:39]  = rc_intg_calc[i_word*39+:39] ;
            end
            ispr_pq_wr_en_i: begin
              rc_no_intg_d[i_word*32+:32] = ispr_pq_wdata_i[i_word*32+:32];
              rc_intg_d[i_word*39+:39]  = rc_intg_calc[i_word*39+:39] ;            
            end
          default: ;
        endcase
      end
        
        //TODO Enable ASSERTs
        //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))
    
        assign rc_wr_en[i_word] = ispr_init_i |
                                  ((ispr_addr_i == IsprRc) & (ispr_base_wr_en_i[i_word] | ispr_pq_wr_en_i));
    end

    // RC Idx Register
    prim_secded_inv_39_32_enc i_secded_enc_rc_idx (
      .data_i (rc_idx_no_intg_d),
      .data_o (rc_idx_intg_calc)
    );
    prim_secded_inv_39_32_dec i_secded_dec_rc_idx (
      .data_i     (rc_idx_intg_q),
      .data_o     (/* unused because we abort on any integrity error */),
      .syndrome_o (/* unused */),
      .err_o      (rc_idx_intg_err)
    );
    assign rc_idx_no_intg_q = rc_idx_intg_q[PQLEN-1:0];    

    always_ff @(posedge clk_i) begin
        if (rc_idx_wr_en) begin
            rc_idx_intg_q <= rc_idx_intg_d;
        end
    end

    assign rc_idx_inc = rc_idx_no_intg_q[0+:2] + 1;

    always_comb begin
      rc_idx_no_intg_d = '0;

      unique case (1'b1)
          ispr_init_i: rc_idx_intg_d = EccZeroWord; 
          ispr_base_wr_en_i[0]: begin
            rc_idx_no_intg_d = {30'b0,ispr_base_wdata_i[0+:2]};
            rc_idx_intg_d = rc_idx_intg_calc;
          end
          ispr_pq_wr_en_i: begin
            rc_idx_no_intg_d = {30'b0,ispr_pq_wdata_i[0+:2]};
            rc_idx_intg_d = rc_idx_intg_calc;            
          end
          rc_idx_inc_i: begin
            rc_idx_no_intg_d = {30'b0,rc_idx_inc[0+:2]};
            rc_idx_intg_d = rc_idx_intg_calc;              
          end
        default: ;
      endcase
    end  
    
    //TODO Enable ASSERTs
    //`ASSERT(ModWrSelOneHot, $onehot0({ispr_init_i, ispr_base_wr_en_i[i_word]}))
    
    assign rc_idx_wr_en = ispr_init_i |
                          rc_idx_inc_i | 
                          ((ispr_addr_i == IsprRcIdx) & (ispr_base_wr_en_i[0] | ispr_pq_wr_en_i));

    
    assign psi_o        = psi; 
    assign twiddle_o    = twiddle_no_intg_q;
    assign omega_o      = omega;
    assign prime_o      = prime_no_intg_q;
    assign prime_dash_o = prime_dash_no_intg_q;
    assign const_o      = const_no_intg_q;
    assign rc_o         = rc;
    
    always_comb begin
        ispr_rdata_o = {224'b0, prime_no_intg_q};
        
        unique case (ispr_addr_i)
            IsprPrime:        ispr_rdata_o = {224'b0, prime_no_intg_q};
            IsprPrimeDash:    ispr_rdata_o = {224'b0, prime_dash_no_intg_q};
            IsprTwiddle:      ispr_rdata_o = {224'b0, twiddle_no_intg_q};
            IsprOmega:        ispr_rdata_o = omega_no_intg_q;
            IsprPsi:          ispr_rdata_o = psi_no_intg_q;
            IsprOmegaIdx:     ispr_rdata_o = {253'b0, omega_idx_no_intg_q[0+:3]};
            IsprPsiIdx:       ispr_rdata_o = {253'b0, psi_idx_no_intg_q[0+:3]};
            IsprConst:        ispr_rdata_o = {224'b0, const_no_intg_q};
            IsprRc:           ispr_rdata_o = rc_no_intg_q;
            IsprRcIdx:        ispr_rdata_o = {254'b0, rc_idx_no_intg_q[0+:2]};
            default: ;
        endcase
    end


endmodule: otbn_twiddle_update
