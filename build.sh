#!/usr/bin/env bash
#
# Shell script to build cargo-nextest tool on OpenBSD-stable
#

set -eu

# Rust profile for build
# PROFILE="debug"
PROFILE="release"

# Check args to get version
if [ $# -ne 1 ]; then
	echo "ERROR: unable to get cargo-nextest version"
	echo "usage: build.sh <NEXTEST_VERSION>"
	exit 1
fi

# cargo-nextest version
VERSION=$1

echo "[*] Build cargo-nextest version ${VERSION} on OpenBSD $(uname -r)"

rm -f /tmp/cargo-nextest-"${VERSION}".tar.gz

# Check version and download sources for cargo-nextest
STATUSCODE=$(curl -sL "https://github.com/nextest-rs/nextest/archive/refs/tags/cargo-nextest-"${VERSION}".tar.gz" -O --output-dir /tmp --write-out "%{http_code}")
if test $STATUSCODE -eq 404; then
	rm -f /tmp/cargo-nextest-"${VERSION}".tar.gz
	echo "ERROR: non existent cargo-nextest version '${VERSION}'"
	exit 1
fi

if test $STATUSCODE -gt 400; then
	echo "ERROR: unable to download sources for cargo-nextest - HTTP Status-Code = ${STATUSCODE}"
	exit 1
fi

WRKDIR=/tmp/cargo-nextest-build-${VERSION}

echo "[*] WRKDIR=${WRKDIR}"
rm -rf ${WRKDIR}

echo "[*] Download sources for cargo-nextest-build-${VERSION}"

# Prepare sources for cargo-nextest
tar xzf /tmp/cargo-nextest-"${VERSION}".tar.gz -C /tmp
mv /tmp/nextest-cargo-nextest-"${VERSION}" ${WRKDIR}
rm -f /tmp/cargo-nextest-"${VERSION}".tar.gz

# Download sources for crate libc (commit 4e0bfc439 for OpenBSD waitid)
echo "[*] Download sources for libc crate"
cd ${WRKDIR}
mkdir crates
cd crates
git clone https://github.com/rust-lang/libc.git
cd libc
git reset --hard 4e0bfc439

# Download crate openssl-sys
echo "[*] Download sources for openssl-sys-0.9.97 crate"
cd ${WRKDIR}
curl -sL https://crates.io/api/v1/crates/openssl-sys/0.9.97/download|tar xzf - -C crates

# Patch crate openssl-sys
echo "[*] Patch sources for openssl-sys-0.9.97 crate"
cd ${WRKDIR}/crates/openssl-sys-0.9.97
sed -i.orig -e "/ => ('.', '.'),/h" -e "/ => ('.', '.', '.'),/h" -e "/_ => version_error(),/{g; s/(.*) =>/_ =>/; }" build/main.rs

# Download crate zstd-sys-2.0.9+zstd.1.5.5
echo "[*] Download sources for zstd-sys-2.0.9+zstd.1.5.5 crate"
cd ${WRKDIR}
curl -sL https://crates.io/api/v1/crates/zstd-sys/2.0.9+zstd.1.5.5/download|tar xzf - -C crates

# Patch crate zstd-sys-2.0.9+zstd.1.5.5
echo "[*] Patch sources for zstd-sys-2.0.9+zstd.1.5.5 crate"
cd ${WRKDIR}/crates/zstd-sys-2.0.9+zstd.1.5.5
rm -rf zstd
sed -i.orig -e 's,^fn main() {,fn main() { println!("cargo:rustc-link-lib=zstd"); return;,' build.rs
sed -i '1s/^/#![allow(unreachable_code)]\'$'\n/' build.rs

# Patch cargo configuration for modified crates
echo "[*] Patch cargo configuration in .cargo/config.toml"

cd ${WRKDIR}
printf "\n[patch.crates-io]\n" > cargo_config-patch.toml
printf "libc = { path = 'crates/libc' }\n" >> cargo_config-patch.toml
printf "openssl-sys = { path = 'crates/openssl-sys-0.9.97'}\n" >> cargo_config-patch.toml
printf "zstd-sys = { path = 'crates/zstd-sys-2.0.9+zstd.1.5.5' }\n" >> cargo_config-patch.toml

cat cargo_config-patch.toml >> .cargo/config.toml
rm -f cargo_config-patch.toml

# Fix fixtures/nextest-tests/scripts/my-script.sh
# See https://github.com/nextest-rs/nextest/commit/4a0de0ba4b706dd45b8c247a09e0ad0ec30f962e
echo "[*] Patch fixtures/nextest-tests/scripts/my-script.sh"
cd ${WRKDIR}/fixtures/nextest-tests/scripts/
cat << 'EOF' > my-script.sh
#!/bin/sh

# This depends only on /bin/sh, not bash, because some platforms like OpenBSD don't have bash
# installed by default.

# If this environment variable is set, exit with non-zero.
if [ -n "$__NEXTEST_SETUP_SCRIPT_ERROR" ]; then
    echo "__NEXTEST_SETUP_SCRIPT_ERROR is set, exiting with 1"
    exit 1
fi

echo MY_ENV_VAR=my-env-var >> "$NEXTEST_ENV"
EOF

# Disable self-update feature
echo "[*] Disable self-update feature in cargo-nextest/Cargo.toml"
cd ${WRKDIR}/cargo-nextest
sed -i.orig -e 's/default = \["default-no-update", "self-update"\]/default = \[\]/' Cargo.toml

echo "[*] Patch Cargo.toml to strip binary in release profile"
cd ${WRKDIR}
printf "\n[profile.release]\n" > Cargo-patch.toml
printf "strip = true  # Automatically strip symbols from the binary.\n" >> Cargo-patch.toml

cat Cargo-patch.toml >> Cargo.toml
rm -f Cargo-patch.toml

cd ${WRKDIR}
# Build cargo-nextest with cargo
echo "[*] Build cargo-nextest with profile ${PROFILE}"
if [ "${PROFILE}" = "release" ]; then
	OPENSSL_NO_VENDOR=1 RUSTFLAGS=-L/usr/local/lib cargo build --release
else
	OPENSSL_NO_VENDOR=1 RUSTFLAGS=-L/usr/local/lib cargo build
fi
