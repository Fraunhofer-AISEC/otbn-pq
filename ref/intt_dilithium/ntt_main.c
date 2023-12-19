// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "ntt.h"
#include "params.h"

int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  

  int32_t a[N];

  puts("Dilithium INTT Performance Test\n");
  // Initialize poly
    for(int i=0; i<N; i++){
        a[i] = i;
    }

  puts("Dilithium INTT Start\n");

  pcount_enable(1);
  invntt_tomont(a);
  pcount_enable(0);

  puts("Dilithium INTT Done\n");
  putchar('\n');

  return 0;
}
