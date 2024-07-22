/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* Dilithium-V Verify Implementation */


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
.globl prime
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
.word 0xa7f3f997
.word 0x15cb9480
.word 0xfb7e46a
.word 0x3f2ff5e0
.word 0x586b2dc9
.word 0x659d6c28
.word 0x983800e
.word 0x89b62123

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
.word 0xa58ccbe4
.word 0x43c96b6
.word 0xc68a2111
.word 0xe3110b99
.word 0x4f106988
.word 0x8fffb913
.word 0xdee809a9
.word 0x4a0e3e03
.word 0x8b9258da
.word 0x680df89f
.word 0xa649662a
.word 0x2ea5ef05
.word 0x0 
.word 0x0 
.word 0x0 
.word 0x0 

/* hint */
.globl hint0
hint0:
.word 0x0
.word 0x0
.word 0x0
.word 0x2000
.word 0x80
.word 0x8000
.word 0x0
.word 0x40200
.word 0x0
.word 0x6400000
.word 0x8000000
.word 0x8000000
.word 0x5000000
.word 0x0
.word 0x4
.word 0x0
.word 0x20000000
.word 0x0
.word 0x80000000
.word 0x28000000
.word 0x1008
.word 0x0
.word 0x40000000
.word 0x0
.word 0x20
.word 0x20000000
.word 0x4000000
.word 0x8000040
.word 0x0
.word 0x0
.word 0x0
.word 0x0
.word 0x0
.word 0x802000
.word 0x2
.word 0x10000000
.word 0x20000400
.word 0x8
.word 0xc200
.word 0x10
.word 0x0
.word 0x8000000
.word 0x4
.word 0x0
.word 0x8
.word 0x2004000
.word 0x0
.word 0x1000000
.word 0x0
.word 0x80000040
.word 0x2000
.word 0x10000
.word 0x0
.word 0x0
.word 0x10000000
.word 0x0
.word 0x0
.word 0x20
.word 0x4020
.word 0x0
.word 0x8040008
.word 0x2200000
.word 0x20000000
.word 0x0

  
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
.word 0x7bca7d
.word 0x2688b
.word 0x5d17
.word 0x196be
.word 0x7f13c9
.word 0x79cb1e
.word 0x7f466d
.word 0x4440b
.word 0x789d06
.word 0x78f8d3
.word 0x7ed9f5
.word 0x742af
.word 0x7a1714
.word 0x79abff
.word 0x784f49
.word 0x76ea1
.word 0x7cb792
.word 0x7b62e6
.word 0x4b81
.word 0x7d60d
.word 0x7b1261
.word 0x1e0ec
.word 0x49563
.word 0x29ad3
.word 0x7f6416
.word 0x7e2194
.word 0x7c9661
.word 0x7f9fa2
.word 0x79c4b5
.word 0x41d60
.word 0x7bf693
.word 0x778fc
.word 0x69028
.word 0x78eda6
.word 0x78ed63
.word 0x79e697
.word 0x64973
.word 0x323ff
.word 0x7dbbff
.word 0x6e56a
.word 0x7b32f4
.word 0x7977be
.word 0x7f784c
.word 0x7e9df
.word 0x7bb716
.word 0x7cfa8b
.word 0x794cd2
.word 0x6309f
.word 0x7a74d
.word 0x7f4c45
.word 0x1858e
.word 0x7d7be0
.word 0x35328
.word 0x786ba9
.word 0x39d48
.word 0x7c874c
.word 0x789959
.word 0x7a6e12
.word 0x7a9698
.word 0x72fd9
.word 0x7d2b6f
.word 0x7f9862
.word 0x7c078a
.word 0x57d81
.word 0x77e407
.word 0x76ae5
.word 0x7b282b
.word 0x79ca70
.word 0x54492
.word 0x78ab6a
.word 0x7f62b7
.word 0x7808ea
.word 0x57dec
.word 0x54a6d
.word 0x5b969
.word 0xa520
.word 0x7af6e6
.word 0x221d9
.word 0x34665
.word 0x78443
.word 0x782c71
.word 0x7fdbdb
.word 0xbc62
.word 0x7f6f3e
.word 0x7f354a
.word 0x66d01
.word 0x8dca
.word 0x7e47e2
.word 0x7dd43d
.word 0x1705b
.word 0x675c0
.word 0x788212
.word 0x78a335
.word 0x3f571
.word 0x7fc706
.word 0x78f3e7
.word 0x525ca
.word 0x7c5578
.word 0x7e6d6e
.word 0x7bbafb
.word 0x7abf99
.word 0x79d209
.word 0x69de4
.word 0x7975ac
.word 0x580c0
.word 0x7b5add
.word 0x7d5a7c
.word 0x7850d
.word 0x7360d
.word 0x7ea9fb
.word 0x7a247d
.word 0x334f5
.word 0x6f72f
.word 0x24961
.word 0x79b03e
.word 0x7e39bd
.word 0x38771
.word 0x7cf37b
.word 0x6f1f0
.word 0x7ad3a1
.word 0x7af767
.word 0x7b90ff
.word 0x7e298f
.word 0x7e7116
.word 0xa09d
.word 0x7bb09c
.word 0x32500
.word 0x7f30ff
.word 0x6e2a7
.word 0x4f680
.word 0x7b03a7
.word 0xabd3
.word 0x2d35f
.word 0x78263a
.word 0x79be00
.word 0x30a94
.word 0x7a4b25
.word 0x3ed2b
.word 0x5fe0a
.word 0x4c1b6
.word 0x68e8
.word 0x7ab74d
.word 0x7aeb95
.word 0xac27
.word 0x51283
.word 0x78f8c5
.word 0x2c8c4
.word 0x620e5
.word 0x1111e
.word 0x7efca9
.word 0x121b1
.word 0x7c5b38
.word 0x4b723
.word 0x66241
.word 0x78723d
.word 0x54a0a
.word 0x1f9a3
.word 0x5fc8
.word 0x7951dc
.word 0x7c022d
.word 0x7db7d3
.word 0x57f0
.word 0x4940c
.word 0x7b82d2
.word 0x12698
.word 0x5a21
.word 0x7b6981
.word 0x4ffd3
.word 0x6d337
.word 0x77f5b4
.word 0x7c4bc4
.word 0x79d837
.word 0x44e3b
.word 0x7b933d
.word 0x78bf92
.word 0x4cf92
.word 0x478eb
.word 0x5cb18
.word 0x79b4b8
.word 0x10b12
.word 0x7b8d46
.word 0x78ce8d
.word 0x1a6a4
.word 0x13f6a
.word 0x7a6b45
.word 0x9df5
.word 0x251fe
.word 0x14132
.word 0x18518
.word 0x7bb9ae
.word 0x77cf5
.word 0x7f8fe3
.word 0x77e753
.word 0x69a94
.word 0x3b226
.word 0x13bd8
.word 0xfb17
.word 0x7c36b1
.word 0xcb2f
.word 0x6ec6d
.word 0x7e15a1
.word 0x43bb8
.word 0x79d587
.word 0xb00a
.word 0x7c765f
.word 0x123a3
.word 0x11920
.word 0x7a6821
.word 0x7e704f
.word 0x69ce6
.word 0x7fdd56
.word 0x7a8b05
.word 0x25e7f
.word 0x7cfda1
.word 0x7bba68
.word 0x51fb1
.word 0x7de158
.word 0x7fb3d2
.word 0x780f6f
.word 0x72dee
.word 0x2541e
.word 0x52062
.word 0x4654d
.word 0x23839
.word 0x1e8f3
.word 0x7deb9b
.word 0x7a66db
.word 0x4b06
.word 0x7b37a9
.word 0xc75e
.word 0x7bb1f2
.word 0x7ec3ae
.word 0x7ec150
.word 0x1d3f0
.word 0x7c724d
.word 0x7cbcbb
.word 0x7f32d
.word 0x57039
.word 0x7d8f1b
.word 0x7d378
.word 0x3c7cc
.word 0x45f17
.word 0x6985f
.word 0x322c2
.word 0x79996f
.word 0x7f4e3d
.word 0x7f9883
.word 0x783c8d
.word 0x7bf0dc
.word 0x7fe71
.word 0x7c43f5
.word 0x790e76
.word 0x7d7056
.word 0x4f0ed
.word 0x8219
.word 0x1bd10
.word 0x780625
.word 0x7da25f
.word 0x79f68e
.word 0x1658c
.word 0x7e892
.word 0x704b6
.word 0x17ecf
.word 0x37805
.word 0x51f8f
.word 0x7890f5
.word 0x6a61
.word 0x477b3
.word 0x7ebc26
.word 0x7af049
.word 0x1e7d4
.word 0x5e3b6
.word 0x63953
.word 0x7112f
.word 0x78bece
.word 0x10db4
.word 0x57454
.word 0x7f6b34
.word 0x1eeb9
.word 0x153b7
.word 0x7d38ca
.word 0x7ddab7
.word 0x7a3e1f
.word 0xe76c
.word 0x7ea505
.word 0x7b762c
.word 0x10b3b
.word 0x6ceed
.word 0x29197
.word 0x6f537
.word 0x7be577
.word 0x7ae65b
.word 0x798485
.word 0x5e8d6
.word 0x32d5c
.word 0x45198
.word 0x32fd
.word 0x7f50b5
.word 0x4cb10
.word 0x78905b
.word 0x7bcb38
.word 0x78e62b
.word 0xf738
.word 0x2547
.word 0x7dca9
.word 0x6a588
.word 0xe53
.word 0x7f23c4
.word 0x7c2f0a
.word 0x1ecb6
.word 0x573af
.word 0x723fc
.word 0x79d7fb
.word 0x5721c
.word 0x37e00
.word 0x7e7642
.word 0x39bef
.word 0x7bce
.word 0x6a763
.word 0x7f972e
.word 0x7b8599
.word 0x7f860d
.word 0x1422d
.word 0x7c4d5f
.word 0x7aa258
.word 0x7ef43e
.word 0x794787
.word 0x1cc4d
.word 0x32231
.word 0x7953e3
.word 0x78be65
.word 0x7b088a
.word 0x4425
.word 0x7afdae
.word 0x7e8855
.word 0x44a90
.word 0x7effd1
.word 0x28e7e
.word 0x7b2e72
.word 0x7ca4f9
.word 0x5ff7
.word 0x1d404
.word 0x54de8
.word 0x7d9ef5
.word 0x7964dc
.word 0x20d98
.word 0xde8c
.word 0x4b0a2
.word 0x7af312
.word 0x61493
.word 0x7e1ce1
.word 0x5905d
.word 0x41abc
.word 0x7a90c1
.word 0x47f29
.word 0x7b0ca6
.word 0x15bfc
.word 0x5907d
.word 0x7bf40f
.word 0x365cf
.word 0x7c799b
.word 0x79b375
.word 0xd1f4
.word 0x514b9
.word 0x58345
.word 0x7f0fb
.word 0x7a417
.word 0x7da522
.word 0x50603
.word 0x1e203
.word 0x7da1d0
.word 0x7ef81f
.word 0x787c43
.word 0x66b39
.word 0x7d8ef9
.word 0x14ee
.word 0x7d2533
.word 0x7a3e7e
.word 0x7a76a3
.word 0x7b8c22
.word 0xc4b1
.word 0x784683
.word 0x45d30
.word 0x6e946
.word 0x51abf
.word 0x64fa3
.word 0x7ef710
.word 0x78c4c2
.word 0x787c2a
.word 0x549b7
.word 0x7a0c34
.word 0x7d5f17
.word 0x7fad12
.word 0x7b1de2
.word 0x2cbb3
.word 0x4d59e
.word 0x79b0b5
.word 0x79ceb
.word 0x2f865
.word 0x5bc3d
.word 0x11f46
.word 0x7dc5aa
.word 0x51fb2
.word 0x29531
.word 0x7bd3e2
.word 0x74c90
.word 0x7f29df
.word 0x7fd688
.word 0x11e49
.word 0x791f9
.word 0x782c60
.word 0x538e2
.word 0x6e0a9
.word 0x7c8a35
.word 0x794235
.word 0x55fba
.word 0x41d92
.word 0x194bc
.word 0x1551e
.word 0x7f0764
.word 0x7cb45d
.word 0x55205
.word 0x7a13aa
.word 0x7d10d8
.word 0x79d78d
.word 0x68d0c
.word 0x50ac7
.word 0x79eaf9
.word 0x6978c
.word 0x7aa637
.word 0x70737
.word 0x7c2314
.word 0x79dbdb
.word 0x6a496
.word 0x60402
.word 0x7af667
.word 0x4dd80
.word 0x4140
.word 0x7a70c5
.word 0x7e970d
.word 0x7a7fc2
.word 0x45b7
.word 0x2f024
.word 0x7adccd
.word 0x7966a
.word 0x7b1ccd
.word 0x79342c
.word 0xf2c9
.word 0x7b8d67
.word 0x785652
.word 0x7fb3a3
.word 0x799358
.word 0x58625
.word 0x78ffca
.word 0x7efca0
.word 0x399b8
.word 0x7848ba
.word 0x7d547b
.word 0xc64
.word 0x7ca8d3
.word 0x52d9c
.word 0x7f329d
.word 0x7ec21e
.word 0x7a37f
.word 0x69b45
.word 0x7a7aaf
.word 0x2c603
.word 0x7fc937
.word 0x6c3d9
.word 0x3b65c
.word 0x7529a
.word 0x7994f7
.word 0x77b3
.word 0x2df3d
.word 0x49767
.word 0x10017
.word 0x5753
.word 0x79b740
.word 0x25fbf
.word 0x5f7b2
.word 0x4e707
.word 0x5137a
.word 0x3521f
.word 0x7b14f5
.word 0x7af8c7
.word 0x780524
.word 0x1568c
.word 0x7b6b3c
.word 0x7f6b6d
.word 0x55765
.word 0x7bd009
.word 0x7ebbad
.word 0x66563
.word 0x53d34
.word 0x7f7533
.word 0x7e8808
.word 0x7a948f
.word 0x631c2
.word 0x7bdce1
.word 0x3f60c
.word 0x7a262c
.word 0x785904
.word 0x5576b
.word 0x431d6
.word 0x7be946
.word 0x21516
.word 0x7a2f80
.word 0x79d564
.word 0x7992dc
.word 0xc597
.word 0x39b5e
.word 0x7ecc52
.word 0x55af3
.word 0x7e15cf
.word 0x45c
.word 0x7a3704
.word 0x6de52
.word 0x860b
.word 0x7da28a
.word 0x487e3
.word 0x78532e
.word 0x7f41a4
.word 0x163ae
.word 0x6483b
.word 0x1b8ce
.word 0x7a1273
.word 0x1675c
.word 0x7fc3f4
.word 0x7bec1e
.word 0x7e7452
.word 0x7b9535
.word 0x7bdedb
.word 0x7f89c5
.word 0x4d834
.word 0x4b88c
.word 0x3b010
.word 0x652d3
.word 0x4ea5a
.word 0x282dd
.word 0x7f9eaa
.word 0x14d4b
.word 0x1a16f
.word 0x7a94b
.word 0x7da7a0
.word 0x7dcbf
.word 0x2f52d
.word 0x7ee51d
.word 0x7dbdc6
.word 0x63ca3
.word 0x7b086e
.word 0x359d3
.word 0x7bf489
.word 0x4d9d4
.word 0x79eda7
.word 0x7d8bc5
.word 0x52d64
.word 0x78d1bc
.word 0x614a1
.word 0x782e9f
.word 0x50091
.word 0x7ebe1d
.word 0x7de1c2
.word 0x7a51d2
.word 0x7fdca5
.word 0x66934
.word 0x7ad416
.word 0x7c3f53
.word 0x20d9f
.word 0x7933ed
.word 0x5886c
.word 0x7c6d96
.word 0x295ec
.word 0x7d73c8
.word 0x5e365
.word 0x7a4ccf
.word 0x4ea8
.word 0x3ef6f
.word 0x508a8
.word 0x7ee0a2
.word 0x7fb00c
.word 0x7a739b
.word 0x9469
.word 0x77f73b
.word 0x77ed5
.word 0x77937
.word 0x73bd
.word 0x53162
.word 0x42ef2
.word 0x1e07f
.word 0x39467
.word 0x6785d
.word 0x16cf
.word 0x7a8070
.word 0x7c9f1c
.word 0x14e14
.word 0x7b9b91
.word 0x7b6ed7
.word 0x7c6199
.word 0x7e6749
.word 0x6814f
.word 0x7d1a54
.word 0x7adcf5
.word 0xd9ff
.word 0x21267
.word 0x7a45e8
.word 0x4ce45
.word 0x210f2
.word 0x7c1b2b
.word 0x6cedc
.word 0x531c6
.word 0x7d6370
.word 0x7e6311
.word 0x7da195
.word 0x410a2
.word 0x7ab9ff
.word 0x7aca21
.word 0x7fc0fa
.word 0x19dcc
.word 0x26f81
.word 0x7b6dd6
.word 0x7a04ac
.word 0x2f380
.word 0x7f942e
.word 0x9aa4
.word 0x63a8
.word 0x61fce
.word 0x5fe9f
.word 0x2a9d6
.word 0x28388
.word 0x7fd6b
.word 0xae23
.word 0x42cee
.word 0x58bb7
.word 0x7e76c3
.word 0x4e1af
.word 0x7da360
.word 0x7d9866
.word 0x7fb5d3
.word 0xea99
.word 0x71aa
.word 0x48b33
.word 0x1f0bc
.word 0x69f16
.word 0x764a9
.word 0xa22c
.word 0x81b4
.word 0x7c948b
.word 0x77c3c
.word 0x52bf4
.word 0x7b33ef
.word 0x16ecb
.word 0x7c8bd0
.word 0x10c1
.word 0x5d0dd
.word 0x3558f
.word 0x617f0
.word 0x7e16b9
.word 0x5054
.word 0xef2d
.word 0x35620
.word 0x32794
.word 0x193b7
.word 0x6d025
.word 0x5ebca
.word 0x7b240
.word 0x7cb2a2
.word 0x7dd1a3
.word 0x7b0e1a
.word 0x7a8cd0
.word 0x26803
.word 0x3758d
.word 0x7a9737
.word 0x7de240
.word 0x7b58cb
.word 0x7829c4
.word 0x53bce
.word 0x7d64ac
.word 0x6cc04
.word 0x2b22c
.word 0xed44
.word 0x28e3c
.word 0x7cbd2b
.word 0x45ee2
.word 0x7d8764
.word 0x1317e
.word 0x29140
.word 0x488ff
.word 0x638b0
.word 0x61e4d
.word 0x7f589e
.word 0x56e7d
.word 0x7e5487
.word 0x7d3430
.word 0x7a8942
.word 0x70e73
.word 0x7d7603
.word 0x79190
.word 0x57197
.word 0x55eec
.word 0x1432
.word 0x19743
.word 0x7e384a
.word 0x7c2d5c
.word 0x63cbd
.word 0x5ae8
.word 0xb29a
.word 0x26fd9
.word 0x759b3
.word 0x409f5
.word 0xf88b
.word 0x19041
.word 0x3e350
.word 0x4a4af
.word 0x7def6d
.word 0x784fd2
.word 0x79cd9a
.word 0x7bb0cc
.word 0x18fe8
.word 0x382a4
.word 0x4b2b7
.word 0x7cc42
.word 0x7e125
.word 0x7c0d49
.word 0x7f923b
.word 0x7802ef
.word 0x59d63
.word 0x7ccc57
.word 0x7b6548
.word 0x79e944
.word 0x78145a
.word 0x53880
.word 0x61767
.word 0x19e54
.word 0x3a388
.word 0x5c654
.word 0x78879b
.word 0x3a14d
.word 0x7d222d
.word 0x343ff
.word 0x7b6b1b
.word 0x7e3e19
.word 0x79fd7a
.word 0x12f12
.word 0x7eeffd
.word 0x26a0
.word 0x51e38
.word 0x12adb
.word 0x79435
.word 0x5ec1d
.word 0x65f2
.word 0x7e4945
.word 0x58e4
.word 0x3440c
.word 0x7d82
.word 0x7f9537
.word 0x46120
.word 0x481fd
.word 0x7dc35c
.word 0x76e03
.word 0x7e6d88
.word 0x783bbf
.word 0x55e47
.word 0x79782a
.word 0x79c56a
.word 0x7cc1eb
.word 0x7f4a32
.word 0x7e38a2
.word 0x382c4
.word 0x7c6bc8
.word 0x77f570
.word 0x7fd474
.word 0x79116e
.word 0x7bd9af
.word 0x7e4148
.word 0x5db13
.word 0x5ff07
.word 0x7dd23f
.word 0x1b940
.word 0x7f37ad
.word 0x78fbc3
.word 0x634af
.word 0x78432f
.word 0x200c6
.word 0x7a2f23
.word 0x25fe3
.word 0x25343
.word 0x4b2f9
.word 0x7d2cb3
.word 0x55274
.word 0x67c8c
.word 0x7d510e
.word 0x7f767d
.word 0x6dda1
.word 0x7c861e
.word 0x625e4
.word 0x7dbda2
.word 0x6df57
.word 0x7f550f
.word 0x7a25fd
.word 0x3e5cc
.word 0x7ebd82
.word 0x7b80d5
.word 0x7ad9e9
.word 0x683f
.word 0x77e916
.word 0x7e9c24
.word 0x7c6888
.word 0x300bf
.word 0x1b4e
.word 0x10189
.word 0x2c502
.word 0x7de992
.word 0x7f1487
.word 0xe799
.word 0x78690b
.word 0x1420d
.word 0x7e0c2d
.word 0x7b8950
.word 0x15982
.word 0x761d8
.word 0x49a1f
.word 0x8d67
.word 0x7c6215
.word 0x7b0485
.word 0x6813e
.word 0x79f0a6
.word 0x227d3
.word 0x7dfb2a
.word 0x7ba93
.word 0x7ef6fb
.word 0x7a2ca5
.word 0x77e180
.word 0x7867aa
.word 0x60c0b
.word 0x7eea77
.word 0x79812b
.word 0x7fa594
.word 0x54414
.word 0x783831
.word 0x7c29d6
.word 0x666f8
.word 0x797e
.word 0x78d8db
.word 0x7a06aa
.word 0x7d9039
.word 0x3053b
.word 0x69ad2
.word 0x702d0
.word 0x791f96
.word 0x7e5e0a
.word 0x78f77f
.word 0x78362d
.word 0x706c8
.word 0x10be8
.word 0x150f5
.word 0x14e77
.word 0x7c0630
.word 0x7a45c7
.word 0x7b08dc
.word 0x2393a
.word 0x7a281a
.word 0x795a61
.word 0x7d7763
.word 0x797810
.word 0x7a5ea6
.word 0x4928d
.word 0xd80d
.word 0x7cfab
.word 0x7ca0e7
.word 0x7bb78a
.word 0x790c3d
.word 0x31b91
.word 0x1fd1b
.word 0x53c52
.word 0x7bac0a
.word 0x7d8b21
.word 0x4f86a
.word 0x42047
.word 0x61f0c
.word 0x7aac34
.word 0x5fd69
.word 0x7e319e
.word 0x7bb537
.word 0x7aa64e
.word 0x792dfc
.word 0x7823f8
.word 0x7f1f0b
.word 0x38df5
.word 0x71064
.word 0x7a0bdf
.word 0x2b009
.word 0x7b0a2e
.word 0x216b8
.word 0x5bb87
.word 0x4a181
.word 0x7b14f1
.word 0x782414
.word 0x7ec760
.word 0x7d4481
.word 0x7c1dac
.word 0x78cbb0
.word 0x7c0bc3
.word 0x7902ac
.word 0x7dbc2e
.word 0x7d5f8a
.word 0x79d46
.word 0x7f51a1
.word 0x34a96
.word 0x1f830
.word 0x77f27f
.word 0x79493e
.word 0x262fb
.word 0x79b7f9
.word 0x7af3fb
.word 0x7f38be
.word 0x2bf43
.word 0x780302
.word 0x6217f
.word 0x5bc71
.word 0x65138
.word 0x653e8
.word 0x687c5
.word 0x7e466c
.word 0x7f95ab
.word 0x44041
.word 0x79ad88
.word 0x4ce94
.word 0x248dc
.word 0x5a140
.word 0x1a340
.word 0x237d7
.word 0x70398
.word 0x2888f
.word 0x59fe6
.word 0x59372
.word 0x7f1056
.word 0x107bf
.word 0x25215
.word 0x7c04f8
.word 0x31073
.word 0x2bb3f
.word 0x433f1
.word 0x7937b2
.word 0x7a6eb4
.word 0x237b9
.word 0x79ca9a
.word 0x7cf7d4
.word 0x6658b
.word 0x81ae
.word 0x7c80eb
.word 0x7e0094
.word 0x79a1f2
.word 0x78f55c
.word 0x1afac
.word 0x7eb130
.word 0x784610
.word 0x7cac2c
.word 0x7ce00a
.word 0x7813a4
.word 0x7a49dc
.word 0x7fd013
.word 0x7c3590
.word 0x26ac7
.word 0x7a05d1
.word 0x3353f
.word 0x3ad2d
.word 0x64128
.word 0x7e1dd3
.word 0x7a41a0
.word 0x7d0cc2
.word 0x71b7c
.word 0x79a7e9
.word 0x6dcc2
.word 0x61f21
.word 0x5c788
.word 0x7e640b
.word 0x7af121
.word 0x3bd33
.word 0x50082
.word 0x7d43b9
.word 0x3d981
.word 0x47d39
.word 0x26361
.word 0x45997
.word 0x7d0176
.word 0x7cdf32
.word 0x7aee16
.word 0x79ff09
.word 0x62b43
.word 0x227bd
.word 0x3a94a
.word 0x7ea4cf
.word 0x7ef6db
.word 0x7b93b5
.word 0x1c6d8
.word 0x618a3
.word 0x7d66a1
.word 0x430c7
.word 0x26cdc
.word 0x46fce
.word 0x7b5190
.word 0xf3be
.word 0x7aba6
.word 0x79e4c4
.word 0x7d3b0e
.word 0x46f86
.word 0x7f2426
.word 0x788145
.word 0x4da2a
.word 0x575f
.word 0x2db17
.word 0x210f9
.word 0x5bc6a
.word 0x6c5f3
.word 0x7cecac
.word 0x23cb9
.word 0x5fcc0
.word 0x7c7831
.word 0x7e3a14
.word 0x7f3868
.word 0x7b808f
.word 0x79edef
.word 0x1c0c9
.word 0x7db874
.word 0x7806cf
.word 0x684de
.word 0x507b4
.word 0x7b25de
.word 0x2dc72
.word 0x617f1
.word 0x3a7e1
.word 0x7cbebc
.word 0x7a600e
.word 0x7c20f2
.word 0x7c819c
.word 0x11922
.word 0x47f6e
.word 0x78c064
.word 0x7ceb01
.word 0x7ba2df
.word 0x75369
.word 0x6814c
.word 0x9702
.word 0x7b78a0
.word 0x40fbf
.word 0x9d36
.word 0x7f4bd2
.word 0x7eb402
.word 0x7854dd
.word 0x77f889
.word 0x7cea11
.word 0x7f2271
.word 0x3cbbc
.word 0x52728
.word 0x1c90a
.word 0x7e31a7
.word 0x1a59d
.word 0x7b4a6c
.word 0x7bb2ec
.word 0x7c3b79
.word 0x7c3beb
.word 0x7cebf6
.word 0x69f41
.word 0x785e9
.word 0x7c7850
.word 0x79ff
.word 0x7db6a4
.word 0x7c96bc
.word 0x7f8f9d
.word 0x57853
.word 0x3a205
.word 0x7d560a
.word 0x783298
.word 0x2800d
.word 0x67226
.word 0x4ff69
.word 0x2b15c
.word 0x3eb96
.word 0x54798
.word 0x149de
.word 0x24ee1
.word 0x43f29
.word 0x7def4c
.word 0x7e5034
.word 0x75721
.word 0x7bb499
.word 0x7d0cd6
.word 0x7f4847
.word 0x7ca850
.word 0x780e0
.word 0x2d1ca
.word 0x796817
.word 0x3e581
.word 0x7c637b
.word 0x7ad7b1
.word 0x606a4
.word 0x7e1d10
.word 0x7e6387
.word 0x16d62
.word 0x4f4b0
.word 0x7ab6f9
.word 0x3e981
.word 0x7a1bf9
.word 0xb093
.word 0x39c3c
.word 0x7838b
.word 0x7f6da5
.word 0x23201
.word 0x7d2f0d
.word 0x13c10
.word 0x24d0d
.word 0x27d02
.word 0x7b6204
.word 0x7bebae
.word 0x7d3533
.word 0x31014
.word 0x7c48ec
.word 0x7f7ff0
.word 0x5e0ad
.word 0x4a51a
.word 0x26775
.word 0x1a6dd
.word 0x56932
.word 0x1ab8d
.word 0x66232
.word 0x792089
.word 0x784861
.word 0x7d341a
.word 0x7df12c
.word 0x7bc047
.word 0x2c609
.word 0x7a4b19
.word 0x7abcc3
.word 0x218ff
.word 0x7c4d81
.word 0x7b944e
.word 0x7e445d
.word 0x6383a
.word 0x1ba4b
.word 0x5ba38
.word 0x7a1fd4
.word 0x7bef03
.word 0x35ee2
.word 0x7fd470
.word 0x7c775f
.word 0x7c2d5e
.word 0x7a0231
.word 0x46dd0
.word 0x7d83d8
.word 0x7ac849
.word 0x7c6b3d
.word 0x7b9694
.word 0xf2f4
.word 0x7ab07
.word 0x7d74c4
.word 0x4afac
.word 0x7e930f
.word 0x7e4700
.word 0x3e8
.word 0x38853
.word 0x7d24c0
.word 0x7f75a2
.word 0x7bf4de
.word 0x3f8d9
.word 0x3a912
.word 0x6ca7
.word 0x39c3e
.word 0x79a42f
.word 0x7c3a7d
.word 0x7dac2e
.word 0x7b23cb
.word 0x7f15aa
.word 0x58d76
.word 0x48fee
.word 0x79c451
.word 0x7d646e
.word 0x7daf20
.word 0x524c
.word 0xc8a2
.word 0x683c
.word 0x79fd4f
.word 0x62458
.word 0x497e0
.word 0x7e7c0b
.word 0xdf65
.word 0x7d2742
.word 0x2081
.word 0x7b62b
.word 0x5abb2
.word 0x7fb608
.word 0x55e20
.word 0x7e72c6
.word 0x16ff9
.word 0x7968e5
.word 0x5738
.word 0xd64a
.word 0x7d47a1
.word 0x7e7760
.word 0x7f3292
.word 0x699b4
.word 0x7c528e
.word 0x7fd29d
.word 0x7a8122
.word 0x27a19
.word 0x51a27
.word 0x7df195
.word 0x7d1766
.word 0x796307
.word 0x7f28a
.word 0x7a32ee
.word 0x7a5920
.word 0x7d46b3
.word 0x233bb
.word 0x7b5617
.word 0x3c3a0
.word 0x79070
.word 0x7a3b97
.word 0x7a1dc6
.word 0x96eb
.word 0x18b34
.word 0x628d7
.word 0x7f7d30
.word 0x7e829e
.word 0x4aa0c
.word 0x7baf3f
.word 0x7e1641
.word 0x81d
.word 0x79272f
.word 0x14e2b
.word 0x7e34b8
.word 0x469e2
.word 0x797e4c
.word 0x40fc3
.word 0x42d
.word 0x7d2c24
.word 0x7a20a2
.word 0x7c0111
.word 0x7dfc0a
.word 0x2a382
.word 0x7f6e01
.word 0x4691f
.word 0x7a7aec
.word 0x3ffaa
.word 0x7bed6
.word 0x7ba18d
.word 0x4d668
.word 0x7bb2f0
.word 0x750a1
.word 0x786f91
.word 0x7da256
.word 0x6859b
.word 0x7d0448
.word 0x7c206b
.word 0x115af
.word 0x13907
.word 0x7fba55
.word 0x7f5a48
.word 0x119c0
.word 0x7d276f
.word 0x768c1
.word 0x6178b
.word 0x4a202
.word 0x7e01e9
.word 0x7f8d75
.word 0x788acb
.word 0x310d6
.word 0x7d32de
.word 0x74b68
.word 0x6e2af
.word 0xb4da
.word 0x7ae6ec
.word 0x7cd679
.word 0x79ca9c
.word 0x7be252
.word 0x7b7868
.word 0x7e2210
.word 0x7b9ebd
.word 0x6654a
.word 0xb464
.word 0x7df00d
.word 0x7e3214
.word 0x7b7c0f
.word 0x7e44bd
.word 0x7f9e24
.word 0x7baa2f
.word 0x142d7
.word 0x7e8b9d
.word 0x23218
.word 0x78e2e0
.word 0x7c4d3a
.word 0x7d5760
.word 0x7d8f5
.word 0x7b0ea
.word 0x7ba672
.word 0x4842c
.word 0x3c0b0
.word 0x7815b8
.word 0x7ae65c
.word 0x5264c
.word 0x77e112
.word 0x7dd0f9
.word 0x7f9439
.word 0x3a82
.word 0x3be66
.word 0x7ee7c3
.word 0x3bddd
.word 0x7ab071
.word 0x65701
.word 0x359eb
.word 0x7acd38
.word 0x7e763f
.word 0x7b3b04
.word 0x42693
.word 0x7e6219
.word 0x625
.word 0x6b217
.word 0x7fd8f1
.word 0x7f6db5
.word 0x1e451
.word 0x78fc9f
.word 0x11017
.word 0x58e56
.word 0x53e12
.word 0x6b2fb
.word 0x7c8af0
.word 0x78df47
.word 0x58712
.word 0x799f1f
.word 0x77fc80
.word 0x72487
.word 0x4ed7a
.word 0x7be377
.word 0x7df815
.word 0x44f6f
.word 0x7b4f98
.word 0x2023f
.word 0x7fbf9a
.word 0x7f1f26
.word 0x7aa196
.word 0x4517
.word 0x791040
.word 0x7f2ea
.word 0x7c5a17
.word 0x453fb
.word 0x7909d
.word 0x45a22
.word 0x7aa58c
.word 0x17d70
.word 0x7f6207
.word 0x11898
.word 0x7babf4
.word 0x733d6
.word 0xa8fe
.word 0x4fefe
.word 0x29e4d
.word 0x7a5aaa
.word 0x41de2
.word 0x787eb6
.word 0x7b3bda
.word 0x32c29
.word 0x77af2
.word 0x353de
.word 0x781313
.word 0x1b490
.word 0x7f78fa
.word 0x2e1ac
.word 0x7a49a8
.word 0x7b1907
.word 0x6e93b
.word 0x79d0d3
.word 0x7a01ff
.word 0x53eb5
.word 0xef1f
.word 0x7edf74
.word 0x1f57d
.word 0x75faa
.word 0x7c3e4
.word 0x7d3f49
.word 0x79236
.word 0x7c2154
.word 0x7b65d2
.word 0x554ac
.word 0x627e7
.word 0x7c7e11
.word 0xff12
.word 0x7bb2b1
.word 0x5e88c
.word 0x32f10
.word 0x7d0058
.word 0x78961c
.word 0x20eac
.word 0x7dd0cc
.word 0x7f7fe
.word 0x23831
.word 0x7d8598
.word 0x7abd25
.word 0x7837aa
.word 0x7ac5a0
.word 0x7d0e98
.word 0x7d2a76
.word 0x17e18
.word 0x43367
.word 0x7fd818
.word 0x178f2
.word 0x7b128c
.word 0x33bf1
.word 0x79fd87
.word 0x7c5656
.word 0x7daa70
.word 0x7d7802
.word 0x4c167
.word 0x797339
.word 0x67f
.word 0x3132
.word 0x25b2a
.word 0x7b1a3d
.word 0x23fd5
.word 0x4ca38
.word 0x7fde6f
.word 0x4e489
.word 0x788a3c
.word 0x31168
.word 0x3dde3
.word 0x57efc
.word 0x797318
.word 0x45793
.word 0x7c066e
.word 0x7e3a66
.word 0x16505
.word 0x79d450
.word 0x490ac
.word 0x77ead7
.word 0x7ee2c7
.word 0x437ec
.word 0x7b6605
.word 0x4c896
.word 0x535ab
.word 0x7d124d
.word 0x7b3525
.word 0x7bdc98
.word 0x128ff
.word 0x7a4d07
.word 0x7e4aac
.word 0x7894d6
.word 0x7c3ff6
.word 0x7c12cf
.word 0x8682
.word 0x7d68a1
.word 0x25967
.word 0x7c25ef
.word 0x7d3d2
.word 0x786417
.word 0x7d5271
.word 0x46ec
.word 0x7b4e74
.word 0x54217
.word 0x7f52bf
.word 0x1314a
.word 0x6f407
.word 0x71ad9
.word 0x7ed8df
.word 0x2eea2
.word 0x5c918
.word 0x5f35e
.word 0x798819
.word 0x7f20f7
.word 0x5d3d8
.word 0x6ea66
.word 0x7e24f3
.word 0x78e867
.word 0x22a1f
.word 0x7b06cd
.word 0x72405
.word 0x7a72d7
.word 0x793ab8
.word 0x798caf
.word 0x7af5f2
.word 0x7f1442
.word 0x7a2ad5
.word 0x7f2a1c
.word 0x26969
.word 0x7eb98f
.word 0x7829b5
.word 0x7879f1
.word 0x1d7b4
.word 0x4ed
.word 0x7aa36f
.word 0x46595
.word 0x78c197
.word 0x78f0ff
.word 0x20cf7
.word 0x7aa0f0
.word 0x68bc6
.word 0x7ebc8b
.word 0x1ae0e
.word 0x7d6dff
.word 0x7928a5
.word 0x795ad9
.word 0x5a6c5
.word 0x1f793
.word 0x428f2
.word 0x58eba
.word 0x7a53ae
.word 0x5a20
.word 0x7e1b8b
.word 0x6bafb
.word 0x7958e2
.word 0x2dd1d
.word 0x787414
.word 0x30f26
.word 0x792224
.word 0x7d06b8
.word 0x7ef676
.word 0x795e86
.word 0x7b68b6
.word 0x7b2fd2
.word 0x1127
.word 0x139c
.word 0x7973a1
.word 0x7dcd45
.word 0x7fddd8
.word 0x7ac58f
.word 0x50275
.word 0x52ed4
.word 0x7ce1ca
.word 0x41160
.word 0x7e0131
.word 0x7d808
.word 0x3441c
.word 0x7d2218
.word 0x7f83cb
.word 0x228aa
.word 0x7d8b81
.word 0x5b1e4
.word 0x7ca304
.word 0x7ce009
.word 0x7c324e
.word 0x5be9c
.word 0x4cb1e
.word 0x792c5d
.word 0x7b8dab
.word 0x794cd9
.word 0x78d27d
.word 0x49bc
.word 0x2d7c7
.word 0x12eaa
.word 0x79f36e
.word 0x3161d
.word 0x6b89c
.word 0x37f7b
.word 0x1eba4
.word 0x5161e
.word 0x7b61ab
.word 0xadc8
.word 0x7fc4ad
.word 0x7f90f5
.word 0x79bcdb
.word 0x7a0f62
.word 0x4dd2
.word 0x791f6f
.word 0x7a01ee
.word 0x7821f3
.word 0x7b18ae
.word 0x7f5f42
.word 0x7f99ea
.word 0x4a70f
.word 0x4b20a
.word 0x7bb438
.word 0xf796
.word 0x7a10f8
.word 0x57346
.word 0x3ad6a
.word 0x4a0e3
.word 0x12755
.word 0x54ee6
.word 0x4919a
.word 0x78120c
.word 0x61de7
.word 0x7a71cb
.word 0x7fa5a2
.word 0x7a5b64
.word 0x7d7ced
.word 0x798ae6
.word 0x5a795
.word 0x7f0e7b
.word 0x7cf671
.word 0x78bb2d
.word 0x8d63
.word 0x77e140
.word 0x7f1f58
.word 0x30149
.word 0x7e95a
.word 0x68f24
.word 0x53b31
.word 0x7fc392
.word 0x79e2cc
.word 0x204ae
.word 0x7a23f5
.word 0xb11d
.word 0x6f602
.word 0x7dd578
.word 0x264d9
.word 0x7c7641
.word 0x152fc
.word 0x61fa5
.word 0x7940a4
.word 0x7ef1f1
.word 0x7ee606
.word 0x6100d
.word 0x7220
.word 0x24007
.word 0xd211
.word 0x53755
.word 0x7e5fd0
.word 0x7abae8
.word 0x6597f
.word 0x57e69
.word 0x5c899
.word 0x79ff63
.word 0x5f0b4
.word 0x7d77d0
.word 0x7a96db
.word 0x2702e
.word 0x276b8
.word 0xf9ea
.word 0x15b22
.word 0x7f43da
.word 0x7ef9ff
.word 0x7e223f
.word 0x7c38c0
.word 0x7900be
.word 0x7eee06
.word 0x1bfe
.word 0x78a4fe
.word 0x62a6
.word 0x79ff22
.word 0x16fd3
.word 0x7cd8a9
.word 0x687c1
.word 0x7413e
.word 0x7de165
.word 0x78ce8
.word 0x10722
.word 0x11971
.word 0xf0cc
.word 0x7a5ba
.word 0x35208
.word 0x7d3aa
.word 0x267da
.word 0x42bae
.word 0x2431d
.word 0x3a3e0
.word 0x7a386
.word 0x6c778
.word 0x7fdba
.word 0x7a09e6
.word 0x7af4a
.word 0x7ce7fc
.word 0x791e2d
.word 0x35745
.word 0x78fef8
.word 0x209a
.word 0x7b4685
.word 0x7d0e56
.word 0x7a48a9
.word 0x1cc15
.word 0x340a1
.word 0x7b0ff
.word 0x21193
.word 0x5bb01
.word 0x2ff39
.word 0x6488d
.word 0x7e5b6c
.word 0x7b2a36
.word 0x7b1a35
.word 0x4971f
.word 0x9476
.word 0x57049
.word 0x7fc8c3
.word 0x7973b7
.word 0x7b6c39
.word 0x138fb
.word 0x7d640c
.word 0x79d542
.word 0x67a31
.word 0x6dd3a
.word 0x7c746e
.word 0x52160
.word 0x7cbea1
.word 0x7cf8bc
.word 0x7964e1
.word 0x7855be
.word 0x30547
.word 0x7df310
.word 0x57ddf
.word 0x2420b
.word 0x4d44f
.word 0x7f335b
.word 0x7f0ec7
.word 0x62d99
.word 0x265fb
.word 0x7e52a1
.word 0x1538b
.word 0x10434
.word 0x7b6478
.word 0x2bd3e
.word 0x7e9d2c
.word 0x7e187f
.word 0x7cffd1
.word 0x7e9e1f
.word 0x478fe
.word 0x7cbc1a
.word 0x77f5b5
.word 0x7a6ed3
.word 0x15690
.word 0x501df
.word 0xcc40
.word 0x7f8d04
.word 0x24c6f
.word 0x782ae7
.word 0x55b65
.word 0x3cee5
.word 0x62f0a
.word 0x3134b
.word 0x7dd7ee
.word 0x7c746c
.word 0x79a255
.word 0x789fac
.word 0x7cb10d
.word 0x7839f1
.word 0x7e4710
.word 0x7f5731
.word 0x7aa33f
.word 0x7c8d2c
.word 0x7be844
.word 0x45c1d
.word 0x7c90fe
.word 0x49433
.word 0x7d4e49
.word 0x1e254
.word 0x7e8157
.word 0x7fdc52
.word 0x78b7c9
.word 0x2dbd9
.word 0x7a0ba7
.word 0x393a3
.word 0x7a13e4
.word 0x21dce
.word 0x37510
.word 0x3f00a
.word 0x77fd67
.word 0x7cd3b
.word 0x12a8c
.word 0x3ea63
.word 0x7c3b1f
.word 0x7a87c5
.word 0x6617a
.word 0x31797
.word 0x78ae59
.word 0x450b
.word 0x7e8c93
.word 0x2b7b2
.word 0x7c6781
.word 0x30822
.word 0x7c1d71
.word 0x78065c
.word 0x75e1a
.word 0x7dcd1b
.word 0x7b7880
.word 0x7a10b3
.word 0x79df78
.word 0x7af561
.word 0x40589
.word 0x7d24bf
.word 0x489c9
.word 0x78de7
.word 0x3c802
.word 0x798afc
.word 0x7e05fe
.word 0x16fee
.word 0x57b6f
.word 0x40b16
.word 0x78bdf5
.word 0x7e71ed
.word 0x79b81e
.word 0x4d142
.word 0x55a08
.word 0x7f0e6e
.word 0x78e1d1
.word 0x44b07
.word 0x7d54a0
.word 0x7c8fe5

expand_a_temp:
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000

.globl t1_coef_0_0
t1_coef_0_0:
.word 0xba
.word 0x214
.word 0x21f
.word 0x2a4
.word 0x2bb
.word 0x15
.word 0x152
.word 0x33f
.word 0x160
.word 0xe1
.word 0x270
.word 0x92
.word 0x2f
.word 0x3a9
.word 0x2d5
.word 0x3aa
.word 0x302
.word 0x283
.word 0x2f
.word 0x37b
.word 0x1a1
.word 0x1fa
.word 0x91
.word 0xdf
.word 0x2b2
.word 0xb3
.word 0x32f
.word 0x23f
.word 0x10f
.word 0x274
.word 0x19
.word 0x1a5
.word 0x330
.word 0xa5
.word 0x4e
.word 0x277
.word 0x2d5
.word 0x55
.word 0x247
.word 0x4a
.word 0x8f
.word 0x3a4
.word 0x25
.word 0x9a
.word 0x397
.word 0x240
.word 0x4d
.word 0xbe
.word 0x89
.word 0x28e
.word 0xa5
.word 0xa8
.word 0xc
.word 0x1b
.word 0x28f
.word 0x3e2
.word 0x144
.word 0x373
.word 0x2a4
.word 0x153
.word 0x28b
.word 0x134
.word 0x74
.word 0x196
.word 0x80
.word 0x1dc
.word 0x61
.word 0x291
.word 0x28d
.word 0x2c0
.word 0xcd
.word 0x334
.word 0x240
.word 0x87
.word 0x250
.word 0xd1
.word 0x3a0
.word 0x2
.word 0x227
.word 0x215
.word 0x3be
.word 0xc2
.word 0xb0
.word 0x2b
.word 0x346
.word 0x301
.word 0x1e6
.word 0x2b6
.word 0x117
.word 0x3a3
.word 0x3c5
.word 0x23d
.word 0xc7
.word 0x1fa
.word 0x10
.word 0x16e
.word 0x3fe
.word 0x2ab
.word 0x252
.word 0x1da
.word 0x24
.word 0x306
.word 0x2c7
.word 0x3a5
.word 0x10b
.word 0x1da
.word 0x376
.word 0xd2
.word 0x27d
.word 0x3fa
.word 0xe9
.word 0x275
.word 0x391
.word 0xb1
.word 0x106
.word 0x76
.word 0x5c
.word 0x35c
.word 0x298
.word 0x277
.word 0xbc
.word 0x32c
.word 0x3af
.word 0x131
.word 0x35b
.word 0x3d5
.word 0x14f
.word 0x2c8
.word 0x7a
.word 0x353
.word 0x2a6
.word 0xb4
.word 0x2bc
.word 0x3e2
.word 0x4d
.word 0x1de
.word 0x296
.word 0xaf
.word 0x3af
.word 0x30f
.word 0x201
.word 0x7f
.word 0x2af
.word 0x63
.word 0x129
.word 0x2f2
.word 0x77
.word 0x192
.word 0x35e
.word 0xea
.word 0xed
.word 0x30b
.word 0x35c
.word 0x81
.word 0x121
.word 0x218
.word 0xf5
.word 0x1fa
.word 0x15b
.word 0x33f
.word 0x169
.word 0x191
.word 0x3c1
.word 0x240
.word 0x342
.word 0xd4
.word 0x2f3
.word 0x47
.word 0x289
.word 0x208
.word 0x1ff
.word 0x87
.word 0x319
.word 0x14d
.word 0xb4
.word 0x1a0
.word 0x173
.word 0x339
.word 0xaa
.word 0x1bf
.word 0x204
.word 0x367
.word 0xd2
.word 0x23c
.word 0xb3
.word 0x19f
.word 0x356
.word 0x88
.word 0x24b
.word 0x129
.word 0x21
.word 0x171
.word 0x2f
.word 0x123
.word 0x2c4
.word 0x343
.word 0x39
.word 0x3a1
.word 0x254
.word 0x75
.word 0x213
.word 0x376
.word 0x1f3
.word 0xce
.word 0x31a
.word 0x3aa
.word 0x24e
.word 0x34e
.word 0x198
.word 0x4f
.word 0xcb
.word 0x27f
.word 0x2cb
.word 0x28c
.word 0x2c4
.word 0x380
.word 0x122
.word 0x275
.word 0x3c9
.word 0x24
.word 0x3cd
.word 0x3d8
.word 0x82
.word 0x29b
.word 0x3e7
.word 0x143
.word 0x3ef
.word 0x1f9
.word 0x3e
.word 0x39c
.word 0x1af
.word 0x4b
.word 0x38c
.word 0x12
.word 0x352
.word 0x42
.word 0x26f
.word 0x1c8
.word 0x2ce
.word 0x1b0
.word 0x215
.word 0x326
.word 0x39a
.word 0x26a
.word 0x398
.word 0x1db
.word 0x164
.word 0xc1
.word 0x32a
.word 0x27c
.word 0xe1
.word 0xb8
.word 0x3af
.word 0x122
.word 0x1e
.word 0x2ac
.word 0x366
.word 0xc9
.word 0xad
.word 0x37c
.word 0x1a8
.word 0x3d2
.word 0x2fe
.word 0x17a
.word 0x2c4
.word 0xe2
.word 0x268
.word 0x263
.word 0x84
.word 0x117
.word 0x234
.word 0x275
.word 0x47
.word 0x3d2
.word 0x36
.word 0x3d2
.word 0xf1
.word 0x2b9
.word 0x3b1
.word 0x234
.word 0x3df
.word 0x2e0
.word 0x236
.word 0x28c
.word 0x8b
.word 0x308
.word 0x10b
.word 0x39b
.word 0x116
.word 0x264
.word 0x141
.word 0x344
.word 0x2d7
.word 0x13c
.word 0x274
.word 0x256
.word 0x55
.word 0x1e0
.word 0x2a1
.word 0xe3
.word 0x13d
.word 0x25f
.word 0x1c8
.word 0xcf
.word 0x13a
.word 0x39d
.word 0xc9
.word 0x3b
.word 0x232
.word 0x92
.word 0x245
.word 0x379
.word 0xc2
.word 0x1f2
.word 0x2e1
.word 0x13e
.word 0x1ad
.word 0x19c
.word 0x15e
.word 0x69
.word 0x147
.word 0x2c0
.word 0x13
.word 0x369
.word 0x3e9
.word 0x9e
.word 0x377
.word 0x3cf
.word 0x211
.word 0x1df
.word 0x3c
.word 0x29b
.word 0x30f
.word 0x3b8
.word 0x262
.word 0x1b3
.word 0x3ba
.word 0x1ff
.word 0x357
.word 0x23
.word 0x50
.word 0xa8
.word 0x285
.word 0x1a0
.word 0x11d
.word 0x11c
.word 0x179
.word 0x62
.word 0x18b
.word 0xf8
.word 0x1d0
.word 0x93
.word 0xf3
.word 0x2f9
.word 0x20f
.word 0x118
.word 0x242
.word 0xf6
.word 0x15f
.word 0x100
.word 0x1f
.word 0x154
.word 0x108
.word 0xfa
.word 0x2d5
.word 0x110
.word 0x3e9
.word 0x2f
.word 0x113
.word 0xab
.word 0x74
.word 0x9b
.word 0x322
.word 0x3d
.word 0xf
.word 0x14
.word 0x174
.word 0x355
.word 0x1d1
.word 0x122
.word 0x24a
.word 0x3b2
.word 0x1d0
.word 0x34
.word 0x32b
.word 0x98
.word 0x166
.word 0x3be
.word 0x1c
.word 0x2d3
.word 0x37a
.word 0x13c
.word 0x33a
.word 0x1f7
.word 0xfb
.word 0x1ad
.word 0x267
.word 0x24d
.word 0x12d
.word 0x247
.word 0x2c3
.word 0x1a0
.word 0x3b6
.word 0x16b
.word 0x325
.word 0x399
.word 0x1ff
.word 0x18d
.word 0x322
.word 0x149
.word 0x82
.word 0x3b1
.word 0x2a0
.word 0x1f2
.word 0x383
.word 0x252
.word 0x193
.word 0xc9
.word 0x381
.word 0x2dc
.word 0x6
.word 0xe7
.word 0x178
.word 0x134
.word 0x1dc
.word 0x10b
.word 0x12d
.word 0x376
.word 0x9c
.word 0x19a
.word 0x1c6
.word 0x89
.word 0x24e
.word 0x32b
.word 0x325
.word 0x1e0
.word 0x1f6
.word 0xde
.word 0x4c
.word 0x3f7
.word 0xb3
.word 0xf3
.word 0x288
.word 0x2c
.word 0x375
.word 0x287
.word 0x7f
.word 0x1e7
.word 0x1a3
.word 0x35
.word 0x2ee
.word 0x362
.word 0x3ac
.word 0x133
.word 0xda
.word 0x342
.word 0x2d2
.word 0x278
.word 0x17c
.word 0x295
.word 0x20c
.word 0x266
.word 0x28
.word 0x2f9
.word 0x246
.word 0x258
.word 0x2c8
.word 0x2f2
.word 0x282
.word 0x349
.word 0x264
.word 0x1bd
.word 0x30e
.word 0x2ea
.word 0x39d
.word 0x3f0
.word 0x2e4
.word 0x287
.word 0x3c8
.word 0x23a
.word 0x2a5
.word 0x314
.word 0x368
.word 0x3fc
.word 0x377
.word 0x1b7
.word 0x1be
.word 0x15c
.word 0x24d
.word 0x27c
.word 0xf3
.word 0x16b
.word 0x27e
.word 0x1d0
.word 0x28a
.word 0x340
.word 0x7
.word 0x3a9
.word 0x29d
.word 0x2af
.word 0x225
.word 0xdf
.word 0x3de
.word 0x397
.word 0x359
.word 0x84
.word 0x162
.word 0x3a0
.word 0x212
.word 0x7f
.word 0x4b
.word 0x1a
.word 0x18c
.word 0x2c1
.word 0x337
.word 0x3d5
.word 0x397
.word 0x195
.word 0x299
.word 0x33e
.word 0x319
.word 0x2bc
.word 0x3e6
.word 0xd4
.word 0x25
.word 0x2fa
.word 0xf8
.word 0x314
.word 0xbb
.word 0x388
.word 0x75
.word 0x2c7
.word 0x3ce
.word 0x158
.word 0x42
.word 0xfb
.word 0x4e
.word 0x369
.word 0x167
.word 0x2d1
.word 0x234
.word 0x3f4
.word 0x32b
.word 0x76
.word 0x3e5
.word 0x28f
.word 0x35f
.word 0x3d1
.word 0x144
.word 0x91
.word 0x16e
.word 0x284
.word 0x73
.word 0x1ca
.word 0x337
.word 0x4e
.word 0x226
.word 0x12a
.word 0x18c
.word 0x340
.word 0x11e
.word 0x277
.word 0x105
.word 0x169
.word 0x12e
.word 0x35a
.word 0x336
.word 0x378
.word 0x254
.word 0x37
.word 0x22b
.word 0x2d2
.word 0x277
.word 0x30
.word 0xae
.word 0x44
.word 0x1bf
.word 0x3ee
.word 0x3ea
.word 0x30f
.word 0x33a
.word 0x175
.word 0x3c9
.word 0x1aa
.word 0x2e5
.word 0x126
.word 0x191
.word 0x175
.word 0x115
.word 0x143
.word 0x1f3
.word 0x66
.word 0x35b
.word 0x19a
.word 0x294
.word 0x65
.word 0x241
.word 0x1b0
.word 0x33d
.word 0x1dd
.word 0xb1
.word 0x14b
.word 0x1
.word 0x28d
.word 0x24
.word 0x103
.word 0x1c6
.word 0x28f
.word 0x6d
.word 0x194
.word 0x203
.word 0x1dd
.word 0x1cd
.word 0x2bb
.word 0x1e2
.word 0x2d9
.word 0x2c0
.word 0x265
.word 0x3ef
.word 0x365
.word 0x35d
.word 0x178
.word 0x11b
.word 0x2f4
.word 0x1b2
.word 0x26
.word 0x38a
.word 0x32a
.word 0x2dc
.word 0x3d2
.word 0x48
.word 0x341
.word 0x3ed
.word 0x370
.word 0x337
.word 0x1c8
.word 0x277
.word 0x1d8
.word 0x91
.word 0x13c
.word 0x31f
.word 0x37
.word 0x237
.word 0x91
.word 0x9
.word 0x2bb
.word 0xf3
.word 0x21b
.word 0x394
.word 0x132
.word 0x1c1
.word 0x169
.word 0x296
.word 0x27d
.word 0x270
.word 0x4
.word 0x383
.word 0x273
.word 0x3db
.word 0x340
.word 0x1af
.word 0x1a1
.word 0x359
.word 0x17c
.word 0x12d
.word 0x358
.word 0x29e
.word 0xbd
.word 0x1ec
.word 0x37c
.word 0x1b8
.word 0x198
.word 0x63
.word 0x20b
.word 0x13f
.word 0x2a2
.word 0x108
.word 0x164
.word 0x308
.word 0x1de
.word 0x2e9
.word 0x1e1
.word 0x3f7
.word 0x18d
.word 0x2b0
.word 0x2cd
.word 0x1e9
.word 0x2cf
.word 0x19f
.word 0x29a
.word 0x2b9
.word 0x3d7
.word 0x68
.word 0x2dc
.word 0x393
.word 0x12b
.word 0x2b9
.word 0x2fb
.word 0x179
.word 0x14
.word 0x7c
.word 0x3f8
.word 0x172
.word 0x2d
.word 0x3bc
.word 0x44
.word 0x129
.word 0x32
.word 0x353
.word 0x309
.word 0x1e0
.word 0x2e8
.word 0x51
.word 0x1e9
.word 0x29
.word 0x1d5
.word 0x4d
.word 0x1f9
.word 0x389
.word 0x167
.word 0xfa
.word 0x230
.word 0x3b0
.word 0x317
.word 0x2b0
.word 0x229
.word 0x88
.word 0x111
.word 0xe7
.word 0x81
.word 0x1ea
.word 0x1a6
.word 0x247
.word 0x3c1
.word 0x13d
.word 0x32f
.word 0x2
.word 0x6b
.word 0x9d
.word 0x33e
.word 0x3d4
.word 0x2d9
.word 0x36a
.word 0x135
.word 0x1c8
.word 0x141
.word 0x3cb
.word 0x1dc
.word 0x2e1
.word 0x1d7
.word 0x189
.word 0xaf
.word 0x3fb
.word 0xe3
.word 0x150
.word 0x105
.word 0x33c
.word 0x229
.word 0x1bc
.word 0x149
.word 0x388
.word 0x1fe
.word 0xdc
.word 0x3bb
.word 0x1e0
.word 0x130
.word 0x295
.word 0x2e
.word 0x3b3
.word 0xb0
.word 0x76
.word 0x19
.word 0x2aa
.word 0x6a
.word 0x3ac
.word 0x234
.word 0x2
.word 0x3cf
.word 0x81
.word 0x3bd
.word 0x1fd
.word 0x177
.word 0x2c2
.word 0x154
.word 0x109
.word 0x28e
.word 0x35b
.word 0xc9
.word 0x29a
.word 0x8c
.word 0xcb
.word 0x76
.word 0x3df
.word 0x130
.word 0x1b2
.word 0x1c8
.word 0x322
.word 0x2ad
.word 0xb0
.word 0xd
.word 0x6c
.word 0x1c9
.word 0x119
.word 0x354
.word 0x19f
.word 0x2e
.word 0x3e6
.word 0x3d4
.word 0x2e4
.word 0x21b
.word 0x35f
.word 0x2df
.word 0x13d
.word 0x57
.word 0xa4
.word 0x32e
.word 0x35c
.word 0x8c
.word 0x248
.word 0x35f
.word 0x3f1
.word 0x49
.word 0x1de
.word 0x21
.word 0x177
.word 0x244
.word 0x18b
.word 0x3a8
.word 0x3f2
.word 0x2a4
.word 0x85
.word 0x76
.word 0x1d3
.word 0x128
.word 0x2fe
.word 0x272
.word 0xea
.word 0x372
.word 0x2ab
.word 0x261
.word 0x3c9
.word 0x1d5
.word 0x8a
.word 0x2fa
.word 0x163
.word 0x3a0
.word 0x2
.word 0x8c
.word 0x335
.word 0x351
.word 0x3a6
.word 0x3b8
.word 0x8d
.word 0x22e
.word 0x79
.word 0x1b2
.word 0x2b6
.word 0x314
.word 0x33d
.word 0x80
.word 0x180
.word 0x356
.word 0x218
.word 0x28f
.word 0x3cb
.word 0xee
.word 0x26b
.word 0x15f
.word 0xce
.word 0x223
.word 0x1e8
.word 0x300
.word 0x388
.word 0x3f0
.word 0x37e
.word 0x121
.word 0x1a6
.word 0x282
.word 0xbf
.word 0x2b6
.word 0x3ca
.word 0x16f
.word 0x21d
.word 0x27b
.word 0x200
.word 0x67
.word 0x233
.word 0x346
.word 0x3f9
.word 0x347
.word 0x27a
.word 0x2fc
.word 0x1e0
.word 0x3ce
.word 0x131
.word 0x24d
.word 0xcc
.word 0x9d
.word 0x3f5
.word 0x226
.word 0x390
.word 0xea
.word 0x32e
.word 0x17
.word 0x320
.word 0xe5
.word 0x1ae
.word 0x35d
.word 0x1da
.word 0x177
.word 0xb4
.word 0x221
.word 0x145
.word 0x1bb
.word 0x193
.word 0x312
.word 0x107
.word 0x294
.word 0x38e
.word 0xae
.word 0x41
.word 0x1a3
.word 0x274
.word 0x2fd
.word 0x286
.word 0xfe
.word 0x182
.word 0x333
.word 0x359
.word 0x28c
.word 0x3da
.word 0x33c
.word 0x269
.word 0x16e
.word 0x3ac
.word 0x1e4
.word 0x3bd
.word 0x378
.word 0x272
.word 0x19c
.word 0x344
.word 0xff
.word 0x11
.word 0x3ef
.word 0xac
.word 0x16
.word 0x3cf
.word 0x1b5
.word 0x27f
.word 0xd7
.word 0xc7
.word 0x35a
.word 0x2dc
.word 0x4a
.word 0x119
.word 0x21
.word 0x187
.word 0x35d
.word 0x378
.word 0x7b
.word 0x10c
.word 0x159
.word 0x170
.word 0xc9
.word 0x3b6
.word 0x34b
.word 0x245
.word 0x3fe
.word 0x3f5
.word 0x167
.word 0xb8
.word 0x2f2
.word 0x130
.word 0x3cd
.word 0x308
.word 0x170
.word 0x36c
.word 0x1ee
.word 0x86
.word 0x39e
.word 0x189
.word 0x24d
.word 0x1ff
.word 0x18c
.word 0x39c
.word 0x2c0
.word 0x29d
.word 0x55
.word 0x45
.word 0x1b9
.word 0x14d
.word 0x51
.word 0x162
.word 0xf
.word 0x299
.word 0x1e8
.word 0x3b9
.word 0x12e
.word 0x3e9
.word 0x113
.word 0x2cf
.word 0xc4
.word 0x2a7
.word 0x37e
.word 0x80
.word 0x11d
.word 0x352
.word 0x305
.word 0x1db
.word 0x381
.word 0x69
.word 0x150
.word 0xb6
.word 0x3fb
.word 0x66
.word 0x2bf
.word 0xcb
.word 0x51
.word 0x27d
.word 0x11
.word 0x57
.word 0x2ef
.word 0x261
.word 0x5d
.word 0x30c
.word 0x179
.word 0xca
.word 0x2b3
.word 0x1cd
.word 0xdb
.word 0x2cf
.word 0x3da
.word 0x38d
.word 0xf7
.word 0x2e6
.word 0x3bb
.word 0x165
.word 0x30a
.word 0x158
.word 0xc5
.word 0x2b1
.word 0x7b
.word 0x24b
.word 0x24e
.word 0x2ed
.word 0x2bb
.word 0x3d3
.word 0x2c2
.word 0x373
.word 0xa1
.word 0x83
.word 0xb9
.word 0x292
.word 0x373
.word 0x340
.word 0x25c
.word 0x19d
.word 0x16e
.word 0x338
.word 0x2b9
.word 0x381
.word 0x15
.word 0x398
.word 0x354
.word 0x262
.word 0x47
.word 0x36f
.word 0x393
.word 0x2b9
.word 0x338
.word 0x1bd
.word 0x161
.word 0xeb
.word 0x238
.word 0xd9
.word 0x28f
.word 0x3b8
.word 0x190
.word 0xc9
.word 0x25
.word 0x1a4
.word 0x27e
.word 0x26c
.word 0xb1
.word 0xc7
.word 0x38
.word 0x213
.word 0xbc
.word 0x1c5
.word 0x3d7
.word 0x3f3
.word 0x3d9
.word 0x1cb
.word 0x1f0
.word 0x161
.word 0xb2
.word 0x271
.word 0x23d
.word 0x1e
.word 0x1b5
.word 0x179
.word 0x210
.word 0x3a0
.word 0x3aa
.word 0x1cb
.word 0xf2
.word 0x35
.word 0xd5
.word 0x266
.word 0x4b
.word 0x373
.word 0x3a3
.word 0x2da
.word 0x13c
.word 0x64
.word 0x57
.word 0xe8
.word 0x251
.word 0x2fc
.word 0x141
.word 0x1c7
.word 0x3a3
.word 0x3fd
.word 0xfe
.word 0x1fc
.word 0x11c
.word 0x100
.word 0x9f
.word 0x49
.word 0x50
.word 0x2be
.word 0xf1
.word 0x8c
.word 0x262
.word 0x21d
.word 0x21a
.word 0xab
.word 0x56
.word 0x30d
.word 0x2d0
.word 0x115
.word 0x1a
.word 0x131
.word 0x3ee
.word 0x2f2
.word 0xd0
.word 0xf3
.word 0x181
.word 0x1c5
.word 0xc1
.word 0x336
.word 0x3e6
.word 0x203
.word 0xc7
.word 0x1d6
.word 0xfd
.word 0x1b1
.word 0x3d0
.word 0x334
.word 0x3af
.word 0x189
.word 0x98
.word 0x1d9
.word 0x26
.word 0x295
.word 0x293
.word 0x223
.word 0xf0
.word 0xec
.word 0x180
.word 0x20f
.word 0x5c
.word 0x208
.word 0xcc
.word 0x293
.word 0x35d
.word 0x264
.word 0xf
.word 0x3a4
.word 0x36e
.word 0xa0
.word 0xd8
.word 0x11b
.word 0x12e
.word 0x3fb
.word 0x344
.word 0x3c0
.word 0x3ed
.word 0x204
.word 0x3c3
.word 0x2ea
.word 0x79
.word 0x3aa
.word 0x138
.word 0x3e9
.word 0x74
.word 0x386
.word 0x136
.word 0x2d
.word 0x128
.word 0x19f
.word 0x4
.word 0x52
.word 0x286
.word 0x257
.word 0x8c
.word 0x1e6
.word 0x330
.word 0x136
.word 0x19d
.word 0x1f6
.word 0x5
.word 0x373
.word 0xd7
.word 0x3ca
.word 0x1a6
.word 0xcb
.word 0x10c
.word 0xfe
.word 0x1f6
.word 0x3da
.word 0x245
.word 0x303
.word 0x1dc
.word 0x276
.word 0x2e8
.word 0x7a
.word 0x3b3
.word 0x90
.word 0x183
.word 0x1bb
.word 0xe4
.word 0x2e6
.word 0xd5
.word 0xce
.word 0x11f
.word 0x116
.word 0x1e5
.word 0x91
.word 0x86
.word 0x2ee
.word 0xac
.word 0x149
.word 0x244
.word 0x198
.word 0x70
.word 0x1a7
.word 0x2c6
.word 0xc4
.word 0x332
.word 0x1fb
.word 0x32f
.word 0xff
.word 0x3af
.word 0x4a
.word 0x3aa
.word 0x3bc
.word 0x3b9
.word 0x117
.word 0x29c
.word 0xfd
.word 0x7e
.word 0x2fe
.word 0x218
.word 0x3e6
.word 0x284
.word 0x193
.word 0x32
.word 0x35a
.word 0x64
.word 0xd
.word 0x2cf
.word 0x130
.word 0x50
.word 0x25f
.word 0x12e
.word 0x113
.word 0x213
.word 0x33
.word 0x23c
.word 0x1dd
.word 0x29d
.word 0x17f
.word 0x260
.word 0x210
.word 0x3e8
.word 0x2ab
.word 0xdc
.word 0x73
.word 0x3e1
.word 0x83
.word 0x6b
.word 0x128
.word 0x26a
.word 0x103
.word 0x30b
.word 0x11e
.word 0x258
.word 0x301
.word 0x3b6
.word 0x91
.word 0x24c
.word 0x63
.word 0x98
.word 0x24
.word 0x1ba
.word 0x362
.word 0x2f6
.word 0x197
.word 0x1c7
.word 0x2eb
.word 0x31b
.word 0xa6
.word 0x331
.word 0xad
.word 0x136
.word 0x14f
.word 0x137
.word 0x1b0
.word 0x2ba
.word 0x69
.word 0x340
.word 0x103
.word 0x111
.word 0x2b6
.word 0x1f4
.word 0x3d3
.word 0x214
.word 0x328
.word 0x397
.word 0xb0
.word 0xf9
.word 0x19
.word 0x10a
.word 0x190
.word 0x2cc
.word 0x49
.word 0x3d9
.word 0xa1
.word 0xa2
.word 0x301
.word 0x73
.word 0x39a
.word 0x30
.word 0x1c4
.word 0x358
.word 0x28f
.word 0x9f
.word 0x2d8
.word 0x8d
.word 0x249
.word 0x310
.word 0x290
.word 0x37f
.word 0x344
.word 0x388
.word 0x3dc
.word 0x6f
.word 0x127
.word 0x12f
.word 0x4a
.word 0x384
.word 0xce
.word 0x1d3
.word 0x5b
.word 0x1f2
.word 0x26d
.word 0xf1
.word 0x20a
.word 0x192
.word 0x396
.word 0x34f
.word 0x265
.word 0x340
.word 0x33b
.word 0x3b
.word 0x2f1
.word 0x22
.word 0x263
.word 0x387
.word 0x371
.word 0x2f9
.word 0x1d4
.word 0x352
.word 0x57
.word 0xf3
.word 0x371
.word 0x37f
.word 0x2a5
.word 0x26
.word 0x325
.word 0x3c0
.word 0x58
.word 0x3a
.word 0xdc
.word 0x110
.word 0x3e5
.word 0x17f
.word 0x3d4
.word 0xd8
.word 0xa8
.word 0x10c
.word 0x371
.word 0x3f7
.word 0xf0
.word 0x337
.word 0x1a1
.word 0x233
.word 0x2ec
.word 0x67
.word 0x144
.word 0x2a5
.word 0x2f
.word 0x1f6
.word 0x3c9
.word 0xfb
.word 0x7e
.word 0xfc
.word 0x2d9
.word 0x30a
.word 0x26c
.word 0x5a
.word 0x327
.word 0x257
.word 0x53
.word 0xaf
.word 0x2c1
.word 0x66
.word 0x1e4
.word 0x175
.word 0x2f7
.word 0x269
.word 0x19f
.word 0x73
.word 0x29c
.word 0x111
.word 0x84
.word 0x31e
.word 0x6c
.word 0x2bb
.word 0xee
.word 0x314
.word 0x12b
.word 0x13f
.word 0x316
.word 0x36d
.word 0x300
.word 0x352
.word 0x28e
.word 0x390
.word 0x33e
.word 0x256
.word 0x339
.word 0x2c3
.word 0x324
.word 0xe1
.word 0x1df
.word 0x12e
.word 0x2cb
.word 0xa7
.word 0x21d
.word 0x331
.word 0x2a0
.word 0x2fa
.word 0x7e
.word 0x181
.word 0x1e1
.word 0x330
.word 0x1ea
.word 0x357
.word 0x3cb
.word 0x344
.word 0xc0
.word 0x9
.word 0x227
.word 0x4d
.word 0x381
.word 0xb9
.word 0x148
.word 0x2cb
.word 0x336
.word 0x114
.word 0x2c2
.word 0x16d
.word 0x3e8
.word 0x20b
.word 0x11c
.word 0x3d2
.word 0x216
.word 0x2e3
.word 0x1c9
.word 0x37f
.word 0xa7
.word 0x3d9
.word 0x3fd
.word 0xeb
.word 0x32b
.word 0x117
.word 0x3fe
.word 0x3a8
.word 0x2c1
.word 0x2c0
.word 0x3f5
.word 0x3b1
.word 0x1a9
.word 0x1b5
.word 0x29e
.word 0x36a
.word 0x3cd
.word 0x145
.word 0x243
.word 0x39b
.word 0x306
.word 0x150
.word 0x3b3
.word 0x48
.word 0x373
.word 0x2cf
.word 0x3a6
.word 0x1dc
.word 0x3a
.word 0x1c9
.word 0x348
.word 0xd
.word 0x157
.word 0x1a2
.word 0x8
.word 0x2ee
.word 0x257
.word 0x2d4
.word 0x126
.word 0x244
.word 0x316
.word 0x21
.word 0x2c5
.word 0x3a2
.word 0x16
.word 0x1b7
.word 0x75
.word 0x396
.word 0x338
.word 0x25b
.word 0x308
.word 0x20f
.word 0x39f
.word 0x38a
.word 0x31f
.word 0x1df
.word 0xe8
.word 0x82
.word 0x175
.word 0x6f
.word 0x2ac
.word 0x32c
.word 0x2b
.word 0x1e5
.word 0x3c5
.word 0x23f
.word 0x22f
.word 0x1fd
.word 0x48
.word 0x16f
.word 0x1f2
.word 0x34f
.word 0x103
.word 0xdf
.word 0x29b
.word 0x3b8
.word 0x106
.word 0x3ce
.word 0xa8
.word 0x372
.word 0xcc
.word 0x17b
.word 0x4b
.word 0x94
.word 0x64
.word 0x23
.word 0x1a
.word 0x2aa
.word 0x3dd
.word 0x3f9
.word 0x3ce
.word 0x108
.word 0x396
.word 0x166
.word 0x395
.word 0x3d9
.word 0x287
.word 0x21
.word 0x380
.word 0x107
.word 0xea
.word 0x13d
.word 0x3ed
.word 0x165
.word 0x2b8
.word 0xa8
.word 0x19f
.word 0xb3
.word 0x2dd
.word 0x39c
.word 0x202
.word 0x11f
.word 0x22f
.word 0x34a
.word 0x349
.word 0xe
.word 0x1f0
.word 0x3b8
.word 0x185
.word 0x1d9
.word 0x320
.word 0x1d1
.word 0x116
.word 0x188
.word 0x60
.word 0x1dc
.word 0x2bb
.word 0xcc
.word 0x6e
.word 0xc9
.word 0x33d
.word 0x24e
.word 0x380
.word 0xc3
.word 0x2bd
.word 0x152
.word 0x132
.word 0x71
.word 0x30e
.word 0x2f9
.word 0x29f
.word 0x205
.word 0x3a8
.word 0x26d
.word 0x23f
.word 0x2aa
.word 0xa4
.word 0x2ad
.word 0x14
.word 0xc3
.word 0xf2
.word 0x273
.word 0x6f
.word 0x16b
.word 0x2fc
.word 0x2b8
.word 0x42
.word 0x103
.word 0x367
.word 0x38a
.word 0x22b
.word 0x8d
.word 0x80
.word 0x199
.word 0x19b
.word 0x12e
.word 0x3d1
.word 0x3b7
.word 0x3f2
.word 0x1ae
.word 0x124
.word 0x26
.word 0x291
.word 0x7d
.word 0x2a3
.word 0xd7
.word 0x3f4
.word 0x3f1
.word 0x1c4
.word 0x1ec
.word 0x25b
.word 0x382
.word 0x1cf
.word 0x304
.word 0x28e
.word 0x389
.word 0x244
.word 0x182
.word 0x16
.word 0x37d
.word 0x285
.word 0x1d6
.word 0x1fc
.word 0xe1
.word 0x261
.word 0x22c
.word 0x173
.word 0x150
.word 0x22d
.word 0x3ea
.word 0x32e
.word 0x8c
.word 0x195
.word 0x393
.word 0xf9
.word 0x270
.word 0x342
.word 0x3c8
.word 0x1b
.word 0x25e
.word 0x2f5
.word 0x9a
.word 0x164
.word 0x28b
.word 0x2b6
.word 0x18c
.word 0x38a
.word 0x2cb
.word 0x70
.word 0x1b6
.word 0x39e
.word 0x360
.word 0x268
.word 0x355
.word 0x12d
.word 0x325
.word 0x232
.word 0x21b
.word 0x2d7
.word 0x119
.word 0xd
.word 0x304
.word 0x3c8
.word 0xd1
.word 0x32
.word 0xcf
.word 0x1ee
.word 0xd2
.word 0x3e8
.word 0x62
.word 0x24e
.word 0x2ea
.word 0x2b5
.word 0x2b6
.word 0x33d
.word 0x64
.word 0x29d
.word 0x34f
.word 0x30c
.word 0x1de
.word 0x275
.word 0x16d
.word 0x265
.word 0x25f
.word 0xee
.word 0x398
.word 0x31b
.word 0x288
.word 0x55
.word 0xfb
.word 0x198
.word 0x60
.word 0x108
.word 0x296
.word 0x183
.word 0x3ff
.word 0x2d9
.word 0xbe
.word 0x3c5
.word 0x3fc
.word 0x300
.word 0x1e1
.word 0x9e
.word 0x2d8
.word 0x1d4
.word 0x1e1
.word 0x177
.word 0xcc
.word 0x3ec
.word 0x1d9
.word 0x3c7
.word 0x3c
.word 0x1f2
.word 0xc1
.word 0x5f
.word 0x3ff
.word 0x28d
.word 0x15f
.word 0x301
.word 0x35e
.word 0x262
.word 0x210
.word 0x290
.word 0x2b3
.word 0x143
.word 0x2a4
.word 0x22d
.word 0x10
.word 0x35b
.word 0x22b
.word 0x376
.word 0x77
.word 0x33c
.word 0x26f
.word 0x76
.word 0x1e5
.word 0x1dc
.word 0x2c0
.word 0x2ff
.word 0xc
.word 0x16b
.word 0x16d
.word 0x23
.word 0x151
.word 0x16c
.word 0x1d4
.word 0x103
.word 0x32f
.word 0xd2
.word 0x32f
.word 0x4c
.word 0x12c
.word 0xc
.word 0x24
.word 0x159
.word 0x8f
.word 0x36
.word 0x114
.word 0x34b
.word 0x6e
.word 0xaf
.word 0x262
.word 0x341
.word 0xe1
.word 0x3bc
.word 0x280
.word 0x1eb
.word 0x35c
.word 0x362
.word 0x3fd
.word 0x175
.word 0x1f6
.word 0x31a
.word 0x29a
.word 0x116
.word 0x4e
.word 0x397
.word 0x32d
.word 0x363
.word 0x309
.word 0x69
.word 0x211
.word 0x2a6
.word 0x1da
.word 0x328
.word 0x165
.word 0xcd
.word 0xe3
.word 0x19f
.word 0x3e5
.word 0x10
.word 0x35d
.word 0x72
.word 0x1b
.word 0xe1
.word 0x3bc
.word 0x2ed
.word 0x117
.word 0x36a
.word 0x8f
.word 0x130
.word 0x24
.word 0x22f
.word 0x3a0
.word 0x3e4
.word 0x110
.word 0x2c
.word 0x87
.word 0x1b3
.word 0x7f
.word 0x17a
.word 0x71
.word 0xb7
.word 0x20
.word 0x19a
.word 0x117
.word 0x48
.word 0xd4
.word 0x90
.word 0x292
.word 0x3c
.word 0x3bb
.word 0x120
.word 0x1eb
.word 0x13e
.word 0x38f
.word 0x1
.word 0x235
.word 0xbd
.word 0x3fe
.word 0x13e
.word 0x1e4
.word 0xb5
.word 0x3
.word 0x3cb
.word 0x38e
.word 0xcc
.word 0x258
.word 0x22b
.word 0xe1
.word 0x14
.word 0x90
.word 0x2a9
.word 0x33b
.word 0x2bf
.word 0x68
.word 0x329
.word 0x286
.word 0x359
.word 0x54
.word 0x275
.word 0x3f7
.word 0xe1
.word 0xa9
.word 0x18b
.word 0x2d7
.word 0x25f
.word 0x97
.word 0x174
.word 0xc
.word 0xa5
.word 0x108
.word 0x291
.word 0x28d
.word 0x3c0
.word 0x12d
.word 0x202
.word 0xd7
.word 0x2f3
.word 0x29c
.word 0x28b
.word 0x383
.word 0x15e
.word 0xd4
.word 0x356
.word 0x36d
.word 0x328
.word 0x390
.word 0x107
.word 0x2c0
.word 0xf2
.word 0x318
.word 0x12
.word 0x258
.word 0x363
.word 0x88
.word 0x20
.word 0x21b
.word 0x376
.word 0xaf
.word 0x291
.word 0x289
.word 0x3d9
.word 0x10f
.word 0x138
.word 0x3fe
.word 0x19d
.word 0x1
.word 0x339
.word 0x19f
.word 0x1e
.word 0xab
.word 0x344
.word 0x15
.word 0x2ec
.word 0x1fa
.word 0x350
.word 0x5f
.word 0x3d4
.word 0x146
.word 0x1ca
.word 0xf3
.word 0x2a
.word 0x15
.word 0x3ae
.word 0x1b5
.word 0x39f
.word 0x93
.word 0x3bf
.word 0x28c
.word 0x1ff
.word 0xb2
.word 0x37f
.word 0x318
.word 0x20a
.word 0x1ae
.word 0x256
.word 0x397
.word 0x160
.word 0x26a
.word 0x2de
.word 0x3d5
.word 0x2da
.word 0x2ed
.word 0x129
.word 0x2c1
.word 0x1f6
.word 0x2a1
.word 0x11
.word 0x3dd
.word 0x2ba
.word 0x287
.word 0x1d9
.word 0x2dd
.word 0x31
.word 0x187
.word 0x24c
.word 0x39e
.word 0x380
.word 0x1a2
.word 0xde
.word 0x2f4
.word 0xe6
.word 0xb6
.word 0x191
.word 0x374
.word 0x85
.word 0x388
.word 0x8d
.word 0x20a
.word 0x34a
.word 0x18a
.word 0x33a
.word 0xaa
.word 0x9e
.word 0x315
.word 0x21a
.word 0xae
.word 0xd5
.word 0x74
.word 0x131
.word 0x267
.word 0x154
.word 0x357
.word 0x1ef
.word 0x15
.word 0x341
.word 0x2d9
.word 0x1c
.word 0x7
.word 0x113
.word 0x46
.word 0x2d4
.word 0x14c
.word 0x22e
.word 0x5c


A_coeff_0:
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
