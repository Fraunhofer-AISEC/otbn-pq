/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* /* INTT Implementation of Kyber */

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
/*                       NTT                     */
/*************************************************/

/* m = l */
li x2, 2
pq.srw 0, x2

/* j2 = n >> 1 */
li x3, 64
pq.srw 1, x3

/* j = 0 */
li x4, 0
pq.srw 2, x4

/* mode = 1 */
li x5, 1
pq.srw 5, x5

loopi 7, 10
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  loop x3, 4
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
    loop x2, 1
      pq.gsbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
  /* Update psi, omega, m and j2 */
  pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
  srli x3, x3, 1
  slli x2, x2, 1
  pq.srw 2, x4

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
