/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* INTT Implementation of Dilithium */

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

/* Load prime_dash into PQSR*/
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
/*                 NTT-Layer:1                 */
/*************************************************/
pq.pqsru 0, 0, 0, 0, 1, 0, 0

pq.gsbf w0.0, w0.1, 1, 0, 0
pq.gsbf w16.0, w16.1, 1, 0, 0
pq.gsbf w8.0, w8.1, 1, 0, 0
pq.gsbf w24.0, w24.1, 1, 0, 0
pq.gsbf w4.0, w4.1, 1, 0, 0
pq.gsbf w20.0, w20.1, 1, 0, 0
pq.gsbf w12.0, w12.1, 1, 0, 0
pq.gsbf w28.0, w28.1, 1, 0, 0
pq.gsbf w2.0, w2.1, 1, 0, 0
pq.gsbf w18.0, w18.1, 1, 0, 0
pq.gsbf w10.0, w10.1, 1, 0, 0
pq.gsbf w26.0, w26.1, 1, 0, 0
pq.gsbf w6.0, w6.1, 1, 0, 0
pq.gsbf w22.0, w22.1, 1, 0, 0
pq.gsbf w14.0, w14.1, 1, 0, 0
pq.gsbf w30.0, w30.1, 1, 0, 0
pq.gsbf w1.0, w1.1, 1, 0, 0
pq.gsbf w17.0, w17.1, 1, 0, 0
pq.gsbf w9.0, w9.1, 1, 0, 0
pq.gsbf w25.0, w25.1, 1, 0, 0
pq.gsbf w5.0, w5.1, 1, 0, 0
pq.gsbf w21.0, w21.1, 1, 0, 0
pq.gsbf w13.0, w13.1, 1, 0, 0
pq.gsbf w29.0, w29.1, 1, 0, 0
pq.gsbf w3.0, w3.1, 1, 0, 0
pq.gsbf w19.0, w19.1, 1, 0, 0
pq.gsbf w11.0, w11.1, 1, 0, 0
pq.gsbf w27.0, w27.1, 1, 0, 0
pq.gsbf w7.0, w7.1, 1, 0, 0
pq.gsbf w23.0, w23.1, 1, 0, 0
pq.gsbf w15.0, w15.1, 1, 0, 0
pq.gsbf w31.0, w31.1, 1, 0, 0
pq.gsbf w0.4, w0.5, 1, 0, 0
pq.gsbf w16.4, w16.5, 1, 0, 0
pq.gsbf w8.4, w8.5, 1, 0, 0
pq.gsbf w24.4, w24.5, 1, 0, 0
pq.gsbf w4.4, w4.5, 1, 0, 0
pq.gsbf w20.4, w20.5, 1, 0, 0
pq.gsbf w12.4, w12.5, 1, 0, 0
pq.gsbf w28.4, w28.5, 1, 0, 0
pq.gsbf w2.4, w2.5, 1, 0, 0
pq.gsbf w18.4, w18.5, 1, 0, 0
pq.gsbf w10.4, w10.5, 1, 0, 0
pq.gsbf w26.4, w26.5, 1, 0, 0
pq.gsbf w6.4, w6.5, 1, 0, 0
pq.gsbf w22.4, w22.5, 1, 0, 0
pq.gsbf w14.4, w14.5, 1, 0, 0
pq.gsbf w30.4, w30.5, 1, 0, 0
pq.gsbf w1.4, w1.5, 1, 0, 0
pq.gsbf w17.4, w17.5, 1, 0, 0
pq.gsbf w9.4, w9.5, 1, 0, 0
pq.gsbf w25.4, w25.5, 1, 0, 0
pq.gsbf w5.4, w5.5, 1, 0, 0
pq.gsbf w21.4, w21.5, 1, 0, 0
pq.gsbf w13.4, w13.5, 1, 0, 0
pq.gsbf w29.4, w29.5, 1, 0, 0
pq.gsbf w3.4, w3.5, 1, 0, 0
pq.gsbf w19.4, w19.5, 1, 0, 0
pq.gsbf w11.4, w11.5, 1, 0, 0
pq.gsbf w27.4, w27.5, 1, 0, 0
pq.gsbf w7.4, w7.5, 1, 0, 0
pq.gsbf w23.4, w23.5, 1, 0, 0
pq.gsbf w15.4, w15.5, 1, 0, 0
pq.gsbf w31.4, w31.5, 1, 0, 0
pq.gsbf w0.2, w0.3, 1, 0, 0
pq.gsbf w16.2, w16.3, 1, 0, 0
pq.gsbf w8.2, w8.3, 1, 0, 0
pq.gsbf w24.2, w24.3, 1, 0, 0
pq.gsbf w4.2, w4.3, 1, 0, 0
pq.gsbf w20.2, w20.3, 1, 0, 0
pq.gsbf w12.2, w12.3, 1, 0, 0
pq.gsbf w28.2, w28.3, 1, 0, 0
pq.gsbf w2.2, w2.3, 1, 0, 0
pq.gsbf w18.2, w18.3, 1, 0, 0
pq.gsbf w10.2, w10.3, 1, 0, 0
pq.gsbf w26.2, w26.3, 1, 0, 0
pq.gsbf w6.2, w6.3, 1, 0, 0
pq.gsbf w22.2, w22.3, 1, 0, 0
pq.gsbf w14.2, w14.3, 1, 0, 0
pq.gsbf w30.2, w30.3, 1, 0, 0
pq.gsbf w1.2, w1.3, 1, 0, 0
pq.gsbf w17.2, w17.3, 1, 0, 0
pq.gsbf w9.2, w9.3, 1, 0, 0
pq.gsbf w25.2, w25.3, 1, 0, 0
pq.gsbf w5.2, w5.3, 1, 0, 0
pq.gsbf w21.2, w21.3, 1, 0, 0
pq.gsbf w13.2, w13.3, 1, 0, 0
pq.gsbf w29.2, w29.3, 1, 0, 0
pq.gsbf w3.2, w3.3, 1, 0, 0
pq.gsbf w19.2, w19.3, 1, 0, 0
pq.gsbf w11.2, w11.3, 1, 0, 0
pq.gsbf w27.2, w27.3, 1, 0, 0
pq.gsbf w7.2, w7.3, 1, 0, 0
pq.gsbf w23.2, w23.3, 1, 0, 0
pq.gsbf w15.2, w15.3, 1, 0, 0
pq.gsbf w31.2, w31.3, 1, 0, 0
pq.gsbf w0.6, w0.7, 1, 0, 0
pq.gsbf w16.6, w16.7, 1, 0, 0
pq.gsbf w8.6, w8.7, 1, 0, 0
pq.gsbf w24.6, w24.7, 1, 0, 0
pq.gsbf w4.6, w4.7, 1, 0, 0
pq.gsbf w20.6, w20.7, 1, 0, 0
pq.gsbf w12.6, w12.7, 1, 0, 0
pq.gsbf w28.6, w28.7, 1, 0, 0
pq.gsbf w2.6, w2.7, 1, 0, 0
pq.gsbf w18.6, w18.7, 1, 0, 0
pq.gsbf w10.6, w10.7, 1, 0, 0
pq.gsbf w26.6, w26.7, 1, 0, 0
pq.gsbf w6.6, w6.7, 1, 0, 0
pq.gsbf w22.6, w22.7, 1, 0, 0
pq.gsbf w14.6, w14.7, 1, 0, 0
pq.gsbf w30.6, w30.7, 1, 0, 0
pq.gsbf w1.6, w1.7, 1, 0, 0
pq.gsbf w17.6, w17.7, 1, 0, 0
pq.gsbf w9.6, w9.7, 1, 0, 0
pq.gsbf w25.6, w25.7, 1, 0, 0
pq.gsbf w5.6, w5.7, 1, 0, 0
pq.gsbf w21.6, w21.7, 1, 0, 0
pq.gsbf w13.6, w13.7, 1, 0, 0
pq.gsbf w29.6, w29.7, 1, 0, 0
pq.gsbf w3.6, w3.7, 1, 0, 0
pq.gsbf w19.6, w19.7, 1, 0, 0
pq.gsbf w11.6, w11.7, 1, 0, 0
pq.gsbf w27.6, w27.7, 1, 0, 0
pq.gsbf w7.6, w7.7, 1, 0, 0
pq.gsbf w23.6, w23.7, 1, 0, 0
pq.gsbf w15.6, w15.7, 1, 0, 0
pq.gsbf w31.6, w31.7, 1, 1, 1

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
  .quad 0x00000000007fe001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

prime_dash:
  .quad 0x00000000fc7fdfff
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

omega:
  .quad 0x0000000000454828
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

psi:
  .quad 0x000000000061b633
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

coef0:
  .quad 0x004b87b6007a6f0f
  .quad 0x006e487e0053fad1
  .quad 0x000dc925003e366c
  .quad 0x0033b7d30022e609

coef1:
  .quad 0x003bb16300161800
  .quad 0x005167f1003a7d40
  .quad 0x007be2cd00798d85
  .quad 0x0071d5c8006d05f1

coef2:
  .quad 0x00563b37007d20d5
  .quad 0x000007f900591f39
  .quad 0x00230aa3007f1751
  .quad 0x007668d400745664

coef3:
  .quad 0x0025956b006411d6
  .quad 0x0073e8ad00090920
  .quad 0x0045bd3200077bda
  .quad 0x005a1d2e00082a51

coef4:
  .quad 0x000064700022a083
  .quad 0x005c68980000feff
  .quad 0x0052f9b10006addf
  .quad 0x00375e7e0000b099

coef5:
  .quad 0x004aa574005a8498
  .quad 0x003217a7004323f8
  .quad 0x001f216b005521cc
  .quad 0x003caacf007c0b11

coef6:
  .quad 0x00507ed5000d86e3
  .quad 0x0024f561001a2caf
  .quad 0x002627000007af66
  .quad 0x002081ab003507a4

coef7:
  .quad 0x0075990600750fc7
  .quad 0x001ca4d7005e75e7
  .quad 0x006ffea9001cafde
  .quad 0x00710c09004f395b

coef8:
  .quad 0x00640591003dbeaa
  .quad 0x004ffbc6000d2580
  .quad 0x0079934100332561
  .quad 0x002c631b007dbdb8

coef9:
  .quad 0x006bdb720010714b
  .quad 0x001fc55d00103a98
  .quad 0x004acb2a0012b912
  .quad 0x0044ea6e005dcf66

coef10:
  .quad 0x004ae7d70076c946
  .quad 0x007aec390025fe60
  .quad 0x002fee9a001b938a
  .quad 0x00258ca700403dc9

coef11:
  .quad 0x005c66840061badd
  .quad 0x007c4656000aadce
  .quad 0x002af50d00028ff5
  .quad 0x007708b70050ffaa

coef12:
  .quad 0x002b386a006f69e6
  .quad 0x004099be005efae0
  .quad 0x006a58e0003ccc42
  .quad 0x005d9521006d9c8e

coef13:
  .quad 0x00726f22002ed821
  .quad 0x006f896e0054d49c
  .quad 0x004d5a1100527a97
  .quad 0x002567e60032a984

coef14:
  .quad 0x002ed9f7002e6fab
  .quad 0x005f4848003c875e
  .quad 0x00215b4a001fcc1f
  .quad 0x005775ba0078ce31

coef15:
  .quad 0x004941f4007f84f5
  .quad 0x00624ef900348ec3
  .quad 0x00446813002ff2ae
  .quad 0x001e508f003e07ea

coef16:
  .quad 0x00466ded007faf9b
  .quad 0x003fc05f000234b0
  .quad 0x006c9e330029a45c
  .quad 0x002d77500012afc2

coef17:
  .quad 0x0027fb880028e288
  .quad 0x00714eeb0031b252
  .quad 0x0060dfc500449a18
  .quad 0x0045c1b10069631a

coef18:
  .quad 0x004364640052e3c3
  .quad 0x0055194500326a7c
  .quad 0x005c82b800306dd9
  .quad 0x001219f4007d454d

coef19:
  .quad 0x0077a4cb002ef327
  .quad 0x001eb9b0002bdd97
  .quad 0x005495c5004a962e
  .quad 0x006b6379005dd53d

coef20:
  .quad 0x0002447b00294220
  .quad 0x0053d4ca0011fb28
  .quad 0x002489ef002bd05a
  .quad 0x00098de600450ae0

coef21:
  .quad 0x001ed54d007c2cdc
  .quad 0x0069f333002cb813
  .quad 0x00327f030032512c
  .quad 0x00353f2b00796d2b

coef22:
  .quad 0x0021917e0010cf59
  .quad 0x0004c06f0028b5db
  .quad 0x0004185c00466ef3
  .quad 0x0011c6e200780e4c

coef23:
  .quad 0x007920c2005f5013
  .quad 0x004ddb1600346e64
  .quad 0x005bdf9500134bee
  .quad 0x0001966e00326884

coef24:
  .quad 0x00620e1d0003d910
  .quad 0x000e052b003d0359
  .quad 0x0029e983004156b9
  .quad 0x00563c06001399f9

coef25:
  .quad 0x001bbc12006acb1b
  .quad 0x00268ad900080ffc
  .quad 0x007a1cf2004d7f52
  .quad 0x001f53320020337b

coef26:
  .quad 0x0038bd4e00025ea9
  .quad 0x00695d0800582340
  .quad 0x006eb3860053e808
  .quad 0x00611040005c451a

coef27:
  .quad 0x000154bc000df7f2
  .quad 0x0037a7a500138ea8
  .quad 0x0034aad9007f9f93
  .quad 0x001b1bef005ebe1d

coef28:
  .quad 0x0069834d001139ab
  .quad 0x000f8a3f003f5e93
  .quad 0x000eff89006040e6
  .quad 0x001395c900366052

coef29:
  .quad 0x001219ad0018b194
  .quad 0x000b96fa000032d0
  .quad 0x0050c2aa0061fb37
  .quad 0x0070ba7b00259148

coef30:
  .quad 0x00147fb7006f0655
  .quad 0x000eec290013dae5
  .quad 0x0002f5c2003b921f
  .quad 0x0015d02e004eee32

coef31:
  .quad 0x00010b93002502c0
  .quad 0x006badbe0039a2f1
  .quad 0x000efbcb0064073f
  .quad 0x0032089b007b36b9

n1:
  .quad 0x0000000000003ffe
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
