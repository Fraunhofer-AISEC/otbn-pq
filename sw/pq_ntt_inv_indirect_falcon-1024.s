/* Copyright lowRISC contributors. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* INTT Implementation of Falcon-1024 */

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
bn.lid x2, 4288(x0)

/* Load n^-1 into PQSR*/
pq.pqsrw 7, w0


/* Load DMEM(32) into WDR w0*/
bn.lid x2, 0(x3)

/* Load prime_dash into PQSR*/
pq.pqsrw 1, w0


/* Load DMEM(64) into WDR w0*/
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load DMEM(96) into WDR w0*/
bn.lid x2, 0(x15)

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

loopi 8, 13
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  loop x3, 7
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
    loop x2, 1
      pq.gsbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
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


/* Top Bottom Part */
li x2, 0

/* Load DMEM(64) into WDR w0*/
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load DMEM(96) into WDR w0*/
bn.lid x2, 0(x15)

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


li x21, 0

loopi 32, 2
  bn.lid x21++, 192(x20)
  addi x20, x20, 32

loopi 8, 15
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
  pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
  loop x3, 7
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
    loop x2, 1
      pq.gsbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
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



/* Bottom Top Part */

li x2, 0

/* Load DMEM(64) into WDR w0*/
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load DMEM(96) into WDR w0*/
bn.lid x2, 0(x15)

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


li x21, 0
loopi 32, 2
  bn.lid x21++, 192(x20)
  addi x20, x20, 32

loopi 8, 14
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
  loop x3, 7
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
    loop x2, 1
      pq.gsbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0  
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
bn.lid x2, 0(x14)

/* Load omega into PQSR*/
pq.pqsrw 3, w0


/* Load DMEM(96) into WDR w0*/
bn.lid x2, 0(x15)

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

li x21, 0
loopi 32, 2
  bn.lid x21++, 192(x20)
  addi x20, x20, 32

loopi 8, 16
  /* Set psi as twiddle */
  pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 
  pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
  pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
  pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
  loop x3, 7
    /* Set idx0/idx1 */
    pq.pqsru 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0  
    loop x2, 1
      pq.gsbf.ind 0, 0, 0, 0, 1
    /* Update twiddle and increment j */
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 
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


/* Merge - NTT Layer 512 */

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

loopi 2, 23
  loopi 2, 17

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

    loopi 16, 4
      bn.sid x11++, 192(x10)
      bn.sid x8++, 192(x9)
      addi x10, x10, 32
      addi x9, x9, 32

    li x21, 0
    li x7, 16

  pq.pqsru 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0 

  addi x10, x10, 1024
  addi x20, x20, 1024

  addi x9, x9, 1024
  addi x6, x6, 1024


/* Update psi, omega, m and j2 */
pq.pqsru 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 

/* Merge - NTT Layer 1024 */

/* m = n >> 1 */
li x2, 128
pq.srw 0, x2

/* j2 = 1 */
li x3, 1
pq.srw 1, x3

/* j = 0 */
li x4, 0
pq.srw 2, x4

li x20, 0
li x21, 0

li x7, 16
li x6, 2048

li x9, 2048
li x10, 0

/* Set psi as twiddle */
pq.pqsru 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 

loopi 4, 20

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
  .quad 0x000003c900000037
  .quad 0x000017e50000161c
  .quad 0x000000d000001d97
  .quad 0x000024d400002e61

coef1:
  .quad 0x000015490000155d
  .quad 0x00002c48000011aa
  .quad 0x0000238d00000707
  .quad 0x000009230000098f

coef2:
  .quad 0x00002901000024c7
  .quad 0x00002eb1000021a8
  .quad 0x0000033d00001a90
  .quad 0x000007c200001245

coef3:
  .quad 0x000008aa00000fea
  .quad 0x0000004d00002f82
  .quad 0x000005fc00001170
  .quad 0x0000062a00000b26

coef4:
  .quad 0x000023040000025b
  .quad 0x0000148900000fd0
  .quad 0x000004b200001725
  .quad 0x00001d9300001765

coef5:
  .quad 0x0000084600002af3
  .quad 0x00001c8c00001dc5
  .quad 0x00000e610000155c
  .quad 0x00000ffa00000da7

coef6:
  .quad 0x0000077800001069
  .quad 0x0000211900002db0
  .quad 0x0000148b00001a40
  .quad 0x00002a0d00001316

coef7:
  .quad 0x0000229d00002443
  .quad 0x00000c49000016cb
  .quad 0x0000118500002369
  .quad 0x000005b000001ecd

coef8:
  .quad 0x0000019900001cc9
  .quad 0x0000087400001595
  .quad 0x0000165a0000218e
  .quad 0x0000271000000ed8

coef9:
  .quad 0x00000af200001ca7
  .quad 0x00000b15000017ed
  .quad 0x0000124d0000104e
  .quad 0x000005a400002813

coef10:
  .quad 0x00000ec900000222
  .quad 0x00001f6500000333
  .quad 0x0000113c000011d7
  .quad 0x000012530000077f

coef11:
  .quad 0x00002f4a00001e7c
  .quad 0x0000086c000004df
  .quad 0x000021ec00002f94
  .quad 0x00000bff000015f8

coef12:
  .quad 0x000010a7000014f2
  .quad 0x000027ef00002bd8
  .quad 0x00000bd500002b0e
  .quad 0x000025a90000001a

coef13:
  .quad 0x0000006500002657
  .quad 0x0000230900000faa
  .quad 0x000020ec00001e74
  .quad 0x00000ae500002dd1

coef14:
  .quad 0x000024d500000df1
  .quad 0x0000295f00002b68
  .quad 0x00001afd0000007f
  .quad 0x0000030000002a40

coef15:
  .quad 0x00001fcf00002d0e
  .quad 0x00001adf0000037c
  .quad 0x00000e2800002e49
  .quad 0x000015c400002ec9

coef16:
  .quad 0x00002997000010f1
  .quad 0x00001fbe00001244
  .quad 0x00000da800001691
  .quad 0x00000195000000a0

coef17:
  .quad 0x0000063f000018e7
  .quad 0x0000180a00000a41
  .quad 0x00000091000008cd
  .quad 0x00002c42000003a3

coef18:
  .quad 0x00000b78000004a0
  .quad 0x00002c730000061b
  .quad 0x00001f8200002143
  .quad 0x00002704000026fa

coef19:
  .quad 0x0000155b00002ae3
  .quad 0x0000186600000579
  .quad 0x00002be900002f70
  .quad 0x00000e2b00000f00

coef20:
  .quad 0x0000006f00000b78
  .quad 0x00001e7c000003b4
  .quad 0x000009f20000291a
  .quad 0x00000214000002af

coef21:
  .quad 0x00002ab90000201e
  .quad 0x00001a7700000221
  .quad 0x0000015000002ee3
  .quad 0x00001887000024a5

coef22:
  .quad 0x000022b400000fbc
  .quad 0x00000d3700002cf9
  .quad 0x0000112100000c84
  .quad 0x000018fa00000591

coef23:
  .quad 0x00001483000020f7
  .quad 0x0000141400002b30
  .quad 0x000018d30000112d
  .quad 0x00002fef0000216d

coef24:
  .quad 0x0000169f00002f31
  .quad 0x000027a000000843
  .quad 0x0000151e000023b8
  .quad 0x000006150000199d

coef25:
  .quad 0x0000141c00000879
  .quad 0x0000196400002d86
  .quad 0x00000f4100001bc1
  .quad 0x0000040e00002dac

coef26:
  .quad 0x00002a900000173d
  .quad 0x0000079a0000247c
  .quad 0x00002d0a0000220b
  .quad 0x00000b5800001f5e

coef27:
  .quad 0x00002308000024a8
  .quad 0x00000b44000014a1
  .quad 0x00001ae400002446
  .quad 0x000005a40000049b

coef28:
  .quad 0x00000ef800001346
  .quad 0x0000134500002b60
  .quad 0x0000223000001b2e
  .quad 0x000002cf0000265c

coef29:
  .quad 0x000017fc00002623
  .quad 0x0000034400000350
  .quad 0x000022ee00002dd9
  .quad 0x00001af500000701

coef30:
  .quad 0x00002e9600001b4d
  .quad 0x0000062300001774
  .quad 0x0000262e00001e64
  .quad 0x00000bb90000019c

coef31:
  .quad 0x0000024300000de6
  .quad 0x00001cd800000fb4
  .quad 0x00002dc0000018c5
  .quad 0x00001370000026b0

coef32:
  .quad 0x0000002600000223
  .quad 0x000028c500001909
  .quad 0x0000003e00002ce6
  .quad 0x000009150000263d

coef33:
  .quad 0x000009d400000522
  .quad 0x000022a600001abe
  .quad 0x0000298b00002d60
  .quad 0x000025c1000015f5

coef34:
  .quad 0x0000121000000c75
  .quad 0x00002516000002ce
  .quad 0x00000bc800002f5c
  .quad 0x00002cca00001e8b

coef35:
  .quad 0x00002c5500000339
  .quad 0x000006cb00000068
  .quad 0x00001f5500002b85
  .quad 0x00000eaf00001cd5

coef36:
  .quad 0x0000259600002ec0
  .quad 0x000024420000273e
  .quad 0x000005fd00002a81
  .quad 0x0000223b00000056

coef37:
  .quad 0x000008ab00002236
  .quad 0x0000240900002d2e
  .quad 0x000029bf00000383
  .quad 0x0000211c00002621

coef38:
  .quad 0x000023040000030e
  .quad 0x0000133400000e7b
  .quad 0x00002af200000540
  .quad 0x000026eb00002f42

coef39:
  .quad 0x000009cd00000729
  .quad 0x000006b800001e4e
  .quad 0x000012c20000093a
  .quad 0x00000f9500002605

coef40:
  .quad 0x000026da000021da
  .quad 0x00000ce3000005d1
  .quad 0x00000c2d00001399
  .quad 0x000015ae00000d67

coef41:
  .quad 0x00002461000006db
  .quad 0x0000062d000000da
  .quad 0x00000933000021b0
  .quad 0x0000263700000304

coef42:
  .quad 0x0000149c00002782
  .quad 0x0000298400000312
  .quad 0x00000d5c00000205
  .quad 0x00002a6200001005

coef43:
  .quad 0x000007f3000015b8
  .quad 0x0000044c00002397
  .quad 0x00001c720000108f
  .quad 0x00000b410000095e

coef44:
  .quad 0x00000e37000028f5
  .quad 0x000027cc00002b31
  .quad 0x000025de000005fb
  .quad 0x0000086700002d55

coef45:
  .quad 0x0000217a00002366
  .quad 0x0000051b0000244e
  .quad 0x00002bc200000994
  .quad 0x000006a700000a3a

coef46:
  .quad 0x000019a400001f2b
  .quad 0x000010ff000014bd
  .quad 0x00002e27000015ca
  .quad 0x00002eb0000012c5

coef47:
  .quad 0x00002c63000018a3
  .quad 0x00002c2b000020ca
  .quad 0x00000b9c000016b9
  .quad 0x00000e8c000029fa

coef48:
  .quad 0x00002a6f00002ce4
  .quad 0x000015de000003c5
  .quad 0x000016f200000c2d
  .quad 0x00000cc000001c53

coef49:
  .quad 0x000019f60000026b
  .quad 0x0000272800000685
  .quad 0x00001fa300002ba6
  .quad 0x000020e000001771

coef50:
  .quad 0x00002ac1000019f0
  .quad 0x000029540000192e
  .quad 0x000020de00001056
  .quad 0x00000d2800001788

coef51:
  .quad 0x00001fd900002752
  .quad 0x000017d30000027a
  .quad 0x000010ea00000508
  .quad 0x000005cb0000112a

coef52:
  .quad 0x0000036100002062
  .quad 0x000003c500001fb1
  .quad 0x0000292100002ef6
  .quad 0x00001c9900001606

coef53:
  .quad 0x00000df300000b9c
  .quad 0x000018d400000bdf
  .quad 0x000017ec00002b00
  .quad 0x00001b0e00001934

coef54:
  .quad 0x0000255d00001f7d
  .quad 0x00000f590000248c
  .quad 0x00001c6100000cf6
  .quad 0x000025ee00001174

coef55:
  .quad 0x000012a2000012c3
  .quad 0x000013cf000019b3
  .quad 0x000005d900000ba6
  .quad 0x0000118200002781

coef56:
  .quad 0x00002b1f000025d2
  .quad 0x000020f400001cba
  .quad 0x00000b3500001621
  .quad 0x0000165600001f3e

coef57:
  .quad 0x00000ea5000024fb
  .quad 0x000020ff0000135c
  .quad 0x00002e1b00002900
  .quad 0x0000277600002983

coef58:
  .quad 0x000004fd00001e02
  .quad 0x00002bdd0000109f
  .quad 0x00001dcb000000fb
  .quad 0x00000bd300001b18

coef59:
  .quad 0x00000923000009d3
  .quad 0x00000b2300001c91
  .quad 0x000005c9000014e2
  .quad 0x00001cad00002296

coef60:
  .quad 0x00000c770000275b
  .quad 0x00001ea30000100e
  .quad 0x0000286700002971
  .quad 0x000013150000001a

coef61:
  .quad 0x00002d0400000ebb
  .quad 0x00000a3f00002118
  .quad 0x00001ef700002738
  .quad 0x0000029400001ce8

coef62:
  .quad 0x00002e7300000631
  .quad 0x000002d40000269a
  .quad 0x00000eef000012f6
  .quad 0x00000c780000100d

coef63:
  .quad 0x00002087000014ef
  .quad 0x000007c600001091
  .quad 0x0000011200001c55
  .quad 0x0000092a000007da

coef64:
  .quad 0x000024a8000011d6
  .quad 0x00001d01000003e5
  .quad 0x00001d8f00000a3b
  .quad 0x000007bd00001e3c

coef65:
  .quad 0x00001bd200000935
  .quad 0x00001c9200002462
  .quad 0x000011d1000026d9
  .quad 0x000016c3000019d3

coef66:
  .quad 0x0000299700000fbb
  .quad 0x000012e900001501
  .quad 0x0000251600002f89
  .quad 0x00000df300002137

coef67:
  .quad 0x0000070200000dfb
  .quad 0x00000cf500001717
  .quad 0x00001710000007b3
  .quad 0x00000b330000185f

coef68:
  .quad 0x0000137600001477
  .quad 0x000016cc0000010b
  .quad 0x00001c9c00002776
  .quad 0x00000c0e00001e62

coef69:
  .quad 0x000018eb00001954
  .quad 0x00000c9c00001160
  .quad 0x00001d5a00002624
  .quad 0x00001f83000003a3

coef70:
  .quad 0x0000136100001ec4
  .quad 0x000006cf00000655
  .quad 0x00002c22000006cf
  .quad 0x00000b3700000b89

coef71:
  .quad 0x00002cd4000002a5
  .quad 0x00002236000017c6
  .quad 0x000005b500001e2b
  .quad 0x00002d9000001a53

coef72:
  .quad 0x0000217a00002623
  .quad 0x000016b400000175
  .quad 0x000002ea00001556
  .quad 0x00000681000017cd

coef73:
  .quad 0x00000f06000014a9
  .quad 0x0000143e000019e6
  .quad 0x00001ba300000f39
  .quad 0x000027a30000230a

coef74:
  .quad 0x00001df300001569
  .quad 0x00000f7e00002b4b
  .quad 0x000017da000014a3
  .quad 0x00000c0c00001088

coef75:
  .quad 0x0000052200001386
  .quad 0x00002e5000000e34
  .quad 0x00001d27000020cd
  .quad 0x00001463000011b4

coef76:
  .quad 0x000000310000196f
  .quad 0x0000004e00001ea9
  .quad 0x000007c000002267
  .quad 0x00000eb100002029

coef77:
  .quad 0x0000215100000400
  .quad 0x000024b1000004eb
  .quad 0x0000062000001a67
  .quad 0x0000298a00001443

coef78:
  .quad 0x00000c8f0000241d
  .quad 0x0000248400002d01
  .quad 0x00001e2400002274
  .quad 0x00001de7000020b3

coef79:
  .quad 0x00000a540000077a
  .quad 0x0000066600001093
  .quad 0x0000220800000932
  .quad 0x000020710000012c

coef80:
  .quad 0x0000227c00000c11
  .quad 0x0000035a000016e0
  .quad 0x00000a070000117d
  .quad 0x000009a3000029b8

coef81:
  .quad 0x00001ee200002369
  .quad 0x00001d8f00000926
  .quad 0x00000040000001e3
  .quad 0x00002ceb00000101

coef82:
  .quad 0x00000b36000019d8
  .quad 0x000015b200002f51
  .quad 0x000023f70000270c
  .quad 0x00001ce000001216

coef83:
  .quad 0x0000282400001047
  .quad 0x000025c300002d8a
  .quad 0x0000272e0000147f
  .quad 0x00002fca000012ce

coef84:
  .quad 0x000002b800001a16
  .quad 0x00000ab4000027ab
  .quad 0x00002e1100000a16
  .quad 0x00000d5500000c59

coef85:
  .quad 0x00001ae500002ae5
  .quad 0x000001ff00002cb0
  .quad 0x00000e4100000e8e
  .quad 0x000027a300002da6

coef86:
  .quad 0x00002f7800001609
  .quad 0x00002d1800002936
  .quad 0x0000017d00002290
  .quad 0x000016d7000003d3

coef87:
  .quad 0x00001de700002d46
  .quad 0x000020e1000003b7
  .quad 0x00002a9400002388
  .quad 0x00000b9200001fbe

coef88:
  .quad 0x00002a0f00000073
  .quad 0x000023dd0000216f
  .quad 0x00002b4500002fc8
  .quad 0x00002fc8000011d3

coef89:
  .quad 0x000013f200000113
  .quad 0x000023dc00000510
  .quad 0x00002eb800000408
  .quad 0x000001a3000014c0

coef90:
  .quad 0x00002a9f00001c8f
  .quad 0x0000115300002b9d
  .quad 0x000011a900000ea6
  .quad 0x00000fac00002b6f

coef91:
  .quad 0x000019fa000013ce
  .quad 0x0000080d00002978
  .quad 0x00001b12000029b8
  .quad 0x00001b4900001e1a

coef92:
  .quad 0x000000cc00001911
  .quad 0x0000292100001c77
  .quad 0x0000066200001c33
  .quad 0x000008a000001703

coef93:
  .quad 0x0000182d00002d30
  .quad 0x0000170700000847
  .quad 0x000003df00001d78
  .quad 0x00000e65000010f3

coef94:
  .quad 0x0000223100000849
  .quad 0x00001abe00000fd0
  .quad 0x00001ae100001631
  .quad 0x00002abe00002505

coef95:
  .quad 0x00000111000024a4
  .quad 0x00000dfe0000149e
  .quad 0x0000190700001f16
  .quad 0x0000127700002543

coef96:
  .quad 0x0000033000000397
  .quad 0x00002aa400002820
  .quad 0x0000137c000006a5
  .quad 0x000002a8000018d2

coef97:
  .quad 0x0000201a00002cf0
  .quad 0x0000233400002d25
  .quad 0x000027540000232b
  .quad 0x00000b1d00001c25

coef98:
  .quad 0x00001fba0000221b
  .quad 0x00001ae100001047
  .quad 0x00002d25000024d6
  .quad 0x000029990000265f

coef99:
  .quad 0x0000093300001c18
  .quad 0x00000ddb000001c0
  .quad 0x000014bb00000c17
  .quad 0x0000185100000d21

coef100:
  .quad 0x00001f0f00002d2d
  .quad 0x000027470000117c
  .quad 0x000004bc0000111c
  .quad 0x000019fb00002558

coef101:
  .quad 0x0000169100000d4b
  .quad 0x0000012b00001e1c
  .quad 0x00000d18000014f4
  .quad 0x000014b8000023f7

coef102:
  .quad 0x000028110000292c
  .quad 0x00001b66000006e8
  .quad 0x0000296f00000781
  .quad 0x000029a1000024a8

coef103:
  .quad 0x0000006500002ac4
  .quad 0x00001ce3000014ab
  .quad 0x0000269f0000171c
  .quad 0x00001680000001a1

coef104:
  .quad 0x0000061a0000178b
  .quad 0x00001a5a00001012
  .quad 0x000017f1000025d0
  .quad 0x0000147100001f43

coef105:
  .quad 0x00001225000005d7
  .quad 0x00002cdf00001290
  .quad 0x000022ba000002f3
  .quad 0x000015050000101e

coef106:
  .quad 0x0000072d00001273
  .quad 0x0000159700002d4f
  .quad 0x00002e7a00000471
  .quad 0x000015a600000daf

coef107:
  .quad 0x00000860000013c9
  .quad 0x000018d60000092f
  .quad 0x0000069100002b76
  .quad 0x0000144f00000ab6

coef108:
  .quad 0x000024df00001658
  .quad 0x000027e000002abf
  .quad 0x000021da00000091
  .quad 0x0000043100002e77

coef109:
  .quad 0x0000009200000703
  .quad 0x00000b4c000021d8
  .quad 0x000007ed00001a5b
  .quad 0x00002e5b00001788

coef110:
  .quad 0x0000157f00001cbb
  .quad 0x00001f11000005a1
  .quad 0x00000aa60000177c
  .quad 0x00001e33000019b7

coef111:
  .quad 0x00001cfc00000bc7
  .quad 0x00002e930000076e
  .quad 0x000027de00002a15
  .quad 0x00000cb900002d88

coef112:
  .quad 0x0000287500000071
  .quad 0x000021f70000010c
  .quad 0x000004f4000020fd
  .quad 0x00001fd000002ea9

coef113:
  .quad 0x0000278b00002bf6
  .quad 0x000013da00001dcc
  .quad 0x000003e200002048
  .quad 0x00001c2100000064

coef114:
  .quad 0x000007210000180e
  .quad 0x00000ace000018ee
  .quad 0x000003fd00002645
  .quad 0x00000d8400001c98

coef115:
  .quad 0x0000129c000016d9
  .quad 0x0000063600001190
  .quad 0x00001f1b00002a21
  .quad 0x00000eef000023c4

coef116:
  .quad 0x00001d07000020f8
  .quad 0x0000071500002ed1
  .quad 0x0000014d00002066
  .quad 0x0000052300000b03

coef117:
  .quad 0x000027eb00001405
  .quad 0x000003fd00000bd5
  .quad 0x00000fb700000453
  .quad 0x00002fbf00002723

coef118:
  .quad 0x00002f16000018a6
  .quad 0x00002af700001e00
  .quad 0x0000007200001e36
  .quad 0x000002a800000a1b

coef119:
  .quad 0x0000121800000bb8
  .quad 0x0000229b000021a0
  .quad 0x00002be00000097d
  .quad 0x000019f100000a3e

coef120:
  .quad 0x00002532000011a8
  .quad 0x00001c900000115a
  .quad 0x00001d8800000c11
  .quad 0x000018880000297e

coef121:
  .quad 0x0000105400001558
  .quad 0x0000093d00001f26
  .quad 0x000003680000096e
  .quad 0x000022fc00000290

coef122:
  .quad 0x0000205f000019e6
  .quad 0x00002b270000291f
  .quad 0x0000203400001290
  .quad 0x000011390000269e

coef123:
  .quad 0x00002ef800000964
  .quad 0x0000221c00000764
  .quad 0x000012e900000b51
  .quad 0x00002fcc00001356

coef124:
  .quad 0x00000ba700001b40
  .quad 0x00002b39000007d6
  .quad 0x00000fe300002345
  .quad 0x000000f200000e87

coef125:
  .quad 0x00001dc30000144a
  .quad 0x000022c200000820
  .quad 0x000018db00000b05
  .quad 0x00000ec100001641

coef126:
  .quad 0x00000216000024c8
  .quad 0x0000235b00002641
  .quad 0x00001c9c00001950
  .quad 0x00001cf300002d64

coef127:
  .quad 0x0000051200002bbe
  .quad 0x00002a0f000003f3
  .quad 0x000012940000272a
  .quad 0x0000127d00000bd4

n1:
  .quad 0x0000000000000eab
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

