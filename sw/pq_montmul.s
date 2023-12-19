/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* PQ Multiplication example for kyber prime. Loads two 256-bit words from DMem into w1, w0.
   Multiply using PQ.MUL for montgomery multiplication with the results placed into w3, w2 */

.section .text

/* Load operands into WDRs */
li x2, 0
li x3, 1
li x4, 32
li x5, 64
li x6, 9
li x7, 10
li x8, 96

/* Load DMEM(0) into WDR w0*/
bn.lid x2, 0(x0)

/* Load DMEM(32) into WDR w1*/
bn.lid x3, 0(x4)

/* Load DMEM(64) into WDR w9*/
bn.lid x6, 0(x5)

/* Load DMEM(71) into WDR w10*/
bn.lid x7, 0(x8)

/* Load prime into PQSR*/
pq.pqsrw 0, w9

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w10

/* Perform the arithmetic, limbs are 32-bit. Each instance of pq.mul will
   operate on one limb as a 32-bit pq.mul produces a 32-bit result. */

pq.mul w1.0, w0.0, w1.0
pq.mul w1.1, w0.0, w1.1
pq.mul w1.2, w0.0, w1.2
pq.mul w1.3, w0.0, w1.3
pq.mul w1.4, w0.0, w1.4
pq.mul w1.5, w0.0, w1.5
pq.mul w1.6, w0.0, w1.6
pq.mul w1.7, w0.0, w1.7

pq.mul w2.0, w1.0, w1.0
pq.mul w2.1, w1.1, w1.1
pq.mul w2.2, w1.2, w1.2
pq.mul w2.3, w1.3, w1.3
pq.mul w2.4, w1.4, w1.4
pq.mul w2.5, w1.5, w1.5
pq.mul w2.6, w1.6, w1.6
pq.mul w2.7, w1.7, w1.7

pq.mul w3.0, w1.0, w1.1
pq.mul w3.1, w1.2, w1.3
pq.mul w3.2, w1.4, w1.5
pq.mul w3.3, w1.6, w1.7
pq.mul w3.4, w1.0, w1.2
pq.mul w3.5, w1.1, w1.3
pq.mul w3.6, w1.4, w1.6
pq.mul w3.7, w1.5, w1.7

pq.mul w2.0, w2.0, w0.1
pq.mul w2.1, w2.1, w0.1
pq.mul w2.2, w2.2, w0.1
pq.mul w2.3, w2.3, w0.1
pq.mul w2.4, w2.4, w0.1
pq.mul w2.5, w2.5, w0.1
pq.mul w2.6, w2.6, w0.1
pq.mul w2.7, w2.7, w0.1

pq.mul w3.0, w3.0, w0.1
pq.mul w3.1, w3.1, w0.1
pq.mul w3.2, w3.2, w0.1
pq.mul w3.3, w3.3, w0.1
pq.mul w3.4, w3.4, w0.1
pq.mul w3.5, w3.5, w0.1
pq.mul w3.6, w3.6, w0.1
pq.mul w3.7, w3.7, w0.1

/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 512(x0)
bn.sid x4++, 544(x0)

ecall

.section .data

/* 256-bit integer

   0000000100000bac 0000000100000bac
   0000000100000bac 0000000100000bac

   (.quad below is in reverse order) */

operand1:
  .quad 0x0000000100000bac
  .quad 0x0000000100000bac
  .quad 0x0000000100000bac
  .quad 0x0000000100000bac


/* 256-bit integer

   00000caf00000005 00000aff00000006
   00000a8a00000007 0000099900000008

   (.quad below is in reverse order) */

operand2:
  .quad 0x0000099900000008
  .quad 0x00000a8a00000007
  .quad 0x00000aff00000006
  .quad 0x00000caf00000005

/* 256-bit integer

   0000000000000000 0000000000000000
   0000000000000000 0000000000000D01

   (.quad below is in reverse order) */

prime:
  .quad 0x0000000000000D01
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

prime_dash:
  .quad 0x0000000094570cff
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

/* Expected result is
   w3 =
   00000898 0000001e 000003b3 00000038
   00000b67 000000f5 000008c1 00000bc3

   w2 =
   00000042 00000019 000004b5 00000024
   000007da 00000031 0000055c 00000040 */
