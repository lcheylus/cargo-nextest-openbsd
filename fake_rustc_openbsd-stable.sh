#!/bin/sh
#
# Fake rustc binary to get `rust -vV` on OpenBSD-stable 7.4
# Necessary for GH actions Swatinem/rust-cache
#

cat << EOF
rustc 1.72.1 (d5c2e9c34 2023-09-13) (built from a source tarball)
binary: rustc
commit-hash: d5c2e9c342b358556da91d61ed4133f6f50fc0c3
commit-date: 2023-09-13
host: x86_64-unknown-openbsd
release: 1.72.1
LLVM version: 16.0.5
EOF
