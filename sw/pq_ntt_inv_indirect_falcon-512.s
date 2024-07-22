/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* INTT Implementation of Falcon-512 */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load operands into WDRs */
li x2, 0
li x3, 32
li x14, 64
li x15, 128

/* Load DMEM(0) into WDR w0*/
bn.lid x2, 0(x0)

/* Load prime into PQSR*/
pq.pqsrw 0, w0


/* Load DMEM(1152) into WDR w0*/
bn.lid x2, 2240(x0)

/* Load n^-1 into PQSR*/
pq.pqsrw 7, w0


/* Load DMEM(32) into WDR w0*/
bn.lid x2, 0(x3)

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w0


/* Load DMEM(64) into WDR w0*/
bn.lid x2, 0(x14++)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load DMEM(96) into WDR w0*/
bn.lid x2, 0(x15++)

/* Load psi into PQSR*/
pq.pqsrw 4, w0

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

li x10, 0
li x20, 0

/* Top Part */
li x21, 0
loopi 32, 2
  bn.lid x21++, 192(x20)
  addi x20, x20, 32

loopi 8, 11
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  loop x3, 5
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
    loop x2, 1
      pq.gsbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
  /* Update psi, omega, m and j2 */
  pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
  srli x3, x3, 1
  slli x2, x2, 1
  pq.srw 2, x4

li x11, 0

/* store result from [w1] to dmem */
loopi 32, 2
  bn.sid x11++, 192(x10)
  addi x10, x10, 32




/* Bottom Part */
li x2, 0

/* Load DMEM(64) into WDR w0*/
bn.lid x2, 0(x14++)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load DMEM(96) into WDR w0*/
bn.lid x2, 0(x15++)

/* Load psi into PQSR*/
pq.pqsrw 4, w0


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



li x21, 0
loopi 32, 2
  bn.lid x21++, 192(x20)
  addi x20, x20, 32

loopi 8, 12
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
  loop x3, 5
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
    loop x2, 1
      pq.gsbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
  /* Update psi, omega, m and j2 */
  pq.pqsru 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 
  srli x3, x3, 1
  slli x2, x2, 1
  pq.srw 2, x4

li x11, 0

/* store result from [w1] to dmem */
loopi 32, 2
  bn.sid x11++, 192(x10)
  addi x10, x10, 32


/* Merge */

li x20, 0
li x21, 0

li x7, 16
li x6, 1024

li x9, 1024
li x10, 0

/* m = n >> 1 */
li x2, 128
pq.srw 0, x2

/* j2 = 1 */
li x3, 1
pq.srw 1, x3

/* j = 0 */
li x4, 0
pq.srw 2, x4

/* Set psi as twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 


loopi 2, 20

  /* Load DMEM(0) into WDR w0*/
  loopi 16, 4
    bn.lid x21++, 192(x20)
    bn.lid x7++, 192(x6)
    addi x20, x20, 32
    addi x6, x6, 32

  /* Set idx0/idx1 */
  pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  

  loop x2, 1
    pq.gsbf.ind 0, 0, 0, 0, 1

  li x8, 16
  li x11, 0

pq.srw 3, x11
loopi 256, 1
  pq.scale.ind 0, 0, 0, 0, 1

  loopi 16, 4
    bn.sid x11++, 192(x10)
    bn.sid x8++, 192(x9)
    addi x10, x10, 32
    addi x9, x9, 32

  li x21, 0
  li x7, 16

ecall


.section .data

/* 256-bit integer

   0000000000000000 0000000000000000
   0000000000000000 0000000000000D01

['0x539', '0x452', '0x685', '0x2d49', '0x3cb', '0x8f1', '0x900', '0x100', '0x2056']
Psi:
['0x452', '0x685', '0x2d49', '0x3cb', '0x8f1', '0x900', '0x100', '0x2056', '0x2292']

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

omega0:
  .quad 0x0000000000001e43
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

omega1:
  .quad 0x0000000000001e43
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

psi0:
  .quad 0x0000000000000b86
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

psi1:
  .quad 0x0000000000000b86
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

coef0:
  .quad 0x0000207100000d96
  .quad 0x000024b20000244e
  .quad 0x0000176100001a06
  .quad 0x000015b800000c3c

coef1:
  .quad 0x00000e3c000021d1
  .quad 0x00002b360000211f
  .quad 0x0000289b00000166
  .quad 0x00002ecc00002664

coef2:
  .quad 0x0000016d00001a43
  .quad 0x000020340000183e
  .quad 0x0000225f0000239c
  .quad 0x0000197500000792

coef3:
  .quad 0x0000218e00000da3
  .quad 0x00000bbb000011dd
  .quad 0x000017f1000022d8
  .quad 0x00000f3a0000046b

coef4:
  .quad 0x000011e700001788
  .quad 0x00000b78000004c6
  .quad 0x00002fea00002084
  .quad 0x00000cde000010a4

coef5:
  .quad 0x0000181d000018b4
  .quad 0x00002c2f000004ed
  .quad 0x0000153c000007c1
  .quad 0x00000fd400002965

coef6:
  .quad 0x0000215000001a89
  .quad 0x000023e100002920
  .quad 0x00001bf800001ded
  .quad 0x0000290800002dae

coef7:
  .quad 0x000014fa00002104
  .quad 0x00002f4e00001266
  .quad 0x00002ad70000136a
  .quad 0x00001396000018fe

coef8:
  .quad 0x000015ae00001458
  .quad 0x00000c36000011c5
  .quad 0x00001bd800002ad5
  .quad 0x0000104b00001cf4

coef9:
  .quad 0x0000226600001aec
  .quad 0x000029b000002f9d
  .quad 0x00002c550000229c
  .quad 0x000007d300002a28

coef10:
  .quad 0x00002ec400001e82
  .quad 0x00002ba2000021f9
  .quad 0x0000246b00001211
  .quad 0x0000121c000009b3

coef11:
  .quad 0x000023250000083f
  .quad 0x0000039a00000e5a
  .quad 0x00000ac800001b35
  .quad 0x0000119a00002b82

coef12:
  .quad 0x00002458000008fe
  .quad 0x000016eb00000f28
  .quad 0x00001a1200000c5e
  .quad 0x0000159200001a4f

coef13:
  .quad 0x000022ed000013fe
  .quad 0x00002bf200001cad
  .quad 0x000012050000284f
  .quad 0x00002c1e000020b5

coef14:
  .quad 0x00001e5000001f93
  .quad 0x000012a4000015cf
  .quad 0x000006a2000026fe
  .quad 0x00002fe5000019ea

coef15:
  .quad 0x0000071400002103
  .quad 0x0000026d00000d7b
  .quad 0x0000218f000011e8
  .quad 0x0000043b00000533

coef16:
  .quad 0x0000055d0000167f
  .quad 0x00001f3e000002da
  .quad 0x00002a3500000b7e
  .quad 0x000003b900001548

coef17:
  .quad 0x000004e8000029b7
  .quad 0x000001ec00001b86
  .quad 0x00001715000018ac
  .quad 0x00002df4000025b6

coef18:
  .quad 0x00001dbb00001b71
  .quad 0x00000ea700000b49
  .quad 0x000018f70000181c
  .quad 0x00001f0500002973

coef19:
  .quad 0x00002b4700001d8b
  .quad 0x000029c2000011ec
  .quad 0x00000bd900000f19
  .quad 0x000010e2000019b0

coef20:
  .quad 0x000009f500000833
  .quad 0x0000077000000fc9
  .quad 0x00001b6400002917
  .quad 0x00001e34000027d4

coef21:
  .quad 0x00002a2800002663
  .quad 0x0000262b000012d0
  .quad 0x00001c880000024e
  .quad 0x0000159100001f5f

coef22:
  .quad 0x0000065400002348
  .quad 0x000010cf00001005
  .quad 0x00001dc40000157b
  .quad 0x000029f000000000

coef23:
  .quad 0x00000d66000021c2
  .quad 0x00001fe600001fb6
  .quad 0x0000005f0000130d
  .quad 0x00001f1c000014b8

coef24:
  .quad 0x000011e8000013c7
  .quad 0x0000209c0000250f
  .quad 0x00000b7b000006c6
  .quad 0x0000271d00001b2e

coef25:
  .quad 0x00000a0200000d3f
  .quad 0x0000116b000015e9
  .quad 0x0000260f000007cd
  .quad 0x0000296c00001543

coef26:
  .quad 0x000020b000002212
  .quad 0x00000721000017fb
  .quad 0x000015550000006c
  .quad 0x0000031c000009d8

coef27:
  .quad 0x00002c99000022de
  .quad 0x000015a500002504
  .quad 0x00002a5700002e5a
  .quad 0x000006d20000165c

coef28:
  .quad 0x00001eac00000d10
  .quad 0x000010ff0000223a
  .quad 0x00002de500000fe4
  .quad 0x00001fa70000169f

coef29:
  .quad 0x00001f1400001f03
  .quad 0x000027de00002f5e
  .quad 0x000004e5000018af
  .quad 0x0000007500001c3e

coef30:
  .quad 0x0000135d00002026
  .quad 0x0000024700001676
  .quad 0x000013e400000c37
  .quad 0x00001921000008e0

coef31:
  .quad 0x000008ad00001ae6
  .quad 0x0000004200001100
  .quad 0x000020e3000007b5
  .quad 0x000029eb00000bf2

coef32:
  .quad 0x00001f8900000340
  .quad 0x00001a6e00002cbd
  .quad 0x0000290b000018a2
  .quad 0x0000132f00002403

coef33:
  .quad 0x0000110000000140
  .quad 0x000025e3000023a6
  .quad 0x000029cd00000cc3
  .quad 0x0000109500001c46

coef34:
  .quad 0x0000126e00002e38
  .quad 0x00002b6d0000106f
  .quad 0x000014400000088c
  .quad 0x0000019d00000680

coef35:
  .quad 0x000024f900000d03
  .quad 0x00000c2c000019dc
  .quad 0x00000c17000015ce
  .quad 0x0000240100002703

coef36:
  .quad 0x00002899000002a1
  .quad 0x00002c4700001cd7
  .quad 0x0000015700001b91
  .quad 0x0000289300000834

coef37:
  .quad 0x00000c7d00002d89
  .quad 0x000008d0000018f0
  .quad 0x0000230600001c1b
  .quad 0x00002636000018c7

coef38:
  .quad 0x00000f2b00002942
  .quad 0x000017ff00002706
  .quad 0x000029f5000019b3
  .quad 0x000004d70000230d

coef39:
  .quad 0x0000004c000017a2
  .quad 0x000018ca00002564
  .quad 0x00001a6300002a49
  .quad 0x00001b4700000c0a

coef40:
  .quad 0x00002f1b000011f7
  .quad 0x0000063c00000205
  .quad 0x000008dd00002c76
  .quad 0x0000046a00001d02

coef41:
  .quad 0x00000deb000018a8
  .quad 0x0000058200000392
  .quad 0x00002f9300002723
  .quad 0x00002d9600000d73

coef42:
  .quad 0x000004e800002ee5
  .quad 0x0000134000000714
  .quad 0x000019310000012b
  .quad 0x000000f6000028c3

coef43:
  .quad 0x000015f200001a2f
  .quad 0x00001f6e00001c3d
  .quad 0x00000d9d00000f44
  .quad 0x000020d90000270f

coef44:
  .quad 0x0000263300001654
  .quad 0x0000278100002974
  .quad 0x00000aa800001baf
  .quad 0x000027ac000025c9

coef45:
  .quad 0x000003cc00001bdb
  .quad 0x0000145900000c96
  .quad 0x00002d4800001dec
  .quad 0x0000247d00001365

coef46:
  .quad 0x000021d80000020e
  .quad 0x000006000000254a
  .quad 0x00002c0f00000e55
  .quad 0x00002cd200002a5d

coef47:
  .quad 0x0000056f000029f6
  .quad 0x00002f0100001ae8
  .quad 0x00001f9800001bb7
  .quad 0x00001072000022e3

coef48:
  .quad 0x00000d0900001b92
  .quad 0x000027b100002043
  .quad 0x0000190300002f01
  .quad 0x000001900000018b

coef49:
  .quad 0x000003d000001260
  .quad 0x0000046a000010c7
  .quad 0x00002f5600000c4a
  .quad 0x00002fd700001d21

coef50:
  .quad 0x0000025e00002dcf
  .quad 0x0000168000001cac
  .quad 0x00000f9700000098
  .quad 0x00000f1800001702

coef51:
  .quad 0x00001047000022ee
  .quad 0x0000225a00002872
  .quad 0x000003f1000028e3
  .quad 0x00001e1600000aca

coef52:
  .quad 0x000005d6000012f8
  .quad 0x0000113f0000086c
  .quad 0x00001c2f0000181e
  .quad 0x00002ab300002a08

coef53:
  .quad 0x00000db000001c84
  .quad 0x000027e300001380
  .quad 0x00001da100002f8c
  .quad 0x00000faa00001164

coef54:
  .quad 0x00000b7700002e02
  .quad 0x0000001900000b0d
  .quad 0x0000145d0000048c
  .quad 0x0000119d00002d02

coef55:
  .quad 0x00001ea7000029b6
  .quad 0x000014e600001f0c
  .quad 0x00000cb5000006ae
  .quad 0x000007cb00000c30

coef56:
  .quad 0x00000f2b00000205
  .quad 0x00001cf6000024d1
  .quad 0x00001de700000323
  .quad 0x00001a9500002905

coef57:
  .quad 0x0000205300001c2e
  .quad 0x0000156800000740
  .quad 0x0000260800000502
  .quad 0x0000090b00000889

coef58:
  .quad 0x00002d5b000008b2
  .quad 0x0000295e00002405
  .quad 0x000014b300001e32
  .quad 0x0000094c000019e6

coef59:
  .quad 0x0000149e00000063
  .quad 0x0000123c000001d6
  .quad 0x0000071700000ca1
  .quad 0x00002d0200002a58

coef60:
  .quad 0x000015ff00000d5d
  .quad 0x000029d400002ea3
  .quad 0x0000154700001265
  .quad 0x000020be00000c9d

coef61:
  .quad 0x00001e6f00000ef2
  .quad 0x0000209200000e0d
  .quad 0x0000065100002738
  .quad 0x00000e5e000004a7

coef62:
  .quad 0x0000106500001e48
  .quad 0x0000201800000c1c
  .quad 0x0000195800001d13
  .quad 0x00002c53000003cd

coef63:
  .quad 0x0000263d000022a1
  .quad 0x00001f54000004c3
  .quad 0x00002552000025ae
  .quad 0x00000fcd0000263a

n1:
  .quad 0x0000000000001d56
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

