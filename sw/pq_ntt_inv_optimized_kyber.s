/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Unrolled INTT Implementation of Kyber */

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


/* Load DMEM(1152) into WDR w0*/
bn.lid x2, 1152(x0)

/* Load mode into PQSR*/
pq.pqsrw 7, w0


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
/*                 NTT-Layer:2                 */
/*************************************************/
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w0.0, w0.2
pq.gsbf w0.1, w0.3, 1, 0, 0
pq.gsbf w16.0, w16.2
pq.gsbf w16.1, w16.3, 1, 0, 0
pq.gsbf w8.0, w8.2
pq.gsbf w8.1, w8.3, 1, 0, 0
pq.gsbf w24.0, w24.2
pq.gsbf w24.1, w24.3, 1, 0, 0
pq.gsbf w4.0, w4.2
pq.gsbf w4.1, w4.3, 1, 0, 0
pq.gsbf w20.0, w20.2
pq.gsbf w20.1, w20.3, 1, 0, 0
pq.gsbf w12.0, w12.2
pq.gsbf w12.1, w12.3, 1, 0, 0
pq.gsbf w28.0, w28.2
pq.gsbf w28.1, w28.3, 1, 0, 0
pq.gsbf w2.0, w2.2
pq.gsbf w2.1, w2.3, 1, 0, 0
pq.gsbf w18.0, w18.2
pq.gsbf w18.1, w18.3, 1, 0, 0
pq.gsbf w10.0, w10.2
pq.gsbf w10.1, w10.3, 1, 0, 0
pq.gsbf w26.0, w26.2
pq.gsbf w26.1, w26.3, 1, 0, 0
pq.gsbf w6.0, w6.2
pq.gsbf w6.1, w6.3, 1, 0, 0
pq.gsbf w22.0, w22.2
pq.gsbf w22.1, w22.3, 1, 0, 0
pq.gsbf w14.0, w14.2
pq.gsbf w14.1, w14.3, 1, 0, 0
pq.gsbf w30.0, w30.2
pq.gsbf w30.1, w30.3, 1, 0, 0
pq.gsbf w1.0, w1.2
pq.gsbf w1.1, w1.3, 1, 0, 0
pq.gsbf w17.0, w17.2
pq.gsbf w17.1, w17.3, 1, 0, 0
pq.gsbf w9.0, w9.2
pq.gsbf w9.1, w9.3, 1, 0, 0
pq.gsbf w25.0, w25.2
pq.gsbf w25.1, w25.3, 1, 0, 0
pq.gsbf w5.0, w5.2
pq.gsbf w5.1, w5.3, 1, 0, 0
pq.gsbf w21.0, w21.2
pq.gsbf w21.1, w21.3, 1, 0, 0
pq.gsbf w13.0, w13.2
pq.gsbf w13.1, w13.3, 1, 0, 0
pq.gsbf w29.0, w29.2
pq.gsbf w29.1, w29.3, 1, 0, 0
pq.gsbf w3.0, w3.2
pq.gsbf w3.1, w3.3, 1, 0, 0
pq.gsbf w19.0, w19.2
pq.gsbf w19.1, w19.3, 1, 0, 0
pq.gsbf w11.0, w11.2
pq.gsbf w11.1, w11.3, 1, 0, 0
pq.gsbf w27.0, w27.2
pq.gsbf w27.1, w27.3, 1, 0, 0
pq.gsbf w7.0, w7.2
pq.gsbf w7.1, w7.3, 1, 0, 0
pq.gsbf w23.0, w23.2
pq.gsbf w23.1, w23.3, 1, 0, 0
pq.gsbf w15.0, w15.2
pq.gsbf w15.1, w15.3, 1, 0, 0
pq.gsbf w31.0, w31.2
pq.gsbf w31.1, w31.3, 1, 0, 0
pq.gsbf w0.4, w0.6
pq.gsbf w0.5, w0.7, 1, 0, 0
pq.gsbf w16.4, w16.6
pq.gsbf w16.5, w16.7, 1, 0, 0
pq.gsbf w8.4, w8.6
pq.gsbf w8.5, w8.7, 1, 0, 0
pq.gsbf w24.4, w24.6
pq.gsbf w24.5, w24.7, 1, 0, 0
pq.gsbf w4.4, w4.6
pq.gsbf w4.5, w4.7, 1, 0, 0
pq.gsbf w20.4, w20.6
pq.gsbf w20.5, w20.7, 1, 0, 0
pq.gsbf w12.4, w12.6
pq.gsbf w12.5, w12.7, 1, 0, 0
pq.gsbf w28.4, w28.6
pq.gsbf w28.5, w28.7, 1, 0, 0
pq.gsbf w2.4, w2.6
pq.gsbf w2.5, w2.7, 1, 0, 0
pq.gsbf w18.4, w18.6
pq.gsbf w18.5, w18.7, 1, 0, 0
pq.gsbf w10.4, w10.6
pq.gsbf w10.5, w10.7, 1, 0, 0
pq.gsbf w26.4, w26.6
pq.gsbf w26.5, w26.7, 1, 0, 0
pq.gsbf w6.4, w6.6
pq.gsbf w6.5, w6.7, 1, 0, 0
pq.gsbf w22.4, w22.6
pq.gsbf w22.5, w22.7, 1, 0, 0
pq.gsbf w14.4, w14.6
pq.gsbf w14.5, w14.7, 1, 0, 0
pq.gsbf w30.4, w30.6
pq.gsbf w30.5, w30.7, 1, 0, 0
pq.gsbf w1.4, w1.6
pq.gsbf w1.5, w1.7, 1, 0, 0
pq.gsbf w17.4, w17.6
pq.gsbf w17.5, w17.7, 1, 0, 0
pq.gsbf w9.4, w9.6
pq.gsbf w9.5, w9.7, 1, 0, 0
pq.gsbf w25.4, w25.6
pq.gsbf w25.5, w25.7, 1, 0, 0
pq.gsbf w5.4, w5.6
pq.gsbf w5.5, w5.7, 1, 0, 0
pq.gsbf w21.4, w21.6
pq.gsbf w21.5, w21.7, 1, 0, 0
pq.gsbf w13.4, w13.6
pq.gsbf w13.5, w13.7, 1, 0, 0
pq.gsbf w29.4, w29.6
pq.gsbf w29.5, w29.7, 1, 0, 0
pq.gsbf w3.4, w3.6
pq.gsbf w3.5, w3.7, 1, 0, 0
pq.gsbf w19.4, w19.6
pq.gsbf w19.5, w19.7, 1, 0, 0
pq.gsbf w11.4, w11.6
pq.gsbf w11.5, w11.7, 1, 0, 0
pq.gsbf w27.4, w27.6
pq.gsbf w27.5, w27.7, 1, 0, 0
pq.gsbf w7.4, w7.6
pq.gsbf w7.5, w7.7, 1, 0, 0
pq.gsbf w23.4, w23.6
pq.gsbf w23.5, w23.7, 1, 0, 0
pq.gsbf w15.4, w15.6
pq.gsbf w15.5, w15.7, 1, 0, 0
pq.gsbf w31.4, w31.6
pq.gsbf w31.5, w31.7, 1, 1, 1

/*************************************************/
/*                 NTT-Layer:4                 */
/*************************************************/
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w0.0, w0.4
pq.gsbf w0.1, w0.5
pq.gsbf w0.2, w0.6
pq.gsbf w0.3, w0.7, 1, 0, 0
pq.gsbf w16.0, w16.4
pq.gsbf w16.1, w16.5
pq.gsbf w16.2, w16.6
pq.gsbf w16.3, w16.7, 1, 0, 0
pq.gsbf w8.0, w8.4
pq.gsbf w8.1, w8.5
pq.gsbf w8.2, w8.6
pq.gsbf w8.3, w8.7, 1, 0, 0
pq.gsbf w24.0, w24.4
pq.gsbf w24.1, w24.5
pq.gsbf w24.2, w24.6
pq.gsbf w24.3, w24.7, 1, 0, 0
pq.gsbf w4.0, w4.4
pq.gsbf w4.1, w4.5
pq.gsbf w4.2, w4.6
pq.gsbf w4.3, w4.7, 1, 0, 0
pq.gsbf w20.0, w20.4
pq.gsbf w20.1, w20.5
pq.gsbf w20.2, w20.6
pq.gsbf w20.3, w20.7, 1, 0, 0
pq.gsbf w12.0, w12.4
pq.gsbf w12.1, w12.5
pq.gsbf w12.2, w12.6
pq.gsbf w12.3, w12.7, 1, 0, 0
pq.gsbf w28.0, w28.4
pq.gsbf w28.1, w28.5
pq.gsbf w28.2, w28.6
pq.gsbf w28.3, w28.7, 1, 0, 0
pq.gsbf w2.0, w2.4
pq.gsbf w2.1, w2.5
pq.gsbf w2.2, w2.6
pq.gsbf w2.3, w2.7, 1, 0, 0
pq.gsbf w18.0, w18.4
pq.gsbf w18.1, w18.5
pq.gsbf w18.2, w18.6
pq.gsbf w18.3, w18.7, 1, 0, 0
pq.gsbf w10.0, w10.4
pq.gsbf w10.1, w10.5
pq.gsbf w10.2, w10.6
pq.gsbf w10.3, w10.7, 1, 0, 0
pq.gsbf w26.0, w26.4
pq.gsbf w26.1, w26.5
pq.gsbf w26.2, w26.6
pq.gsbf w26.3, w26.7, 1, 0, 0
pq.gsbf w6.0, w6.4
pq.gsbf w6.1, w6.5
pq.gsbf w6.2, w6.6
pq.gsbf w6.3, w6.7, 1, 0, 0
pq.gsbf w22.0, w22.4
pq.gsbf w22.1, w22.5
pq.gsbf w22.2, w22.6
pq.gsbf w22.3, w22.7, 1, 0, 0
pq.gsbf w14.0, w14.4
pq.gsbf w14.1, w14.5
pq.gsbf w14.2, w14.6
pq.gsbf w14.3, w14.7, 1, 0, 0
pq.gsbf w30.0, w30.4
pq.gsbf w30.1, w30.5
pq.gsbf w30.2, w30.6
pq.gsbf w30.3, w30.7, 1, 0, 0
pq.gsbf w1.0, w1.4
pq.gsbf w1.1, w1.5
pq.gsbf w1.2, w1.6
pq.gsbf w1.3, w1.7, 1, 0, 0
pq.gsbf w17.0, w17.4
pq.gsbf w17.1, w17.5
pq.gsbf w17.2, w17.6
pq.gsbf w17.3, w17.7, 1, 0, 0
pq.gsbf w9.0, w9.4
pq.gsbf w9.1, w9.5
pq.gsbf w9.2, w9.6
pq.gsbf w9.3, w9.7, 1, 0, 0
pq.gsbf w25.0, w25.4
pq.gsbf w25.1, w25.5
pq.gsbf w25.2, w25.6
pq.gsbf w25.3, w25.7, 1, 0, 0
pq.gsbf w5.0, w5.4
pq.gsbf w5.1, w5.5
pq.gsbf w5.2, w5.6
pq.gsbf w5.3, w5.7, 1, 0, 0
pq.gsbf w21.0, w21.4
pq.gsbf w21.1, w21.5
pq.gsbf w21.2, w21.6
pq.gsbf w21.3, w21.7, 1, 0, 0
pq.gsbf w13.0, w13.4
pq.gsbf w13.1, w13.5
pq.gsbf w13.2, w13.6
pq.gsbf w13.3, w13.7, 1, 0, 0
pq.gsbf w29.0, w29.4
pq.gsbf w29.1, w29.5
pq.gsbf w29.2, w29.6
pq.gsbf w29.3, w29.7, 1, 0, 0
pq.gsbf w3.0, w3.4
pq.gsbf w3.1, w3.5
pq.gsbf w3.2, w3.6
pq.gsbf w3.3, w3.7, 1, 0, 0
pq.gsbf w19.0, w19.4
pq.gsbf w19.1, w19.5
pq.gsbf w19.2, w19.6
pq.gsbf w19.3, w19.7, 1, 0, 0
pq.gsbf w11.0, w11.4
pq.gsbf w11.1, w11.5
pq.gsbf w11.2, w11.6
pq.gsbf w11.3, w11.7, 1, 0, 0
pq.gsbf w27.0, w27.4
pq.gsbf w27.1, w27.5
pq.gsbf w27.2, w27.6
pq.gsbf w27.3, w27.7, 1, 0, 0
pq.gsbf w7.0, w7.4
pq.gsbf w7.1, w7.5
pq.gsbf w7.2, w7.6
pq.gsbf w7.3, w7.7, 1, 0, 0
pq.gsbf w23.0, w23.4
pq.gsbf w23.1, w23.5
pq.gsbf w23.2, w23.6
pq.gsbf w23.3, w23.7, 1, 0, 0
pq.gsbf w15.0, w15.4
pq.gsbf w15.1, w15.5
pq.gsbf w15.2, w15.6
pq.gsbf w15.3, w15.7, 1, 0, 0
pq.gsbf w31.0, w31.4
pq.gsbf w31.1, w31.5
pq.gsbf w31.2, w31.6
pq.gsbf w31.3, w31.7, 1, 1, 1

/*************************************************/
/*                 NTT-Layer:8                 */
/*************************************************/
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w0.0, w1.0
pq.gsbf w0.1, w1.1
pq.gsbf w0.2, w1.2
pq.gsbf w0.3, w1.3
pq.gsbf w0.4, w1.4
pq.gsbf w0.5, w1.5
pq.gsbf w0.6, w1.6
pq.gsbf w0.7, w1.7, 1, 0, 0
pq.gsbf w16.0, w17.0
pq.gsbf w16.1, w17.1
pq.gsbf w16.2, w17.2
pq.gsbf w16.3, w17.3
pq.gsbf w16.4, w17.4
pq.gsbf w16.5, w17.5
pq.gsbf w16.6, w17.6
pq.gsbf w16.7, w17.7, 1, 0, 0
pq.gsbf w8.0, w9.0
pq.gsbf w8.1, w9.1
pq.gsbf w8.2, w9.2
pq.gsbf w8.3, w9.3
pq.gsbf w8.4, w9.4
pq.gsbf w8.5, w9.5
pq.gsbf w8.6, w9.6
pq.gsbf w8.7, w9.7, 1, 0, 0
pq.gsbf w24.0, w25.0
pq.gsbf w24.1, w25.1
pq.gsbf w24.2, w25.2
pq.gsbf w24.3, w25.3
pq.gsbf w24.4, w25.4
pq.gsbf w24.5, w25.5
pq.gsbf w24.6, w25.6
pq.gsbf w24.7, w25.7, 1, 0, 0
pq.gsbf w4.0, w5.0
pq.gsbf w4.1, w5.1
pq.gsbf w4.2, w5.2
pq.gsbf w4.3, w5.3
pq.gsbf w4.4, w5.4
pq.gsbf w4.5, w5.5
pq.gsbf w4.6, w5.6
pq.gsbf w4.7, w5.7, 1, 0, 0
pq.gsbf w20.0, w21.0
pq.gsbf w20.1, w21.1
pq.gsbf w20.2, w21.2
pq.gsbf w20.3, w21.3
pq.gsbf w20.4, w21.4
pq.gsbf w20.5, w21.5
pq.gsbf w20.6, w21.6
pq.gsbf w20.7, w21.7, 1, 0, 0
pq.gsbf w12.0, w13.0
pq.gsbf w12.1, w13.1
pq.gsbf w12.2, w13.2
pq.gsbf w12.3, w13.3
pq.gsbf w12.4, w13.4
pq.gsbf w12.5, w13.5
pq.gsbf w12.6, w13.6
pq.gsbf w12.7, w13.7, 1, 0, 0
pq.gsbf w28.0, w29.0
pq.gsbf w28.1, w29.1
pq.gsbf w28.2, w29.2
pq.gsbf w28.3, w29.3
pq.gsbf w28.4, w29.4
pq.gsbf w28.5, w29.5
pq.gsbf w28.6, w29.6
pq.gsbf w28.7, w29.7, 1, 0, 0
pq.gsbf w2.0, w3.0
pq.gsbf w2.1, w3.1
pq.gsbf w2.2, w3.2
pq.gsbf w2.3, w3.3
pq.gsbf w2.4, w3.4
pq.gsbf w2.5, w3.5
pq.gsbf w2.6, w3.6
pq.gsbf w2.7, w3.7, 1, 0, 0
pq.gsbf w18.0, w19.0
pq.gsbf w18.1, w19.1
pq.gsbf w18.2, w19.2
pq.gsbf w18.3, w19.3
pq.gsbf w18.4, w19.4
pq.gsbf w18.5, w19.5
pq.gsbf w18.6, w19.6
pq.gsbf w18.7, w19.7, 1, 0, 0
pq.gsbf w10.0, w11.0
pq.gsbf w10.1, w11.1
pq.gsbf w10.2, w11.2
pq.gsbf w10.3, w11.3
pq.gsbf w10.4, w11.4
pq.gsbf w10.5, w11.5
pq.gsbf w10.6, w11.6
pq.gsbf w10.7, w11.7, 1, 0, 0
pq.gsbf w26.0, w27.0
pq.gsbf w26.1, w27.1
pq.gsbf w26.2, w27.2
pq.gsbf w26.3, w27.3
pq.gsbf w26.4, w27.4
pq.gsbf w26.5, w27.5
pq.gsbf w26.6, w27.6
pq.gsbf w26.7, w27.7, 1, 0, 0
pq.gsbf w6.0, w7.0
pq.gsbf w6.1, w7.1
pq.gsbf w6.2, w7.2
pq.gsbf w6.3, w7.3
pq.gsbf w6.4, w7.4
pq.gsbf w6.5, w7.5
pq.gsbf w6.6, w7.6
pq.gsbf w6.7, w7.7, 1, 0, 0
pq.gsbf w22.0, w23.0
pq.gsbf w22.1, w23.1
pq.gsbf w22.2, w23.2
pq.gsbf w22.3, w23.3
pq.gsbf w22.4, w23.4
pq.gsbf w22.5, w23.5
pq.gsbf w22.6, w23.6
pq.gsbf w22.7, w23.7, 1, 0, 0
pq.gsbf w14.0, w15.0
pq.gsbf w14.1, w15.1
pq.gsbf w14.2, w15.2
pq.gsbf w14.3, w15.3
pq.gsbf w14.4, w15.4
pq.gsbf w14.5, w15.5
pq.gsbf w14.6, w15.6
pq.gsbf w14.7, w15.7, 1, 0, 0
pq.gsbf w30.0, w31.0
pq.gsbf w30.1, w31.1
pq.gsbf w30.2, w31.2
pq.gsbf w30.3, w31.3
pq.gsbf w30.4, w31.4
pq.gsbf w30.5, w31.5
pq.gsbf w30.6, w31.6
pq.gsbf w30.7, w31.7, 1, 1, 1

/*************************************************/
/*                 NTT-Layer:16                 */
/*************************************************/
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w0.0, w2.0
pq.gsbf w0.1, w2.1
pq.gsbf w0.2, w2.2
pq.gsbf w0.3, w2.3
pq.gsbf w0.4, w2.4
pq.gsbf w0.5, w2.5
pq.gsbf w0.6, w2.6
pq.gsbf w0.7, w2.7
pq.gsbf w1.0, w3.0
pq.gsbf w1.1, w3.1
pq.gsbf w1.2, w3.2
pq.gsbf w1.3, w3.3
pq.gsbf w1.4, w3.4
pq.gsbf w1.5, w3.5
pq.gsbf w1.6, w3.6
pq.gsbf w1.7, w3.7, 1, 0, 0
pq.gsbf w16.0, w18.0
pq.gsbf w16.1, w18.1
pq.gsbf w16.2, w18.2
pq.gsbf w16.3, w18.3
pq.gsbf w16.4, w18.4
pq.gsbf w16.5, w18.5
pq.gsbf w16.6, w18.6
pq.gsbf w16.7, w18.7
pq.gsbf w17.0, w19.0
pq.gsbf w17.1, w19.1
pq.gsbf w17.2, w19.2
pq.gsbf w17.3, w19.3
pq.gsbf w17.4, w19.4
pq.gsbf w17.5, w19.5
pq.gsbf w17.6, w19.6
pq.gsbf w17.7, w19.7, 1, 0, 0
pq.gsbf w8.0, w10.0
pq.gsbf w8.1, w10.1
pq.gsbf w8.2, w10.2
pq.gsbf w8.3, w10.3
pq.gsbf w8.4, w10.4
pq.gsbf w8.5, w10.5
pq.gsbf w8.6, w10.6
pq.gsbf w8.7, w10.7
pq.gsbf w9.0, w11.0
pq.gsbf w9.1, w11.1
pq.gsbf w9.2, w11.2
pq.gsbf w9.3, w11.3
pq.gsbf w9.4, w11.4
pq.gsbf w9.5, w11.5
pq.gsbf w9.6, w11.6
pq.gsbf w9.7, w11.7, 1, 0, 0
pq.gsbf w24.0, w26.0
pq.gsbf w24.1, w26.1
pq.gsbf w24.2, w26.2
pq.gsbf w24.3, w26.3
pq.gsbf w24.4, w26.4
pq.gsbf w24.5, w26.5
pq.gsbf w24.6, w26.6
pq.gsbf w24.7, w26.7
pq.gsbf w25.0, w27.0
pq.gsbf w25.1, w27.1
pq.gsbf w25.2, w27.2
pq.gsbf w25.3, w27.3
pq.gsbf w25.4, w27.4
pq.gsbf w25.5, w27.5
pq.gsbf w25.6, w27.6
pq.gsbf w25.7, w27.7, 1, 0, 0
pq.gsbf w4.0, w6.0
pq.gsbf w4.1, w6.1
pq.gsbf w4.2, w6.2
pq.gsbf w4.3, w6.3
pq.gsbf w4.4, w6.4
pq.gsbf w4.5, w6.5
pq.gsbf w4.6, w6.6
pq.gsbf w4.7, w6.7
pq.gsbf w5.0, w7.0
pq.gsbf w5.1, w7.1
pq.gsbf w5.2, w7.2
pq.gsbf w5.3, w7.3
pq.gsbf w5.4, w7.4
pq.gsbf w5.5, w7.5
pq.gsbf w5.6, w7.6
pq.gsbf w5.7, w7.7, 1, 0, 0
pq.gsbf w20.0, w22.0
pq.gsbf w20.1, w22.1
pq.gsbf w20.2, w22.2
pq.gsbf w20.3, w22.3
pq.gsbf w20.4, w22.4
pq.gsbf w20.5, w22.5
pq.gsbf w20.6, w22.6
pq.gsbf w20.7, w22.7
pq.gsbf w21.0, w23.0
pq.gsbf w21.1, w23.1
pq.gsbf w21.2, w23.2
pq.gsbf w21.3, w23.3
pq.gsbf w21.4, w23.4
pq.gsbf w21.5, w23.5
pq.gsbf w21.6, w23.6
pq.gsbf w21.7, w23.7, 1, 0, 0
pq.gsbf w12.0, w14.0
pq.gsbf w12.1, w14.1
pq.gsbf w12.2, w14.2
pq.gsbf w12.3, w14.3
pq.gsbf w12.4, w14.4
pq.gsbf w12.5, w14.5
pq.gsbf w12.6, w14.6
pq.gsbf w12.7, w14.7
pq.gsbf w13.0, w15.0
pq.gsbf w13.1, w15.1
pq.gsbf w13.2, w15.2
pq.gsbf w13.3, w15.3
pq.gsbf w13.4, w15.4
pq.gsbf w13.5, w15.5
pq.gsbf w13.6, w15.6
pq.gsbf w13.7, w15.7, 1, 0, 0
pq.gsbf w28.0, w30.0
pq.gsbf w28.1, w30.1
pq.gsbf w28.2, w30.2
pq.gsbf w28.3, w30.3
pq.gsbf w28.4, w30.4
pq.gsbf w28.5, w30.5
pq.gsbf w28.6, w30.6
pq.gsbf w28.7, w30.7
pq.gsbf w29.0, w31.0
pq.gsbf w29.1, w31.1
pq.gsbf w29.2, w31.2
pq.gsbf w29.3, w31.3
pq.gsbf w29.4, w31.4
pq.gsbf w29.5, w31.5
pq.gsbf w29.6, w31.6
pq.gsbf w29.7, w31.7, 1, 1, 1

/*************************************************/
/*                 NTT-Layer:32                 */
/*************************************************/
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w0.0, w4.0
pq.gsbf w0.1, w4.1
pq.gsbf w0.2, w4.2
pq.gsbf w0.3, w4.3
pq.gsbf w0.4, w4.4
pq.gsbf w0.5, w4.5
pq.gsbf w0.6, w4.6
pq.gsbf w0.7, w4.7
pq.gsbf w1.0, w5.0
pq.gsbf w1.1, w5.1
pq.gsbf w1.2, w5.2
pq.gsbf w1.3, w5.3
pq.gsbf w1.4, w5.4
pq.gsbf w1.5, w5.5
pq.gsbf w1.6, w5.6
pq.gsbf w1.7, w5.7
pq.gsbf w2.0, w6.0
pq.gsbf w2.1, w6.1
pq.gsbf w2.2, w6.2
pq.gsbf w2.3, w6.3
pq.gsbf w2.4, w6.4
pq.gsbf w2.5, w6.5
pq.gsbf w2.6, w6.6
pq.gsbf w2.7, w6.7
pq.gsbf w3.0, w7.0
pq.gsbf w3.1, w7.1
pq.gsbf w3.2, w7.2
pq.gsbf w3.3, w7.3
pq.gsbf w3.4, w7.4
pq.gsbf w3.5, w7.5
pq.gsbf w3.6, w7.6
pq.gsbf w3.7, w7.7, 1, 0, 0
pq.gsbf w16.0, w20.0
pq.gsbf w16.1, w20.1
pq.gsbf w16.2, w20.2
pq.gsbf w16.3, w20.3
pq.gsbf w16.4, w20.4
pq.gsbf w16.5, w20.5
pq.gsbf w16.6, w20.6
pq.gsbf w16.7, w20.7
pq.gsbf w17.0, w21.0
pq.gsbf w17.1, w21.1
pq.gsbf w17.2, w21.2
pq.gsbf w17.3, w21.3
pq.gsbf w17.4, w21.4
pq.gsbf w17.5, w21.5
pq.gsbf w17.6, w21.6
pq.gsbf w17.7, w21.7
pq.gsbf w18.0, w22.0
pq.gsbf w18.1, w22.1
pq.gsbf w18.2, w22.2
pq.gsbf w18.3, w22.3
pq.gsbf w18.4, w22.4
pq.gsbf w18.5, w22.5
pq.gsbf w18.6, w22.6
pq.gsbf w18.7, w22.7
pq.gsbf w19.0, w23.0
pq.gsbf w19.1, w23.1
pq.gsbf w19.2, w23.2
pq.gsbf w19.3, w23.3
pq.gsbf w19.4, w23.4
pq.gsbf w19.5, w23.5
pq.gsbf w19.6, w23.6
pq.gsbf w19.7, w23.7, 1, 0, 0
pq.gsbf w8.0, w12.0
pq.gsbf w8.1, w12.1
pq.gsbf w8.2, w12.2
pq.gsbf w8.3, w12.3
pq.gsbf w8.4, w12.4
pq.gsbf w8.5, w12.5
pq.gsbf w8.6, w12.6
pq.gsbf w8.7, w12.7
pq.gsbf w9.0, w13.0
pq.gsbf w9.1, w13.1
pq.gsbf w9.2, w13.2
pq.gsbf w9.3, w13.3
pq.gsbf w9.4, w13.4
pq.gsbf w9.5, w13.5
pq.gsbf w9.6, w13.6
pq.gsbf w9.7, w13.7
pq.gsbf w10.0, w14.0
pq.gsbf w10.1, w14.1
pq.gsbf w10.2, w14.2
pq.gsbf w10.3, w14.3
pq.gsbf w10.4, w14.4
pq.gsbf w10.5, w14.5
pq.gsbf w10.6, w14.6
pq.gsbf w10.7, w14.7
pq.gsbf w11.0, w15.0
pq.gsbf w11.1, w15.1
pq.gsbf w11.2, w15.2
pq.gsbf w11.3, w15.3
pq.gsbf w11.4, w15.4
pq.gsbf w11.5, w15.5
pq.gsbf w11.6, w15.6
pq.gsbf w11.7, w15.7, 1, 0, 0
pq.gsbf w24.0, w28.0
pq.gsbf w24.1, w28.1
pq.gsbf w24.2, w28.2
pq.gsbf w24.3, w28.3
pq.gsbf w24.4, w28.4
pq.gsbf w24.5, w28.5
pq.gsbf w24.6, w28.6
pq.gsbf w24.7, w28.7
pq.gsbf w25.0, w29.0
pq.gsbf w25.1, w29.1
pq.gsbf w25.2, w29.2
pq.gsbf w25.3, w29.3
pq.gsbf w25.4, w29.4
pq.gsbf w25.5, w29.5
pq.gsbf w25.6, w29.6
pq.gsbf w25.7, w29.7
pq.gsbf w26.0, w30.0
pq.gsbf w26.1, w30.1
pq.gsbf w26.2, w30.2
pq.gsbf w26.3, w30.3
pq.gsbf w26.4, w30.4
pq.gsbf w26.5, w30.5
pq.gsbf w26.6, w30.6
pq.gsbf w26.7, w30.7
pq.gsbf w27.0, w31.0
pq.gsbf w27.1, w31.1
pq.gsbf w27.2, w31.2
pq.gsbf w27.3, w31.3
pq.gsbf w27.4, w31.4
pq.gsbf w27.5, w31.5
pq.gsbf w27.6, w31.6
pq.gsbf w27.7, w31.7, 1, 1, 1

/*************************************************/
/*                 NTT-Layer:64                 */
/*************************************************/
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w0.0, w8.0
pq.gsbf w0.1, w8.1
pq.gsbf w0.2, w8.2
pq.gsbf w0.3, w8.3
pq.gsbf w0.4, w8.4
pq.gsbf w0.5, w8.5
pq.gsbf w0.6, w8.6
pq.gsbf w0.7, w8.7
pq.gsbf w1.0, w9.0
pq.gsbf w1.1, w9.1
pq.gsbf w1.2, w9.2
pq.gsbf w1.3, w9.3
pq.gsbf w1.4, w9.4
pq.gsbf w1.5, w9.5
pq.gsbf w1.6, w9.6
pq.gsbf w1.7, w9.7
pq.gsbf w2.0, w10.0
pq.gsbf w2.1, w10.1
pq.gsbf w2.2, w10.2
pq.gsbf w2.3, w10.3
pq.gsbf w2.4, w10.4
pq.gsbf w2.5, w10.5
pq.gsbf w2.6, w10.6
pq.gsbf w2.7, w10.7
pq.gsbf w3.0, w11.0
pq.gsbf w3.1, w11.1
pq.gsbf w3.2, w11.2
pq.gsbf w3.3, w11.3
pq.gsbf w3.4, w11.4
pq.gsbf w3.5, w11.5
pq.gsbf w3.6, w11.6
pq.gsbf w3.7, w11.7
pq.gsbf w4.0, w12.0
pq.gsbf w4.1, w12.1
pq.gsbf w4.2, w12.2
pq.gsbf w4.3, w12.3
pq.gsbf w4.4, w12.4
pq.gsbf w4.5, w12.5
pq.gsbf w4.6, w12.6
pq.gsbf w4.7, w12.7
pq.gsbf w5.0, w13.0
pq.gsbf w5.1, w13.1
pq.gsbf w5.2, w13.2
pq.gsbf w5.3, w13.3
pq.gsbf w5.4, w13.4
pq.gsbf w5.5, w13.5
pq.gsbf w5.6, w13.6
pq.gsbf w5.7, w13.7
pq.gsbf w6.0, w14.0
pq.gsbf w6.1, w14.1
pq.gsbf w6.2, w14.2
pq.gsbf w6.3, w14.3
pq.gsbf w6.4, w14.4
pq.gsbf w6.5, w14.5
pq.gsbf w6.6, w14.6
pq.gsbf w6.7, w14.7
pq.gsbf w7.0, w15.0
pq.gsbf w7.1, w15.1
pq.gsbf w7.2, w15.2
pq.gsbf w7.3, w15.3
pq.gsbf w7.4, w15.4
pq.gsbf w7.5, w15.5
pq.gsbf w7.6, w15.6
pq.gsbf w7.7, w15.7, 1, 0, 0
pq.gsbf w16.0, w24.0
pq.gsbf w16.1, w24.1
pq.gsbf w16.2, w24.2
pq.gsbf w16.3, w24.3
pq.gsbf w16.4, w24.4
pq.gsbf w16.5, w24.5
pq.gsbf w16.6, w24.6
pq.gsbf w16.7, w24.7
pq.gsbf w17.0, w25.0
pq.gsbf w17.1, w25.1
pq.gsbf w17.2, w25.2
pq.gsbf w17.3, w25.3
pq.gsbf w17.4, w25.4
pq.gsbf w17.5, w25.5
pq.gsbf w17.6, w25.6
pq.gsbf w17.7, w25.7
pq.gsbf w18.0, w26.0
pq.gsbf w18.1, w26.1
pq.gsbf w18.2, w26.2
pq.gsbf w18.3, w26.3
pq.gsbf w18.4, w26.4
pq.gsbf w18.5, w26.5
pq.gsbf w18.6, w26.6
pq.gsbf w18.7, w26.7
pq.gsbf w19.0, w27.0
pq.gsbf w19.1, w27.1
pq.gsbf w19.2, w27.2
pq.gsbf w19.3, w27.3
pq.gsbf w19.4, w27.4
pq.gsbf w19.5, w27.5
pq.gsbf w19.6, w27.6
pq.gsbf w19.7, w27.7
pq.gsbf w20.0, w28.0
pq.gsbf w20.1, w28.1
pq.gsbf w20.2, w28.2
pq.gsbf w20.3, w28.3
pq.gsbf w20.4, w28.4
pq.gsbf w20.5, w28.5
pq.gsbf w20.6, w28.6
pq.gsbf w20.7, w28.7
pq.gsbf w21.0, w29.0
pq.gsbf w21.1, w29.1
pq.gsbf w21.2, w29.2
pq.gsbf w21.3, w29.3
pq.gsbf w21.4, w29.4
pq.gsbf w21.5, w29.5
pq.gsbf w21.6, w29.6
pq.gsbf w21.7, w29.7
pq.gsbf w22.0, w30.0
pq.gsbf w22.1, w30.1
pq.gsbf w22.2, w30.2
pq.gsbf w22.3, w30.3
pq.gsbf w22.4, w30.4
pq.gsbf w22.5, w30.5
pq.gsbf w22.6, w30.6
pq.gsbf w22.7, w30.7
pq.gsbf w23.0, w31.0
pq.gsbf w23.1, w31.1
pq.gsbf w23.2, w31.2
pq.gsbf w23.3, w31.3
pq.gsbf w23.4, w31.4
pq.gsbf w23.5, w31.5
pq.gsbf w23.6, w31.6
pq.gsbf w23.7, w31.7, 1, 1, 1

/*************************************************/
/*                 NTT-Layer:128                 */
/*************************************************/
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w0.0, w16.0
pq.gsbf w0.1, w16.1
pq.gsbf w0.2, w16.2
pq.gsbf w0.3, w16.3
pq.gsbf w0.4, w16.4
pq.gsbf w0.5, w16.5
pq.gsbf w0.6, w16.6
pq.gsbf w0.7, w16.7
pq.gsbf w1.0, w17.0
pq.gsbf w1.1, w17.1
pq.gsbf w1.2, w17.2
pq.gsbf w1.3, w17.3
pq.gsbf w1.4, w17.4
pq.gsbf w1.5, w17.5
pq.gsbf w1.6, w17.6
pq.gsbf w1.7, w17.7
pq.gsbf w2.0, w18.0
pq.gsbf w2.1, w18.1
pq.gsbf w2.2, w18.2
pq.gsbf w2.3, w18.3
pq.gsbf w2.4, w18.4
pq.gsbf w2.5, w18.5
pq.gsbf w2.6, w18.6
pq.gsbf w2.7, w18.7
pq.gsbf w3.0, w19.0
pq.gsbf w3.1, w19.1
pq.gsbf w3.2, w19.2
pq.gsbf w3.3, w19.3
pq.gsbf w3.4, w19.4
pq.gsbf w3.5, w19.5
pq.gsbf w3.6, w19.6
pq.gsbf w3.7, w19.7
pq.gsbf w4.0, w20.0
pq.gsbf w4.1, w20.1
pq.gsbf w4.2, w20.2
pq.gsbf w4.3, w20.3
pq.gsbf w4.4, w20.4
pq.gsbf w4.5, w20.5
pq.gsbf w4.6, w20.6
pq.gsbf w4.7, w20.7
pq.gsbf w5.0, w21.0
pq.gsbf w5.1, w21.1
pq.gsbf w5.2, w21.2
pq.gsbf w5.3, w21.3
pq.gsbf w5.4, w21.4
pq.gsbf w5.5, w21.5
pq.gsbf w5.6, w21.6
pq.gsbf w5.7, w21.7
pq.gsbf w6.0, w22.0
pq.gsbf w6.1, w22.1
pq.gsbf w6.2, w22.2
pq.gsbf w6.3, w22.3
pq.gsbf w6.4, w22.4
pq.gsbf w6.5, w22.5
pq.gsbf w6.6, w22.6
pq.gsbf w6.7, w22.7
pq.gsbf w7.0, w23.0
pq.gsbf w7.1, w23.1
pq.gsbf w7.2, w23.2
pq.gsbf w7.3, w23.3
pq.gsbf w7.4, w23.4
pq.gsbf w7.5, w23.5
pq.gsbf w7.6, w23.6
pq.gsbf w7.7, w23.7
pq.gsbf w8.0, w24.0
pq.gsbf w8.1, w24.1
pq.gsbf w8.2, w24.2
pq.gsbf w8.3, w24.3
pq.gsbf w8.4, w24.4
pq.gsbf w8.5, w24.5
pq.gsbf w8.6, w24.6
pq.gsbf w8.7, w24.7
pq.gsbf w9.0, w25.0
pq.gsbf w9.1, w25.1
pq.gsbf w9.2, w25.2
pq.gsbf w9.3, w25.3
pq.gsbf w9.4, w25.4
pq.gsbf w9.5, w25.5
pq.gsbf w9.6, w25.6
pq.gsbf w9.7, w25.7
pq.gsbf w10.0, w26.0
pq.gsbf w10.1, w26.1
pq.gsbf w10.2, w26.2
pq.gsbf w10.3, w26.3
pq.gsbf w10.4, w26.4
pq.gsbf w10.5, w26.5
pq.gsbf w10.6, w26.6
pq.gsbf w10.7, w26.7
pq.gsbf w11.0, w27.0
pq.gsbf w11.1, w27.1
pq.gsbf w11.2, w27.2
pq.gsbf w11.3, w27.3
pq.gsbf w11.4, w27.4
pq.gsbf w11.5, w27.5
pq.gsbf w11.6, w27.6
pq.gsbf w11.7, w27.7
pq.gsbf w12.0, w28.0
pq.gsbf w12.1, w28.1
pq.gsbf w12.2, w28.2
pq.gsbf w12.3, w28.3
pq.gsbf w12.4, w28.4
pq.gsbf w12.5, w28.5
pq.gsbf w12.6, w28.6
pq.gsbf w12.7, w28.7
pq.gsbf w13.0, w29.0
pq.gsbf w13.1, w29.1
pq.gsbf w13.2, w29.2
pq.gsbf w13.3, w29.3
pq.gsbf w13.4, w29.4
pq.gsbf w13.5, w29.5
pq.gsbf w13.6, w29.6
pq.gsbf w13.7, w29.7
pq.gsbf w14.0, w30.0
pq.gsbf w14.1, w30.1
pq.gsbf w14.2, w30.2
pq.gsbf w14.3, w30.3
pq.gsbf w14.4, w30.4
pq.gsbf w14.5, w30.5
pq.gsbf w14.6, w30.6
pq.gsbf w14.7, w30.7
pq.gsbf w15.0, w31.0
pq.gsbf w15.1, w31.1
pq.gsbf w15.2, w31.2
pq.gsbf w15.3, w31.3
pq.gsbf w15.4, w31.4
pq.gsbf w15.5, w31.5
pq.gsbf w15.6, w31.6
pq.gsbf w15.7, w31.7, 1, 1, 1

li x4, 0

pq.srw 3, x4
loopi 256, 1
  pq.scale.ind 0, 0, 0, 0, 1

/* store result from [w1] to dmem */
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
  .quad 0x00000000000001f4
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000ce7

psi:
  .quad 0x0000000000000732
  .quad 0x0000000000000000  
  .quad 0x0000000000000000
  .quad 0x0000000000000000

coef0:
  .quad 0x00000b1d0000097d
  .quad 0x0000031b000001a9
  .quad 0x0000054c00000749
  .quad 0x0000001f00000270

coef1:
  .quad 0x00000895000009b3
  .quad 0x00000a6c00000aa5
  .quad 0x0000020500000a93
  .quad 0x00000892000005d0

coef2:
  .quad 0x00000323000007b3
  .quad 0x000000e70000039a
  .quad 0x000002650000090f
  .quad 0x0000025e00000433

coef3:
  .quad 0x00000c4700000132
  .quad 0x00000a9e00000564
  .quad 0x0000021300000483
  .quad 0x0000063200000332

coef4:
  .quad 0x0000009b00000b3a
  .quad 0x000005a200000130
  .quad 0x000006b000000a3b
  .quad 0x0000086f00000879

coef5:
  .quad 0x00000a4a000005c7
  .quad 0x000007de00000b30
  .quad 0x00000c800000068f
  .quad 0x0000078300000066

coef6:
  .quad 0x0000022e00000643
  .quad 0x0000013c000002a9
  .quad 0x000003a300000205
  .quad 0x000007cf000006c4

coef7:
  .quad 0x00000446000007e8
  .quad 0x0000086f000008e4
  .quad 0x000007b50000088b
  .quad 0x0000086e00000a4d

coef8:
  .quad 0x000000c600000945
  .quad 0x000000f700000baa
  .quad 0x000001c1000005ca
  .quad 0x0000050a00000485

coef9:
  .quad 0x000008ac00000421
  .quad 0x000003fb00000464
  .quad 0x0000089e00000190
  .quad 0x000008b9000004c9

coef10:
  .quad 0x00000b4000000560
  .quad 0x0000026600000a68
  .quad 0x000007b6000007a8
  .quad 0x00000a7700000b76

coef11:
  .quad 0x000008a900000b2c
  .quad 0x00000ca200000b51
  .quad 0x0000002400000771
  .quad 0x0000086100000902

coef12:
  .quad 0x00000245000000db
  .quad 0x0000056200000bb8
  .quad 0x00000b1300000958
  .quad 0x0000044300000695

coef13:
  .quad 0x000008660000041e
  .quad 0x00000c780000021f
  .quad 0x00000cae000009d6
  .quad 0x0000023a000008e5

coef14:
  .quad 0x000009da000000ef
  .quad 0x000007c600000346
  .quad 0x00000a4d0000007e
  .quad 0x000003320000007e

coef15:
  .quad 0x0000043300000ca0
  .quad 0x000002e6000003ac
  .quad 0x0000027600000a39
  .quad 0x00000ad80000028a

coef16:
  .quad 0x000001e200000a2e
  .quad 0x00000364000008a0
  .quad 0x000008650000079d
  .quad 0x0000076800000bfa

coef17:
  .quad 0x0000090200000bb4
  .quad 0x000003730000003f
  .quad 0x000005210000099f
  .quad 0x00000bb70000079f

coef18:
  .quad 0x0000070e00000061
  .quad 0x0000083800000b0e
  .quad 0x00000995000006eb
  .quad 0x00000a2d00000172

coef19:
  .quad 0x000005bb00000367
  .quad 0x000007c10000097a
  .quad 0x000002920000093b
  .quad 0x0000028f000003f7

coef20:
  .quad 0x00000298000001f5
  .quad 0x00000c30000004e1
  .quad 0x00000c1c0000006a
  .quad 0x0000077f000004fa

coef21:
  .quad 0x0000086300000762
  .quad 0x0000079d000007a9
  .quad 0x000001cd000006ca
  .quad 0x000004f600000ad4

coef22:
  .quad 0x0000082900000c17
  .quad 0x00000a100000041b
  .quad 0x000006c70000065c
  .quad 0x000007f200000c7b

coef23:
  .quad 0x0000020c0000028f
  .quad 0x0000038500000c7b
  .quad 0x0000058b000007d7
  .quad 0x0000091e0000009d

coef24:
  .quad 0x00000b0900000928
  .quad 0x000003520000027a
  .quad 0x00000a52000009db
  .quad 0x00000644000002a0

coef25:
  .quad 0x00000cd0000000d8
  .quad 0x0000038900000525
  .quad 0x000005fc0000048d
  .quad 0x0000030900000bf3

coef26:
  .quad 0x000006d8000000f2
  .quad 0x0000021500000804
  .quad 0x00000742000003ee
  .quad 0x0000049f00000920

coef27:
  .quad 0x0000068400000678
  .quad 0x00000b82000007f5
  .quad 0x0000041800000888
  .quad 0x00000b0900000068

coef28:
  .quad 0x0000006f0000036d
  .quad 0x000007c500000553
  .quad 0x00000293000007cb
  .quad 0x000001fa0000000c

coef29:
  .quad 0x000007e60000060f
  .quad 0x0000063700000c8c
  .quad 0x0000091a00000665
  .quad 0x00000aeb00000659

coef30:
  .quad 0x0000004600000306
  .quad 0x00000c7a000003ea
  .quad 0x000003db000003a0
  .quad 0x00000bbd00000a9d

coef31:
  .quad 0x0000009500000b43
  .quad 0x00000c2100000a22
  .quad 0x00000856000009c6
  .quad 0x000008ff00000a9d

n1:
  .quad 0x00000000000005a1
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
