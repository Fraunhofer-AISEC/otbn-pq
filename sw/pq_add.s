/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* PQ addition and subtraction example for kyber prime. Loads two 256-bit words from DMem into w1, w0.
   Arithmetic using PQ.ADD and PQ.SUB with the results placed into w3, w2 */

.section .text

/* Load operands into WDRs */
li x2, 0
li x3, 1
li x4, 32
li x5, 64
li x7, 72
li x6, 9

/* Load DMEM(0) into WDR w0*/
bn.lid x2, 0(x0)

/* Load DMEM(32) into WDR w1*/
bn.lid x3, 0(x4)

/* Load DMEM(64) into WDR w9*/
bn.lid x6, 0(x5)

/* Load prime into PQSR*/
pq.pqsrw 0, w9

/* Perform the arithmetic, limbs are 32-bit. Each instance of pq.add/pq.sub will
   operate on one limb as a 32-bit pq.add/pq.sub produces a 32-bit result. */

pq.add w2.0, w0.0, w1.0
pq.sub w3.0, w0.0, w1.0
pq.add w2.1, w0.1, w1.1
pq.sub w3.1, w0.1, w1.1
pq.add w2.2, w0.2, w1.2
pq.sub w3.2, w0.2, w1.2
pq.add w2.3, w0.3, w1.3
pq.sub w3.3, w0.3, w1.3
pq.add w2.4, w0.4, w1.4
pq.sub w3.4, w0.4, w1.4
pq.add w2.5, w0.5, w1.5
pq.sub w3.5, w0.5, w1.5
pq.add w2.6, w0.6, w1.6
pq.sub w3.6, w0.6, w1.6
pq.add w2.7, w0.7, w1.7
pq.sub w3.7, w0.7, w1.7


/* store result from [w2, w3] to dmem */
li x4, 2
bn.sid x4++, 512(x0)
bn.sid x4++, 544(x0)

ecall

.section .data

/* 256-bit integer

   00000d0000000001 000001a500000002
   000003e700000003 000004d200000004

   (.quad below is in reverse order) */

operand1:
  .quad 0x000004d200000004
  .quad 0x000003e700000003
  .quad 0x000001a500000002
  .quad 0x00000d0000000001


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

/* Expected result is
   w3 =
   00000051 00000cfd 000003a7 00000cfd
   0000065e 00000cfd 0000083a 00000cfd

   w2 =
   00000cae 00000006 00000ca4 00000008
   00000170 0000000a 0000016a 0000000c */
