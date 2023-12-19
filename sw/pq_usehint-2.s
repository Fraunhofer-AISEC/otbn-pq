/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* UseHint Implementation */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load DMEM(0) into WDR w0*/
li x2, 0
bn.lid x2, 32(x0)

/* Load prime into PQSR*/
pq.pqsrw 0, w0

li x4, 32
li x5, 0
li x6, 64

/* Address of Coefficients: 0 */
li x4, 0
jal x1, decompose

li x4, 15
bn.sid x4++, 2048(x2)
addi x2, x2, 32
bn.sid x4, 2048(x2)

/* Address of Coefficients: 0 */
li x4, 0

/* Address of Hint Coefficients: */
li x5, 128

/* Load Hint coefficients from Address in x5 into WDR 9 */
li x3, 20
bn.lid x3, 0(x5++)

jal x1, use_hint

li x4, 10
bn.sid x4, 1024(x0)

ecall

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
bn.lid x3, 96(x0)

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
bn.lid x3, 32(x0) 

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
bn.and w11, w8, w10
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

coef0:
  .word 0x04E852F7
/* Decomposition of 0x04E852F7 should result in 
     a1 = 0xffffffb0
     a0 = 0x0550f2f6
*/

coef1:
  .word 0x00000000
/* Decomposition of 0x00000000 should result in 
     a1 = 0x00000000
     a0 = 0x00000000
*/

coef2:
  .word 0x007fe000
/* Decomposition of 0x007fe000 should result in 
     a1 = 0x00000000
     a0 = 0xffffffff
*/

coef3:
  .word 0x00000010
/* Decomposition of 0x00000010 should result in 
     a1 = 0x00000018
     a0 = 0x00000010
*/

coef4:
  .word 0x0044db78
/* Decomposition of 0x0044db78 should result in 
     a1 = 0xffffffb0
     a0 = 0xffff1b78
*/ 
 
coef5:
  .word 0x0002a6a3
/* Decomposition of 0x0002a6a3 should result in 
     a1 = 0x00000001
     a0 = 0xffffbea3
*/

coef6:
  .word 0x00000548
/* Decomposition of 0x00000548 should result in 
     a1 = 0x00000000
     a0 = 0x00000548
*/

coef7:
  .word 0x00029057
/* Decomposition of 0x00029057 should result in 
     a1 = 0x00000001
     a0 = 0xffffa857
*/

bitmask32:
  .word 0xFFFFFFFF

bitmask_extended: 
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
 
allzero: 
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

prime:
  .quad 0x00000000007fe001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  
hint_coeff0:
  .word 0x000000AA
  
hint_coeff1:
  .word 0x00000001
  
hint_coeff2:
  .word 0x00000000
  
hint_coeff3:
  .word 0x00000001
  
hint_coeff4:
  .word 0x00000000
  
hint_coeff5:
  .word 0x00000001
  
hint_coeff6:
  .word 0x00000000
  
hint_coeff7:
  .word 0x00000001
