#!/bin/sh
#
# Fake rustc binary to get `rust -vV` on OpenBSD-stable 7.5
# Necessary for GH actions Swatinem/rust-cache
#

cat << EOF
rustc 1.76.0 (07dca489a 2024-02-04) (built from a source tarball)
binary: rustc
commit-hash: 07dca489ac2d933c78d3c5158e3f43beefeb02ce
commit-date: 2024-02-04
host: x86_64-unknown-openbsd
release: 1.76.0
LLVM version: 16.0.6
EOF
