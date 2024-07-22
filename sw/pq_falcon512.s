/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* Falcon-512 Verify Implementation */


.section .text

/*************************************************/
/*  Reduce s2 elements modulo q ([0..q-1] range) */
/*************************************************/


/*************************************************/
/*     Compute -s1 = s2*h - c0 mod phi mod q     */
/*************************************************/

/*******************************************************/
/* Normalize -s1 elements into the [-q/2..q/2] range.  */
/*******************************************************/


/************************************************************************************/
/* Signature is valid if and only if the aggregate (-s1,s2) vector is short enough. */
/************************************************************************************/

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

A_coeff_0:
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
.quad 0x0000000000000000
