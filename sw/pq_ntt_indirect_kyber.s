/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* NTT Implementation of Kyber */

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
/*                       NTT                     */
/*************************************************/

/* m = n >> 1 */
li x2, 128
pq.srw 0, x2

/* j2 = 1 */
li x3, 1
pq.srw 1, x3

/* j = 0 */
li x4, 0
pq.srw 2, x4


loopi 7, 10
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  loop x3, 4
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0   
    loop x2, 1
      pq.ctbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
  /* Update idx_psi, idx_omega, m and j2 */
  pq.pqsru 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0 
  slli x3, x3, 1
  srli x2, x2, 1
  pq.srw 2, x4

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
