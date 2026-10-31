#!/usr/bin/env python3
# Licensed under the Apache License, Version 2.0. See LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

"""Host-only regression checks for the Kyber reference benchmarks.

Run from the repository root:
    python3 ref/tests/test_kyber_benchmarks.py -v

Requires Linux, Python 3 and GCC. The temporary performance-counter header
only permits host syntax checking; it does not model the target hardware.
The numerical checks compare the C forward NTT with existing RTL expected
vectors modulo q. They do not execute OTBN instructions or measure cycles.
"""

import ctypes
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
KYBER_Q = 3329
KYBER_N = 256


class KyberBenchmarkTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.gcc = shutil.which("gcc")
        if cls.gcc is None:
            raise RuntimeError("GCC is required. On Ubuntu: sudo apt install gcc")
        cls.temporary = tempfile.TemporaryDirectory(prefix="otbn-pq-host-tests-")
        cls.addClassCleanup(cls.temporary.cleanup)
        cls.tempdir = Path(cls.temporary.name)
        cls.include_dir = cls.tempdir / "include"
        cls.include_dir.mkdir()
        (cls.include_dir / "simple_system_common.h").write_text(
            "#ifndef OTBN_HOST_COUNTER_STUB_H\n"
            "#define OTBN_HOST_COUNTER_STUB_H\n"
            "#include <stdio.h>\n"
            "static inline void pcount_enable(int v) { (void)v; }\n"
            "static inline void pcount_reset(void) {}\n"
            "#endif\n",
            encoding="utf-8",
        )

    def assert_caller_types_match(self, benchmark):
        ref = ROOT / "ref" / benchmark
        result = subprocess.run(
            [self.gcc, "-std=c11", "-fsyntax-only",
             "-Werror=incompatible-pointer-types",
             "-I", str(self.include_dir), "-I", str(ref),
             str(ref / "ntt_main.c")],
            capture_output=True, text=True, check=False,
        )
        self.assertEqual(
            result.returncode, 0,
            f"{benchmark}: benchmark input type disagrees with its kernel API.\n"
            f"{result.stdout}{result.stderr}",
        )

    @classmethod
    def forward_ntt_output(cls):
        if not hasattr(cls, "_forward_output"):
            ref = ROOT / "ref" / "ntt_kyber"
            library_path = cls.tempdir / "libkyber_ntt.so"
            result = subprocess.run(
                [cls.gcc, "-std=c11", "-O2", "-fPIC", "-shared",
                 "-I", str(ref), str(ref / "ntt.c"), str(ref / "reduce.c"),
                 "-o", str(library_path)],
                capture_output=True, text=True, check=False,
            )
            if result.returncode:
                raise RuntimeError(
                    "Could not build the host C NTT kernel:\n" + result.stderr
                )
            cls._library = ctypes.CDLL(str(library_path))
            ntt = cls._library.pqcrystals_kyber512_ref_ntt
            ntt.argtypes = [ctypes.POINTER(ctypes.c_int16)]
            ntt.restype = None
            coefficients = (ctypes.c_int16 * KYBER_N)(*range(KYBER_N))
            ntt(coefficients)
            cls._forward_output = [int(v) % KYBER_Q for v in coefficients]
        return cls._forward_output

    def assert_expected_vector(self, filename):
        text = (ROOT / "dv" / "sv" / filename).read_text(encoding="utf-8")
        entries = re.findall(
            r"^\s*(\d+)\s*:\s*assert\s*\(rdbk\s*==\s*32'd(\d+)\)",
            text, flags=re.MULTILINE,
        )
        self.assertEqual(len(entries), KYBER_N, "Expected 256 coefficient checks")
        expected = {int(i): int(v) % KYBER_Q for i, v in entries}
        self.assertEqual(set(expected), set(range(KYBER_N)))
        actual = self.forward_ntt_output()
        for index in range(KYBER_N):
            with self.subTest(vector=filename, coefficient=index):
                self.assertEqual(actual[index], expected[index])

    def test_ntt_benchmark_argument_types(self):
        self.assert_caller_types_match("ntt_kyber")

    def test_intt_benchmark_argument_types(self):
        self.assert_caller_types_match("intt_kyber")

    def test_ntt_matches_optimized_rtl_expected_vector(self):
        self.assert_expected_vector("testcase0024.sv")

    def test_ntt_matches_indirect_rtl_expected_vector(self):
        self.assert_expected_vector("testcase0026.sv")


if __name__ == "__main__":
    unittest.main()
