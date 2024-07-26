/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* Falcon-512 Verify Implementation */
.section .text

/*************************************************/
/*  Reduce s2 elements modulo q ([0..q-1] range) */
/*************************************************/

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
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

s2_coef1:
  .quad 0x0000000900000008
  .quad 0x0000000b0000000a
  .quad 0x0000000d0000000c
  .quad 0x0000000f0000000e

s2_coef2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

s2_coef3:
  .quad 0x0000001900000018
  .quad 0x0000001b0000001a
  .quad 0x0000001d0000001c
  .quad 0x0000001f0000001e

s2_coef4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

s2_coef5:
  .quad 0x0000002900000028
  .quad 0x0000002b0000002a
  .quad 0x0000002d0000002c
  .quad 0x0000002f0000002e

s2_coef6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

s2_coef7:
  .quad 0x0000003900000038
  .quad 0x0000003b0000003a
  .quad 0x0000003d0000003c
  .quad 0x0000003f0000003e

s2_coef8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

s2_coef9:
  .quad 0x0000004900000048
  .quad 0x0000004b0000004a
  .quad 0x0000004d0000004c
  .quad 0x0000004f0000004e

s2_coef10:
  .quad 0x0000005100000050
  .quad 0x0000005300000052
  .quad 0x0000005500000054
  .quad 0x0000005700000056

s2_coef11:
  .quad 0x0000005900000058
  .quad 0x0000005b0000005a
  .quad 0x0000005d0000005c
  .quad 0x0000005f0000005e

s2_coef12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

s2_coef13:
  .quad 0x0000006900000068
  .quad 0x0000006b0000006a
  .quad 0x0000006d0000006c
  .quad 0x0000006f0000006e

s2_coef14:
  .quad 0x0000007100000070
  .quad 0x0000007300000072
  .quad 0x0000007500000074
  .quad 0x0000007700000076

s2_coef15:
  .quad 0x0000007900000078
  .quad 0x0000007b0000007a
  .quad 0x0000007d0000007c
  .quad 0x0000007f0000007e

s2_coef16:
  .quad 0x0000008100000080
  .quad 0x0000008300000082
  .quad 0x0000008500000084
  .quad 0x0000008700000086

s2_coef17:
  .quad 0x0000008900000088
  .quad 0x0000008b0000008a
  .quad 0x0000008d0000008c
  .quad 0x0000008f0000008e

s2_coef18:
  .quad 0x0000009100000090
  .quad 0x0000009300000092
  .quad 0x0000009500000094
  .quad 0x0000009700000096

s2_coef19:
  .quad 0x0000009900000098
  .quad 0x0000009b0000009a
  .quad 0x0000009d0000009c
  .quad 0x0000009f0000009e

s2_coef20:
  .quad 0x000000a1000000a0
  .quad 0x000000a3000000a2
  .quad 0x000000a5000000a4
  .quad 0x000000a7000000a6

s2_coef21:
  .quad 0x000000a9000000a8
  .quad 0x000000ab000000aa
  .quad 0x000000ad000000ac
  .quad 0x000000af000000ae

s2_coef22:
  .quad 0x000000b1000000b0
  .quad 0x000000b3000000b2
  .quad 0x000000b5000000b4
  .quad 0x000000b7000000b6

s2_coef23:
  .quad 0x000000b9000000b8
  .quad 0x000000bb000000ba
  .quad 0x000000bd000000bc
  .quad 0x000000bf000000be

s2_coef24:
  .quad 0x000000c1000000c0
  .quad 0x000000c3000000c2
  .quad 0x000000c5000000c4
  .quad 0x000000c7000000c6

s2_coef25:
  .quad 0x000000c9000000c8
  .quad 0x000000cb000000ca
  .quad 0x000000cd000000cc
  .quad 0x000000cf000000ce

s2_coef26:
  .quad 0x000000d1000000d0
  .quad 0x000000d3000000d2
  .quad 0x000000d5000000d4
  .quad 0x000000d7000000d6

s2_coef27:
  .quad 0x000000d9000000d8
  .quad 0x000000db000000da
  .quad 0x000000dd000000dc
  .quad 0x000000df000000de

s2_coef28:
  .quad 0x000000e1000000e0
  .quad 0x000000e3000000e2
  .quad 0x000000e5000000e4
  .quad 0x000000e7000000e6

s2_coef29:
  .quad 0x000000e9000000e8
  .quad 0x000000eb000000ea
  .quad 0x000000ed000000ec
  .quad 0x000000ef000000ee

s2_coef30:
  .quad 0x000000f1000000f0
  .quad 0x000000f3000000f2
  .quad 0x000000f5000000f4
  .quad 0x000000f7000000f6

s2_coef31:
  .quad 0x000000f9000000f8
  .quad 0x000000fb000000fa
  .quad 0x000000fd000000fc
  .quad 0x000000ff000000fe

s2_coef32:
  .quad 0x0000010100000100
  .quad 0x0000010300000102
  .quad 0x0000010500000104
  .quad 0x0000010700000106

s2_coef33:
  .quad 0x0000010900000108
  .quad 0x0000010b0000010a
  .quad 0x0000010d0000010c
  .quad 0x0000010f0000010e

s2_coef34:
  .quad 0x0000011100000110
  .quad 0x0000011300000112
  .quad 0x0000011500000114
  .quad 0x0000011700000116

s2_coef35:
  .quad 0x0000011900000118
  .quad 0x0000011b0000011a
  .quad 0x0000011d0000011c
  .quad 0x0000011f0000011e

s2_coef36:
  .quad 0x0000012100000120
  .quad 0x0000012300000122
  .quad 0x0000012500000124
  .quad 0x0000012700000126

s2_coef37:
  .quad 0x0000012900000128
  .quad 0x0000012b0000012a
  .quad 0x0000012d0000012c
  .quad 0x0000012f0000012e

s2_coef38:
  .quad 0x0000013100000130
  .quad 0x0000013300000132
  .quad 0x0000013500000134
  .quad 0x0000013700000136

s2_coef39:
  .quad 0x0000013900000138
  .quad 0x0000013b0000013a
  .quad 0x0000013d0000013c
  .quad 0x0000013f0000013e

s2_coef40:
  .quad 0x0000014100000140
  .quad 0x0000014300000142
  .quad 0x0000014500000144
  .quad 0x0000014700000146

s2_coef41:
  .quad 0x0000014900000148
  .quad 0x0000014b0000014a
  .quad 0x0000014d0000014c
  .quad 0x0000014f0000014e

s2_coef42:
  .quad 0x0000015100000150
  .quad 0x0000015300000152
  .quad 0x0000015500000154
  .quad 0x0000015700000156

s2_coef43:
  .quad 0x0000015900000158
  .quad 0x0000015b0000015a
  .quad 0x0000015d0000015c
  .quad 0x0000015f0000015e

s2_coef44:
  .quad 0x0000016100000160
  .quad 0x0000016300000162
  .quad 0x0000016500000164
  .quad 0x0000016700000166

s2_coef45:
  .quad 0x0000016900000168
  .quad 0x0000016b0000016a
  .quad 0x0000016d0000016c
  .quad 0x0000016f0000016e

s2_coef46:
  .quad 0x0000017100000170
  .quad 0x0000017300000172
  .quad 0x0000017500000174
  .quad 0x0000017700000176

s2_coef47:
  .quad 0x0000017900000178
  .quad 0x0000017b0000017a
  .quad 0x0000017d0000017c
  .quad 0x0000017f0000017e

s2_coef48:
  .quad 0x0000018100000180
  .quad 0x0000018300000182
  .quad 0x0000018500000184
  .quad 0x0000018700000186

s2_coef49:
  .quad 0x0000018900000188
  .quad 0x0000018b0000018a
  .quad 0x0000018d0000018c
  .quad 0x0000018f0000018e

s2_coef50:
  .quad 0x0000019100000190
  .quad 0x0000019300000192
  .quad 0x0000019500000194
  .quad 0x0000019700000196

s2_coef51:
  .quad 0x0000019900000198
  .quad 0x0000019b0000019a
  .quad 0x0000019d0000019c
  .quad 0x0000019f0000019e

s2_coef52:
  .quad 0x000001a1000001a0
  .quad 0x000001a3000001a2
  .quad 0x000001a5000001a4
  .quad 0x000001a7000001a6

s2_coef53:
  .quad 0x000001a9000001a8
  .quad 0x000001ab000001aa
  .quad 0x000001ad000001ac
  .quad 0x000001af000001ae

s2_coef54:
  .quad 0x000001b1000001b0
  .quad 0x000001b3000001b2
  .quad 0x000001b5000001b4
  .quad 0x000001b7000001b6

s2_coef55:
  .quad 0x000001b9000001b8
  .quad 0x000001bb000001ba
  .quad 0x000001bd000001bc
  .quad 0x000001bf000001be

s2_coef56:
  .quad 0x000001c1000001c0
  .quad 0x000001c3000001c2
  .quad 0x000001c5000001c4
  .quad 0x000001c7000001c6

s2_coef57:
  .quad 0x000001c9000001c8
  .quad 0x000001cb000001ca
  .quad 0x000001cd000001cc
  .quad 0x000001cf000001ce

s2_coef58:
  .quad 0x000001d1000001d0
  .quad 0x000001d3000001d2
  .quad 0x000001d5000001d4
  .quad 0x000001d7000001d6

s2_coef59:
  .quad 0x000001d9000001d8
  .quad 0x000001db000001da
  .quad 0x000001dd000001dc
  .quad 0x000001df000001de

s2_coef60:
  .quad 0x000001e1000001e0
  .quad 0x000001e3000001e2
  .quad 0x000001e5000001e4
  .quad 0x000001e7000001e6

s2_coef61:
  .quad 0x000001e9000001e8
  .quad 0x000001eb000001ea
  .quad 0x000001ed000001ec
  .quad 0x000001ef000001ee

s2_coef62:
  .quad 0x000001f1000001f0
  .quad 0x000001f3000001f2
  .quad 0x000001f5000001f4
  .quad 0x000001f7000001f6

s2_coef63:
  .quad 0x000001f9000001f8
  .quad 0x000001fb000001fa
  .quad 0x000001fd000001fc
  .quad 0x000001ff000001fe

h_coef0:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

h_coef1:
  .quad 0x0000000900000008
  .quad 0x0000000b0000000a
  .quad 0x0000000d0000000c
  .quad 0x0000000f0000000e

h_coef2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

h_coef3:
  .quad 0x0000001900000018
  .quad 0x0000001b0000001a
  .quad 0x0000001d0000001c
  .quad 0x0000001f0000001e

h_coef4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

h_coef5:
  .quad 0x0000002900000028
  .quad 0x0000002b0000002a
  .quad 0x0000002d0000002c
  .quad 0x0000002f0000002e

h_coef6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

h_coef7:
  .quad 0x0000003900000038
  .quad 0x0000003b0000003a
  .quad 0x0000003d0000003c
  .quad 0x0000003f0000003e

h_coef8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

h_coef9:
  .quad 0x0000004900000048
  .quad 0x0000004b0000004a
  .quad 0x0000004d0000004c
  .quad 0x0000004f0000004e

h_coef10:
  .quad 0x0000005100000050
  .quad 0x0000005300000052
  .quad 0x0000005500000054
  .quad 0x0000005700000056

h_coef11:
  .quad 0x0000005900000058
  .quad 0x0000005b0000005a
  .quad 0x0000005d0000005c
  .quad 0x0000005f0000005e

h_coef12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

h_coef13:
  .quad 0x0000006900000068
  .quad 0x0000006b0000006a
  .quad 0x0000006d0000006c
  .quad 0x0000006f0000006e

h_coef14:
  .quad 0x0000007100000070
  .quad 0x0000007300000072
  .quad 0x0000007500000074
  .quad 0x0000007700000076

h_coef15:
  .quad 0x0000007900000078
  .quad 0x0000007b0000007a
  .quad 0x0000007d0000007c
  .quad 0x0000007f0000007e

h_coef16:
  .quad 0x0000008100000080
  .quad 0x0000008300000082
  .quad 0x0000008500000084
  .quad 0x0000008700000086

h_coef17:
  .quad 0x0000008900000088
  .quad 0x0000008b0000008a
  .quad 0x0000008d0000008c
  .quad 0x0000008f0000008e

h_coef18:
  .quad 0x0000009100000090
  .quad 0x0000009300000092
  .quad 0x0000009500000094
  .quad 0x0000009700000096

h_coef19:
  .quad 0x0000009900000098
  .quad 0x0000009b0000009a
  .quad 0x0000009d0000009c
  .quad 0x0000009f0000009e

h_coef20:
  .quad 0x000000a1000000a0
  .quad 0x000000a3000000a2
  .quad 0x000000a5000000a4
  .quad 0x000000a7000000a6

h_coef21:
  .quad 0x000000a9000000a8
  .quad 0x000000ab000000aa
  .quad 0x000000ad000000ac
  .quad 0x000000af000000ae

h_coef22:
  .quad 0x000000b1000000b0
  .quad 0x000000b3000000b2
  .quad 0x000000b5000000b4
  .quad 0x000000b7000000b6

h_coef23:
  .quad 0x000000b9000000b8
  .quad 0x000000bb000000ba
  .quad 0x000000bd000000bc
  .quad 0x000000bf000000be

h_coef24:
  .quad 0x000000c1000000c0
  .quad 0x000000c3000000c2
  .quad 0x000000c5000000c4
  .quad 0x000000c7000000c6

h_coef25:
  .quad 0x000000c9000000c8
  .quad 0x000000cb000000ca
  .quad 0x000000cd000000cc
  .quad 0x000000cf000000ce

h_coef26:
  .quad 0x000000d1000000d0
  .quad 0x000000d3000000d2
  .quad 0x000000d5000000d4
  .quad 0x000000d7000000d6

h_coef27:
  .quad 0x000000d9000000d8
  .quad 0x000000db000000da
  .quad 0x000000dd000000dc
  .quad 0x000000df000000de

h_coef28:
  .quad 0x000000e1000000e0
  .quad 0x000000e3000000e2
  .quad 0x000000e5000000e4
  .quad 0x000000e7000000e6

h_coef29:
  .quad 0x000000e9000000e8
  .quad 0x000000eb000000ea
  .quad 0x000000ed000000ec
  .quad 0x000000ef000000ee

h_coef30:
  .quad 0x000000f1000000f0
  .quad 0x000000f3000000f2
  .quad 0x000000f5000000f4
  .quad 0x000000f7000000f6

h_coef31:
  .quad 0x000000f9000000f8
  .quad 0x000000fb000000fa
  .quad 0x000000fd000000fc
  .quad 0x000000ff000000fe

h_coef32:
  .quad 0x0000010100000100
  .quad 0x0000010300000102
  .quad 0x0000010500000104
  .quad 0x0000010700000106

h_coef33:
  .quad 0x0000010900000108
  .quad 0x0000010b0000010a
  .quad 0x0000010d0000010c
  .quad 0x0000010f0000010e

h_coef34:
  .quad 0x0000011100000110
  .quad 0x0000011300000112
  .quad 0x0000011500000114
  .quad 0x0000011700000116

h_coef35:
  .quad 0x0000011900000118
  .quad 0x0000011b0000011a
  .quad 0x0000011d0000011c
  .quad 0x0000011f0000011e

h_coef36:
  .quad 0x0000012100000120
  .quad 0x0000012300000122
  .quad 0x0000012500000124
  .quad 0x0000012700000126

h_coef37:
  .quad 0x0000012900000128
  .quad 0x0000012b0000012a
  .quad 0x0000012d0000012c
  .quad 0x0000012f0000012e

h_coef38:
  .quad 0x0000013100000130
  .quad 0x0000013300000132
  .quad 0x0000013500000134
  .quad 0x0000013700000136

h_coef39:
  .quad 0x0000013900000138
  .quad 0x0000013b0000013a
  .quad 0x0000013d0000013c
  .quad 0x0000013f0000013e

h_coef40:
  .quad 0x0000014100000140
  .quad 0x0000014300000142
  .quad 0x0000014500000144
  .quad 0x0000014700000146

h_coef41:
  .quad 0x0000014900000148
  .quad 0x0000014b0000014a
  .quad 0x0000014d0000014c
  .quad 0x0000014f0000014e

h_coef42:
  .quad 0x0000015100000150
  .quad 0x0000015300000152
  .quad 0x0000015500000154
  .quad 0x0000015700000156

h_coef43:
  .quad 0x0000015900000158
  .quad 0x0000015b0000015a
  .quad 0x0000015d0000015c
  .quad 0x0000015f0000015e

h_coef44:
  .quad 0x0000016100000160
  .quad 0x0000016300000162
  .quad 0x0000016500000164
  .quad 0x0000016700000166

h_coef45:
  .quad 0x0000016900000168
  .quad 0x0000016b0000016a
  .quad 0x0000016d0000016c
  .quad 0x0000016f0000016e

h_coef46:
  .quad 0x0000017100000170
  .quad 0x0000017300000172
  .quad 0x0000017500000174
  .quad 0x0000017700000176

h_coef47:
  .quad 0x0000017900000178
  .quad 0x0000017b0000017a
  .quad 0x0000017d0000017c
  .quad 0x0000017f0000017e

h_coef48:
  .quad 0x0000018100000180
  .quad 0x0000018300000182
  .quad 0x0000018500000184
  .quad 0x0000018700000186

h_coef49:
  .quad 0x0000018900000188
  .quad 0x0000018b0000018a
  .quad 0x0000018d0000018c
  .quad 0x0000018f0000018e

h_coef50:
  .quad 0x0000019100000190
  .quad 0x0000019300000192
  .quad 0x0000019500000194
  .quad 0x0000019700000196

h_coef51:
  .quad 0x0000019900000198
  .quad 0x0000019b0000019a
  .quad 0x0000019d0000019c
  .quad 0x0000019f0000019e

h_coef52:
  .quad 0x000001a1000001a0
  .quad 0x000001a3000001a2
  .quad 0x000001a5000001a4
  .quad 0x000001a7000001a6

h_coef53:
  .quad 0x000001a9000001a8
  .quad 0x000001ab000001aa
  .quad 0x000001ad000001ac
  .quad 0x000001af000001ae

h_coef54:
  .quad 0x000001b1000001b0
  .quad 0x000001b3000001b2
  .quad 0x000001b5000001b4
  .quad 0x000001b7000001b6

h_coef55:
  .quad 0x000001b9000001b8
  .quad 0x000001bb000001ba
  .quad 0x000001bd000001bc
  .quad 0x000001bf000001be

h_coef56:
  .quad 0x000001c1000001c0
  .quad 0x000001c3000001c2
  .quad 0x000001c5000001c4
  .quad 0x000001c7000001c6

h_coef57:
  .quad 0x000001c9000001c8
  .quad 0x000001cb000001ca
  .quad 0x000001cd000001cc
  .quad 0x000001cf000001ce

h_coef58:
  .quad 0x000001d1000001d0
  .quad 0x000001d3000001d2
  .quad 0x000001d5000001d4
  .quad 0x000001d7000001d6

h_coef59:
  .quad 0x000001d9000001d8
  .quad 0x000001db000001da
  .quad 0x000001dd000001dc
  .quad 0x000001df000001de

h_coef60:
  .quad 0x000001e1000001e0
  .quad 0x000001e3000001e2
  .quad 0x000001e5000001e4
  .quad 0x000001e7000001e6

h_coef61:
  .quad 0x000001e9000001e8
  .quad 0x000001eb000001ea
  .quad 0x000001ed000001ec
  .quad 0x000001ef000001ee

h_coef62:
  .quad 0x000001f1000001f0
  .quad 0x000001f3000001f2
  .quad 0x000001f5000001f4
  .quad 0x000001f7000001f6

h_coef63:
  .quad 0x000001f9000001f8
  .quad 0x000001fb000001fa
  .quad 0x000001fd000001fc
  .quad 0x000001ff000001fe

c0_coef0:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

c0_coef1:
  .quad 0x0000000900000008
  .quad 0x0000000b0000000a
  .quad 0x0000000d0000000c
  .quad 0x0000000f0000000e

c0_coef2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

c0_coef3:
  .quad 0x0000001900000018
  .quad 0x0000001b0000001a
  .quad 0x0000001d0000001c
  .quad 0x0000001f0000001e

c0_coef4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

c0_coef5:
  .quad 0x0000002900000028
  .quad 0x0000002b0000002a
  .quad 0x0000002d0000002c
  .quad 0x0000002f0000002e

c0_coef6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

c0_coef7:
  .quad 0x0000003900000038
  .quad 0x0000003b0000003a
  .quad 0x0000003d0000003c
  .quad 0x0000003f0000003e

c0_coef8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

c0_coef9:
  .quad 0x0000004900000048
  .quad 0x0000004b0000004a
  .quad 0x0000004d0000004c
  .quad 0x0000004f0000004e

c0_coef10:
  .quad 0x0000005100000050
  .quad 0x0000005300000052
  .quad 0x0000005500000054
  .quad 0x0000005700000056

c0_coef11:
  .quad 0x0000005900000058
  .quad 0x0000005b0000005a
  .quad 0x0000005d0000005c
  .quad 0x0000005f0000005e

c0_coef12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

c0_coef13:
  .quad 0x0000006900000068
  .quad 0x0000006b0000006a
  .quad 0x0000006d0000006c
  .quad 0x0000006f0000006e

c0_coef14:
  .quad 0x0000007100000070
  .quad 0x0000007300000072
  .quad 0x0000007500000074
  .quad 0x0000007700000076

c0_coef15:
  .quad 0x0000007900000078
  .quad 0x0000007b0000007a
  .quad 0x0000007d0000007c
  .quad 0x0000007f0000007e

c0_coef16:
  .quad 0x0000008100000080
  .quad 0x0000008300000082
  .quad 0x0000008500000084
  .quad 0x0000008700000086

c0_coef17:
  .quad 0x0000008900000088
  .quad 0x0000008b0000008a
  .quad 0x0000008d0000008c
  .quad 0x0000008f0000008e

c0_coef18:
  .quad 0x0000009100000090
  .quad 0x0000009300000092
  .quad 0x0000009500000094
  .quad 0x0000009700000096

c0_coef19:
  .quad 0x0000009900000098
  .quad 0x0000009b0000009a
  .quad 0x0000009d0000009c
  .quad 0x0000009f0000009e

c0_coef20:
  .quad 0x000000a1000000a0
  .quad 0x000000a3000000a2
  .quad 0x000000a5000000a4
  .quad 0x000000a7000000a6

c0_coef21:
  .quad 0x000000a9000000a8
  .quad 0x000000ab000000aa
  .quad 0x000000ad000000ac
  .quad 0x000000af000000ae

c0_coef22:
  .quad 0x000000b1000000b0
  .quad 0x000000b3000000b2
  .quad 0x000000b5000000b4
  .quad 0x000000b7000000b6

c0_coef23:
  .quad 0x000000b9000000b8
  .quad 0x000000bb000000ba
  .quad 0x000000bd000000bc
  .quad 0x000000bf000000be

c0_coef24:
  .quad 0x000000c1000000c0
  .quad 0x000000c3000000c2
  .quad 0x000000c5000000c4
  .quad 0x000000c7000000c6

c0_coef25:
  .quad 0x000000c9000000c8
  .quad 0x000000cb000000ca
  .quad 0x000000cd000000cc
  .quad 0x000000cf000000ce

c0_coef26:
  .quad 0x000000d1000000d0
  .quad 0x000000d3000000d2
  .quad 0x000000d5000000d4
  .quad 0x000000d7000000d6

c0_coef27:
  .quad 0x000000d9000000d8
  .quad 0x000000db000000da
  .quad 0x000000dd000000dc
  .quad 0x000000df000000de

c0_coef28:
  .quad 0x000000e1000000e0
  .quad 0x000000e3000000e2
  .quad 0x000000e5000000e4
  .quad 0x000000e7000000e6

c0_coef29:
  .quad 0x000000e9000000e8
  .quad 0x000000eb000000ea
  .quad 0x000000ed000000ec
  .quad 0x000000ef000000ee

c0_coef30:
  .quad 0x000000f1000000f0
  .quad 0x000000f3000000f2
  .quad 0x000000f5000000f4
  .quad 0x000000f7000000f6

c0_coef31:
  .quad 0x000000f9000000f8
  .quad 0x000000fb000000fa
  .quad 0x000000fd000000fc
  .quad 0x000000ff000000fe

c0_coef32:
  .quad 0x0000010100000100
  .quad 0x0000010300000102
  .quad 0x0000010500000104
  .quad 0x0000010700000106

c0_coef33:
  .quad 0x0000010900000108
  .quad 0x0000010b0000010a
  .quad 0x0000010d0000010c
  .quad 0x0000010f0000010e

c0_coef34:
  .quad 0x0000011100000110
  .quad 0x0000011300000112
  .quad 0x0000011500000114
  .quad 0x0000011700000116

c0_coef35:
  .quad 0x0000011900000118
  .quad 0x0000011b0000011a
  .quad 0x0000011d0000011c
  .quad 0x0000011f0000011e

c0_coef36:
  .quad 0x0000012100000120
  .quad 0x0000012300000122
  .quad 0x0000012500000124
  .quad 0x0000012700000126

c0_coef37:
  .quad 0x0000012900000128
  .quad 0x0000012b0000012a
  .quad 0x0000012d0000012c
  .quad 0x0000012f0000012e

c0_coef38:
  .quad 0x0000013100000130
  .quad 0x0000013300000132
  .quad 0x0000013500000134
  .quad 0x0000013700000136

c0_coef39:
  .quad 0x0000013900000138
  .quad 0x0000013b0000013a
  .quad 0x0000013d0000013c
  .quad 0x0000013f0000013e

c0_coef40:
  .quad 0x0000014100000140
  .quad 0x0000014300000142
  .quad 0x0000014500000144
  .quad 0x0000014700000146

c0_coef41:
  .quad 0x0000014900000148
  .quad 0x0000014b0000014a
  .quad 0x0000014d0000014c
  .quad 0x0000014f0000014e

c0_coef42:
  .quad 0x0000015100000150
  .quad 0x0000015300000152
  .quad 0x0000015500000154
  .quad 0x0000015700000156

c0_coef43:
  .quad 0x0000015900000158
  .quad 0x0000015b0000015a
  .quad 0x0000015d0000015c
  .quad 0x0000015f0000015e

c0_coef44:
  .quad 0x0000016100000160
  .quad 0x0000016300000162
  .quad 0x0000016500000164
  .quad 0x0000016700000166

c0_coef45:
  .quad 0x0000016900000168
  .quad 0x0000016b0000016a
  .quad 0x0000016d0000016c
  .quad 0x0000016f0000016e

c0_coef46:
  .quad 0x0000017100000170
  .quad 0x0000017300000172
  .quad 0x0000017500000174
  .quad 0x0000017700000176

c0_coef47:
  .quad 0x0000017900000178
  .quad 0x0000017b0000017a
  .quad 0x0000017d0000017c
  .quad 0x0000017f0000017e

c0_coef48:
  .quad 0x0000018100000180
  .quad 0x0000018300000182
  .quad 0x0000018500000184
  .quad 0x0000018700000186

c0_coef49:
  .quad 0x0000018900000188
  .quad 0x0000018b0000018a
  .quad 0x0000018d0000018c
  .quad 0x0000018f0000018e

c0_coef50:
  .quad 0x0000019100000190
  .quad 0x0000019300000192
  .quad 0x0000019500000194
  .quad 0x0000019700000196

c0_coef51:
  .quad 0x0000019900000198
  .quad 0x0000019b0000019a
  .quad 0x0000019d0000019c
  .quad 0x0000019f0000019e

c0_coef52:
  .quad 0x000001a1000001a0
  .quad 0x000001a3000001a2
  .quad 0x000001a5000001a4
  .quad 0x000001a7000001a6

c0_coef53:
  .quad 0x000001a9000001a8
  .quad 0x000001ab000001aa
  .quad 0x000001ad000001ac
  .quad 0x000001af000001ae

c0_coef54:
  .quad 0x000001b1000001b0
  .quad 0x000001b3000001b2
  .quad 0x000001b5000001b4
  .quad 0x000001b7000001b6

c0_coef55:
  .quad 0x000001b9000001b8
  .quad 0x000001bb000001ba
  .quad 0x000001bd000001bc
  .quad 0x000001bf000001be

c0_coef56:
  .quad 0x000001c1000001c0
  .quad 0x000001c3000001c2
  .quad 0x000001c5000001c4
  .quad 0x000001c7000001c6

c0_coef57:
  .quad 0x000001c9000001c8
  .quad 0x000001cb000001ca
  .quad 0x000001cd000001cc
  .quad 0x000001cf000001ce

c0_coef58:
  .quad 0x000001d1000001d0
  .quad 0x000001d3000001d2
  .quad 0x000001d5000001d4
  .quad 0x000001d7000001d6

c0_coef59:
  .quad 0x000001d9000001d8
  .quad 0x000001db000001da
  .quad 0x000001dd000001dc
  .quad 0x000001df000001de

c0_coef60:
  .quad 0x000001e1000001e0
  .quad 0x000001e3000001e2
  .quad 0x000001e5000001e4
  .quad 0x000001e7000001e6

c0_coef61:
  .quad 0x000001e9000001e8
  .quad 0x000001eb000001ea
  .quad 0x000001ed000001ec
  .quad 0x000001ef000001ee

c0_coef62:
  .quad 0x000001f1000001f0
  .quad 0x000001f3000001f2
  .quad 0x000001f5000001f4
  .quad 0x000001f7000001f6

c0_coef63:
  .quad 0x000001f9000001f8
  .quad 0x000001fb000001fa
  .quad 0x000001fd000001fc
  .quad 0x000001ff000001fe

tt_coef0:
  .quad 0x0000263d000022a1
  .quad 0x00001f54000004c3
  .quad 0x00002552000025ae
  .quad 0x00000fcd0000263a