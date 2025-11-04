#!/bin/sh
#
# Fake rustc binary to get `rust -vV` on OpenBSD-stable 7.8
# Necessary for GH actions Swatinem/rust-cache
#

cat << EOF
rustc 1.90.0 (1159e78c4 2025-09-14) (built from a source tarball)
binary: rustc
commit-hash: 1159e78c4747b02ef996e55082b704c09b970588
commit-date: 2025-09-14
host: x86_64-unknown-openbsd
release: 1.90.0
LLVM version: 19.1.7
EOF
