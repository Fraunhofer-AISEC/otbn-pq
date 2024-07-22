/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* SampleInBall Implementation */

.section .text.start

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load operands into WDRs */
li x2, 0
li x3, 0
li x4, 31
li x5, 96

/* Load DMEM(0) into WDR w31*/
bn.lid x4, 0(x3++)

/* Load round counter (rc0) into PQSR*/
pq.pqsrw 8, w31


/*************************************************/
/*                Load Inital State              */
/*************************************************/

/* Load inital state into WDRs w0 - w9 */

/* A[3,0] A[2,0] A[1,0] A[0,0] */
bn.lid x2++, 192(x0) 

/* A[4,0] */
bn.lid x2++, 192(x0)

/* A[3,1] A[2,1] A[1,1] A[0,1] */
bn.lid x2++, 192(x0) 

/* A[4,1] */
bn.lid x2++, 192(x0)

/* A[3,2] A[2,2] A[1,2] A[0,2] */
bn.lid x2++, 192(x0) 

/* A[4,2] */
bn.lid x2++, 192(x0) 

/* A[3,3] A[2,3] A[1,3] A[0,3] */
bn.lid x2++, 192(x0)

/* A[4,3] */
bn.lid x2++, 192(x0) 

/* A[3,4] A[2,4] A[1,4] A[0,4] */
bn.lid x2++, 192(x0)

/* A[4,4] */
bn.lid x2++, 192(x0) 

/*************************************************/
/*              Load Message and Nonce           */
/*************************************************/

/* M[3,0] M[2,0] M[1,0] M[0,0] */
bn.lid x2++, 224(x0) 

/* M[4,0] */
bn.lid x2++, 192(x0)

/* Padding the message */
bn.addi w12, w0, 31
bn.or w11, w11, w12

/* M[3,1] M[2,1] M[1,1] M[0,1] */
bn.lid x2++, 192(x0)

/* M[4,1] */
bn.lid x2++, 192(x0)

/* M[3,2] M[2,2] M[1,2] M[0,2] */
bn.lid x2++, 192(x0)

/* M[4,2] */
bn.lid x2++, 192(x0)

/* M[3,3] M[2,3] M[1,3] M[0,3] */
bn.lid x2++, 192(x0)

/* M[4,3] */
bn.lid x2++, 192(x0)

/* M[3,4] M[2,4] M[1,4] M[0,4] */
bn.lid x2++, 192(x0)

/* Padding the message */
bn.lid x2, 192(x0)
bn.addi w19, w19, 128
bn.or w16, w16, w19 << 120

/* M[4,4] */
bn.lid x2, 192(x0)

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

/* Check correct padding */
/* Uncomment the following lines to check padding */
li x4, 0
li x2, 0

bn.sid x4++, 2048(x2)
bn.sid x4++, 2080(x2)

bn.sid x4++, 2112(x2)
bn.sid x4++, 2144(x2)

bn.sid x4++, 2176(x2)
bn.sid x4++, 2208(x2)

bn.sid x4++, 2240(x2)
bn.sid x4++, 2272(x2)

bn.sid x4++, 2304(x2)
bn.sid x4++, 2336(x2)


/* Call Keccak Permuation function */
li x5, 0
jal x1, keccak_permutation


/*************************************************/
/*                  SampleInBall                 */
/*
* @param[in] w0-w9: keccak state
* @param[out] DMEM[1024+i]: sampled challenge coefficients
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
*
*
*
*
*
*
*
*
/*************************************************/

/* Write shake256 output to memory --> transfer to GPRs */
li x4, 0
li x2, 0

bn.sid x4++, 544(x2)
bn.sid x4++, 576(x2)

bn.sid x4++, 608(x2)
bn.sid x4++, 640(x2)

bn.sid x4++, 672(x2)
bn.sid x4++, 704(x2)

bn.sid x4++, 736(x2)
bn.sid x4++, 768(x2)

bn.sid x4++, 800(x2)
bn.sid x4++, 832(x2)

/* Store Sign Bytes (first 8 bytes) in x6 & x7*/
lw x6, 544(x2)
addi x2, x2, 4
lw x7, 544(x2)
addi x2, x2, 4
li x8, 31

/* Init challenge polynomial */

/* Initialize challenge address space with zeros */
li x5, 0
loopi 256, 2
  sw x0, 1024(x5)
  addi x5, x5, 4

/* Load N-TAU(i) in x10 */
li x10, 217
/* Load sample in x12 */
lw x12, 544(x2)
addi x2, x2, 4

/* Count bytes in x12 over x17 */
li x17, 4

/* Load SHAKE256 rate in x11 */
li x11, 136
/* li x2, 0 */

/* Repeat TAU times to create Tau +/- 1's */
loopi 39, 53

loop_while_b_greater_i:

/* Check if x2 > SHAKE256 rate */
bne x2, x11, skip_shake256

/* Call Keccak Permuation function */
li x5, 0
jal x1, keccak_permutation

/* Write shake256 output to memory --> transfer to GPRs */
li x4, 0
li x2, 0

bn.sid x4++, 544(x2)
bn.sid x4++, 576(x2)

bn.sid x4++, 608(x2)
bn.sid x4++, 640(x2)

bn.sid x4++, 672(x2)
bn.sid x4++, 704(x2)

bn.sid x4++, 736(x2)
bn.sid x4++, 768(x2)

bn.sid x4++, 800(x2)
bn.sid x4++, 832(x2)

/* Load SHAKE256 rate in x11 */
li x11, 136
li x2, 0

skip_shake256:

/* Store in x12 & mask in x13 */
bne x17, x0, skip_load_sample
lw x12, 544(x2)

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
/* Shif MSB to pos[0] */
srli x15, x15, 31

/* Check if b =< i */
beq x15, x0, loop_while_b_greater_i

/* Sample +/- 1*/

/* c->coeffs[i] = c->coeffs[b] */
/* lw x18, 1024(x14*4) */
slli x16, x14, 2
lw x18, 1024(x16)

/* sw x18, 1024(x10*4) */
slli x16, x10, 2
sw x18, 1024(x16)

/* c->coeffs[b] = 1 - 2*(signs & 1) */
and x18, x0, x0

/* +1 or -1 depending on sign */
andi x19, x6, 1
beq x19, x0, plus_one


minus_one:

addi x18, x18, -1
beq x0, x0, next_sign

plus_one:

addi x18, x18, 1
beq x0, x0, next_sign


next_sign:

/* Store c->coeffs[b] */
slli x16, x14, 2
sw x18, 1024(x16)

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


li x31, 1
li x31, 2
li x31, 3
li x31, 4
li x31, 5
li x31, 6
li x31, 7
li x31, 8
li x31, 9
li x31, 10
li x31, 11

ecall


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



.section .data

/* 256-bit integer

   0000000000000000 0000000000000000
   0000000000000000 0000000000000D01

   (.quad below is in reverse order) */

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
  
.globl message
message:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  
.globl message
nonce:
  .word 0x00000B0A


