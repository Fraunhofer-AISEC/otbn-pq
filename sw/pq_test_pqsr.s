/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Test programm to verify write and read functionality of PQSR and PQCTRLSR */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load operands into WDRs */
li x2, 0
li x3, 32
li x4, 64
li x5, 96


/*************************************************/
/*                   PRIME TEST                  */
/*************************************************/

/* Load DMEM(0) into WDR w0*/
bn.lid x2, 0(x0)

/* Load prime into PQSR*/
pq.pqsrw 0, w0

/* Read prime PQSR*/
pq.pqsrr w1, 0

/* Subtract w1 from w0 */
bn.sub w2, w1, w0

/* Load new prime into PQSR*/
pq.pqsrw 0, w2

/* Read prime PQCTRLSR*/
pq.srr x9, 16

/* Add 14 to x9 (=14)*/
li x24, 14
add x9, x9, x24

/* Load new prime into PQSR*/
pq.srw 16, x9

/* Read prime PQSR*/
pq.pqsrr w0, 0

/* Store new prime in MEM */
li x4, 0
bn.sid x4, 544(x0)


/*************************************************/
/*                   OMEGA TEST                  */
/*************************************************/
/* Load DMEM(64) into WDR w0*/
li x4, 64
bn.lid x2, 0(x4)

/* Load omega into PQSR*/
pq.pqsrw 3, w0

/* Read omega PQSR*/
pq.pqsrr w1, 3

/* Subtract w1 from w0 */
bn.sub w2, w1, w0

/* Load new prime into PQSR*/
pq.pqsrw 3, w2


/* Read omega PQCTRLSR*/
pq.srr x9, 64

/* Add 96 to x9 (=96)*/
li x24, 96
add x9, x9, x24

/* Load new omega into PQSR*/
pq.srw 64, x9


/* Read omega PQCTRLSR*/
pq.srr x9, 65

/* Add 97 to x9 (=7)*/
li x24, 97
add x9, x9, x24

/* Load new omega into PQSR*/
pq.srw 65, x9


/* Read omega PQCTRLSR*/
pq.srr x9, 66

/* Add 7 to x9 (=98)*/
li x24, 98
add x9, x9, x24

/* Load new omega into PQSR*/
pq.srw 66, x9


/* Read omega PQCTRLSR*/
pq.srr x9, 67

/* Add 7 to x9 (=99)*/
li x24, 99
add x9, x9, x24

/* Load new omega into PQSR*/
pq.srw 67, x9


/* Read omega PQCTRLSR*/
pq.srr x9, 68

/* Add 7 to x9 (=100)*/
li x24, 100
add x9, x9, x24

/* Load new omega into PQSR*/
pq.srw 68, x9


/* Read omega PQCTRLSR*/
pq.srr x9, 69

/* Add 7 to x9 (=101)*/
addi x9, x9, 101

/* Load new omega into PQSR*/
pq.srw 69, x9


/* Read omega PQCTRLSR*/
pq.srr x9, 70

/* Add 7 to x9 (=102)*/
li x24, 102
add x9, x9, x24

/* Load new omega into PQSR*/
pq.srw 70, x9


/* Read omega PQCTRLSR*/
pq.srr x9, 71

/* Add 7 to x9 (=103)*/
li x24, 103
add x9, x9, x24

/* Load new omega into PQSR*/
pq.srw 71, x9


/* Read omega PQSR*/
pq.pqsrr w0, 3

/* Store new omega in MEM */
li x4, 0
bn.sid x4, 576(x0)


/*************************************************/
/*                 PQCTRLSR TEST                 */
/*************************************************/
li x4, 0

/* m = l */
li x2, 1
pq.srw 0, x2

/* read and store m */
pq.srr x9, 0
sw x9, 608(x4)


/* j2 = n >> 1 */
li x3, 128
pq.srw 1, x3

/* read and store j2 */
pq.srr x9, 1
sw x9, 612(x4)


/* j = 0 */
li x4, 0
pq.srw 2, x4

/* read and store j */
pq.srr x9, 2
sw x9, 616(x4)


/* mode = 1 */
li x5, 1
pq.srw 5, x5

/* read and store mode */
pq.srr x9, 5
sw x9, 620(x4)


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
