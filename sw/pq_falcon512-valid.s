/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* Falcon-512 Verify Implementation */
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

loopi 64, 3
  jal x1, normalize
  addi x19, x19, 32
  addi x20, x20, 32


/* Correct until this point here */

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

loopi 64, 30

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
  .quad 0x0000000000000539
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

omega1:
.word 0x2baf
.word 0x299b
.word 0x2f04
.word 0x1edc
.word 0x1861
.word 0x21a6
.word 0x2bfe
.word 0x256d


psi0:
  .quad 0x0000000000002BAF
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

psi1:
.word 0x299b
.word 0x2f04
.word 0x1edc
.word 0x1861
.word 0x21a6
.word 0x2bfe
.word 0x256d
.word 0x201d


inv_omega0:
  .quad 0x00000000000025c9
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

inv_omega1:
  .quad 0x00000000000025c9
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

inv_psi0:
  .quad 0x0000000000001b53
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

inv_psi1:
  .quad 0x0000000000001b53
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

n1:
  .quad 0x0000000000001d56
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

s2_coef0: 
.word 0x5f
.word 0x67
.word 0x3
.word 0x22a
.word 0x8a
.word 0x15
.word 0xffffff58
.word 0x4f
.word 0xffffff73
.word 0xffffff3a
.word 0x101
.word 0x70
.word 0x33
.word 0xffffffcd
.word 0x53
.word 0xffffffc6
.word 0xffffff4c
.word 0xffffff92
.word 0x8a
.word 0xcc
.word 0xbe
.word 0xffffff9e
.word 0x14
.word 0x156
.word 0xfffffedd
.word 0xffffffe0
.word 0x19
.word 0xffffff71
.word 0xffffffd2
.word 0x81
.word 0xffffff7b
.word 0x79
.word 0xffffff7f
.word 0xffffffe0
.word 0xfffffedb
.word 0xb9
.word 0xffffffa3
.word 0x170
.word 0xffffff05
.word 0xd8
.word 0x44
.word 0xfffffff1
.word 0xfffffffa
.word 0x39
.word 0xffffffe6
.word 0xffffffce
.word 0xfffffffa
.word 0xab
.word 0xffffff77
.word 0x123
.word 0x3e
.word 0xffffff8a
.word 0x48
.word 0xfffffed9
.word 0xffffff9e
.word 0x210
.word 0x115
.word 0xffffffa9
.word 0xffffffe3
.word 0xd3
.word 0xffffff5d
.word 0xffffff13
.word 0xffffff4a
.word 0x12
.word 0xffffffbc
.word 0xffffffa0
.word 0x1ab
.word 0x81
.word 0xffffffe3
.word 0xfffffff0
.word 0xf9
.word 0xfffffdd4
.word 0xffffffa3
.word 0x64
.word 0xffffffea
.word 0xad
.word 0xffffffaa
.word 0xfe
.word 0x126
.word 0x71
.word 0xffffff5a
.word 0x124
.word 0x45
.word 0xffffffeb
.word 0x11d
.word 0xffffffe5
.word 0x3f
.word 0x1
.word 0x33
.word 0xfffffec3
.word 0xffffff66
.word 0xffffff79
.word 0xffffff26
.word 0xffffffac
.word 0xffffffe5
.word 0xffffffa0
.word 0xffffff30
.word 0xffffff64
.word 0x91
.word 0xe
.word 0x5
.word 0x1a4
.word 0xc6
.word 0x40
.word 0xaf
.word 0xfffffef4
.word 0xfffffff9
.word 0x91
.word 0x5
.word 0xfffffe5e
.word 0xffffffda
.word 0x3b
.word 0x3c
.word 0xfffffff0
.word 0x7
.word 0xffffffac
.word 0xb7
.word 0xffffff99
.word 0xffffff0a
.word 0xfffffe8c
.word 0xde
.word 0xda
.word 0xffffff9a
.word 0x146
.word 0x170
.word 0xffffffab
.word 0xffffff7d
.word 0x7b
.word 0x146
.word 0xb7
.word 0xd6
.word 0xffffffbd
.word 0xfffffff3
.word 0xfffffff7
.word 0x99
.word 0xffffffea
.word 0xa2
.word 0x66
.word 0x143
.word 0x6b
.word 0x8e
.word 0xffffffd9
.word 0xffffff9f
.word 0xffffffb6
.word 0x97
.word 0xffffff5b
.word 0xc6
.word 0xffffff77
.word 0xffffff73
.word 0xffffffd5
.word 0xfffffef8
.word 0xffffffa2
.word 0x53
.word 0x68
.word 0xffffffeb
.word 0x6e
.word 0x8b
.word 0xc
.word 0x10b
.word 0xfffffeac
.word 0x2c
.word 0xffffff8b
.word 0x3
.word 0xffffff33
.word 0xffffffb5
.word 0xffffffc2
.word 0xb2
.word 0xffffff92
.word 0xffffffdf
.word 0xffffff14
.word 0xffffff72
.word 0xffffff8b
.word 0x37
.word 0xffffffdd
.word 0xfe
.word 0xffffff6b
.word 0xffffffd7
.word 0x50
.word 0x56
.word 0x9
.word 0xffffffe0
.word 0x61
.word 0xffffff38
.word 0xffffffb1
.word 0xffffff22
.word 0x18c
.word 0xe4
.word 0xffffffab
.word 0x48
.word 0x7d
.word 0x8a
.word 0xfffffefc
.word 0xffffff63
.word 0x44
.word 0xfffffeb6
.word 0xfffffffe
.word 0xe9
.word 0xc2
.word 0x15e
.word 0xfffffed1
.word 0x72
.word 0xffffff39
.word 0xffffff8b
.word 0x125
.word 0x60
.word 0x95
.word 0xffffffb5
.word 0xffffff6a
.word 0x39
.word 0xffffff8c
.word 0x164
.word 0x81
.word 0x76
.word 0x7d
.word 0xa3
.word 0xffffffd9
.word 0xffffff56
.word 0xfffffef3
.word 0x54
.word 0x115
.word 0xffffff0c
.word 0x67
.word 0x3c
.word 0x13d
.word 0xffffff39
.word 0xffffff40
.word 0xffffff7f
.word 0xffffffc9
.word 0x18
.word 0xfffffff8
.word 0xffffff3d
.word 0x74
.word 0xffffffd3
.word 0x21
.word 0x32
.word 0x141
.word 0x62
.word 0xffffff88
.word 0xfffffffb
.word 0xffffffbd
.word 0xffffff90
.word 0x114
.word 0x23
.word 0xb1
.word 0xffffffe9
.word 0xffffff97
.word 0xeb
.word 0xffffffc0
.word 0xa0
.word 0xffffff1d
.word 0xffffff72
.word 0xffffff17
.word 0xffffffbf
.word 0xffffffee
.word 0x154
.word 0xffffff68
.word 0xffffffbc
.word 0xfffffffd
.word 0xffffff03
.word 0xffffffd7
.word 0xffffffc5
.word 0xab
.word 0x42
.word 0xfffffff8
.word 0x13
.word 0xffffff99
.word 0xffffffdb
.word 0x29
.word 0x44
.word 0xffffff45
.word 0xa9
.word 0x4a
.word 0xffffff62
.word 0xffffffe1
.word 0x10
.word 0x7c
.word 0xe
.word 0x162
.word 0xbf
.word 0xfffffeeb
.word 0x1
.word 0xffffffda
.word 0xfa
.word 0x12
.word 0xffffff15
.word 0xffffff2c
.word 0xffffffed
.word 0xcd
.word 0xfffffffc
.word 0xeb
.word 0x89
.word 0x19
.word 0xffffffbd
.word 0x134
.word 0x62
.word 0xffffffe5
.word 0x99
.word 0x47
.word 0x9f
.word 0x6e
.word 0x76
.word 0x8
.word 0xfffffefc
.word 0xffffffd7
.word 0xb3
.word 0xffffffad
.word 0x15b
.word 0xc
.word 0xffffff24
.word 0x6
.word 0xffffff8a
.word 0xffffffef
.word 0xfffffee9
.word 0x38
.word 0xffffff7e
.word 0x20
.word 0xfffffef0
.word 0x8e
.word 0x8
.word 0xad
.word 0xffffff16
.word 0xfffffee9
.word 0x13
.word 0x80
.word 0xffffff5b
.word 0xa7
.word 0xffffff66
.word 0xffffffcd
.word 0xffffffc2
.word 0xffffff59
.word 0xffffffc2
.word 0x70
.word 0xeb
.word 0xffffff00
.word 0xffffffdb
.word 0x7
.word 0x9a
.word 0x2c
.word 0x46
.word 0xfffffff4
.word 0xfffffe46
.word 0xc
.word 0x1f
.word 0xffffff22
.word 0xffffffc3
.word 0x50
.word 0xeb
.word 0x53
.word 0xec
.word 0x75
.word 0x1b
.word 0xffffffa2
.word 0xffffffb7
.word 0x25
.word 0xfffffef3
.word 0xffffffbd
.word 0x9
.word 0xffffff27
.word 0x24
.word 0x14a
.word 0x91
.word 0x6a
.word 0xffffffe7
.word 0x46
.word 0xffffff32
.word 0x3d
.word 0xffffffc3
.word 0xc2
.word 0xffffffb0
.word 0x5b
.word 0x29
.word 0x40
.word 0x23
.word 0xffffff4b
.word 0x29
.word 0xf9
.word 0xfffffecb
.word 0x6f
.word 0xbd
.word 0xffffffc6
.word 0xffffff79
.word 0xcc
.word 0xdb
.word 0x89
.word 0x58
.word 0xffffff52
.word 0xfffffebc
.word 0xfe
.word 0xffffff45
.word 0x4d
.word 0xf9
.word 0xffffffde
.word 0x11
.word 0xffffff3d
.word 0xe3
.word 0xffffffc7
.word 0xffffffd5
.word 0xbc
.word 0xffffff31
.word 0xffffffbe
.word 0x38
.word 0xfd
.word 0xffffffe3
.word 0xffffff60
.word 0xffffff16
.word 0xfffffeff
.word 0xffffffac
.word 0xffffffd1
.word 0x19
.word 0xc
.word 0xffffffdd
.word 0x74
.word 0xffffff51
.word 0x9b
.word 0x4b
.word 0x54
.word 0x55
.word 0xfffffff3
.word 0x8a
.word 0xffffffec
.word 0xffffff71
.word 0xffffff56
.word 0x79
.word 0x4a
.word 0xffffff84
.word 0x6f
.word 0xffffff98
.word 0xf9
.word 0x2e
.word 0x76
.word 0xffffffd1
.word 0x12e
.word 0xb
.word 0xffffffd8
.word 0xfffffff4
.word 0xffffffca
.word 0x2c
.word 0xffffffa2
.word 0xffffffa9
.word 0xffffffba
.word 0x4a
.word 0x4d
.word 0xd4
.word 0xffffff59
.word 0x91
.word 0xffffffba
.word 0xfffffebd
.word 0x2
.word 0xffffff06
.word 0x55
.word 0xfffffee4
.word 0x44
.word 0x6f
.word 0xffffffd6
.word 0x8
.word 0x17c
.word 0x1a
.word 0xffffff8c
.word 0xffffff89
.word 0xffffffb8
.word 0xffffffbe
.word 0xffffffec
.word 0xe6
.word 0xffffff82
.word 0x156
.word 0xfffffec1
.word 0xffffff26
.word 0xffffff9e
.word 0xfffffed1
.word 0xbc
.word 0xffffffe7
.word 0xfffffef8
.word 0xffffff85
.word 0x3b
.word 0xffffffad
.word 0xffffffba
.word 0x59
.word 0xffffff9a
.word 0xffffff42
.word 0x8
.word 0xc1
.word 0x36
.word 0x4d
.word 0x86
.word 0xfffffe6e
.word 0xffffffef
.word 0xba
.word 0xffffffe9
.word 0xffffffae
.word 0xffffffe5
.word 0xb2
.word 0xfffffec8
.word 0xffffff91
.word 0xd1
.word 0xe1
.word 0xffffff84
.word 0xfb
.word 0xe4
.word 0xffffffe0
.word 0xffffffde
.word 0x145
.word 0x54
.word 0x96
.word 0x3e
.word 0x94
.word 0x91
.word 0xff
.word 0x9b
.word 0x12
.word 0xffffffaa
.word 0x4c
.word 0x8d
h_coef0: 
.word 0x1f83
.word 0x1d15
.word 0x2ce4
.word 0x140e
.word 0x1bc4
.word 0x26ee
.word 0x2bca
.word 0x7a1
.word 0x12df
.word 0xa1f
.word 0x2db7
.word 0x24cc
.word 0x274a
.word 0x1ae7
.word 0x20a3
.word 0x17d5
.word 0x25ca
.word 0x1f9e
.word 0x1f27
.word 0xe27
.word 0x23e3
.word 0x149b
.word 0x87a
.word 0x1cfa
.word 0x4b9
.word 0x1f17
.word 0x1259
.word 0x2644
.word 0x1f63
.word 0xbab
.word 0x2339
.word 0x27cd
.word 0x765
.word 0x2969
.word 0x17ef
.word 0x24a9
.word 0x1686
.word 0x636
.word 0x1cf1
.word 0xd6a
.word 0x117f
.word 0x164c
.word 0x2038
.word 0x181c
.word 0x787
.word 0x4d8
.word 0x2a86
.word 0xe50
.word 0x29aa
.word 0x250c
.word 0x650
.word 0x26b2
.word 0x2347
.word 0x16bd
.word 0x7e0
.word 0x145d
.word 0xef3
.word 0x7ba
.word 0x1235
.word 0x2032
.word 0x792
.word 0x18c7
.word 0x9f5
.word 0x2283
.word 0x461
.word 0xd82
.word 0x118d
.word 0x2156
.word 0x205d
.word 0x4c0
.word 0x22e2
.word 0x22df
.word 0x1cef
.word 0x14bc
.word 0x2f6f
.word 0x17a6
.word 0x11cb
.word 0xf62
.word 0x108
.word 0xebf
.word 0x1d3a
.word 0x16c7
.word 0x289c
.word 0xbf7
.word 0x24e4
.word 0x1787
.word 0x21ad
.word 0x2b92
.word 0x7a0
.word 0x2267
.word 0x2970
.word 0x247b
.word 0x2932
.word 0x25d0
.word 0x1ca4
.word 0x1a7a
.word 0x2f44
.word 0x669
.word 0xa38
.word 0x2255
.word 0x292c
.word 0x1512
.word 0x158d
.word 0x2e44
.word 0x11ea
.word 0x2ec
.word 0x44f
.word 0x1df5
.word 0x593
.word 0x1953
.word 0x255c
.word 0xd7f
.word 0x3ba
.word 0x1ec3
.word 0x925
.word 0x1c73
.word 0x1fe7
.word 0x1268
.word 0x22c4
.word 0x2a95
.word 0x1804
.word 0x76a
.word 0x23fe
.word 0x24d1
.word 0x525
.word 0x142b
.word 0x1cc8
.word 0x16d7
.word 0x2939
.word 0x222b
.word 0x20d3
.word 0x24da
.word 0x371
.word 0x2f04
.word 0x1ef
.word 0x10f1
.word 0x23c0
.word 0x16eb
.word 0x114f
.word 0x17fe
.word 0x2e8b
.word 0x2dff
.word 0x2ae3
.word 0x2a53
.word 0x1778
.word 0x2a00
.word 0x246f
.word 0x1d56
.word 0x2fc3
.word 0x1ef4
.word 0xdb0
.word 0x2e31
.word 0x3cb
.word 0x16c
.word 0x29d2
.word 0x1a02
.word 0x2325
.word 0x2de1
.word 0x2cbf
.word 0x1754
.word 0xf8d
.word 0x115c
.word 0x1898
.word 0x1594
.word 0x884
.word 0x11b7
.word 0x25e
.word 0x14f4
.word 0x244c
.word 0x2082
.word 0x448
.word 0x24da
.word 0x18c1
.word 0x2714
.word 0x1586
.word 0x2b16
.word 0x2036
.word 0x116d
.word 0x2cdb
.word 0x11d
.word 0x1932
.word 0x12e8
.word 0x1ca4
.word 0x1e0a
.word 0xf4b
.word 0xe58
.word 0x280e
.word 0x4b6
.word 0x988
.word 0x10c3
.word 0x13a7
.word 0x134c
.word 0x2017
.word 0xd8e
.word 0x24ac
.word 0xf73
.word 0x1457
.word 0x2fda
.word 0x2469
.word 0x22b4
.word 0x2bbc
.word 0x10e0
.word 0x1fef
.word 0xbc7
.word 0x14a5
.word 0x2878
.word 0x1817
.word 0x696
.word 0x34f
.word 0x18d
.word 0x1ecf
.word 0x97f
.word 0x1558
.word 0x2afc
.word 0x320
.word 0xb4c
.word 0x1572
.word 0x23f6
.word 0x1fc1
.word 0x1fd7
.word 0xe60
.word 0x2569
.word 0x1f0a
.word 0x2f8
.word 0x2bbb
.word 0x9ec
.word 0x2edb
.word 0x1557
.word 0x23b0
.word 0x2469
.word 0xd84
.word 0xf6
.word 0x1700
.word 0x2dbc
.word 0x2689
.word 0x1e11
.word 0xff2
.word 0x270e
.word 0x188
.word 0x9de
.word 0x128a
.word 0x38c
.word 0x1795
.word 0x533
.word 0xc5f
.word 0x205d
.word 0x1c95
.word 0x223d
.word 0x688
.word 0x2d82
.word 0x26da
.word 0x1673
.word 0xb29
.word 0x26bd
.word 0x13c8
.word 0x21f2
.word 0x56
.word 0xbdf
.word 0x1cb2
.word 0x2d24
.word 0x2791
.word 0x222f
.word 0x81d
.word 0x1eb7
.word 0x389
.word 0x2e90
.word 0x208b
.word 0xe5b
.word 0x1495
.word 0x150b
.word 0x11f8
.word 0x1f12
.word 0x68
.word 0x1d47
.word 0x2e0e
.word 0xc1e
.word 0x73c
.word 0x511
.word 0x1be9
.word 0x1d58
.word 0x2621
.word 0x1ec2
.word 0xe71
.word 0xec4
.word 0x388
.word 0x1639
.word 0x1c1f
.word 0x507
.word 0x1fb1
.word 0xc0c
.word 0x5a0
.word 0xbe8
.word 0x2310
.word 0x29e9
.word 0x1dd1
.word 0x107f
.word 0x1a3e
.word 0x2c6b
.word 0x191f
.word 0xd1a
.word 0x1976
.word 0x2023
.word 0x178e
.word 0x680
.word 0x23bf
.word 0x3f1
.word 0x1de1
.word 0x1af
.word 0x2054
.word 0x932
.word 0x2a86
.word 0x2ec3
.word 0x24fb
.word 0x100c
.word 0x2ae2
.word 0x179e
.word 0x347
.word 0x1456
.word 0x2ced
.word 0x2640
.word 0x1b91
.word 0x26e9
.word 0x6ce
.word 0xce3
.word 0x1d56
.word 0x2f10
.word 0x11de
.word 0x3cd
.word 0x131e
.word 0x2ca8
.word 0x2726
.word 0x2f85
.word 0x17b6
.word 0xa23
.word 0x21b5
.word 0x1774
.word 0x1ff3
.word 0x162
.word 0x2de1
.word 0x2440
.word 0x18b7
.word 0xb09
.word 0x27dd
.word 0x1dea
.word 0xcd6
.word 0x180e
.word 0x11a2
.word 0x90e
.word 0xa72
.word 0x106a
.word 0x25c4
.word 0x19c8
.word 0x61a
.word 0x1004
.word 0x2502
.word 0x223f
.word 0x1808
.word 0x2015
.word 0x285c
.word 0x1227
.word 0x2247
.word 0x1cc7
.word 0x182
.word 0x12dc
.word 0x2b49
.word 0x137d
.word 0x1579
.word 0xfad
.word 0x1908
.word 0x2e92
.word 0x553
.word 0x2f0c
.word 0x2152
.word 0x2487
.word 0x15b5
.word 0x215c
.word 0x2247
.word 0x2e8
.word 0x3e5
.word 0x263
.word 0x659
.word 0x738
.word 0x82f
.word 0x2847
.word 0xfd7
.word 0x1b05
.word 0x7af
.word 0x1b36
.word 0x2232
.word 0x1eb4
.word 0x278a
.word 0xdd
.word 0x20f2
.word 0x2155
.word 0x11e8
.word 0x231e
.word 0x1603
.word 0x1b32
.word 0x26f4
.word 0x274a
.word 0x2b48
.word 0x177a
.word 0x5d7
.word 0x2b75
.word 0x2660
.word 0x16ed
.word 0x47e
.word 0x4ae
.word 0x1806
.word 0xd59
.word 0x2892
.word 0x2554
.word 0xba1
.word 0x148d
.word 0x2994
.word 0x1491
.word 0x1a57
.word 0x3e8
.word 0x2e4b
.word 0x2fc9
.word 0x14f8
.word 0x2ac4
.word 0x2a4b
.word 0x4fa
.word 0x7ca
.word 0x17c6
.word 0x349
.word 0x1626
.word 0x7a4
.word 0x2b4d
.word 0x2a59
.word 0x299c
.word 0x532
.word 0x2add
.word 0x212a
.word 0xbb7
.word 0xc7a
.word 0x14dc
.word 0x274c
.word 0x2809
.word 0x268f
.word 0x2a6e
.word 0x4bf
.word 0x1073
.word 0x461
.word 0x13b6
.word 0x1cad
.word 0x1cf4
.word 0x139b
.word 0x22ed
.word 0x2642
.word 0x228a
.word 0xaf
.word 0x2366
.word 0x2159
.word 0x2bfb
.word 0x1708
.word 0x25db
.word 0xada
.word 0x2f1c
.word 0x2743
.word 0x2e8d
.word 0xb3a
.word 0x805
.word 0x277e
.word 0x2f0f
.word 0x89e
.word 0x2904
.word 0x2ee6
.word 0x1818
.word 0x2174
.word 0xa3d
.word 0x44b
.word 0x2305
.word 0x3db
.word 0xeca
.word 0x29e7
.word 0x13b0
.word 0x18a
.word 0x11b4
.word 0x2d66
.word 0x2018
.word 0x2dd6
.word 0x263b
.word 0x278
.word 0x2bf7
.word 0x18dd
.word 0x1400
.word 0x2d91
.word 0x2458
.word 0x3a8
.word 0x189f
.word 0x276e
.word 0x2c05
.word 0x29ac
.word 0x1b5
.word 0x1411
.word 0x2378
.word 0x73b
.word 0x1642
.word 0x1a7e
.word 0x2a19
.word 0x2742
.word 0x1467
.word 0x2c24
.word 0x2ffc
.word 0x1b92
.word 0x12de
.word 0x2cd1
.word 0x2263
.word 0x1082
.word 0x1224
c0_coef0: 
.word 0x142b
.word 0x1e63
.word 0x202e
.word 0x1d5e
.word 0x13c8
.word 0x2b03
.word 0x1fc9
.word 0x24a
.word 0x686
.word 0x2574
.word 0x891
.word 0x2bab
.word 0xc9e
.word 0x230d
.word 0x1598
.word 0x2fdd
.word 0xf00
.word 0xda
.word 0xda9
.word 0x17b3
.word 0x2825
.word 0x201
.word 0x21e8
.word 0x328
.word 0x1f99
.word 0x1e9a
.word 0x2cb1
.word 0x29a6
.word 0x1ed1
.word 0x17a5
.word 0xa6c
.word 0x48a
.word 0xffe
.word 0x2424
.word 0x1554
.word 0x28cd
.word 0x2f3e
.word 0x1e3d
.word 0x1878
.word 0x90a
.word 0x19c7
.word 0x229
.word 0x6f0
.word 0x4d7
.word 0xa92
.word 0xbf4
.word 0xa9d
.word 0x6de
.word 0xc19
.word 0x2d60
.word 0x750
.word 0x2a40
.word 0x38e
.word 0xe58
.word 0x16eb
.word 0x5d7
.word 0x16bc
.word 0x1bba
.word 0x179e
.word 0x6b8
.word 0x293e
.word 0x1a5b
.word 0x2e4
.word 0xb73
.word 0xbce
.word 0xb49
.word 0x1fe7
.word 0xc97
.word 0x2725
.word 0x101e
.word 0x2a09
.word 0x1db3
.word 0x85d
.word 0x2c9c
.word 0x28b9
.word 0x2203
.word 0x1ef0
.word 0x14c8
.word 0x2b2e
.word 0x1f29
.word 0x8ea
.word 0x2203
.word 0x2222
.word 0xe61
.word 0x164e
.word 0x8a4
.word 0x553
.word 0x2b84
.word 0x2201
.word 0xad2
.word 0x2cd4
.word 0x2dc0
.word 0x2504
.word 0x211e
.word 0x261
.word 0x124b
.word 0x2aa5
.word 0x1336
.word 0x18c5
.word 0x1a11
.word 0x1aa2
.word 0x168a
.word 0x71c
.word 0xa32
.word 0x27f5
.word 0x288
.word 0x2dac
.word 0x26c7
.word 0x1bd2
.word 0x1284
.word 0x22f3
.word 0x11ff
.word 0x622
.word 0x2862
.word 0x1cb7
.word 0x2b43
.word 0x2bd3
.word 0x172a
.word 0x2f88
.word 0x1c8b
.word 0x1ab3
.word 0x17f7
.word 0x159a
.word 0x2e76
.word 0x1183
.word 0x152c
.word 0x1d50
.word 0x625
.word 0x29b4
.word 0x508
.word 0x27ef
.word 0x1ba8
.word 0x2b44
.word 0x26bf
.word 0x1132
.word 0xe6a
.word 0x79b
.word 0xa99
.word 0x22b8
.word 0x249e
.word 0x22d6
.word 0x2cde
.word 0x1132
.word 0x13c5
.word 0x1b25
.word 0xa11
.word 0x1d8a
.word 0x1dfd
.word 0xa16
.word 0x18fc
.word 0xd7
.word 0x3e
.word 0x4a3
.word 0xa1e
.word 0x2433
.word 0x1535
.word 0x24e0
.word 0x20a6
.word 0xc50
.word 0x2ca1
.word 0xc88
.word 0x20f8
.word 0x197d
.word 0x2951
.word 0x21fa
.word 0xf2b
.word 0x181d
.word 0x1209
.word 0x1cff
.word 0x12da
.word 0x46e
.word 0x1fac
.word 0x2310
.word 0x162f
.word 0x4f8
.word 0x1317
.word 0x1491
.word 0xf96
.word 0x2eb7
.word 0x574
.word 0x119
.word 0xefd
.word 0xfbd
.word 0x11c7
.word 0x2d58
.word 0xac7
.word 0x13e2
.word 0x2307
.word 0x2139
.word 0x1fe8
.word 0xdc5
.word 0x6c
.word 0x2cb5
.word 0xab6
.word 0x2c38
.word 0xdd7
.word 0xebb
.word 0x1297
.word 0x1473
.word 0x1c50
.word 0x1d22
.word 0x1744
.word 0x1886
.word 0x110c
.word 0x738
.word 0x17e6
.word 0x121c
.word 0x176e
.word 0x20ce
.word 0x2501
.word 0x1ca5
.word 0x2895
.word 0xa38
.word 0x21d9
.word 0x3a5
.word 0x2e39
.word 0xf9
.word 0x1e7b
.word 0xfbf
.word 0x1252
.word 0x145e
.word 0x12c5
.word 0x23d5
.word 0x351
.word 0x2da9
.word 0x1a25
.word 0x1ed6
.word 0x8f
.word 0x27a7
.word 0x876
.word 0x1796
.word 0xfe1
.word 0x1468
.word 0x23eb
.word 0x19f2
.word 0x28aa
.word 0x2fc4
.word 0x270c
.word 0x880
.word 0x198
.word 0xfa3
.word 0x1eac
.word 0x185b
.word 0x16d2
.word 0x10e3
.word 0x4ae
.word 0x88c
.word 0x2f5b
.word 0x24a6
.word 0xb7f
.word 0x1f63
.word 0x2103
.word 0x6dd
.word 0x359
.word 0x25e4
.word 0x2bc3
.word 0x110b
.word 0xfd1
.word 0x2f9d
.word 0x2ebc
.word 0xdb5
.word 0x12f
.word 0xfa3
.word 0x26a9
.word 0x1458
.word 0x21b3
.word 0xebf
.word 0xb28
.word 0x2200
.word 0x10ae
.word 0x251e
.word 0xcbb
.word 0x147d
.word 0x2a36
.word 0x505
.word 0x1721
.word 0x2884
.word 0xfd
.word 0xd64
.word 0x24cb
.word 0x1ab
.word 0xa3d
.word 0x2409
.word 0x26d9
.word 0x1afd
.word 0x2dd1
.word 0x12a
.word 0x26f
.word 0x23b2
.word 0x1701
.word 0x2f63
.word 0x1158
.word 0x2c7b
.word 0x2a11
.word 0x14fd
.word 0x279d
.word 0x1d73
.word 0x2858
.word 0x22ee
.word 0x2c20
.word 0xfe5
.word 0x1b76
.word 0x1bfa
.word 0x6e9
.word 0x2f50
.word 0xe3c
.word 0x2b4a
.word 0x1492
.word 0x2dd5
.word 0x163f
.word 0x19df
.word 0x22c7
.word 0x2a84
.word 0x775
.word 0x98
.word 0x1e6a
.word 0x1617
.word 0x21c3
.word 0x17df
.word 0x22e7
.word 0x31b
.word 0x101f
.word 0x2292
.word 0x532
.word 0xe4a
.word 0x1d78
.word 0x229e
.word 0x125f
.word 0x23f1
.word 0x197d
.word 0x18da
.word 0x163e
.word 0x16f7
.word 0x12ec
.word 0x1ab1
.word 0x2137
.word 0xf9e
.word 0x1f0
.word 0x2ed6
.word 0x133f
.word 0x292e
.word 0x2b99
.word 0x216d
.word 0x1f9a
.word 0x1b20
.word 0x108
.word 0x577
.word 0x2b3f
.word 0xd1c
.word 0x19a8
.word 0x1764
.word 0x29e4
.word 0x20f0
.word 0x3d3
.word 0x2d61
.word 0x2c56
.word 0x2a03
.word 0x16f3
.word 0x8ed
.word 0xaae
.word 0x2134
.word 0x232d
.word 0x1ea8
.word 0x2765
.word 0x1abb
.word 0xcf1
.word 0xe95
.word 0x2c71
.word 0x136c
.word 0x2d95
.word 0x1fa
.word 0x24f2
.word 0xc4c
.word 0x15f3
.word 0x1cc3
.word 0xbdb
.word 0x2c75
.word 0x1e51
.word 0x1a15
.word 0x220b
.word 0xb5b
.word 0x292b
.word 0x113a
.word 0x2708
.word 0xc84
.word 0x2cca
.word 0x278b
.word 0x478
.word 0x666
.word 0xe94
.word 0x1a4e
.word 0x4dd
.word 0x23bf
.word 0x1611
.word 0x1037
.word 0x27a0
.word 0x1ef3
.word 0x230c
.word 0x1bb3
.word 0x2c6
.word 0x278d
.word 0x121f
.word 0x1795
.word 0x286
.word 0x222
.word 0x341
.word 0x20c1
.word 0x326
.word 0x2fcf
.word 0x5f2
.word 0x1c3b
.word 0x1d2e
.word 0x857
.word 0x1e8
.word 0x202a
.word 0x1d1f
.word 0x2253
.word 0x99b
.word 0xe3
.word 0xf1f
.word 0x1450
.word 0x11e0
.word 0x503
.word 0x29b8
.word 0x1bb2
.word 0x1fd3
.word 0x2a77
.word 0xede
.word 0x2366
.word 0x196
.word 0x4a4
.word 0x1f69
.word 0xca
.word 0x13fa
.word 0xdbf
.word 0x1290
.word 0x1e0a
.word 0x1a43
.word 0x1aab
.word 0x1f72
.word 0x1a9d
.word 0x23b0
.word 0xa20
.word 0x256b
.word 0x2d22
.word 0x1b65
.word 0x153e
.word 0x1455
.word 0x155f
.word 0x1e70
.word 0x2c72
.word 0x384
.word 0x1552
.word 0x2236
.word 0x2dc2
.word 0x6af
.word 0x3be
.word 0x2501
.word 0x2094
.word 0x1a12
.word 0x2a60
.word 0x1175
.word 0x1e01
.word 0x2067
.word 0xd45
.word 0x1e8e
.word 0xc8c
.word 0x1846
.word 0xb48
.word 0x204a
.word 0xb8e
.word 0x193
.word 0x1378
.word 0x2c81
.word 0xb51
.word 0x2fe5
.word 0x203b
.word 0x21ee
.word 0x267b
.word 0x2c29
.word 0x2bcb
.word 0x2f3c
.word 0x1f
.word 0x201
.word 0xb6
.word 0xf19
.word 0x27ca
.word 0x1fb0
.word 0x288b
.word 0x1e9c
.word 0x1c42
.word 0x82e
.word 0x837
.word 0x2b45
.word 0x1c72
.word 0x58b
.word 0x235e
.word 0x1045
.word 0x34f
.word 0x27a6
.word 0x76a
.word 0x2048
.word 0x1fa0
.word 0x1190
.word 0x1b40
.word 0x24b0
.word 0x2d41
.word 0x1f7d
.word 0x29f4
.word 0x579
.word 0x28ef
.word 0x23b2

tt_coef0:
  .quad 0x0000263d000022a1
  .quad 0x00001f54000004c3
  .quad 0x00002552000025ae
  .quad 0x00000fcd0000263a