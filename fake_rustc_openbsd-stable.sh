#!/bin/sh
#
# Fake rustc binary to get `rust -vV` on OpenBSD-stable 7.6
# Necessary for GH actions Swatinem/rust-cache
#

cat << EOF
rustc 1.81.0 (eeb90cda1 2024-09-04) (built from a source tarball)
binary: rustc
commit-hash: eeb90cda1969383f56a2637cbd3037bdf598841c
commit-date: 2024-09-04
host: x86_64-unknown-openbsd
release: 1.81.0
LLVM version: 17.0.6
EOF
