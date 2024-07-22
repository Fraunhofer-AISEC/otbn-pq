/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* Dilithium-II Verify Implementation */


.section .text.start

/*************************************************/
/*        Load Constants for SampleInBall        */
/*************************************************/

/* ToDo: Move Down before UseHint loop */
/* Address to store w1 */
li x29, 28672

/* Address register to load operands in WDRs */
li x2, 0

/* Address of rc in x3*/
la x3, rc0

/* Address WDR31 with x4 to load rc in */
li x4, 31

/* Load rc into WDR w31*/
bn.lid x4, 0(x3++)

/* Load round counter (rc0) into PQSR*/
pq.pqsrw 8, w31

/*************************************************/
/*      Prepare Keccak State for Absorption      */
/*************************************************/

/* Pointer to current lane */
li x24, 0

/* Pointer to packed bits */  
li x25, 28672

/* Init Keccak State with Zeros */
la x31, allzero
li x2, 0  
loopi 10, 1
  bn.lid x2++, 0(x31)  

/* Store Keccak State */
li x31, 21504
li x2, 0  
loopi 10, 2
  bn.sid x2++, 0(x31)  
  addi x31, x31, 32 

/* Absorb MU */

/* Configure for Keccak Absorb */

/* Load Constants for NTT */
li x2, 0

/* Load prime into WDR w0*/
la x31, bitmask32
bn.lid x2, 0(x31)

/* Load prime into PQSR*/
pq.pqsrw 0, w0

/* Number of 32-bit words to absorb */
li x15, 12
la x26, digest_message  
li x31, 21504
li x2, 0  
loopi 10, 2
  bn.lid x2++, 0(x31)  
  addi x31, x31, 32  
    
jal x1, keccak_absorb

li x31, 21504
li x2, 0  
loopi 10, 2
  bn.sid x2++, 0(x31)  
  addi x31, x31, 32  


/* Load Constants for NTT */
li x2, 0

/* Load prime into WDR w0*/
la x31, prime
bn.lid x2, 0(x31)

/* Load prime into PQSR*/
pq.pqsrw 0, w0
  
/* Pointer to packed w1 bits */
li x26, 19456

/*************************************************/
/*SampleInBall and NTT of Challenge Coefficients */
/*
* ToDo: 
*   - Loading of inital state over loop
*   - Absorb message function
*   - Check which modulo (whether centered recuction necessary)
*/
/*************************************************/

/*                Load Inital State              */

/* Load inital state into WDRs w0 - w9 */
la x31, allzero
li x2, 0 
/* A[3,0] A[2,0] A[1,0] A[0,0] */
bn.lid x2++, 0(x31) 

/* A[4,0] */
bn.lid x2++, 0(x31) 

/* A[3,1] A[2,1] A[1,1] A[0,1] */
bn.lid x2++, 0(x31) 

/* A[4,1] */
bn.lid x2++, 0(x31) 

/* A[3,2] A[2,2] A[1,2] A[0,2] */
bn.lid x2++, 0(x31) 

/* A[4,2] */
bn.lid x2++, 0(x31) 

/* A[3,3] A[2,3] A[1,3] A[0,3] */
bn.lid x2++, 0(x31) 

/* A[4,3] */
bn.lid x2++, 0(x31) 

/* A[3,4] A[2,4] A[1,4] A[0,4] */
bn.lid x2++, 0(x31) 

/* A[4,4] */
bn.lid x2++, 0(x31) 


/*              Load Message and Nonce           */


/* M[3,0] M[2,0] M[1,0] M[0,0] */
la x31, challenge_seed
bn.lid x2++, 0(x31) 

la x31, allzero
/* M[4,0] */
bn.lid x2++, 0(x31) 

/* Padding the message */
bn.addi w12, w0, 31
bn.or w11, w11, w12

/* M[3,1] M[2,1] M[1,1] M[0,1] */
bn.lid x2++, 0(x31) 

/* M[4,1] */
bn.lid x2++, 0(x31) 

/* M[3,2] M[2,2] M[1,2] M[0,2] */
bn.lid x2++, 0(x31) 

/* M[4,2] */
bn.lid x2++, 0(x31) 

/* M[3,3] M[2,3] M[1,3] M[0,3] */
bn.lid x2++, 0(x31) 

/* M[4,3] */
bn.lid x2++, 0(x31) 

/* M[3,4] M[2,4] M[1,4] M[0,4] */
bn.lid x2++, 0(x31) 

/* Padding the message */
bn.lid x2, 0(x31) 
bn.addi w19, w19, 128
bn.or w16, w16, w19 << 120

/* M[4,4] */
bn.lid x2, 0(x31) 

/* Absorb Message  */
bn.xor w0, w0, w10
bn.xor w1, w1, w11
bn.xor w2, w2, w12
bn.xor w3, w3, w13
bn.xor w4, w4, w14
bn.xor w5, w5, w15
bn.xor w6, w6, w16
bn.xor w7, w7, w17
bn.xor w8, w8, w18
bn.xor w9, w9, w19

/* Call Keccak Permuation function */
la x5, rc0
jal x1, keccak_permutation

jal x1, sampleinball

/* FOR DEBUG START */

/* Load Challenge Coefficients in WDRs */
la x31, challenge_coef_0
li x2, 0
loopi 32, 2
  bn.lid x2++, 0(x31)
  addi x31, x31, 32

li x31, 27648
li x2, 0

loopi 32, 2
  bn.sid x2++, 0(x31)
  addi x31, x31, 32
  
/* FOR DEBUG END */

/*********************************/
/* NTT of Challenge Coefficients */
/*********************************/

/* Load Constants for NTT */
li x2, 0

/* Load prime into WDR w0*/
la x31, prime
bn.lid x2, 0(x31)

/* Load prime into PQSR*/
pq.pqsrw 0, w0


/* Load prime_dash into WDR w0*/
la x31, prime_dash
bn.lid x2, 0(x31)

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w0


/* Load omega into WDR w0*/
la x31, omega
bn.lid x2, 0(x31)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load psi into WDR w0*/
la x31, psi
bn.lid x2, 0(x31)

/* Load psi into PQSR*/
pq.pqsrw 4, w0

/* Load Challenge Coefficients in WDRs */
la x31, challenge_coef_0

loopi 32, 2
  bn.lid x2++, 0(x31)
  addi x31, x31, 32

/* FOR DEBUG START */

li x31, 27648
li x2, 0

loopi 32, 2
  bn.sid x2++, 0(x31)
  addi x31, x31, 32

/* FOR DEBUG END */

jal x1, ntt

/* Store Challenge Coefficients in DMEM */
la x31, challenge_coef_0
li x2, 0

loopi 32, 2
  bn.sid x2++, 0(x31)
  addi x31, x31, 32


/* FOR DEBUG START */

li x31, 26624
li x2, 0

loopi 32, 2
  bn.sid x2++, 0(x31)
  addi x31, x31, 32

/* FOR DEBUG END */  
 
  
/*************************************************/
/* ExpandA and Loop                              */
/*
*   - Add correct header 
*
* Note: DONT TOUCH x26 and x7 !!!!!!!!!!!!!!!!!!
*/
/*************************************************/

/* Prepare Nonce */
li x23, 0
li x7, 0

/* Prepare other variables */
li x2, 0
li x22, 0

/* For i in 0 to k */
loopi 4, 205

  /* Init w_acc_coef_0_0 */

  la x31, allzero
  bn.lid x0, 0(x31)
  li x31, 20480 
  
  loopi 32, 1
    bn.sid x0, 0(x31++) 
    
  /* For j in 0 to l */
  loopi 4, 55
    li x22, 0
    slli x8, x23, 8
    add x8, x8, x7
    /* Hardcoded !!!! */
    sw x8, 608(x0)
    jal x1, poly_uniform
    /* addi x7, x7, 1 */
    
    /*********************************/
    /* NTT of Signature Coefficients */
    /*********************************/
    
    /* Load Constants for NTT */
    li x2, 0

    /* Reset Mode */
    /* mode = 0 */
    pq.srw 5, x2
      
    /* Load omega into WDR w0*/
    la x31, omega
    bn.lid x2, 0(x31)

    /* Load omega into PQSR*/
    pq.pqsrw 3, w0

    /* Load psi into WDR w0*/
    la x31, psi
    bn.lid x2, 0(x31)

    /* Load psi into PQSR*/
    pq.pqsrw 4, w0
    
        
    /* Load Signature Coefficients in WDRs */
    /*ToDo: Update depending on K*/
    la x31, signature_coef_0_0
    slli x30, x7, 10
    add x31, x31, x30
    
    loopi 32, 2
      bn.lid x2++, 0(x31)
      addi x31, x31, 32
    
    jal x1, ntt

    /* Store Signature Coefficients in DMEM */
    /* la x31, signature_coef_0_0 */
    li x31, 17408

    slli x9, x0, 10
    add x31, x31, x9
    
    li x2, 0
    loopi 32, 2
      bn.sid x2++, 0(x31)
      addi x31, x31, 32

    /* Increment x7 here not above !!!*/
    addi x7, x7, 1
    
    /*********************************/
    /*          A_i,k x z_k          */
    /*********************************/ 
    
    
    /* la x4, signature_coef_0_0 */
    li x4, 17408
    /* ToDo: Adapt Address */
    slli x9, x0, 10
    add x4, x4, x9
    /* la x5, A_coeff_0 */
    li x5, 16352
    /* la x6, Az_coef_0_0 */
    li x6, 18432
    
    /* Load r_dash into WDR w0*/
    li x2, 0
    la x31, r_dash 
    bn.lid x2, 0(x31)

    /* j = 0 */
    li x2, 0
    pq.srw 2, x0

    /* Load r_dash into scale PQSR*/
    pq.pqsrw 7, w0
    
    jal x1, pointwise_mul

    /* Addition w_i and (A_i,k x z_k)*/
    
    /* la x4, Az_coef_0_0 */
    li x4, 18432
    /* la x5, w_acc_coef_0_0 */
    li x5, 20480
    /* la x6, w_acc_coef_0_0 */
    li x6, 20480 
     
    li x31, 1
    jal x1, pointwise_add

    li x31, 2
    li x31, 3
    
  /*********************************/
  /*           t_i x 2^d           */
  /*********************************/   
    
  /* Load 2^d into WDR w0*/
  li x2, 0
  la x31, allzero
  bn.lid x2++, 0(x31)
  bn.lid x2, 0(x31)
  bn.addi w0, w0, 1
  bn.rshi w0, w0, w1 >> 243

  /* Configure Indirect Addressing */

  /* m = l */
  li x2, 1
  pq.srw 0, x2

  /* j2 = n >> 1 */
  li x3, 128
  pq.srw 1, x3

  /* j = 0 */
  li x4, 0
  pq.srw 2, x4

  /* mode = 1 */
  li x5, 1
  pq.srw 5, x5

  /* Set idx0 and idx1 */
  pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 

  /* Convert 2^d into Montgomery Domain */
  pq.scale.ind 0, 0, 0, 0, 0

  /* Load 2^d into Scale PQSR */
  pq.pqsrw 7, w0

  /* ToDo: Load t1 into WDRs depending on k and l */
  la x31, t1_coef_0_0
  slli x30, x23, 10
  add x31, x31, x30
  
  li x2, 0
  loopi 32, 2
    bn.lid x2++, 0(x31)
    addi x31, x31, 32
      
  /* Scale Loop */
  loopi 256, 1
    pq.scale.ind 0, 0, 0, 0, 1

  /* Store Signature Coefficients in DMEM */
  li x31, 25600
    
  li x2, 0
  loopi 32, 2
    bn.sid x2++, 0(x31)
    addi x31, x31, 32

  /* Reset Mode */
  /* mode = 0 */
  li x5, 0
  pq.srw 5, x5

  /* t1 is already in memory, so it does not have ot be loaded again */

  li x31, 144


  /*********************************/
  /*            NTT(t_i)           */
  /*********************************/ 
    
  jal x1, ntt

  /* Store Signature Coefficients in DMEM */
  li x31, 24576
    
  li x2, 0
  loopi 32, 2
    bn.sid x2++, 0(x31)
    addi x31, x31, 32

      
  /*********************************/
  /*        NTT(c) x NTT(t)        */
  /*********************************/ 
    
  li x4, 24576
  la x5, challenge_coef_0
  li x6, 25600 
    
    
  /* Load r_dash into WDR w0*/
  li x2, 0
  la x31, r_dash 
  bn.lid x2, 0(x31)

  /* j = 0 */
  li x2, 0
  pq.srw 2, x0

  /* Load r_dash into scale PQSR*/
  pq.pqsrw 7, w0
        
  jal x1, pointwise_mul    
      
  /* Subtract */
    
  /* Address of w_acc_coef_0_0 */
  li x4, 20480 
  li x5, 25600
   
  li x6, 20480
        
  jal x1, pointwise_sub       
 
  /*********************************/
  /*         INTT(w_i_temp)        */
  /*********************************/ 

  /* Load Constants for NTT */
  li x2, 0
    
  /* Load omega into WDR w0*/
  la x31, omega_inv
  bn.lid x2, 0(x31)

  /* Load omega into PQSR*/
  pq.pqsrw 3, w0

  /* Load psi into WDR w0*/
  la x31, psi_inv
  bn.lid x2, 0(x31)

  /* Load psi into PQSR*/
  pq.pqsrw 4, w0

  /* Load n^-1 into WDR w0*/
  la x31, n1 
  bn.lid x2, 0(x31)

  /* Load n^-1 into scale PQSR*/
  pq.pqsrw 7, w0    
    
    
  /* Load w_i_temp Coefficients in WDRs */
  la x31, 20480
    
  loopi 32, 2
    bn.lid x2++, 0(x31)
    addi x31, x31, 32
    
  jal x1, intt

  /* Store Signature Coefficients in DMEM */
  la x31, 20480
        
  li x2, 0
  loopi 32, 2
    bn.sid x2++, 0(x31)
    addi x31, x31, 32   
   
  /* UseHint */
  la x6, allzero
    
  /* Address of Coefficients: 0 */
  li x4, 20480

  /* Address of Hint Coefficients */
  /* ToDo: Depending on K*/
  la x5, hint0
  slli x30, x23, 5
  add x5, x5, x30

    
  /* Load Hint coefficients from Address in x5 into WDR 20 */
  li x3, 20
  bn.lid x3, 0(x5++)

  /* Loop trough hint coefficients*/
  loopi 32, 4
    jal x1, use_hint
    li x30, 10
    bn.sid x30, 0(x29++)    
    addi x4, x4, 32
    
  /* Absorb */
 
    /* Load Constants for NTT */
    li x2, 0

    /* Load prime into WDR w0*/
    la x31, bitmask32
    bn.lid x2, 0(x31)

    /* Load prime into PQSR*/
    pq.pqsrw 0, w0

    /* Start Address of w1 coefficients */
    addi x4, x25, 0

    loopi 1, 31
      /* Load coefficients at address x4 and pack them into w10-15*/
      jal x1, pack_w1
      
      /* Store packed bits at address 19456 */
      li x2, 10
      li x18, 19456
      loopi 6, 2
        bn.sid x2++, 0(x18)
        addi x18, x18, 32
  
  
      /* Number of 32-bit words to absorb */
      li x15, 48
  
      li x31, 21504
      li x2, 0  
      loopi 10, 2
        bn.lid x2++, 0(x31)  
        addi x31, x31, 32
      
      /* Absorb packed w1 bytes at address x26 into keccak state in w0-9*/
      jal x1, keccak_absorb

      li x31, 21504
      li x2, 0  
      loopi 10, 2
        bn.sid x2++, 0(x31)  
        addi x31, x31, 32  
  
      addi x26, x26, 0
      addi x0, x0, 0
      
      /* FOR DEBUG START */
      /* If you want to check w1' uncomment the next line */
      /* addi x25, x25, 1024 */
      /* If you want to check w1' comment the next line */
      li x29, 28672
      /* FOR DEBUG END */
 
      /* Load Constants for NTT */
      li x2, 0

      /* Load prime into WDR w0*/
      la x31, prime
      bn.lid x2, 0(x31)

      /* Load prime into PQSR*/
      pq.pqsrw 0, w0
      
      li x31, 7
      li x31, 8
      li x31, 7
      li x31, 8
   
  /* Increment and reset loop variables */
  addi x23, x23, 1
  li x7, 0 
  
li x31, 7
li x31, 8
li x31, 9
li x31, 10
li x31, 11
li x31, 12
li x31, 13
li x31, 14
li x31, 15
li x31, 7
li x31, 8
li x31, 9
li x31, 10
li x31, 11
li x31, 12
li x31, 13
li x31, 14
li x31, 15
li x31, 7
li x31, 8
li x31, 9
li x31, 10
li x31, 11
li x31, 12
li x31, 13
li x31, 14
li x31, 15
li x31, 7
li x31, 8
li x31, 9
li x31, 10
li x31, 11
li x31, 12
li x31, 13
li x31, 14
li x31, 15

/* Padding of Message */

/* Load allzero state into WDRs w10 - w19 */
la x31, allzero
li x2, 10 
/* A[3,0] A[2,0] A[1,0] A[0,0] */
bn.lid x2++, 0(x31) 

/* A[4,0] */
bn.lid x2++, 0(x31) 

/* A[3,1] A[2,1] A[1,1] A[0,1] */
bn.lid x2++, 0(x31) 

/* A[4,1] */
bn.lid x2++, 0(x31) 

/* A[3,2] A[2,2] A[1,2] A[0,2] */
bn.lid x2++, 0(x31) 

/* A[4,2] */
bn.lid x2++, 0(x31) 

/* A[3,3] A[2,3] A[1,3] A[0,3] */
bn.lid x2++, 0(x31) 

/* A[4,3] */
bn.lid x2++, 0(x31) 

/* A[3,4] A[2,4] A[1,4] A[0,4] */
bn.lid x2++, 0(x31) 

/* A[4,4] */
bn.lid x2++, 0(x31) 

/* Padding */
bn.addi w10, w10, 31

bn.lid x2, 0(x31) 
bn.addi w20, w20, 128
bn.or w16, w16, w20 << 120

/* Load Keccak State */
li x31, 21504
li x2, 0  
loopi 10, 2
  bn.lid x2++, 0(x31)  
  addi x31, x31, 32  

/* Absorb Message  */
bn.xor w0, w0, w10
bn.xor w1, w1, w11
bn.xor w2, w2, w12
bn.xor w3, w3, w13
bn.xor w4, w4, w14
bn.xor w5, w5, w15
bn.xor w6, w6, w16
bn.xor w7, w7, w17
bn.xor w8, w8, w18
bn.xor w9, w9, w19

/* Call Keccak Permuation function */
la x5, rc0

jal x1, keccak_permutation

li x31, 21504
li x2, 0  
loopi 10, 2
  bn.sid x2++, 0(x31)  
  addi x31, x31, 32  

/* Compare challenge seeds */
la x31, challenge_seed    
li x2, 20  
bn.lid x2, 0(x31)

bn.sub w30, w20, w0, FG0

/* Check Zero Flag */
csrrw x14, 1984, x0
li x3, 8
andi x14, x14, 8

bne x14, x3, failed
li x31, 0
beq x0, x0, return_x31

failed:
li x31, -1

return_x31:
sw x31, 0(x0)
    
ecall


/*************************************************/
/*            Functions and Procedures           */
/*************************************************/


/*************************************************/
/*               Pointwise Addition                    
* @param[in] x4: address of first operand in DMEM
* @param[in] x5: address of second operand in DMEM
* @param[in] x6: address of result in DMEM
* @param[out] DMEM[x6:x6+1024]: output of addition
*
* clobbered registers: x2: WDR register address operand
*                      x3: WDR register address operand
*                      x8: WDR register address result
*                      w24: WDR result
*                      w0: WDR operand
*                      w16: WDR operand
*
*
*
*
*
*
*
*
*
/*************************************************/

pointwise_add:

li x2, 0
li x3, 16
li x8, 24

loopi 32, 11

  bn.lid x2, 0(x4++)
  bn.lid x3, 0(x5++)


  /* Coefficientwise Addition */

  /* Coefficientwise Multiplication */
  pq.add w24.0, w0.0, w16.0
  pq.add w24.1, w0.1, w16.1
  pq.add w24.2, w0.2, w16.2
  pq.add w24.3, w0.3, w16.3
  pq.add w24.4, w0.4, w16.4
  pq.add w24.5, w0.5, w16.5
  pq.add w24.6, w0.6, w16.6
  pq.add w24.7, w0.7, w16.7

  /* Store Coefficients */
  bn.sid x8, 0(x6++)

ret


/*************************************************/
/*               Pointwise Subtraction                    
* @param[in] x4: address of first operand in DMEM
* @param[in] x5: address of second operand in DMEM
* @param[in] x6: address of result in DMEM
* @param[out] DMEM[x6:x6+1024]: output of subtraction
*
* clobbered registers: x2: WDR register address operand
*                      x3: WDR register address operand
*                      x8: WDR register address result
*                      w24: WDR result
*                      w0: WDR operand
*                      w16: WDR operand
*
*
*
*
*
*
*
*
*
/*************************************************/

pointwise_sub:

li x2, 0
li x3, 16
li x8, 24

loopi 32, 11

  bn.lid x2, 0(x4++)
  bn.lid x3, 0(x5++)


  /* Coefficientwise Subtraction */

  /* Coefficientwise Multiplication */
  pq.sub w24.0, w0.0, w16.0
  pq.sub w24.1, w0.1, w16.1
  pq.sub w24.2, w0.2, w16.2
  pq.sub w24.3, w0.3, w16.3
  pq.sub w24.4, w0.4, w16.4
  pq.sub w24.5, w0.5, w16.5
  pq.sub w24.6, w0.6, w16.6
  pq.sub w24.7, w0.7, w16.7


  /* Store Coefficients */
  bn.sid x8, 0(x6++)

ret


/*************************************************/
/*            Pointwise Multiplication                    
* @param[in] x4: address of first operand in DMEM
* @param[in] x5: address of second operand in DMEM
* @param[in] x6: address of result in DMEM
* @param[out] DMEM[x6:x6+1024]: output of multiplication
*
* clobbered registers: x2: WDR register address operand
*                      x3: WDR register address operand
*                      x8: WDR register address result
*                      w24: WDR result
*                      w0: WDR operand
*                      w16: WDR operand
*
*
*
*
*
*
*
*
*
/*************************************************/

pointwise_mul:

li x2, 0
li x3, 16
li x8, 24

loopi 32, 14

  bn.lid x2, 0(x4++)
  bn.lid x3, 0(x5++)


  /* Coefficientwise Multiplication */


  /* Set idx0/idx1 */
  pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 

  loopi 8, 1
    /* Transformation in Montgomery Domain */
    pq.scale.ind 0, 0, 0, 0, 1

  /* Coefficientwise Multiplication */
  pq.mul w24.0, w0.0, w16.0
  pq.mul w24.1, w0.1, w16.1
  pq.mul w24.2, w0.2, w16.2
  pq.mul w24.3, w0.3, w16.3
  pq.mul w24.4, w0.4, w16.4
  pq.mul w24.5, w0.5, w16.5
  pq.mul w24.6, w0.6, w16.6
  pq.mul w24.7, w0.7, w16.7


  /* Store Coefficients */
  bn.sid x8, 0(x6++)

ret


/*************************************************/
/*                     PACK_W1                   */
/*
* @param[in]  x4: start address of w1 coefficients
* @param[out]  WDR10-W15: packed w1 bytes
*
* clobbered registers: x2: 
*                      x4: 
*                      x31: 
*                      w0: 
*                      w1: 
*                      w17: 
*                      w18: 
*                      w19: 
*                      w20:                   
*
*/
/*************************************************/
pack_w1:


  /* Load allzero in W18 */
  la x31, allzero
  li x2, 18  
  bn.lid x2, 0(x31)  
  
  /* Load Mask in W18 */
  bn.addi w18, w18, 255
  
  /* Load allzero in W19 */
  la x31, allzero
  li x2, 19
  bn.lid x2, 0(x31)
  
  /* Initialize Destination registers */
  li x2, 10
  loopi 6, 1
    bn.lid x2++, 0(x31) 
    
  /* Initialize idx register */
  
  /* Set WDR10 as Destination */
  li x2, 80
  pq.srw 3, x2
  
  loopi 16, 78
  
  /* Initialize idx register */
  
  /* Set WDR20 as Source */
  li x2, 160
  pq.srw 4, x2
  
  /* Load Coefficients of 16 WDRs */
  li x2, 0
  loopi 2, 2
    bn.lid x2++, 0(x4)
    addi x4, x4, 32 
  
  /* Shifting */
  
  /* Byte 0 */
  bn.and w20, w0, w18
  
  bn.rshi w17, w19, w0 >> 26
  bn.and w17, w17, w18
  bn.or w20, w20, w17
  
  /* Byte 1 */
  bn.rshi w17, w19, w0 >> 34
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 8 
  
  bn.rshi w17, w19, w0 >> 60
  bn.and w17, w17, w18 
  bn.or w20, w20, w17 << 8 
  
  /* Byte 2 */
  bn.rshi w17, w19, w0 >> 68
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 16
  
  bn.rshi w17, w19, w0 >> 94
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 16
  
  /* Byte 0 */
  bn.rshi w17, w19, w0 >> 128
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 24

  bn.rshi w17, w19, w0 >> 154
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 24
  
  /* Byte 1 */
  bn.rshi w17, w19, w0 >> 162
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 32 
  
  bn.rshi w17, w19, w0 >> 188
  bn.and w17, w17, w18 
  bn.or w20, w20, w17 << 32
  
  /* Byte 2 */
  bn.rshi w17, w19, w0 >> 196
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 40
  
  bn.rshi w17, w19, w0 >> 222
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 40
  
  /* Byte 0 */
  bn.and w17, w1, w18 
  bn.or w20, w20, w17 << 48 
  
  bn.rshi w17, w19, w1 >> 26
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 48

  /* Byte 1 */
  bn.rshi w17, w19, w1 >> 34
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 56  

  bn.rshi w17, w19, w1 >> 60
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 56    

  /* Byte 2 */
  bn.rshi w17, w19, w1 >> 68
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 64

  bn.rshi w17, w19, w1 >> 94
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 64  
  
  /* Byte 0 */
  bn.rshi w17, w19, w1 >> 128
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 72
  
  bn.rshi w17, w19, w1 >> 154
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 72  
     
  /* Byte 1 */
  bn.rshi w17, w19, w1 >> 162
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 80

  bn.rshi w17, w19, w1 >> 188
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 80  

  /* Byte 2 */
  bn.rshi w17, w19, w1 >> 196
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 88
  
  bn.rshi w17, w19, w1 >> 222
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 88  
  
  /* 96-bit packed into first 3 words of W20 */
  
  /* Move these words into Destination WDRs */
  loopi 3,1
    pq.add.ind 0, 0, 0, 0, 1
    
  addi x0, x0, 0    
  
ret

/*************************************************/
/*                  KECCAK_ABSORB                */
/*
* @param[in]  w0-w9: Keccak State 
* @param[in]  x26: pointer to packed w1 bytes 
* @param[in]  w10-w15: 
* @param[in]  x24: pointer to current lane 
* @param[in]  x15: number of 32-bit words left
*
* clobbered registers: x2: 
*                      x3:
*                      x5:
*
*/
/*************************************************/


keccak_absorb:

  /* Load and Configure Source Words */
  li x2, 10
  addi x14, x26, 0
  
  loopi 6, 2
    bn.lid x2++, 0(x14)
    addi x14, x14, 32
    
  /* Set w10 as source */
  addi x3, x0, 80
  pq.srw 4, x3

  /* Prepare Message */

  prep_loop:
  
  /* Load allzero in W20-W29 */
  la x31, allzero
  li x2, 20
  loopi 10, 1
    bn.lid x2++, 0(x31)
    
  /* Add 20 to lane pointer to address --> destination idx */
  addi x3, x24, 160
  pq.srw 3, x3
  
  state_loop:
  
    pq.add.ind 0, 0, 0, 0, 1
    
    /* Decrement missing 32-bit words */
    li x2, 1
    sub x15, x15, x2 
    
    /* If 51 --> full --> Keccak Permutation */
    li x5, 51
    bne x24, x5, skip_permutation
    
    /* Absorb Message  */
    bn.xor w0, w0, w20
    bn.xor w1, w1, w21
    bn.xor w2, w2, w22
    bn.xor w3, w3, w23
    bn.xor w4, w4, w24
    bn.xor w5, w5, w25
    bn.xor w6, w6, w26
    bn.xor w7, w7, w27
    bn.xor w8, w8, w28
    bn.xor w9, w9, w29
    
    la x5, rc0
    jal x1, keccak_permutation
    
    li x24, 0
    
    /* Load and Configure Source Words */
    li x2, 10
    addi x14, x26, 0
  
    loopi 6, 2
      bn.lid x2++, 0(x14)
      addi x14, x14, 32
    
    
    /* Check # missing bits */
    beq x15, x0, end_keccak
    
    beq x0, x0, prep_loop
    
  /* Else */
    skip_permutation:
    /* Differentiate Cases when WDR stores 4 or 1 lanes */
    /* If 9 or 25 or 41 address is incremented +7 instead + 1 */
    li x5, 9

    /* Select 4-bit LSBs of x24 */
    andi x14, x24, 15

    bne x5, x14, increment_wdrword_address
    addi x24, x24, 6

    increment_wdrword_address: 
    addi x24, x24, 1    
    
    /* Add 20 to lane pointer to address --> destination idx */
    addi x3, x24, 160
    pq.srw 3, x3
  
    /* Check # missing bits */
    bne x15, x0, state_loop
    
    /* Absorb Message  */
    bn.xor w0, w0, w20
    bn.xor w1, w1, w21
    bn.xor w2, w2, w22
    bn.xor w3, w3, w23
    bn.xor w4, w4, w24
    bn.xor w5, w5, w25
    bn.xor w6, w6, w26
    bn.xor w7, w7, w27
    bn.xor w8, w8, w28
    bn.xor w9, w9, w29

  end_keccak:
  
ret




/*************************************************/
/*                   Poly Uniform                    
* @param[in] w0-w31: input values in time domain
* @param[out] w0-w31: output values in frequency domain
*
* clobbered registers: x2: m
*                      x3: j2
*                      x4: 2
*
*
*
*
*
*
*
*
*
/*************************************************/

poly_uniform:

/* Load inital state into WDRs w0 - w9 */
la x31, allzero
li x2, 0

/* A[3,0] A[2,0] A[1,0] A[0,0] */
bn.lid x2++, 0(x31) 

/* A[4,0] */
bn.lid x2++, 0(x31) 

/* A[3,1] A[2,1] A[1,1] A[0,1] */
bn.lid x2++, 0(x31) 

/* A[4,1] */
bn.lid x2++, 0(x31) 

/* A[3,2] A[2,2] A[1,2] A[0,2] */
bn.lid x2++, 0(x31) 

/* A[4,2] */
bn.lid x2++, 0(x31) 

/* A[3,3] A[2,3] A[1,3] A[0,3] */
bn.lid x2++, 0(x31) 

/* A[4,3] */
bn.lid x2++, 0(x31) 

/* A[3,4] A[2,4] A[1,4] A[0,4] */
bn.lid x2++, 0(x31) 

/* A[4,4] */
bn.lid x2++, 0(x31) 

/*************************************************/
/*              Load Message and Nonce           */
/*************************************************/

/* M[3,0] M[2,0] M[1,0] M[0,0] */
la x31, expanda_seed
bn.lid x2++, 0(x31) 

/* M[4,0] */
addi x31, x31, 32
bn.lid x2++, 0(x31) 

/* Padding the message */
bn.addi w12, w0, 31
bn.or w11, w11, w12 << 16

/* M[3,1] M[2,1] M[1,1] M[0,1] */
la x31, allzero
bn.lid x2++, 0(x31) 

/* M[4,1] */
bn.lid x2++, 0(x31) 

/* M[3,2] M[2,2] M[1,2] M[0,2] */
bn.lid x2++, 0(x31) 

/* M[4,2] */
bn.lid x2++, 0(x31) 

/* M[3,3] M[2,3] M[1,3] M[0,3] */
bn.lid x2++, 0(x31) 

/* M[4,3] */
bn.lid x2++, 0(x31) 

/* M[3,4] M[2,4] M[1,4] M[0,4] */
bn.lid x2++, 0(x31) 

/* Padding the message */
bn.lid x2, 0(x31) 
bn.addi w19, w19, 128
bn.or w18, w18, w19 << 56

/* M[4,4] */
bn.lid x2, 0(x31) 

/* Absorb Message  */
bn.xor w0, w0, w10
bn.xor w1, w1, w11
bn.xor w2, w2, w12
bn.xor w3, w3, w13
bn.xor w4, w4, w14
bn.xor w5, w5, w15
bn.xor w6, w6, w16
bn.xor w7, w7, w17
bn.xor w8, w8, w18
bn.xor w9, w9, w19

li x28, 256

/* Position inside current destination WDR - Initialize with 8 */
li x17, 8
li x18, 176
li x19, 0

sampling_loop:

/* Squeeze */

li x2, 0

/* Call Keccak Permuation function */
la x5, rc0
jal x1, keccak_permutation

/* Align all samples */

/* Keccak State Position in X10 */
li x10, 0
/* Aligned Samples Position in X13*/
li x13, 14

jal x1, align_chunks

li x4, 14
li x2, 0

/* Load All-Zero in W22*/
li x21, 22
la x31, allzero
bn.lid x21, 0(x31) 

beq x19, x0, skip_load_previous_samples
  la x31, expand_a_temp
  bn.lid x21, 0(x31)
  
skip_load_previous_samples:

/* Rejection Sampling */
li x19, 0
jal x1, rej_uniform
/*ToDo: WDR not finished but new samples required */
bne x28, x0, sampling_loop

ret


/*************************************************/
/*                       NTT                     
* @param[in] w0-w31: input values in time domain
* @param[out] w0-w31: output values in frequency domain
*
* clobbered registers: x2: m
*                      x3: j2
*                      x4: 2
*
*
*
*
*
*
*
*
*
/*************************************************/

ntt:

/* m = n >> 1 */
li x2, 128
pq.srw 0, x2

/* j2 = 1 */
li x3, 1
pq.srw 1, x3

/* j = 0 */
li x4, 0
pq.srw 2, x4


loopi 8, 10
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  loop x3, 4
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0   
    loop x2, 1
      pq.ctbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
  /* Update idx_psi, idx_omega, m and j2 */
  pq.pqsru 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0 
  slli x3, x3, 1
  srli x2, x2, 1
  pq.srw 2, x4

ret


/*************************************************/
/*                       INTT                     
* @param[in] w0-w31: input values in time domain
* @param[out] w0-w31: output values in frequency domain
*
* clobbered registers: x2: m
*                      x3: j2
*                      x4: 2
*                      x5: mode
*
*
*
*
*
*
*
*
*
/*************************************************/

intt:

/* m = l */
li x2, 1
pq.srw 0, x2

/* j2 = n >> 1 */
li x3, 128
pq.srw 1, x3

/* j = 0 */
li x4, 0
pq.srw 2, x4

/* mode = 1 */
li x5, 1
pq.srw 5, x5

loopi 8, 10
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  loop x3, 4
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
    loop x2, 1
      pq.gsbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
  /* Update psi, omega, m and j2 */
  pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
  srli x3, x3, 1
  slli x2, x2, 1
  pq.srw 2, x4

pq.srw 3, x4
loopi 256, 1
  pq.scale.ind 0, 0, 0, 0, 1

ret

/*************************************************/
/*                  SampleInBall                 */
/*
* @param[in] w0-w9: keccak state
* @param[out] DMEM[1024+i]: sampled challenge coeffs
*
* clobbered registers: x2: address to store keccak state
*                      x3: address of current RC value
*                      x4: internal variables
*                      x5: internal variables
*                      x6-x7: sign bytes
*                      x8: internal variables
*                      x10: store N-TAU(i)
*                      x11: store SHAKE256 rate
*                      x12: store sample
*                      x13: store 8-bit bitmask 
*                      x14: store current byte
*                      x15: store (b-i)
*                      x16: address of coeffs[b/i]
*                      x17: count bytes in x12
*                      x18: intermediate result (coeff)
*                      x19: intermediate result (sign)
*                      w10-19: intermediate results
*                      w20-29: intermediate results
*                      w31: round counter value
*
*                      DMEM[544-832] transfer between register sets
*
*
*
*
*
*
*
*
*
/*************************************************/

sampleinball: 

/* Write shake256 output to memory --> transfer to GPRs */
li x4, 0
li x2, 0

la x31, challenge_temp_0

loopi 10, 2
  bn.sid x4++, 0(x31)
  addi x31, x31, 32


/* Store Sign Bytes (first 8 bytes) in x6 & x7*/
la x31, challenge_temp_0

lw x6, 0(x31)
addi x2, x2, 4
addi x31, x31, 4

lw x7, 0(x31)
addi x2, x2, 4
addi x31, x31, 4

li x8, 31

/* Init challenge polynomial */

/* Initialize challenge address space with zeros */
la x30, challenge_coef_0
loopi 256, 2
  sw x0, 0(x30)
  addi x30, x30, 4

/* Load N-TAU(i) in x10 */
li x10, 217

/* Load sample in x12 */
lw x12, 0(x31)
addi x2, x2, 4
addi x31, x31, 4

/* Count bytes in x12 over x17 */
li x17, 4

/* Load SHAKE256 rate in x11 */
li x11, 136
/* li x2, 0 */

/* Repeat TAU times to create Tau +/- 1's */
loopi 39, 64

loop_while_b_greater_i:

/* Check if x2 > SHAKE256 rate */
bne x2, x11, skip_shake256

/* Call Keccak Permuation function */
la x5, rc0
jal x1, keccak_permutation

/* Write shake256 output to memory --> transfer to GPRs */
li x4, 0
la x31, challenge_temp_0

loopi 10, 2
  bn.sid x4++, 0(x31)
  addi x31, x31, 32

/* Load SHAKE256 rate in x11 */
li x11, 136
li x2, 0

skip_shake256:

/* Store in x12 & mask in x13 */
bne x17, x0, skip_load_sample
la x31, challenge_temp_0
add x31, x31, x2
lw x12, 0(x31)

/* Differentiate Cases when WDR stores 4 or 1 lanes */
/* If 9 or 25 or 42 address is incremented +20 instead + 4 */
li x5, 36

/* Load 4-bit mask in x13 */
andi x13, x2, 63

bne x5, x13, increment_sample_address
addi x2, x2, 24

increment_sample_address: 
addi x2, x2, 4

/* Count bytes in x12 over x17 */
li x17, 4


skip_load_sample:
/* Load 8-bit mask in x13 */
li x13, 255
and x14, x12, x13
/* Current Byte(b) in x14 */
srli x12, x12, 8
li x5, 1
sub x17, x17, x5

/* Store (b-i) in x15 */
sub x15, x14, x10
beq x15, x0, exit_loop_while_b_greater_i
/* Shif MSB to pos[0] */
srli x15, x15, 31

/* Check if b =< i */
beq x15, x0, loop_while_b_greater_i

exit_loop_while_b_greater_i:
/* Sample +/- 1*/

/* c->coeffs[i] = c->coeffs[b] */
/* lw x18, 1024(x14*4) */
slli x16, x14, 2
la x30, challenge_coef_0
add x30, x30, x16
lw x18, 0(x30)

/* sw x18, 1024(x10*4) */
slli x16, x10, 2
la x30, challenge_coef_0
add x30, x30, x16
sw x18, 0(x30)

/* c->coeffs[b] = 1 - 2*(signs & 1) */
and x18, x0, x0

/* +1 or -1 depending on sign */
andi x19, x6, 1
beq x19, x0, plus_one


minus_one:

/*addi x18, x18, -1*/
li x18, 8380416
beq x0, x0, next_sign

plus_one:

addi x18, x18, 1
beq x0, x0, next_sign


next_sign:

/* Store c->coeffs[b] */
slli x16, x14, 2
la x30, challenge_coef_0
add x30, x30, x16
sw x18, 0(x30)

/* shift signs >>= 1 */
srli x6, x6, 1

/* move x7 to x6 when x6 is empty */
bne x8, x0, skip_sign_update
andi x6, x6, 0
addi x6, x7, 0

skip_sign_update:
li x5, 1
sub x8, x8, x5 

/* Update loop variable */
addi x10, x10, 1


li x30, 1
li x30, 2
li x30, 3
li x30, 4
li x30, 5
li x30, 6
li x30, 7
li x30, 8
li x30, 9
li x30, 10
li x30, 11

ret



/*************************************************/
/*               Keccak Permutation              */
/*
* @param[in] x5:    Address of RC0 in DMEM
* @param[in] W0-W9: Keccak State
*
* clobbered registers: x3: address of current RC value
*                      x4: internal variables
*                      w10-19: intermediate results
*                      w20-29: intermediate results
*                      w31: round counter value
*
*
*
*
*
*
*
*
*
/*************************************************/

keccak_permutation:

/* x4 as pointer to W31 */
li x4, 31

/* Copy Address of RC0 in X3  */
/* X3 is incremented each four round to address the correct RC in DMEM */
addi x3, x5, 0

/* Load DMEM(0) into WDR w31*/
bn.lid x4, 0(x3++)

/* Load round counter (rc0) into PQSR*/
pq.pqsrw 8, w31

loopi 6, 83
loopi 2, 80

/*************************************************/
/*                  Keccak Round                 */
/*************************************************/

/* Theta XOR Computation*/

bn.xor w10, w0, w2
bn.xor w11, w1, w3

bn.xor w10, w10, w4
bn.xor w11, w11, w5

bn.xor w10, w10, w6
bn.xor w11, w11, w7

bn.xor w10, w10, w8
bn.xor w11, w11, w9

/* Theta Parity Plain Computation */

pq.parity w10, w11

/* Theta, Rho and Pi Merged Computation */


pq.xorr w20.0, w0.0, w10.0, 1, 0
pq.xorr w24.0, w0.1, w10.1, 1, 0
pq.xorr w28.0, w0.2, w10.2, 1, 0
pq.xorr w22.0, w0.3, w10.3, 1, 0
pq.xorr w26.0, w1.0, w11.0, 1, 1

pq.xorr w26.1, w2.0, w10.0, 1, 0
pq.xorr w20.1, w2.1, w10.1, 1, 0
pq.xorr w24.1, w2.2, w10.2, 1, 0
pq.xorr w28.1, w2.3, w10.3, 1, 0
pq.xorr w22.1, w3.0, w11.0, 1, 1

pq.xorr w22.2, w4.0, w10.0, 1, 0
pq.xorr w26.2, w4.1, w10.1, 1, 0
pq.xorr w20.2, w4.2, w10.2, 1, 0
pq.xorr w24.2, w4.3, w10.3, 1, 0
pq.xorr w28.2, w5.0, w11.0, 1, 1

pq.xorr w28.3, w6.0, w10.0, 1, 0
pq.xorr w22.3, w6.1, w10.1, 1, 0
pq.xorr w26.3, w6.2, w10.2, 1, 0
pq.xorr w20.3, w6.3, w10.3, 1, 0
pq.xorr w24.3, w7.0, w11.0, 1, 1

pq.xorr w25.0, w8.0, w10.0, 1, 0
pq.xorr w29.0, w8.1, w10.1, 1, 0
pq.xorr w23.0, w8.2, w10.2, 1, 0
pq.xorr w27.0, w8.3, w10.3, 1, 0
pq.xorr w21.0, w9.0, w11.0, 1, 1

/* Chi Plain Computations */

pq.chi w20, w21
pq.chi w22, w23
pq.chi w24, w25
pq.chi w26, w27
pq.chi w28, w29

/* Iota Computation */

pq.ioata w20.0, w20.0, w20.0, 1

/* Theta XOR Computation*/

bn.xor w10, w20, w22
bn.xor w11, w21, w23

bn.xor w10, w10, w24
bn.xor w11, w11, w25

bn.xor w10, w10, w26
bn.xor w11, w11, w27

bn.xor w10, w10, w28
bn.xor w11, w11, w29

/* Theta Parity Plain Computation */

pq.parity w10, w11

/* Theta, Rho and Pi Merged Computation */

pq.xorr w0.0, w20.0, w10.0, 1, 0
pq.xorr w4.0, w20.1, w10.1, 1, 0
pq.xorr w8.0, w20.2, w10.2, 1, 0
pq.xorr w2.0, w20.3, w10.3, 1, 0
pq.xorr w6.0, w21.0, w11.0, 1, 1

pq.xorr w6.1, w22.0, w10.0, 1, 0
pq.xorr w0.1, w22.1, w10.1, 1, 0
pq.xorr w4.1, w22.2, w10.2, 1, 0
pq.xorr w8.1, w22.3, w10.3, 1, 0
pq.xorr w2.1, w23.0, w11.0, 1, 1

pq.xorr w2.2, w24.0, w10.0, 1, 0
pq.xorr w6.2, w24.1, w10.1, 1, 0
pq.xorr w0.2, w24.2, w10.2, 1, 0
pq.xorr w4.2, w24.3, w10.3, 1, 0
pq.xorr w8.2, w25.0, w11.0, 1, 1

pq.xorr w8.3, w26.0, w10.0, 1, 0
pq.xorr w2.3, w26.1, w10.1, 1, 0
pq.xorr w6.3, w26.2, w10.2, 1, 0
pq.xorr w0.3, w26.3, w10.3, 1, 0
pq.xorr w4.3, w27.0, w11.0, 1, 1

pq.xorr w5.0, w28.0, w10.0, 1, 0
pq.xorr w9.0, w28.1, w10.1, 1, 0
pq.xorr w3.0, w28.2, w10.2, 1, 0
pq.xorr w7.0, w28.3, w10.3, 1, 0
pq.xorr w1.0, w29.0, w11.0, 1, 1

/* Chi Plain Computations */

pq.chi w0, w1
pq.chi w2, w3
pq.chi w4, w5
pq.chi w6, w7
pq.chi w8, w9

/* Iota Computation */

pq.ioata w0.0, w0.0, w0.0, 1

/* Load DMEM(0) into WDR w0*/
bn.lid x4, 0(x3++)

/* Load round counter (rc0) into PQSR*/
pq.pqsrw 8, w31

/* End of Keccak Permutation */

ret


/***********************************************/
/*      24-bit Data Alignment Procedure       
*                                            
* @param[in]   : W20              
* @param[out]  : W21             
* clobbered registers: x4, W30, W30, W31     
*
*/
/***********************************************/

data_alignment:

/* Load Bitmask in W31*/
li x4, 31
la x31, bitmask
bn.lid x4, 0(x31)

/* Load All-Zero in W30*/
li x4, 30
la x31, allzero
bn.lid x4++, 0(x31) 

/* Mask sample and store it in W21*/
bn.and w21, w20, w31


/* Update Bitmask */
bn.or w30, w30, w31 << 32

/* Mask sample*/
bn.and w30, w30, w20 << 8

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 64

/* Mask sample*/
bn.and w30, w30, w20 << 16

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 96

/* Mask sample*/
bn.and w30, w30, w20 << 24

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 128

/* Mask sample*/
bn.and w30, w30, w20 << 32

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 160

/* Mask sample*/
bn.and w30, w30, w20 << 40

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 192

/* Mask sample*/
bn.and w30, w30, w20 << 48

/* Store sample in W21 */
bn.or w21, w21, w30


/* Update Bitmask */
bn.or w30, w30, w31 << 224

/* Mask sample*/
bn.and w30, w30, w20 << 56

/* Store sample in W21 */
bn.or w21, w21, w30

ret


/************************************************************/
/* Align chunk of samples (inside 5 WDRs) */
/*
* @param[in]  x10: address of raw Keccak samples inside WDRs
* @param[in]  x13: address of output WDR 
* @param[out] W[x13+i] for i in [0,6]
*
* clobbered registers: x10, x11, x12, x13,
*                      w10, w11, w12,
*                      w20, w21, w30
*
*/
/************************************************************/

align_chunks:

/* Load address of WDR for intermediate computation in x11 (W10 fixed)*/
li x11, 10

/* Load address of Input WDR for further function call in x12 (W20 fixed)*/
li x12, 20

/* Data Layout I */

/* Align samples for first WDR*/
bn.movr x12, x10
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Store S[3-0] in W[10]*/
li x11, 10
bn.movr x11, x10++

/* Store S[4] in W[11]*/
li x11, 11
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 (lower part)*/
bn.rshi w20, w11, w10 >> 192

/* Store S[7-5] in W[12]*/
li x11, 12
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 (upper part)*/
bn.or w20, w20, w12 << 128

/* Align samples for second WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Load All-Zero in W30*/
bn.addi w30, w30, 0
bn.rshi w20, w30, w12 >> 64

/* Align samples for third WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Data Layout II */

/* Store S[9] in W[10]*/
li x11, 10
bn.movr x11, x10++

/* Store S[13-10] in W[11]*/
li x11, 11
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 */
bn.or w20, w10, w11 << 64

/* Align samples for fourth WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Store S[14] in W[12]*/
li x11, 12
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 */
bn.rshi w20, w12, w11 >> 128

/* Align samples for fifth WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Data Layout I */

/* Align samples for sixth WDR*/
bn.movr x12, x10
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

/* Store S[18-15] in W[10]*/
li x11, 10
bn.movr x11, x10++

/* Store S[19] in W[11]*/
li x11, 11
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 (lower part)*/
bn.rshi w20, w11, w10 >> 192

/* Store S[23-20] in W[12]*/
li x11, 12
bn.movr x11, x10++

/* Combine 2 registers and store them in W20 (upper part)*/
bn.or w20, w20, w12 << 128

/* Align samples for second WDR*/
jal x1, data_alignment

/* Store */
li x11, 21
bn.movr x13++, x11

ret



/************************************************************/
/* Rejection Uniform */
/*
* @param[in]  x28: number of coefficients to be sampled left 
* @param[in]  x22: pointer of first output sample inside DMEM
* @param[in]  w22: all zero vector
* @param[out] DMEM[1024+x22+i] for i in [0,6]
*
* clobbered registers: x4 : internal variables
*                      x10: constant 112 (w14) for indirect register addressing
*                      x18: constant 176 (w24) for indirect register addressing
*                      x14: Read out flags
*                      x15: Current WDR word
*                      x16: Current WDR 
*                      x17: Current Desintation WDR
*                      x20: constant 24 for indirect register addressing
*                      x21: constant 14 for indirect register addressing
*                      x28: number of coefficients left to be sampled
*                      w10: intermediate result
*                      w11: intermediate result
*                      w12: intermediate result
*                      w20: intermediate result
*                      w21: intermediate result
*                      w30: constant value prime
*                      w31: constant value 24-bit mask
*
*/
/************************************************************/
rej_uniform: 

/* set fixed values to address w22 and w14*/
/* li x11, 176 */
li x10, 112

li x20, 24
li x21, 14

/* Load All-Zero in W23*/
li x4, 23
la x31, allzero
bn.lid x4, 0(x31) 

/* bn.mov w23, w22 */

/* Load index for output samples into PQSPR idx0 */
pq.srw 3, x18

/* Load index for input samples into PQSPR idx1 */
pq.srw 4, x10

/* Position of current source WDR - Initialize with 7 */
li x16, 7

/* Position inside current destination WDR - Initialize with 8 */
/* li x17, 8 */

/* Load Prime in W30*/
li x4, 30
la x31, prime
bn.lid x4, 0(x31)

/* Build Prime-Vector */
bn.or w30, w30, w30 << 32
bn.or w30, w30, w30 << 64
bn.or w30, w30, w30 << 128

/* Loop through WDRs containing potential sampels */
loop_source_wdr:

/* Position inside current source WDR - Initialize with 8 */
li x15, 8

/* Copy sample in W24 for comparison */
bn.movr x20, x21
addi x21, x21, 1

/* Reset word select inside w22*/
/*
li x10, 176
pq.srw 3, x18
*/

/* Load Bitmask in W31*/
li x4, 31
la x31, bitmask
bn.lid x4, 0(x31)

/* Loop for words inside WDR */
loop_source_wdr_word:

/* Mask sample in W24 and store it in W29*/
bn.and w29, w24, w31

/* Mask Prime in W30 and store it in W28*/
bn.and w28, w30, w31

/* Compare if sample < q */
bn.cmp w28, w29, FG0
csrrw x14, 1984, x0

/* Check for overflow (overflow <=> sample > q)*/
andi x14, x14, 1

li x4, 1
sub x15, x15, x4

/* If sample > q skip the storing of the sample*/
bne x14, x0, sample_rejected

/* Store sample */
pq.add.ind 0, 0, 0, 0, 0

/* Decrement number of coefficients left*/
li x4, 1
sub x28, x28, x4

/* Check if WDR full --> store it, increment DMEM address, reset WDR */
/* Update Loop Variable for WDR word */
li x4, 1
sub x17, x17, x4

li x4, 22
bne x17, x0, wdr_not_full

/* la x31, A_coeff_0
add x31, x31, x22
bn.sid x4, 0(x31) */

bn.sid x4, 16352(x22)
addi x22, x22, 32

bn.and w21, w21, w29
li x17, 8

/* Reset All Zero Vector */
bn.mov w22, w23

/* Reset WDR word select for W22*/
li x18, 176
pq.srw 3, x18

beq x0, x0, sample_rejected
wdr_not_full:

/* Increment destination word */
addi x18, x18, 1

sample_rejected:

/* Increment source word*/
addi x10, x10, 1

/* If no coefficient is left to be samples, jump out of the loop */
beq x28, x0, end_loops

/* Update source and destination indices (check if both necessary)*/
pq.srw 3, x18
pq.srw 4, x10

/* Update Mask */
bn.or w31, w23, w31 << 32

/* Loop for words inside WDR */
bne x15, x0, loop_source_wdr_word

/* Loop through WDRs containing potential samples */
li x4, 1
sub x16, x16, x4
bne x16, x0, loop_source_wdr

/* No potential samples left, but not finished */
li x19, 1
li x4, 22
la x31, expand_a_temp
bn.sid x4, 0(x31)

end_loops:

ret

/*************************************************/
/*                     UseHint                   */
/*
* @param[in]  x6: address of all-zero vector
* @param[in]  x4: address of coefficients
* @param[in]  w20: current hint bits
* @param[out] w10: result of UseHint
*
* clobbered registers: x3: internal register addressing
*                      x14: read out flags
*                      x15: read out flags
*                      w1: store constant 127
*                      w2: store constant 11275
*                      w3: store constant 1<<23
*                      w4: store constant 43
*                      w5: store constant 19464
*                      w6: store constant 4190208
*                      w7: store constant 0x0...0
*                      w8: store constant 0XF...F
*                      w9: store coefficients
*                      w10: sorting of coefficients
*                      w11: intermediate result
*                      w12: intermediate result
*                      w13: intermediate result
*                      w14: intermediate result
*                      w15: intermediate result
*                      w16: intermediate result                       
*
*/
/*************************************************/
use_hint:

/* Initialize WDR 10 with 0x0...0*/
li x3, 10
bn.lid x3++, 0(x6)

/* a1 = decompose(&a0, a) */
jal x1, decompose
/* WDR 15 = a1 , WDR 16 = a0 */

/* if(hint == 0) */

loopi 8, 45

/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.addi w11, w7, 1
bn.and w11, w11, w20
bn.cmp w11, w7, FG0

/* Check Zero Flag */
csrrw x14, 1984, x0
li x3, 8
andi x14, x14, 8

bne x3, x14, hint_not_zero
/* return a1 */
bn.rshi w10, w15, w10 >> 32
beq x0, x0, shift_coefficients

/* else */
hint_not_zero:

/* if(a0 > 0)*/

/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w16


/* Check Allzero Flag */
bn.cmp w7, w11, FG0
csrrw x14, 1984, x0
andi x15, x14, 8
srli x15, x15, 3

/* Check Carry Flag */
bn.rshi w11, w7, w11 >> 31
bn.cmp w7, w11, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

/* Check Flags: Carry = 1 if a0 < 0 ; Allzero = 1 if a0 == 0*/
or x15, x15, x14
li x3, 1
beq x3, x15, a0_leq_zero

/* return (a1 == 43) ?  0 : a1 + 1 */

/* From decompose: WDR 4 = 43 */
/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w15
bn.cmp w11, w4, FG0

/* Check Zero Flag */
csrrw x14, 1984, x0
li x3, 8
andi x14, x14, 8
bne x3, x14, a1_not_43

/* Store 0 if a1 == 43*/
bn.rshi w10, w7, w10 >> 32
beq x0, x0, shift_coefficients

a1_not_43:

/* Store a1+1 if a1 =/= 43*/
bn.addi w11, w11, 1
bn.rshi w10, w11, w10 >> 32
beq x0, x0, shift_coefficients

/* else */
a0_leq_zero:

/* return (a1 ==  0) ? 43 : a1 - 1 */

/* From decompose: WDR 4 = 43 */
/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w15
bn.cmp w11, w7, FG0

csrrw x14, 1984, x0
li x3, 8
andi x14, x14, 8
bne x3, x14, a1_not_zero

/* Store 43 if a1 == 0 */
bn.rshi w10, w4, w10 >> 32
beq x0, x0, shift_coefficients

a1_not_zero:

/* Store a1-1 if a1 =/= 0 */
bn.subi w11, w11, 1
bn.rshi w10, w11, w10 >> 32

shift_coefficients:
bn.rshi w15, w7, w15 >> 32
bn.rshi w16, w7, w16 >> 32
bn.rshi w20, w7, w20 >> 1

ret

/*************************************************/
/*                    Decompose                  */
/*
* @param[in]  x6: address of all-zero vector
* @param[in]  x4: address of coefficients
* @param[out] w15: a1
* @param[out] w16: a0
*
* clobbered registers: x3: internal register addressing
*                      x14: read out flags
*                      w1: store constant 127
*                      w2: store constant 11275
*                      w3: store constant 1<<23
*                      w4: store constant 43
*                      w5: store constant 19464
*                      w6: store constant 4190208
*                      w7: store constant 0x0...0
*                      w8: store constant 0XF...F
*                      w9: store coefficients
*                      w10: sorting of coefficients
*                      w11: intermediate result
*                      w12: intermediate result
*                      w13: intermediate result
*                      w14: intermediate result
*                         
*
*/
/*************************************************/

decompose:

/* Initialize all necessary WDRs with zero */
li x3, 0
loopi 18, 1
  bn.lid x3++, 0(x6) 

/* Load Prime into WDR w0*/
li x3, 0
la x31, prime
bn.lid x3, 0(x31)

/* Store 127 in WDR 1 */
bn.addi w1, w1, 127

/* Store 11275 in WDR 2 */
bn.addi w2, w2, 11
bn.rshi w2, w2, w7 >> 246
bn.addi w2, w2, 11

/* Store 1<<23 in WDR 3 */
bn.addi w3, w3, 1
bn.rshi w3, w3, w7 >> 233

/* Store 43 in WDR 4 */
bn.addi w4, w4, 43

/* Store 2*GAMMA2 = 190464 in WDR 5 (93 << 12) */
bn.addi w5, w5, 93
bn.rshi w5, w5, w7 >> 245

/* Store (Q-1)/2 = 4190208 in WDR 6 (1023 << 12) */
bn.addi w6, w6, 1023
bn.rshi w6, w6, w7 >> 244

/* Allzero in WDR 7 */

/* Store Mask in WDR 8 */
li x3, 8
la x31, bitmask32
bn.lid x3, 0(x31) 

/* Load Coefficients in WDR 9 */
li x3, 9
bn.lid x3, 0(x4) 

/* Work in WDR 10 */

/* Sort coefficients differently to store them easier in one WDR */
pq.add w10.7, w9.0, w7.0
pq.add w10.6, w9.1, w7.0
pq.add w10.5, w9.2, w7.0
pq.add w10.4, w9.3, w7.0
pq.add w10.3, w9.4, w7.0
pq.add w10.2, w9.5, w7.0
pq.add w10.1, w9.6, w7.0
pq.add w10.0, w9.7, w7.0


loopi 8, 52
/* a1  = (a + 127) >> 7 */
bn.and w11, w8, w10
bn.addi w11, w11, 127
bn.and w11, w8, w11
bn.rshi w11, w7, w11 >> 7
bn.and w11, w8, w11

/* a1*11275 + (1 << 23) */
bn.mulqacc.wo.z w11, w2.0, w11.0, 0
bn.add w11, w11, w3

/* (a1*11275 + (1 << 23)) >> 24 */
bn.rshi w12, w7, w11 >> 31
bn.addi w13, w13, 1
bn.cmp w12, w13, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

bn.rshi w11, w7, w11 >> 24

bne x14, x0, skip_mask0
bn.or w11, w11, w8 << 8
bn.and w11, w11, w8
skip_mask0:

/* ((43 - a1) >> 31) & a1 */
bn.sub w12, w4, w11
bn.and w12, w8, w12
bn.rshi w12, w7, w12 >> 31

bn.cmp w7, w12, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

beq x14, x0, skip_mask1
bn.rshi w12, w8, w7 >> 248
bn.or w12, w8, w12
bn.and w12, w12, w8
skip_mask1:

bn.and w12, w8, w12
bn.and w12, w12, w11

/* a1 ^= ((43 - a1) >> 31) & a1 */
bn.xor w12, w12, w11

/* *a0  = a - a1*2*GAMMA2 */
bn.mulqacc.wo.z w13, w12.0, w5.0, 0
bn.and w13, w8, w13
bn.and w14, w8, w10
bn.sub w13, w14, w13

/* *a0 -= (((Q-1)/2 - *a0) >> 31) & Q */
bn.sub w14, w6, w13
bn.and w14, w8, w14

bn.rshi w14, w7, w14 >> 31

bn.addi w17, w17, 0
bn.cmp w7, w14, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

beq x14, x0, skip_mask2
bn.rshi w11, w8, w7 >> 248
bn.or w14, w8, w14
bn.and w14, w14, w8
skip_mask2:

bn.and w14, w8, w14
bn.and w14, w0, w14
bn.sub w14, w13, w14


/* Store a1 and a0 in WDR15 and WDR16 */
bn.and w12, w8, w12
bn.or w15, w12, w15 << 32
bn.and w14, w8, w14
bn.or w16, w14, w16 << 32

/* Update WDR10 to process next coefficient */
bn.or w10, w7, w10 >> 32

ret

.section .data

/* Constants */
.globl prime
prime:
  .quad 0x00000000007fe001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

prime_dash:
  .quad 0x00000000fc7fdfff
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

omega:
  .quad 0x000064f7003fe201
  .quad 0x00039e4400581103
  .quad 0x00299658001bde2b
  .quad 0x0043e6e600294a67

psi:
  .quad 0x00581103000064f7
  .quad 0x001bde2b00039e44
  .quad 0x00294a6700299658
  .quad 0x001fea930043e6e6

n1:
  .quad 0x0000000000003ffe
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

omega_inv:
  .quad 0x0000000000454828
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

psi_inv:
  .quad 0x000000000061b633
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

r_dash:
  .quad 0x00000000002419ff
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

bitmask:
  .word 0x007FFFFF
  
bitmask_extended: 
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

bitmask32:
  .word 0xFFFFFFFF

bitmask32_extended: 
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

rc0:
  .quad 0x0000000000000001
  .quad 0x0000000000008082
  .quad 0x800000000000808a
  .quad 0x8000000080008000

rc1:
  .quad 0x000000000000808b
  .quad 0x0000000080000001
  .quad 0x8000000080008081
  .quad 0x8000000000008009

rc2:
  .quad 0x000000000000008a
  .quad 0x0000000000000088
  .quad 0x0000000080008009
  .quad 0x000000008000000a

rc3:
  .quad 0x000000008000808b
  .quad 0x800000000000008b
  .quad 0x8000000000008089
  .quad 0x8000000000008003

rc4:
  .quad 0x8000000000008002
  .quad 0x8000000000000080
  .quad 0x000000000000800a
  .quad 0x800000008000000a

rc5:
  .quad 0x8000000080008081
  .quad 0x8000000000008080
  .quad 0x0000000080000001
  .quad 0x8000000080008008

allzero:
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000


/* Challenge Seed */
.globl challenge_seed
challenge_seed:
.word 0xc5eb439f
.word 0x4d8ec3b0
.word 0xf6c6ac1c
.word 0x5607d332
.word 0x80304dab
.word 0xda08a239
.word 0x8ce17103
.word 0xf4c2d7b6

/* Rho (Seed) */
.globl expanda_seed  
expanda_seed:
.word 0xf1b4b637
.word 0x4f6e545b
.word 0xdc6da943
.word 0x64d57f19
.word 0xd70eaf61
.word 0x64377ce1
.word 0x7079332f
.word 0x420ec1ad

/* Nonce */  
.globl expanda_nonce 
expanda_nonce:
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

/* Mu */  
.globl digest_message
digest_message:
.word 0xdbbeaece
.word 0x8d03382a
.word 0x48d76766
.word 0xdd1e0858

.word 0x69336666
.word 0xb1b7d1dc
.word 0x17c19f31
.word 0x7b3ca7ec

.word 0x3292875c
.word 0x96bd237d
.word 0xb99b3b9b
.word 0x67c0534e

.word 0x0 
.word 0x0 
.word 0x0 
.word 0x0 

/* hint */
.globl hint0
hint0:
.word 0x100000
.word 0x4000
.word 0x100000
.word 0x0
.word 0x140
.word 0x40000001
.word 0x80100000
.word 0x8000004
.word 0x0
.word 0x20240
.word 0x20d
.word 0xc00
.word 0x20000010
.word 0x5000000
.word 0x2020000
.word 0x44000010
.word 0x0
.word 0x80900002
.word 0x800
.word 0x1004000
.word 0x40040400
.word 0x20010630
.word 0xc0000
.word 0x40
.word 0x8880
.word 0x89
.word 0x800900
.word 0x80880010
.word 0x10800080
.word 0x1
.word 0x400f000
.word 0x44000004

challenge_temp_0:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_temp_1:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_temp_2:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_temp_3:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_temp_4:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_temp_5:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_temp_6:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_temp_7:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

/* 1024 */
challenge_temp_8:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_temp_9:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_coef_0:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

challenge_coef_1:
  .quad 0x0000000900000008
  .quad 0x0000000B0000000A
  .quad 0x0000000D0000000C
  .quad 0x0000000F0000000E

challenge_coef_2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

challenge_coef_3:
  .quad 0x0000001900000018
  .quad 0x0000001B0000001A
  .quad 0x0000001D0000001C
  .quad 0x0000001F0000001E

challenge_coef_4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

challenge_coef_5:
  .quad 0x0000002900000028
  .quad 0x0000002B0000002A
  .quad 0x0000002D0000002C
  .quad 0x0000002F0000002E

challenge_coef_6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

challenge_coef_7:
  .quad 0x0000003900000038
  .quad 0x0000003B0000003A
  .quad 0x0000003D0000003C
  .quad 0x0000003F0000003E

challenge_coef_8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

challenge_coef_9:
  .quad 0x0000004900000048
  .quad 0x0000004B0000004A
  .quad 0x0000004D0000004C
  .quad 0x0000004F0000004E

challenge_coef_10:
  .quad 0x0000005100000050
  .quad 0x0000005300000052
  .quad 0x0000005500000054
  .quad 0x0000005700000056

challenge_coef_11:
  .quad 0x0000005900000058
  .quad 0x0000005B0000005A
  .quad 0x0000005D0000005C
  .quad 0x0000005F0000005E

challenge_coef_12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

challenge_coef_13:
  .quad 0x0000006900000068
  .quad 0x0000006B0000006A
  .quad 0x0000006D0000006C
  .quad 0x0000006F0000006E

challenge_coef_14:
  .quad 0x0000007100000070
  .quad 0x0000007300000072
  .quad 0x0000007500000074
  .quad 0x0000007700000076

challenge_coef_15:
  .quad 0x0000007900000078
  .quad 0x0000007B0000007A
  .quad 0x0000007D0000007C
  .quad 0x0000007F0000007E

challenge_coef_16:
  .quad 0x0000008100000080
  .quad 0x0000008300000082
  .quad 0x0000008500000084
  .quad 0x0000008700000086

challenge_coef_17:
  .quad 0x0000008900000088
  .quad 0x0000008B0000008A
  .quad 0x0000008D0000008C
  .quad 0x0000008F0000008E

challenge_coef_18:
  .quad 0x0000009100000090
  .quad 0x0000009300000092
  .quad 0x0000009500000094
  .quad 0x0000009700000096

challenge_coef_19:
  .quad 0x0000009900000098
  .quad 0x0000009B0000009A
  .quad 0x0000009D0000009C
  .quad 0x0000009F0000009E

challenge_coef_20:
  .quad 0x000000A1000000A0
  .quad 0x000000A3000000A2
  .quad 0x000000A5000000A4
  .quad 0x000000A7000000A6

challenge_coef_21:
  .quad 0x000000A9000000A8
  .quad 0x000000AB000000AA
  .quad 0x000000AD000000AC
  .quad 0x000000AF000000AE

challenge_coef_22:
  .quad 0x000000B1000000B0
  .quad 0x000000B3000000B2
  .quad 0x000000B5000000B4
  .quad 0x000000B7000000B6

challenge_coef_23:
  .quad 0x000000B9000000B8
  .quad 0x000000BB000000BA
  .quad 0x000000BD000000BC
  .quad 0x000000BF000000BE

challenge_coef_24:
  .quad 0x000000C1000000C0
  .quad 0x000000C3000000C2
  .quad 0x000000C5000000C4
  .quad 0x000000C7000000C6

challenge_coef_25:
  .quad 0x000000C9000000C8
  .quad 0x000000CB000000CA
  .quad 0x000000CD000000CC
  .quad 0x000000CF000000CE

challenge_coef_26:
  .quad 0x000000D1000000D0
  .quad 0x000000D3000000D2
  .quad 0x000000D5000000D4
  .quad 0x000000D7000000D6

challenge_coef_27:
  .quad 0x000000D9000000D8
  .quad 0x000000DB000000DA
  .quad 0x000000DD000000DC
  .quad 0x000000DF000000DE

challenge_coef_28:
  .quad 0x000000E1000000E0
  .quad 0x000000E3000000E2
  .quad 0x000000E5000000E4
  .quad 0x000000E7000000E6

challenge_coef_29:
  .quad 0x000000E9000000E8
  .quad 0x000000EB000000EA
  .quad 0x000000ED000000EC
  .quad 0x000000EF000000EE

challenge_coef_30:
  .quad 0x000000F1000000F0
  .quad 0x000000F3000000F2
  .quad 0x000000F5000000F4
  .quad 0x000000F7000000F6

challenge_coef_31:
  .quad 0x000000F9000000F8
  .quad 0x000000FB000000FA
  .quad 0x000000FD000000FC
  .quad 0x000000FF000000FE

.globl signature_coef_0_0
signature_coef_0_0:
.word 0x7f9914
.word 0x5610
.word 0x7e0369
.word 0x7ee049
.word 0x7f7d07
.word 0x7f9e1a
.word 0x7f8c2d
.word 0x7e3946
.word 0x7dec3d
.word 0x7e1dd0
.word 0x7e7ffc
.word 0x9f86
.word 0x647
.word 0x7ed08e
.word 0xef67
.word 0x528b
.word 0x7debc0
.word 0x10ccf
.word 0x71c0
.word 0x1bbb8
.word 0x7e0ee5
.word 0x4786
.word 0x1a201
.word 0x133bd
.word 0x7de95f
.word 0x177f9
.word 0xea69
.word 0x1c9a1
.word 0x7ea6cc
.word 0x7eaa96
.word 0x912
.word 0x7fa38b
.word 0x7e29ad
.word 0x7e03bf
.word 0x7e911c
.word 0x7f2e2e
.word 0x7f85fc
.word 0x56ea
.word 0x7fc492
.word 0x1ee58
.word 0xff0e
.word 0x180e
.word 0x98c
.word 0x1c2ed
.word 0x7ee3f3
.word 0x7f2110
.word 0x7fa271
.word 0x108da
.word 0x1089f
.word 0x16987
.word 0x7fdb76
.word 0x1bce3
.word 0x5273
.word 0x7e1044
.word 0x1a37b
.word 0x7e0e68
.word 0x7e81ce
.word 0x7e876e
.word 0x7f7e6b
.word 0x7e76cd
.word 0x15b28
.word 0x7e678d
.word 0x10e93
.word 0x7eb68d
.word 0x7e875e
.word 0x1ce63
.word 0x7ec645
.word 0x7ecfa6
.word 0x7eff8a
.word 0x7e1d6a
.word 0x30c
.word 0x7ed404
.word 0x3b77
.word 0x7fc4a7
.word 0x7e1704
.word 0x7f967d
.word 0x7fb2c3
.word 0x14735
.word 0x7ead9b
.word 0x7f3c4f
.word 0x14f55
.word 0xbb20
.word 0x1cd51
.word 0x29cd
.word 0x7f201d
.word 0x7f71d6
.word 0x1a312
.word 0x7f50a5
.word 0x7f9fd0
.word 0x7f792a
.word 0x1580d
.word 0x7f28c6
.word 0x1418f
.word 0x7eb152
.word 0x7e6253
.word 0x1cee0
.word 0x7e891b
.word 0x7f423e
.word 0x7ebd0f
.word 0x7f05b0
.word 0x7f2732
.word 0x1dfad
.word 0x1137e
.word 0x14420
.word 0x17b33
.word 0xe88
.word 0x7ea859
.word 0xafce
.word 0xa2a3
.word 0x7e3326
.word 0x3651
.word 0x7debcc
.word 0x7e28ab
.word 0x7cd9
.word 0x7f5eed
.word 0x7f8093
.word 0x7e658b
.word 0x914d
.word 0x7f0ab9
.word 0x8674
.word 0x7e9f18
.word 0x7e81bd
.word 0x7e5b87
.word 0x6765
.word 0x7ed726
.word 0xc919
.word 0xa75b
.word 0x7f1e3e
.word 0x7ef59c
.word 0xd92
.word 0x7e6d4c
.word 0x15863
.word 0x1a60a
.word 0x1d2ac
.word 0x1a64
.word 0xadb9
.word 0x12ccd
.word 0x8e78
.word 0x4411
.word 0x7edfab
.word 0x7f2995
.word 0x9e2a
.word 0xcd24
.word 0x7e6807
.word 0x18932
.word 0x7fac5b
.word 0x1b0ee
.word 0xe0ce
.word 0xc04
.word 0x7e805e
.word 0x7ed4ec
.word 0xb359
.word 0x7e2b2e
.word 0x7e7cfb
.word 0x7e7788
.word 0x7f5e1e
.word 0x1517c
.word 0x7e563b
.word 0x7e548a
.word 0x7fcf25
.word 0x7f95f7
.word 0x1706c
.word 0x7e376b
.word 0x7e9c9b
.word 0x1d7ef
.word 0x277e
.word 0xbc92
.word 0x7e134c
.word 0x7e5a68
.word 0x15cf8
.word 0x7ee803
.word 0x7e5070
.word 0x7f4d3d
.word 0xf210
.word 0x7fdcce
.word 0x8764
.word 0x7de0e8
.word 0x18349
.word 0x7f528a
.word 0x53ac
.word 0xc729
.word 0xd887
.word 0x7e719c
.word 0x7ef82a
.word 0x7e4414
.word 0x7f08ba
.word 0x9938
.word 0xc104
.word 0x7ee7ac
.word 0x12e7d
.word 0x18c6b
.word 0x7f876d
.word 0x7f76ac
.word 0x5ed5
.word 0x315d
.word 0x7f9c3b
.word 0x7fa8d5
.word 0x18cf1
.word 0x7de351
.word 0x1078
.word 0x1e004
.word 0x7f8fcf
.word 0x7df272
.word 0x7e7d12
.word 0x1ad36
.word 0x7b44
.word 0x19154
.word 0x124b0
.word 0xde09
.word 0x1e50
.word 0x8576
.word 0x7fc751
.word 0x141ea
.word 0x7e2550
.word 0x1d92d
.word 0x7e1f8d
.word 0x1e50c
.word 0x7e62a5
.word 0x7f03a4
.word 0x7de326
.word 0xac15
.word 0x19ebe
.word 0x7f1bd6
.word 0x7e89b6
.word 0x196ea
.word 0x7eb5e3
.word 0x7e01e0
.word 0x7fb531
.word 0x7e5aca
.word 0x1588d
.word 0xc1ad
.word 0x7e85ba
.word 0x31a3
.word 0x7e6662
.word 0x7eb3b6
.word 0x7e8605
.word 0x7f33af
.word 0x7f994f
.word 0x14e08
.word 0xe94a
.word 0x7f7d15
.word 0x7f38af
.word 0x19351
.word 0xd4ae
.word 0x7e2733
.word 0x7f74d5
.word 0x7e4fc8
.word 0x120dc
.word 0x153fa
.word 0x7fda0a
.word 0xd244
.word 0x13e41
.word 0x7fc8eb
.word 0x7effa1
.word 0x7f7582
.word 0x7e7127
.word 0x7f3f70
.word 0x7f2a30
.word 0x7e872b
.word 0x335b
.word 0x7f7515
.word 0x7f81ab
.word 0x7f6578
.word 0x7f5f9b
.word 0x4712
.word 0x16a7a
.word 0x7e5603
.word 0x7e9dfc
.word 0x1728f
.word 0x7e24cf
.word 0x11209
.word 0x1bd22
.word 0xa507
.word 0x7ef117
.word 0x7f9a15
.word 0xc677
.word 0x44e4
.word 0x16774
.word 0x12562
.word 0x4b1c
.word 0xe991
.word 0x197f5
.word 0x18d73
.word 0xd8b5
.word 0x7f9e3f
.word 0x7ef4b6
.word 0x7fcb2e
.word 0x1e45f
.word 0x7e666a
.word 0x7f39fb
.word 0x149ca
.word 0x1fcc0
.word 0x7e8768
.word 0x7eea4c
.word 0xa42a
.word 0x1f0b
.word 0x1023e
.word 0x7ed8a1
.word 0x7f83eb
.word 0x549d
.word 0x1bf70
.word 0x1aa53
.word 0x7f8ca0
.word 0x82c7
.word 0x7f0b3d
.word 0x7fb8d2
.word 0x1d26c
.word 0x7ef426
.word 0x41ae
.word 0x17f24
.word 0x1bde4
.word 0x7fa0ac
.word 0x1eccf
.word 0x972d
.word 0x7e0038
.word 0x7eec54
.word 0x161e7
.word 0x7dfc8e
.word 0x145c6
.word 0x7f46c1
.word 0x1eaa8
.word 0x7fa336
.word 0x1e8df
.word 0x7fa187
.word 0x7ebb50
.word 0x39da
.word 0xa4b4
.word 0x7f57e6
.word 0xc4d6
.word 0x7e004a
.word 0x7f1219
.word 0x7147
.word 0x7ef1cb
.word 0x7eb297
.word 0xbea1
.word 0xeaab
.word 0x7e59b5
.word 0x7f63cd
.word 0x7f6606
.word 0x7f646b
.word 0x4a49
.word 0x106be
.word 0x16fba
.word 0xa0a1
.word 0x1b2c3
.word 0x7f0825
.word 0x7f5e24
.word 0xf240
.word 0x7ee70f
.word 0x1d15b
.word 0x1e3c4
.word 0x189d
.word 0x7eff26
.word 0x7ed235
.word 0x45ec
.word 0xcd02
.word 0x7f6458
.word 0x1ea35
.word 0x1b09d
.word 0x7e1567
.word 0x7e9c12
.word 0xd34e
.word 0x7e2dcc
.word 0x1f86c
.word 0x7e653a
.word 0x7f5ebc
.word 0x7c53
.word 0xb501
.word 0x7ed4ca
.word 0x7e7983
.word 0x7f1f99
.word 0x7eb1e0
.word 0x13026
.word 0x7e082f
.word 0x7ec600
.word 0x13b8c
.word 0x7f9d85
.word 0x94f
.word 0x1b0d2
.word 0x7ed5dc
.word 0xe4ca
.word 0x1d9d7
.word 0x7e533b
.word 0x7fce6b
.word 0x7e376a
.word 0x7e83b0
.word 0x7f08ad
.word 0x7f331b
.word 0x1f407
.word 0x653d
.word 0x5663
.word 0xcbca
.word 0xf135
.word 0x7f790b
.word 0x1a027
.word 0x7e2c53
.word 0x1bce
.word 0x1d0af
.word 0x7f101e
.word 0x7f5ace
.word 0x1daaa
.word 0x1d20a
.word 0x175e6
.word 0x7de63c
.word 0x1703
.word 0xb4ff
.word 0x7571
.word 0x7f23c4
.word 0x7fa5ed
.word 0x1e642
.word 0x7f3ae1
.word 0xc951
.word 0x1f644
.word 0x110fa
.word 0x157ce
.word 0x10e
.word 0x184e7
.word 0xcf07
.word 0xc317
.word 0x7e93d5
.word 0x1570f
.word 0x1a93f
.word 0x7fac4d
.word 0x99bb
.word 0x7ee954
.word 0x7e8b1f
.word 0x7de0
.word 0x8c93
.word 0x7f1485
.word 0xd6f7
.word 0x15ad0
.word 0x7f9577
.word 0x16b68
.word 0x7f0c7a
.word 0x7e5a43
.word 0x22a1
.word 0x7ecdf5
.word 0x43f1
.word 0x1ef26
.word 0x85e2
.word 0xeeda
.word 0x1f948
.word 0x7e307f
.word 0x7f2b62
.word 0x7f36d7
.word 0x7f1eb8
.word 0x504a
.word 0x88ad
.word 0x6d80
.word 0x7fc5da
.word 0xef90
.word 0x1f090
.word 0x7f7fe0
.word 0x7e9ba3
.word 0x7fa95d
.word 0x7df3bf
.word 0x856a
.word 0x15c4d
.word 0x9569
.word 0x3a01
.word 0x7f8e7b
.word 0x7e8f12
.word 0x19ecc
.word 0x7eb136
.word 0x15f2a
.word 0x7e984f
.word 0x166b0
.word 0x7efdbd
.word 0x7edf57
.word 0x1e83b
.word 0x7fc8c0
.word 0x18c82
.word 0x13b12
.word 0x7f769b
.word 0x54d0
.word 0x16e9b
.word 0x7e4bc7
.word 0x2fc5
.word 0x7ea4a1
.word 0xb893
.word 0x2bb6
.word 0x7e4586
.word 0x8c4b
.word 0x7e332d
.word 0x7fca23
.word 0x1c152
.word 0x1605
.word 0x13e83
.word 0x7eebe5
.word 0x12eb3
.word 0x7e0bde
.word 0x7fbe68
.word 0x5672
.word 0x7f5f4d
.word 0x7faa69
.word 0x1482
.word 0x7e7dba
.word 0x16b5d
.word 0x4922
.word 0x7efeb6
.word 0x2223
.word 0x7f48a7
.word 0x43a2
.word 0x15075
.word 0x7ef950
.word 0x7deb0d
.word 0x7e43ee
.word 0x7e6bf1
.word 0x7eb5a2
.word 0x1733d
.word 0x7e09c8
.word 0xc741
.word 0x7fb87d
.word 0x7fa157
.word 0x9b5b
.word 0x7f4a90
.word 0x7df17f
.word 0x7fdf9d
.word 0x17fca
.word 0xd3c1
.word 0x13108
.word 0x7e870f
.word 0x7e46c8
.word 0x8d95
.word 0x7fcec9
.word 0x7e2558
.word 0x7f7bb2
.word 0x7e4010
.word 0x7fab26
.word 0x7e7049
.word 0x7fa9f6
.word 0x108d0
.word 0x7ea8c5
.word 0x7f8a2c
.word 0x4319
.word 0x8a7c
.word 0xb01f
.word 0x7eca0c
.word 0x7de68e
.word 0x136a
.word 0x7eb28a
.word 0x7f7b96
.word 0x7f5c2e
.word 0x7e51bd
.word 0x61c8
.word 0x1b259
.word 0x7f1cc1
.word 0x13f5b
.word 0x19af7
.word 0x7ea7fa
.word 0x7e3b5f
.word 0x7e9c96
.word 0x7ed195
.word 0x38b9
.word 0xdf2f
.word 0x18948
.word 0x7ece44
.word 0x7eb0c6
.word 0x7de5cf
.word 0x19f69
.word 0x119b1
.word 0x1c6ed
.word 0x1d980
.word 0x13db4
.word 0x7f131e
.word 0x7edb1b
.word 0x14a13
.word 0x94be
.word 0x1f902
.word 0x149e
.word 0x7f57bd
.word 0x48b5
.word 0x7f2d9b
.word 0x7ee2e3
.word 0x2cf8
.word 0xc0a4
.word 0xf70d
.word 0x3327
.word 0x7e8107
.word 0x9624
.word 0x17f82
.word 0xbbf6
.word 0x7fa6e1
.word 0x41fa
.word 0x124e0
.word 0x1859d
.word 0xbb75
.word 0x7f3c0b
.word 0x198c6
.word 0xb201
.word 0x7f51cb
.word 0x7eccd9
.word 0x1294a
.word 0x7e02ef
.word 0x7365
.word 0x7fa9cc
.word 0x7f1522
.word 0x1c99f
.word 0x3265
.word 0x2515
.word 0x3a60
.word 0x1f815
.word 0x1d1f6
.word 0x1f37
.word 0x7e7f12
.word 0x7ee41c
.word 0xd48a
.word 0xce00
.word 0x1fbeb
.word 0x7fb78e
.word 0x17740
.word 0x17c60
.word 0x95f9
.word 0x7dfcb1
.word 0x7decbb
.word 0xe8cf
.word 0x7e7f4e
.word 0x7f1f84
.word 0x2739
.word 0x7e5b02
.word 0x7f8660
.word 0xfee3
.word 0x7f005d
.word 0x110f0
.word 0x7f5404
.word 0x1125b
.word 0x16e51
.word 0x7f64aa
.word 0x7f6afd
.word 0x1c33f
.word 0x7ef7c7
.word 0x7f4380
.word 0xc82f
.word 0x1404f
.word 0x7fce9e
.word 0x7ea484
.word 0x7de87c
.word 0x7f0dfd
.word 0xbe54
.word 0x7e649c
.word 0x1d24b
.word 0x16895
.word 0x7e8d4a
.word 0x7ef83f
.word 0x6561
.word 0x7fb832
.word 0x33fc
.word 0x7de44f
.word 0x1c700
.word 0xf5ea
.word 0xc8d8
.word 0x168d9
.word 0x1d7f4
.word 0xd29e
.word 0x7ef13a
.word 0x7f208d
.word 0x1b62b
.word 0x1d175
.word 0x1cf13
.word 0x18e52
.word 0x20b1
.word 0x7efd73
.word 0xb57c
.word 0x16d4a
.word 0x1d6b0
.word 0xd4ec
.word 0x7e0d24
.word 0x7e6624
.word 0x1037e
.word 0x8b00
.word 0xc68
.word 0x12090
.word 0x1aef1
.word 0x91ff
.word 0x7ebb86
.word 0x15674
.word 0x7eec4e
.word 0x18a74
.word 0x13470
.word 0x7dfb72
.word 0x1ec31
.word 0x9af4
.word 0x1d8c5
.word 0x7f1bc9
.word 0x5339
.word 0x12424
.word 0x13452
.word 0x8eeb
.word 0xdab4
.word 0x7e76ee
.word 0x7f42b7
.word 0xc844
.word 0x49a2
.word 0x7df145
.word 0x1ba28
.word 0x7f608d
.word 0x1571b
.word 0x7f1a5d
.word 0x7e1f2f
.word 0x7f4392
.word 0x5536
.word 0x125b7
.word 0xa097
.word 0x7fbb6a
.word 0x7f2630
.word 0x7741
.word 0x7274
.word 0x2a4f
.word 0x9e51
.word 0x7e9e46
.word 0x59b4
.word 0x7dfe44
.word 0x7efa3b
.word 0x9eda
.word 0x1841f
.word 0xbee1
.word 0x1697
.word 0x7fc2e7
.word 0x1ff83
.word 0x1dd38
.word 0x1fe91
.word 0xb100
.word 0x7f9ad0
.word 0x7ee6
.word 0xb131
.word 0x7e06f4
.word 0x7e3ee4
.word 0x7e3140
.word 0x1b530
.word 0x7f6548
.word 0x7e38da
.word 0x7e13cf
.word 0xa718
.word 0x7eabf9
.word 0x7e19c3
.word 0x7f57a6
.word 0x1b829
.word 0x13ea0
.word 0x7239
.word 0x1fa6f
.word 0x7f4f89
.word 0x7e711f
.word 0x7dbe
.word 0x3567
.word 0x6d61
.word 0x7f6e24
.word 0x179b0
.word 0x8a35
.word 0xf2c
.word 0x14d17
.word 0x9b0d
.word 0x7fab87
.word 0x1ad62
.word 0x1b369
.word 0x1510e
.word 0x7df3cb
.word 0x7f0334
.word 0xc07d
.word 0x7e5544
.word 0x1702
.word 0x7f6d47
.word 0x19599
.word 0x7747
.word 0x8e6f
.word 0x7e2f3c
.word 0x7e00c9
.word 0x7e438c
.word 0x1fe33
.word 0x1f33b
.word 0x7e9280
.word 0x7ec87a
.word 0x7f4730
.word 0x169c0
.word 0x7e3104
.word 0x7e16e6
.word 0x1a2c3
.word 0xdcf9
.word 0x7f8faf
.word 0x14105
.word 0x7f4846
.word 0x7e846b
.word 0x7df5de
.word 0x1fd7d
.word 0x1b770
.word 0xc919
.word 0x1e83e
.word 0x11f34
.word 0xcade
.word 0x7ea818
.word 0x1509b
.word 0xb0c3
.word 0xe563
.word 0x12918
.word 0x687f
.word 0x7e82ee
.word 0x7e9883
.word 0x7fc47b
.word 0x192b3
.word 0x56e1
.word 0x7f6109
.word 0x7e073d
.word 0x3f0e
.word 0x7eeeac
.word 0x1c3d5
.word 0x7de7af
.word 0x7ea371
.word 0x7e8be0
.word 0xfbb6
.word 0x7f49c1
.word 0xd6e
.word 0x16ca5
.word 0x7fb2c8
.word 0x1e3ab
.word 0x16493
.word 0x9c37
.word 0x7e8b4c
.word 0x7f6cd8
.word 0x7efc4c
.word 0x7f214f
.word 0x7e45fe
.word 0xf840
.word 0x7f3155
.word 0xc43c
.word 0x7bfc
.word 0x1d5f3
.word 0x7ed759
.word 0x7ec243
.word 0x7e7e1a
.word 0x14f25
.word 0x7f93c2
.word 0xb710
.word 0x7fa18e
.word 0x1f4f0
.word 0x7fc8b7
.word 0x1c43e
.word 0x7f83b2
.word 0x7fb3f0
.word 0x7f674f
.word 0xd283
.word 0x7f7b5a
.word 0x371b
.word 0x7df586
.word 0x93e4
.word 0x10323
.word 0x7ea293
.word 0x7e81a0
.word 0x18717
.word 0x7f493b
.word 0x1027f
.word 0x7e4ce7
.word 0x1f7ef
.word 0xb48e
.word 0x168cf
.word 0x7e734a
.word 0x7f4993
.word 0x7e6bae
.word 0x1b590
.word 0x7720
.word 0x16ad4
.word 0x7df6aa
.word 0x7ea02b
.word 0xcc90
.word 0x12c69
.word 0x10150
.word 0x168f6
.word 0x2dbd
.word 0xdf1a
.word 0x7e02fb
.word 0x7fc0f3
.word 0x8e59
.word 0x2e2d
.word 0xa554
.word 0x122e9
.word 0x4b24
.word 0x12e8f
.word 0x7f762a
.word 0x9ee
.word 0x15660
.word 0x15684
.word 0x7ec39c
.word 0x7e7eda
.word 0x49cc
.word 0x7e0ef8
.word 0x18d80
.word 0xd3c
.word 0x7eaa80
.word 0x14978
.word 0x7f432c
.word 0x15268
.word 0x7eb462
.word 0x7edc52
.word 0x7e11c4
.word 0x7fd590
.word 0x19c20
.word 0x11fc6
.word 0x7e8bd7
.word 0x831f
.word 0x2b01
.word 0x7ecbb2
.word 0x11521
.word 0x85e8
.word 0x7efaa4
.word 0x7e4e14
.word 0x327
.word 0x1a51f
.word 0x7ea619
.word 0xfa1b
.word 0x7f9337
.word 0xab9e
.word 0x16756
.word 0x7e5904
.word 0x4b64
.word 0x1fb43
.word 0x7f0be8
.word 0x680f
.word 0x2eb0
.word 0x7e956d
.word 0x1e54d
.word 0x7e1ea1
.word 0x1824b
.word 0x7ee650
.word 0x7de502
.word 0x7ec3ed
.word 0x512
.word 0x7f1a10
.word 0x142ed
.word 0x7fc376
.word 0x7f8c85
.word 0x7f13ab
.word 0x7f2c18
.word 0x8773
.word 0x13d6d
.word 0x7f0125
.word 0x7e76b9
.word 0x1d420
.word 0x16129
.word 0x7e8bf4
.word 0x7f9c0d
.word 0x7fd438
.word 0x128aa
.word 0x15c49
.word 0x19b03
.word 0x7e28ca
.word 0x70e4
.word 0x7f9bc0
.word 0x7e37bf
.word 0xc75f
.word 0x1912
.word 0x11d2f
.word 0x7ef332
.word 0xb314
.word 0x2acf
.word 0x7e0375
.word 0x9d03
.word 0x14c5f
.word 0x11ba1
.word 0x7e2c25
.word 0x7f43eb
.word 0x2ca9
.word 0xf727
.word 0x17b72
.word 0x7ef847
.word 0x1d305
.word 0x7f53cd
.word 0xc5d
.word 0x5aa4
.word 0x7ec54c
.word 0x7de308
.word 0x188d7
.word 0x7e5349
.word 0xc29
.word 0x7ea381
.word 0x1ab34
.word 0x7ecdb1
.word 0x8b21
.word 0x5d79
.word 0x1be9b
.word 0x7f7fa4
.word 0x2e6f
.word 0x13ae8
.word 0x7ebd2c
.word 0x17566
.word 0x7f1808
.word 0x5d20
.word 0x1f1ee
.word 0x1a0d5
.word 0x7f4abc
.word 0x7f35f3
.word 0x7f360b
.word 0x16454
.word 0x7fa8b9
.word 0x17f51
.word 0x7e7650
.word 0x18200
.word 0x7f3bea
.word 0x1cc59
.word 0x7e7c21
.word 0x7f1ace
.word 0x1f592
.word 0x1ca5f
.word 0x7ed2fd
.word 0x541b
.word 0x168dc
.word 0x7e2717
.word 0xf0b3
.word 0x7e454a
.word 0x15d8e
.word 0xabff
.word 0x7eb3ff
.word 0x7eaf1d
.word 0x7f3d67
.word 0x17312
.word 0x15fc0
.word 0x7ef09a
.word 0x7f2fde
.word 0x7ee93f
.word 0x1f3a3
.word 0x111f8
.word 0xaebf
.word 0x12b6b
.word 0x7e34b3
.word 0x15437
.word 0x7f83e4
.word 0xa6c


expand_a_temp:
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000

.globl t1_coef_0_0
t1_coef_0_0:
.word 0xc8
.word 0x2a5
.word 0x383
.word 0x3f0
.word 0x217
.word 0x3a2
.word 0x385
.word 0x296
.word 0x170
.word 0x310
.word 0x57
.word 0x36d
.word 0x26d
.word 0x370
.word 0x1b2
.word 0x126
.word 0x2be
.word 0x1f5
.word 0x2f6
.word 0x6
.word 0x24
.word 0x73
.word 0x108
.word 0x5
.word 0x109
.word 0x199
.word 0x21c
.word 0x3fb
.word 0x29c
.word 0x1ae
.word 0xbc
.word 0x354
.word 0x369
.word 0x212
.word 0x254
.word 0xa6
.word 0x3a
.word 0x2d0
.word 0xba
.word 0x117
.word 0x3a0
.word 0x140
.word 0x341
.word 0x257
.word 0x29
.word 0x1fe
.word 0x78
.word 0x395
.word 0x11c
.word 0x3b9
.word 0x1b1
.word 0x2fa
.word 0x176
.word 0x2d4
.word 0x398
.word 0x3a5
.word 0x32a
.word 0x10e
.word 0x174
.word 0x27e
.word 0x116
.word 0xb5
.word 0x145
.word 0xe8
.word 0x2
.word 0x83
.word 0x34c
.word 0x82
.word 0x2e8
.word 0x386
.word 0x1f3
.word 0x82
.word 0x21b
.word 0x1d7
.word 0x1ca
.word 0x27b
.word 0xbd
.word 0x31
.word 0x271
.word 0x269
.word 0x92
.word 0x1d4
.word 0x19e
.word 0x109
.word 0x1a9
.word 0x13e
.word 0x369
.word 0x156
.word 0x129
.word 0x73
.word 0x283
.word 0x280
.word 0x3f9
.word 0x154
.word 0xe8
.word 0x3d1
.word 0x1d1
.word 0x1b5
.word 0x32e
.word 0x30e
.word 0x204
.word 0x38d
.word 0x282
.word 0x281
.word 0x372
.word 0x326
.word 0x1be
.word 0x8f
.word 0x2ed
.word 0x42
.word 0x319
.word 0x194
.word 0x3a6
.word 0x16b
.word 0x17f
.word 0x1d9
.word 0x20d
.word 0x226
.word 0x3ae
.word 0x38
.word 0x150
.word 0x18a
.word 0x78
.word 0x331
.word 0x6b
.word 0x158
.word 0x177
.word 0x23c
.word 0x2f
.word 0x106
.word 0x1e4
.word 0x18c
.word 0x35d
.word 0x3c7
.word 0x15f
.word 0x176
.word 0x1c8
.word 0x171
.word 0xd8
.word 0x97
.word 0x183
.word 0x149
.word 0x36e
.word 0x1cd
.word 0x4d
.word 0x209
.word 0xef
.word 0x3c
.word 0x253
.word 0x1a9
.word 0x2e7
.word 0xc5
.word 0x1ad
.word 0xf2
.word 0x1c
.word 0x136
.word 0x3bc
.word 0x2b
.word 0x15e
.word 0x1f0
.word 0x12b
.word 0x104
.word 0xfc
.word 0x38f
.word 0x3e1
.word 0x3c5
.word 0x98
.word 0x209
.word 0x394
.word 0x370
.word 0x2ac
.word 0x2a9
.word 0x256
.word 0xfe
.word 0x3cf
.word 0xd9
.word 0x21a
.word 0x138
.word 0x253
.word 0x168
.word 0x295
.word 0x38e
.word 0x235
.word 0x142
.word 0x2a2
.word 0x1bf
.word 0xae
.word 0xde
.word 0x164
.word 0x38a
.word 0x115
.word 0x227
.word 0xdf
.word 0xfc
.word 0x3c
.word 0x93
.word 0x2eb
.word 0xb8
.word 0x26a
.word 0x142
.word 0x105
.word 0x314
.word 0x2c6
.word 0x14b
.word 0x2c7
.word 0x71
.word 0x26c
.word 0x23a
.word 0x103
.word 0x364
.word 0x37
.word 0x1a5
.word 0x2dc
.word 0x286
.word 0x56
.word 0x3d4
.word 0x37b
.word 0x1a9
.word 0xa9
.word 0x36b
.word 0x1fa
.word 0x273
.word 0x1ce
.word 0x171
.word 0xc5
.word 0x1bc
.word 0x284
.word 0x22b
.word 0x2de
.word 0x27
.word 0x124
.word 0x14b
.word 0x387
.word 0x274
.word 0xd6
.word 0x2e5
.word 0x3ea
.word 0x139
.word 0x168
.word 0xe8
.word 0x20e
.word 0x1b2
.word 0x303
.word 0x3aa
.word 0x36a
.word 0xe9
.word 0x2ad
.word 0xf0
.word 0x18d
.word 0xb4
.word 0x21f
.word 0x286
.word 0x1
.word 0xe1
.word 0x6
.word 0x2a4
.word 0x2e1
.word 0xd1
.word 0x2e6
.word 0x2a7
.word 0x14a
.word 0x3fd
.word 0x30b
.word 0x180
.word 0xcc
.word 0x325
.word 0x53
.word 0x1dc
.word 0x29b
.word 0x25a
.word 0x1f8
.word 0x3d8
.word 0x1a4
.word 0x162
.word 0x1d7
.word 0x12a
.word 0x28e
.word 0x152
.word 0x17f
.word 0xbb
.word 0x38d
.word 0xfc
.word 0x19a
.word 0x17e
.word 0xa5
.word 0x66
.word 0x345
.word 0xc2
.word 0x38
.word 0x1c7
.word 0x1e1
.word 0x181
.word 0x17d
.word 0x84
.word 0x33e
.word 0x54
.word 0x9b
.word 0x195
.word 0x392
.word 0x1d7
.word 0x95
.word 0x120
.word 0x34a
.word 0x379
.word 0x1f2
.word 0x2d7
.word 0x253
.word 0xb6
.word 0x21
.word 0xb3
.word 0x111
.word 0x3d3
.word 0x8b
.word 0x4c
.word 0x3e4
.word 0xd8
.word 0x146
.word 0x1f0
.word 0xec
.word 0x2c
.word 0x1fe
.word 0x140
.word 0x2ae
.word 0x6d
.word 0x339
.word 0x137
.word 0x247
.word 0x2d4
.word 0x3e4
.word 0x63
.word 0x70
.word 0x34f
.word 0x78
.word 0xd6
.word 0x184
.word 0x392
.word 0x81
.word 0x34d
.word 0xe2
.word 0x19d
.word 0x250
.word 0x99
.word 0xc5
.word 0x3c3
.word 0x3f1
.word 0x116
.word 0x33a
.word 0x33c
.word 0xd2
.word 0x217
.word 0x55
.word 0x166
.word 0xb0
.word 0x225
.word 0x17a
.word 0x331
.word 0xbc
.word 0x385
.word 0x276
.word 0x25
.word 0x29b
.word 0x3fc
.word 0x2c8
.word 0x3
.word 0xf
.word 0x386
.word 0x16b
.word 0x331
.word 0x259
.word 0x163
.word 0x2fb
.word 0x31a
.word 0x3ea
.word 0x317
.word 0x3
.word 0x124
.word 0x1ef
.word 0xe8
.word 0x253
.word 0x93
.word 0x312
.word 0x1b7
.word 0x10d
.word 0x108
.word 0x2a8
.word 0x42
.word 0x36d
.word 0x1bc
.word 0x2f2
.word 0x32c
.word 0x20f
.word 0x34f
.word 0x121
.word 0x291
.word 0xa5
.word 0x25c
.word 0x84
.word 0x38f
.word 0x11f
.word 0x2b8
.word 0x1aa
.word 0x18b
.word 0x1d0
.word 0xa0
.word 0x6b
.word 0x2c0
.word 0x1ac
.word 0x2c1
.word 0x34f
.word 0x3cc
.word 0x373
.word 0x2b7
.word 0x39
.word 0x3c8
.word 0x1d3
.word 0x214
.word 0x48
.word 0x152
.word 0x3f5
.word 0xcc
.word 0x19c
.word 0x181
.word 0x5a
.word 0x2bd
.word 0x3f4
.word 0x40
.word 0x7e
.word 0x44
.word 0x94
.word 0x210
.word 0x39e
.word 0x105
.word 0x256
.word 0x121
.word 0x37e
.word 0x40
.word 0x25b
.word 0x2db
.word 0x18f
.word 0x28d
.word 0x175
.word 0x61
.word 0x275
.word 0x328
.word 0x122
.word 0x250
.word 0x3f8
.word 0x2e2
.word 0x2a4
.word 0x348
.word 0x374
.word 0x124
.word 0x87
.word 0x386
.word 0x15b
.word 0x31c
.word 0x1c1
.word 0x362
.word 0x43
.word 0xa6
.word 0x139
.word 0x3b0
.word 0x60
.word 0x19d
.word 0x186
.word 0xdc
.word 0x3fb
.word 0x2a2
.word 0x32f
.word 0x32f
.word 0x324
.word 0x3ad
.word 0x357
.word 0x3ba
.word 0x1ad
.word 0x3da
.word 0x3c6
.word 0x380
.word 0x225
.word 0x3e6
.word 0x167
.word 0x3ea
.word 0x393
.word 0x159
.word 0x17a
.word 0x272
.word 0x345
.word 0x3ac
.word 0x261
.word 0x394
.word 0x129
.word 0x3
.word 0x228
.word 0x23e
.word 0x324
.word 0xd1
.word 0x14f
.word 0x336
.word 0x369
.word 0x361
.word 0x35a
.word 0x304
.word 0x1de
.word 0xd
.word 0x2d6
.word 0x1af
.word 0x398
.word 0xa6
.word 0x301
.word 0x3df
.word 0x85
.word 0x3f9
.word 0x1a9
.word 0x1ca
.word 0x122
.word 0xa1
.word 0x2e2
.word 0x306
.word 0x357
.word 0x197
.word 0x2bb
.word 0x46
.word 0x148
.word 0x27
.word 0x3c7
.word 0x20c
.word 0x30a
.word 0x333
.word 0x1da
.word 0x2ea
.word 0x4c
.word 0x342
.word 0x28b
.word 0x63
.word 0x77
.word 0x325
.word 0x2f
.word 0x35e
.word 0x181
.word 0x18
.word 0x41
.word 0x3ed
.word 0x16
.word 0x306
.word 0x47
.word 0x34b
.word 0x29
.word 0xcf
.word 0xaf
.word 0x19e
.word 0x1a9
.word 0x300
.word 0x82
.word 0xfe
.word 0x8c
.word 0x209
.word 0x2
.word 0x21
.word 0x7e
.word 0xa
.word 0x3cb
.word 0x11c
.word 0x2f2
.word 0x2b9
.word 0x157
.word 0xda
.word 0x3e1
.word 0x2ab
.word 0x156
.word 0x92
.word 0xc8
.word 0x10b
.word 0x4f
.word 0xcf
.word 0x13a
.word 0x7a
.word 0x289
.word 0x202
.word 0x393
.word 0x325
.word 0x144
.word 0x294
.word 0x105
.word 0x8a
.word 0x1ec
.word 0x109
.word 0x17d
.word 0xba
.word 0x1
.word 0x22f
.word 0x48
.word 0x168
.word 0x3ed
.word 0x278
.word 0xc7
.word 0x3b
.word 0x2e1
.word 0x27d
.word 0x9
.word 0xb9
.word 0x3b1
.word 0x329
.word 0x7d
.word 0x2f5
.word 0xa5
.word 0x225
.word 0x2a3
.word 0x22c
.word 0x244
.word 0x381
.word 0x1f3
.word 0x150
.word 0xaf
.word 0x1e6
.word 0x3e
.word 0x86
.word 0x3e3
.word 0x6a
.word 0x1d4
.word 0x10a
.word 0x47
.word 0x2c6
.word 0x2e4
.word 0x273
.word 0x283
.word 0x32c
.word 0x17a
.word 0x2a0
.word 0x392
.word 0x20e
.word 0x3a3
.word 0x366
.word 0x2e4
.word 0x208
.word 0x1f4
.word 0x11
.word 0x3ee
.word 0x15a
.word 0x129
.word 0x3
.word 0x25a
.word 0xcf
.word 0x171
.word 0x152
.word 0x2c7
.word 0x22
.word 0x30c
.word 0x299
.word 0x3da
.word 0x3e8
.word 0x90
.word 0x1ec
.word 0x164
.word 0x1a5
.word 0x134
.word 0x26a
.word 0x2a9
.word 0x2c4
.word 0x1ac
.word 0x193
.word 0x15b
.word 0x159
.word 0x254
.word 0x7f
.word 0x3ac
.word 0x142
.word 0x34
.word 0xe7
.word 0xa5
.word 0xfb
.word 0x84
.word 0xe5
.word 0xb4
.word 0x3a9
.word 0x3a4
.word 0x5d
.word 0x76
.word 0x28d
.word 0x242
.word 0x2e8
.word 0x135
.word 0x39d
.word 0x8e
.word 0x369
.word 0x168
.word 0x1fd
.word 0x257
.word 0x26d
.word 0x385
.word 0x1ac
.word 0x34a
.word 0x245
.word 0x61
.word 0x1f6
.word 0x3da
.word 0x6e
.word 0xbc
.word 0x2d1
.word 0x2e3
.word 0x353
.word 0x127
.word 0x1b9
.word 0x33d
.word 0x3a9
.word 0x1a4
.word 0x368
.word 0x10e
.word 0x243
.word 0x16e
.word 0x39f
.word 0x287
.word 0x396
.word 0x356
.word 0x1bf
.word 0x390
.word 0x196
.word 0x2ab
.word 0x3af
.word 0x19f
.word 0x1eb
.word 0x2ac
.word 0x252
.word 0x3bd
.word 0x185
.word 0x36d
.word 0x2bb
.word 0x25f
.word 0x367
.word 0x71
.word 0x224
.word 0x14f
.word 0x32a
.word 0x261
.word 0x43
.word 0xb3
.word 0x147
.word 0x304
.word 0x2e8
.word 0x242
.word 0x157
.word 0x3c7
.word 0x34e
.word 0x30
.word 0xde
.word 0x1a5
.word 0x296
.word 0x26c
.word 0x379
.word 0x338
.word 0x19d
.word 0x273
.word 0x2a6
.word 0xbf
.word 0x2bf
.word 0x301
.word 0x3c2
.word 0x181
.word 0x84
.word 0x2a
.word 0xc8
.word 0x28e
.word 0x35f
.word 0x10a
.word 0x61
.word 0x68
.word 0x332
.word 0x63
.word 0x3f4
.word 0x36d
.word 0x22
.word 0x1fc
.word 0x285
.word 0x180
.word 0x24f
.word 0x3bb
.word 0x3df
.word 0x3a1
.word 0x201
.word 0x1f
.word 0x18b
.word 0x256
.word 0x177
.word 0x348
.word 0x2ea
.word 0x270
.word 0x263
.word 0x3f5
.word 0x378
.word 0x12
.word 0x1b9
.word 0x39e
.word 0x61
.word 0x111
.word 0x1c1
.word 0x6
.word 0xb4
.word 0x14a
.word 0x304
.word 0x144
.word 0x1a8
.word 0x179
.word 0x2fd
.word 0x7d
.word 0x23c
.word 0x73
.word 0xaf
.word 0x2eb
.word 0x322
.word 0x1ab
.word 0x1c3
.word 0x57
.word 0x220
.word 0xc6
.word 0x20d
.word 0x25a
.word 0x167
.word 0x3cc
.word 0x2e9
.word 0x145
.word 0x1be
.word 0x3a6
.word 0x82
.word 0x362
.word 0x343
.word 0xca
.word 0x2a6
.word 0x3a7
.word 0x1a
.word 0x24
.word 0x16c
.word 0xcd
.word 0xea
.word 0x213
.word 0x1b0
.word 0x24d
.word 0x98
.word 0x2bf
.word 0x35
.word 0x1fa
.word 0x2f
.word 0xc7
.word 0x6f
.word 0x24c
.word 0x49
.word 0x1aa
.word 0x3bf
.word 0x18a
.word 0x30d
.word 0x1bd
.word 0x29a
.word 0x9e
.word 0x2fe
.word 0x1ca
.word 0x3a2
.word 0xf2
.word 0x49
.word 0x196
.word 0x231
.word 0x1ab
.word 0x396
.word 0x2d
.word 0x127
.word 0x3f0
.word 0x16d
.word 0x213
.word 0x13f
.word 0x259
.word 0x3bf
.word 0x1ac
.word 0x3e7
.word 0x3da
.word 0x356
.word 0x240
.word 0x26b
.word 0x2b9
.word 0x2b3
.word 0x65
.word 0x374
.word 0x2df
.word 0x9e
.word 0x197
.word 0x297
.word 0x139
.word 0x215
.word 0x25a
.word 0x217
.word 0x88
.word 0x34a
.word 0x34c
.word 0x2cb
.word 0x380
.word 0x12f
.word 0x78
.word 0x1cc
.word 0x3bf
.word 0x104
.word 0x353
.word 0x1ce
.word 0x1b2
.word 0x15b
.word 0xa2
.word 0x33a
.word 0x308
.word 0x3e0
.word 0x13c
.word 0x37b
.word 0x15d
.word 0x39
.word 0x6b
.word 0x75
.word 0x21e
.word 0x295
.word 0x14f
.word 0x8c
.word 0x31a
.word 0x198
.word 0x37c
.word 0x349
.word 0x1e9
.word 0x371
.word 0x125
.word 0x1f
.word 0xdc
.word 0x366
.word 0x3ed
.word 0x25a
.word 0x13
.word 0x1e9
.word 0x2c2
.word 0x146
.word 0x61
.word 0x247
.word 0x1bc
.word 0x352
.word 0x370
.word 0x2b7
.word 0x4a
.word 0x3e2
.word 0x1eb
.word 0x1f6
.word 0x1c6
.word 0x1ba
.word 0x215
.word 0x56
.word 0x3e8
.word 0x3e1
.word 0x3a9
.word 0x23d
.word 0x36d
.word 0x381
.word 0x3ab
.word 0x2b6
.word 0x163
.word 0x5
.word 0x2e0
.word 0x1f6
.word 0x37c
.word 0x19
.word 0x25
.word 0x4e
.word 0x102
.word 0x19e
.word 0x31a
.word 0x32b
.word 0x145
.word 0x3a
.word 0x393
.word 0x151
.word 0x2e4
.word 0x4d
.word 0x393
.word 0x318
.word 0x3a7
.word 0x1fa
.word 0xe5
.word 0x1a0
.word 0x3bb
.word 0xce
.word 0x9
.word 0x239
.word 0x12f
.word 0x320
.word 0x141
.word 0x34
.word 0x8d
.word 0x1a6
.word 0x35e
.word 0x349
.word 0x2f5
.word 0x21e
.word 0x195
.word 0x3a4
.word 0x2c6
.word 0x2bf
.word 0x21c
.word 0x5e
.word 0x53
.word 0x59
.word 0x1f4
.word 0xb5
.word 0x28c
.word 0x287
.word 0x264
.word 0x225
.word 0x83
.word 0x3b0
.word 0x3b8
.word 0x345
.word 0x389
.word 0x18a
.word 0x19c
.word 0x359
.word 0x187
.word 0x146
.word 0x11a
.word 0x3e8
.word 0x273
.word 0x26e
.word 0x291
.word 0x1ed
.word 0xcd
.word 0x261
.word 0x365
.word 0x297


A_coeff_0:
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
