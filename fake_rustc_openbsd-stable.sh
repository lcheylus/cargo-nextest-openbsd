#!/bin/sh
#
# Fake rustc binary to get `rust -vV` on OpenBSD-stable 7.8
# Necessary for GH actions Swatinem/rust-cache
#

cat << EOF
rustc 1.94.1 (e408947bf 2026-03-25) (built from a source tarball)
binary: rustc
commit-hash: e408947bfd200af42db322daf0fadfe7e26d3bd1
commit-date: 2026-03-25
host: x86_64-unknown-openbsd
release: 1.94.1
LLVM version: 20.1.8
EOF
