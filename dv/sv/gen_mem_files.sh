#!/bin/bash

# Copyright Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC). */
# Licensed under the Apache License, Version 2.0, see LICENSE for details. */
# SPDX-License-Identifier: Apache-2.0 */

# Script to autogenerate memory contents for RTL testbench

# Search for assembly software code to generate imem and dmem contents
search_dir=sw
for entry in "$search_dir"/*
do
  if [[ $entry == *.s ]]
  then
    echo "Generate memory contents for ${entry}"
    util/otbn_as.py -o ${entry%.*}.o ${entry%.*}.s
    util/otbn_ld.py -o ${entry%.*}.elf ${entry%.*}.o
    dv/otbnsim/standalone.py ${entry%.*}.elf
    entry=${entry#"${search_dir}/"}
    mv dv/sv/mem/imem.txt dv/sv/mem/imem_${entry%.*}.txt
    mv dv/sv/mem/dmem.txt dv/sv/mem/dmem_${entry%.*}.txt
  fi
done



