// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "ntt.h"
#include "params.h"

int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  

  int16_t a[256];
  int16_t b[256];
  int16_t r[256];

  puts("Kyber Basemul Performance Test\n");
  // Initialize poly
    for(int i=0; i<256; i++){
        a[i] = i;
 	b[i] = i;
    }

  puts("Kyber Basemul Start\n");
  unsigned int i;
  pcount_enable(1);
  for(i=0;i<256/4;i++) {
    basemul(&r[4*i], &a[4*i], &b[4*i], zetas[64+i]);
    basemul(&r[4*i+2], &a[4*i+2], &b[4*i+2],
            -zetas[64+i]);
  }
  pcount_enable(0);

  puts("Kyber Basemul Done\n");
  putchar('\n');

  return 0;
}
