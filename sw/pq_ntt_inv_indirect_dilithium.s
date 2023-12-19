/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
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
/*                       NTT                     */
/*************************************************/

/* m = l */
li x2, 1
pq.srw 0, x2

/* j2 = n >> 1 */
li x3, 128
pq.srw 1, x3

/* j = 0 */
li x4, 0
pq.srw 2, x4

/* mode = 1 */
li x5, 1
pq.srw 5, x5

loopi 8, 10
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
