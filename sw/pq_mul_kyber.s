/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* PQ basecase multiplication for Kyber */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load operands into WDRs */
li x2, 0
li x3, 32

/* Load prime into WDR w0*/
bn.lid x2, 0(x0)

/* Load prime into PQSR*/
pq.pqsrw 0, w0


/* Load prime_dash into WDR w0*/
bn.lid x2, 0(x3)

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w0


/* Load omega into WDR w0*/
bn.lid x2, 64(x3)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load r_dash into WDR w0*/
bn.lid x2, 64(x2)

/* Load r_dash into PQSR*/
pq.pqsrw 7, w0


/*************************************************/
/*                Load Coefficients              */
/*************************************************/

/* Variables for input coefficient DMEM offsets  */
li x4, 0
li x5, 1024

/* Variable for output coefficient DMEM offset  */
li x6, 0

/* WDRs to store input coefficients*/
li x2, 0
li x3, 16

/* WDR for output coefficient*/
li x24, 0

/* Address for first psi value*/
li x7, 128


/*************************************************/
/*             Basecase Multiplication           */
/*************************************************/

/* m = n >> 1 */
li x2, 128
pq.srw 0, x2

/* j2 = 1 */
li x9, 1
pq.srw 1, x9

/* j = 0 */
li x2, 0
pq.srw 2, x2

loopi 4, 45

  /* Load twiddle factors from DMEM and load into WDR w0*/
  bn.lid x2, 0(x7++)

  /* Load new twiddle factors into PQSR*/
  pq.pqsrw 4, w0

  loopi 8, 41

    /* Load new Coefficients */
    bn.lid x2, 256(x4++)
    bn.lid x3, 256(x5++)

    /* Set psi as twiddle and set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0 

    /* First Quarter */
    /* W0.0 = f_(4i) * r_dash */
    pq.scale.ind 0, 0, 0, 0, 1

    /* W0.1 = f_(4i+1) * r_dash */
    pq.scale.ind 0, 0, 0, 0, 1

    /* W24.0 = f_(4i) * r_dash * g_(4i+1) */
    pq.mul w24.0, w0.0, w16.1

    /* W24.1 = f_(4i+1) * r_dash * g_(4i) */
    pq.mul w24.1, w0.1, w16.0

    /* W0.0 = f_(4i) * g_(4_i) */
    pq.mul w0.0, w0.0, w16.0

    /* W0.1 = f_(4i+1) * g_(4_i+1) */
    pq.mul w0.1, w0.1, w16.1

    /* W0.0 = f_(4i+1) * g_(4_i+1) * twiddle */
    /* ?? Shoud this be exchanged with an separat instruction ?? */
    pq.ctbf w0.0, w0.1

    /* W24.1 = f_(4i+1) * g_(4i) + f_(4i) * g_(4i+1) */
    pq.add w0.1, w24.1, w24.0

    /* W24.1 = f_(4i+1) * g_(4_i+1) * twiddle + f_(4i) * g_(4_i) */
    /*pq.add w24.0, w0.1, w1.0*/

    /* Invert twiddle*/
    pq.pqsru 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 

    /* Second Quarter */
    /* W0.2 = f_(4i) * r_dash */
    pq.scale.ind 0, 0, 0, 0, 1

    /* W0.3 = f_(4i+1) * r_dash */
    pq.scale.ind 0, 0, 0, 0, 1

    /* W24.2 = f_(4i) * r_dash * g_(4i+1) */
    pq.mul w24.2, w0.2, w16.3

    /* W24.3 = f_(4i+1) * r_dash * g_(4i) */
    pq.mul w24.3, w0.3, w16.2

    /* W0.2 = f_(4i) * g_(4_i) */
    pq.mul w0.2, w0.2, w16.2

    /* W0.3 = f_(4i+1) * g_(4_i+1) */
    pq.mul w0.3, w0.3, w16.3

    /* W0.0 = f_(4i+1) * g_(4_i+1) * twiddle */
    /* ?? Shoud this be exchanged with an separat instruction ?? */
    pq.ctbf w0.2, w0.3

    /* W24.3 = f_(4i+1) * g_(4i) + f_(4i) * g_(4i+1) */
    pq.add w0.3, w24.3, w24.2

    /* W24.2 = f_(4i+1) * g_(4_i+1) * twiddle + f_(4i) * g_(4_i) */
    /*pq.add w24.2, w0.3, w1.2*/

    /* Invert twiddle*/
    pq.pqsru 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 

    /* Update twiddle and increment psi_idx*/
    pq.pqsru 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0 

    /* Third Quarter */
    /* W0.4 = f_(4i) * r_dash */
    pq.scale.ind 0, 0, 0, 0, 1

    /* W0.5 = f_(4i+1) * r_dash */
    pq.scale.ind 0, 0, 0, 0, 1

    /* W24.4 = f_(4i) * r_dash * g_(4i+1) */
    pq.mul w24.4, w0.4, w16.5

    /* W24.5 = f_(4i+1) * r_dash * g_(4i) */
    pq.mul w24.5, w0.5, w16.4

    /* W0.4 = f_(4i) * g_(4_i) */
    pq.mul w0.4, w0.4, w16.4

    /* W0.5 = f_(4i+1) * g_(4_i+1) */
    pq.mul w0.5, w0.5, w16.5

    /* W0.4 = f_(4i+1) * g_(4_i+1) * twiddle */
    /* ?? Shoud this be exchanged with an separat instruction ?? */
    pq.ctbf w0.4, w0.5

    /* W24.5 = f_(4i+1) * g_(4i) + f_(4i) * g_(4i+1) */
    pq.add w0.5, w24.5, w24.4

    /* W24.4 = f_(4i+1) * g_(4_i+1) * twiddle + f_(4i) * g_(4_i) */
    /*pq.add w24.4, w0.5, w1.4*/

    /* Invert twiddle*/
    pq.pqsru 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 

    /* Fourth Quarter */
    /* W0.6 = f_(4i) * r_dash */
    pq.scale.ind 0, 0, 0, 0, 1

    /* W0.7 = f_(4i+1) * r_dash */
    pq.scale.ind 0, 0, 0, 0, 1

    /* W24.6 = f_(4i) * r_dash * g_(4i+1) */
    pq.mul w24.6, w0.6, w16.7

    /* W24.7 = f_(4i+1) * r_dash * g_(4i) */
    pq.mul w24.7, w0.7, w16.6

    /* W0.6 = f_(4i) * g_(4_i) */
    pq.mul w0.6, w0.6, w16.6

    /* W0.7 = f_(4i+1) * g_(4_i+1) */
    pq.mul w0.7, w0.7, w16.7

    /* W0.6 = f_(4i+1) * g_(4_i+1) * twiddle */
    /* ?? Shoud this be exchanged with an separat instruction ?? */
    pq.ctbf w0.6, w0.7

    /* W24.7 = f_(4i+1) * g_(4i) + f_(4i) * g_(4i+1) */
    pq.add w0.7, w24.7, w24.6

    /* W24.6 = f_(4i+1) * g_(4_i+1) * twiddle + f_(4i) * g_(4_i) */
    /*pq.add w24.6, w0.7, w1.6*/

    /* Invert twiddle*/
    pq.pqsru 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0 

    /* Store Coefficients */
    bn.sid x24, 256(x6++)

  nop

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

r_dash:
  .quad 0x0000000100000bac
  .quad 0x0000000100000bac
  .quad 0x0000000100000bac
  .quad 0x0000000100000bac

omega:
  .quad 0x000000000000094b
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

psi0:
  .quad 0x00000c5300000bd3
  .quad 0x00000bcf00000434
  .quad 0x000006640000088d
  .quad 0x000004f600000361

psi1:
  .quad 0x000006e0000001eb
  .quad 0x00000a4c000008c1
  .quad 0x0000060f00000846
  .quad 0x00000c0000000bdc

psi2:
  .quad 0x00000ba200000a2d
  .quad 0x000005a900000557
  .quad 0x000000560000006f
  .quad 0x0000034800000136

psi3:
  .quad 0x00000a4800000821
  .quad 0x00000ae80000071f
  .quad 0x0000086900000b4f
  .quad 0x000008f600000755

coefa0:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

coefa1:
  .quad 0x0000000900000008
  .quad 0x0000000b0000000a
  .quad 0x0000000d0000000c
  .quad 0x0000000f0000000e

coefa2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

coefa3:
  .quad 0x0000001900000018
  .quad 0x0000001b0000001a
  .quad 0x0000001d0000001c
  .quad 0x0000001f0000001e

coefa4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

coefa5:
  .quad 0x0000002900000028
  .quad 0x0000002b0000002a
  .quad 0x0000002d0000002c
  .quad 0x0000002f0000002e

coefa6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

coefa7:
  .quad 0x0000003900000038
  .quad 0x0000003b0000003a
  .quad 0x0000003d0000003c
  .quad 0x0000003f0000003e

coefa8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

coefa9:
  .quad 0x0000004900000048
  .quad 0x0000004b0000004a
  .quad 0x0000004d0000004c
  .quad 0x0000004f0000004e

coefa10:
  .quad 0x0000005100000050
  .quad 0x0000005300000052
  .quad 0x0000005500000054
  .quad 0x0000005700000056

coefa11:
  .quad 0x0000005900000058
  .quad 0x0000005b0000005a
  .quad 0x0000005d0000005c
  .quad 0x0000005f0000005e

coefa12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

coefa13:
  .quad 0x0000006900000068
  .quad 0x0000006b0000006a
  .quad 0x0000006d0000006c
  .quad 0x0000006f0000006e

coefa14:
  .quad 0x0000007100000070
  .quad 0x0000007300000072
  .quad 0x0000007500000074
  .quad 0x0000007700000076

coefa15:
  .quad 0x0000007900000078
  .quad 0x0000007b0000007a
  .quad 0x0000007d0000007c
  .quad 0x0000007f0000007e

coefa16:
  .quad 0x0000008100000080
  .quad 0x0000008300000082
  .quad 0x0000008500000084
  .quad 0x0000008700000086

coefa17:
  .quad 0x0000008900000088
  .quad 0x0000008b0000008a
  .quad 0x0000008d0000008c
  .quad 0x0000008f0000008e

coefa18:
  .quad 0x0000009100000090
  .quad 0x0000009300000092
  .quad 0x0000009500000094
  .quad 0x0000009700000096

coefa19:
  .quad 0x0000009900000098
  .quad 0x0000009b0000009a
  .quad 0x0000009d0000009c
  .quad 0x0000009f0000009e

coefa20:
  .quad 0x000000a1000000a0
  .quad 0x000000a3000000a2
  .quad 0x000000a5000000a4
  .quad 0x000000a7000000a6

coefa21:
  .quad 0x000000a9000000a8
  .quad 0x000000ab000000aa
  .quad 0x000000ad000000ac
  .quad 0x000000af000000ae

coefa22:
  .quad 0x000000b1000000b0
  .quad 0x000000b3000000b2
  .quad 0x000000b5000000b4
  .quad 0x000000b7000000b6

coefa23:
  .quad 0x000000b9000000b8
  .quad 0x000000bb000000ba
  .quad 0x000000bd000000bc
  .quad 0x000000bf000000be

coefa24:
  .quad 0x000000c1000000c0
  .quad 0x000000c3000000c2
  .quad 0x000000c5000000c4
  .quad 0x000000c7000000c6

coefa25:
  .quad 0x000000c9000000c8
  .quad 0x000000cb000000ca
  .quad 0x000000cd000000cc
  .quad 0x000000cf000000ce

coefa26:
  .quad 0x000000d1000000d0
  .quad 0x000000d3000000d2
  .quad 0x000000d5000000d4
  .quad 0x000000d7000000d6

coefa27:
  .quad 0x000000d9000000d8
  .quad 0x000000db000000da
  .quad 0x000000dd000000dc
  .quad 0x000000df000000de

coefa28:
  .quad 0x000000e1000000e0
  .quad 0x000000e3000000e2
  .quad 0x000000e5000000e4
  .quad 0x000000e7000000e6

coefa29:
  .quad 0x000000e9000000e8
  .quad 0x000000eb000000ea
  .quad 0x000000ed000000ec
  .quad 0x000000ef000000ee

coefa30:
  .quad 0x000000f1000000f0
  .quad 0x000000f3000000f2
  .quad 0x000000f5000000f4
  .quad 0x000000f7000000f6

coefa31:
  .quad 0x000000f9000000f8
  .quad 0x000000fb000000fa
  .quad 0x000000fd000000fc
  .quad 0x000000ff000000fe

coefb0:
  .quad 0x0000000100000000
  .quad 0x0000000300000002
  .quad 0x0000000500000004
  .quad 0x0000000700000006

coefb1:
  .quad 0x0000000900000008
  .quad 0x0000000b0000000a
  .quad 0x0000000d0000000c
  .quad 0x0000000f0000000e

coefb2:
  .quad 0x0000001100000010
  .quad 0x0000001300000012
  .quad 0x0000001500000014
  .quad 0x0000001700000016

coefb3:
  .quad 0x0000001900000018
  .quad 0x0000001b0000001a
  .quad 0x0000001d0000001c
  .quad 0x0000001f0000001e

coefb4:
  .quad 0x0000002100000020
  .quad 0x0000002300000022
  .quad 0x0000002500000024
  .quad 0x0000002700000026

coefb5:
  .quad 0x0000002900000028
  .quad 0x0000002b0000002a
  .quad 0x0000002d0000002c
  .quad 0x0000002f0000002e

coefb6:
  .quad 0x0000003100000030
  .quad 0x0000003300000032
  .quad 0x0000003500000034
  .quad 0x0000003700000036

coefb7:
  .quad 0x0000003900000038
  .quad 0x0000003b0000003a
  .quad 0x0000003d0000003c
  .quad 0x0000003f0000003e

coefb8:
  .quad 0x0000004100000040
  .quad 0x0000004300000042
  .quad 0x0000004500000044
  .quad 0x0000004700000046

coefb9:
  .quad 0x0000004900000048
  .quad 0x0000004b0000004a
  .quad 0x0000004d0000004c
  .quad 0x0000004f0000004e

coefb10:
  .quad 0x0000005100000050
  .quad 0x0000005300000052
  .quad 0x0000005500000054
  .quad 0x0000005700000056

coefb11:
  .quad 0x0000005900000058
  .quad 0x0000005b0000005a
  .quad 0x0000005d0000005c
  .quad 0x0000005f0000005e

coef12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

coef13:
  .quad 0x0000006900000068
  .quad 0x0000006b0000006a
  .quad 0x0000006d0000006c
  .quad 0x0000006f0000006e

coefb14:
  .quad 0x0000007100000070
  .quad 0x0000007300000072
  .quad 0x0000007500000074
  .quad 0x0000007700000076

coefb15:
  .quad 0x0000007900000078
  .quad 0x0000007b0000007a
  .quad 0x0000007d0000007c
  .quad 0x0000007f0000007e

coefb16:
  .quad 0x0000008100000080
  .quad 0x0000008300000082
  .quad 0x0000008500000084
  .quad 0x0000008700000086

coefb17:
  .quad 0x0000008900000088
  .quad 0x0000008b0000008a
  .quad 0x0000008d0000008c
  .quad 0x0000008f0000008e

coefb18:
  .quad 0x0000009100000090
  .quad 0x0000009300000092
  .quad 0x0000009500000094
  .quad 0x0000009700000096

coefb19:
  .quad 0x0000009900000098
  .quad 0x0000009b0000009a
  .quad 0x0000009d0000009c
  .quad 0x0000009f0000009e

coefb20:
  .quad 0x000000a1000000a0
  .quad 0x000000a3000000a2
  .quad 0x000000a5000000a4
  .quad 0x000000a7000000a6

coefb21:
  .quad 0x000000a9000000a8
  .quad 0x000000ab000000aa
  .quad 0x000000ad000000ac
  .quad 0x000000af000000ae

coefb22:
  .quad 0x000000b1000000b0
  .quad 0x000000b3000000b2
  .quad 0x000000b5000000b4
  .quad 0x000000b7000000b6

coefb23:
  .quad 0x000000b9000000b8
  .quad 0x000000bb000000ba
  .quad 0x000000bd000000bc
  .quad 0x000000bf000000be

coefb24:
  .quad 0x000000c1000000c0
  .quad 0x000000c3000000c2
  .quad 0x000000c5000000c4
  .quad 0x000000c7000000c6

coefb25:
  .quad 0x000000c9000000c8
  .quad 0x000000cb000000ca
  .quad 0x000000cd000000cc
  .quad 0x000000cf000000ce

coefb26:
  .quad 0x000000d1000000d0
  .quad 0x000000d3000000d2
  .quad 0x000000d5000000d4
  .quad 0x000000d7000000d6

coefb27:
  .quad 0x000000d9000000d8
  .quad 0x000000db000000da
  .quad 0x000000dd000000dc
  .quad 0x000000df000000de

coefb28:
  .quad 0x000000e1000000e0
  .quad 0x000000e3000000e2
  .quad 0x000000e5000000e4
  .quad 0x000000e7000000e6

coefb29:
  .quad 0x000000e9000000e8
  .quad 0x000000eb000000ea
  .quad 0x000000ed000000ec
  .quad 0x000000ef000000ee

coefb30:
  .quad 0x000000f1000000f0
  .quad 0x000000f3000000f2
  .quad 0x000000f5000000f4
  .quad 0x000000f7000000f6

coefb31:
  .quad 0x000000f9000000f8
  .quad 0x000000fb000000fa
  .quad 0x000000fd000000fc
  .quad 0x000000ff000000fe
