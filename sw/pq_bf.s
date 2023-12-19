/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* PQ Buttefly example for kyber prime. Loads two 256-bit words from DMem into w1, w0.
   Butterfly Operations using PQ.CTBF and PQ.GSBF for montgomery multiplication with the results placed into w3, w2 */

.section .text

/* Load operands into WDRs */
li x2, 0
li x3, 1
li x4, 32
li x5, 64
li x6, 9
li x7, 10
li x8, 96
li x9, 11
li x10, 128
li x11, 12
li x12, 160

/* Load DMEM(0) into WDR w0*/
bn.lid x2, 0(x0)

/* Load DMEM(32) into WDR w1*/
bn.lid x3, 0(x4)

/* Load DMEM(64) into WDR w9*/
bn.lid x6, 0(x5)

/* Load DMEM(96) into WDR w10*/
bn.lid x7, 0(x8)

/* Load DMEM(128) into WDR w11*/
bn.lid x9, 0(x10)

/* Load DMEM(160) into WDR w12*/
bn.lid x11, 0(x12)


/* Load prime into PQSR*/
pq.pqsrw 0, w9

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w10

/* Load omega into PQSR*/
pq.pqsrw 3, w12

/* Load psi into PQSR*/
pq.pqsrw 4, w11


/* Perform the arithmetic, limbs are 32-bit. Each instance of pq.mul will
   operate on one limb as a 32-bit pq.mul produces a 32-bit result. */


/* Set Psi as Twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w1.0, w1.4
pq.ctbf w1.1, w1.5
pq.ctbf w1.2, w1.6
pq.ctbf w1.3, w1.7

/* Increment Omega Idx and Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 1

/* Set Psi as Twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w1.0, w1.2
pq.ctbf w1.1, w1.3

/* Increment Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 0

/* Set Psi as Twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w1.4, w1.6
pq.ctbf w1.5, w1.7

/* Increment Omega Idx and Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 1

/* Set Psi as Twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w1.0, w1.1

/* Increment Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 0

/* Set Psi as Twiddle */

pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w1.4, w1.5

/* Increment Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 0

/* Set Psi as Twiddle */

pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w1.2, w1.3

/* Increment Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 0

/* Set Psi as Twiddle */

pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w1.6, w1.7


/* store result from [w1] to dmem */
li x4, 1
bn.sid x4, 512(x0)


/* Load DMEM(192) into WDR w12*/
li x12, 192
bn.lid x9, 0(x12)

/* Increment Omega Idx and Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 1

/* Increment Omega Idx and Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 1

/* Load psi into PQSR*/
pq.pqsrw 4, w11


/* Set Psi as Twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w1.0, w1.1

/* Increment Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 0

/* Set Psi as Twiddle */

pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w1.4, w1.5

/* Increment Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 0

/* Set Psi as Twiddle */

pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w1.2, w1.3

/* Increment Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 0

/* Set Psi as Twiddle */

pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w1.6, w1.7

/* Increment Omega Idx and Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 1

/* Set Psi as Twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w1.0, w1.2
pq.gsbf w1.1, w1.3

/* Increment Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 0

/* Set Psi as Twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w1.4, w1.6
pq.gsbf w1.5, w1.7

/* Increment Omega Idx and Psi Idx */
pq.pqsru 0, 0, 0, 0, 0, 1, 1

/* Set Psi as Twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w1.0, w1.4
pq.gsbf w1.1, w1.5
pq.gsbf w1.2, w1.6
pq.gsbf w1.3, w1.7

/* store result from [w1] to dmem */
li x4, 1
bn.sid x4, 544(x0)

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

   0047152200692177 004b310b002d409f
   000f503300713fc8 00534f5c00355ef0

   (.quad below is in reverse order) */

operand2:
  .quad 0x00534f5c00355ef0
  .quad 0x000f503300713fc8
  .quad 0x004b310b002d409f
  .quad 0x000731e200692177

/* 256-bit integer

   0000000000000000 0000000000000000
   0000000000000000 0000000000000D01

   (.quad below is in reverse order) */

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

psi:
  .quad 0x0043e6e600294a67
  .quad 0x001fea9300688c82
  .quad 0x0033ff5a002358d4
  .quad 0x00000008003a41f8

omega:
  .quad 0x00294a6700299658
  .quad 0x000000100043e6e6
  .quad 0x0000002400000019
  .quad 0x0000004000000031

psi_inv:
  .quad 0x006a81990061b633
  .quad 0x0043ca37000ce94a
  .quad 0x00375fa900454828
  .quad 0x00000008002ab0d3

/* Expected result is
   w3 =
   00000898 0000001e 000003b3 00000038
   00000b67 000000f5 000008c1 00000bc3

   w2 =
   00000042 00000019 000004b5 00000024
   000007da 00000031 0000055c 00000040 */
