/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* Dilithium-V Verify Implementation */


.section .text

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
loopi 8, 205

  /* Init w_acc_coef_0_0 */

  la x31, allzero
  bn.lid x0, 0(x31)
  li x31, 20480 
  
  loopi 32, 1
    bn.sid x0, 0(x31++) 
    
  /* For j in 0 to l */
  loopi 7, 55
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
    la x31, signature_coef_0_0
    slli x30, x7, 10
    add x31, x31, x30   
    
    loopi 32, 2
      bn.lid x2++, 0(x31)
      addi x31, x31, 32
    
    jal x1, ntt

    /* Store Signature Coefficients in DMEM */
    /* la x31, signature_coef_0_0 */
    li x31, 30720

    slli x9, x0, 10
    add x31, x31, x9
    
    li x2, 0
    loopi 32, 2
      bn.sid x2++, 0(x31)
      addi x31, x31, 32
    
    /* Increment x7 here not above!!!! */
    addi x7, x7, 1
    /*********************************/
    /*          A_i,k x z_k          */
    /*********************************/ 
    
    
    /* la x4, signature_coef_0_0 */
    li x4, 30720
    /* ToDo: Adapt Address */
    slli x9, x0, 10
    add x4, x4, x9
    /* la x5, A_coeff_0 */
    li x5, 19456
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
  /* ToDo: Add offset depending on k and l */
    
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
  /* ToDo: Add offset depending on k and l */
    
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
      loopi 4, 2
        bn.sid x2++, 0(x18)
        addi x18, x18, 32
  
  
      /* Number of 32-bit words to absorb */
      li x15, 32
  
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
bn.addi w16, w16, 31

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
  loopi 4, 1
    bn.lid x2++, 0(x31) 
    
  /* Initialize idx register */
  
  /* Set WDR10 as Destination */
  li x2, 80
  pq.srw 3, x2
  
  loopi 32, 31
  
  /* Initialize idx register */
  
  /* Set WDR20 as Source */
  li x2, 160
  pq.srw 4, x2
  
  /* Load Coefficients of 16 WDRs */
  li x2, 0
  loopi 1, 2
    bn.lid x2++, 0(x4)
    addi x4, x4, 32 
  
  /* Shifting */
  
  /* Byte 0 */
  bn.and w20, w0, w18
  
  bn.rshi w17, w19, w0 >> 28
  bn.and w17, w17, w18
  bn.or w20, w20, w17
  
  /* Byte 1 */
  bn.rshi w17, w19, w0 >> 64
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 8 
  
  bn.rshi w17, w19, w0 >> 92
  bn.and w17, w17, w18 
  bn.or w20, w20, w17 << 8 
  
  /* Byte 2 */
  bn.rshi w17, w19, w0 >> 128
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 16
  
  bn.rshi w17, w19, w0 >> 156
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 16
  
  /* Byte 3 */
  bn.rshi w17, w19, w0 >> 192
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 24

  bn.rshi w17, w19, w0 >> 220
  bn.and w17, w17, w18
  bn.or w20, w20, w17 << 24 


  /* 32-bit packed into first word of W20 */
  
  /* Move these words into Destination WDRs */
  loopi 1,1
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
  
  loopi 4, 2
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
  
    loopi 4, 2
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
li x10, 196

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
loopi 60, 64

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

li x31, 19456
add x31, x31, x22
bn.sid x4, 0(x31)
addi x22, x22, 32

/* bn.sid x4, 19456(x22)
addi x22, x22, 32
*/
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

loopi 8, 34

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
/* From decompose: WDR 16 = a0 */
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

/* return (a1 + 1) & 15 */

/* From decompose: WDR 4 = 15 */
/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w15
bn.addi w11, w11, 1
bn.and w11, w11, w4
bn.rshi w10, w11, w10 >> 32
beq x0, x0, shift_coefficients

/* else */
a0_leq_zero:

/* return (a1 - 1) & 15 */

/* From decompose: WDR 4 = 15 */
/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w15
bn.subi w11, w11, 1
bn.and w11, w8, w11
bn.and w11, w11, w4
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
*                      w2: store constant 1025
*                      w3: store constant 1<<21
*                      w4: store constant 15
*                      w5: store constant 2*GAMMA2
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

/* Store 1025 in WDR 2 */
bn.addi w2, w2, 1023
bn.addi w2, w2, 2

/* Store 1<<21 in WDR 3 */
bn.addi w3, w3, 1
bn.rshi w3, w3, w7 >> 235

/* Store 15 in WDR 4 */
bn.addi w4, w4, 15

/* Store 2*GAMMA2 = (prime-1)/32*2 in WDR 5 */
bn.subi w5, w0, 1
bn.rshi w5, w7, w5 >> 6
bn.rshi w5, w5, w7 >> 254

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


loopi 8, 40
/* a1  = (a + 127) >> 7 */
bn.and w11, w8, w10
bn.addi w11, w11, 127
bn.and w11, w8, w11
bn.rshi w11, w7, w11 >> 7
bn.and w11, w8, w11

/* a1*1025 + (1 << 21) */
bn.mulqacc.wo.z w11, w2.0, w11.0, 0
bn.add w11, w11, w3

/* (a1*1025 + (1 << 21)) >> 22 */
bn.rshi w12, w7, w11 >> 31
bn.addi w13, w13, 1
bn.cmp w12, w13, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

bn.rshi w11, w7, w11 >> 22

bne x14, x0, skip_mask0
bn.or w11, w11, w8 << 8
bn.and w11, w11, w8
skip_mask0:

/* a1 = a1 & 15 */
bn.and w12, w4, w11

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
challenge_seed:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

/* Rho (Seed) */  
expanda_seed:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

/* Nonce */  
expanda_nonce:
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

/* Mu */  
digest_message:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

/* hint */
hint0:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

hint1:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

hint2:  
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

hint3:  
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

hint4:  
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

hint5:  
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

hint6:  
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  
hint7:  
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000  
  
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

signature_coef_0_0:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

signature_coef_0_1:
  .quad 0x0000000900000008
  .quad 0x0000000B0000000A
  .quad 0x0000000D0000000C
  .quad 0x0000000F0000000E

signature_coef_0_2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

signature_coef_0_3:
  .quad 0x0000001900000018
  .quad 0x0000001B0000001A
  .quad 0x0000001D0000001C
  .quad 0x0000001F0000001E

signature_coef_0_4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

signature_coef_0_5:
  .quad 0x0000002900000028
  .quad 0x0000002B0000002A
  .quad 0x0000002D0000002C
  .quad 0x0000002F0000002E

signature_coef_0_6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

signature_coef_0_7:
  .quad 0x0000003900000038
  .quad 0x0000003B0000003A
  .quad 0x0000003D0000003C
  .quad 0x0000003F0000003E

signature_coef_0_8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

signature_coef_0_9:
  .quad 0x0000004900000048
  .quad 0x0000004B0000004A
  .quad 0x0000004D0000004C
  .quad 0x0000004F0000004E

signature_coef_0_10:
  .quad 0x0000005100000050
  .quad 0x0000005300000052
  .quad 0x0000005500000054
  .quad 0x0000005700000056

signature_coef_0_11:
  .quad 0x0000005900000058
  .quad 0x0000005B0000005A
  .quad 0x0000005D0000005C
  .quad 0x0000005F0000005E

signature_coef_0_12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

signature_coef_0_13:
  .quad 0x0000006900000068
  .quad 0x0000006B0000006A
  .quad 0x0000006D0000006C
  .quad 0x0000006F0000006E

signature_coef_0_14:
  .quad 0x0000007100000070
  .quad 0x0000007300000072
  .quad 0x0000007500000074
  .quad 0x0000007700000076

signature_coef_0_15:
  .quad 0x0000007900000078
  .quad 0x0000007B0000007A
  .quad 0x0000007D0000007C
  .quad 0x0000007F0000007E

signature_coef_0_16:
  .quad 0x0000008100000080
  .quad 0x0000008300000082
  .quad 0x0000008500000084
  .quad 0x0000008700000086

signature_coef_0_17:
  .quad 0x0000008900000088
  .quad 0x0000008B0000008A
  .quad 0x0000008D0000008C
  .quad 0x0000008F0000008E

signature_coef_0_18:
  .quad 0x0000009100000090
  .quad 0x0000009300000092
  .quad 0x0000009500000094
  .quad 0x0000009700000096

signature_coef_0_19:
  .quad 0x0000009900000098
  .quad 0x0000009B0000009A
  .quad 0x0000009D0000009C
  .quad 0x0000009F0000009E

signature_coef_0_20:
  .quad 0x000000A1000000A0
  .quad 0x000000A3000000A2
  .quad 0x000000A5000000A4
  .quad 0x000000A7000000A6

signature_coef_0_21:
  .quad 0x000000A9000000A8
  .quad 0x000000AB000000AA
  .quad 0x000000AD000000AC
  .quad 0x000000AF000000AE

signature_coef_0_22:
  .quad 0x000000B1000000B0
  .quad 0x000000B3000000B2
  .quad 0x000000B5000000B4
  .quad 0x000000B7000000B6

signature_coef_0_23:
  .quad 0x000000B9000000B8
  .quad 0x000000BB000000BA
  .quad 0x000000BD000000BC
  .quad 0x000000BF000000BE

signature_coef_0_24:
  .quad 0x000000C1000000C0
  .quad 0x000000C3000000C2
  .quad 0x000000C5000000C4
  .quad 0x000000C7000000C6

signature_coef_0_25:
  .quad 0x000000C9000000C8
  .quad 0x000000CB000000CA
  .quad 0x000000CD000000CC
  .quad 0x000000CF000000CE

signature_coef_0_26:
  .quad 0x000000D1000000D0
  .quad 0x000000D3000000D2
  .quad 0x000000D5000000D4
  .quad 0x000000D7000000D6

signature_coef_0_27:
  .quad 0x000000D9000000D8
  .quad 0x000000DB000000DA
  .quad 0x000000DD000000DC
  .quad 0x000000DF000000DE

signature_coef_0_28:
  .quad 0x000000E1000000E0
  .quad 0x000000E3000000E2
  .quad 0x000000E5000000E4
  .quad 0x000000E7000000E6

signature_coef_0_29:
  .quad 0x000000E9000000E8
  .quad 0x000000EB000000EA
  .quad 0x000000ED000000EC
  .quad 0x000000EF000000EE

signature_coef_0_30:
  .quad 0x000000F1000000F0
  .quad 0x000000F3000000F2
  .quad 0x000000F5000000F4
  .quad 0x000000F7000000F6

signature_coef_0_31:
  .quad 0x000000F9000000F8
  .quad 0x000000FB000000FA
  .quad 0x000000FD000000FC
  .quad 0x000000FF000000FE

signature_coef_1_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

signature_coef_1_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

signature_coef_1_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

signature_coef_1_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

signature_coef_1_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

signature_coef_1_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

signature_coef_1_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

signature_coef_1_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

signature_coef_1_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

signature_coef_1_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

signature_coef_1_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

signature_coef_1_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

signature_coef_1_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

signature_coef_1_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

signature_coef_1_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

signature_coef_1_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

signature_coef_1_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

signature_coef_1_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

signature_coef_1_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

signature_coef_1_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

signature_coef_1_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

signature_coef_1_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

signature_coef_1_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

signature_coef_1_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

signature_coef_1_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

signature_coef_1_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

signature_coef_1_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

signature_coef_1_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

signature_coef_1_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

signature_coef_1_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

signature_coef_1_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

signature_coef_1_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

signature_coef_2_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

signature_coef_2_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

signature_coef_2_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

signature_coef_2_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

signature_coef_2_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

signature_coef_2_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

signature_coef_2_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

signature_coef_2_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

signature_coef_2_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

signature_coef_2_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

signature_coef_2_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

signature_coef_2_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

signature_coef_2_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

signature_coef_2_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

signature_coef_2_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

signature_coef_2_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

signature_coef_2_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

signature_coef_2_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

signature_coef_2_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

signature_coef_2_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

signature_coef_2_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

signature_coef_2_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

signature_coef_2_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

signature_coef_2_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

signature_coef_2_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

signature_coef_2_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

signature_coef_2_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

signature_coef_2_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

signature_coef_2_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

signature_coef_2_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

signature_coef_2_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

signature_coef_2_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

signature_coef_3_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

signature_coef_3_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

signature_coef_3_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

signature_coef_3_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

signature_coef_3_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

signature_coef_3_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

signature_coef_3_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

signature_coef_3_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

signature_coef_3_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

signature_coef_3_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

signature_coef_3_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

signature_coef_3_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

signature_coef_3_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

signature_coef_3_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

signature_coef_3_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

signature_coef_3_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

signature_coef_3_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

signature_coef_3_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

signature_coef_3_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

signature_coef_3_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

signature_coef_3_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

signature_coef_3_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

signature_coef_3_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

signature_coef_3_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

signature_coef_3_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

signature_coef_3_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

signature_coef_3_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

signature_coef_3_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

signature_coef_3_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

signature_coef_3_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

signature_coef_3_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

signature_coef_3_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

signature_coef_4_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

signature_coef_4_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

signature_coef_4_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

signature_coef_4_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

signature_coef_4_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

signature_coef_4_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

signature_coef_4_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

signature_coef_4_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

signature_coef_4_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

signature_coef_4_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

signature_coef_4_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

signature_coef_4_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

signature_coef_4_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

signature_coef_4_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

signature_coef_4_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

signature_coef_4_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

signature_coef_4_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

signature_coef_4_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

signature_coef_4_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

signature_coef_4_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

signature_coef_4_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

signature_coef_4_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

signature_coef_4_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

signature_coef_4_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

signature_coef_4_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

signature_coef_4_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

signature_coef_4_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

signature_coef_4_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

signature_coef_4_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

signature_coef_4_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

signature_coef_4_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

signature_coef_4_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

signature_coef_5_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

signature_coef_5_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

signature_coef_5_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

signature_coef_5_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

signature_coef_5_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

signature_coef_5_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

signature_coef_5_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

signature_coef_5_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

signature_coef_5_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

signature_coef_5_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

signature_coef_5_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

signature_coef_5_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

signature_coef_5_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

signature_coef_5_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

signature_coef_5_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

signature_coef_5_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

signature_coef_5_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

signature_coef_5_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

signature_coef_5_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

signature_coef_5_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

signature_coef_5_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

signature_coef_5_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

signature_coef_5_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

signature_coef_5_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

signature_coef_5_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

signature_coef_5_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

signature_coef_5_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

signature_coef_5_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

signature_coef_5_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

signature_coef_5_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

signature_coef_5_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

signature_coef_5_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

signature_coef_6_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

signature_coef_6_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

signature_coef_6_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

signature_coef_6_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

signature_coef_6_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

signature_coef_6_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

signature_coef_6_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

signature_coef_6_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

signature_coef_6_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

signature_coef_6_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

signature_coef_6_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

signature_coef_6_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

signature_coef_6_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

signature_coef_6_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

signature_coef_6_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

signature_coef_6_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

signature_coef_6_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

signature_coef_6_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

signature_coef_6_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

signature_coef_6_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

signature_coef_6_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

signature_coef_6_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

signature_coef_6_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

signature_coef_6_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

signature_coef_6_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

signature_coef_6_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

signature_coef_6_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

signature_coef_6_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

signature_coef_6_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

signature_coef_6_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

signature_coef_6_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

signature_coef_6_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

expand_a_temp:
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000

t1_coef_0_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

t1_coef_0_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

t1_coef_0_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

t1_coef_0_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

t1_coef_0_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

t1_coef_0_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

t1_coef_0_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

t1_coef_0_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

t1_coef_0_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

t1_coef_0_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

t1_coef_0_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

t1_coef_0_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

t1_coef_0_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

t1_coef_0_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

t1_coef_0_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

t1_coef_0_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

t1_coef_0_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

t1_coef_0_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

t1_coef_0_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

t1_coef_0_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

t1_coef_0_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

t1_coef_0_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

t1_coef_0_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

t1_coef_0_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

t1_coef_0_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

t1_coef_0_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

t1_coef_0_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

t1_coef_0_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

t1_coef_0_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

t1_coef_0_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

t1_coef_0_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

t1_coef_0_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

t1_coef_1_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

t1_coef_1_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

t1_coef_1_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

t1_coef_1_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

t1_coef_1_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

t1_coef_1_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

t1_coef_1_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

t1_coef_1_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

t1_coef_1_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

t1_coef_1_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

t1_coef_1_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

t1_coef_1_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

t1_coef_1_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

t1_coef_1_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

t1_coef_1_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

t1_coef_1_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

t1_coef_1_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

t1_coef_1_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

t1_coef_1_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

t1_coef_1_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

t1_coef_1_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

t1_coef_1_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

t1_coef_1_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

t1_coef_1_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

t1_coef_1_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

t1_coef_1_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

t1_coef_1_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

t1_coef_1_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

t1_coef_1_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

t1_coef_1_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

t1_coef_1_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

t1_coef_1_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

t1_coef_2_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

t1_coef_2_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

t1_coef_2_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

t1_coef_2_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

t1_coef_2_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

t1_coef_2_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

t1_coef_2_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

t1_coef_2_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

t1_coef_2_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

t1_coef_2_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

t1_coef_2_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

t1_coef_2_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

t1_coef_2_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

t1_coef_2_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

t1_coef_2_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

t1_coef_2_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

t1_coef_2_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

t1_coef_2_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

t1_coef_2_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

t1_coef_2_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

t1_coef_2_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

t1_coef_2_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

t1_coef_2_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

t1_coef_2_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

t1_coef_2_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

t1_coef_2_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

t1_coef_2_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

t1_coef_2_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

t1_coef_2_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

t1_coef_2_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

t1_coef_2_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

t1_coef_2_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

t1_coef_3_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

t1_coef_3_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

t1_coef_3_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

t1_coef_3_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

t1_coef_3_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

t1_coef_3_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

t1_coef_3_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

t1_coef_3_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

t1_coef_3_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

t1_coef_3_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

t1_coef_3_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

t1_coef_3_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

t1_coef_3_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

t1_coef_3_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

t1_coef_3_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

t1_coef_3_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

t1_coef_3_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

t1_coef_3_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

t1_coef_3_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

t1_coef_3_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

t1_coef_3_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

t1_coef_3_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

t1_coef_3_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

t1_coef_3_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

t1_coef_3_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

t1_coef_3_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

t1_coef_3_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

t1_coef_3_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

t1_coef_3_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

t1_coef_3_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

t1_coef_3_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

t1_coef_3_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

t1_coef_4_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

t1_coef_4_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

t1_coef_4_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

t1_coef_4_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

t1_coef_4_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

t1_coef_4_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

t1_coef_4_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

t1_coef_4_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

t1_coef_4_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

t1_coef_4_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

t1_coef_4_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

t1_coef_4_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

t1_coef_4_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

t1_coef_4_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

t1_coef_4_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

t1_coef_4_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

t1_coef_4_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

t1_coef_4_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

t1_coef_4_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

t1_coef_4_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

t1_coef_4_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

t1_coef_4_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

t1_coef_4_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

t1_coef_4_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

t1_coef_4_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

t1_coef_4_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

t1_coef_4_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

t1_coef_4_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

t1_coef_4_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

t1_coef_4_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

t1_coef_4_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

t1_coef_4_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

t1_coef_5_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

t1_coef_5_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

t1_coef_5_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

t1_coef_5_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

t1_coef_5_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

t1_coef_5_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

t1_coef_5_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

t1_coef_5_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

t1_coef_5_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

t1_coef_5_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

t1_coef_5_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

t1_coef_5_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

t1_coef_5_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

t1_coef_5_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

t1_coef_5_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

t1_coef_5_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

t1_coef_5_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

t1_coef_5_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

t1_coef_5_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

t1_coef_5_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

t1_coef_5_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

t1_coef_5_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

t1_coef_5_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

t1_coef_5_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

t1_coef_5_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

t1_coef_5_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

t1_coef_5_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

t1_coef_5_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

t1_coef_5_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

t1_coef_5_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

t1_coef_5_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

t1_coef_5_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

t1_coef_6_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

t1_coef_6_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

t1_coef_6_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

t1_coef_6_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

t1_coef_6_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

t1_coef_6_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

t1_coef_6_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

t1_coef_6_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

t1_coef_6_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

t1_coef_6_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

t1_coef_6_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

t1_coef_6_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

t1_coef_6_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

t1_coef_6_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

t1_coef_6_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

t1_coef_6_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

t1_coef_6_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

t1_coef_6_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

t1_coef_6_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

t1_coef_6_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

t1_coef_6_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

t1_coef_6_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

t1_coef_6_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

t1_coef_6_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

t1_coef_6_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

t1_coef_6_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

t1_coef_6_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

t1_coef_6_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

t1_coef_6_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

t1_coef_6_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

t1_coef_6_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

t1_coef_6_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

t1_coef_7_0:
.quad 0x0000000100000000
.quad 0x0000000300000002
.quad 0x0000000500000004
.quad 0x0000000700000006

t1_coef_7_1:
.quad 0x0000000900000008
.quad 0x0000000B0000000A
.quad 0x0000000D0000000C
.quad 0x0000000F0000000E

t1_coef_7_2:
.quad 0x0000001100000010
.quad 0x0000001300000012
.quad 0x0000001500000014
.quad 0x0000001700000016

t1_coef_7_3:
.quad 0x0000001900000018
.quad 0x0000001B0000001A
.quad 0x0000001D0000001C
.quad 0x0000001F0000001E

t1_coef_7_4:
.quad 0x0000002100000020
.quad 0x0000002300000022
.quad 0x0000002500000024
.quad 0x0000002700000026

t1_coef_7_5:
.quad 0x0000002900000028
.quad 0x0000002B0000002A
.quad 0x0000002D0000002C
.quad 0x0000002F0000002E

t1_coef_7_6:
.quad 0x0000003100000030
.quad 0x0000003300000032
.quad 0x0000003500000034
.quad 0x0000003700000036

t1_coef_7_7:
.quad 0x0000003900000038
.quad 0x0000003B0000003A
.quad 0x0000003D0000003C
.quad 0x0000003F0000003E

t1_coef_7_8:
.quad 0x0000004100000040
.quad 0x0000004300000042
.quad 0x0000004500000044
.quad 0x0000004700000046

t1_coef_7_9:
.quad 0x0000004900000048
.quad 0x0000004B0000004A
.quad 0x0000004D0000004C
.quad 0x0000004F0000004E

t1_coef_7_10:
.quad 0x0000005100000050
.quad 0x0000005300000052
.quad 0x0000005500000054
.quad 0x0000005700000056

t1_coef_7_11:
.quad 0x0000005900000058
.quad 0x0000005B0000005A
.quad 0x0000005D0000005C
.quad 0x0000005F0000005E

t1_coef_7_12:
.quad 0x0000006100000060
.quad 0x0000006300000062
.quad 0x0000006500000064
.quad 0x0000006700000066

t1_coef_7_13:
.quad 0x0000006900000068
.quad 0x0000006B0000006A
.quad 0x0000006D0000006C
.quad 0x0000006F0000006E

t1_coef_7_14:
.quad 0x0000007100000070
.quad 0x0000007300000072
.quad 0x0000007500000074
.quad 0x0000007700000076

t1_coef_7_15:
.quad 0x0000007900000078
.quad 0x0000007B0000007A
.quad 0x0000007D0000007C
.quad 0x0000007F0000007E

t1_coef_7_16:
.quad 0x0000008100000080
.quad 0x0000008300000082
.quad 0x0000008500000084
.quad 0x0000008700000086

t1_coef_7_17:
.quad 0x0000008900000088
.quad 0x0000008B0000008A
.quad 0x0000008D0000008C
.quad 0x0000008F0000008E

t1_coef_7_18:
.quad 0x0000009100000090
.quad 0x0000009300000092
.quad 0x0000009500000094
.quad 0x0000009700000096

t1_coef_7_19:
.quad 0x0000009900000098
.quad 0x0000009B0000009A
.quad 0x0000009D0000009C
.quad 0x0000009F0000009E

t1_coef_7_20:
.quad 0x000000A1000000A0
.quad 0x000000A3000000A2
.quad 0x000000A5000000A4
.quad 0x000000A7000000A6

t1_coef_7_21:
.quad 0x000000A9000000A8
.quad 0x000000AB000000AA
.quad 0x000000AD000000AC
.quad 0x000000AF000000AE

t1_coef_7_22:
.quad 0x000000B1000000B0
.quad 0x000000B3000000B2
.quad 0x000000B5000000B4
.quad 0x000000B7000000B6

t1_coef_7_23:
.quad 0x000000B9000000B8
.quad 0x000000BB000000BA
.quad 0x000000BD000000BC
.quad 0x000000BF000000BE

t1_coef_7_24:
.quad 0x000000C1000000C0
.quad 0x000000C3000000C2
.quad 0x000000C5000000C4
.quad 0x000000C7000000C6

t1_coef_7_25:
.quad 0x000000C9000000C8
.quad 0x000000CB000000CA
.quad 0x000000CD000000CC
.quad 0x000000CF000000CE

t1_coef_7_26:
.quad 0x000000D1000000D0
.quad 0x000000D3000000D2
.quad 0x000000D5000000D4
.quad 0x000000D7000000D6

t1_coef_7_27:
.quad 0x000000D9000000D8
.quad 0x000000DB000000DA
.quad 0x000000DD000000DC
.quad 0x000000DF000000DE

t1_coef_7_28:
.quad 0x000000E1000000E0
.quad 0x000000E3000000E2
.quad 0x000000E5000000E4
.quad 0x000000E7000000E6

t1_coef_7_29:
.quad 0x000000E9000000E8
.quad 0x000000EB000000EA
.quad 0x000000ED000000EC
.quad 0x000000EF000000EE

t1_coef_7_30:
.quad 0x000000F1000000F0
.quad 0x000000F3000000F2
.quad 0x000000F5000000F4
.quad 0x000000F7000000F6

t1_coef_7_31:
.quad 0x000000F9000000F8
.quad 0x000000FB000000FA
.quad 0x000000FD000000FC
.quad 0x000000FF000000FE

A_coeff_0:
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
