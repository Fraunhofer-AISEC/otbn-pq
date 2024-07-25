/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* Falcon-512 Verify Implementation */


.section .text

/* Test NTT */

/* Load operands into WDRs */
li x2, 0


/* Load prime into WDR w0*/
la x14, prime
bn.lid x2, 0(x14)

/* Load prime into PQSR*/
pq.pqsrw 0, w0


/* Load prime_dash into WDR w0*/
la x14, prime_dash
bn.lid x2, 0(x14)

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w0


/* Load DMEM(64) into WDR w0*/
la x14, omega0
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load DMEM(96) into WDR w0*/
la x14, psi0
bn.lid x2, 0(x14)

/* Load psi into PQSR*/
pq.pqsrw 4, w0


la x20, coef0
la x19, coef0

jal x1, ntt
li x31, 99

la x20, inv_coef0
la x19, inv_coef0

/* Load DMEM(64) into WDR w0*/
la x14, inv_omega0
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0

/* Load DMEM(96) into WDR w0*/
la x14, inv_psi0
bn.lid x2, 0(x14)

/* Load psi into PQSR*/
pq.pqsrw 4, w0

/* Load n1 into WDR w0*/
la x14, n1
bn.lid x2, 0(x14)

/* Load n^-1 into PQSR*/
pq.pqsrw 7, w0

jal x1, intt

ecall





/*************************************************/
/*  Reduce s2 elements modulo q ([0..q-1] range) */
/*************************************************/

/* input address */
li x4, 0

/* output address */
li x6, 0

jal x1, reduce

/*************************************************/
/*     Compute -s1 = s2*h - c0 mod phi mod q     */
/*************************************************/


/*************/
/*    NTT    */
/*************/


/* Load operands and constants into WDRs */
li x2, 0

/* Load prime into WDR w0*/
la x14, prime
bn.lid x2, 0(x14)

/* Load prime into PQSR*/
pq.pqsrw 0, w0


/* Load prime_dash into WDR w0*/
la x14, prime_dash
bn.lid x2, 0(x14)

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w0


/* Load DMEM(64) into WDR w0*/
la x14, omega0
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load DMEM(96) into WDR w0*/
la x14, psi0
bn.lid x2, 0(x14)

/* Load psi into PQSR*/
pq.pqsrw 4, w0


la x20, coef0
la x19, coef0

jal x1, ntt



/*************/
/*    MUL    */
/*************/

/* input address 1 */
li x4, 16352

/* input address 2 */
li x5, 16352

/* output address */
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




/*************/
/*   INTT    */
/*************/

la x20, inv_coef0
la x19, inv_coef0

/* Load DMEM(64) into WDR w0*/
la x14, inv_omega0
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0

/* Load DMEM(96) into WDR w0*/
la x14, inv_psi0
bn.lid x2, 0(x14)

/* Load psi into PQSR*/
pq.pqsrw 4, w0

/* Load n1 into WDR w0*/
la x14, n1
bn.lid x2, 0(x14)

/* Load n^-1 into PQSR*/
pq.pqsrw 7, w0

jal x1, intt


/*************/
/*    SUB    */
/*************/
/* la x4, Az_coef_0_0 */
li x4, 18432
/* la x5, w_acc_coef_0_0 */
li x5, 20480
/* la x6, w_acc_coef_0_0 */
li x6, 20480 
  
li x31, 1
jal x1, pointwise_sub


/*******************************************************/
/* Normalize -s1 elements into the [-q/2..q/2] range.  */
/*******************************************************/

li x20, 0
li x19, 0

loopi 64, 3
  jal x1, normalize
  addi x19, x19, 32
  addi x20, x20, 32


/************************************************************************************/
/* Signature is valid if and only if the aggregate (-s1,s2) vector is short enough. */
/************************************************************************************/

li x20, 0
li x19, 0

jal x1, is_short
addi x2, x2, 0
ecall

/*************************************************/
/*            Functions and Procedures           */
/*************************************************/


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

loopi 64, 11

  bn.lid x2, 0(x4++)
  bn.lid x3, 0(x5++)


  /* Coefficientwise Subtraction */

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

loopi 64, 14

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
/*                    NTT     
* @param[in]  x20: pointer to input coefficients                  
* @param[in]  x19: pointer to output coefficients      
* clobbered registers: x2: m
*                      x3: j2
*                      x4: 2
*                      x23: intermediate address output
*                      x24: intermediate address input
*                      x25: wdr source 0
*                      x26: wdr source 1
*                      w0-w31: coefficients
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

/*                 NTT - Layer 512               */

  addi x24, x20, 0
  addi x23, x19, 0

  li x25, 0
  li x26, 16

  /* m = n >> 1 */
  li x2, 128
  pq.srw 0, x2

  /* j2 = 1 */
  li x3, 1
  pq.srw 1, x3

  /* j = 0 */
  li x4, 0
  pq.srw 2, x4

  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 

  loopi 2, 15

    /* Load coefficients into WDRs */
    loopi 16, 3
      bn.lid x25++, 0(x24)
      bn.lid x26++, 1024(x24)
      addi x24, x24, 32

    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  

    loop x2, 1
      pq.ctbf.ind 0, 0, 0, 0, 1

    li x25, 0
    li x26, 16

    loopi 16, 3
      bn.sid x25++, 0(x23)
      bn.sid x26++, 1024(x23)
      addi x23, x23, 32

    li x25, 0
    li x26, 16

/*              NTT - Layer 256 -> 1             */

  /* Reload omega and psi */

  /* Load omega into WDR w0 */
  la x26, omega1
  bn.lid x25, 0(x26)

  /* Load omega into PQSR */
  pq.pqsrw 3, w0


  /* Load psi into WDR w0*/
  la x26, psi1
  bn.lid x25, 0(x26)

  /* Load psi into PQSR*/
  pq.pqsrw 4, w0

  /* Load coefficients again */
  addi x24, x19, 0

  loopi 32, 2
    bn.lid x25++, 0(x24)
    addi x24, x24, 32

  loopi 8, 11
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 5
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0   
      loop x2, 1
        pq.ctbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    /* Update idx_psi, idx_omega, m and j2 */
    pq.pqsru 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0 
    slli x3, x3, 1
    srli x2, x2, 1
    pq.srw 2, x4


  addi x24, x19, 0
  li x25, 0

  /* store results to dmem */
  loopi 32, 2
    bn.sid x25++, 0(x24)
    addi x24, x24, 32


  /* m = n >> 1 */
  li x2, 128
  pq.srw 0, x2

  /* j2 = 1 */
  li x3, 1
  pq.srw 1, x3

  /* j = 0 */
  li x4, 0
  pq.srw 2, x4

  addi x24, x19, 0
  li x25, 0

  /* load coefficients from dmem */
  loopi 32, 2
    bn.lid x25++, 1024(x24)
    addi x24, x24, 32

  loopi 8, 12
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 5
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0   
      loop x2, 1
        pq.ctbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    /* Update idx_psi, idx_omega, m and j2 */
    pq.pqsru 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0 
    slli x3, x3, 1
    srli x2, x2, 1
    pq.srw 2, x4

  addi x24, x19, 0
  li x25, 0

  /* store result from [w1] to dmem */
  loopi 32, 2
    bn.sid x25++, 1024(x24)
    addi x24, x24, 32

ret


/*************************************************/
/*                       INTT                     
* @param[in]  x20: pointer to input coefficients                  
* @param[in]  x19: pointer to output coefficients      
* clobbered registers: x2: m
*                      x3: j2
*                      x4: 2
*                      x23: intermediate address output
*                      x24: intermediate address input
*                      x25: wdr source 0
*                      x26: wdr source 1
*                      w0-w31: coefficients
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


  /* Top Part */
  addi x24, x20, 0
  li x23, 0

  loopi 32, 2
    bn.lid x23++, 0(x24)
    addi x24, x24, 32


  loopi 8, 11
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 5
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
      loop x2, 1
        pq.gsbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
    /* Update psi, omega, m and j2 */
    pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
    srli x3, x3, 1
    slli x2, x2, 1
    pq.srw 2, x4


  li x25, 0
  addi x24, x20, 0

  /* store result to dmem */
  loopi 32, 2
    bn.sid x25++, 0(x24)
    addi x24, x24, 32

  /* Bottom Part */
  li x2, 0
  la x25, inv_omega0

  /* Load DMEM(64) into WDR w0*/
  bn.lid x2, 0(x25)

  /* Load omega into PQSR*/
  pq.pqsrw 3, w0

  la x25, inv_psi0
  /* Load DMEM(96) into WDR w0*/
  bn.lid x2, 0(x25)

  /* Load psi into PQSR*/
  pq.pqsrw 4, w0

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

  li x25, 0
  addi x24, x20, 0

  loopi 32, 2
    bn.lid x25++, 1024(x24)
    addi x24, x24, 32

  loopi 8, 12
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 5
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
      loop x2, 1
        pq.gsbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    /* Update psi, omega, m and j2 */
    pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
    srli x3, x3, 1
    slli x2, x2, 1
    pq.srw 2, x4

  li x25, 0
  addi x24, x20, 0

  /* store result to dmem */
  loopi 32, 2
    bn.sid x25++, 1024(x24)
    addi x24, x24, 32

  /* Merge */
  addi x24, x20, 0
  li x25, 0
  li x26, 16

  /* m = n >> 1 */
  li x2, 128
  pq.srw 0, x2

  /* j2 = 1 */
  li x3, 1
  pq.srw 1, x3

  /* j = 0 */
  li x4, 0
  pq.srw 2, x4

  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 

  loopi 2, 18

    /* Load DMEM(0) into WDR w0*/
    loopi 16, 3
      bn.lid x25++, 0(x24)
      bn.lid x26++, 1024(x24)
      addi x24, x24, 32

    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  

    loop x2, 1
      pq.gsbf.ind 0, 0, 0, 0, 1

    li x25, 0
    li x26, 16

    pq.srw 3, x25

    loopi 256, 1
      pq.scale.ind 0, 0, 0, 0, 1

    loopi 16, 3
      bn.sid x25++, 0(x20)
      bn.sid x26++, 1024(x20)
      addi x20, x20, 32

    li x25, 0
    li x26, 16

ret


/*************************************************/
/*                      REDUCE                     
* @param[in] x4: address of operands in DMEM
* @param[in] x6: address of result in DMEM
* @param[out] DMEM[x6:x6+1024]: output of subtraction
*
* clobbered registers: x2: WDR register address operand
*                      x8: WDR register address result
*                      w24: WDR result
*                      w0: WDR operand
*                      w16: WDR operand all zero
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

reduce:

li x2, 0
li x8, 24

/* Generate all zero vector */
bn.xor w16, w16, w16

loopi 64, 10

  bn.lid x2, 0(x4++)

  /* Coefficientwise Subtraction */
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
/*                      NORMALIZE                     
* @param[in]  x20: pointer to input coefficients                  
* @param[in]  x19: pointer to output coefficients      
* clobbered registers: x2: m
*                      x3: j2
*                      x4: 2
*                      x23: intermediate address output
*                      x24: intermediate address input
*                      x25: wdr source 0
*                      x26: wdr source 1
*                      w6: Q/2
*                      w7: 0x00000000
*                      w8: 0xffffffff
*                      w9: load coefficients in there
*                      w13: w
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

normalize:

  /* Generate constants */

  /* Load bitmask in w8 */
  la x4, bitmask32
  li x3, 8
  bn.lid x3, 0(x4) 

  /* Compute allzero vector in w7 */
  bn.xor w7, w7, w7

  /* Load prime in w9 */
  la x4, prime
  li x3, 9
  bn.lid x3, 0(x4) 

  /* Compute Q/2 and store in w6 */
  bn.rshi w6, w7, w9 >> 1

  /* Load Coefficients in WDR 9 */
  li x3, 9
  bn.lid x3, 0(x20) 

  /* Work in WDR 14 */

  /* Sort coefficients differently to store them easier in one WDR */
  pq.add w10.7, w9.0, w7.0
  pq.add w10.6, w9.1, w7.0
  pq.add w10.5, w9.2, w7.0
  pq.add w10.4, w9.3, w7.0
  pq.add w10.3, w9.4, w7.0
  pq.add w10.2, w9.5, w7.0
  pq.add w10.1, w9.6, w7.0
  pq.add w10.0, w9.7, w7.0


  loopi 8, 17

    /* Select current coefficient */
    bn.and w13, w8, w10

    /* w -= (((Q-1)/2 - w) >> 31) & Q */
    bn.sub w14, w6, w13
    bn.and w14, w8, w14

    bn.rshi w14, w7, w14 >> 31

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

    /* Store w in WDR16 */
    bn.and w14, w8, w14
    bn.or w16, w14, w16 << 32

    /* Update WDR10 to process next coefficient */
    bn.or w10, w7, w10 >> 32

  li x8, 16
  /* Store Coefficients */
  bn.sid x8, 0(x19)

ret



/*************************************************/
/*                      IS_SHORT                                   
* @param[in]  x19: pointer to s1 coefficients     
* @param[in]  x20: pointer to s2 coefficients
* @param[in]  x21: pointer to store coefficients     
* clobbered registers: x2: m
*                      x3: j2
*                      x4: 2
*                      x23: intermediate address output
*                      x24: intermediate address input
*                      x25: wdr source 0
*                      x26: wdr source 1
*                      w6: Q/2
*                      w7: beta^2
*                      w8: 0xffffffff
*                      w9: load coefficients in there
*                      w13: w
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
is_short:

/* Compute squared norm in w31 and w30 */

/* Initialize w30 as 0x000..0*/
bn.xor w30, w30, w30

/* Initialize w31 as 0x000..0*/
bn.xor w31, w31, w31

/* Initialize w24 as 0x000..0*/
bn.xor w24, w24, w24

/* Load beta squared into w7 */
la x2, l2bound
li x3, 7
bn.lid x3, 0(x2)

li x2, 0
li x3, 16

loopi 64, 42

  /* load s1 for s1 * s1 */
  bn.lid x2, 0(x19)
  bn.lid x3, 0(x19++)

  /* Set idx0/idx1 */
  pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 

  loopi 8, 1
    /* Transformation in Montgomery Domain */
    pq.scale.ind 0, 0, 0, 0, 1

  /* Square s1 and add to norm */
  pq.mul w24.0, w0.0, w16.0
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.1, w16.1
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.2, w16.2
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.3, w16.3
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.4, w16.4
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.5, w16.5
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.6, w16.6
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.7, w16.7
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  /* load s2 for s2 * s2 */
  bn.lid x2, 0(x20)
  bn.lid x3, 0(x20++)

  /* Set idx0/idx1 */
  pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 

  loopi 8, 1
    /* Transformation in Montgomery Domain */
    pq.scale.ind 0, 0, 0, 0, 1

  /* Square s1 and add to norm */
  pq.mul w24.0, w0.0, w16.0
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.1, w16.1
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.2, w16.2
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.3, w16.3
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.4, w16.4
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.5, w16.5
  bn.add w31, w31, w24
  bn.or w30, w31, w30 

  pq.mul w24.0, w0.6, w16.6
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  pq.mul w24.0, w0.7, w16.7
  bn.add w31, w31, w24
  bn.or w30, w31, w30

  /* Check if norm exceeds bound */
  bn.cmp w7, w30, FG0
  csrrw x14, 1984, x0
  andi x14, x14, 1

  /* If norm exceeds bound x14 is set to 0 */
  xori x14, x14, 1

ret

.section .data

/* Constants */
prime:
  .quad 0x0000000000003001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

prime_dash:
  .quad 0x00000000f7002fff
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

omega0:
  .quad 0x0000000000000539
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

omega1:
  .quad 0x0000068500000452
  .quad 0x000003cb00002d49
  .quad 0x00000900000008f1
  .quad 0x0000205600000100

psi0:
  .quad 0x0000000000000452
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

psi1:
  .quad 0x00002d4900000685
  .quad 0x000008f1000003cb
  .quad 0x0000010000000900
  .quad 0x0000229200002056

inv_omega0:
  .quad 0x0000000000001e43
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

inv_omega1:
  .quad 0x0000000000001e43
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

inv_psi0:
  .quad 0x0000000000000b86
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

inv_psi1:
  .quad 0x0000000000000b86
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

n1:
  .quad 0x0000000000001d56
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

coef0:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

coef1:
  .quad 0x0000000900000008
  .quad 0x0000000b0000000a
  .quad 0x0000000d0000000c
  .quad 0x0000000f0000000e

coef2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

coef3:
  .quad 0x0000001900000018
  .quad 0x0000001b0000001a
  .quad 0x0000001d0000001c
  .quad 0x0000001f0000001e

coef4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

coef5:
  .quad 0x0000002900000028
  .quad 0x0000002b0000002a
  .quad 0x0000002d0000002c
  .quad 0x0000002f0000002e

coef6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

coef7:
  .quad 0x0000003900000038
  .quad 0x0000003b0000003a
  .quad 0x0000003d0000003c
  .quad 0x0000003f0000003e

coef8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

coef9:
  .quad 0x0000004900000048
  .quad 0x0000004b0000004a
  .quad 0x0000004d0000004c
  .quad 0x0000004f0000004e

coef10:
  .quad 0x0000005100000050
  .quad 0x0000005300000052
  .quad 0x0000005500000054
  .quad 0x0000005700000056

coef11:
  .quad 0x0000005900000058
  .quad 0x0000005b0000005a
  .quad 0x0000005d0000005c
  .quad 0x0000005f0000005e

coef12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

coef13:
  .quad 0x0000006900000068
  .quad 0x0000006b0000006a
  .quad 0x0000006d0000006c
  .quad 0x0000006f0000006e

coef14:
  .quad 0x0000007100000070
  .quad 0x0000007300000072
  .quad 0x0000007500000074
  .quad 0x0000007700000076

coef15:
  .quad 0x0000007900000078
  .quad 0x0000007b0000007a
  .quad 0x0000007d0000007c
  .quad 0x0000007f0000007e

coef16:
  .quad 0x0000008100000080
  .quad 0x0000008300000082
  .quad 0x0000008500000084
  .quad 0x0000008700000086

coef17:
  .quad 0x0000008900000088
  .quad 0x0000008b0000008a
  .quad 0x0000008d0000008c
  .quad 0x0000008f0000008e

coef18:
  .quad 0x0000009100000090
  .quad 0x0000009300000092
  .quad 0x0000009500000094
  .quad 0x0000009700000096

coef19:
  .quad 0x0000009900000098
  .quad 0x0000009b0000009a
  .quad 0x0000009d0000009c
  .quad 0x0000009f0000009e

coef20:
  .quad 0x000000a1000000a0
  .quad 0x000000a3000000a2
  .quad 0x000000a5000000a4
  .quad 0x000000a7000000a6

coef21:
  .quad 0x000000a9000000a8
  .quad 0x000000ab000000aa
  .quad 0x000000ad000000ac
  .quad 0x000000af000000ae

coef22:
  .quad 0x000000b1000000b0
  .quad 0x000000b3000000b2
  .quad 0x000000b5000000b4
  .quad 0x000000b7000000b6

coef23:
  .quad 0x000000b9000000b8
  .quad 0x000000bb000000ba
  .quad 0x000000bd000000bc
  .quad 0x000000bf000000be

coef24:
  .quad 0x000000c1000000c0
  .quad 0x000000c3000000c2
  .quad 0x000000c5000000c4
  .quad 0x000000c7000000c6

coef25:
  .quad 0x000000c9000000c8
  .quad 0x000000cb000000ca
  .quad 0x000000cd000000cc
  .quad 0x000000cf000000ce

coef26:
  .quad 0x000000d1000000d0
  .quad 0x000000d3000000d2
  .quad 0x000000d5000000d4
  .quad 0x000000d7000000d6

coef27:
  .quad 0x000000d9000000d8
  .quad 0x000000db000000da
  .quad 0x000000dd000000dc
  .quad 0x000000df000000de

coef28:
  .quad 0x000000e1000000e0
  .quad 0x000000e3000000e2
  .quad 0x000000e5000000e4
  .quad 0x000000e7000000e6

coef29:
  .quad 0x000000e9000000e8
  .quad 0x000000eb000000ea
  .quad 0x000000ed000000ec
  .quad 0x000000ef000000ee

coef30:
  .quad 0x000000f1000000f0
  .quad 0x000000f3000000f2
  .quad 0x000000f5000000f4
  .quad 0x000000f7000000f6

coef31:
  .quad 0x000000f9000000f8
  .quad 0x000000fb000000fa
  .quad 0x000000fd000000fc
  .quad 0x000000ff000000fe

coef32:
  .quad 0x0000010100000100
  .quad 0x0000010300000102
  .quad 0x0000010500000104
  .quad 0x0000010700000106

coef33:
  .quad 0x0000010900000108
  .quad 0x0000010b0000010a
  .quad 0x0000010d0000010c
  .quad 0x0000010f0000010e

coef34:
  .quad 0x0000011100000110
  .quad 0x0000011300000112
  .quad 0x0000011500000114
  .quad 0x0000011700000116

coef35:
  .quad 0x0000011900000118
  .quad 0x0000011b0000011a
  .quad 0x0000011d0000011c
  .quad 0x0000011f0000011e

coef36:
  .quad 0x0000012100000120
  .quad 0x0000012300000122
  .quad 0x0000012500000124
  .quad 0x0000012700000126

coef37:
  .quad 0x0000012900000128
  .quad 0x0000012b0000012a
  .quad 0x0000012d0000012c
  .quad 0x0000012f0000012e

coef38:
  .quad 0x0000013100000130
  .quad 0x0000013300000132
  .quad 0x0000013500000134
  .quad 0x0000013700000136

coef39:
  .quad 0x0000013900000138
  .quad 0x0000013b0000013a
  .quad 0x0000013d0000013c
  .quad 0x0000013f0000013e

coef40:
  .quad 0x0000014100000140
  .quad 0x0000014300000142
  .quad 0x0000014500000144
  .quad 0x0000014700000146

coef41:
  .quad 0x0000014900000148
  .quad 0x0000014b0000014a
  .quad 0x0000014d0000014c
  .quad 0x0000014f0000014e

coef42:
  .quad 0x0000015100000150
  .quad 0x0000015300000152
  .quad 0x0000015500000154
  .quad 0x0000015700000156

coef43:
  .quad 0x0000015900000158
  .quad 0x0000015b0000015a
  .quad 0x0000015d0000015c
  .quad 0x0000015f0000015e

coef44:
  .quad 0x0000016100000160
  .quad 0x0000016300000162
  .quad 0x0000016500000164
  .quad 0x0000016700000166

coef45:
  .quad 0x0000016900000168
  .quad 0x0000016b0000016a
  .quad 0x0000016d0000016c
  .quad 0x0000016f0000016e

coef46:
  .quad 0x0000017100000170
  .quad 0x0000017300000172
  .quad 0x0000017500000174
  .quad 0x0000017700000176

coef47:
  .quad 0x0000017900000178
  .quad 0x0000017b0000017a
  .quad 0x0000017d0000017c
  .quad 0x0000017f0000017e

coef48:
  .quad 0x0000018100000180
  .quad 0x0000018300000182
  .quad 0x0000018500000184
  .quad 0x0000018700000186

coef49:
  .quad 0x0000018900000188
  .quad 0x0000018b0000018a
  .quad 0x0000018d0000018c
  .quad 0x0000018f0000018e

coef50:
  .quad 0x0000019100000190
  .quad 0x0000019300000192
  .quad 0x0000019500000194
  .quad 0x0000019700000196

coef51:
  .quad 0x0000019900000198
  .quad 0x0000019b0000019a
  .quad 0x0000019d0000019c
  .quad 0x0000019f0000019e

coef52:
  .quad 0x000001a1000001a0
  .quad 0x000001a3000001a2
  .quad 0x000001a5000001a4
  .quad 0x000001a7000001a6

coef53:
  .quad 0x000001a9000001a8
  .quad 0x000001ab000001aa
  .quad 0x000001ad000001ac
  .quad 0x000001af000001ae

coef54:
  .quad 0x000001b1000001b0
  .quad 0x000001b3000001b2
  .quad 0x000001b5000001b4
  .quad 0x000001b7000001b6

coef55:
  .quad 0x000001b9000001b8
  .quad 0x000001bb000001ba
  .quad 0x000001bd000001bc
  .quad 0x000001bf000001be

coef56:
  .quad 0x000001c1000001c0
  .quad 0x000001c3000001c2
  .quad 0x000001c5000001c4
  .quad 0x000001c7000001c6

coef57:
  .quad 0x000001c9000001c8
  .quad 0x000001cb000001ca
  .quad 0x000001cd000001cc
  .quad 0x000001cf000001ce

coef58:
  .quad 0x000001d1000001d0
  .quad 0x000001d3000001d2
  .quad 0x000001d5000001d4
  .quad 0x000001d7000001d6

coef59:
  .quad 0x000001d9000001d8
  .quad 0x000001db000001da
  .quad 0x000001dd000001dc
  .quad 0x000001df000001de

coef60:
  .quad 0x000001e1000001e0
  .quad 0x000001e3000001e2
  .quad 0x000001e5000001e4
  .quad 0x000001e7000001e6

coef61:
  .quad 0x000001e9000001e8
  .quad 0x000001eb000001ea
  .quad 0x000001ed000001ec
  .quad 0x000001ef000001ee

coef62:
  .quad 0x000001f1000001f0
  .quad 0x000001f3000001f2
  .quad 0x000001f5000001f4
  .quad 0x000001f7000001f6

coef63:
  .quad 0x000001f9000001f8
  .quad 0x000001fb000001fa
  .quad 0x000001fd000001fc
  .quad 0x000001ff000001fe

inv_coef0:
  .quad 0x0000207100000d96
  .quad 0x000024b20000244e
  .quad 0x0000176100001a06
  .quad 0x000015b800000c3c

inv_coef1:
  .quad 0x00000e3c000021d1
  .quad 0x00002b360000211f
  .quad 0x0000289b00000166
  .quad 0x00002ecc00002664

inv_coef2:
  .quad 0x0000016d00001a43
  .quad 0x000020340000183e
  .quad 0x0000225f0000239c
  .quad 0x0000197500000792

inv_coef3:
  .quad 0x0000218e00000da3
  .quad 0x00000bbb000011dd
  .quad 0x000017f1000022d8
  .quad 0x00000f3a0000046b

inv_coef4:
  .quad 0x000011e700001788
  .quad 0x00000b78000004c6
  .quad 0x00002fea00002084
  .quad 0x00000cde000010a4

inv_coef5:
  .quad 0x0000181d000018b4
  .quad 0x00002c2f000004ed
  .quad 0x0000153c000007c1
  .quad 0x00000fd400002965

inv_coef6:
  .quad 0x0000215000001a89
  .quad 0x000023e100002920
  .quad 0x00001bf800001ded
  .quad 0x0000290800002dae

inv_coef7:
  .quad 0x000014fa00002104
  .quad 0x00002f4e00001266
  .quad 0x00002ad70000136a
  .quad 0x00001396000018fe

inv_coef8:
  .quad 0x000015ae00001458
  .quad 0x00000c36000011c5
  .quad 0x00001bd800002ad5
  .quad 0x0000104b00001cf4

inv_coef9:
  .quad 0x0000226600001aec
  .quad 0x000029b000002f9d
  .quad 0x00002c550000229c
  .quad 0x000007d300002a28

inv_coef10:
  .quad 0x00002ec400001e82
  .quad 0x00002ba2000021f9
  .quad 0x0000246b00001211
  .quad 0x0000121c000009b3

inv_coef11:
  .quad 0x000023250000083f
  .quad 0x0000039a00000e5a
  .quad 0x00000ac800001b35
  .quad 0x0000119a00002b82

inv_coef12:
  .quad 0x00002458000008fe
  .quad 0x000016eb00000f28
  .quad 0x00001a1200000c5e
  .quad 0x0000159200001a4f

inv_coef13:
  .quad 0x000022ed000013fe
  .quad 0x00002bf200001cad
  .quad 0x000012050000284f
  .quad 0x00002c1e000020b5

inv_coef14:
  .quad 0x00001e5000001f93
  .quad 0x000012a4000015cf
  .quad 0x000006a2000026fe
  .quad 0x00002fe5000019ea

inv_coef15:
  .quad 0x0000071400002103
  .quad 0x0000026d00000d7b
  .quad 0x0000218f000011e8
  .quad 0x0000043b00000533

inv_coef16:
  .quad 0x0000055d0000167f
  .quad 0x00001f3e000002da
  .quad 0x00002a3500000b7e
  .quad 0x000003b900001548

inv_coef17:
  .quad 0x000004e8000029b7
  .quad 0x000001ec00001b86
  .quad 0x00001715000018ac
  .quad 0x00002df4000025b6

inv_coef18:
  .quad 0x00001dbb00001b71
  .quad 0x00000ea700000b49
  .quad 0x000018f70000181c
  .quad 0x00001f0500002973

inv_coef19:
  .quad 0x00002b4700001d8b
  .quad 0x000029c2000011ec
  .quad 0x00000bd900000f19
  .quad 0x000010e2000019b0

inv_coef20:
  .quad 0x000009f500000833
  .quad 0x0000077000000fc9
  .quad 0x00001b6400002917
  .quad 0x00001e34000027d4

inv_coef21:
  .quad 0x00002a2800002663
  .quad 0x0000262b000012d0
  .quad 0x00001c880000024e
  .quad 0x0000159100001f5f

inv_coef22:
  .quad 0x0000065400002348
  .quad 0x000010cf00001005
  .quad 0x00001dc40000157b
  .quad 0x000029f000000000

inv_coef23:
  .quad 0x00000d66000021c2
  .quad 0x00001fe600001fb6
  .quad 0x0000005f0000130d
  .quad 0x00001f1c000014b8

inv_coef24:
  .quad 0x000011e8000013c7
  .quad 0x0000209c0000250f
  .quad 0x00000b7b000006c6
  .quad 0x0000271d00001b2e

inv_coef25:
  .quad 0x00000a0200000d3f
  .quad 0x0000116b000015e9
  .quad 0x0000260f000007cd
  .quad 0x0000296c00001543

inv_coef26:
  .quad 0x000020b000002212
  .quad 0x00000721000017fb
  .quad 0x000015550000006c
  .quad 0x0000031c000009d8

inv_coef27:
  .quad 0x00002c99000022de
  .quad 0x000015a500002504
  .quad 0x00002a5700002e5a
  .quad 0x000006d20000165c

inv_coef28:
  .quad 0x00001eac00000d10
  .quad 0x000010ff0000223a
  .quad 0x00002de500000fe4
  .quad 0x00001fa70000169f

inv_coef29:
  .quad 0x00001f1400001f03
  .quad 0x000027de00002f5e
  .quad 0x000004e5000018af
  .quad 0x0000007500001c3e

inv_coef30:
  .quad 0x0000135d00002026
  .quad 0x0000024700001676
  .quad 0x000013e400000c37
  .quad 0x00001921000008e0

inv_coef31:
  .quad 0x000008ad00001ae6
  .quad 0x0000004200001100
  .quad 0x000020e3000007b5
  .quad 0x000029eb00000bf2

inv_coef32:
  .quad 0x00001f8900000340
  .quad 0x00001a6e00002cbd
  .quad 0x0000290b000018a2
  .quad 0x0000132f00002403

inv_coef33:
  .quad 0x0000110000000140
  .quad 0x000025e3000023a6
  .quad 0x000029cd00000cc3
  .quad 0x0000109500001c46

inv_coef34:
  .quad 0x0000126e00002e38
  .quad 0x00002b6d0000106f
  .quad 0x000014400000088c
  .quad 0x0000019d00000680

inv_coef35:
  .quad 0x000024f900000d03
  .quad 0x00000c2c000019dc
  .quad 0x00000c17000015ce
  .quad 0x0000240100002703

inv_coef36:
  .quad 0x00002899000002a1
  .quad 0x00002c4700001cd7
  .quad 0x0000015700001b91
  .quad 0x0000289300000834

inv_coef37:
  .quad 0x00000c7d00002d89
  .quad 0x000008d0000018f0
  .quad 0x0000230600001c1b
  .quad 0x00002636000018c7

inv_coef38:
  .quad 0x00000f2b00002942
  .quad 0x000017ff00002706
  .quad 0x000029f5000019b3
  .quad 0x000004d70000230d

inv_coef39:
  .quad 0x0000004c000017a2
  .quad 0x000018ca00002564
  .quad 0x00001a6300002a49
  .quad 0x00001b4700000c0a

inv_coef40:
  .quad 0x00002f1b000011f7
  .quad 0x0000063c00000205
  .quad 0x000008dd00002c76
  .quad 0x0000046a00001d02

inv_coef41:
  .quad 0x00000deb000018a8
  .quad 0x0000058200000392
  .quad 0x00002f9300002723
  .quad 0x00002d9600000d73

inv_coef42:
  .quad 0x000004e800002ee5
  .quad 0x0000134000000714
  .quad 0x000019310000012b
  .quad 0x000000f6000028c3

inv_coef43:
  .quad 0x000015f200001a2f
  .quad 0x00001f6e00001c3d
  .quad 0x00000d9d00000f44
  .quad 0x000020d90000270f

inv_coef44:
  .quad 0x0000263300001654
  .quad 0x0000278100002974
  .quad 0x00000aa800001baf
  .quad 0x000027ac000025c9

inv_coef45:
  .quad 0x000003cc00001bdb
  .quad 0x0000145900000c96
  .quad 0x00002d4800001dec
  .quad 0x0000247d00001365

inv_coef46:
  .quad 0x000021d80000020e
  .quad 0x000006000000254a
  .quad 0x00002c0f00000e55
  .quad 0x00002cd200002a5d

inv_coef47:
  .quad 0x0000056f000029f6
  .quad 0x00002f0100001ae8
  .quad 0x00001f9800001bb7
  .quad 0x00001072000022e3

inv_coef48:
  .quad 0x00000d0900001b92
  .quad 0x000027b100002043
  .quad 0x0000190300002f01
  .quad 0x000001900000018b

inv_coef49:
  .quad 0x000003d000001260
  .quad 0x0000046a000010c7
  .quad 0x00002f5600000c4a
  .quad 0x00002fd700001d21

inv_coef50:
  .quad 0x0000025e00002dcf
  .quad 0x0000168000001cac
  .quad 0x00000f9700000098
  .quad 0x00000f1800001702

inv_coef51:
  .quad 0x00001047000022ee
  .quad 0x0000225a00002872
  .quad 0x000003f1000028e3
  .quad 0x00001e1600000aca

inv_coef52:
  .quad 0x000005d6000012f8
  .quad 0x0000113f0000086c
  .quad 0x00001c2f0000181e
  .quad 0x00002ab300002a08

inv_coef53:
  .quad 0x00000db000001c84
  .quad 0x000027e300001380
  .quad 0x00001da100002f8c
  .quad 0x00000faa00001164

inv_coef54:
  .quad 0x00000b7700002e02
  .quad 0x0000001900000b0d
  .quad 0x0000145d0000048c
  .quad 0x0000119d00002d02

inv_coef55:
  .quad 0x00001ea7000029b6
  .quad 0x000014e600001f0c
  .quad 0x00000cb5000006ae
  .quad 0x000007cb00000c30

inv_coef56:
  .quad 0x00000f2b00000205
  .quad 0x00001cf6000024d1
  .quad 0x00001de700000323
  .quad 0x00001a9500002905

inv_coef57:
  .quad 0x0000205300001c2e
  .quad 0x0000156800000740
  .quad 0x0000260800000502
  .quad 0x0000090b00000889

inv_coef58:
  .quad 0x00002d5b000008b2
  .quad 0x0000295e00002405
  .quad 0x000014b300001e32
  .quad 0x0000094c000019e6

inv_coef59:
  .quad 0x0000149e00000063
  .quad 0x0000123c000001d6
  .quad 0x0000071700000ca1
  .quad 0x00002d0200002a58

inv_coef60:
  .quad 0x000015ff00000d5d
  .quad 0x000029d400002ea3
  .quad 0x0000154700001265
  .quad 0x000020be00000c9d

inv_coef61:
  .quad 0x00001e6f00000ef2
  .quad 0x0000209200000e0d
  .quad 0x0000065100002738
  .quad 0x00000e5e000004a7

inv_coef62:
  .quad 0x0000106500001e48
  .quad 0x0000201800000c1c
  .quad 0x0000195800001d13
  .quad 0x00002c53000003cd

inv_coef63:
  .quad 0x0000263d000022a1
  .quad 0x00001f54000004c3
  .quad 0x00002552000025ae
  .quad 0x00000fcd0000263a

bitmask32:
  .word 0xFFFFFFFF

bitmask_extended: 
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

l2bound:
  .word 0x02075426

l2bound_extended: 
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

r_dash:
  .quad 0x0000000000001620
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000