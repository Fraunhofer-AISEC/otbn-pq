`timescale 1ns / 1ps

// Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module tb_otbn

    import prim_alert_pkg::*;
    import otbn_pkg::*;
    import otbn_reg_pkg::*;
    import tb_tl_ul_pkg::*;

    (
    
    );
    
    // Parameter
    localparam bit                   Stub         = 1'b0;
    localparam regfile_e             RegFile      = RegFileFF;
    localparam logic [NumAlerts-1:0] AlertAsyncOn = {NumAlerts{1'b0}};
    
    // Default seed and permutation for URND LFSR
    localparam urnd_prng_seed_t RndCnstUrndPrngSeed = RndCnstUrndPrngSeedDefault; 
     
    localparam string                 log_path = "/home/t_stelzer/projects/TUM/dilithium-on-open-titan/hw/vendor/aisec_otbn_pq/dv/sv/log/";
    localparam string                 mem_path = "/home/t_stelzer/projects/TUM/dilithium-on-open-titan/hw/vendor/aisec_otbn_pq/dv/sv/mem/";
    
    // Filehandle, clock cycle counter, readback data variable, teststate
    integer                                     f;   
    integer                                     cc;
    integer                                     cc_start;
    integer                                     cc_stop;
    integer                                     cc_count_dilithium;
    integer                                     cc_count_kyber;
    
    integer                                     cc_count_dilithium_indirect;
    integer                                     cc_count_kyber_indirect;
    
    integer                                     cc_count_dilithium_inv;
    integer                                     cc_count_kyber_inv;    
    
    integer                                     cc_count_dilithium_inv_indirect;
    integer                                     cc_count_kyber_inv_indirect;    
 
    integer                                     cc_count_falcon512_indirect;
    integer                                     cc_count_falcon1024_indirect;

    integer                                     cc_count_falcon512_inv_indirect;
    integer                                     cc_count_falcon1024_inv_indirect;

    integer                                     cc_count_dilithium_pointwise_mul;
    integer                                     cc_count_kyber_base_mul;
    integer                                     cc_count_falcon512_pointwise_mul;
    integer                                     cc_count_falcon1024_pointwise_mul;

    integer                                     cc_count_keccak;
    integer                                     cc_count_shake128;
    integer                                     cc_count_shake256;
    integer                                     cc_count_sampleinball;
    integer                                     cc_count_poly_uniform;

    integer                                     cc_count_usehint2;
    integer                                     cc_count_poly_usehint2;
    integer                                     cc_count_packw12;

    integer                                     cc_count_usehint35;
    integer                                     cc_count_poly_usehint35;
    integer                                     cc_count_packw135;

    integer                                     cc_count_dilithium_2;
    integer                                     cc_count_dilithium_3;
    integer                                     cc_count_dilithium_5;

    logic                       [31:0]          rdbk;
    string                                      teststate;  
    integer                                     error_count;
    
    // Clock and Reset
    logic                                       clk_i;
    logic                                       rst_ni;

    // Bus Signals    
    tlul_pkg::tl_h2d_t                          tl_i_d,tl_i_q;
    tlul_pkg::tl_d2h_t                          tl_o;
    logic                                       err_tl;
       
    // Inter-module signals
    prim_mubi_pkg::mubi4_t                      idle_o;
    
    // Interrupts
    logic                                       intr_done_o;
    
    // Alerts
    prim_alert_pkg::alert_rx_t [NumAlerts-1:0] alert_rx_i;
    prim_alert_pkg::alert_tx_t [NumAlerts-1:0] alert_tx_o;
    
    // Memory configuration
    prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_i;

    
    // EDN clock and interface
    logic                                       clk_edn_i;
    logic                                       rst_edn_ni;
    
    edn_pkg::edn_req_t                          edn_rnd_o;
    edn_pkg::edn_rsp_t                          edn_rnd_i;
    
    edn_pkg::edn_req_t                          edn_urnd_o;
    edn_pkg::edn_rsp_t                          edn_urnd_i;
    
    lc_ctrl_pkg::lc_tx_t                        lc_rma_req_i,lc_escalate_en_i;   
    
    
    // DUT   
    otbn #(.Stub(Stub),
        .RegFile(RegFile),
        .AlertAsyncOn(AlertAsyncOn),
        
        // Default seed and permutation for URND LFSR
        .RndCnstUrndPrngSeed(RndCnstUrndPrngSeed),
        .RndCnstOtbnKey(RndCnstOtbnKeyDefault),
        .RndCnstOtbnNonce(RndCnstOtbnNonceDefault))
    DUT (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        
        .tl_i(tl_i_q),
        .tl_o(tl_o),
        
          // Inter-module signals
        .idle_o(idle_o),
        
          // Interrupts
        .intr_done_o(intr_done_o),
        
          // Alerts
        .alert_rx_i(alert_rx_i),
        .alert_tx_o(alert_tx_o),

         // Lifecycle interfaces
         .lc_escalate_en_i(lc_escalate_en_i),

         .lc_rma_req_i(lc_rma_req_i),
         .lc_rma_ack_o(),
        
          // Memory configuration
        .ram_cfg_i(ram_cfg_i),
        
          // EDN clock and interface
        .clk_edn_i(clk_edn_i),
        .rst_edn_ni(rst_edn_ni),
        .edn_rnd_o(edn_rnd_o),
        .edn_rnd_i(edn_rnd_i),
        
        .edn_urnd_o(edn_urnd_o),
        .edn_urnd_i(edn_urnd_i),
          // Key request to OTP (running on clk_fixed)
        .clk_otp_i(clk_edn_i),
        .rst_otp_ni(rst_edn_ni),
        .otbn_otp_key_o(),
        .otbn_otp_key_i('b0),

        .keymgr_key_i('b0)
        
    );
    
    // Clock Generation
    initial begin 
        clk_i = 0;

        forever begin
            #1 clk_i = ~clk_i;

        end
    end
    
    initial begin 

        cc = 0;
        forever begin
            @(posedge clk_i) ;
            cc = cc + 1;
        end
    end    
    
    initial begin 
        clk_edn_i = 0;
        forever begin
            #1 clk_edn_i = ~clk_edn_i;
        end
    end



    
    // EDN Response Generation
    
    always_ff @ (posedge clk_edn_i)
        begin
            edn_urnd_i = edn_pkg::EDN_RSP_DEFAULT;
            edn_rnd_i = edn_pkg::EDN_RSP_DEFAULT; 
            
            if (edn_urnd_o.edn_req == 1'b1)
                begin
                    edn_urnd_i.edn_ack = edn_urnd_o.edn_req;
                    edn_urnd_i.edn_bus = $urandom();
                end
                
            if (edn_rnd_o.edn_req == 1'b1)
                begin
                    edn_rnd_i.edn_ack = edn_rnd_o.edn_req;
                    edn_rnd_i.edn_bus = $urandom();
                end
             
        end
    
    
    // Tester
    
    initial begin 
        //Inital Bus Signals
        tl_i_d.a_address = 32'h0;
        tl_i_d.a_data = 32'h0;
        tl_i_d.a_mask = 4'hF;
        tl_i_d.a_opcode = tlul_pkg::PutFullData;
        tl_i_d.a_size = 2'b10;
        tl_i_d.a_source = 7'h0;
        tl_i_d.a_valid = 1'b0;
        tl_i_d.a_user = tlul_pkg::TL_A_USER_DEFAULT;
        
        rst_ni = 1;   
        rst_edn_ni = 1;
        #5
        rst_ni = 0;
        rst_edn_ni = 0;
        #5
        rst_ni = 1;   
        rst_edn_ni = 1;
        
        lc_escalate_en_i = lc_ctrl_pkg::LC_TX_DEFAULT;
        lc_rma_req_i = lc_ctrl_pkg::LC_TX_DEFAULT;
        
        f = $fopen({log_path, "tl_output.txt"},"w");
        
        error_count = 0;
        
        // Header 
        $fwrite(f,"----------------------------------------------------------------\n");
        $fwrite(f,"-- OTBN - RTL - Testbench                                       \n");
        $fwrite(f,"----------------------------------------------------------------\n");

        // Read Registers
        for (int i=0 ; i<6 ; i++) begin
            read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
        end
        
        // Interrupt Test Register
        read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(0), .tl_o(tl_o), .tl_i(tl_i_d) );
        
        teststate = "Run Application";
        // Write Programm to IMEM  
        for (int i=0 ; i<128 ; i++) begin 
            // NOP Instruction
            write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(32'b10011), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );   
        end
        // ECALL Instruction
        write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(32'b1110011), .address(OTBN_IMEM_OFFSET+4*128), .tl_o(tl_o), .tl_i(tl_i_d) );
        
        // Read IMEM  
        for (int i=0 ; i<129 ; i++) begin 
            //NOP
            read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_IMEM_OFFSET+4*i), .tl_o(tl_o), .tl_i(tl_i_d) );
        end        
        // Set Instruction Counter to zero (optional)
        write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(32'h0), .address(OTBN_INSN_CNT_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
        
        // Start Programm in IMEM
        write_tl_ul(.log_filehandle(f), .clk(clk_i), .clk_cycles(cc), .data(CmdExecute), .address(OTBN_CMD_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
        
        // Poll on Status Register until Programm is finished
        rdbk = '1;
        while (rdbk != '0) begin 
            read_tl_ul(.log_filehandle(f), .data(rdbk), .clk(clk_i), .clk_cycles(cc), .address(OTBN_STATUS_OFFSET), .tl_o(tl_o), .tl_i(tl_i_d) );
        end 

        $display("Begin Testcase 0000: MUL256\n");	
        `include "testcase0000.sv"

        $display("Begin Testcase 0001: Access of PQSPR\n");	
        `include "testcase0001.sv"

        $display("Begin Testcase 0002: Keccak\n");	
        `include "testcase0002.sv"

        $display("Begin Testcase 0003: PQ-ALU: Add and Sub\n");	
        `include "testcase0003.sv"

        $display("Begin Testcase 0004: PQ-ALU: Mont Mul\n");	
        `include "testcase0004.sv"

        $display("Begin Testcase 0004: PQ-ALU: Butterfly\n");	
        `include "testcase0005.sv"


        $display("Begin Testcase 0010: Keccak\n");	
        `include "testcase0010.sv"

        $display("Begin Testcase 0011: SHAKE-128\n");	
        `include "testcase0011.sv"

        $display("Begin Testcase 0012: SHAKE-256\n");	
        `include "testcase0012.sv"


	    $display("Begin Testcase 0020: NTT Dilithium Unrolled\n");	
        `include "testcase0020.sv"

	    $display("Begin Testcase 0021: INTT Dilithium Unrolled\n");	
        `include "testcase0021.sv"

	    $display("Begin Testcase 0022: NTT Dilithium Indirect Reg Addr\n");	
        `include "testcase0022.sv"

	    $display("Begin Testcase 0023: INTT Dilithium Indirect Reg Addr\n");	
        `include "testcase0023.sv"

        $display("Begin Testcase 0024: NTT Kyber Unrolled\n");	
        `include "testcase0024.sv"

        $display("Begin Testcase 0025: INTT Kyber Unrolled\n");	
        `include "testcase0025.sv"

        $display("Begin Testcase 0026: NTT Kyber Indirect Reg Addr\n");	
        `include "testcase0026.sv"

        $display("Begin Testcase 0027: INTT Kyber Indirect Reg Addr\n");	
        `include "testcase0027.sv"

        $display("Begin Testcase 0028: NTT Falcon-512 Indirect Reg Addr\n");	
        `include "testcase0028.sv"

        $display("Begin Testcase 0029: INTT Falcon-512 Indirect Reg Addr\n");	
        `include "testcase0029.sv"

        $display("Begin Testcase 0030: NTT Falcon-1024 Indirect Reg Addr\n");	
        `include "testcase0030.sv"

        $display("Begin Testcase 0031: INTT Falcon-1024 Indirect Reg Addr\n");	
        `include "testcase0031.sv"

        $display("Begin Testcase 0040: Pointwise Mul Dilithium\n");	
        `include "testcase0040.sv"

        $display("Begin Testcase 0040: Basecase Mul Kyber\n");	
        `include "testcase0041.sv"

        $display("Begin Testcase 0042: Pointwise Mul Falcon-512\n");	
        `include "testcase0042.sv"

        $display("Begin Testcase 0043: Pointwise Mul Falcon-1024\n");	
        `include "testcase0043.sv"



        $display("Begin Testcase 0100: Dilithium ExpandA\n");	
        `include "testcase0100.sv"

        $display("Begin Testcase 0100: Dilithium SampleInBall\n");	
        `include "testcase0101.sv"

        $display("Begin Testcase 0200: Dilithium-II Decompose & UseHint\n");	
        `include "testcase0200.sv"

        $display("Begin Testcase 0201: Dilithium-II Poly UseHint\n");	
        `include "testcase0201.sv"

        $display("Begin Testcase 0202: Dilithium-II Poly PackW1\n");	
        `include "testcase0202.sv"


        $display("Begin Testcase 0210: Dilithium-III/IV Decompose & UseHint\n");	
        `include "testcase0210.sv"

        $display("Begin Testcase 0211: Dilithium-III/IV Poly UseHint\n");	
        `include "testcase0211.sv"

        $display("Begin Testcase 0212: Dilithium-II Poly PackW1\n");	
        `include "testcase0212.sv"

////////////////////////////////////////////////////////////////////////////////////////////////////
// Dilithium Signature Verification
////////////////////////////////////////////////////////////////////////////////////////////////////

        $display("Begin Testcase 1000: Dilithium-II Verify with valid signature\n");	
        `include "testcase1000-dilitium-ii-valid.sv"

        $display("Begin Testcase 1001: Dilithium-II Verify with invalid signature\n");	
        `include "testcase1001-dilitium-ii-invalid.sv"

        $display("Begin Testcase 1002: Dilithium-III Verify with valid signature\n");	
        `include "testcase1002-dilitium-iii-valid.sv"

        $display("Begin Testcase 1003: Dilithium-III Verify with invalid signature\n");	
        `include "testcase1003-dilitium-iii-invalid.sv"

        $display("Begin Testcase 1004: Dilithium-V Verify with valid signature\n");	
        `include "testcase1004-dilitium-v-valid.sv"

        $display("Begin Testcase 1005: Dilithium-V Verify with invalid signature\n");	
        `include "testcase1005-dilitium-v-invalid.sv"
	
        // Measurement of Performance
        
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Keccak Performance in CC : %d \n", cc_count_keccak);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"SHAKE-128 Performance in CC : %d \n", cc_count_shake128);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"SHAKE-256 Performance in CC : %d \n", cc_count_shake256);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Dilithium NTT Performance in CC : %d \n", cc_count_dilithium);
        $fwrite(f,"----------------------------------------------------------------\n");        

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Dilithium NTT (indirect) Performance in CC : %d \n", cc_count_dilithium_indirect);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Dilithium INVNTT Performance in CC : %d \n", cc_count_dilithium_inv);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Dilithium INVNTT (indirect) Performance in CC : %d \n", cc_count_dilithium_inv_indirect);
        $fwrite(f,"----------------------------------------------------------------\n"); 
        
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Dilithium Multiplication Performance in CC : %d \n", cc_count_dilithium_pointwise_mul);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Kyber NTT Performance in CC : %d \n", cc_count_kyber);
        $fwrite(f,"----------------------------------------------------------------\n");         

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Kyber INVNTT Performance in CC : %d \n", cc_count_kyber_inv);
        $fwrite(f,"----------------------------------------------------------------\n");      

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Kyber NTT (indirect)  Performance in CC : %d \n", cc_count_kyber_indirect);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Kyber INVNTT (indirect) Performance in CC : %d \n", cc_count_kyber_inv_indirect);
        $fwrite(f,"----------------------------------------------------------------\n"); 

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Kyber Multiplication Performance in CC : %d \n", cc_count_kyber_base_mul);
        $fwrite(f,"----------------------------------------------------------------\n");  
 
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"FALCON-512 NTT (indirect) Performance in CC : %d \n", cc_count_falcon512_indirect);
        $fwrite(f,"----------------------------------------------------------------\n");   

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"FALCON-512 INVNTT (indirect) Performance in CC : %d \n", cc_count_falcon512_inv_indirect);
        $fwrite(f,"----------------------------------------------------------------\n"); 

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"FALCON-512 Multiplication Performance in CC : %d \n", cc_count_falcon512_pointwise_mul);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"FALCON-1024 NTT (indirect) Performance in CC : %d \n", cc_count_falcon1024_indirect);
        $fwrite(f,"----------------------------------------------------------------\n");   

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"FALCON-1024 INVNTT (indirect) Performance in CC : %d \n", cc_count_falcon1024_inv_indirect);
        $fwrite(f,"----------------------------------------------------------------\n"); 

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"FALCON-1024 Multiplication Performance in CC : %d \n", cc_count_falcon1024_pointwise_mul);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"'ExpandA Performance in CC : %d \n", cc_count_poly_uniform);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"SampleInBall Performance in CC : %d \n", cc_count_sampleinball);
        $fwrite(f,"----------------------------------------------------------------\n"); 

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Decompose-2 & UseHint-2 Perfromance in CC : %d \n", cc_count_usehint2);
        $fwrite(f,"----------------------------------------------------------------\n");         
        
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Poly-UseHint-2 Performance in CC : %d \n", cc_count_poly_usehint2);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"PackW1 - 2 Performance in CC : %d \n", cc_count_packw12);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Decompose-3-5 & UseHint-3-5 Perfromance in CC : %d \n", cc_count_usehint35);
        $fwrite(f,"----------------------------------------------------------------\n");         
        
        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Poly-UseHint-3-5 Performance in CC : %d \n", cc_count_poly_usehint35);
        $fwrite(f,"----------------------------------------------------------------\n"); 

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"PackW1 - 3-5 Performance in CC : %d \n", cc_count_packw135);
        $fwrite(f,"----------------------------------------------------------------\n");  

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Dilithium-II Performance in CC : %d \n", cc_count_dilithium_2);
        $fwrite(f,"----------------------------------------------------------------\n");         

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Dilithium-III Performance in CC : %d \n", cc_count_dilithium_3);
        $fwrite(f,"----------------------------------------------------------------\n");         

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Dilithium-V Performance in CC : %d \n", cc_count_dilithium_5);
        $fwrite(f,"----------------------------------------------------------------\n"); 

        $fwrite(f,"----------------------------------------------------------------\n");           
        $fwrite(f,"Errors: %d \n",error_count);
        $fwrite(f,"----------------------------------------------------------------\n");  
        
         
        $fclose(f);
        $stop;
    end
 
    assign ram_cfg_i.ram_cfg.cfg_en = 1'b0;
    assign ram_cfg_i.ram_cfg.cfg = 4'b0;   
    assign ram_cfg_i.rf_cfg.cfg_en = 1'b0;
    assign ram_cfg_i.rf_cfg.cfg = 4'b0; 
       
    assign alert_rx_i[0].ack_n  = 1'b1;
    assign alert_rx_i[0].ack_p  = 1'b0;
    assign alert_rx_i[0].ping_n = 1'b1;
    assign alert_rx_i[0].ping_p = 1'b0;
    assign alert_rx_i[1].ack_n  = 1'b1;
    assign alert_rx_i[1].ack_p  = 1'b0;
    assign alert_rx_i[1].ping_n = 1'b1;
    assign alert_rx_i[1].ping_p = 1'b0;
  
   // Generate integrity signals for bus
  // to otbn
  assign tl_i_d.a_param = 3'b0;

  assign tl_i_d.d_ready = 1'b1;
  
  tlul_cmd_intg_gen u_tlul_cmd_intg_gen (
      .tl_i(tl_i_d),
      .tl_o(tl_i_q)
  );

  // Check integrity of transmission from
  // otbn
  tlul_rsp_intg_chk u_tlul_rsp_intg_chk (
      .tl_i (tl_o),
      .err_o(err_tl)
  );
   
endmodule

