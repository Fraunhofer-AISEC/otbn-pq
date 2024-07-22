// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


package otbn_pq_pkg;

  import otbn_pkg::*;


  // Global Constants ==============================================================================
    
  // Data path width for PQ instructions, in bits.
  parameter int PQLEN = 32;
  
  // Number of 32-bit words per WLEN
  parameter int BaseWordsPerPQLEN = 8*PQLEN / 32;
    
  //
  parameter int LOG_R = 32;
    
  // "Extended" PQLEN: the size of the datapath with added integrity bits
  parameter int ExtPQLEN = PQLEN * 39 / 32;



  typedef enum logic {
    InsnSubsetBasePq = 1'b0,  // Base (RV32/Narrow) Instruction Subset
    InsnSubsetPq     = 1'b1   // PQ (BN/Wide) Instruction Subset
  } insn_subset_pq_e;


  typedef struct packed {
    insn_subset_pq_e    subset;
    logic               br_insn;
    logic   [3:0]       br_nof_bits;
    
    logic               sl_j2;
    logic               sl_m;
    logic               inc_j;
    logic               inc_idx;
    logic               set_idx;
    
    logic               ispr_rd_insn;
    logic               ispr_wr_insn;
    logic               ispr_rs_insn;

    logic               ictrlspr_rd_insn;
    logic               ictrlspr_wr_insn;
    logic               ictrlspr_rs_insn;
    
    logic               update_omega;
    logic               update_psi;
    logic               set_twiddle_as_psi;
    logic               update_twiddle;
    logic               invert_twiddle;
    logic               omega_idx_inc;
    logic               psi_idx_inc;
        
    logic               inc_x;
    logic               inc_y;
    
    logic               rc_idx_inc;
  } insn_dec_shared_pq_t;


  // Regfile write data selection
  typedef enum logic [2:0] {
    RfWdSelExPq,
    RfWdSelExInPlacePq,
    RfWdSelIsprPq,
    RfWdSelIsprPqCtrl,
    RfWdSelExKeccakLanePq,
    RfWdSelExKeccakPlaneInPlacePq
  } rf_wd_pq_sel_e;


  // {sel_gs_subtractor, sel_ct_mux0,sel_ct_mux1, sel_twiddle, sel_scale, sel_forward_rs0, sel_forward_rs1, sel_rd }
  typedef enum logic [7:0] {
    AluOpPqAdd          = 8'h42,
    AluOpPqSub          = 8'h27,
    AluOpPqMul          = 8'h01,
    AluOpPqScale        = 8'h09,
    AluOpPqButterflyCT  = 8'h74,
    AluOpPqButterflyGS  = 8'hD2
  } alu_op_pq_e;

  // {ioata, rot}
  typedef enum logic [1:0] {
    KeccakLaneOpXOR     = 2'b00,
    KeccakLaneOpXORR    = 2'b01,
    KeccakLaneOpXORi    = 2'b10
  } keccak_lane_op_pq_e;  

  // {chi}
  typedef enum logic {
    KeccakPlaneOpParity = 1'b0,
    KeccakPlaneOpChi    = 1'b1
  } keccak_plane_op_pq_e; 
  
  typedef struct packed {
    alu_op_pq_e             op;
    logic   [WLEN-1:0]      operand_a;
    logic   [WLEN-1:0]      operand_b;
    logic   [PQLEN-1:0]     prime;
    logic   [LOG_R-1:0]     prime_dash;
    logic   [PQLEN-1:0]     twiddle;
    logic   [PQLEN-1:0]     scale;
    logic   [PQLEN-1:0]     imm; 
    logic   [2:0]           operand_a_w_sel;
    logic   [2:0]           operand_b_w_sel; 
    logic   [2:0]           d_w_sel;
    logic                   imm_sel;
  } alu_pq_operation_t;

  typedef struct packed {
    keccak_lane_op_pq_e     op;
    logic   [WLEN-1:0]      operand_a;
    logic   [WLEN-1:0]      operand_b;
    logic   [63:0]          rc;
    logic   [2:0]           x;
    logic   [2:0]           y;
    logic   [1:0]           operand_a_w_sel;
    logic   [1:0]           operand_b_w_sel; 
    logic   [1:0]           d_w_sel;
  } keccak_lane_operation_t;

  typedef struct packed {
    keccak_plane_op_pq_e    op;
    logic   [WLEN-1:0]      operand_a;
    logic   [WLEN-1:0]      operand_b;
  } keccak_plane_operation_t;

  typedef enum logic {
    BitrevOpPq          = 1'b0,
    BitrevOpPqShift     = 1'b1
  } bitrev_op_pq_e;

  typedef struct packed {
    bitrev_op_pq_e          op;
    logic   [PQLEN-1:0]     operand_a;
    logic   [3:0]           nof_bits;    
  } bitrev_pq_operation_t;
    

  parameter int NPqspr = 10;
  parameter int PqsprNumWidth = $clog2(NPqspr);
  typedef enum logic [PqsprNumWidth-1:0] {
    PqsrPrime       = 'd0,
    PqsrPrimeDash   = 'd1,
    PqsrTwiddle     = 'd2,
    PqsrOmega       = 'd3,
    PqsrPsi         = 'd4,
    PqsrOmegaIdx    = 'd5,
    PqsrPsiIdx      = 'd6,
    PqsrConst       = 'd7,
    PqsrRc          = 'd8,
    PqsrRcIdx       = 'd9
  } pqspr_e;

  parameter int PqctrlsprNumWidth = 8;
  typedef enum logic [PqctrlsprNumWidth-1:0] {
    PqctrlsrM           = 'h00,
    PqctrlsrJ2          = 'h01,
    PqctrlsrJ           = 'h02,
    PqctrlsrIdx0        = 'h03,
    PqctrlsrIdx1        = 'h04,
    PqctrlsrMode        = 'h05,
    PqctrlsrX           = 'h06,
    PqctrlsrY           = 'h07,
    PqctrlsrPrime       = 'h10,
    PqctrlsrPrimeDash   = 'h20,
    PqctrlsrTwiddle     = 'h30,
    PqctrlsrOmega0      = 'h40,
    PqctrlsrOmega1      = 'h41,
    PqctrlsrOmega2      = 'h42,
    PqctrlsrOmega3      = 'h43,
    PqctrlsrOmega4      = 'h44,
    PqctrlsrOmega5      = 'h45,
    PqctrlsrOmega6      = 'h46,    
    PqctrlsrOmega7      = 'h47,
    PqctrlsrPsi0        = 'h50,
    PqctrlsrPsi1        = 'h51,
    PqctrlsrPsi2        = 'h52,
    PqctrlsrPsi3        = 'h53,
    PqctrlsrPsi4        = 'h54,
    PqctrlsrPsi5        = 'h55,
    PqctrlsrPsi6        = 'h56,
    PqctrlsrPsi7        = 'h57,    
    PqctrlsrOmegaIdx    = 'h60,
    PqctrlsrPsiIdx      = 'h70,
    PqctrlsrConst       = 'h80,
    PqctrlsrRc0         = 'hA0,
    PqctrlsrRc1         = 'hA1,
    PqctrlsrRc2         = 'hA2,
    PqctrlsrRc3         = 'hA3,
    PqctrlsrRc4         = 'hA4,
    PqctrlsrRc5         = 'hA5,
    PqctrlsrRc6         = 'hA6,
    PqctrlsrRc7         = 'hA7,
    PqctrlsrRcIdx       = 'hB0
  } pqctrlspr_e;
  
  // Internal Post-Quantum Special Purpose Registers (IPQSPRs)
  // CSRs and PQSRs might have some overlap in the future into what they map into. IPQSPRs are the actual registers in the
  // design which CSRs and PQSRs are mapped on to.
  parameter int Nipqspr = 18;
  parameter int IpqsprNumWidth = $clog2(Nipqspr);
  typedef enum logic [IpqsprNumWidth-1:0] {
    IsprPrime       = 'd0,
    IsprPrimeDash   = 'd1,
    IsprTwiddle     = 'd2,
    IsprOmega       = 'd3,
    IsprPsi         = 'd4,
    IsprOmegaIdx    = 'd5,
    IsprPsiIdx      = 'd6,
    IsprConst       = 'd7,
    IsprM           = 'd8,
    IsprJ2          = 'd9,
    IsprJ           = 'd10,
    IsprIdx0        = 'd11,
    IsprIdx1        = 'd12,
    IsprMode        = 'd13,
    IsprX           = 'd14,
    IsprY           = 'd15,
    IsprRc          = 'd16,
    IsprRcIdx       = 'd17    
  } ipqspr_e;



  typedef struct packed {
    logic [WdrAw-1:0]        d;           // Destination register
    logic [WdrAw-1:0]        a;           // First source register
    logic [WdrAw-1:0]        b;           // Second source register
    
    logic [PQLEN-1:0]        imm;
    
    logic [PqsprNumWidth-1:0]            pqsr_addr;   // PQSR Address
    logic [PqctrlsprNumWidth-1:0]        pqctrlsr_addr;   // PQSR Address
    
    alu_op_pq_e              alu_op;
    keccak_lane_op_pq_e      keccak_lane_op;
    keccak_plane_op_pq_e     keccak_plane_op;
    
    op_b_sel_e               alu_op_b_sel;

    logic [2:0]              pq_op_a_w_sel;
    logic [2:0]              pq_op_b_w_sel;
    logic [2:0]              pq_d_w_sel;
    
    logic [7:0]              pq_wr_w_sel_a;
    logic [7:0]              pq_wr_w_sel_b;
    logic [7:0]              pq_wr_w_sel_d;
    
    logic                    pq_in_place;
    logic                    operands_indirect;
    logic                    use_const;
    logic                    use_imm;
     
    logic                    rf_we;
    rf_wd_pq_sel_e           rf_wdata_sel;
    
    logic                    rf_ren_a;
    logic                    rf_ren_b;

    logic                    sel_insn;
    
  } insn_dec_pq_t;


  typedef struct packed {
    logic gs_sub_op_en;
    logic ct_sub_op_en;
    logic mul_op_en;
    logic add_op_en;
  } alu_predec_pq_t;

  typedef struct packed {
    logic sub_op_en;
    logic mul_omega_op_en;
    logic mul_twiddle_op_en;
  } trcu_predec_pq_t;

endpackage
