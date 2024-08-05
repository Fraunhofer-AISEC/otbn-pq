/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* PQ Buttefly example for kyber prime. Loads two 256-bit words from DMem into w1, w0.
   Butterfly Operations using PQ.CTBF and PQ.GSBF for montgomery multiplication with the results placed into w3, w2 */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load operands into WDRs */
li x2, 0
li x3, 32
li x4, 64
li x5, 96

/* Load DMEM(0) into WDR w0*/
bn.lid x2, 0(x0)

/* Load prime into PQSR*/
pq.pqsrw 0, w0


/* Load DMEM(32) into WDR w0*/
bn.lid x2, 0(x3)

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w0


/* Load DMEM(64) into WDR w0*/
bn.lid x2, 0(x4)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load DMEM(96) into WDR w0*/
bn.lid x2, 0(x5)

/* Load psi into PQSR*/
pq.pqsrw 4, w0

/*************************************************/
/*                Load Coefficients              */
/*************************************************/

/* Load DMEM(0) into WDR w0*/

bn.lid x2++, 128(x0)
bn.lid x2++, 160(x0)
bn.lid x2++, 192(x0)
bn.lid x2++, 224(x0)

bn.lid x2++, 256(x0)
bn.lid x2++, 288(x0)
bn.lid x2++, 320(x0)
bn.lid x2++, 352(x0)

bn.lid x2++, 384(x0)
bn.lid x2++, 416(x0)
bn.lid x2++, 448(x0)
bn.lid x2++, 480(x0)

bn.lid x2++, 512(x0)
bn.lid x2++, 544(x0)
bn.lid x2++, 576(x0)
bn.lid x2++, 608(x0)

bn.lid x2++, 640(x0)
bn.lid x2++, 672(x0)
bn.lid x2++, 704(x0)
bn.lid x2++, 736(x0)

bn.lid x2++, 768(x0)
bn.lid x2++, 800(x0)
bn.lid x2++, 832(x0)
bn.lid x2++, 864(x0)

bn.lid x2++, 896(x0)
bn.lid x2++, 928(x0)
bn.lid x2++, 960(x0)
bn.lid x2++, 992(x0)

bn.lid x2++, 1024(x0)
bn.lid x2++, 1056(x0)
bn.lid x2++, 1088(x0)
bn.lid x2, 1120(x0)



/*************************************************/
/*                 NTT-Layer:128                 */
/*************************************************/
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w0.0, w16.0
pq.ctbf w0.1, w16.1
pq.ctbf w0.2, w16.2
pq.ctbf w0.3, w16.3
pq.ctbf w0.4, w16.4
pq.ctbf w0.5, w16.5
pq.ctbf w0.6, w16.6
pq.ctbf w0.7, w16.7
pq.ctbf w1.0, w17.0
pq.ctbf w1.1, w17.1
pq.ctbf w1.2, w17.2
pq.ctbf w1.3, w17.3
pq.ctbf w1.4, w17.4
pq.ctbf w1.5, w17.5
pq.ctbf w1.6, w17.6
pq.ctbf w1.7, w17.7
pq.ctbf w2.0, w18.0
pq.ctbf w2.1, w18.1
pq.ctbf w2.2, w18.2
pq.ctbf w2.3, w18.3
pq.ctbf w2.4, w18.4
pq.ctbf w2.5, w18.5
pq.ctbf w2.6, w18.6
pq.ctbf w2.7, w18.7
pq.ctbf w3.0, w19.0
pq.ctbf w3.1, w19.1
pq.ctbf w3.2, w19.2
pq.ctbf w3.3, w19.3
pq.ctbf w3.4, w19.4
pq.ctbf w3.5, w19.5
pq.ctbf w3.6, w19.6
pq.ctbf w3.7, w19.7
pq.ctbf w4.0, w20.0
pq.ctbf w4.1, w20.1
pq.ctbf w4.2, w20.2
pq.ctbf w4.3, w20.3
pq.ctbf w4.4, w20.4
pq.ctbf w4.5, w20.5
pq.ctbf w4.6, w20.6
pq.ctbf w4.7, w20.7
pq.ctbf w5.0, w21.0
pq.ctbf w5.1, w21.1
pq.ctbf w5.2, w21.2
pq.ctbf w5.3, w21.3
pq.ctbf w5.4, w21.4
pq.ctbf w5.5, w21.5
pq.ctbf w5.6, w21.6
pq.ctbf w5.7, w21.7
pq.ctbf w6.0, w22.0
pq.ctbf w6.1, w22.1
pq.ctbf w6.2, w22.2
pq.ctbf w6.3, w22.3
pq.ctbf w6.4, w22.4
pq.ctbf w6.5, w22.5
pq.ctbf w6.6, w22.6
pq.ctbf w6.7, w22.7
pq.ctbf w7.0, w23.0
pq.ctbf w7.1, w23.1
pq.ctbf w7.2, w23.2
pq.ctbf w7.3, w23.3
pq.ctbf w7.4, w23.4
pq.ctbf w7.5, w23.5
pq.ctbf w7.6, w23.6
pq.ctbf w7.7, w23.7
pq.ctbf w8.0, w24.0
pq.ctbf w8.1, w24.1
pq.ctbf w8.2, w24.2
pq.ctbf w8.3, w24.3
pq.ctbf w8.4, w24.4
pq.ctbf w8.5, w24.5
pq.ctbf w8.6, w24.6
pq.ctbf w8.7, w24.7
pq.ctbf w9.0, w25.0
pq.ctbf w9.1, w25.1
pq.ctbf w9.2, w25.2
pq.ctbf w9.3, w25.3
pq.ctbf w9.4, w25.4
pq.ctbf w9.5, w25.5
pq.ctbf w9.6, w25.6
pq.ctbf w9.7, w25.7
pq.ctbf w10.0, w26.0
pq.ctbf w10.1, w26.1
pq.ctbf w10.2, w26.2
pq.ctbf w10.3, w26.3
pq.ctbf w10.4, w26.4
pq.ctbf w10.5, w26.5
pq.ctbf w10.6, w26.6
pq.ctbf w10.7, w26.7
pq.ctbf w11.0, w27.0
pq.ctbf w11.1, w27.1
pq.ctbf w11.2, w27.2
pq.ctbf w11.3, w27.3
pq.ctbf w11.4, w27.4
pq.ctbf w11.5, w27.5
pq.ctbf w11.6, w27.6
pq.ctbf w11.7, w27.7
pq.ctbf w12.0, w28.0
pq.ctbf w12.1, w28.1
pq.ctbf w12.2, w28.2
pq.ctbf w12.3, w28.3
pq.ctbf w12.4, w28.4
pq.ctbf w12.5, w28.5
pq.ctbf w12.6, w28.6
pq.ctbf w12.7, w28.7
pq.ctbf w13.0, w29.0
pq.ctbf w13.1, w29.1
pq.ctbf w13.2, w29.2
pq.ctbf w13.3, w29.3
pq.ctbf w13.4, w29.4
pq.ctbf w13.5, w29.5
pq.ctbf w13.6, w29.6
pq.ctbf w13.7, w29.7
pq.ctbf w14.0, w30.0
pq.ctbf w14.1, w30.1
pq.ctbf w14.2, w30.2
pq.ctbf w14.3, w30.3
pq.ctbf w14.4, w30.4
pq.ctbf w14.5, w30.5
pq.ctbf w14.6, w30.6
pq.ctbf w14.7, w30.7
pq.ctbf w15.0, w31.0
pq.ctbf w15.1, w31.1
pq.ctbf w15.2, w31.2
pq.ctbf w15.3, w31.3
pq.ctbf w15.4, w31.4
pq.ctbf w15.5, w31.5
pq.ctbf w15.6, w31.6
pq.ctbf w15.7, w31.7

/*************************************************/
/*                 NTT-Layer:64                 */
/*************************************************/

pq.pqsru 0, 0, 0, 0, 0, 1, 1
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w0.0, w8.0
pq.ctbf w0.1, w8.1
pq.ctbf w0.2, w8.2
pq.ctbf w0.3, w8.3
pq.ctbf w0.4, w8.4
pq.ctbf w0.5, w8.5
pq.ctbf w0.6, w8.6
pq.ctbf w0.7, w8.7
pq.ctbf w1.0, w9.0
pq.ctbf w1.1, w9.1
pq.ctbf w1.2, w9.2
pq.ctbf w1.3, w9.3
pq.ctbf w1.4, w9.4
pq.ctbf w1.5, w9.5
pq.ctbf w1.6, w9.6
pq.ctbf w1.7, w9.7
pq.ctbf w2.0, w10.0
pq.ctbf w2.1, w10.1
pq.ctbf w2.2, w10.2
pq.ctbf w2.3, w10.3
pq.ctbf w2.4, w10.4
pq.ctbf w2.5, w10.5
pq.ctbf w2.6, w10.6
pq.ctbf w2.7, w10.7
pq.ctbf w3.0, w11.0
pq.ctbf w3.1, w11.1
pq.ctbf w3.2, w11.2
pq.ctbf w3.3, w11.3
pq.ctbf w3.4, w11.4
pq.ctbf w3.5, w11.5
pq.ctbf w3.6, w11.6
pq.ctbf w3.7, w11.7
pq.ctbf w4.0, w12.0
pq.ctbf w4.1, w12.1
pq.ctbf w4.2, w12.2
pq.ctbf w4.3, w12.3
pq.ctbf w4.4, w12.4
pq.ctbf w4.5, w12.5
pq.ctbf w4.6, w12.6
pq.ctbf w4.7, w12.7
pq.ctbf w5.0, w13.0
pq.ctbf w5.1, w13.1
pq.ctbf w5.2, w13.2
pq.ctbf w5.3, w13.3
pq.ctbf w5.4, w13.4
pq.ctbf w5.5, w13.5
pq.ctbf w5.6, w13.6
pq.ctbf w5.7, w13.7
pq.ctbf w6.0, w14.0
pq.ctbf w6.1, w14.1
pq.ctbf w6.2, w14.2
pq.ctbf w6.3, w14.3
pq.ctbf w6.4, w14.4
pq.ctbf w6.5, w14.5
pq.ctbf w6.6, w14.6
pq.ctbf w6.7, w14.7
pq.ctbf w7.0, w15.0
pq.ctbf w7.1, w15.1
pq.ctbf w7.2, w15.2
pq.ctbf w7.3, w15.3
pq.ctbf w7.4, w15.4
pq.ctbf w7.5, w15.5
pq.ctbf w7.6, w15.6
pq.ctbf w7.7, w15.7, 1, 0, 0
pq.ctbf w16.0, w24.0
pq.ctbf w16.1, w24.1
pq.ctbf w16.2, w24.2
pq.ctbf w16.3, w24.3
pq.ctbf w16.4, w24.4
pq.ctbf w16.5, w24.5
pq.ctbf w16.6, w24.6
pq.ctbf w16.7, w24.7
pq.ctbf w17.0, w25.0
pq.ctbf w17.1, w25.1
pq.ctbf w17.2, w25.2
pq.ctbf w17.3, w25.3
pq.ctbf w17.4, w25.4
pq.ctbf w17.5, w25.5
pq.ctbf w17.6, w25.6
pq.ctbf w17.7, w25.7
pq.ctbf w18.0, w26.0
pq.ctbf w18.1, w26.1
pq.ctbf w18.2, w26.2
pq.ctbf w18.3, w26.3
pq.ctbf w18.4, w26.4
pq.ctbf w18.5, w26.5
pq.ctbf w18.6, w26.6
pq.ctbf w18.7, w26.7
pq.ctbf w19.0, w27.0
pq.ctbf w19.1, w27.1
pq.ctbf w19.2, w27.2
pq.ctbf w19.3, w27.3
pq.ctbf w19.4, w27.4
pq.ctbf w19.5, w27.5
pq.ctbf w19.6, w27.6
pq.ctbf w19.7, w27.7
pq.ctbf w20.0, w28.0
pq.ctbf w20.1, w28.1
pq.ctbf w20.2, w28.2
pq.ctbf w20.3, w28.3
pq.ctbf w20.4, w28.4
pq.ctbf w20.5, w28.5
pq.ctbf w20.6, w28.6
pq.ctbf w20.7, w28.7
pq.ctbf w21.0, w29.0
pq.ctbf w21.1, w29.1
pq.ctbf w21.2, w29.2
pq.ctbf w21.3, w29.3
pq.ctbf w21.4, w29.4
pq.ctbf w21.5, w29.5
pq.ctbf w21.6, w29.6
pq.ctbf w21.7, w29.7
pq.ctbf w22.0, w30.0
pq.ctbf w22.1, w30.1
pq.ctbf w22.2, w30.2
pq.ctbf w22.3, w30.3
pq.ctbf w22.4, w30.4
pq.ctbf w22.5, w30.5
pq.ctbf w22.6, w30.6
pq.ctbf w22.7, w30.7
pq.ctbf w23.0, w31.0
pq.ctbf w23.1, w31.1
pq.ctbf w23.2, w31.2
pq.ctbf w23.3, w31.3
pq.ctbf w23.4, w31.4
pq.ctbf w23.5, w31.5
pq.ctbf w23.6, w31.6
pq.ctbf w23.7, w31.7


/*************************************************/
/*                 NTT-Layer:32                 */
/*************************************************/

pq.pqsru 0, 0, 0, 0, 0, 1, 1
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w0.0, w4.0
pq.ctbf w0.1, w4.1
pq.ctbf w0.2, w4.2
pq.ctbf w0.3, w4.3
pq.ctbf w0.4, w4.4
pq.ctbf w0.5, w4.5
pq.ctbf w0.6, w4.6
pq.ctbf w0.7, w4.7
pq.ctbf w1.0, w5.0
pq.ctbf w1.1, w5.1
pq.ctbf w1.2, w5.2
pq.ctbf w1.3, w5.3
pq.ctbf w1.4, w5.4
pq.ctbf w1.5, w5.5
pq.ctbf w1.6, w5.6
pq.ctbf w1.7, w5.7
pq.ctbf w2.0, w6.0
pq.ctbf w2.1, w6.1
pq.ctbf w2.2, w6.2
pq.ctbf w2.3, w6.3
pq.ctbf w2.4, w6.4
pq.ctbf w2.5, w6.5
pq.ctbf w2.6, w6.6
pq.ctbf w2.7, w6.7
pq.ctbf w3.0, w7.0
pq.ctbf w3.1, w7.1
pq.ctbf w3.2, w7.2
pq.ctbf w3.3, w7.3
pq.ctbf w3.4, w7.4
pq.ctbf w3.5, w7.5
pq.ctbf w3.6, w7.6
pq.ctbf w3.7, w7.7, 1, 0, 0
pq.ctbf w16.0, w20.0
pq.ctbf w16.1, w20.1
pq.ctbf w16.2, w20.2
pq.ctbf w16.3, w20.3
pq.ctbf w16.4, w20.4
pq.ctbf w16.5, w20.5
pq.ctbf w16.6, w20.6
pq.ctbf w16.7, w20.7
pq.ctbf w17.0, w21.0
pq.ctbf w17.1, w21.1
pq.ctbf w17.2, w21.2
pq.ctbf w17.3, w21.3
pq.ctbf w17.4, w21.4
pq.ctbf w17.5, w21.5
pq.ctbf w17.6, w21.6
pq.ctbf w17.7, w21.7
pq.ctbf w18.0, w22.0
pq.ctbf w18.1, w22.1
pq.ctbf w18.2, w22.2
pq.ctbf w18.3, w22.3
pq.ctbf w18.4, w22.4
pq.ctbf w18.5, w22.5
pq.ctbf w18.6, w22.6
pq.ctbf w18.7, w22.7
pq.ctbf w19.0, w23.0
pq.ctbf w19.1, w23.1
pq.ctbf w19.2, w23.2
pq.ctbf w19.3, w23.3
pq.ctbf w19.4, w23.4
pq.ctbf w19.5, w23.5
pq.ctbf w19.6, w23.6
pq.ctbf w19.7, w23.7, 1, 0, 0
pq.ctbf w8.0, w12.0
pq.ctbf w8.1, w12.1
pq.ctbf w8.2, w12.2
pq.ctbf w8.3, w12.3
pq.ctbf w8.4, w12.4
pq.ctbf w8.5, w12.5
pq.ctbf w8.6, w12.6
pq.ctbf w8.7, w12.7
pq.ctbf w9.0, w13.0
pq.ctbf w9.1, w13.1
pq.ctbf w9.2, w13.2
pq.ctbf w9.3, w13.3
pq.ctbf w9.4, w13.4
pq.ctbf w9.5, w13.5
pq.ctbf w9.6, w13.6
pq.ctbf w9.7, w13.7
pq.ctbf w10.0, w14.0
pq.ctbf w10.1, w14.1
pq.ctbf w10.2, w14.2
pq.ctbf w10.3, w14.3
pq.ctbf w10.4, w14.4
pq.ctbf w10.5, w14.5
pq.ctbf w10.6, w14.6
pq.ctbf w10.7, w14.7
pq.ctbf w11.0, w15.0
pq.ctbf w11.1, w15.1
pq.ctbf w11.2, w15.2
pq.ctbf w11.3, w15.3
pq.ctbf w11.4, w15.4
pq.ctbf w11.5, w15.5
pq.ctbf w11.6, w15.6
pq.ctbf w11.7, w15.7, 1, 0, 0
pq.ctbf w24.0, w28.0
pq.ctbf w24.1, w28.1
pq.ctbf w24.2, w28.2
pq.ctbf w24.3, w28.3
pq.ctbf w24.4, w28.4
pq.ctbf w24.5, w28.5
pq.ctbf w24.6, w28.6
pq.ctbf w24.7, w28.7
pq.ctbf w25.0, w29.0
pq.ctbf w25.1, w29.1
pq.ctbf w25.2, w29.2
pq.ctbf w25.3, w29.3
pq.ctbf w25.4, w29.4
pq.ctbf w25.5, w29.5
pq.ctbf w25.6, w29.6
pq.ctbf w25.7, w29.7
pq.ctbf w26.0, w30.0
pq.ctbf w26.1, w30.1
pq.ctbf w26.2, w30.2
pq.ctbf w26.3, w30.3
pq.ctbf w26.4, w30.4
pq.ctbf w26.5, w30.5
pq.ctbf w26.6, w30.6
pq.ctbf w26.7, w30.7
pq.ctbf w27.0, w31.0
pq.ctbf w27.1, w31.1
pq.ctbf w27.2, w31.2
pq.ctbf w27.3, w31.3
pq.ctbf w27.4, w31.4
pq.ctbf w27.5, w31.5
pq.ctbf w27.6, w31.6
pq.ctbf w27.7, w31.7


/*************************************************/
/*                 NTT-Layer:16                 */
/*************************************************/

pq.pqsru 0, 0, 0, 0, 0, 1, 1
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w0.0, w2.0
pq.ctbf w0.1, w2.1
pq.ctbf w0.2, w2.2
pq.ctbf w0.3, w2.3
pq.ctbf w0.4, w2.4
pq.ctbf w0.5, w2.5
pq.ctbf w0.6, w2.6
pq.ctbf w0.7, w2.7
pq.ctbf w1.0, w3.0
pq.ctbf w1.1, w3.1
pq.ctbf w1.2, w3.2
pq.ctbf w1.3, w3.3
pq.ctbf w1.4, w3.4
pq.ctbf w1.5, w3.5
pq.ctbf w1.6, w3.6
pq.ctbf w1.7, w3.7, 1, 0, 0
pq.ctbf w16.0, w18.0
pq.ctbf w16.1, w18.1
pq.ctbf w16.2, w18.2
pq.ctbf w16.3, w18.3
pq.ctbf w16.4, w18.4
pq.ctbf w16.5, w18.5
pq.ctbf w16.6, w18.6
pq.ctbf w16.7, w18.7
pq.ctbf w17.0, w19.0
pq.ctbf w17.1, w19.1
pq.ctbf w17.2, w19.2
pq.ctbf w17.3, w19.3
pq.ctbf w17.4, w19.4
pq.ctbf w17.5, w19.5
pq.ctbf w17.6, w19.6
pq.ctbf w17.7, w19.7, 1, 0, 0
pq.ctbf w8.0, w10.0
pq.ctbf w8.1, w10.1
pq.ctbf w8.2, w10.2
pq.ctbf w8.3, w10.3
pq.ctbf w8.4, w10.4
pq.ctbf w8.5, w10.5
pq.ctbf w8.6, w10.6
pq.ctbf w8.7, w10.7
pq.ctbf w9.0, w11.0
pq.ctbf w9.1, w11.1
pq.ctbf w9.2, w11.2
pq.ctbf w9.3, w11.3
pq.ctbf w9.4, w11.4
pq.ctbf w9.5, w11.5
pq.ctbf w9.6, w11.6
pq.ctbf w9.7, w11.7, 1, 0, 0
pq.ctbf w24.0, w26.0
pq.ctbf w24.1, w26.1
pq.ctbf w24.2, w26.2
pq.ctbf w24.3, w26.3
pq.ctbf w24.4, w26.4
pq.ctbf w24.5, w26.5
pq.ctbf w24.6, w26.6
pq.ctbf w24.7, w26.7
pq.ctbf w25.0, w27.0
pq.ctbf w25.1, w27.1
pq.ctbf w25.2, w27.2
pq.ctbf w25.3, w27.3
pq.ctbf w25.4, w27.4
pq.ctbf w25.5, w27.5
pq.ctbf w25.6, w27.6
pq.ctbf w25.7, w27.7, 1, 0, 0
pq.ctbf w4.0, w6.0
pq.ctbf w4.1, w6.1
pq.ctbf w4.2, w6.2
pq.ctbf w4.3, w6.3
pq.ctbf w4.4, w6.4
pq.ctbf w4.5, w6.5
pq.ctbf w4.6, w6.6
pq.ctbf w4.7, w6.7
pq.ctbf w5.0, w7.0
pq.ctbf w5.1, w7.1
pq.ctbf w5.2, w7.2
pq.ctbf w5.3, w7.3
pq.ctbf w5.4, w7.4
pq.ctbf w5.5, w7.5
pq.ctbf w5.6, w7.6
pq.ctbf w5.7, w7.7, 1, 0, 0
pq.ctbf w20.0, w22.0
pq.ctbf w20.1, w22.1
pq.ctbf w20.2, w22.2
pq.ctbf w20.3, w22.3
pq.ctbf w20.4, w22.4
pq.ctbf w20.5, w22.5
pq.ctbf w20.6, w22.6
pq.ctbf w20.7, w22.7
pq.ctbf w21.0, w23.0
pq.ctbf w21.1, w23.1
pq.ctbf w21.2, w23.2
pq.ctbf w21.3, w23.3
pq.ctbf w21.4, w23.4
pq.ctbf w21.5, w23.5
pq.ctbf w21.6, w23.6
pq.ctbf w21.7, w23.7, 1, 0, 0
pq.ctbf w12.0, w14.0
pq.ctbf w12.1, w14.1
pq.ctbf w12.2, w14.2
pq.ctbf w12.3, w14.3
pq.ctbf w12.4, w14.4
pq.ctbf w12.5, w14.5
pq.ctbf w12.6, w14.6
pq.ctbf w12.7, w14.7
pq.ctbf w13.0, w15.0
pq.ctbf w13.1, w15.1
pq.ctbf w13.2, w15.2
pq.ctbf w13.3, w15.3
pq.ctbf w13.4, w15.4
pq.ctbf w13.5, w15.5
pq.ctbf w13.6, w15.6
pq.ctbf w13.7, w15.7, 1, 0, 0
pq.ctbf w28.0, w30.0
pq.ctbf w28.1, w30.1
pq.ctbf w28.2, w30.2
pq.ctbf w28.3, w30.3
pq.ctbf w28.4, w30.4
pq.ctbf w28.5, w30.5
pq.ctbf w28.6, w30.6
pq.ctbf w28.7, w30.7
pq.ctbf w29.0, w31.0
pq.ctbf w29.1, w31.1
pq.ctbf w29.2, w31.2
pq.ctbf w29.3, w31.3
pq.ctbf w29.4, w31.4
pq.ctbf w29.5, w31.5
pq.ctbf w29.6, w31.6
pq.ctbf w29.7, w31.7


/*************************************************/
/*                 NTT-Layer:8                 */
/*************************************************/

pq.pqsru 0, 0, 0, 0, 0, 1, 1
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w0.0, w1.0
pq.ctbf w0.1, w1.1
pq.ctbf w0.2, w1.2
pq.ctbf w0.3, w1.3
pq.ctbf w0.4, w1.4
pq.ctbf w0.5, w1.5
pq.ctbf w0.6, w1.6
pq.ctbf w0.7, w1.7, 1, 0, 0
pq.ctbf w16.0, w17.0
pq.ctbf w16.1, w17.1
pq.ctbf w16.2, w17.2
pq.ctbf w16.3, w17.3
pq.ctbf w16.4, w17.4
pq.ctbf w16.5, w17.5
pq.ctbf w16.6, w17.6
pq.ctbf w16.7, w17.7, 1, 0, 0
pq.ctbf w8.0, w9.0
pq.ctbf w8.1, w9.1
pq.ctbf w8.2, w9.2
pq.ctbf w8.3, w9.3
pq.ctbf w8.4, w9.4
pq.ctbf w8.5, w9.5
pq.ctbf w8.6, w9.6
pq.ctbf w8.7, w9.7, 1, 0, 0
pq.ctbf w24.0, w25.0
pq.ctbf w24.1, w25.1
pq.ctbf w24.2, w25.2
pq.ctbf w24.3, w25.3
pq.ctbf w24.4, w25.4
pq.ctbf w24.5, w25.5
pq.ctbf w24.6, w25.6
pq.ctbf w24.7, w25.7, 1, 0, 0
pq.ctbf w4.0, w5.0
pq.ctbf w4.1, w5.1
pq.ctbf w4.2, w5.2
pq.ctbf w4.3, w5.3
pq.ctbf w4.4, w5.4
pq.ctbf w4.5, w5.5
pq.ctbf w4.6, w5.6
pq.ctbf w4.7, w5.7, 1, 0, 0
pq.ctbf w20.0, w21.0
pq.ctbf w20.1, w21.1
pq.ctbf w20.2, w21.2
pq.ctbf w20.3, w21.3
pq.ctbf w20.4, w21.4
pq.ctbf w20.5, w21.5
pq.ctbf w20.6, w21.6
pq.ctbf w20.7, w21.7, 1, 0, 0
pq.ctbf w12.0, w13.0
pq.ctbf w12.1, w13.1
pq.ctbf w12.2, w13.2
pq.ctbf w12.3, w13.3
pq.ctbf w12.4, w13.4
pq.ctbf w12.5, w13.5
pq.ctbf w12.6, w13.6
pq.ctbf w12.7, w13.7, 1, 0, 0
pq.ctbf w28.0, w29.0
pq.ctbf w28.1, w29.1
pq.ctbf w28.2, w29.2
pq.ctbf w28.3, w29.3
pq.ctbf w28.4, w29.4
pq.ctbf w28.5, w29.5
pq.ctbf w28.6, w29.6
pq.ctbf w28.7, w29.7, 1, 0, 0
pq.ctbf w2.0, w3.0
pq.ctbf w2.1, w3.1
pq.ctbf w2.2, w3.2
pq.ctbf w2.3, w3.3
pq.ctbf w2.4, w3.4
pq.ctbf w2.5, w3.5
pq.ctbf w2.6, w3.6
pq.ctbf w2.7, w3.7, 1, 0, 0
pq.ctbf w18.0, w19.0
pq.ctbf w18.1, w19.1
pq.ctbf w18.2, w19.2
pq.ctbf w18.3, w19.3
pq.ctbf w18.4, w19.4
pq.ctbf w18.5, w19.5
pq.ctbf w18.6, w19.6
pq.ctbf w18.7, w19.7, 1, 0, 0
pq.ctbf w10.0, w11.0
pq.ctbf w10.1, w11.1
pq.ctbf w10.2, w11.2
pq.ctbf w10.3, w11.3
pq.ctbf w10.4, w11.4
pq.ctbf w10.5, w11.5
pq.ctbf w10.6, w11.6
pq.ctbf w10.7, w11.7, 1, 0, 0
pq.ctbf w26.0, w27.0
pq.ctbf w26.1, w27.1
pq.ctbf w26.2, w27.2
pq.ctbf w26.3, w27.3
pq.ctbf w26.4, w27.4
pq.ctbf w26.5, w27.5
pq.ctbf w26.6, w27.6
pq.ctbf w26.7, w27.7, 1, 0, 0
pq.ctbf w6.0, w7.0
pq.ctbf w6.1, w7.1
pq.ctbf w6.2, w7.2
pq.ctbf w6.3, w7.3
pq.ctbf w6.4, w7.4
pq.ctbf w6.5, w7.5
pq.ctbf w6.6, w7.6
pq.ctbf w6.7, w7.7, 1, 0, 0
pq.ctbf w22.0, w23.0
pq.ctbf w22.1, w23.1
pq.ctbf w22.2, w23.2
pq.ctbf w22.3, w23.3
pq.ctbf w22.4, w23.4
pq.ctbf w22.5, w23.5
pq.ctbf w22.6, w23.6
pq.ctbf w22.7, w23.7, 1, 0, 0
pq.ctbf w14.0, w15.0
pq.ctbf w14.1, w15.1
pq.ctbf w14.2, w15.2
pq.ctbf w14.3, w15.3
pq.ctbf w14.4, w15.4
pq.ctbf w14.5, w15.5
pq.ctbf w14.6, w15.6
pq.ctbf w14.7, w15.7, 1, 0, 0
pq.ctbf w30.0, w31.0
pq.ctbf w30.1, w31.1
pq.ctbf w30.2, w31.2
pq.ctbf w30.3, w31.3
pq.ctbf w30.4, w31.4
pq.ctbf w30.5, w31.5
pq.ctbf w30.6, w31.6
pq.ctbf w30.7, w31.7


/*************************************************/
/*                 NTT-Layer:4                 */
/*************************************************/

pq.pqsru 0, 0, 0, 0, 0, 1, 1
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w0.0, w0.4
pq.ctbf w0.1, w0.5
pq.ctbf w0.2, w0.6
pq.ctbf w0.3, w0.7, 1, 0, 0
pq.ctbf w16.0, w16.4
pq.ctbf w16.1, w16.5
pq.ctbf w16.2, w16.6
pq.ctbf w16.3, w16.7, 1, 0, 0
pq.ctbf w8.0, w8.4
pq.ctbf w8.1, w8.5
pq.ctbf w8.2, w8.6
pq.ctbf w8.3, w8.7, 1, 0, 0
pq.ctbf w24.0, w24.4
pq.ctbf w24.1, w24.5
pq.ctbf w24.2, w24.6
pq.ctbf w24.3, w24.7, 1, 0, 0
pq.ctbf w4.0, w4.4
pq.ctbf w4.1, w4.5
pq.ctbf w4.2, w4.6
pq.ctbf w4.3, w4.7, 1, 0, 0
pq.ctbf w20.0, w20.4
pq.ctbf w20.1, w20.5
pq.ctbf w20.2, w20.6
pq.ctbf w20.3, w20.7, 1, 0, 0
pq.ctbf w12.0, w12.4
pq.ctbf w12.1, w12.5
pq.ctbf w12.2, w12.6
pq.ctbf w12.3, w12.7, 1, 0, 0
pq.ctbf w28.0, w28.4
pq.ctbf w28.1, w28.5
pq.ctbf w28.2, w28.6
pq.ctbf w28.3, w28.7, 1, 0, 0
pq.ctbf w2.0, w2.4
pq.ctbf w2.1, w2.5
pq.ctbf w2.2, w2.6
pq.ctbf w2.3, w2.7, 1, 0, 0
pq.ctbf w18.0, w18.4
pq.ctbf w18.1, w18.5
pq.ctbf w18.2, w18.6
pq.ctbf w18.3, w18.7, 1, 0, 0
pq.ctbf w10.0, w10.4
pq.ctbf w10.1, w10.5
pq.ctbf w10.2, w10.6
pq.ctbf w10.3, w10.7, 1, 0, 0
pq.ctbf w26.0, w26.4
pq.ctbf w26.1, w26.5
pq.ctbf w26.2, w26.6
pq.ctbf w26.3, w26.7, 1, 0, 0
pq.ctbf w6.0, w6.4
pq.ctbf w6.1, w6.5
pq.ctbf w6.2, w6.6
pq.ctbf w6.3, w6.7, 1, 0, 0
pq.ctbf w22.0, w22.4
pq.ctbf w22.1, w22.5
pq.ctbf w22.2, w22.6
pq.ctbf w22.3, w22.7, 1, 0, 0
pq.ctbf w14.0, w14.4
pq.ctbf w14.1, w14.5
pq.ctbf w14.2, w14.6
pq.ctbf w14.3, w14.7, 1, 0, 0
pq.ctbf w30.0, w30.4
pq.ctbf w30.1, w30.5
pq.ctbf w30.2, w30.6
pq.ctbf w30.3, w30.7, 1, 0, 0
pq.ctbf w1.0, w1.4
pq.ctbf w1.1, w1.5
pq.ctbf w1.2, w1.6
pq.ctbf w1.3, w1.7, 1, 0, 0
pq.ctbf w17.0, w17.4
pq.ctbf w17.1, w17.5
pq.ctbf w17.2, w17.6
pq.ctbf w17.3, w17.7, 1, 0, 0
pq.ctbf w9.0, w9.4
pq.ctbf w9.1, w9.5
pq.ctbf w9.2, w9.6
pq.ctbf w9.3, w9.7, 1, 0, 0
pq.ctbf w25.0, w25.4
pq.ctbf w25.1, w25.5
pq.ctbf w25.2, w25.6
pq.ctbf w25.3, w25.7, 1, 0, 0
pq.ctbf w5.0, w5.4
pq.ctbf w5.1, w5.5
pq.ctbf w5.2, w5.6
pq.ctbf w5.3, w5.7, 1, 0, 0
pq.ctbf w21.0, w21.4
pq.ctbf w21.1, w21.5
pq.ctbf w21.2, w21.6
pq.ctbf w21.3, w21.7, 1, 0, 0
pq.ctbf w13.0, w13.4
pq.ctbf w13.1, w13.5
pq.ctbf w13.2, w13.6
pq.ctbf w13.3, w13.7, 1, 0, 0
pq.ctbf w29.0, w29.4
pq.ctbf w29.1, w29.5
pq.ctbf w29.2, w29.6
pq.ctbf w29.3, w29.7, 1, 0, 0
pq.ctbf w3.0, w3.4
pq.ctbf w3.1, w3.5
pq.ctbf w3.2, w3.6
pq.ctbf w3.3, w3.7, 1, 0, 0
pq.ctbf w19.0, w19.4
pq.ctbf w19.1, w19.5
pq.ctbf w19.2, w19.6
pq.ctbf w19.3, w19.7, 1, 0, 0
pq.ctbf w11.0, w11.4
pq.ctbf w11.1, w11.5
pq.ctbf w11.2, w11.6
pq.ctbf w11.3, w11.7, 1, 0, 0
pq.ctbf w27.0, w27.4
pq.ctbf w27.1, w27.5
pq.ctbf w27.2, w27.6
pq.ctbf w27.3, w27.7, 1, 0, 0
pq.ctbf w7.0, w7.4
pq.ctbf w7.1, w7.5
pq.ctbf w7.2, w7.6
pq.ctbf w7.3, w7.7, 1, 0, 0
pq.ctbf w23.0, w23.4
pq.ctbf w23.1, w23.5
pq.ctbf w23.2, w23.6
pq.ctbf w23.3, w23.7, 1, 0, 0
pq.ctbf w15.0, w15.4
pq.ctbf w15.1, w15.5
pq.ctbf w15.2, w15.6
pq.ctbf w15.3, w15.7, 1, 0, 0
pq.ctbf w31.0, w31.4
pq.ctbf w31.1, w31.5
pq.ctbf w31.2, w31.6
pq.ctbf w31.3, w31.7


/*************************************************/
/*                 NTT-Layer:2                 */
/*************************************************/

pq.pqsru 0, 0, 0, 0, 0, 1, 1
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.ctbf w0.0, w0.2
pq.ctbf w0.1, w0.3, 1, 0, 0
pq.ctbf w16.0, w16.2
pq.ctbf w16.1, w16.3, 1, 0, 0
pq.ctbf w8.0, w8.2
pq.ctbf w8.1, w8.3, 1, 0, 0
pq.ctbf w24.0, w24.2
pq.ctbf w24.1, w24.3, 1, 0, 0
pq.ctbf w4.0, w4.2
pq.ctbf w4.1, w4.3, 1, 0, 0
pq.ctbf w20.0, w20.2
pq.ctbf w20.1, w20.3, 1, 0, 0
pq.ctbf w12.0, w12.2
pq.ctbf w12.1, w12.3, 1, 0, 0
pq.ctbf w28.0, w28.2
pq.ctbf w28.1, w28.3, 1, 0, 0
pq.ctbf w2.0, w2.2
pq.ctbf w2.1, w2.3, 1, 0, 0
pq.ctbf w18.0, w18.2
pq.ctbf w18.1, w18.3, 1, 0, 0
pq.ctbf w10.0, w10.2
pq.ctbf w10.1, w10.3, 1, 0, 0
pq.ctbf w26.0, w26.2
pq.ctbf w26.1, w26.3, 1, 0, 0
pq.ctbf w6.0, w6.2
pq.ctbf w6.1, w6.3, 1, 0, 0
pq.ctbf w22.0, w22.2
pq.ctbf w22.1, w22.3, 1, 0, 0
pq.ctbf w14.0, w14.2
pq.ctbf w14.1, w14.3, 1, 0, 0
pq.ctbf w30.0, w30.2
pq.ctbf w30.1, w30.3, 1, 0, 0
pq.ctbf w1.0, w1.2
pq.ctbf w1.1, w1.3, 1, 0, 0
pq.ctbf w17.0, w17.2
pq.ctbf w17.1, w17.3, 1, 0, 0
pq.ctbf w9.0, w9.2
pq.ctbf w9.1, w9.3, 1, 0, 0
pq.ctbf w25.0, w25.2
pq.ctbf w25.1, w25.3, 1, 0, 0
pq.ctbf w5.0, w5.2
pq.ctbf w5.1, w5.3, 1, 0, 0
pq.ctbf w21.0, w21.2
pq.ctbf w21.1, w21.3, 1, 0, 0
pq.ctbf w13.0, w13.2
pq.ctbf w13.1, w13.3, 1, 0, 0
pq.ctbf w29.0, w29.2
pq.ctbf w29.1, w29.3, 1, 0, 0
pq.ctbf w3.0, w3.2
pq.ctbf w3.1, w3.3, 1, 0, 0
pq.ctbf w19.0, w19.2
pq.ctbf w19.1, w19.3, 1, 0, 0
pq.ctbf w11.0, w11.2
pq.ctbf w11.1, w11.3, 1, 0, 0
pq.ctbf w27.0, w27.2
pq.ctbf w27.1, w27.3, 1, 0, 0
pq.ctbf w7.0, w7.2
pq.ctbf w7.1, w7.3, 1, 0, 0
pq.ctbf w23.0, w23.2
pq.ctbf w23.1, w23.3, 1, 0, 0
pq.ctbf w15.0, w15.2
pq.ctbf w15.1, w15.3, 1, 0, 0
pq.ctbf w31.0, w31.2
pq.ctbf w31.1, w31.3, 1, 0, 0
pq.ctbf w0.4, w0.6
pq.ctbf w0.5, w0.7, 1, 0, 0
pq.ctbf w16.4, w16.6
pq.ctbf w16.5, w16.7, 1, 0, 0
pq.ctbf w8.4, w8.6
pq.ctbf w8.5, w8.7, 1, 0, 0
pq.ctbf w24.4, w24.6
pq.ctbf w24.5, w24.7, 1, 0, 0
pq.ctbf w4.4, w4.6
pq.ctbf w4.5, w4.7, 1, 0, 0
pq.ctbf w20.4, w20.6
pq.ctbf w20.5, w20.7, 1, 0, 0
pq.ctbf w12.4, w12.6
pq.ctbf w12.5, w12.7, 1, 0, 0
pq.ctbf w28.4, w28.6
pq.ctbf w28.5, w28.7, 1, 0, 0
pq.ctbf w2.4, w2.6
pq.ctbf w2.5, w2.7, 1, 0, 0
pq.ctbf w18.4, w18.6
pq.ctbf w18.5, w18.7, 1, 0, 0
pq.ctbf w10.4, w10.6
pq.ctbf w10.5, w10.7, 1, 0, 0
pq.ctbf w26.4, w26.6
pq.ctbf w26.5, w26.7, 1, 0, 0
pq.ctbf w6.4, w6.6
pq.ctbf w6.5, w6.7, 1, 0, 0
pq.ctbf w22.4, w22.6
pq.ctbf w22.5, w22.7, 1, 0, 0
pq.ctbf w14.4, w14.6
pq.ctbf w14.5, w14.7, 1, 0, 0
pq.ctbf w30.4, w30.6
pq.ctbf w30.5, w30.7, 1, 0, 0
pq.ctbf w1.4, w1.6
pq.ctbf w1.5, w1.7, 1, 0, 0
pq.ctbf w17.4, w17.6
pq.ctbf w17.5, w17.7, 1, 0, 0
pq.ctbf w9.4, w9.6
pq.ctbf w9.5, w9.7, 1, 0, 0
pq.ctbf w25.4, w25.6
pq.ctbf w25.5, w25.7, 1, 0, 0
pq.ctbf w5.4, w5.6
pq.ctbf w5.5, w5.7, 1, 0, 0
pq.ctbf w21.4, w21.6
pq.ctbf w21.5, w21.7, 1, 0, 0
pq.ctbf w13.4, w13.6
pq.ctbf w13.5, w13.7, 1, 0, 0
pq.ctbf w29.4, w29.6
pq.ctbf w29.5, w29.7, 1, 0, 0
pq.ctbf w3.4, w3.6
pq.ctbf w3.5, w3.7, 1, 0, 0
pq.ctbf w19.4, w19.6
pq.ctbf w19.5, w19.7, 1, 0, 0
pq.ctbf w11.4, w11.6
pq.ctbf w11.5, w11.7, 1, 0, 0
pq.ctbf w27.4, w27.6
pq.ctbf w27.5, w27.7, 1, 0, 0
pq.ctbf w7.4, w7.6
pq.ctbf w7.5, w7.7, 1, 0, 0
pq.ctbf w23.4, w23.6
pq.ctbf w23.5, w23.7, 1, 0, 0
pq.ctbf w15.4, w15.6
pq.ctbf w15.5, w15.7, 1, 0, 0
pq.ctbf w31.4, w31.6
pq.ctbf w31.5, w31.7

/* store result from [w1] to dmem */
li x4, 0
bn.sid x4++, 544(x0)
bn.sid x4++, 576(x0)
bn.sid x4++, 608(x0)
bn.sid x4++, 640(x0)

bn.sid x4++, 672(x0)
bn.sid x4++, 704(x0)
bn.sid x4++, 736(x0)
bn.sid x4++, 768(x0)

bn.sid x4++, 800(x0)
bn.sid x4++, 832(x0)
bn.sid x4++, 864(x0)
bn.sid x4++, 896(x0)

bn.sid x4++, 928(x0)
bn.sid x4++, 960(x0)
bn.sid x4++, 992(x0)
bn.sid x4++, 1024(x0)


bn.sid x4++, 1056(x0)
bn.sid x4++, 1088(x0)
bn.sid x4++, 1120(x0)
bn.sid x4++, 1152(x0)

bn.sid x4++, 1184(x0)
bn.sid x4++, 1216(x0)
bn.sid x4++, 1248(x0)
bn.sid x4++, 1280(x0)

bn.sid x4++, 1312(x0)
bn.sid x4++, 1344(x0)
bn.sid x4++, 1376(x0)
bn.sid x4++, 1408(x0)

bn.sid x4++, 1440(x0)
bn.sid x4++, 1472(x0)
bn.sid x4++, 1504(x0)
bn.sid x4, 1536(x0)

ecall


.section .data

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

omega:
  .quad 0x0000094b000007b8
  .quad 0x00000a310000079c
  .quad 0x000003f000000827
  .quad 0x00000000000005f4

psi:
  .quad 0x0000079c0000094b
  .quad 0x0000082700000a31
  .quad 0x000005f4000003f0
  .quad 0x0000000000000bd3

coef0:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

coef1:
  .quad 0x0000000900000008
  .quad 0x0000000B0000000A
  .quad 0x0000000D0000000C
  .quad 0x0000000F0000000E

coef2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

coef3:
  .quad 0x0000001900000018
  .quad 0x0000001B0000001A
  .quad 0x0000001D0000001C
  .quad 0x0000001F0000001E

coef4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

coef5:
  .quad 0x0000002900000028
  .quad 0x0000002B0000002A
  .quad 0x0000002D0000002C
  .quad 0x0000002F0000002E

coef6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

coef7:
  .quad 0x0000003900000038
  .quad 0x0000003B0000003A
  .quad 0x0000003D0000003C
  .quad 0x0000003F0000003E

coef8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

coef9:
  .quad 0x0000004900000048
  .quad 0x0000004B0000004A
  .quad 0x0000004D0000004C
  .quad 0x0000004F0000004E

coef10:
  .quad 0x0000005100000050
  .quad 0x0000005300000052
  .quad 0x0000005500000054
  .quad 0x0000005700000056

coef11:
  .quad 0x0000005900000058
  .quad 0x0000005B0000005A
  .quad 0x0000005D0000005C
  .quad 0x0000005F0000005E

coef12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

coef13:
  .quad 0x0000006900000068
  .quad 0x0000006B0000006A
  .quad 0x0000006D0000006C
  .quad 0x0000006F0000006E

coef14:
  .quad 0x0000007100000070
  .quad 0x0000007300000072
  .quad 0x0000007500000074
  .quad 0x0000007700000076

coef15:
  .quad 0x0000007900000078
  .quad 0x0000007B0000007A
  .quad 0x0000007D0000007C
  .quad 0x0000007F0000007E

coef16:
  .quad 0x0000008100000080
  .quad 0x0000008300000082
  .quad 0x0000008500000084
  .quad 0x0000008700000086

coef17:
  .quad 0x0000008900000088
  .quad 0x0000008B0000008A
  .quad 0x0000008D0000008C
  .quad 0x0000008F0000008E

coef18:
  .quad 0x0000009100000090
  .quad 0x0000009300000092
  .quad 0x0000009500000094
  .quad 0x0000009700000096

coef19:
  .quad 0x0000009900000098
  .quad 0x0000009B0000009A
  .quad 0x0000009D0000009C
  .quad 0x0000009F0000009E

coef20:
  .quad 0x000000A1000000A0
  .quad 0x000000A3000000A2
  .quad 0x000000A5000000A4
  .quad 0x000000A7000000A6

coef21:
  .quad 0x000000A9000000A8
  .quad 0x000000AB000000AA
  .quad 0x000000AD000000AC
  .quad 0x000000AF000000AE

coef22:
  .quad 0x000000B1000000B0
  .quad 0x000000B3000000B2
  .quad 0x000000B5000000B4
  .quad 0x000000B7000000B6

coef23:
  .quad 0x000000B9000000B8
  .quad 0x000000BB000000BA
  .quad 0x000000BD000000BC
  .quad 0x000000BF000000BE

coef24:
  .quad 0x000000C1000000C0
  .quad 0x000000C3000000C2
  .quad 0x000000C5000000C4
  .quad 0x000000C7000000C6

coef25:
  .quad 0x000000C9000000C8
  .quad 0x000000CB000000CA
  .quad 0x000000CD000000CC
  .quad 0x000000CF000000CE

coef26:
  .quad 0x000000D1000000D0
  .quad 0x000000D3000000D2
  .quad 0x000000D5000000D4
  .quad 0x000000D7000000D6

coef27:
  .quad 0x000000D9000000D8
  .quad 0x000000DB000000DA
  .quad 0x000000DD000000DC
  .quad 0x000000DF000000DE

coef28:
  .quad 0x000000E1000000E0
  .quad 0x000000E3000000E2
  .quad 0x000000E5000000E4
  .quad 0x000000E7000000E6

coef29:
  .quad 0x000000E9000000E8
  .quad 0x000000EB000000EA
  .quad 0x000000ED000000EC
  .quad 0x000000EF000000EE

coef30:
  .quad 0x000000F1000000F0
  .quad 0x000000F3000000F2
  .quad 0x000000F5000000F4
  .quad 0x000000F7000000F6

coef31:
  .quad 0x000000F9000000F8
  .quad 0x000000FB000000FA
  .quad 0x000000FD000000FC
  .quad 0x000000FF000000FE

/* Expected result is

   w3 =
   00000898 0000001e 000003b3 00000038
   00000b67 000000f5 000008c1 00000bc3

   w2 =
   00000042 00000019 000004b5 00000024
   000007da 00000031 0000055c 00000040 */
