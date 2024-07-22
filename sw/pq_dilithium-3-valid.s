/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* Dilithium-III Verify Implementation */


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
loopi 6, 205

  /* Init w_acc_coef_0_0 */

  la x31, allzero
  bn.lid x0, 0(x31)
  li x31, 20480 
  
  loopi 32, 1
    bn.sid x0, 0(x31++) 
    
  /* For j in 0 to l */
  loopi 5, 55
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
    li x31, 17408

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
li x10, 207

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
loopi 49, 64

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
.word 0xd767ac79
.word 0xc605c395
.word 0xdbb8f26b
.word 0xf8b5f48f
.word 0xd068b5a9
.word 0xc4cc00ef
.word 0x418c6b91
.word 0x577285ed

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
.word 0x4c266f97
.word 0xb2490ec
.word 0x26c6d4c7
.word 0x781c7c32
.word 0x1bec71fa
.word 0x58abd773
.word 0x23be7b49
.word 0x9721d36a
.word 0x2a2a612c
.word 0xa324c3f1
.word 0x6c7b4db7
.word 0xbd938153
.word 0x0 
.word 0x0 
.word 0x0 
.word 0x0 

/* hint */
.globl hint0
hint0:
.word 0x800
.word 0x0
.word 0x0
.word 0x10010
.word 0x80000c0
.word 0x0
.word 0x0
.word 0x8000080
.word 0x0
.word 0x0
.word 0x1000000
.word 0x10
.word 0x1000
.word 0x400
.word 0x0
.word 0x0
.word 0x0
.word 0x0
.word 0x0
.word 0x200000
.word 0x200000
.word 0x40
.word 0x8000000
.word 0x100080
.word 0x8
.word 0x40000000
.word 0x100
.word 0xa0000
.word 0x0
.word 0x20000000
.word 0x10
.word 0x0
.word 0x0
.word 0x100
.word 0x10
.word 0x10000000
.word 0x0
.word 0x100020
.word 0x100
.word 0x200
.word 0x8000000
.word 0x0
.word 0x0
.word 0x0
.word 0x800000
.word 0x0
.word 0x0
.word 0x800000
    
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
.word 0x32d01
.word 0x4901
.word 0x24481
.word 0xb35b
.word 0x6c89c
.word 0x53c8a
.word 0x2191b
.word 0x7e0225
.word 0x7e3c7f
.word 0x7e9f4e
.word 0x78ef38
.word 0x7d9091
.word 0x796d10
.word 0x7b3c86
.word 0x7e28cc
.word 0x35974
.word 0x7e01b2
.word 0x784bcc
.word 0x78c9b6
.word 0x13329
.word 0x7bf057
.word 0x7d238b
.word 0x1c986
.word 0x7ba867
.word 0x4b58e
.word 0x5f18a
.word 0x7ce152
.word 0x7bd9c8
.word 0x7d3933
.word 0x23cdf
.word 0x7e0f5b
.word 0x3d6e1
.word 0x7ef0b4
.word 0x79b48b
.word 0x668a4
.word 0x7ad82b
.word 0x7be9bc
.word 0x45e6a
.word 0x7ce1f9
.word 0x20397
.word 0x4bd
.word 0x79baa9
.word 0x79ad2
.word 0x346bb
.word 0x22034
.word 0x78b271
.word 0x3c47f
.word 0x7812ba
.word 0x15076
.word 0x3af4c
.word 0x63084
.word 0x1c177
.word 0x782c22
.word 0x6078d
.word 0x40d2
.word 0x46bc6
.word 0x73bae
.word 0x5fe8a
.word 0x7c8a6d
.word 0x17475
.word 0x3faf0
.word 0x7c67b1
.word 0x7cdcfa
.word 0x12c4
.word 0x16e02
.word 0x7e66d1
.word 0x6a2a1
.word 0x79ff09
.word 0x7938bc
.word 0x7b2afc
.word 0x7ae6d8
.word 0x27661
.word 0x546ff
.word 0x239e8
.word 0x7dc320
.word 0x2b555
.word 0x5b58f
.word 0x67d98
.word 0x7b8135
.word 0x7bde0e
.word 0x7a004b
.word 0x6604d
.word 0x795ad0
.word 0x649f2
.word 0x40dcc
.word 0x77e113
.word 0x567eb
.word 0x76fad
.word 0x7c183e
.word 0x7843b5
.word 0x7eda94
.word 0x77fe89
.word 0x17b9d
.word 0x7be969
.word 0x7b0966
.word 0x3a572
.word 0x736c1
.word 0x7cd66d
.word 0x5f575
.word 0x7b9cd9
.word 0x2cf45
.word 0x7c81aa
.word 0x7abd03
.word 0x79b1c1
.word 0x7e1a4c
.word 0x78aef4
.word 0xe994
.word 0x7c8a53
.word 0x43d5a
.word 0x7f4bf
.word 0x7a5cb8
.word 0x4fcf4
.word 0x1376b
.word 0x7c4fb1
.word 0x36363
.word 0x78c902
.word 0x792f42
.word 0x79872c
.word 0x3a895
.word 0x7b7291
.word 0x3243f
.word 0x378a0
.word 0x2ffe0
.word 0x7c4202
.word 0x4e3ce
.word 0x7b3f33
.word 0x77d70
.word 0x7ab533
.word 0x702ec
.word 0x7c170e
.word 0x7da297
.word 0x2ff4a
.word 0x7ac55b
.word 0x7d32a
.word 0x7869e9
.word 0xcb6a
.word 0x7c400d
.word 0x99bc
.word 0x7f9d4a
.word 0x78d050
.word 0x78a77
.word 0x78d6a0
.word 0x65fa1
.word 0x78629d
.word 0x4dd5d
.word 0x7e4812
.word 0x7b8c2e
.word 0x708a
.word 0x78d13d
.word 0x78bbc7
.word 0x7830d7
.word 0x118b3
.word 0xa48e
.word 0x29d7
.word 0x7d055a
.word 0x7d4dc3
.word 0x39c66
.word 0x25b18
.word 0x59039
.word 0x7a0864
.word 0x7cd4a
.word 0x7e9d75
.word 0x78425a
.word 0xbc43
.word 0x7f0400
.word 0x34027
.word 0x7ac496
.word 0x79d565
.word 0x38d4b
.word 0x9db0
.word 0x2113f
.word 0x7ba4f
.word 0x2300e
.word 0x79c27b
.word 0x7f21dc
.word 0x794a61
.word 0x77e7b7
.word 0x7ec587
.word 0x7e33cd
.word 0x7c20b0
.word 0xb6fa
.word 0x7b8ecf
.word 0x7d6c79
.word 0x7ca5b5
.word 0x7e5cff
.word 0x7b7008
.word 0x6d46b
.word 0x792a0
.word 0x7ded50
.word 0x18778
.word 0x1a82b
.word 0x595c6
.word 0x21163
.word 0x7baa4f
.word 0x1115c
.word 0x7df31b
.word 0x79a059
.word 0x494b2
.word 0x4eb54
.word 0x7a353f
.word 0x7cad6c
.word 0x3e51
.word 0x7051d
.word 0x7e993d
.word 0x7cfa6f
.word 0x7bd791
.word 0x21587
.word 0x2533b
.word 0x79fcae
.word 0x3046b
.word 0x7cebc
.word 0x79b5e3
.word 0x7a926f
.word 0x79767
.word 0x28e2a
.word 0x6cd0b
.word 0x7cc39e
.word 0x7b4737
.word 0x79c919
.word 0x41e01
.word 0x7ed777
.word 0x2d913
.word 0x7c341e
.word 0x1bbdd
.word 0x4f38e
.word 0x2b154
.word 0x7b7fca
.word 0x78d8bf
.word 0x59933
.word 0x7af113
.word 0x7bc2c0
.word 0x79c898
.word 0x7cc4d1
.word 0x7cedc5
.word 0x428fb
.word 0x7e59e8
.word 0x7aaea6
.word 0x7d48e4
.word 0x34290
.word 0x7bfffc
.word 0x7d32a5
.word 0x7c5324
.word 0x118a
.word 0x18454
.word 0x60238
.word 0x7db5f5
.word 0x7a4181
.word 0x731b3
.word 0x7e7cb3
.word 0x7d06ec
.word 0x7eb013
.word 0x656dc
.word 0x7adce0
.word 0x7f7ae7
.word 0x7af3c6
.word 0x7d793e
.word 0x2aee8
.word 0x7cbf64
.word 0x7c395d
.word 0x735d
.word 0x5533
.word 0x67059
.word 0x7830dc
.word 0x1441d
.word 0x717a8
.word 0x7d6a0e
.word 0x5b880
.word 0x7ae86f
.word 0x7a171b
.word 0x7bb238
.word 0x7e7ba9
.word 0x2db21
.word 0x4143c
.word 0x780d1f
.word 0x67d5
.word 0x7f6a36
.word 0x18d15
.word 0x7e5d4f
.word 0x7112e
.word 0x45448
.word 0x7e3d44
.word 0x7e72a3
.word 0x7f35d5
.word 0x7b8403
.word 0x7bf8b0
.word 0x7ac08d
.word 0x2addc
.word 0x5a149
.word 0x4cc01
.word 0x1627a
.word 0x53c31
.word 0x6a808
.word 0x5eb0c
.word 0x789a64
.word 0x47746
.word 0x12f5e
.word 0xb33a
.word 0x76ea3
.word 0x2ad5e
.word 0x7fc0f
.word 0x7d9dfc
.word 0x7ec58f
.word 0x7e87e0
.word 0x33165
.word 0x79162f
.word 0x3b4a1
.word 0x7b199d
.word 0x75c4f
.word 0x54c91
.word 0x19c69
.word 0x7a2bc7
.word 0x7004d
.word 0x37e7f
.word 0x77ff77
.word 0x79f37e
.word 0x7e1a6
.word 0x72c5d
.word 0x7b7dc7
.word 0x784e83
.word 0x7a1317
.word 0x796166
.word 0x33f33
.word 0x7bccde
.word 0x460ca
.word 0x7f69e2
.word 0x6619b
.word 0x6a4ca
.word 0x7c59e1
.word 0x7981e2
.word 0x4c4c1
.word 0x6e5ff
.word 0x79b943
.word 0x7f0275
.word 0x6db3d
.word 0x7b7efc
.word 0x7c6fbe
.word 0x7effe0
.word 0x7a8c1c
.word 0x7ebe24
.word 0x7aaaa8
.word 0x7b4aef
.word 0x7c5335
.word 0x78363a
.word 0x7b9678
.word 0x7844f8
.word 0x784dfb
.word 0x780a87
.word 0x38e49
.word 0x5c36b
.word 0x7ccef2
.word 0x3b564
.word 0x7e1489
.word 0x320e5
.word 0x68130
.word 0x793e3e
.word 0x7c54f
.word 0x34149
.word 0x798791
.word 0x7efd31
.word 0x7879a6
.word 0x3a9bf
.word 0x1958f
.word 0x79f682
.word 0x7a96bc
.word 0x39049
.word 0x7f35c
.word 0x79f0bc
.word 0x782d7d
.word 0x7e451a
.word 0x78c486
.word 0x7ce48
.word 0x17916
.word 0x7dfafc
.word 0x79d92f
.word 0x7f48c6
.word 0x7d1a4d
.word 0x7f95f
.word 0x7d3a83
.word 0x39626
.word 0x7e902e
.word 0x7b4b84
.word 0x65178
.word 0x7fdbc0
.word 0x6388d
.word 0x799afe
.word 0x27b59
.word 0x954d
.word 0x79ffc2
.word 0x2693c
.word 0x540de
.word 0x3df04
.word 0x5fc62
.word 0x7d4196
.word 0x7b4aef
.word 0x4434a
.word 0x7e27f5
.word 0x7f383a
.word 0x2cb7d
.word 0x64fd7
.word 0x789d0d
.word 0x7a8588
.word 0x2b4a1
.word 0x7db731
.word 0x7e3b8a
.word 0x7f1e26
.word 0x7a1133
.word 0x3d983
.word 0x104e9
.word 0x7cd1de
.word 0x6725e
.word 0x78e7db
.word 0x79e129
.word 0x1a59a
.word 0x7a3ec5
.word 0x7fd5f
.word 0x3b0a
.word 0x14958
.word 0x7c9b55
.word 0x43fce
.word 0x494d3
.word 0x7e74f6
.word 0x60c8d
.word 0x49a3
.word 0x863b
.word 0x78bc38
.word 0xbda6
.word 0x794d62
.word 0x63467
.word 0x7df938
.word 0x78709c
.word 0x45883
.word 0x65383
.word 0x7ea2e0
.word 0x71812
.word 0x78b64a
.word 0x6d66f
.word 0x78b6cb
.word 0x7efd2e
.word 0x7ecb6a
.word 0x4617
.word 0x7d282c
.word 0x68859
.word 0x7ae16b
.word 0x7f6749
.word 0x7f8955
.word 0x7885ae
.word 0x7e315d
.word 0x7deace
.word 0x35e3c
.word 0x14052
.word 0x7f2b26
.word 0x37343
.word 0x7883dc
.word 0x7c96e7
.word 0x7fa3ec
.word 0x4095a
.word 0x794f7d
.word 0x6f359
.word 0x60e85
.word 0x7f243f
.word 0x7f1fc6
.word 0x72f75
.word 0x1b20
.word 0x2a021
.word 0x7c6211
.word 0x4830b
.word 0x25b90
.word 0x72c94
.word 0x5434b
.word 0x7c9771
.word 0x7bdb36
.word 0x29999
.word 0x7e2895
.word 0x1aa30
.word 0xb53
.word 0x7c6e7a
.word 0x50b54
.word 0x24a59
.word 0x791a54
.word 0x7b5779
.word 0x7d2263
.word 0x482fd
.word 0x7e33c0
.word 0x7b91df
.word 0x77e193
.word 0x792244
.word 0x7e1da6
.word 0x7e2ba0
.word 0x78194a
.word 0x7c047c
.word 0x61b56
.word 0x73adb
.word 0x7e0a03
.word 0x7f9ee2
.word 0x4271a
.word 0x7a4ac6
.word 0x78c6e8
.word 0x27d44
.word 0x184e2
.word 0x7b12a2
.word 0x7ee27a
.word 0x3e77f
.word 0x79f20d
.word 0x790b39
.word 0x7b5812
.word 0x7ad2aa
.word 0x785fea
.word 0x7f96e0
.word 0x792b91
.word 0xe651
.word 0x67db5
.word 0x7b197a
.word 0x2bbe2
.word 0x1be4f
.word 0x499a6
.word 0x7a7526
.word 0x7b8f04
.word 0x79dd6f
.word 0x66439
.word 0x55be0
.word 0x7e9101
.word 0x797a1b
.word 0x48489
.word 0x346ae
.word 0x12f42
.word 0x23546
.word 0x7f2fa3
.word 0x66fd7
.word 0x7f0556
.word 0x35ff7
.word 0x595d
.word 0x79b22
.word 0x1d89a
.word 0xfee0
.word 0x18ab
.word 0x7c52db
.word 0x7c63c6
.word 0x7db3c5
.word 0x784049
.word 0x7c4a57
.word 0x43dec
.word 0x7a9ae4
.word 0x79a3b4
.word 0x49196
.word 0x79a4a9
.word 0x7c9e3e
.word 0x7f4003
.word 0x8234
.word 0x20709
.word 0x79c800
.word 0x32630
.word 0x64291
.word 0x711b8
.word 0x7a5551
.word 0x714e2
.word 0x7932f1
.word 0x7d7981
.word 0x7e4f28
.word 0x1e0c
.word 0x63002
.word 0x786d8e
.word 0x7424f
.word 0x7d08ba
.word 0x7e6980
.word 0x7c06d0
.word 0x42e1
.word 0x2e25c
.word 0x265a2
.word 0x7d7e87
.word 0x6c9bd
.word 0x7aeabc
.word 0x78e758
.word 0x49383
.word 0x7ed947
.word 0x7c86bd
.word 0x7e9aaa
.word 0x7e806e
.word 0x6941a
.word 0x120af
.word 0x7d9bb8
.word 0x7c947b
.word 0x7bee80
.word 0x3ee76
.word 0x7850d7
.word 0x7e8af6
.word 0x2cfbd
.word 0x79f33
.word 0x5d61
.word 0x2b599
.word 0x7fd66e
.word 0x49cc3
.word 0x21f6d
.word 0x3e6b
.word 0x7c930e
.word 0x7eb7fe
.word 0x5989e
.word 0x7d70fb
.word 0x7813c9
.word 0x1abe6
.word 0x7e9445
.word 0x51195
.word 0x7d505
.word 0x7a7d67
.word 0x25fc3
.word 0x7b7e14
.word 0x7e9a5e
.word 0x7ce3e8
.word 0x34f11
.word 0x7fd3c9
.word 0x679db
.word 0x7ec436
.word 0x7e4b00
.word 0x2cce3
.word 0x7e3d4e
.word 0x796a63
.word 0x7947be
.word 0x720
.word 0x7bf61
.word 0x4d5c4
.word 0x7c2a66
.word 0x24e2e
.word 0x3cdb
.word 0x799749
.word 0x79d2c9
.word 0x791c1d
.word 0x7c9b45
.word 0x52449
.word 0xd857
.word 0x791bb
.word 0x55cb5
.word 0x3a946
.word 0x63cbf
.word 0x7ea2b0
.word 0x7b6596
.word 0x7f41a0
.word 0x7c4504
.word 0x7f30af
.word 0x77e510
.word 0x78cd2a
.word 0x7be0ae
.word 0x3ca2d
.word 0x7ba78f
.word 0x790ceb
.word 0x73a82
.word 0x7870af
.word 0x7ec2a7
.word 0x7cf7ee
.word 0x7a18c8
.word 0x1a28c
.word 0x7c6043
.word 0x4796c
.word 0x4d31d
.word 0x7cf24b
.word 0x7af4f4
.word 0x7b6ed5
.word 0x48a18
.word 0x793ae6
.word 0x47688
.word 0x18d3e
.word 0x67a30
.word 0x2300c
.word 0x314f0
.word 0x79349a
.word 0x7f3f85
.word 0x79344a
.word 0x79bff4
.word 0x78b2ea
.word 0x32b81
.word 0x11e39
.word 0x7c4f4e
.word 0x34cfe
.word 0x6a6ab
.word 0x7b4434
.word 0xaf85
.word 0x7db9aa
.word 0x715dc
.word 0x350bd
.word 0x4812a
.word 0x403d5
.word 0x67e33
.word 0x18ae1
.word 0x74a78
.word 0x7eb338
.word 0x22a2b
.word 0x79bb28
.word 0x7ae87c
.word 0x7b5f13
.word 0x23847
.word 0x7ea9fb
.word 0x7fa265
.word 0x7f66b5
.word 0x79847c
.word 0x7eff6b
.word 0x7f06c3
.word 0x669fe
.word 0x5a885
.word 0x7dc1c5
.word 0x7996ef
.word 0x7f5ce6
.word 0x7ac8a0
.word 0x782814
.word 0x62655
.word 0x7e5fe1
.word 0x7f8869
.word 0x6587f
.word 0x79ee13
.word 0x6176f
.word 0x789393
.word 0x7df58a
.word 0x4d9da
.word 0x784c00
.word 0x79ff28
.word 0x27fa0
.word 0x2fb8c
.word 0x5938a
.word 0x475a6
.word 0x78cf4f
.word 0x2edfe
.word 0x36f0a
.word 0x9815
.word 0x783293
.word 0x48f20
.word 0x780c74
.word 0x18335
.word 0x7bbb8a
.word 0x788d06
.word 0x7f8849
.word 0x7da8f8
.word 0x7f0719
.word 0x7c3dc8
.word 0x79f3a6
.word 0x52af2
.word 0x7fab1f
.word 0x7d327e
.word 0x648c1
.word 0xe604
.word 0x1d051
.word 0x5022d
.word 0x7f3d52
.word 0x1e99
.word 0x55997
.word 0x7cd0e1
.word 0x7c34a6
.word 0x7c0d61
.word 0x65647
.word 0x3e9b2
.word 0x65da5
.word 0x7d1e89
.word 0x2a6b0
.word 0x5822e
.word 0x7cc86e
.word 0x6a37
.word 0x7d360c
.word 0x4664f
.word 0x7c7707
.word 0x2cd2b
.word 0x7ef22f
.word 0x7fcae7
.word 0x159fe
.word 0x7bdfd6
.word 0x6a689
.word 0x4893c
.word 0x7aad22
.word 0x5b950
.word 0x142d8
.word 0x7eff31
.word 0x7e7e7d
.word 0x7e2e18
.word 0x63fac
.word 0x5dfb6
.word 0x174c0
.word 0xa18f
.word 0x7defd9
.word 0x61731
.word 0x18e41
.word 0x52736
.word 0x79d370
.word 0x53679
.word 0x3bbbf
.word 0x7c884c
.word 0x65d3b
.word 0x3a596
.word 0x781307
.word 0x7f8e3e
.word 0x795464
.word 0x7a9490
.word 0x7ad4b6
.word 0x78d87e
.word 0x79edda
.word 0x7d7258
.word 0x784941
.word 0x7a01ef
.word 0x53b31
.word 0x7f3dd4
.word 0x7da427
.word 0x7ad8e1
.word 0x7f60b9
.word 0x4d29c
.word 0x78c063
.word 0x63bb3
.word 0x3c139
.word 0x7d6854
.word 0x3e93c
.word 0x7d5d82
.word 0x16036
.word 0x77355
.word 0x6f29c
.word 0x78a08b
.word 0x102c0
.word 0x7840ef
.word 0x7b09fd
.word 0x4b76d
.word 0x7da8f0
.word 0x79d10
.word 0x165ee
.word 0x7fc2f7
.word 0x3f73e
.word 0x24bc3
.word 0x3a3ff
.word 0x7c9d4e
.word 0x5e3a2
.word 0x4fbf8
.word 0x3dc33
.word 0x37eaa
.word 0x7c5f83
.word 0x7d3c9f
.word 0x2fe19
.word 0x7d9a2a
.word 0x7f60d9
.word 0x1e8c1
.word 0x7f2614
.word 0x7cad77
.word 0x44069
.word 0x1c51d
.word 0x7dca1f
.word 0x78f48b
.word 0x5b832
.word 0x7b1544
.word 0x129c0
.word 0x69dcf
.word 0x316fe
.word 0x7921de
.word 0x79625f
.word 0x3150
.word 0x29710
.word 0x76d7
.word 0x78e355
.word 0x5d94e
.word 0x5e80f
.word 0x7ec131
.word 0x1dde9
.word 0x1fbce
.word 0x799154
.word 0x7e49b2
.word 0x49330
.word 0x7c75a7
.word 0x6bfff
.word 0x5f7f5
.word 0x3f592
.word 0x79048a
.word 0x5377
.word 0x7fd5c3
.word 0x692ec
.word 0x78ca6b
.word 0x7d9917
.word 0x6454c
.word 0x70fd
.word 0x7ac38c
.word 0xc60a
.word 0x5340c
.word 0x5141
.word 0x413bf
.word 0x40e16
.word 0x1ece7
.word 0x6375f
.word 0x624eb
.word 0x7dbaa0
.word 0x7c7d38
.word 0x45582
.word 0x7d008b
.word 0x53ea
.word 0x19838
.word 0x7b48ff
.word 0x17ddc
.word 0xb8ce
.word 0x46224
.word 0x7e2386
.word 0x17efe
.word 0x11304
.word 0x658d0
.word 0xfa8b
.word 0x785187
.word 0x53855
.word 0x7a3a7f
.word 0x77f2d4
.word 0x6c7a3
.word 0x40fc5
.word 0x46f62
.word 0x7f04f3
.word 0x6eb10
.word 0x7f6027
.word 0x7a837a
.word 0x7a036b
.word 0x7c1774
.word 0x61d68
.word 0x77f600
.word 0x100fd
.word 0x6e60d
.word 0x7c3da0
.word 0x7f9705
.word 0x7f472b
.word 0x7ce4bc
.word 0x7c46a4
.word 0x796bd4
.word 0x7c697f
.word 0x7e0481
.word 0x7f2f76
.word 0x3ac4d
.word 0x7ba6c0
.word 0x7b94c7
.word 0x6d4e5
.word 0x3bfc6
.word 0x6f672
.word 0x7a6dd7
.word 0x65c87
.word 0x5097f
.word 0x7c99f6
.word 0x7db202
.word 0x20dbb
.word 0x7be138
.word 0x6e13
.word 0x7fab06
.word 0x5e7b9
.word 0x793afa
.word 0x771e
.word 0x7bda2
.word 0x4e5e0
.word 0x7be67c
.word 0x61148
.word 0xa61f
.word 0x1872c
.word 0x7cb016
.word 0x36861
.word 0x7b5cbf
.word 0xaff2
.word 0x7c441d
.word 0x7df4d3
.word 0x7aa0b9
.word 0x6e2a6
.word 0x7b3ea4
.word 0x7e04c9
.word 0x764f9
.word 0x40236
.word 0x674c1
.word 0x2e878
.word 0x7bab44
.word 0x7cf861
.word 0x28681
.word 0x7ae524
.word 0x33123
.word 0x7eb902
.word 0x78d553
.word 0x7b50d8
.word 0x7add00
.word 0x293cf
.word 0x785223
.word 0xab99
.word 0x7d95f1
.word 0x78bea0
.word 0x8194
.word 0x7fbc2e
.word 0x7ac426
.word 0x3c6af
.word 0x7e3290
.word 0x1d503
.word 0x32b17
.word 0x7654e
.word 0x7502c
.word 0x6d9d2
.word 0x43f40
.word 0x785b67
.word 0x7c7c0b
.word 0x7bc01
.word 0x7bd4ee
.word 0x25e5a
.word 0x7a6839
.word 0x681b8
.word 0x153fb
.word 0x163a8
.word 0x2748f
.word 0x7b5451
.word 0x4d48b
.word 0x7a4f59
.word 0x7d1f56
.word 0xae0
.word 0x4579f
.word 0x4d071
.word 0x76350
.word 0x48e0c
.word 0x7a5986
.word 0x7e9a28
.word 0x7e8441
.word 0x7beab3
.word 0x7375e
.word 0x7a2adc
.word 0x7aff0f
.word 0x7d5ee8
.word 0x72f49
.word 0x60b
.word 0xa8ec
.word 0x786080
.word 0x7f5244
.word 0x7ed055
.word 0x7f1f2f
.word 0x507
.word 0x3f601
.word 0x7a4d96
.word 0x66142
.word 0x790e94
.word 0xf2c9
.word 0x7e824d
.word 0x7e55
.word 0x7d572b
.word 0x78737
.word 0x4e6de
.word 0x7976b0
.word 0x10f41
.word 0x38561
.word 0x7baf3b
.word 0x7e51d8
.word 0x3265d
.word 0x7e24e6
.word 0x7cf30a
.word 0x7eafff
.word 0x21670
.word 0x3ceed
.word 0x7eb959
.word 0x79c555
.word 0x37360
.word 0x14f32
.word 0x7dba05
.word 0x71dca
.word 0x1daa8
.word 0x5b3f2
.word 0x6772d
.word 0x7dd382
.word 0x3ddae
.word 0x44491
.word 0x7713e
.word 0x52e57
.word 0x7cfd07
.word 0x53c57
.word 0x25d3a
.word 0x33fbe
.word 0x1acd
.word 0x4abb6
.word 0x7b608f
.word 0x7f80b7
.word 0x79dc2d
.word 0x7c823a
.word 0x52d58
.word 0x34ed9
.word 0x7a66ca
.word 0x7dab2b
.word 0x7fa977
.word 0x7a1da9
.word 0x62ba1
.word 0x7a2228
.word 0x7da196
.word 0x5c0e
.word 0x7ad44e
.word 0x4fc1e
.word 0x7dba5a
.word 0x50183
.word 0xe9be
.word 0x153a5
.word 0x51af3
.word 0x7ef916
.word 0x5dc41
.word 0x7f704a
.word 0x7b76b2
.word 0x78200f
.word 0x4f822
.word 0x7aad80
.word 0x7f297e
.word 0x141
.word 0x5715d
.word 0x2dcd
.word 0x7a7f63
.word 0x1a101
.word 0x51319
.word 0x7a3aa6
.word 0xe2ee
.word 0x322da
.word 0x79688b
.word 0x7a05e3
.word 0xc251
.word 0x74fa8
.word 0x1f609
.word 0x7919fc
.word 0x7e10aa
.word 0x7ce5c5
.word 0x7d449f
.word 0x21651
.word 0x61747
.word 0x788836
.word 0x785fd
.word 0x26902
.word 0x182dc
.word 0x7e21c8
.word 0x79190
.word 0x1160
.word 0x4932
.word 0x4f795
.word 0x57e7e
.word 0xda9e
.word 0x7918fe
.word 0x7de02b
.word 0x7ab0a0
.word 0x63c9a
.word 0x7c2be3
.word 0x53c3a
.word 0x784c10
.word 0x78fc1f
.word 0x7d579a
.word 0x48c95
.word 0x7e013e
.word 0x77ff0a
.word 0x7b7a35
.word 0x788a2e
.word 0x792d2
.word 0x434e8
.word 0x7892b7
.word 0x7ae277
.word 0x7bbfeb
.word 0x86a8
.word 0x74786
.word 0x7d27ff
.word 0x16abd
.word 0x7a43be
.word 0x7fbcd8
.word 0x1ac66
.word 0x752d7
.word 0x418ff
.word 0x7ad4ba
.word 0x7ebfd3
.word 0x78d8ee
.word 0x39e8d
.word 0x7bc848
.word 0x74ec0
.word 0x78fe3
.word 0x3c749
.word 0x31223
.word 0x7b9e33
.word 0x7c8a8f
.word 0x752e7
.word 0x78633f
.word 0x76eed
.word 0x2d67a
.word 0x10c0d
.word 0x63e56
.word 0x79cd26
.word 0x6a03
.word 0x7eed1e
.word 0x2bda6
.word 0x735b8
.word 0x7ef95c
.word 0x6a841
.word 0x7e35b7
.word 0x7bdd2a
.word 0x7db59e
.word 0x281ca
.word 0x7b9690
.word 0x7c3e61
.word 0x5dc6b
.word 0x5dbf7
.word 0x78c26e
.word 0x22958
.word 0x1c26b
.word 0x793a55
.word 0x78ff8
.word 0x7846f4
.word 0x31b65
.word 0x7effad
.word 0x42126
.word 0x767ab
.word 0x7a3834
.word 0x7f4199
.word 0x37cf1
.word 0x31a9d
.word 0x78beda
.word 0x7f5ffe
.word 0x7e2531
.word 0x36cc2
.word 0x786
.word 0x7f0f5f
.word 0x7c21ea
.word 0x7e5e42
.word 0x7f967c
.word 0x7e4d24
.word 0x78d34b
.word 0x4a1c7
.word 0x7e02ae
.word 0x7d6fb5
.word 0x7acc4e
.word 0x7dbc4a
.word 0x7fa6e
.word 0x12b97
.word 0x784aab
.word 0x7d58df
.word 0x1de58
.word 0xd1c7
.word 0x7e7343
.word 0x7fb0d8
.word 0x7a029c
.word 0x6c090
.word 0x5a79c
.word 0x7809e8
.word 0x7e0192
.word 0x5c25f
.word 0x7ab42d
.word 0x7c5627
.word 0x122e7
.word 0x79d34d
.word 0x14195
.word 0x7e6538
.word 0x13398
.word 0x15273
.word 0x7d18de
.word 0x7b0f99
.word 0x78839c
.word 0x7c18a3
.word 0x36675
.word 0x799f7b
.word 0x7e6104
.word 0x4a149
.word 0x79080e
.word 0x7056a
.word 0x7a1d0b
.word 0x7c4e0b
.word 0x794b37
.word 0x7c2ff
.word 0x61315
.word 0x4428b
.word 0xbcd1
.word 0x7a34c6
.word 0x62036
.word 0x760a8
.word 0x7836dc
.word 0x78d27
.word 0x1d9d9
.word 0x7eb1e4
.word 0x781df5
.word 0x7d6154
.word 0x7d80e3
.word 0x5811d
.word 0x2344c
.word 0x4aacc
.word 0x7fba21
.word 0x789bf5
.word 0x7de435
.word 0x2b9b6
.word 0x7f57f8
.word 0x4a314
.word 0x7f8ebc
.word 0x78857b
.word 0x787fa8
.word 0x7cbc5
.word 0x4e62d
.word 0x5abe8
.word 0x792aa0
.word 0x796f85
.word 0x370a8
.word 0x7e5610
.word 0x45f6b
.word 0x798809
.word 0x7f10f1
.word 0x328ea
.word 0x7fbd9c
.word 0x2e379



expand_a_temp:
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000

.globl t1_coef_0_0
t1_coef_0_0:
.word 0x99
.word 0xab
.word 0xc5
.word 0xd2
.word 0x241
.word 0xa4
.word 0x23a
.word 0x31
.word 0x1b0
.word 0x1d3
.word 0x212
.word 0xfe
.word 0x2ff
.word 0x13c
.word 0x13b
.word 0x3b7
.word 0x32d
.word 0x295
.word 0x1d9
.word 0x12e
.word 0x3bb
.word 0xce
.word 0x51
.word 0x246
.word 0x3a8
.word 0x22f
.word 0x1d0
.word 0x33f
.word 0x1c1
.word 0x3d2
.word 0x38c
.word 0x316
.word 0x109
.word 0x50
.word 0x333
.word 0x1cb
.word 0x13b
.word 0x25a
.word 0x83
.word 0xbb
.word 0x13a
.word 0x255
.word 0x337
.word 0xb7
.word 0x1ad
.word 0x346
.word 0xa9
.word 0x384
.word 0x2d8
.word 0x2b7
.word 0x337
.word 0x7c
.word 0x2dd
.word 0x169
.word 0x114
.word 0xad
.word 0x225
.word 0x37f
.word 0x1ed
.word 0xa
.word 0x55
.word 0x2f3
.word 0x3de
.word 0x3e8
.word 0xac
.word 0x347
.word 0x3dd
.word 0x323
.word 0x32c
.word 0x68
.word 0x82
.word 0x23f
.word 0x152
.word 0xff
.word 0x81
.word 0x150
.word 0x177
.word 0x3e2
.word 0x383
.word 0x15c
.word 0x1a8
.word 0x329
.word 0x3e6
.word 0xd0
.word 0x11c
.word 0x25c
.word 0x3ef
.word 0x1b6
.word 0x98
.word 0x4f
.word 0x3af
.word 0x2ac
.word 0x76
.word 0xf1
.word 0x191
.word 0x399
.word 0x31e
.word 0xf8
.word 0x13b
.word 0x241
.word 0xbe
.word 0x96
.word 0x2b2
.word 0x9
.word 0x2c5
.word 0x198
.word 0x6a
.word 0x9c
.word 0x21c
.word 0x176
.word 0x310
.word 0x6a
.word 0x3a6
.word 0x3ef
.word 0x141
.word 0x2b5
.word 0xd3
.word 0x170
.word 0xa7
.word 0x112
.word 0x16d
.word 0x2af
.word 0x3aa
.word 0x3d7
.word 0x8b
.word 0x36
.word 0xfc
.word 0x3f2
.word 0x25e
.word 0x315
.word 0x314
.word 0x313
.word 0x76
.word 0x197
.word 0x2aa
.word 0x262
.word 0x2a
.word 0x341
.word 0x87
.word 0x27
.word 0x1bb
.word 0x242
.word 0x2bb
.word 0x78
.word 0x328
.word 0x1a9
.word 0x203
.word 0x1a7
.word 0x190
.word 0x26f
.word 0x39d
.word 0x1d
.word 0xf6
.word 0xcd
.word 0x362
.word 0x1d5
.word 0x1e8
.word 0x25b
.word 0x368
.word 0x3f9
.word 0x394
.word 0x32
.word 0xf6
.word 0x1a
.word 0x250
.word 0xc8
.word 0x278
.word 0xf2
.word 0xc0
.word 0x2f
.word 0x8a
.word 0x11
.word 0x2c5
.word 0x3d1
.word 0x115
.word 0x8e
.word 0xf9
.word 0x17b
.word 0x12a
.word 0x171
.word 0x242
.word 0x188
.word 0x6
.word 0x11a
.word 0x1d6
.word 0x38d
.word 0x149
.word 0x2e
.word 0x4d
.word 0x23
.word 0x29
.word 0xfa
.word 0x26c
.word 0x1dc
.word 0x167
.word 0x26e
.word 0x12b
.word 0x34a
.word 0x2be
.word 0x14b
.word 0x2e1
.word 0x8
.word 0x251
.word 0x2
.word 0x395
.word 0x3b1
.word 0x13e
.word 0x2cb
.word 0x22d
.word 0x265
.word 0x320
.word 0x1d1
.word 0x308
.word 0x2a4
.word 0x6
.word 0x103
.word 0x331
.word 0x3a4
.word 0x3c6
.word 0x3d2
.word 0x127
.word 0x2a7
.word 0x262
.word 0xbd
.word 0x207
.word 0x23e
.word 0x3e3
.word 0x2a0
.word 0x27f
.word 0x187
.word 0x178
.word 0x2a5
.word 0x29
.word 0x2dc
.word 0x144
.word 0x30c
.word 0x352
.word 0x3d5
.word 0x166
.word 0xe3
.word 0x255
.word 0x349
.word 0x332
.word 0x237
.word 0x313
.word 0x240
.word 0x2f1
.word 0xfb
.word 0x143
.word 0x1ec
.word 0x29c
.word 0xdb
.word 0x2f6
.word 0x239
.word 0x1fd
.word 0x174
.word 0x72
.word 0x1c2
.word 0x207
.word 0x1c7
.word 0x2eb
.word 0x17c
.word 0x59
.word 0x37e
.word 0x48
.word 0x1d
.word 0x2b
.word 0x350
.word 0x82
.word 0x1cc
.word 0x261
.word 0x152
.word 0x32
.word 0x332
.word 0x20f
.word 0x145
.word 0x1b6
.word 0x1d6
.word 0x1b6
.word 0x2ea
.word 0x24
.word 0x260
.word 0x213
.word 0x1d6
.word 0x245
.word 0x27f
.word 0x3fe
.word 0x163
.word 0x35a
.word 0xc7
.word 0x14a
.word 0x29e
.word 0x1f4
.word 0x2b3
.word 0x28a
.word 0x2d5
.word 0x152
.word 0xc3
.word 0x198
.word 0x345
.word 0x3af
.word 0x336
.word 0x125
.word 0x77
.word 0x333
.word 0x31d
.word 0x136
.word 0x136
.word 0x1d8
.word 0x328
.word 0x27b
.word 0x1c0
.word 0x1a2
.word 0x17a
.word 0x297
.word 0x1b
.word 0x1fb
.word 0x3f6
.word 0x23b
.word 0x2a
.word 0x32c
.word 0x282
.word 0x364
.word 0x64
.word 0x234
.word 0x2f0
.word 0x30a
.word 0x2a1
.word 0x369
.word 0x8c
.word 0x6f
.word 0x119
.word 0x350
.word 0x3a1
.word 0x36c
.word 0x35d
.word 0x26b
.word 0x2d3
.word 0x2c0
.word 0x1c5
.word 0x86
.word 0xa9
.word 0x140
.word 0x166
.word 0x3a1
.word 0x23c
.word 0x156
.word 0x17
.word 0x265
.word 0x341
.word 0xf3
.word 0x39
.word 0x1f2
.word 0x361
.word 0x176
.word 0x11b
.word 0x142
.word 0x2a6
.word 0x1c2
.word 0xf1
.word 0x3f9
.word 0x113
.word 0x7e
.word 0x29e
.word 0x2a5
.word 0x307
.word 0x2a2
.word 0x3ba
.word 0x12b
.word 0x81
.word 0x1d2
.word 0x3cc
.word 0x2b4
.word 0x162
.word 0x392
.word 0x1ce
.word 0x2d6
.word 0x112
.word 0x1c5
.word 0x1b2
.word 0x185
.word 0x386
.word 0x299
.word 0x13e
.word 0x1bd
.word 0xa0
.word 0x28
.word 0x42
.word 0x116
.word 0x1fb
.word 0xb7
.word 0x38d
.word 0x265
.word 0xbc
.word 0x1ef
.word 0x33e
.word 0xf1
.word 0x1e2
.word 0x2e0
.word 0x48
.word 0xa2
.word 0x1a4
.word 0x1a9
.word 0x1b9
.word 0x8b
.word 0x2b8
.word 0x358
.word 0xaa
.word 0x204
.word 0x3dd
.word 0x81
.word 0x91
.word 0x3a1
.word 0x153
.word 0x2c0
.word 0x352
.word 0x1f2
.word 0x11
.word 0x31b
.word 0x259
.word 0x3ca
.word 0x6a
.word 0x1d2
.word 0x3da
.word 0x7
.word 0x317
.word 0x3ce
.word 0x1fb
.word 0x4e
.word 0x26f
.word 0x3ad
.word 0x30a
.word 0x334
.word 0x387
.word 0x2d8
.word 0x39f
.word 0x161
.word 0x167
.word 0x13d
.word 0x252
.word 0xc4
.word 0x3a2
.word 0x26e
.word 0x389
.word 0xa0
.word 0x37d
.word 0x1d7
.word 0x305
.word 0xee
.word 0x3b0
.word 0x28a
.word 0x2ae
.word 0x38c
.word 0x1a6
.word 0x187
.word 0x177
.word 0x35
.word 0x199
.word 0x26f
.word 0x1a7
.word 0x155
.word 0x355
.word 0x2cd
.word 0x3de
.word 0x21b
.word 0xcd
.word 0x88
.word 0x171
.word 0xa1
.word 0x39c
.word 0xe6
.word 0x1b9
.word 0x38a
.word 0x3a0
.word 0x98
.word 0x289
.word 0x9
.word 0x130
.word 0x23d
.word 0x315
.word 0x3df
.word 0xf9
.word 0x1ba
.word 0x331
.word 0x20b
.word 0x2bd
.word 0x187
.word 0xe
.word 0xa3
.word 0x255
.word 0x3fe
.word 0x99
.word 0x125
.word 0x2a8
.word 0x13e
.word 0x10d
.word 0x278
.word 0x25d
.word 0x1ac
.word 0xd9
.word 0xe7
.word 0x152
.word 0xd0
.word 0x2d
.word 0x56
.word 0x186
.word 0x35b
.word 0xdb
.word 0x7b
.word 0x307
.word 0x9c
.word 0x3c2
.word 0x3b9
.word 0x2f1
.word 0x17a
.word 0x2c3
.word 0x12a
.word 0x21
.word 0x193
.word 0x37c
.word 0x1cc
.word 0x254
.word 0x128
.word 0x2a0
.word 0x1bd
.word 0x15a
.word 0x137
.word 0x338
.word 0x8
.word 0x10d
.word 0x2a6
.word 0x2ed
.word 0x185
.word 0x1b8
.word 0x331
.word 0x1d3
.word 0x176
.word 0x3f6
.word 0x118
.word 0x168
.word 0x3f3
.word 0x36a
.word 0x80
.word 0x1e1
.word 0x160
.word 0x341
.word 0x3ea
.word 0x6e
.word 0x316
.word 0x3ac
.word 0x1ac
.word 0xed
.word 0x1ee
.word 0x4c
.word 0xff
.word 0x3a7
.word 0xef
.word 0x1c6
.word 0x8f
.word 0x2ac
.word 0x2cd
.word 0xad
.word 0x2d1
.word 0x1e9
.word 0x46
.word 0x2a1
.word 0x121
.word 0x273
.word 0x2ec
.word 0xa1
.word 0x229
.word 0x7e
.word 0x8d
.word 0x346
.word 0x76
.word 0x39e
.word 0x225
.word 0x178
.word 0xb9
.word 0x106
.word 0x3fb
.word 0x6e
.word 0x115
.word 0x9d
.word 0x197
.word 0x200
.word 0x304
.word 0x324
.word 0x22e
.word 0x28b
.word 0x3e7
.word 0xbc
.word 0x233
.word 0x2e6
.word 0x3e
.word 0x9f
.word 0x1a9
.word 0x18
.word 0x7d
.word 0x125
.word 0x28
.word 0x1d7
.word 0x6d
.word 0x118
.word 0x6d
.word 0x269
.word 0x356
.word 0x333
.word 0x214
.word 0x2a8
.word 0x362
.word 0x2e2
.word 0x347
.word 0x77
.word 0x138
.word 0x271
.word 0x7
.word 0x387
.word 0xca
.word 0x1e5
.word 0x94
.word 0x34e
.word 0x31
.word 0x242
.word 0x3c9
.word 0x326
.word 0x107
.word 0x245
.word 0x36
.word 0x33e
.word 0x17a
.word 0x1d8
.word 0x170
.word 0x39f
.word 0x42
.word 0x124
.word 0x41
.word 0x45
.word 0x2aa
.word 0xe5
.word 0x233
.word 0x172
.word 0x31a
.word 0x1c0
.word 0x3eb
.word 0x364
.word 0x294
.word 0x351
.word 0x302
.word 0x2a9
.word 0x24d
.word 0x257
.word 0x2ae
.word 0x20
.word 0x92
.word 0x104
.word 0x29e
.word 0x6
.word 0x307
.word 0x358
.word 0x8a
.word 0x338
.word 0x2ee
.word 0x3a4
.word 0x343
.word 0x117
.word 0x151
.word 0x132
.word 0x13e
.word 0x4b
.word 0xb7
.word 0x337
.word 0x15b
.word 0x347
.word 0x1df
.word 0x2dd
.word 0x131
.word 0x8a
.word 0x2be
.word 0xaf
.word 0x362
.word 0xda
.word 0x243
.word 0x2f0
.word 0xa2
.word 0xd0
.word 0x3ba
.word 0x119
.word 0x26
.word 0x250
.word 0x1cc
.word 0x257
.word 0x1ae
.word 0x177
.word 0x241
.word 0x31c
.word 0x3ce
.word 0x1c
.word 0x3a6
.word 0x26f
.word 0x3ee
.word 0x11b
.word 0x3f2
.word 0x16c
.word 0xc5
.word 0x3d3
.word 0x1b7
.word 0x282
.word 0xe8
.word 0x11e
.word 0x38c
.word 0x301
.word 0x5b
.word 0x2c7
.word 0x355
.word 0x378
.word 0x2d9
.word 0x2ff
.word 0x311
.word 0x3cf
.word 0x31a
.word 0x10f
.word 0xd0
.word 0x1db
.word 0x1c7
.word 0x32d
.word 0x92
.word 0x176
.word 0x2e2
.word 0x3c6
.word 0x132
.word 0x137
.word 0x11
.word 0x351
.word 0x272
.word 0x26f
.word 0x183
.word 0xc4
.word 0x340
.word 0x15c
.word 0x194
.word 0x206
.word 0x2d9
.word 0xfd
.word 0x197
.word 0x1c9
.word 0xad
.word 0x6d
.word 0x105
.word 0x389
.word 0x9a
.word 0x132
.word 0x2e7
.word 0x4a
.word 0x75
.word 0x2fa
.word 0x42
.word 0x105
.word 0x7f
.word 0x35b
.word 0x3e3
.word 0x213
.word 0x1d0
.word 0x15f
.word 0xde
.word 0x3e9
.word 0x3c0
.word 0x143
.word 0x377
.word 0x371
.word 0xe8
.word 0x33b
.word 0x1bf
.word 0x1ec
.word 0x2e4
.word 0x3d1
.word 0xd5
.word 0x365
.word 0x208
.word 0x1b
.word 0x342
.word 0x2a9
.word 0x3b0
.word 0x2b8
.word 0x1aa
.word 0x47
.word 0xf8
.word 0x157
.word 0x279
.word 0x29d
.word 0x33c
.word 0x19c
.word 0x157
.word 0x3cc
.word 0x3c
.word 0x2c6
.word 0x1dc
.word 0x361
.word 0x3f0
.word 0x29f
.word 0x1fe
.word 0xdc
.word 0x98
.word 0x3d4
.word 0x37a
.word 0x38f
.word 0x1f3
.word 0x3ed
.word 0x3ae
.word 0x1da
.word 0xfa
.word 0x13e
.word 0x14d
.word 0x3db
.word 0x98
.word 0xc0
.word 0x35d
.word 0x25
.word 0x191
.word 0x18b
.word 0x8d
.word 0x7d
.word 0x10e
.word 0x16d
.word 0x38c
.word 0x9a
.word 0x3a7
.word 0x371
.word 0x1df
.word 0x335
.word 0x18d
.word 0x2d
.word 0x3e3
.word 0xf2
.word 0x13d
.word 0x175
.word 0x3f5
.word 0xa8
.word 0x294
.word 0x54
.word 0x10
.word 0x228
.word 0x5
.word 0x318
.word 0x1e0
.word 0x1fc
.word 0x14f
.word 0x1ac
.word 0x385
.word 0x159
.word 0x21f
.word 0x5e
.word 0x302
.word 0xee
.word 0xc9
.word 0x106
.word 0x184
.word 0x1fb
.word 0x242
.word 0x134
.word 0x2e0
.word 0x27e
.word 0x238
.word 0x11a
.word 0x1c8
.word 0x132
.word 0x149
.word 0xe
.word 0x1e5
.word 0xd9
.word 0x2d2
.word 0x2b3
.word 0x1a1
.word 0x347
.word 0x3a7
.word 0x2fa
.word 0x1d6
.word 0x3d
.word 0x4d
.word 0x11d
.word 0x3bf
.word 0x275
.word 0x3a3
.word 0x2a4
.word 0x39c
.word 0x221
.word 0xf3
.word 0x384
.word 0x34
.word 0x282
.word 0x2cb
.word 0x253
.word 0x126
.word 0x210
.word 0x2ca
.word 0x322
.word 0x294
.word 0x358
.word 0xa
.word 0x2ab
.word 0x6d
.word 0x21e
.word 0xf6
.word 0x337
.word 0xfb
.word 0x2ff
.word 0x19b
.word 0x204
.word 0x15d
.word 0xb
.word 0x17a
.word 0x50
.word 0x345
.word 0x150
.word 0x10b
.word 0x2a5
.word 0x11a
.word 0x31
.word 0x5e
.word 0x5
.word 0x17a
.word 0x223
.word 0x3c2
.word 0x175
.word 0x389
.word 0x329
.word 0x196
.word 0x29e
.word 0x366
.word 0x194
.word 0x11e
.word 0x10e
.word 0x34f
.word 0x158
.word 0x279
.word 0x78
.word 0x9
.word 0x1ef
.word 0x3e2
.word 0x15a
.word 0x3c9
.word 0x3f4
.word 0x241
.word 0x35b
.word 0x297
.word 0x37d
.word 0xa4
.word 0x2f
.word 0x20b
.word 0x2be
.word 0x376
.word 0xb0
.word 0x36e
.word 0x7e
.word 0x74
.word 0x3eb
.word 0x12
.word 0x235
.word 0x105
.word 0x22
.word 0x69
.word 0x284
.word 0xaf
.word 0x84
.word 0xc1
.word 0x178
.word 0x16a
.word 0x30d
.word 0x117
.word 0x21e
.word 0x35c
.word 0xe4
.word 0xa
.word 0x38
.word 0x3e9
.word 0x12
.word 0x22f
.word 0x3ee
.word 0x14b
.word 0x3bc
.word 0x98
.word 0x3c1
.word 0x5c
.word 0x1c2
.word 0x213
.word 0x1d9
.word 0x233
.word 0x328
.word 0x372
.word 0x361
.word 0xea
.word 0x1be
.word 0x174
.word 0x114
.word 0x1ca
.word 0x8c
.word 0x3e8
.word 0x226
.word 0x132
.word 0x1aa
.word 0x353
.word 0x26a
.word 0x1af
.word 0x2bd
.word 0xd0
.word 0x9e
.word 0x29f
.word 0x323
.word 0x329
.word 0x2a9
.word 0x350
.word 0x340
.word 0x2d3
.word 0x1ed
.word 0x333
.word 0x3e9
.word 0x1a3
.word 0x37d
.word 0x2f1
.word 0xd6
.word 0x2ea
.word 0x27e
.word 0xe6
.word 0xc9
.word 0xba
.word 0x3ee
.word 0xa4
.word 0x130
.word 0x2d2
.word 0x267
.word 0x109
.word 0x37b
.word 0xea
.word 0xb0
.word 0xef
.word 0x111
.word 0x16e
.word 0x2e4
.word 0x136
.word 0x261
.word 0x203
.word 0x3d
.word 0x133
.word 0x333
.word 0x147
.word 0xcf
.word 0x3db
.word 0x1f2
.word 0x2e3
.word 0x2db
.word 0x32f
.word 0x224
.word 0xf3
.word 0x1f0
.word 0x185
.word 0xc9
.word 0x54
.word 0x3f4
.word 0xac
.word 0xa9
.word 0x10a
.word 0x209
.word 0x233
.word 0x126
.word 0xa2
.word 0x3dc
.word 0x314
.word 0x381
.word 0x1f6
.word 0x139
.word 0xc5
.word 0x2d6
.word 0x21a
.word 0x2c4
.word 0x3ee
.word 0x3b5
.word 0x38e
.word 0x369
.word 0x2f7
.word 0x36b
.word 0x19a
.word 0x13a
.word 0x74
.word 0x10f
.word 0x19a
.word 0x3ac
.word 0x53
.word 0x3d3
.word 0xde
.word 0x223
.word 0xb1
.word 0x14b
.word 0x10c
.word 0x260
.word 0x217
.word 0x84
.word 0x2fc
.word 0x147
.word 0x16a
.word 0x17b
.word 0x9b
.word 0x262
.word 0x35b
.word 0x31b
.word 0x110
.word 0x3c4
.word 0x2d6
.word 0x1bb
.word 0x7b
.word 0x225
.word 0x2d1
.word 0x2e0
.word 0x1c9
.word 0x15d
.word 0x2cb
.word 0x2df
.word 0xa
.word 0x2f0
.word 0x1ef
.word 0x349
.word 0x20b
.word 0xe6
.word 0x24d
.word 0x33
.word 0x10f
.word 0x6
.word 0x2d0
.word 0x3a7
.word 0x35d
.word 0x35b
.word 0x22e
.word 0x29
.word 0x2fe
.word 0x31b
.word 0x96
.word 0x290
.word 0x33
.word 0x17f
.word 0x256
.word 0x2a7
.word 0x99
.word 0x2e8
.word 0x38a
.word 0x76
.word 0x2b7
.word 0x197
.word 0xd2
.word 0x368
.word 0x37c
.word 0x346
.word 0x5a
.word 0x398
.word 0x209
.word 0x1d3
.word 0x5f
.word 0x3b0
.word 0x15f
.word 0x10f
.word 0x38b
.word 0x259
.word 0x2a7
.word 0x371
.word 0x68
.word 0x6c
.word 0x10a
.word 0xe6
.word 0xcd
.word 0x329
.word 0x112
.word 0x129
.word 0x369
.word 0x7b
.word 0x393
.word 0x301
.word 0x1cc
.word 0x371
.word 0x70
.word 0x212
.word 0x1bb
.word 0x39d
.word 0x173
.word 0xf3
.word 0x3e2
.word 0x30e
.word 0x320
.word 0x13d
.word 0x385
.word 0x1c7
.word 0x2b4
.word 0x3ad
.word 0x1bd
.word 0x366
.word 0x1e1
.word 0x106
.word 0x3f6
.word 0x35b
.word 0x84
.word 0x3bc
.word 0x14
.word 0x335
.word 0x133
.word 0x156
.word 0x3d1
.word 0x3d0
.word 0x2da
.word 0x227
.word 0x94
.word 0x1b2
.word 0x252
.word 0x165
.word 0xc9
.word 0x33
.word 0x2e4
.word 0x2c9
.word 0x19c
.word 0x397
.word 0x8
.word 0x386
.word 0x3c8
.word 0xa
.word 0x1ea
.word 0x26d
.word 0x2ff
.word 0xd1
.word 0x2b5
.word 0x24f
.word 0x376
.word 0x25c
.word 0x175
.word 0x362
.word 0x34b
.word 0x312
.word 0x19a
.word 0x18c
.word 0x137
.word 0x69
.word 0x2aa
.word 0x30
.word 0x284
.word 0x13c
.word 0x3b9
.word 0x1d0
.word 0x27c
.word 0x2a0
.word 0x26c
.word 0x253
.word 0x22f
.word 0x312
.word 0x306
.word 0x320
.word 0x302
.word 0x371
.word 0x282
.word 0x350
.word 0x3c2
.word 0x381
.word 0x1e7
.word 0xfc
.word 0x39a
.word 0x6e
.word 0x3e4
.word 0x3b4
.word 0x333
.word 0x379
.word 0x19
.word 0x31e
.word 0x12b
.word 0x3d5
.word 0x307
.word 0x244
.word 0x32e
.word 0x251
.word 0x64
.word 0x19
.word 0x2c2
.word 0x7b
.word 0x26f
.word 0x21f
.word 0x314
.word 0x1ca
.word 0xa
.word 0x1e2
.word 0x26a
.word 0x1f1
.word 0x1d8
.word 0x3f5
.word 0x19f
.word 0x257
.word 0x336
.word 0x7
.word 0x27d
.word 0x3
.word 0x231
.word 0x186
.word 0x2e0
.word 0xa8
.word 0x13a
.word 0x1da
.word 0x3f2
.word 0xe5
.word 0xa7
.word 0x34b
.word 0x76
.word 0x3e5
.word 0xbb
.word 0x1f0
.word 0x335
.word 0x2b9
.word 0x1c4
.word 0x3ea
.word 0x2c
.word 0x2d9
.word 0x16
.word 0x3d
.word 0x2c
.word 0x347
.word 0x133
.word 0x1d5
.word 0x294
.word 0x2fe
.word 0x214
.word 0x15d
.word 0x184
.word 0x1d3
.word 0x3fa
.word 0x60
.word 0x2dd
.word 0x11
.word 0x164
.word 0x358
.word 0x216
.word 0x177
.word 0xd3
.word 0x337
.word 0x395
.word 0x35e
.word 0x88
.word 0xf3
.word 0x289
.word 0x34b
.word 0x360
.word 0x3e1
.word 0x1c2
.word 0x1e
.word 0x36a
.word 0x29d
.word 0x105
.word 0x115
.word 0xb6
.word 0x20a
.word 0x3e7
.word 0x1e2
.word 0x170
.word 0xa
.word 0x315
.word 0x31d
.word 0x94
.word 0x327
.word 0x308
.word 0x1ab
.word 0x4e
.word 0x395
.word 0x222
.word 0x2f2
.word 0x31e
.word 0x336
.word 0x314
.word 0x237
.word 0x1a8
.word 0x1d2
.word 0x3a
.word 0xb
.word 0x291
.word 0x311
.word 0x1bb
.word 0x3f
.word 0xc2
.word 0x311
.word 0xf3
.word 0x260
.word 0x244
.word 0x277
.word 0x15
.word 0x36a
.word 0x31f
.word 0x3d6
.word 0x132
.word 0xcf
.word 0x2bb
.word 0x124
.word 0xb1
.word 0x21b
.word 0x39c
.word 0x1cd
.word 0x30c
.word 0x218
.word 0x305
.word 0x100
.word 0x3b
.word 0x202
.word 0xb4
.word 0x3e8
.word 0x24b
.word 0xbf
.word 0x175
.word 0x1da
.word 0x3d9
.word 0x175
.word 0x1c0
.word 0x110
.word 0x348
.word 0x39
.word 0x274
.word 0xca
.word 0x2e4
.word 0x13a
.word 0x3d5
.word 0x1a7
.word 0x376
.word 0x193
.word 0x26a
.word 0x179
.word 0x207
.word 0x3c2
.word 0xcb
.word 0x1f2
.word 0x380
.word 0xda
.word 0x118
.word 0x25a
.word 0x201
.word 0x31d
.word 0xfa
.word 0x240
.word 0x120
.word 0x3dc
.word 0x31
.word 0x313
.word 0x29d
.word 0x27e
.word 0x2d0
.word 0x96
.word 0x232
.word 0x2c6
.word 0x2a1
.word 0xf2
.word 0x394
.word 0x1a7
.word 0x3cf
.word 0x28e
.word 0x113
.word 0xb4
.word 0x2d1
.word 0x2d1
.word 0x34
.word 0x34a
.word 0x52
.word 0x196
.word 0x331
.word 0x215
.word 0x39e
.word 0x59
.word 0x391
.word 0x194
.word 0x3a6
.word 0x1cd
.word 0x2ce
.word 0x34e
.word 0x35c
.word 0x222
.word 0x19
.word 0x87
.word 0xb9
.word 0x17e
.word 0x58
.word 0x34c
.word 0x31d
.word 0x1d4
.word 0x24b
.word 0x10a
.word 0x340
.word 0x120
.word 0x1b0
.word 0xcf
.word 0x322
.word 0x216
.word 0xe6
.word 0x2e
.word 0x21a
.word 0x40
.word 0xc1
.word 0x262
.word 0x73
.word 0x37c
.word 0x2f
.word 0x2f1
.word 0x167
.word 0x3f7
.word 0x50
.word 0xe1
.word 0x272
.word 0x3b0
.word 0x259
.word 0xb5
.word 0x1d3
.word 0xe5
.word 0x1ba
.word 0x321
.word 0x120
.word 0x2a4
.word 0x379
.word 0x20e
.word 0x3bf
.word 0x2e5
.word 0x2d5
.word 0x1bf
.word 0x1ad
.word 0x1df
.word 0x288
.word 0x29e
.word 0x34c
.word 0xc
.word 0x282
.word 0xf0
.word 0x59
.word 0x188
.word 0x66
.word 0x264
.word 0x374
.word 0x2a3
.word 0x266
.word 0x221
.word 0x1c4
.word 0x3cc
.word 0x1ea
.word 0x29c

A_coeff_0:
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
