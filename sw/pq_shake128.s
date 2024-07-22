/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* SHAKE-128 Implementation */

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
bn.lid x2++, 256(x0)

/* Padding the message */
bn.addi w12, w0, 31
bn.or w11, w11, w12 << 16

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
bn.or w18, w18, w19 << 56

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
/* Uncomment the following lines to check padding
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


ecall */

/* Squeeze three times*/
li x2, 0
loopi 3, 100

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


/* Store results from [w0-w9] to dmem */
li x4, 0

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

addi x2, x2, 320

/* Load DMEM(0) into WDR w31*/
li x3, 0
li x4, 31
bn.lid x4, 0(x3++)

/* Load round counter (rc0) into PQSR*/
pq.pqsrw 8, w31

ecall


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
  
.globl nonce
nonce:
  .word 0x00000B0A


