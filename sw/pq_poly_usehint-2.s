/* Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* UseHint Implementation */

.section .text

/*************************************************/
/*        Load Constants for Configuration       */
/*************************************************/

/* Load Bitmask into WDR w0*/
li x2, 0
bn.lid x2, 0(x0)

/* Load Bitmask into Prime PQSR*/
pq.pqsrw 0, w0


/* Load hint bits for polynomial in W20 */
li x2, 96
li x3, 20
bn.lid x3, 0(x2)

/* Address of coefficients */
li x4, 128

/* Address of all-zero vector */
li x6, 32

/* Relative address of result coefficient */
li x7, 0

loopi 32, 4
  jal x1, use_hint
  /* Select next pair of coefficients */
  addi x4, x4, 32
  li x3, 10
  bn.sid x3, 2048(x7++)
  

ecall








/*************************************************/
/*                     UseHint                   */
/*
* @param[in]  x6: address of all-zero vector
* @param[in]  x4: address of coefficients
* @param[in]  w20: current hint bits
* @param[out] w10: result of UseHint
*
* clobbered registers: x3: internal register addressing
*                      x14: read out flags
*                      x15: read out flags
*                      w1: store constant 127
*                      w2: store constant 11275
*                      w3: store constant 1<<23
*                      w4: store constant 43
*                      w5: store constant 19464
*                      w6: store constant 4190208
*                      w7: store constant 0x0...0
*                      w8: store constant 0XF...F
*                      w9: store coefficients
*                      w10: sorting of coefficients
*                      w11: intermediate result
*                      w12: intermediate result
*                      w13: intermediate result
*                      w14: intermediate result
*                      w15: intermediate result
*                      w16: intermediate result                       
*
*/
/*************************************************/
use_hint:

/* Initialize WDR 10 with 0x0...0*/
li x3, 10
bn.lid x3++, 0(x6)

/* a1 = decompose(&a0, a) */
jal x1, decompose
/* WDR 15 = a1 , WDR 16 = a0 */

/* if(hint == 0) */

loopi 8, 45

/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.addi w11, w7, 1
bn.and w11, w11, w20
bn.cmp w11, w7, FG0

/* Check Zero Flag */
csrrw x14, 1984, x0
li x3, 8
andi x14, x14, 8

bne x3, x14, hint_not_zero
/* return a1 */
bn.rshi w10, w15, w10 >> 32
beq x0, x0, shift_coefficients

/* else */
hint_not_zero:

/* if(a0 > 0)*/

/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w16


/* Check Allzero Flag */
bn.cmp w7, w11, FG0
csrrw x14, 1984, x0
andi x15, x14, 8
srli x15, x15, 3

/* Check Carry Flag */
bn.rshi w11, w7, w11 >> 31
bn.cmp w7, w11, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

/* Check Flags: Carry = 1 if a0 < 0 ; Allzero = 1 if a0 == 0*/
or x15, x15, x14
li x3, 1
beq x3, x15, a0_leq_zero

/* return (a1 == 43) ?  0 : a1 + 1 */

/* From decompose: WDR 4 = 43 */
/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w15
bn.cmp w11, w4, FG0

/* Check Zero Flag */
csrrw x14, 1984, x0
li x3, 8
andi x14, x14, 8
bne x3, x14, a1_not_43

/* Store 0 if a1 == 43*/
bn.rshi w10, w7, w10 >> 32
beq x0, x0, shift_coefficients

a1_not_43:

/* Store a1+1 if a1 =/= 43*/
bn.addi w11, w11, 1
bn.rshi w10, w11, w10 >> 32
beq x0, x0, shift_coefficients

/* else */
a0_leq_zero:

/* return (a1 ==  0) ? 43 : a1 - 1 */

/* From decompose: WDR 4 = 43 */
/* From decompose: WDR 7 = 0x0...0 */
/* From decompose: WDR 8 = 0xFFFFFFFF */

bn.and w11, w8, w15
bn.cmp w11, w7, FG0

csrrw x14, 1984, x0
li x3, 8
andi x14, x14, 8
bne x3, x14, a1_not_zero

/* Store 43 if a1 == 0 */
bn.rshi w10, w4, w10 >> 32
beq x0, x0, shift_coefficients

a1_not_zero:

/* Store a1-1 if a1 =/= 0 */
bn.subi w11, w11, 1
bn.rshi w10, w11, w10 >> 32

shift_coefficients:
bn.rshi w15, w7, w15 >> 32
bn.rshi w16, w7, w16 >> 32
bn.rshi w20, w7, w20 >> 1

ret

/*************************************************/
/*                    Decompose                  */
/*
* @param[in]  x6: address of all-zero vector
* @param[in]  x4: address of coefficients
* @param[out] w15: a1
* @param[out] w16: a0
*
* clobbered registers: x3: internal register addressing
*                      x14: read out flags
*                      w1: store constant 127
*                      w2: store constant 11275
*                      w3: store constant 1<<23
*                      w4: store constant 43
*                      w5: store constant 19464
*                      w6: store constant 4190208
*                      w7: store constant 0x0...0
*                      w8: store constant 0XF...F
*                      w9: store coefficients
*                      w10: sorting of coefficients
*                      w11: intermediate result
*                      w12: intermediate result
*                      w13: intermediate result
*                      w14: intermediate result
*                         
*
*/
/*************************************************/

decompose:

/* Initialize all necessary WDRs with zero */
li x3, 0
loopi 18, 1
  bn.lid x3++, 0(x6) 

/* Load Prime into WDR w0*/
li x3, 0
bn.lid x3, 64(x0)

/* Store 127 in WDR 1 */
bn.addi w1, w1, 127

/* Store 11275 in WDR 2 */
bn.addi w2, w2, 11
bn.rshi w2, w2, w7 >> 246
bn.addi w2, w2, 11

/* Store 1<<23 in WDR 3 */
bn.addi w3, w3, 1
bn.rshi w3, w3, w7 >> 233

/* Store 43 in WDR 4 */
bn.addi w4, w4, 43

/* Store 2*GAMMA2 = 190464 in WDR 5 (93 << 12) */
bn.addi w5, w5, 93
bn.rshi w5, w5, w7 >> 245

/* Store (Q-1)/2 = 4190208 in WDR 6 (1023 << 12) */
bn.addi w6, w6, 1023
bn.rshi w6, w6, w7 >> 244

/* Allzero in WDR 7 */

/* Store Mask in WDR 8 */
li x3, 8
bn.lid x3, 0(x0) 

/* Load Coefficients in WDR 9 */
li x3, 9
bn.lid x3, 0(x4) 

/* Work in WDR 10 */

/* Sort coefficients differently to store them easier in one WDR */
pq.add w10.7, w9.0, w7.0
pq.add w10.6, w9.1, w7.0
pq.add w10.5, w9.2, w7.0
pq.add w10.4, w9.3, w7.0
pq.add w10.3, w9.4, w7.0
pq.add w10.2, w9.5, w7.0
pq.add w10.1, w9.6, w7.0
pq.add w10.0, w9.7, w7.0


loopi 8, 52
/* a1  = (a + 127) >> 7 */
bn.and w11, w8, w10
bn.addi w11, w11, 127
bn.and w11, w8, w10
bn.rshi w11, w7, w11 >> 7
bn.and w11, w8, w11

/* a1*11275 + (1 << 23) */
bn.mulqacc.wo.z w11, w2.0, w11.0, 0
bn.add w11, w11, w3

/* (a1*11275 + (1 << 23)) >> 24 */
bn.rshi w12, w7, w11 >> 31
bn.addi w13, w13, 1
bn.cmp w12, w13, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

bn.rshi w11, w7, w11 >> 24

bne x14, x0, skip_mask0
bn.or w11, w11, w8 << 8
bn.and w11, w11, w8
skip_mask0:

/* ((43 - a1) >> 31) & a1 */
bn.sub w12, w4, w11
bn.and w12, w8, w12
bn.rshi w12, w7, w12 >> 31

bn.cmp w7, w12, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

beq x14, x0, skip_mask1
bn.rshi w12, w8, w7 >> 248
bn.or w12, w8, w12
bn.and w12, w12, w8
skip_mask1:

bn.and w12, w8, w12
bn.and w12, w12, w11

/* a1 ^= ((43 - a1) >> 31) & a1 */
bn.xor w12, w12, w11

/* *a0  = a - a1*2*GAMMA2 */
bn.mulqacc.wo.z w13, w12.0, w5.0, 0
bn.and w13, w8, w13
bn.and w14, w8, w10
bn.sub w13, w14, w13

/* *a0 -= (((Q-1)/2 - *a0) >> 31) & Q */
bn.sub w14, w6, w13
bn.and w14, w8, w14

bn.rshi w14, w7, w14 >> 31

bn.addi w17, w17, 0
bn.cmp w7, w14, FG0
csrrw x14, 1984, x0
andi x14, x14, 1

beq x14, x0, skip_mask2
bn.rshi w11, w8, w7 >> 248
bn.or w14, w8, w14
bn.and w14, w14, w8
skip_mask2:

bn.and w14, w8, w14
bn.and w14, w0, w14
bn.sub w14, w13, w14


/* Store a1 and a0 in WDR15 and WDR16 */
bn.and w12, w8, w12
bn.or w15, w12, w15 << 32
bn.and w14, w8, w14
bn.or w16, w14, w16 << 32

/* Update WDR10 to process next coefficient */
bn.or w10, w7, w10 >> 32

ret

.section .data

bitmask32:
  .word 0xFFFFFFFF

bitmask_extended: 
  .word 0x00000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
 
allzero: 
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000

prime:
  .quad 0x00000000007fe001
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  .quad 0x0000000000000000
  
hint_coeffs:
  .quad 0xAAAAAAAAAAAAAAAA
  .quad 0xAAAAAAAAAAAAAAAA
  .quad 0xAAAAAAAAAAAAAAAA
  .quad 0xAAAAAAAAAAAAAAAA
  
coef0:
  .word 0x79b387
coef1:
  .word 0x6fe1dc
coef2:
  .word 0x3219cc
coef3:
  .word 0x5caa23
coef4:
  .word 0x6631b9
coef5:
  .word 0x19d591
coef6:
  .word 0x416ab0
coef7:
  .word 0x5f6fb0
coef8:
  .word 0x022d66
coef9:
  .word 0x6a731b
coef10:
  .word 0x6de25a
coef11:
  .word 0x7534b0
coef12:
  .word 0x578319
coef13:
  .word 0x5d7805
coef14:
  .word 0x231264
coef15:
  .word 0x3447fb
coef16:
  .word 0x3d0b5a
coef17:
  .word 0x2738e8
coef18:
  .word 0x124083
coef19:
  .word 0x507082
coef20:
  .word 0x24f418
coef21:
  .word 0x1155c9
coef22:
  .word 0x225499
coef23:
  .word 0x102101
coef24:
  .word 0x1507ca
coef25:
  .word 0x1f2ff6
coef26:
  .word 0x50877f
coef27:
  .word 0x4961e3
coef28:
  .word 0x5a58f3
coef29:
  .word 0x5b1479
coef30:
  .word 0x203a55
coef31:
  .word 0x232759
coef32:
  .word 0x1c325a
coef33:
  .word 0x285e5b
coef34:
  .word 0x150f7d
coef35:
  .word 0x065a10
coef36:
  .word 0x74138c
coef37:
  .word 0x6be58c
coef38:
  .word 0x6cd6ab
coef39:
  .word 0x3b2c7f
coef40:
  .word 0x5d698d
coef41:
  .word 0x04e3ac
coef42:
  .word 0x5bafd9
coef43:
  .word 0x3dda85
coef44:
  .word 0x2b0f0b
coef45:
  .word 0x33f9e8
coef46:
  .word 0x4f78b8
coef47:
  .word 0x599114
coef48:
  .word 0x2e0e8e
coef49:
  .word 0x1c5a64
coef50:
  .word 0x6e8f22
coef51:
  .word 0x22169f
coef52:
  .word 0x11b1ab
coef53:
  .word 0x40b58a
coef54:
  .word 0x68f080
coef55:
  .word 0x0cd81e
coef56:
  .word 0x31933a
coef57:
  .word 0x6ad6d4
coef58:
  .word 0x32aae6
coef59:
  .word 0x29599b
coef60:
  .word 0x49d636
coef61:
  .word 0x5e254e
coef62:
  .word 0x45f7aa
coef63:
  .word 0x47e1d7
coef64:
  .word 0x3fd190
coef65:
  .word 0x5fb938
coef66:
  .word 0x194249
coef67:
  .word 0x426779
coef68:
  .word 0x5582c1
coef69:
  .word 0x3ab9d5
coef70:
  .word 0x18089b
coef71:
  .word 0x535353
coef72:
  .word 0x5d1022
coef73:
  .word 0x4c90f1
coef74:
  .word 0x79bebb
coef75:
  .word 0x78c155
coef76:
  .word 0x02a13f
coef77:
  .word 0x188d23
coef78:
  .word 0x04144e
coef79:
  .word 0x421884
coef80:
  .word 0x72ee7d
coef81:
  .word 0x5e5684
coef82:
  .word 0x0b0a6f
coef83:
  .word 0x6b81d9
coef84:
  .word 0x3a811a
coef85:
  .word 0x1bad1b
coef86:
  .word 0x362831
coef87:
  .word 0x211832
coef88:
  .word 0x72bc91
coef89:
  .word 0x5b81dc
coef90:
  .word 0x7e85a5
coef91:
  .word 0x6c11fa
coef92:
  .word 0x58fd42
coef93:
  .word 0x10ce50
coef94:
  .word 0x7b1020
coef95:
  .word 0x6df0c7
coef96:
  .word 0x7103b9
coef97:
  .word 0x245f98
coef98:
  .word 0x0a816a
coef99:
  .word 0x2b46ec
coef100:
  .word 0x73b440
coef101:
  .word 0x3d2f56
coef102:
  .word 0x5d98e6
coef103:
  .word 0x5658ee
coef104:
  .word 0x477ab1
coef105:
  .word 0x736fb5
coef106:
  .word 0x5adc6e
coef107:
  .word 0x496b59
coef108:
  .word 0x188463
coef109:
  .word 0x30a44c
coef110:
  .word 0x4cbff8
coef111:
  .word 0x4f92cc
coef112:
  .word 0x7abf75
coef113:
  .word 0x638cfd
coef114:
  .word 0x724eff
coef115:
  .word 0x3d88b3
coef116:
  .word 0x2ef8d2
coef117:
  .word 0x309ac2
coef118:
  .word 0x0fa9ac
coef119:
  .word 0x653f5
coef120:
  .word 0x6f1d84
coef121:
  .word 0x4a0a88
coef122:
  .word 0x4d2b06
coef123:
  .word 0x083c46
coef124:
  .word 0x419205
coef125:
  .word 0x6a415b
coef126:
  .word 0x794c68
coef127:
  .word 0x44c01a
coef128:
  .word 0x4113dd
coef129:
  .word 0x486c5f
coef130:
  .word 0x079a7a
coef131:
  .word 0x007857
coef132:
  .word 0x77b01f
coef133:
  .word 0x0e2ba4
coef134:
  .word 0x35c842
coef135:
  .word 0x388815
coef136:
  .word 0x3d547e
coef137:
  .word 0x6a565a
coef138:
  .word 0x6e1e54
coef139:
  .word 0x189f11
coef140:
  .word 0x3aac91
coef141:
  .word 0x798fb2
coef142:
  .word 0x0f854e
coef143:
  .word 0x13cb0f
coef144:
  .word 0x576295
coef145:
  .word 0x362ff8
coef146:
  .word 0x662091
coef147:
  .word 0x69e77f
coef148:
  .word 0x2f4e1c
coef149:
  .word 0x04c5a7
coef150:
  .word 0x14b12d
coef151:
  .word 0x0d040a
coef152:
  .word 0x43ed26
coef153:
  .word 0x1335f6
coef154:
  .word 0x0c6769
coef155:
  .word 0x4fd888
coef156:
  .word 0x45b917
coef157:
  .word 0x49bb57
coef158:
  .word 0x0e3b8f
coef159:
  .word 0x2c9cf2
coef160:
  .word 0x5d1e83
coef161:
  .word 0x26c70e
coef162:
  .word 0x5c6f9b
coef163:
  .word 0x4ab15e
coef164:
  .word 0x25a66d
coef165:
  .word 0x67b0b5
coef166:
  .word 0x468e12
coef167:
  .word 0x2e313c
coef168:
  .word 0x4b2db0
coef169:
  .word 0x043906
coef170:
  .word 0x126a82
coef171:
  .word 0x556272
coef172:
  .word 0x5630f3
coef173:
  .word 0x29ab1c
coef174:
  .word 0x0c4425
coef175:
  .word 0x243da4
coef176:
  .word 0x7e161f
coef177:
  .word 0x6643c5
coef178:
  .word 0x10af10
coef179:
  .word 0x1f5f70
coef180:
  .word 0x4000f8
coef181:
  .word 0x52db10
coef182:
  .word 0x779946
coef183:
  .word 0x3693c0
coef184:
  .word 0x7dea36
coef185:
  .word 0x280e73
coef186:
  .word 0x3a53e3
coef187:
  .word 0x5e8882
coef188:
  .word 0x6af0e7
coef189:
  .word 0x01dd75
coef190:
  .word 0xaebb6
coef191:
  .word 0x7d1f05
coef192:
  .word 0x783a66
coef193:
  .word 0x722cf5
coef194:
  .word 0x1a44ec
coef195:
  .word 0x20d4a5
coef196:
  .word 0x1f7c71
coef197:
  .word 0x253c71
coef198:
  .word 0x1d3084
coef199:
  .word 0x399d61
coef200:
  .word 0x6ef04f
coef201:
  .word 0x69496f
coef202:
  .word 0x5a3bda
coef203:
  .word 0x5e3afb
coef204:
  .word 0x06998c
coef205:
  .word 0x45d293
coef206:
  .word 0x292851
coef207:
  .word 0x05c519
coef208:
  .word 0x1012ae
coef209:
  .word 0x578ce9
coef210:
  .word 0x5c1ac1
coef211:
  .word 0x34d742
coef212:
  .word 0x20beca
coef213:
  .word 0x56a000
coef214:
  .word 0x67cfe3
coef215:
  .word 0x2677ea
coef216:
  .word 0x51ad80
coef217:
  .word 0x7bf217
coef218:
  .word 0x54a829
coef219:
  .word 0x359194
coef220:
  .word 0x321f45
coef221:
  .word 0x5a0f56
coef222:
  .word 0x1b5acc
coef223:
  .word 0x2f45f7
coef224:
  .word 0x354312
coef225:
  .word 0x7b875c
coef226:
  .word 0x5d4ae3
coef227:
  .word 0x416c77
coef228:
  .word 0x237523
coef229:
  .word 0x2b453f
coef230:
  .word 0x1436bc
coef231:
  .word 0x10a1a3
coef232:
  .word 0x3574bf
coef233:
  .word 0x31569f
coef234:
  .word 0x1fab4a
coef235:
  .word 0x674551
coef236:
  .word 0x3cbee7
coef237:
  .word 0x430b0d
coef238:
  .word 0x1f2f8f
coef239:
  .word 0x39e967
coef240:
  .word 0x66fee4
coef241:
  .word 0x462499
coef242:
  .word 0x6e0b10
coef243:
  .word 0x4082a8
coef244:
  .word 0x10d23d
coef245:
  .word 0x52a4b7
coef246:
  .word 0x17da74
coef247:
  .word 0x3e0040
coef248:
  .word 0x5170ee
coef249:
  .word 0x68ad2e
coef250:
  .word 0x408295
coef251:
  .word 0x66a548
coef252:
  .word 0x74c3ae
coef253:
  .word 0x2cd72b
coef254:
  .word 0x67ac0f
coef255:
  .word 0x25c181

