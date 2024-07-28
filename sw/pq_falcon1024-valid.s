/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* Falcon-1024 Verify Implementation */
.section .text

/*************************************************/
/*  Reduce s2 elements modulo q ([0..q-1] range) */
/*************************************************/

/* Load operands and constants into WDRs */
li x2, 0

/* Load prime into WDR w0*/
la x14, prime
bn.lid x2, 0(x14)

/* Load prime into PQSR*/
pq.pqsrw 0, w0

/* input address */
la x4, s2_coef0

/* output address */
la x6, tt_coef0

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

/* Load omega0 into WDR w0*/
la x14, omega0
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0

/* Load psi0 into WDR w0*/
la x14, psi0
bn.lid x2, 0(x14)

/* Load psi into PQSR*/
pq.pqsrw 4, w0

/* NTT(tt) */
la x20, tt_coef0
la x19, tt_coef0
jal x1, ntt

/* Load operands and constants into WDRs */
li x2, 0

/* Load omega0 into WDR w0*/
la x14, omega0
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0

/* Load psi0 into WDR w0*/
la x14, psi0
bn.lid x2, 0(x14)

/* Load psi into PQSR*/
pq.pqsrw 4, w0

/* NTT(tt) */
la x20, h_coef0
la x19, h_coef0
jal x1, ntt


/*************/
/*    MUL    */
/*************/

/* input address 1 */
la x4, tt_coef0

/* input address 2 */
la x5, h_coef0

/* output address */
la x6, tt_coef0

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
li x2, 0

la x20, tt_coef0
la x19, tt_coef0

/* Load inv_omega0 into WDR w0*/
la x14, inv_omega0
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0

/* Load inv_psi0 into WDR w0*/
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

li x5, 0
pq.srw 5, x5

la x4, tt_coef0
la x5, c0_coef0
la x6, tt_coef0 
  
li x31, 1
jal x1, pointwise_sub


/*******************************************************/
/* Normalize -s1 elements into the [-q/2..q/2] range.  */
/*******************************************************/

la x20, tt_coef0
la x19, tt_coef0

loopi 128, 3
  jal x1, normalize
  addi x19, x19, 32
  addi x20, x20, 32

/************************************************************************************/
/* Signature is valid if and only if the aggregate (-s1,s2) vector is short enough. */
/************************************************************************************/

la x20, tt_coef0
la x19, s2_coef0

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

loopi 128, 11

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

loopi 128, 14

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

/*                 NTT - Layer 1024              */

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

  loopi 4, 15

    /* Load DMEM(0) into WDR w0*/
    loopi 16, 3
      bn.lid x25++, 0(x24)
      bn.lid x26++, 2048(x24)
      addi x24, x24, 32

    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  

    loop x2, 1
      pq.ctbf.ind 0, 0, 0, 0, 1

    li x25, 0
    li x26, 16

    loopi 16, 3
      bn.sid x25++, 0(x23)
      bn.sid x26++, 2048(x23)
      addi x23, x23, 32

    li x25, 0
    li x26, 16

/*                 NTT - Layer 512               */

  addi x23, x19, 0
  addi x24, x19, 0

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

  /* Update idx_psi and idx_omega */
  pq.pqsru 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0 

  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 

loopi 2, 25

  /* m = n >> 1 */
  li x2, 128
  pq.srw 0, x2

  /* j2 = 1 */
  li x3, 1
  pq.srw 1, x3

  /* j = 0 */
  li x4, 0
  pq.srw 2, x4

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

  pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

  addi x24, x24, 1024
  addi x23, x23, 1024


/*              NTT - Layer 256 -> 1             */

  loopi 7, 1
    /* Update idx_psi and idx_omega */
    pq.pqsru 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0 

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
  li x25, 0

  loopi 32, 2
    bn.lid x25++, 0(x24)
    addi x24, x24, 32

  loopi 8, 13
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 7
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0   
      loop x2, 1
        pq.ctbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
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

  loopi 32, 2
    bn.lid x25++, 1024(x24)
    addi x24, x24, 32
    
  loopi 8, 15
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 7
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0   
      loop x2, 1
        pq.ctbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
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
    bn.sid x25++, 1024(x24)
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
    bn.lid x25++, 2048(x24)
    addi x24, x24, 32

  loopi 8, 14
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 7
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0   
      loop x2, 1
        pq.ctbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
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
    bn.sid x25++, 2048(x24)
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

  li x25, 0
  addi x21, x24, 0
  loopi 32, 2
    bn.lid x25++, 2048(x21)
    addi x21, x21, 32

  loopi 8, 16
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 7
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0   
      loop x2, 1
        pq.ctbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    /* Update idx_psi, idx_omega, m and j2 */
    pq.pqsru 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0 
    slli x3, x3, 1
    srli x2, x2, 1
    pq.srw 2, x4

  /* store result from [w1] to dmem */
  li x25, 0
  addi x21, x24, 0
  loopi 32, 2
    bn.sid x25++, 2048(x21)
    addi x21, x21, 32

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
  li x25, 0

  loopi 32, 2
    bn.lid x25++, 0(x24)
    addi x24, x24, 32

  loopi 8, 13
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 7
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
      loop x2, 1
        pq.gsbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
    /* Update psi, omega, m and j2 */
    pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
    srli x3, x3, 1
    slli x2, x2, 1
    pq.srw 2, x4


  li x25, 0
  addi x23, x19, 0

  /* store result to dmem */
  loopi 32, 2
    bn.sid x25++, 0(x23)
    addi x23, x23, 32

  /* Top Bottom Part */
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

  li x25, 0
  addi x24, x20, 0

  loopi 32, 2
    bn.lid x25++, 1024(x24)
    addi x24, x24, 32

  loopi 8, 15
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    loop x3, 7
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
      loop x2, 1
        pq.gsbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    /* Update psi, omega, m and j2 */
    pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
    srli x3, x3, 1
    slli x2, x2, 1
    pq.srw 2, x4

  li x25, 0
  addi x23, x19, 0

  /* store result to dmem */
  loopi 32, 2
    bn.sid x25++, 1024(x23)
    addi x23, x23, 32

  /* Bottom Top Part */
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

  li x25, 0
  addi x24, x20, 0

  loopi 32, 2
    bn.lid x25++, 2048(x24)
    addi x24, x24, 32

  loopi 8, 14
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 7
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
      loop x2, 1
        pq.gsbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
    /* Update psi, omega, m and j2 */
    pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
    srli x3, x3, 1
    slli x2, x2, 1
    pq.srw 2, x4

  li x25, 0
  addi x23, x19, 0

  /* store result to dmem */
  loopi 32, 2
    bn.sid x25++, 2048(x23)
    addi x23, x23, 32


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

  li x25, 0
  addi x24, x20, 1024

  loopi 32, 2
    bn.lid x25++, 2048(x24)
    addi x24, x24, 32

  loopi 8, 16
    /* Set psi as twiddle */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    loop x3, 7
      /* Set idx0/idx1 */
      pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
      loop x2, 1
        pq.gsbf.ind 0, 0, 0, 0, 1
      /* Update twiddle and increment j */
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
      pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    /* Update psi, omega, m and j2 */
    pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
    srli x3, x3, 1
    slli x2, x2, 1
    pq.srw 2, x4

  li x25, 0
  addi x23, x19, 1024

  /* store result to dmem */
  loopi 32, 2
    bn.sid x25++, 2048(x23)
    addi x23, x23, 32

  /* Merge - NTT Layer 512 */
  addi x24, x19, 0
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

  loopi 2, 19
    loopi 2, 15

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

      loopi 16, 3
        bn.sid x25++, 0(x23)
        bn.sid x26++, 1024(x23)
        addi x23, x23, 32

      li x25, 0
      li x26, 16

    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 

    addi x24, x24, 1024
    addi x23, x23, 1024

/* Update psi, omega, m and j2 */
pq.pqsru 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

/* Merge - NTT Layer 1024 */

  addi x24, x19, 0
  addi x23, x19, 0

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

  loopi 4, 18

    /* Load DMEM(0) into WDR w0*/
    loopi 16, 3
      bn.lid x25++, 0(x24)
      bn.lid x26++, 2048(x24)
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
      bn.sid x25++, 0(x23)
      bn.sid x26++, 2048(x23)
      addi x23, x23, 32

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

loopi 128, 10

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

  /* Load prime in w0 */
  la x4, prime
  li x3, 0
  bn.lid x3, 0(x4) 

  /* Compute Q/2 and store in w6 */
  bn.rshi w6, w7, w0 >> 1

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

    /* (Q-1)/2 - w */
    bn.sub w14, w6, w13
    bn.and w14, w8, w14

    /* (((Q-1)/2 - w) >> 31) */
    bn.rshi w14, w7, w14 >> 31

    /* Check Sign */
    bn.cmp w7, w14, FG0
    csrrw x14, 1984, x0
    andi x14, x14, 1

    /* If negative subtract Q from w */
    beq x14, x0, skip_mask2
    /* ToDo: What does this line do? */
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

/* Load bitmask in w8 */
la x4, bitmask32
li x3, 8
bn.lid x3, 0(x4) 

/* Initialize w7 as 0x00...0 */
li x3, 0
bn.xor w7, w7, w7

loopi 128, 30

  /* load s1 for s1 * s1 into WDR0 */
  bn.lid x3, 0(x19++)

  /* Square s1 and add to norm */

  /* Select current coefficient */
  bn.and w0, w8, w0

  /* s += (z * z) */
  bn.mulqacc.wo.z w24, w0.0, w0.0, 0
  bn.and w24, w8, w24
  bn.add w31, w31, w24

  /* ng |= s */
  bn.or w30, w31, w30

  /* Update coefficient to process */
  bn.or w0, w7, w0 >> 32

  loopi 7, 6
  
    /* Select current coefficient */
    bn.and w0, w8, w0

    /* s += (z * z) */
    bn.mulqacc.wo.z w24, w0.0, w0.0, 0
    bn.and w24, w8, w24
    bn.add w31, w31, w24

    /* ng |= s */
    bn.or w30, w31, w30

    /* Update coefficient to process */
    bn.or w0, w7, w0 >> 32

  /* load s2 for s2 * s2  into WDR0 */
  bn.lid x3, 0(x20++)

  /* Square s2 and add to norm */

  /* Select current coefficient */
  bn.and w0, w8, w0

  /* s += (z * z) */
  bn.mulqacc.wo.z w24, w0.0, w0.0, 0
  bn.and w24, w8, w24
  bn.add w31, w31, w24

  /* ng |= s */
  bn.or w30, w31, w30

  /* Update coefficient to process */
  bn.or w0, w7, w0 >> 32

  loopi 7, 6
  
    /* Select current coefficient */
    bn.and w0, w8, w0

    /* s += (z * z) */
    bn.mulqacc.wo.z w24, w0.0, w0.0, 0
    bn.and w24, w8, w24
    bn.add w31, w31, w24

    /* ng |= s */
    bn.or w30, w31, w30

    /* Update coefficient to process */
    bn.or w0, w7, w0 >> 32

  addi x31, x31, 1
  addi x31, x31, 2
  addi x31, x31, 3
  addi x31, x31, 4
  addi x31, x31, 5
  addi x31, x31, 6
  addi x31, x31, 7
  addi x31, x31, 8
  addi x31, x31, 9
  addi x31, x31, 10
  addi x31, x31, 11
  addi x31, x31, 12
  addi x31, x31, 13

  li x31, 15
  addi x31, x31, 1

  /* Check if norm exceeds bound */

  /* Load beta squared into w7 */
  la x2, l2bound
  li x3, 7
  bn.lid x3, 0(x2)

  bn.cmp w7, w30, FG0
  csrrw x14, 1984, x0
  andi x14, x14, 1

  /* If norm exceeds bound x14 is set to 0 */
  xori x14, x14, 1

  /* Write back w30 to check if norm was computed correctly */
  li x2, 30
  bn.sid x2, 0(x0)

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
  .word 0x539
  .word 0x2baf
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

omega1:
.word 0x299b
.word 0x2f04
.word 0x1edc
.word 0x1861
.word 0x21a6
.word 0x2bfe
.word 0x256d
.word 0x201d

psi0:
  .word 0x2baf
  .word 0x299b
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

psi1:
  .word 0x2f04
  .word 0x1edc
  .word 0x1861
  .word 0x21a6
  .word 0x2bfe
  .word 0x256d
  .word 0x201d
  .word 0xb72

inv_omega0:
  .quad 0x0000000000001b53
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

inv_omega1:
  .quad 0x0000000000001b53
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

inv_psi0:
  .quad 0x0000000000002f42
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

inv_psi1:
  .quad 0x0000000000002f42
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

n1:
  .quad 0x0000000000000eab
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

bitmask32:
  .word 0xFFFFFFFF

bitmask_extended: 
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

l2bound:
  .word 0x0430299A

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

s2_coef0:
.word 0x76
.word 0xffffff62
.word 0xffffffb8
.word 0xffffffd8
.word 0x10c
.word 0xffffff63
.word 0xffffff7a
.word 0xffffffc9
.word 0xfa
.word 0xffffffda
.word 0xffffff3f
.word 0xae
.word 0x48
.word 0xffffffb0
.word 0x87
.word 0xb9
.word 0x3c
.word 0xe2
.word 0x7b
.word 0xfffffef4
.word 0xe6
.word 0xffffff36
.word 0x29
.word 0x8c
.word 0x48
.word 0xffffff2f
.word 0xffffff6a
.word 0xde
.word 0xffffffee
.word 0xb2
.word 0xf5
.word 0xffffffb5
.word 0xffffffe6
.word 0xffffff94
.word 0xffffff4c
.word 0x50
.word 0xffffffa3
.word 0x72
.word 0xffffffb3
.word 0xffffffb1
.word 0xba
.word 0xffffff94
.word 0x8c
.word 0xffffffa9
.word 0x6a
.word 0xffffffdf
.word 0xffffffae
.word 0xffffff6b
.word 0x172
.word 0x8
.word 0xffffff5f
.word 0xe1
.word 0xffffffd1
.word 0xffffffe1
.word 0xffffff58
.word 0xffffffdf
.word 0xfffffec2
.word 0xffffffb6
.word 0xffffffc6
.word 0xffffff27
.word 0x82
.word 0xe6
.word 0xfffffec1
.word 0xf9
.word 0x1d
.word 0x33
.word 0xffffffed
.word 0xaa
.word 0x1e8
.word 0xfffffff1
.word 0x18
.word 0xffffffdd
.word 0xce
.word 0xffffff63
.word 0x81
.word 0xffffffc8
.word 0x1d2
.word 0x26
.word 0x6c
.word 0x9
.word 0xb2
.word 0xffffffb0
.word 0x138
.word 0xe1
.word 0xffffff33
.word 0xffffffa9
.word 0xffffff44
.word 0xfffffff1
.word 0x4f
.word 0xffffffbc
.word 0x16
.word 0xffffff30
.word 0xffffff18
.word 0xffffff37
.word 0x73
.word 0x32
.word 0xffffff48
.word 0xffffffde
.word 0x77
.word 0xb
.word 0x11b
.word 0xd9
.word 0xffffff9b
.word 0xffffffc4
.word 0x0
.word 0x54
.word 0xffffffee
.word 0x20
.word 0xffffff49
.word 0xfffffe84
.word 0xd3
.word 0x39
.word 0x47
.word 0x92
.word 0xed
.word 0xe6
.word 0x34
.word 0x13
.word 0xc0
.word 0xa
.word 0xffffffec
.word 0x6c
.word 0xffffffde
.word 0xef
.word 0xffffff7e
.word 0x14f
.word 0xffffff55
.word 0x5f
.word 0xffffff71
.word 0xffffff96
.word 0xffffffcf
.word 0xffffff77
.word 0x7f
.word 0xffffff2a
.word 0x49
.word 0xffffff2d
.word 0xa8
.word 0x5b
.word 0xb9
.word 0x33
.word 0x27
.word 0xfffffe9f
.word 0xffffffd9
.word 0xfffffff3
.word 0xffffff08
.word 0xffffffbe
.word 0x20
.word 0x5b
.word 0x17e
.word 0xffffff6c
.word 0x3c
.word 0x49
.word 0xfffffec5
.word 0xfffffffa
.word 0xd4
.word 0x4c
.word 0xffffff0a
.word 0x9a
.word 0xffffffae
.word 0xffffff65
.word 0x25
.word 0x4b
.word 0xfffffef7
.word 0x1d
.word 0xffffff30
.word 0x44
.word 0x17
.word 0x55
.word 0xf
.word 0xffffffaa
.word 0xffffffa5
.word 0xffffff91
.word 0xffffff8c
.word 0xffffffb6
.word 0x9c
.word 0x89
.word 0xffffffc7
.word 0xfffffff9
.word 0xffffff14
.word 0xb
.word 0x24
.word 0xffffffd1
.word 0x51
.word 0xffffff74
.word 0xffffffc8
.word 0x113
.word 0x115
.word 0x1e
.word 0x47
.word 0x66
.word 0xc2
.word 0xfffffe55
.word 0x121
.word 0xfffffff5
.word 0xffffffa0
.word 0x1b
.word 0xffffff6b
.word 0x14
.word 0xf5
.word 0xfffffebd
.word 0xffffffd6
.word 0xffffff6b
.word 0x57
.word 0xffffffc7
.word 0xfffffef3
.word 0xfffffefc
.word 0xffffffbb
.word 0x36
.word 0xffffffc1
.word 0x98
.word 0x4d
.word 0x5e
.word 0xc0
.word 0x81
.word 0xfffffec1
.word 0x5e
.word 0xffffffc9
.word 0x46
.word 0xffffffa2
.word 0x56
.word 0x8d
.word 0xffffff81
.word 0x17f
.word 0xffffffb8
.word 0xf
.word 0xd3
.word 0x40
.word 0xffffffbb
.word 0x18b
.word 0xffffffbf
.word 0x6b
.word 0x3
.word 0xc9
.word 0xe
.word 0x80
.word 0xffffff43
.word 0x3a
.word 0xffffffa0
.word 0xffffffd4
.word 0xfffffe2e
.word 0x7f
.word 0xed
.word 0xb8
.word 0xffffff82
.word 0xb2
.word 0xfffffeda
.word 0xffffffe7
.word 0x32
.word 0xd7
.word 0xffffff4a
.word 0xffffffd6
.word 0xffffff60
.word 0x11
.word 0x94
.word 0x1b
.word 0xffffffaf
.word 0xffffff28
.word 0xffffffe0
.word 0xfe
.word 0x103
.word 0x5f
.word 0xfffffe57
.word 0xffffffb1
.word 0xfffffe70
.word 0x4f
.word 0xffffff69
.word 0xffffffc4
.word 0xffffff57
.word 0x69
.word 0xfffffeb9
.word 0x5b
.word 0xfffffffd
.word 0xffffffcf
.word 0x85
.word 0xffffffeb
.word 0x47
.word 0x55
.word 0xffffff3a
.word 0xffffffc2
.word 0xfffffffd
.word 0xffffff2e
.word 0x7d
.word 0xffffff98
.word 0x5b
.word 0xffffff70
.word 0x44
.word 0x5d
.word 0xffffff4b
.word 0xffffff84
.word 0xc9
.word 0x7
.word 0xffffff8e
.word 0xffffff6c
.word 0xffffffc9
.word 0xffffff30
.word 0xffffff69
.word 0xab
.word 0xf2
.word 0x94
.word 0xffffff49
.word 0x174
.word 0x9d
.word 0x122
.word 0xffffff41
.word 0x82
.word 0xffffff63
.word 0xffffffbb
.word 0x6
.word 0xffffff22
.word 0x26
.word 0xca
.word 0xfffffff9
.word 0x4c
.word 0xffffff9b
.word 0xfffffffa
.word 0xffffffbd
.word 0x35
.word 0xfffffeb8
.word 0xfffffff8
.word 0x45
.word 0xcd
.word 0xffffffea
.word 0xfffffff1
.word 0xffffff6e
.word 0xfd
.word 0xffffff5b
.word 0xffffff03
.word 0xffffff2d
.word 0xffffffb4
.word 0x14
.word 0x6
.word 0xffffff93
.word 0x8c
.word 0x40
.word 0xffffffdd
.word 0x67
.word 0x10
.word 0xffffff4f
.word 0xb
.word 0xb6
.word 0xffffffd2
.word 0xffffffd6
.word 0xffffff8a
.word 0xc5
.word 0x7d
.word 0xfffffe88
.word 0xffffff5b
.word 0xf0
.word 0xffffff0e
.word 0x96
.word 0xa6
.word 0xffffffe1
.word 0xffffffd3
.word 0xffffffc7
.word 0xffffff7b
.word 0xffffff62
.word 0xffffff37
.word 0xffffff7d
.word 0xffffffe6
.word 0x131
.word 0xffffff3e
.word 0xffffffe2
.word 0xffffff73
.word 0xffffff31
.word 0x99
.word 0xf
.word 0xffffffad
.word 0x7d
.word 0xffffffa2
.word 0xffffff6b
.word 0xbe
.word 0xffffffec
.word 0x73
.word 0x161
.word 0xffffff53
.word 0xffffff7f
.word 0xffffff02
.word 0x55
.word 0xffffff7c
.word 0xb5
.word 0x164
.word 0xfffffef2
.word 0xffffffcb
.word 0xfffffe8d
.word 0xfffffec5
.word 0x2c
.word 0x1b
.word 0x46
.word 0xffffff13
.word 0x27
.word 0xffffffd3
.word 0xfffffef4
.word 0xffffffb8
.word 0xfffffec0
.word 0x2d
.word 0xffffff5a
.word 0x57
.word 0x1c6
.word 0x92
.word 0x8d
.word 0xffffff8b
.word 0xfffffff2
.word 0x27
.word 0xffffff8e
.word 0xffffff6f
.word 0xffffffbd
.word 0xffffffb9
.word 0x7e
.word 0xfffffff8
.word 0x1d7
.word 0x100
.word 0xffffff62
.word 0xffffff46
.word 0xffffffa5
.word 0x4c
.word 0xffffff75
.word 0xffffff43
.word 0xffffff1c
.word 0xffffff47
.word 0xfffffffd
.word 0xffffffa2
.word 0xffffff74
.word 0xc0
.word 0x117
.word 0x61
.word 0xffffffc9
.word 0x19
.word 0xffffffb1
.word 0x8a
.word 0x4c
.word 0x61
.word 0xffffff66
.word 0xffffffb4
.word 0xa3
.word 0x75
.word 0x9
.word 0xffffffb5
.word 0x81
.word 0x66
.word 0x117
.word 0xffffffd1
.word 0xffffff9c
.word 0xffffff8e
.word 0x7c
.word 0x7f
.word 0x2
.word 0xfffffef8
.word 0xe8
.word 0x120
.word 0xfffffebd
.word 0xa2
.word 0xffffffea
.word 0xffffff7d
.word 0xd1
.word 0xffffff28
.word 0xffffff26
.word 0x16
.word 0xfffffedc
.word 0x101
.word 0x125
.word 0x27
.word 0x1bb
.word 0x127
.word 0xffffff58
.word 0xffffffbe
.word 0xffffffc6
.word 0x29
.word 0xffffff8b
.word 0x49
.word 0x6b
.word 0xffffff70
.word 0xbd
.word 0xffffff07
.word 0xffffff1c
.word 0x5
.word 0xffffff6a
.word 0x1d
.word 0xb2
.word 0xc0
.word 0xffffffeb
.word 0xffffffc8
.word 0xffffff20
.word 0x84
.word 0xffffff27
.word 0xffffff77
.word 0xfffffffa
.word 0xffffff4d
.word 0x1b
.word 0x1e
.word 0xffffffcf
.word 0xffffff48
.word 0xfffffff8
.word 0xe5
.word 0xfffffee7
.word 0x5
.word 0x2b
.word 0xaa
.word 0xfffffff6
.word 0x15
.word 0xffffffe8
.word 0xffffffe8
.word 0x7e
.word 0xfffffef4
.word 0x40
.word 0x29
.word 0xffffff52
.word 0x21
.word 0xffffff53
.word 0x54
.word 0xfffffff7
.word 0xffffffd7
.word 0x4
.word 0xffffffc7
.word 0x7d
.word 0xffffff5c
.word 0x16d
.word 0x84
.word 0x4
.word 0xffffff52
.word 0xffffff91
.word 0x4d
.word 0x116
.word 0x40
.word 0xed
.word 0xffffff61
.word 0xfffffffe
.word 0xffffffb3
.word 0x66
.word 0xfffffff1
.word 0xfffffef4
.word 0xc8
.word 0xffffff92
.word 0xffffff26
.word 0xfffffff0
.word 0x54
.word 0x9f
.word 0xffffffb6
.word 0xffffffe7
.word 0x91
.word 0xffffff28
.word 0xfffffeed
.word 0xffffffe4
.word 0xffffffda
.word 0xffffff80
.word 0xffffff5d
.word 0xb2
.word 0xffffffc9
.word 0xb0
.word 0xffffffef
.word 0x28
.word 0x5a
.word 0x7d
.word 0xffffffe5
.word 0xc
.word 0xffffffb6
.word 0xffffffa6
.word 0xffffffe9
.word 0xd
.word 0xfffffef0
.word 0x4a
.word 0x43
.word 0xfffffefd
.word 0xffffff7b
.word 0x66
.word 0x99
.word 0x6c
.word 0x34
.word 0x18
.word 0x51
.word 0x17
.word 0x118
.word 0xd8
.word 0xb4
.word 0xffffffab
.word 0x3e
.word 0xd0
.word 0x4c
.word 0x30
.word 0x101
.word 0xffffff2e
.word 0x21
.word 0x168
.word 0x3d
.word 0xb6
.word 0x3c
.word 0xc4
.word 0xf3
.word 0xfffffe78
.word 0xdf
.word 0xffffffd2
.word 0x1b
.word 0xfffffedd
.word 0xfa
.word 0xa2
.word 0xffffff58
.word 0xffffffc2
.word 0x108
.word 0xffffff27
.word 0x0
.word 0x32
.word 0x118
.word 0xffffff77
.word 0xffffff54
.word 0xffffffc1
.word 0xffffff04
.word 0xffffffb0
.word 0xffffff9e
.word 0x9b
.word 0xfffffff9
.word 0xdb
.word 0xffffffde
.word 0xfd
.word 0x1a
.word 0x37
.word 0x13
.word 0x14d
.word 0xffffffd0
.word 0xf4
.word 0x93
.word 0xa2
.word 0xfffffe7e
.word 0xffffffd2
.word 0x50
.word 0xffffffac
.word 0x14
.word 0xffffff97
.word 0xfffffffd
.word 0xffffffb1
.word 0xd1
.word 0x2d
.word 0xe
.word 0x71
.word 0x52
.word 0x6a
.word 0x4a
.word 0xfffffff7
.word 0xffffff48
.word 0xffffff7b
.word 0xffffff92
.word 0x5d
.word 0xffffff50
.word 0x71
.word 0xffffff9a
.word 0x13
.word 0x39
.word 0xffffff89
.word 0x3d
.word 0x65
.word 0x10c
.word 0xffffff03
.word 0xd4
.word 0xffffff7f
.word 0xffffff8f
.word 0xffffff6c
.word 0xffffff3d
.word 0xffffffbb
.word 0x20
.word 0x18
.word 0x58
.word 0x155
.word 0x5d
.word 0xffffff25
.word 0xffffffe7
.word 0xffffffab
.word 0xffffff8f
.word 0xbf
.word 0xfffffe0e
.word 0xffffff49
.word 0xe
.word 0xffffff3e
.word 0x25
.word 0x92
.word 0x60
.word 0xffffff38
.word 0x60
.word 0xde
.word 0x6b
.word 0x33
.word 0x63
.word 0xf8
.word 0xffffff9e
.word 0xb9
.word 0xe9
.word 0xfffffe9a
.word 0x44
.word 0xffffff9e
.word 0x9b
.word 0x6e
.word 0xe3
.word 0x9d
.word 0xffffff56
.word 0x93
.word 0xffffffc8
.word 0x7c
.word 0xfffffff5
.word 0x9a
.word 0x1
.word 0xffffff87
.word 0xffffffa3
.word 0x7d
.word 0xc6
.word 0xffffffdf
.word 0x42
.word 0x88
.word 0xffffff87
.word 0x73
.word 0x42
.word 0xffffff33
.word 0x4c
.word 0x38
.word 0x158
.word 0x3c
.word 0xba
.word 0x12c
.word 0xffffff90
.word 0xffffffdf
.word 0xffffff46
.word 0xb0
.word 0xffffff2a
.word 0x0
.word 0x76
.word 0xffffff6d
.word 0x6e
.word 0x16
.word 0xfffffff8
.word 0x28
.word 0xb9
.word 0x115
.word 0x8
.word 0xffffff24
.word 0xae
.word 0x38
.word 0x15a
.word 0xffffffd0
.word 0x63
.word 0xc5
.word 0x5a
.word 0x87
.word 0x9f
.word 0xfffffe49
.word 0xe8
.word 0xffffffb6
.word 0x5f
.word 0x149
.word 0xfffffee8
.word 0xfffffee8
.word 0x9
.word 0xffffffaa
.word 0xffffff6c
.word 0xffffffb5
.word 0xffffff80
.word 0xffffff46
.word 0xffffffe6
.word 0x5b
.word 0xfffffeee
.word 0x9a
.word 0xf7
.word 0x68
.word 0x80
.word 0xffffffbd
.word 0xfffffee5
.word 0x54
.word 0xffffff8a
.word 0xffffffb4
.word 0xffffff6e
.word 0x9a
.word 0x4f
.word 0xfffffff0
.word 0x51
.word 0xffffff48
.word 0x5b
.word 0xffffffd3
.word 0x74
.word 0xffffff7b
.word 0x9b
.word 0xa0
.word 0xfc
.word 0xd
.word 0x5a
.word 0xc
.word 0x87
.word 0xb0
.word 0xa1
.word 0xffffffe9
.word 0xffffffa7
.word 0xffffff94
.word 0xa1
.word 0xffffffab
.word 0xffffff57
.word 0xffffffda
.word 0x5c
.word 0xffffff3a
.word 0x104
.word 0xffffff96
.word 0xc
.word 0x6f
.word 0xffffffd1
.word 0x12b
.word 0x8b
.word 0xb9
.word 0xffffffc4
.word 0xffffffd0
.word 0xfffffffb
.word 0xffffff88
.word 0xffffffa4
.word 0xfffffeb2
.word 0x161
.word 0x92
.word 0xffffff22
.word 0x53
.word 0x64
.word 0x136
.word 0x6c
.word 0x2e
.word 0xc4
.word 0xffffffe1
.word 0xffffff15
.word 0xffffffde
.word 0x88
.word 0xfffffeca
.word 0xce
.word 0xfffffe94
.word 0x95
.word 0x2
.word 0x2d
.word 0x42
.word 0xffffff6e
.word 0x25
.word 0xfa
.word 0x7d
.word 0x22
.word 0xa1
.word 0xffffffae
.word 0xa
.word 0xffffffed
.word 0x1c
.word 0xffffff68
.word 0xfffffef3
.word 0x54
.word 0xffffffa3
.word 0xf0
.word 0xffffffc6
.word 0x27
.word 0xffffff90
.word 0xffffff7f
.word 0xffffff70
.word 0x4e
.word 0xa2
.word 0x46
.word 0x7b
.word 0x64
.word 0x144
.word 0xa3
.word 0xffffff72
.word 0xffffff6f
.word 0x75
.word 0x28
.word 0x29
.word 0xfffffff4
.word 0x61
.word 0xffffff4f
.word 0xffffff19
.word 0xffffff1f
.word 0x7e
.word 0x106
.word 0xffffff5c
.word 0xb4
.word 0xa2
.word 0xffffff2b
.word 0xffffff18
.word 0xa
.word 0xb7
.word 0xfffffff4
.word 0x6
.word 0x54
.word 0x2f
.word 0x3f
.word 0x1a
.word 0xffffff6e
.word 0x1a3
.word 0xffffffd1
.word 0xffffff98
.word 0xffffffb2
.word 0x3
.word 0x5a
.word 0xffffff55
.word 0xffffffe8
.word 0xffffff21
.word 0xffffff94
.word 0xffffffaa
.word 0xffffff69
.word 0x37
.word 0xffffff7f
.word 0xfffffec6
.word 0xc5
.word 0x55
.word 0xffffff8f
.word 0xfffffe7e
.word 0xfffffff7
.word 0x7a
.word 0xf4
.word 0xffffff40
.word 0xffffffbf
.word 0xfffffff7
.word 0x4d
.word 0xfffffef3
.word 0xfffffff8
.word 0x4
.word 0xfffffeef
.word 0xe9
.word 0x91
.word 0x15f
.word 0x93
.word 0xffffff62
.word 0xffffff05
.word 0x6e
.word 0xffffff50
.word 0xffffff45
.word 0xc2
.word 0xfffffff1
.word 0xfffffee2
.word 0xb
.word 0xffffffa5
.word 0xffffff4c
.word 0xffffffaf
.word 0xfffffea0
.word 0xf
.word 0xaa
.word 0xab
.word 0xe8
.word 0x2e
.word 0x3c
.word 0x9
.word 0xfffffffb
.word 0xffffffd1
.word 0x148
.word 0x53
.word 0x58
.word 0xffffff9d
.word 0x64
.word 0xffffffaf
.word 0xffffff9f
.word 0xffffff49
.word 0xffffffc2
.word 0xffffff6e
.word 0x17f
.word 0x164
.word 0x7
.word 0x58
.word 0xffffff8f
.word 0xffffffa4
.word 0x4c
.word 0xa5
.word 0xef
.word 0xffffff97
.word 0xffffff87
.word 0xffffffae
.word 0xffffff9d
.word 0xffffff61
.word 0x11
.word 0x107
.word 0xfffffff5
.word 0xffffffd2
.word 0xffffffd1
.word 0x56
.word 0xf1
.word 0xe0
.word 0xffffffd1
.word 0xd5
.word 0x60
.word 0xffffff8e
.word 0x14b
.word 0xffffff17
.word 0xffffffed
.word 0xffffffff
.word 0x7
.word 0xffffff18
.word 0xe7
.word 0xffffffc9
.word 0xae
.word 0x1c
.word 0x93
.word 0xfffffef6
.word 0xffffff0d
.word 0xffffffcd
.word 0x1e1
.word 0xffffffd3
.word 0x32
.word 0x4a
.word 0xffffff12
.word 0x18
.word 0xffffff23
.word 0xffffffe9
.word 0xffffff07
.word 0x22
.word 0xffffffee
.word 0x4a
.word 0xffffff94
.word 0xffffff80
.word 0x69
.word 0xffffff8d
.word 0xe7
.word 0xffffffde
.word 0x13
.word 0x5b
.word 0xffffff74
.word 0xffffffc0
.word 0xba
.word 0xffffffa7
.word 0xffffff6e
.word 0x3
.word 0x81
.word 0xffffffd1
.word 0xffffffd4
.word 0x2a
.word 0x5
.word 0x96
.word 0x18d
.word 0x61
.word 0x33
.word 0xffffff8e
.word 0xffffff17
.word 0xffffffc3
.word 0xffffff20

h_coef0: 
.word 0x26a1
.word 0xaa6
.word 0x246d
.word 0x1fbc
.word 0x1c68
.word 0x2d9b
.word 0x2b37
.word 0x60d
.word 0x1e3b
.word 0x2e2b
.word 0x259c
.word 0x2b4a
.word 0x1f00
.word 0x229e
.word 0x78d
.word 0x280c
.word 0x1569
.word 0x10c8
.word 0x2e40
.word 0x14a8
.word 0x1cbd
.word 0x1493
.word 0x2b77
.word 0x9de
.word 0x2dfb
.word 0x11b8
.word 0x2151
.word 0x17dc
.word 0x70e
.word 0x2d8f
.word 0x13c0
.word 0x2ef6
.word 0x2b9c
.word 0x1150
.word 0x3e6
.word 0xc14
.word 0x110f
.word 0x2a1c
.word 0x2b1d
.word 0x17a9
.word 0x297f
.word 0x1da9
.word 0x1d46
.word 0x2fe0
.word 0x1ded
.word 0x11f7
.word 0x29f1
.word 0x1b92
.word 0x2a4e
.word 0x284d
.word 0x1bf9
.word 0x185b
.word 0x1fc2
.word 0x28b1
.word 0xc71
.word 0x14fd
.word 0xbb1
.word 0x10fe
.word 0xec5
.word 0x241
.word 0x2873
.word 0x394
.word 0x906
.word 0x1c52
.word 0x2bc2
.word 0x18a6
.word 0x623
.word 0x90f
.word 0x1f63
.word 0x21d9
.word 0x86e
.word 0x2503
.word 0x1aa3
.word 0x435
.word 0x1418
.word 0x1bb4
.word 0x1c5e
.word 0x1701
.word 0x11aa
.word 0x2b01
.word 0x1b0
.word 0x1a59
.word 0xb61
.word 0x2428
.word 0x425
.word 0x459
.word 0x1697
.word 0x22d9
.word 0x4a1
.word 0x9b0
.word 0x79d
.word 0x22c4
.word 0x2312
.word 0x1498
.word 0x2317
.word 0xa14
.word 0x19ac
.word 0xcd
.word 0x1b9e
.word 0x2ddb
.word 0x11d4
.word 0x226c
.word 0x1327
.word 0x18e0
.word 0x1169
.word 0x2797
.word 0x20cd
.word 0x2ebb
.word 0x29c9
.word 0x2837
.word 0x29f5
.word 0x2148
.word 0x2b82
.word 0x2ce
.word 0x264d
.word 0x19d2
.word 0x103e
.word 0x26c9
.word 0x1c2d
.word 0x1ad1
.word 0x1cbf
.word 0x8b6
.word 0x2e38
.word 0x219a
.word 0x198e
.word 0x10df
.word 0xcd2
.word 0x103b
.word 0x2cac
.word 0x2cfe
.word 0x89d
.word 0x1fab
.word 0x1f70
.word 0x1aed
.word 0x2b33
.word 0x1f32
.word 0x36c
.word 0x16d0
.word 0x2697
.word 0xfab
.word 0x292c
.word 0x1285
.word 0x270a
.word 0x2fbd
.word 0x24cf
.word 0x239f
.word 0x71e
.word 0x2a73
.word 0x35d
.word 0x154b
.word 0x2b03
.word 0x1b2d
.word 0xc5c
.word 0x2c29
.word 0x2793
.word 0x213d
.word 0x1fea
.word 0x23bb
.word 0x2d58
.word 0x1398
.word 0x270a
.word 0x283a
.word 0x2c6b
.word 0x281d
.word 0x9ed
.word 0x24a2
.word 0x104
.word 0x1f36
.word 0x4ab
.word 0x1fc0
.word 0x1aed
.word 0xac0
.word 0x2d1a
.word 0x2bb3
.word 0x2670
.word 0xb10
.word 0x1dd1
.word 0x2f7a
.word 0x13fd
.word 0x2d46
.word 0x108f
.word 0xe3
.word 0x1995
.word 0x20ff
.word 0x1c99
.word 0x190b
.word 0x1fe9
.word 0x2c14
.word 0x2c7d
.word 0x20dc
.word 0x288b
.word 0x20dc
.word 0xc90
.word 0x13d5
.word 0xe34
.word 0x171e
.word 0x10bf
.word 0x2544
.word 0x37e
.word 0x9fc
.word 0x2057
.word 0x2f91
.word 0x207
.word 0x2313
.word 0x203c
.word 0x2fd8
.word 0xa0
.word 0x28e4
.word 0x22a1
.word 0x605
.word 0x148a
.word 0x1d63
.word 0x265
.word 0x1696
.word 0x2f46
.word 0xe2f
.word 0x341
.word 0x2f70
.word 0x974
.word 0x1b3b
.word 0x28d8
.word 0x2bcc
.word 0x333
.word 0x204f
.word 0x600
.word 0x2cfa
.word 0x254d
.word 0x2b43
.word 0x2256
.word 0x910
.word 0xf51
.word 0x2c74
.word 0x692
.word 0x4f1
.word 0x18cb
.word 0xc2
.word 0xd7f
.word 0x387
.word 0xd9d
.word 0x4db
.word 0x1939
.word 0x2f1
.word 0x14d5
.word 0x20c8
.word 0x18d
.word 0x11c6
.word 0x20a2
.word 0x2ea9
.word 0x72f
.word 0x2dce
.word 0x1ee9
.word 0x106b
.word 0x222b
.word 0x2feb
.word 0x221d
.word 0x2d38
.word 0x21f0
.word 0x1767
.word 0x1670
.word 0x119f
.word 0x21d4
.word 0x145a
.word 0x28f2
.word 0x14c0
.word 0x175a
.word 0x1afd
.word 0x83
.word 0x1ae4
.word 0xd1a
.word 0x1473
.word 0x24e1
.word 0x217c
.word 0x25d9
.word 0x1b65
.word 0xc9d
.word 0x6b1
.word 0xd4f
.word 0x1465
.word 0xc2a
.word 0x5ae
.word 0x1fee
.word 0x2327
.word 0x8ef
.word 0xb3e
.word 0x165d
.word 0x94b
.word 0x8bf
.word 0x2343
.word 0x19f0
.word 0x23b6
.word 0x11ad
.word 0x677
.word 0x1412
.word 0x20a2
.word 0x2fb6
.word 0x1234
.word 0x1c07
.word 0xb7e
.word 0x171a
.word 0x5f4
.word 0x196b
.word 0x1a94
.word 0x227b
.word 0xf7e
.word 0x24ac
.word 0x168f
.word 0xc75
.word 0x33f
.word 0x2d45
.word 0x2162
.word 0x1a8e
.word 0x15e9
.word 0xe90
.word 0x2414
.word 0x1929
.word 0x1b87
.word 0x1c77
.word 0x12ae
.word 0x2925
.word 0x2659
.word 0xaa8
.word 0xa6d
.word 0x2d54
.word 0x117
.word 0x29db
.word 0x28fe
.word 0x2e78
.word 0x26e
.word 0x2918
.word 0x4b5
.word 0x2ea1
.word 0x1dc0
.word 0x2a31
.word 0x27f6
.word 0x2f77
.word 0x171a
.word 0x2408
.word 0x1daa
.word 0x2b39
.word 0x14d0
.word 0xf1a
.word 0x1913
.word 0x1c7e
.word 0x65a
.word 0x2c5d
.word 0x2611
.word 0x1f86
.word 0x24f7
.word 0x24bb
.word 0x2807
.word 0x162
.word 0xa8f
.word 0x34d
.word 0x21e8
.word 0x2a08
.word 0x1d3
.word 0x10bb
.word 0x1c08
.word 0x12a3
.word 0xb01
.word 0x6fe
.word 0x2b10
.word 0x114
.word 0x63b
.word 0x12b0
.word 0x227d
.word 0x221a
.word 0xa2
.word 0x13d7
.word 0x1d41
.word 0x2729
.word 0x2152
.word 0x14bb
.word 0xf23
.word 0x27a7
.word 0xcd4
.word 0xf76
.word 0x703
.word 0xd2c
.word 0x1fb5
.word 0xda4
.word 0x1ed0
.word 0x2815
.word 0x109e
.word 0x125e
.word 0x188c
.word 0x2ce2
.word 0x21e7
.word 0x866
.word 0xd1b
.word 0x11b3
.word 0x1121
.word 0x14b7
.word 0x1c03
.word 0x192
.word 0x537
.word 0x20a1
.word 0x7b1
.word 0xe2c
.word 0x1b31
.word 0x1f6b
.word 0x1645
.word 0xef3
.word 0x1b7b
.word 0x1aad
.word 0x171c
.word 0x695
.word 0x2ac1
.word 0x1382
.word 0x1073
.word 0x55a
.word 0x9fb
.word 0x2731
.word 0x491
.word 0x2776
.word 0xfd1
.word 0xbf4
.word 0x1277
.word 0x1b8
.word 0x2c79
.word 0x1fe9
.word 0x125d
.word 0xda
.word 0x1262
.word 0x27ac
.word 0x307
.word 0x22e6
.word 0x1185
.word 0x181c
.word 0xd07
.word 0x2365
.word 0x10fe
.word 0x28cc
.word 0x1533
.word 0x1318
.word 0x2de1
.word 0x2d0e
.word 0x1e2a
.word 0x16c4
.word 0x14cf
.word 0x28f6
.word 0x88f
.word 0xe49
.word 0x79b
.word 0xea8
.word 0x1cb
.word 0x1074
.word 0x8cc
.word 0x2543
.word 0xcf3
.word 0x270e
.word 0xbe1
.word 0x2d2f
.word 0x68
.word 0x15ca
.word 0x125b
.word 0x1745
.word 0x2868
.word 0x9a3
.word 0x7f5
.word 0x2b5f
.word 0xc94
.word 0x1c31
.word 0x19d9
.word 0x171f
.word 0x15fe
.word 0xb5d
.word 0x172
.word 0x395
.word 0x2a4d
.word 0x1730
.word 0x256e
.word 0x146f
.word 0x23f7
.word 0x0
.word 0x50
.word 0x2f30
.word 0x2c
.word 0xbcf
.word 0x7c
.word 0xa7
.word 0x175a
.word 0x2e32
.word 0x23bc
.word 0x3bb
.word 0x271
.word 0x1789
.word 0x1ba5
.word 0x100e
.word 0x2915
.word 0x2421
.word 0x170e
.word 0x1a41
.word 0xb1e
.word 0x2f9a
.word 0x1af7
.word 0x3c7
.word 0x2080
.word 0x21d6
.word 0x1e1b
.word 0x1473
.word 0x89e
.word 0x2b21
.word 0x43c
.word 0xf87
.word 0x87a
.word 0x1b7c
.word 0x116e
.word 0x254e
.word 0x176f
.word 0x680
.word 0x1909
.word 0x2496
.word 0x2a9
.word 0x263f
.word 0x195a
.word 0x2d46
.word 0xee
.word 0x26e0
.word 0x272b
.word 0x1023
.word 0x1416
.word 0x2784
.word 0x28a2
.word 0x1080
.word 0xd90
.word 0x2157
.word 0x161f
.word 0xb08
.word 0x1812
.word 0x2c58
.word 0xebf
.word 0x29dc
.word 0x288e
.word 0x715
.word 0x1c7a
.word 0x171b
.word 0xe15
.word 0x1315
.word 0x990
.word 0x1f59
.word 0x168b
.word 0x726
.word 0xc6
.word 0x1af7
.word 0x1b33
.word 0x10a7
.word 0xad1
.word 0x6e8
.word 0x1b30
.word 0x2892
.word 0x2d08
.word 0x23ad
.word 0x2941
.word 0x7f9
.word 0x2e95
.word 0xd0a
.word 0x2028
.word 0xbe2
.word 0x1c85
.word 0x1c36
.word 0x2d3d
.word 0x101c
.word 0xc55
.word 0x18a2
.word 0x24a3
.word 0x1c13
.word 0x1923
.word 0x1a53
.word 0x2065
.word 0x26e2
.word 0x1e9e
.word 0x21e6
.word 0x12dc
.word 0x198d
.word 0x1acd
.word 0x1d03
.word 0xa9b
.word 0xded
.word 0x2c45
.word 0x184
.word 0x2fb3
.word 0x1f94
.word 0x1494
.word 0xd36
.word 0x8e2
.word 0x79d
.word 0x2a91
.word 0xb62
.word 0x290d
.word 0x16ed
.word 0x5a5
.word 0x685
.word 0x2be6
.word 0x271
.word 0x2f52
.word 0x2fa6
.word 0x2f6b
.word 0xddb
.word 0x746
.word 0x2c2a
.word 0x2982
.word 0x5f9
.word 0x1ee2
.word 0x75e
.word 0x2e63
.word 0x1714
.word 0x266a
.word 0x808
.word 0x2592
.word 0x221d
.word 0x2118
.word 0xe9a
.word 0xc9d
.word 0x4ce
.word 0x2db6
.word 0x13af
.word 0x1f61
.word 0x2959
.word 0x619
.word 0x2a58
.word 0x271
.word 0x12ca
.word 0x278d
.word 0x131e
.word 0xc61
.word 0x2833
.word 0x22c2
.word 0xea8
.word 0x598
.word 0xa1e
.word 0x2734
.word 0x2af5
.word 0x1a79
.word 0x2389
.word 0x785
.word 0x27ca
.word 0x1396
.word 0x1526
.word 0x2e34
.word 0x194a
.word 0x1f45
.word 0x36d
.word 0x4ae
.word 0xdb3
.word 0x8c0
.word 0x1871
.word 0xbc3
.word 0x1bc3
.word 0x17fa
.word 0x908
.word 0x2fd4
.word 0xd18
.word 0x2846
.word 0x16ce
.word 0x21ed
.word 0x2118
.word 0x5cb
.word 0x41f
.word 0x2b08
.word 0x655
.word 0xbb6
.word 0x2862
.word 0x75f
.word 0x1bc7
.word 0x2021
.word 0x720
.word 0x2ea9
.word 0x7fb
.word 0x2e6a
.word 0x1de2
.word 0x2a5
.word 0x2f32
.word 0xd6b
.word 0x25d9
.word 0xef5
.word 0x12ea
.word 0x11a2
.word 0x1331
.word 0x1c42
.word 0x2e8
.word 0x927
.word 0x2df4
.word 0x2fca
.word 0x1edd
.word 0x26de
.word 0x2a7b
.word 0x1501
.word 0x2a80
.word 0xf7a
.word 0x29e6
.word 0x974
.word 0x1028
.word 0x2410
.word 0x2fe6
.word 0x1967
.word 0x49
.word 0x20e5
.word 0x1749
.word 0x15dc
.word 0x2264
.word 0x18fc
.word 0x432
.word 0x16ba
.word 0xbb2
.word 0x1f6f
.word 0xf0
.word 0x925
.word 0x465
.word 0x7ee
.word 0x24a4
.word 0xd17
.word 0x2e16
.word 0xc2f
.word 0x1bdd
.word 0x140d
.word 0x224e
.word 0x1844
.word 0x14d5
.word 0x157b
.word 0x20a2
.word 0x25a
.word 0x17d1
.word 0xe1b
.word 0x1fc3
.word 0x60f
.word 0x2605
.word 0x15de
.word 0xaa7
.word 0x1f87
.word 0x266d
.word 0x810
.word 0x2099
.word 0x1f91
.word 0x119e
.word 0x103a
.word 0x2565
.word 0x27ef
.word 0x227
.word 0x1e28
.word 0xc4d
.word 0x93
.word 0x6a4
.word 0xf27
.word 0x2597
.word 0x1fd4
.word 0x2cf0
.word 0x1ffa
.word 0x236e
.word 0x1b4c
.word 0xb0e
.word 0x2db
.word 0x2614
.word 0xc39
.word 0x1103
.word 0x1d1c
.word 0x2d06
.word 0x1e7c
.word 0x2e
.word 0x2fc4
.word 0x46c
.word 0x2a69
.word 0x1021
.word 0x1cdc
.word 0x36
.word 0x1d9
.word 0xb09
.word 0xca8
.word 0x1ffb
.word 0x10b0
.word 0x1c50
.word 0x9b9
.word 0x2212
.word 0x251f
.word 0xa0
.word 0x2293
.word 0x1d55
.word 0x6c1
.word 0x1ae
.word 0x1cae
.word 0xa04
.word 0x221c
.word 0x2391
.word 0x5d0
.word 0xb4e
.word 0xdf1
.word 0xb0
.word 0x9f0
.word 0x1afb
.word 0x22e2
.word 0x1788
.word 0x1483
.word 0x1a18
.word 0x1ba7
.word 0x161a
.word 0x523
.word 0x220b
.word 0xa5a
.word 0x2183
.word 0x1c02
.word 0x2a68
.word 0x124b
.word 0x1248
.word 0x145a
.word 0x2de
.word 0x2238
.word 0x1dde
.word 0x71c
.word 0xc72
.word 0xce7
.word 0x715
.word 0x26bc
.word 0x2d7f
.word 0x97b
.word 0x275b
.word 0x1091
.word 0x1e79
.word 0x7b7
.word 0x1bcf
.word 0x1d
.word 0x2ebf
.word 0x2f63
.word 0x2ed6
.word 0x99
.word 0x11f7
.word 0x1586
.word 0xfd0
.word 0xf0
.word 0x37a
.word 0x7e6
.word 0x1012
.word 0x2859
.word 0x408
.word 0x312
.word 0x1f03
.word 0x558
.word 0x33
.word 0x25ee
.word 0x2925
.word 0x1302
.word 0x1903
.word 0x21a6
.word 0x43d
.word 0x1362
.word 0x866
.word 0x1d6a
.word 0x2e4d
.word 0x2208
.word 0xe4e
.word 0x1fe6
.word 0x1354
.word 0x26ec
.word 0x271f
.word 0x1234
.word 0x2b
.word 0xe4d
.word 0x2148
.word 0x2ffa
.word 0x2ec1
.word 0x7a9
.word 0x2b6d
.word 0x2ce0
.word 0x251a
.word 0x22a5
.word 0x2ee3
.word 0x2f3
.word 0x414
.word 0x27cc
.word 0xa1c
.word 0xe90
.word 0xe4d
.word 0x26ef
.word 0x3ca
.word 0x1470
.word 0x16fa
.word 0x2597
.word 0x2bb6
.word 0xf5c
.word 0x2fe1
.word 0x1334
.word 0x15b7
.word 0x23da
.word 0x177d
.word 0x22a3
.word 0xa09
.word 0x6e0
.word 0x2ae9
.word 0x2835
.word 0x404
.word 0x8ed
.word 0xeb3
.word 0x17a0
.word 0x23dc
.word 0x7
.word 0xb69
.word 0x1c0a
.word 0x28b8
.word 0x2017
.word 0x967
.word 0x197c
.word 0x181c
.word 0x1055
.word 0x23f
.word 0x346
.word 0x1320
.word 0x23ff
.word 0x396
.word 0x2d69
.word 0x2a22
.word 0x2580
.word 0x28d
.word 0xf5b
.word 0x26e0
.word 0x10f0
.word 0x2a22
.word 0x1b48
.word 0x1851
.word 0x2fc
.word 0x1335
.word 0x4d0
.word 0x2e18
.word 0x6a2
.word 0x546
.word 0x791
.word 0x1594
.word 0x2ec1
.word 0x1066
.word 0x141b
.word 0x2c
.word 0x15c9
.word 0xc1a
.word 0xcb6
.word 0xa39
.word 0x260a
.word 0x1896
.word 0x2d96
.word 0x209e
.word 0x1e69
.word 0x221a
.word 0x2514
.word 0x25ca
.word 0x231d
.word 0x2dcf
.word 0x2bc
.word 0x382
.word 0x109c
.word 0x1b7d
.word 0x2d02
.word 0x210c
.word 0x6bd
.word 0x1547
.word 0x1bfa
.word 0xcc6
.word 0x78d
.word 0x1265
.word 0x233
.word 0x2e1f
.word 0x294a
.word 0xc7c
.word 0x7c3
.word 0x2e36
.word 0x2e88
.word 0x2ee0
.word 0x2490
.word 0x23f1
.word 0x550
.word 0x2d1f
.word 0x5d2
.word 0x1dde
.word 0x23ad
.word 0xc9
.word 0x139b
.word 0x1e23
.word 0x163d
.word 0x894
.word 0x1313
.word 0x2f6f
.word 0xeb8
.word 0x25f1
.word 0x287d
.word 0x1f18
.word 0x2054
.word 0x2692
.word 0x1fd0
.word 0x2416
.word 0x2b0d
.word 0xf85
.word 0x1060
.word 0x27c4
.word 0x1c0d
.word 0xb58
.word 0x137e
.word 0x150b
.word 0x343
.word 0xe4c
.word 0xa22
.word 0xcd6
.word 0x3b6
.word 0x2969
.word 0x2f7a
.word 0x8bb
.word 0x2a58
.word 0x261a
.word 0xeb5
.word 0x2917
.word 0xfac
.word 0x11b4
.word 0x17b8
.word 0x4e1
.word 0x126a
.word 0x7a5
.word 0xb5f
.word 0x2d54
.word 0x2551
.word 0x1574
.word 0x160d
.word 0x127e
.word 0x9ed
.word 0x2651
.word 0x20bc
.word 0x105
.word 0x119c
.word 0xf18
.word 0x2441

c0_coef0: 
.word 0xdd2
.word 0x2229
.word 0xb58
.word 0xb99
.word 0xb8
.word 0x1624
.word 0x231
.word 0x184e
.word 0x2858
.word 0x2be2
.word 0x1f0d
.word 0x1f85
.word 0x252c
.word 0x11ad
.word 0x1ca8
.word 0x25e2
.word 0xd1f
.word 0x1f43
.word 0xf0c
.word 0x175
.word 0x2b34
.word 0x1757
.word 0x1859
.word 0x1e32
.word 0x1b42
.word 0x5b0
.word 0x2dfb
.word 0xc95
.word 0x284d
.word 0xb12
.word 0x1e46
.word 0x247a
.word 0x2826
.word 0x2acb
.word 0x263b
.word 0x19b
.word 0xdeb
.word 0x672
.word 0x282d
.word 0xf18
.word 0x2ff1
.word 0x1c4b
.word 0x994
.word 0x1a8a
.word 0xe3e
.word 0xc76
.word 0x2ce7
.word 0x2a68
.word 0x2cc5
.word 0x1422
.word 0x927
.word 0x2350
.word 0x259a
.word 0x158e
.word 0x21bc
.word 0x1153
.word 0x2b30
.word 0x29bc
.word 0x2685
.word 0x205c
.word 0x200f
.word 0x313
.word 0x262b
.word 0x20a8
.word 0x2bed
.word 0x1263
.word 0x436
.word 0x4d
.word 0x2f76
.word 0x1f6a
.word 0x1fc6
.word 0x605
.word 0x2816
.word 0x2d48
.word 0xf63
.word 0x220a
.word 0x1055
.word 0x4d8
.word 0x1b6
.word 0x1201
.word 0x2dbc
.word 0x6f9
.word 0x80c
.word 0xf57
.word 0xa37
.word 0x588
.word 0x21ee
.word 0x227c
.word 0x32c
.word 0x1a93
.word 0x1a96
.word 0x15ec
.word 0x9cb
.word 0x2c93
.word 0x29c1
.word 0x12ce
.word 0x1fa4
.word 0x27ba
.word 0xb59
.word 0x1ed2
.word 0x250f
.word 0x2782
.word 0x14b1
.word 0x22bc
.word 0x2093
.word 0x16c7
.word 0x8ed
.word 0x10f
.word 0x73
.word 0x241
.word 0x184
.word 0x440
.word 0x1d58
.word 0x2fff
.word 0x16a4
.word 0x1f44
.word 0xc4
.word 0x14e1
.word 0x25d5
.word 0x192
.word 0x275e
.word 0x1db7
.word 0x1e04
.word 0xed
.word 0x2efa
.word 0xe10
.word 0x24
.word 0x244d
.word 0xb1d
.word 0x881
.word 0x33f
.word 0x1bd2
.word 0xaf
.word 0x2b14
.word 0x2ee5
.word 0xf8e
.word 0x297f
.word 0xa7a
.word 0xfcc
.word 0xfec
.word 0x9e5
.word 0xfe8
.word 0x9d6
.word 0x2d83
.word 0x400
.word 0x2829
.word 0x28cd
.word 0x2a0f
.word 0x2fa1
.word 0x211c
.word 0x1629
.word 0x1907
.word 0x1469
.word 0x2498
.word 0x2c41
.word 0x792
.word 0x249c
.word 0x185b
.word 0x30d
.word 0xafa
.word 0x2037
.word 0x2422
.word 0xd04
.word 0x14f
.word 0x25c2
.word 0x26dd
.word 0x231
.word 0x39a
.word 0xcb4
.word 0x3cc
.word 0x35e
.word 0x220d
.word 0xbb4
.word 0x2b92
.word 0x2c24
.word 0x22f4
.word 0x18d7
.word 0x23a2
.word 0x2be
.word 0x1d7c
.word 0x2af7
.word 0x9da
.word 0x2155
.word 0x24f3
.word 0x459
.word 0xbdd
.word 0x1993
.word 0x1737
.word 0xbdb
.word 0x2e6e
.word 0x605
.word 0x888
.word 0x2005
.word 0xa6a
.word 0xa81
.word 0x12fa
.word 0x2b1f
.word 0x6b6
.word 0xade
.word 0xe4
.word 0x130a
.word 0x272c
.word 0x13a6
.word 0x173b
.word 0x197f
.word 0x1b6a
.word 0x1cea
.word 0x25c2
.word 0x145
.word 0x1d85
.word 0x2307
.word 0xfae
.word 0x181a
.word 0x259d
.word 0x304
.word 0x1e05
.word 0x2845
.word 0x28fa
.word 0x2e9f
.word 0xbaa
.word 0x1274
.word 0x13f0
.word 0x4f8
.word 0x2281
.word 0xfd7
.word 0x2181
.word 0x2ba4
.word 0x71c
.word 0x1fc4
.word 0x10b7
.word 0xc36
.word 0x1aed
.word 0x291
.word 0x4dc
.word 0x2f82
.word 0x1e5d
.word 0x2156
.word 0x2979
.word 0x6a4
.word 0x8e
.word 0x6b7
.word 0x1368
.word 0x1cd9
.word 0x25c9
.word 0x14cf
.word 0xed2
.word 0x23bf
.word 0x1b4d
.word 0xca8
.word 0x848
.word 0x2008
.word 0x13a3
.word 0x8d6
.word 0x29a2
.word 0x1c09
.word 0x28e5
.word 0x2276
.word 0x21ca
.word 0x27ee
.word 0x2a94
.word 0x2847
.word 0x2f1d
.word 0x1c0c
.word 0xe04
.word 0x25fe
.word 0x6bf
.word 0x175f
.word 0x2007
.word 0x15e8
.word 0xb33
.word 0xadc
.word 0x1648
.word 0x2b94
.word 0x1296
.word 0xa
.word 0x68c
.word 0x198d
.word 0x25ed
.word 0x2e22
.word 0x2df9
.word 0x6ff
.word 0x1a56
.word 0x27ac
.word 0x13e
.word 0x2c50
.word 0x98e
.word 0x18e
.word 0x7e3
.word 0x256f
.word 0x1a32
.word 0x1715
.word 0x185c
.word 0x1fb0
.word 0x6be
.word 0x2b63
.word 0xca7
.word 0x1ddf
.word 0x28ea
.word 0x24df
.word 0x1d44
.word 0x28cc
.word 0x212b
.word 0x1559
.word 0x14cf
.word 0x2665
.word 0x2c59
.word 0x6a9
.word 0x2f9c
.word 0x2aab
.word 0x25f7
.word 0x1c4
.word 0x1f95
.word 0x194e
.word 0x1527
.word 0x9f
.word 0xf65
.word 0x1d57
.word 0xb72
.word 0xfa9
.word 0x17d4
.word 0x1443
.word 0x2c4a
.word 0x27be
.word 0x257d
.word 0x2ccb
.word 0x2c8b
.word 0x11de
.word 0x1005
.word 0x157
.word 0x59f
.word 0x22a4
.word 0xe85
.word 0x1aad
.word 0x1af2
.word 0x6cc
.word 0x264e
.word 0x7bf
.word 0x34f
.word 0x15c3
.word 0x15ab
.word 0x1d00
.word 0x1b04
.word 0x1b8e
.word 0x1544
.word 0x131e
.word 0xae5
.word 0xaeb
.word 0xe6c
.word 0x89c
.word 0x2686
.word 0x145a
.word 0x888
.word 0x2e36
.word 0xf01
.word 0x2599
.word 0x787
.word 0x2e4e
.word 0x2022
.word 0x1690
.word 0x2bbc
.word 0x215b
.word 0x2a1a
.word 0x19e
.word 0x19d5
.word 0x1911
.word 0x232b
.word 0x1ffa
.word 0xa27
.word 0x291b
.word 0x77d
.word 0x1940
.word 0x1be4
.word 0xb7e
.word 0x1f5f
.word 0x2761
.word 0x2f14
.word 0xfd
.word 0x483
.word 0x25f5
.word 0x206d
.word 0x2131
.word 0x798
.word 0x1d19
.word 0x1291
.word 0x13d1
.word 0x2fbc
.word 0x2d94
.word 0x21db
.word 0x7f7
.word 0xc94
.word 0x1f33
.word 0x1964
.word 0x238d
.word 0x288f
.word 0x18aa
.word 0x2a3c
.word 0x6b3
.word 0x2109
.word 0x1958
.word 0x16ec
.word 0x1b34
.word 0x257d
.word 0x2fe6
.word 0x1a4b
.word 0x1efd
.word 0x11cf
.word 0x1133
.word 0x1d4d
.word 0x205f
.word 0x1342
.word 0x160d
.word 0xd0b
.word 0x153
.word 0x2748
.word 0x13f0
.word 0x166e
.word 0x2297
.word 0xc71
.word 0x258b
.word 0x1461
.word 0x2457
.word 0x645
.word 0x280f
.word 0xd4e
.word 0x2e88
.word 0x2c56
.word 0x1712
.word 0xa12
.word 0x1459
.word 0x746
.word 0x205f
.word 0x2e4b
.word 0xf33
.word 0x2d4c
.word 0x1328
.word 0x5df
.word 0x2c29
.word 0x65c
.word 0xa88
.word 0xc18
.word 0x227a
.word 0xbe
.word 0x997
.word 0x118d
.word 0x7a4
.word 0x1feb
.word 0x1d7c
.word 0x187e
.word 0xa4f
.word 0x3e9
.word 0x2488
.word 0x7aa
.word 0x292
.word 0x28f4
.word 0x24a
.word 0x286b
.word 0x12e7
.word 0x108f
.word 0x21c5
.word 0x2f2f
.word 0x1983
.word 0xddd
.word 0x2bbf
.word 0x19c
.word 0x1824
.word 0x5c7
.word 0x267d
.word 0x6f1
.word 0x1bae
.word 0x1b47
.word 0x290f
.word 0x18b2
.word 0xef7
.word 0xa13
.word 0x2bf
.word 0x8e7
.word 0x2af2
.word 0x1076
.word 0x2ff3
.word 0x91
.word 0x1dcd
.word 0x1eea
.word 0x1936
.word 0x25c
.word 0x186c
.word 0x526
.word 0x27d5
.word 0xcc3
.word 0x1bf7
.word 0x17d
.word 0x2178
.word 0x163b
.word 0x7d3
.word 0x2faa
.word 0x2c78
.word 0x2752
.word 0x1505
.word 0x1f2a
.word 0x2afb
.word 0x230e
.word 0x2f4d
.word 0x2e59
.word 0x5cc
.word 0x2d5
.word 0xff6
.word 0x2eb1
.word 0x1585
.word 0x1864
.word 0x2065
.word 0x180
.word 0x524
.word 0x154f
.word 0x1af
.word 0x14fe
.word 0x358
.word 0x2cb8
.word 0x13b4
.word 0x29ed
.word 0x1cf3
.word 0x2744
.word 0x1694
.word 0x16ec
.word 0x12b9
.word 0x418
.word 0x2404
.word 0x12b9
.word 0x1e17
.word 0x1b42
.word 0xa9c
.word 0x1ea9
.word 0x151e
.word 0x22ee
.word 0x804
.word 0x2e74
.word 0x2a29
.word 0xf4a
.word 0x103d
.word 0x1b52
.word 0x2aa4
.word 0x1491
.word 0x1376
.word 0x24b8
.word 0x2373
.word 0x19e6
.word 0x2f3a
.word 0x1267
.word 0x2c5e
.word 0xfa
.word 0x422
.word 0x73a
.word 0x23c9
.word 0x5c1
.word 0xbfc
.word 0x16df
.word 0xc5d
.word 0x219f
.word 0xcf6
.word 0x90b
.word 0x2221
.word 0x12f0
.word 0x1bf7
.word 0x2f6
.word 0x1e38
.word 0xcac
.word 0x3a3
.word 0xce0
.word 0x1a67
.word 0x210f
.word 0x441
.word 0x19ea
.word 0xa5b
.word 0x8f5
.word 0xcd3
.word 0xc45
.word 0x17df
.word 0x2ff8
.word 0xeb2
.word 0x2dcb
.word 0x296a
.word 0x20c8
.word 0x682
.word 0x13e7
.word 0x1182
.word 0x20c2
.word 0x549
.word 0x37
.word 0x91f
.word 0x23a5
.word 0x22c9
.word 0x1c6c
.word 0x2372
.word 0x1af5
.word 0xf49
.word 0x265
.word 0x751
.word 0x2d01
.word 0x1cb5
.word 0x6d0
.word 0x1bba
.word 0x180f
.word 0x110f
.word 0x7b2
.word 0x22ed
.word 0x14eb
.word 0x18f9
.word 0x3e9
.word 0x378
.word 0x2d3c
.word 0x23a3
.word 0xeac
.word 0x1d4d
.word 0x13de
.word 0x276a
.word 0x257a
.word 0x22f3
.word 0x1d1a
.word 0x21b0
.word 0x1fcf
.word 0xaa7
.word 0x14e8
.word 0x2208
.word 0x1180
.word 0xd00
.word 0x11d7
.word 0x4a2
.word 0xdd6
.word 0x1aab
.word 0x13c1
.word 0x2682
.word 0x2c0e
.word 0x1c55
.word 0x2bc
.word 0x66e
.word 0xf9e
.word 0x2841
.word 0x14c1
.word 0x2009
.word 0x240d
.word 0x24c7
.word 0x1544
.word 0x3f
.word 0x2f57
.word 0x1811
.word 0x1c9c
.word 0xdfe
.word 0x15fa
.word 0x1f71
.word 0x178d
.word 0x19e3
.word 0x177f
.word 0x2ab3
.word 0x13
.word 0xf84
.word 0x2a16
.word 0x174d
.word 0x1264
.word 0x2387
.word 0x2af3
.word 0x2158
.word 0x1f75
.word 0x6b
.word 0x2e02
.word 0x2c0d
.word 0x660
.word 0x15f
.word 0x2db
.word 0xe94
.word 0x2c27
.word 0xa7c
.word 0x671
.word 0x1862
.word 0xcb4
.word 0xc40
.word 0x6a2
.word 0xc6c
.word 0x164d
.word 0x1c63
.word 0x1ba4
.word 0x1ee4
.word 0x219
.word 0x23fa
.word 0x9b6
.word 0x16c
.word 0x554
.word 0x1e3e
.word 0x2c14
.word 0x196f
.word 0x1ea6
.word 0x28e1
.word 0x28f1
.word 0x2298
.word 0x11e9
.word 0xc0b
.word 0x25ef
.word 0x2735
.word 0xd7e
.word 0x17cb
.word 0x2949
.word 0x7a9
.word 0x1710
.word 0xbf
.word 0xf3e
.word 0x1cd
.word 0x233a
.word 0x10c4
.word 0x1516
.word 0x122a
.word 0x210e
.word 0x1276
.word 0xd65
.word 0x241b
.word 0x293f
.word 0x2d61
.word 0x2e1e
.word 0xef6
.word 0x1e2c
.word 0x832
.word 0xaeb
.word 0xadd
.word 0x2a7e
.word 0x1567
.word 0xa38
.word 0x729
.word 0x1f8b
.word 0xcfd
.word 0xcbd
.word 0x2660
.word 0xa9b
.word 0xd3b
.word 0x1b4b
.word 0x9e1
.word 0x1fcd
.word 0x27b2
.word 0x154f
.word 0x2b0c
.word 0x162f
.word 0x2a57
.word 0x21a9
.word 0xe7e
.word 0x1e9b
.word 0xeb
.word 0x2356
.word 0x2111
.word 0x847
.word 0x24ec
.word 0x20e4
.word 0x1b30
.word 0x1ad6
.word 0x1da1
.word 0x74a
.word 0x12e0
.word 0x21e6
.word 0x1989
.word 0x6ad
.word 0x1bae
.word 0x2972
.word 0x21c4
.word 0x21f3
.word 0x1f48
.word 0x14f5
.word 0x277f
.word 0x15ff
.word 0x2593
.word 0x2876
.word 0x29a1
.word 0xafe
.word 0x2e35
.word 0x196f
.word 0x2836
.word 0x2fec
.word 0x658
.word 0x1888
.word 0x2129
.word 0x2702
.word 0xfe1
.word 0x245f
.word 0x2c2c
.word 0xc5
.word 0x10a8
.word 0x1e13
.word 0x3c
.word 0x99c
.word 0x7e
.word 0x2d4c
.word 0x1448
.word 0xc33
.word 0x2eb4
.word 0x2312
.word 0x1358
.word 0x23b6
.word 0x1fe1
.word 0xd1f
.word 0x7f7
.word 0xb84
.word 0x2f2b
.word 0x2361
.word 0x925
.word 0x14d7
.word 0x1522
.word 0x243c
.word 0x20c3
.word 0x2b13
.word 0x29ab
.word 0x6c8
.word 0x1eb0
.word 0x2099
.word 0x1f4f
.word 0x1fdf
.word 0x1a88
.word 0x2a60
.word 0x9e5
.word 0x2555
.word 0x2e8a
.word 0x23e1
.word 0x24c7
.word 0x2e2b
.word 0x55f
.word 0x366
.word 0x1697
.word 0x2e1
.word 0x13c6
.word 0x2437
.word 0xa08
.word 0x24aa
.word 0xbe
.word 0x1f44
.word 0x24ae
.word 0xc74
.word 0x1789
.word 0x24c
.word 0x381
.word 0x277c
.word 0x14bc
.word 0x2bf1
.word 0xd5f
.word 0x1930
.word 0x7d9
.word 0x1d0a
.word 0x11cd
.word 0x17c0
.word 0x1be3
.word 0x842
.word 0x13cb
.word 0x2acb
.word 0x41b
.word 0x227
.word 0x276d
.word 0x221d
.word 0x1952
.word 0x87
.word 0x1157
.word 0x2d51
.word 0x341
.word 0x6bc
.word 0x16a4
.word 0x2248
.word 0x479
.word 0x1ff5
.word 0x2d46
.word 0x1d4f
.word 0xc28
.word 0x1aad
.word 0x2fe4
.word 0x1613
.word 0x1a58
.word 0x1b61
.word 0xf1
.word 0x692
.word 0x2f9
.word 0xe37
.word 0x322
.word 0x276f
.word 0x205
.word 0x116d
.word 0x2cbb
.word 0x26a3
.word 0x1ae7
.word 0x28f8
.word 0x1de3
.word 0x144d
.word 0x2aca
.word 0x1c2a
.word 0x2046
.word 0x2ab0
.word 0x410
.word 0x1fb8
.word 0x196c
.word 0x74d
.word 0x1bf8
.word 0x1553
.word 0xdc3
.word 0x1ac
.word 0x2bf7
.word 0x2c7e
.word 0x208d
.word 0x8a2
.word 0x8b2
.word 0x24aa
.word 0x2d4e
.word 0x25c2
.word 0x176c
.word 0x2eeb
.word 0x2092
.word 0xb38
.word 0xa25
.word 0x2e89
.word 0x2743
.word 0x22a4
.word 0x9d8
.word 0x1a9
.word 0x1d53
.word 0x1246
.word 0x2b8b
.word 0xf9f
.word 0x2b43
.word 0xe9c
.word 0x20f6
.word 0x2be6
.word 0x2b9b
.word 0x2970
.word 0xfea
.word 0xaf7
.word 0xd4
.word 0x3d6
.word 0x16fc
.word 0x12c5
.word 0x1ee0
.word 0x1e43
.word 0xde4
.word 0x2c2d
.word 0x2d40
.word 0x278f
.word 0x2808
.word 0x2667
.word 0x2d48
.word 0x22a
.word 0xc7c
.word 0x15b7
.word 0x1802
.word 0x144d
.word 0x26df
.word 0x29a1
.word 0x275a
.word 0x2a2f
.word 0x2967
.word 0x16f1
.word 0x28da
.word 0x485
.word 0x628
.word 0x27ad
.word 0x108e
.word 0x1acb
.word 0x1231
.word 0x1e44
.word 0x1dc1
.word 0xb1f
.word 0xcd9
.word 0x1502
.word 0x17be
.word 0xcaa
.word 0x11e5
.word 0xa41
.word 0x28fa
.word 0x104e
.word 0x3c9
.word 0xd7e
.word 0x1acd
.word 0x173a
.word 0x2477
.word 0xfa4
.word 0x2dca
.word 0x17d3
.word 0x19d7
.word 0x24d6
.word 0x1eb1
.word 0x33
.word 0xa7e
.word 0xa66
.word 0x5ae
.word 0x2ecd
.word 0x267b
.word 0x7d6
.word 0x137b
.word 0x237b
.word 0x664
.word 0x2c9f
.word 0x719
.word 0x1ecd
.word 0x287a
.word 0x64c
.word 0x26bf
.word 0xbca
.word 0x2475
.word 0xcbc
.word 0x8f1
.word 0x21ea
.word 0x1d00
.word 0x1619
.word 0x11cd
.word 0x2832
.word 0x1eec
.word 0x10d5
.word 0x1090
.word 0x6f7
.word 0x2f9
.word 0x2194
.word 0x2759
.word 0x2666
.word 0x1b7c
.word 0x1286
.word 0xb1b
.word 0x20f3
.word 0xfaf
.word 0x1eb
.word 0x251b
.word 0x125d
.word 0x146d
.word 0x228e
.word 0x246
.word 0x2f2a
.word 0x2ac0
.word 0x226f
.word 0xee4
.word 0x26f6

tt_coef0:
.word 0x0000000