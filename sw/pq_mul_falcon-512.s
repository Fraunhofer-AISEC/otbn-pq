/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* PQ Pointwise Multiplication example for Falcon-512 */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load operands into WDRs */
li x2, 0
li x3, 32

/* Load DMEM(0) into WDR w0*/
bn.lid x2, 0(x0)

/* Load prime into PQSR*/
pq.pqsrw 0, w0


/* Load DMEM(32) into WDR w0*/
bn.lid x2, 0(x3)

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w0


/* Load DMEM(64) into WDR w0*/
bn.lid x2, 64(x0)

/* Load r_dash into PQSR*/
pq.pqsrw 7, w0


/* m = n >> 1 */
li x2, 128
pq.srw 0, x2

/* j2 = 1 */
li x3, 1
pq.srw 1, x3

/* j = 0 */
li x2, 0
pq.srw 2, x2



/*************************************************/
/*                Load Coefficients              */
/*************************************************/

/* Load Coefficients into WDRs */

li x4, 0
li x5, 2048

li x6, 0

li x3, 16

li x24, 24

loopi 64, 14

  bn.lid x2, 128(x4++)
  bn.lid x3, 128(x5++)

  /*************************************************/
  /*         Coefficientwise Multiplication        */
  /*************************************************/

  /* Set idx0/idx1 */
  pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0 

  loopi 8, 1
    /* Transformation in Montgomery Domain */
    pq.scale.ind 0, 0, 0, 0, 1

  /* Coefficientwise Multiplication */
  pq.mul w24.0, w0.0, w16.0
  pq.mul w24.1, w0.1, w16.1
  pq.mul w24.2, w0.2, w16.2
  pq.mul w24.3, w0.3, w16.3
  pq.mul w24.4, w0.4, w16.4
  pq.mul w24.5, w0.5, w16.5
  pq.mul w24.6, w0.6, w16.6
  pq.mul w24.7, w0.7, w16.7

  /*************************************************/
  /*               Store Coefficients              */
  /*************************************************/
  bn.sid x24, 128(x6++)


ecall


.section .data

/* 256-bit integer

   0000000000000000 0000000000000000
   0000000000000000 0000000000000D01

   (.quad below is in reverse order) */

prime:
  .quad 0x0000000000003001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

prime_dash:
  .quad 0x00000000f7002fff
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

r_dash:
  .quad 0x0000000000001620
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

psi:
  .quad 0x000000000061b633
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

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

coefa32:
  .quad 0x0000010100000100
  .quad 0x0000010300000102
  .quad 0x0000010500000104
  .quad 0x0000010700000106

coefa33:
  .quad 0x0000010900000108
  .quad 0x0000010b0000010a
  .quad 0x0000010d0000010c
  .quad 0x0000010f0000010e

coefa34:
  .quad 0x0000011100000110
  .quad 0x0000011300000112
  .quad 0x0000011500000114
  .quad 0x0000011700000116

coefa35:
  .quad 0x0000011900000118
  .quad 0x0000011b0000011a
  .quad 0x0000011d0000011c
  .quad 0x0000011f0000011e

coefa36:
  .quad 0x0000012100000120
  .quad 0x0000012300000122
  .quad 0x0000012500000124
  .quad 0x0000012700000126

coefa37:
  .quad 0x0000012900000128
  .quad 0x0000012b0000012a
  .quad 0x0000012d0000012c
  .quad 0x0000012f0000012e

coefa38:
  .quad 0x0000013100000130
  .quad 0x0000013300000132
  .quad 0x0000013500000134
  .quad 0x0000013700000136

coefa39:
  .quad 0x0000013900000138
  .quad 0x0000013b0000013a
  .quad 0x0000013d0000013c
  .quad 0x0000013f0000013e

coefa40:
  .quad 0x0000014100000140
  .quad 0x0000014300000142
  .quad 0x0000014500000144
  .quad 0x0000014700000146

coefa41:
  .quad 0x0000014900000148
  .quad 0x0000014b0000014a
  .quad 0x0000014d0000014c
  .quad 0x0000014f0000014e

coefa42:
  .quad 0x0000015100000150
  .quad 0x0000015300000152
  .quad 0x0000015500000154
  .quad 0x0000015700000156

coefa43:
  .quad 0x0000015900000158
  .quad 0x0000015b0000015a
  .quad 0x0000015d0000015c
  .quad 0x0000015f0000015e

coefa44:
  .quad 0x0000016100000160
  .quad 0x0000016300000162
  .quad 0x0000016500000164
  .quad 0x0000016700000166

coefa45:
  .quad 0x0000016900000168
  .quad 0x0000016b0000016a
  .quad 0x0000016d0000016c
  .quad 0x0000016f0000016e

coefa46:
  .quad 0x0000017100000170
  .quad 0x0000017300000172
  .quad 0x0000017500000174
  .quad 0x0000017700000176

coefa47:
  .quad 0x0000017900000178
  .quad 0x0000017b0000017a
  .quad 0x0000017d0000017c
  .quad 0x0000017f0000017e

coefa48:
  .quad 0x0000018100000180
  .quad 0x0000018300000182
  .quad 0x0000018500000184
  .quad 0x0000018700000186

coefa49:
  .quad 0x0000018900000188
  .quad 0x0000018b0000018a
  .quad 0x0000018d0000018c
  .quad 0x0000018f0000018e

coefa50:
  .quad 0x0000019100000190
  .quad 0x0000019300000192
  .quad 0x0000019500000194
  .quad 0x0000019700000196

coefa51:
  .quad 0x0000019900000198
  .quad 0x0000019b0000019a
  .quad 0x0000019d0000019c
  .quad 0x0000019f0000019e

coefa52:
  .quad 0x000001a1000001a0
  .quad 0x000001a3000001a2
  .quad 0x000001a5000001a4
  .quad 0x000001a7000001a6

coefa53:
  .quad 0x000001a9000001a8
  .quad 0x000001ab000001aa
  .quad 0x000001ad000001ac
  .quad 0x000001af000001ae

coefa54:
  .quad 0x000001b1000001b0
  .quad 0x000001b3000001b2
  .quad 0x000001b5000001b4
  .quad 0x000001b7000001b6

coefa55:
  .quad 0x000001b9000001b8
  .quad 0x000001bb000001ba
  .quad 0x000001bd000001bc
  .quad 0x000001bf000001be

coefa56:
  .quad 0x000001c1000001c0
  .quad 0x000001c3000001c2
  .quad 0x000001c5000001c4
  .quad 0x000001c7000001c6

coefa57:
  .quad 0x000001c9000001c8
  .quad 0x000001cb000001ca
  .quad 0x000001cd000001cc
  .quad 0x000001cf000001ce

coefa58:
  .quad 0x000001d1000001d0
  .quad 0x000001d3000001d2
  .quad 0x000001d5000001d4
  .quad 0x000001d7000001d6

coefa59:
  .quad 0x000001d9000001d8
  .quad 0x000001db000001da
  .quad 0x000001dd000001dc
  .quad 0x000001df000001de

coefa60:
  .quad 0x000001e1000001e0
  .quad 0x000001e3000001e2
  .quad 0x000001e5000001e4
  .quad 0x000001e7000001e6

coefa61:
  .quad 0x000001e9000001e8
  .quad 0x000001eb000001ea
  .quad 0x000001ed000001ec
  .quad 0x000001ef000001ee

coefa62:
  .quad 0x000001f1000001f0
  .quad 0x000001f3000001f2
  .quad 0x000001f5000001f4
  .quad 0x000001f7000001f6

coefa63:
  .quad 0x000001f9000001f8
  .quad 0x000001fb000001fa
  .quad 0x000001fd000001fc
  .quad 0x000001ff000001fe

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

coefb12:
  .quad 0x0000006100000060
  .quad 0x0000006300000062
  .quad 0x0000006500000064
  .quad 0x0000006700000066

coefb13:
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

coefb32:
  .quad 0x0000010100000100
  .quad 0x0000010300000102
  .quad 0x0000010500000104
  .quad 0x0000010700000106

coefb33:
  .quad 0x0000010900000108
  .quad 0x0000010b0000010a
  .quad 0x0000010d0000010c
  .quad 0x0000010f0000010e

coefb34:
  .quad 0x0000011100000110
  .quad 0x0000011300000112
  .quad 0x0000011500000114
  .quad 0x0000011700000116

coefb35:
  .quad 0x0000011900000118
  .quad 0x0000011b0000011a
  .quad 0x0000011d0000011c
  .quad 0x0000011f0000011e

coefb36:
  .quad 0x0000012100000120
  .quad 0x0000012300000122
  .quad 0x0000012500000124
  .quad 0x0000012700000126

coefb37:
  .quad 0x0000012900000128
  .quad 0x0000012b0000012a
  .quad 0x0000012d0000012c
  .quad 0x0000012f0000012e

coefb38:
  .quad 0x0000013100000130
  .quad 0x0000013300000132
  .quad 0x0000013500000134
  .quad 0x0000013700000136

coefb39:
  .quad 0x0000013900000138
  .quad 0x0000013b0000013a
  .quad 0x0000013d0000013c
  .quad 0x0000013f0000013e

coefb40:
  .quad 0x0000014100000140
  .quad 0x0000014300000142
  .quad 0x0000014500000144
  .quad 0x0000014700000146

coefb41:
  .quad 0x0000014900000148
  .quad 0x0000014b0000014a
  .quad 0x0000014d0000014c
  .quad 0x0000014f0000014e

coefb42:
  .quad 0x0000015100000150
  .quad 0x0000015300000152
  .quad 0x0000015500000154
  .quad 0x0000015700000156

coefb43:
  .quad 0x0000015900000158
  .quad 0x0000015b0000015a
  .quad 0x0000015d0000015c
  .quad 0x0000015f0000015e

coefb44:
  .quad 0x0000016100000160
  .quad 0x0000016300000162
  .quad 0x0000016500000164
  .quad 0x0000016700000166

coefb45:
  .quad 0x0000016900000168
  .quad 0x0000016b0000016a
  .quad 0x0000016d0000016c
  .quad 0x0000016f0000016e

coefb46:
  .quad 0x0000017100000170
  .quad 0x0000017300000172
  .quad 0x0000017500000174
  .quad 0x0000017700000176

coefb47:
  .quad 0x0000017900000178
  .quad 0x0000017b0000017a
  .quad 0x0000017d0000017c
  .quad 0x0000017f0000017e

coefb48:
  .quad 0x0000018100000180
  .quad 0x0000018300000182
  .quad 0x0000018500000184
  .quad 0x0000018700000186

coefb49:
  .quad 0x0000018900000188
  .quad 0x0000018b0000018a
  .quad 0x0000018d0000018c
  .quad 0x0000018f0000018e

coefb50:
  .quad 0x0000019100000190
  .quad 0x0000019300000192
  .quad 0x0000019500000194
  .quad 0x0000019700000196

coefb51:
  .quad 0x0000019900000198
  .quad 0x0000019b0000019a
  .quad 0x0000019d0000019c
  .quad 0x0000019f0000019e

coefb52:
  .quad 0x000001a1000001a0
  .quad 0x000001a3000001a2
  .quad 0x000001a5000001a4
  .quad 0x000001a7000001a6

coefb53:
  .quad 0x000001a9000001a8
  .quad 0x000001ab000001aa
  .quad 0x000001ad000001ac
  .quad 0x000001af000001ae

coefb54:
  .quad 0x000001b1000001b0
  .quad 0x000001b3000001b2
  .quad 0x000001b5000001b4
  .quad 0x000001b7000001b6

coefb55:
  .quad 0x000001b9000001b8
  .quad 0x000001bb000001ba
  .quad 0x000001bd000001bc
  .quad 0x000001bf000001be

coefb56:
  .quad 0x000001c1000001c0
  .quad 0x000001c3000001c2
  .quad 0x000001c5000001c4
  .quad 0x000001c7000001c6

coefb57:
  .quad 0x000001c9000001c8
  .quad 0x000001cb000001ca
  .quad 0x000001cd000001cc
  .quad 0x000001cf000001ce

coefb58:
  .quad 0x000001d1000001d0
  .quad 0x000001d3000001d2
  .quad 0x000001d5000001d4
  .quad 0x000001d7000001d6

coefb59:
  .quad 0x000001d9000001d8
  .quad 0x000001db000001da
  .quad 0x000001dd000001dc
  .quad 0x000001df000001de

coefb60:
  .quad 0x000001e1000001e0
  .quad 0x000001e3000001e2
  .quad 0x000001e5000001e4
  .quad 0x000001e7000001e6

coefb61:
  .quad 0x000001e9000001e8
  .quad 0x000001eb000001ea
  .quad 0x000001ed000001ec
  .quad 0x000001ef000001ee

coefb62:
  .quad 0x000001f1000001f0
  .quad 0x000001f3000001f2
  .quad 0x000001f5000001f4
  .quad 0x000001f7000001f6

coefb63:
  .quad 0x000001f9000001f8
  .quad 0x000001fb000001fa
  .quad 0x000001fd000001fc
  .quad 0x000001ff000001fe
