// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "ntt.h"


int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  

  uint16_t a[512];

  puts("FALCON-512 NTT Performance Test\n");
  // Initialize poly
    for(int i=0; i<512; i++){
        a[i] = i;
    }

  puts("FALCON-512 NTT Start\n");

  pcount_enable(1);
  mq_NTT(a,9);
  pcount_enable(0);

  puts("FALCON-512 NTT Done\n");
  putchar('\n');

  return 0;
}
