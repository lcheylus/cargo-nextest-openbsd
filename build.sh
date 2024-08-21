#!/usr/bin/env bash
#
# Shell script to build cargo-nextest tool on OpenBSD-stable
#

set -eu

# Rust profile for build
# PROFILE="debug"
PROFILE="release"

usage() {
	echo "usage: build.sh NEXTEST_VERSION [WRKDIR]"
	printf "\n  - NEXTEST_VERSION\tversion of cargo-nextest to build\n"
	printf "  - WRKDIR\t\tdirectory to download sources and build tool "
	echo "(default = /tmp/cargo-nextest-build-<NEXTEST_VERSION>)"
}

# Check args to get version
if [ $# -lt 1 ]; then
	printf "ERROR: unable to get cargo-nextest version\n\n"
	usage
	exit 1
elif [ $# -gt 2 ]; then
	usage
	exit 1
fi

# cargo-nextest version
VERSION=$1

echo "[*] Build cargo-nextest version ${VERSION} on OpenBSD $(uname -r)"

rm -f /tmp/cargo-nextest-"${VERSION}".tar.gz

# Check version and download sources for cargo-nextest
STATUSCODE=$(curl -sL "https://github.com/nextest-rs/nextest/archive/refs/tags/cargo-nextest-${VERSION}.tar.gz" -O --output-dir /tmp --write-out "%{http_code}")
if test "$STATUSCODE" -eq 404; then
	rm -f /tmp/cargo-nextest-"${VERSION}".tar.gz
	echo "ERROR: non existent cargo-nextest version '${VERSION}'"
	exit 1
fi

if test "$STATUSCODE" -gt 400; then
	echo "ERROR: unable to download sources for cargo-nextest - HTTP Status-Code = ${STATUSCODE}"
	exit 1
fi

# Set WRKDIR from args (optional)
WRKDIR=${2:-/tmp/cargo-nextest-build-"${VERSION}"}

echo "[*] WRKDIR=${WRKDIR}"

echo "[*] Download sources for cargo-nextest-build-${VERSION}"

# Prepare sources for cargo-nextest
tar xzf /tmp/cargo-nextest-"${VERSION}".tar.gz -C /tmp
cp -a /tmp/nextest-cargo-nextest-"${VERSION}"/. "${WRKDIR}"
rm -f /tmp/cargo-nextest-"${VERSION}".tar.gz

mkdir -p "${WRKDIR}"/crates

# Download crate openssl-sys
echo "[*] Download sources for openssl-sys-0.9.103 crate"
cd "${WRKDIR}"
curl -sL https://crates.io/api/v1/crates/openssl-sys/0.9.103/download|tar xzf - -C crates

# Patch crate openssl-sys
echo "[*] Patch sources for openssl-sys-0.9.103 crate"
cd "${WRKDIR}"/crates/openssl-sys-0.9.103
sed -i.orig -e "/ => ('.', '.'),/h" -e "/ => ('.', '.', '.'),/h" -e "/_ => version_error(),/{g; s/(.*) =>/_ =>/; }" build/main.rs

# Download crate zstd-sys-2.0.10+zstd.1.5.6
echo "[*] Download sources for zstd-sys-2.0.10+zstd.1.5.6 crate"
cd "${WRKDIR}"
curl -sL https://crates.io/api/v1/crates/zstd-sys/2.0.10+zstd.1.5.6/download|tar xzf - -C crates

# Patch crate zstd-sys-2.0.10+zstd.1.5.6
echo "[*] Patch sources for zstd-sys-2.0.10+zstd.1.5.6 crate"
cd "${WRKDIR}"/crates/zstd-sys-2.0.10+zstd.1.5.6
rm -rf zstd
sed -i.orig -e 's,^fn main() {,fn main() { println!("cargo:rustc-link-lib=zstd"); return;,' build.rs
sed -i '1s/^/#![allow(unreachable_code)]\'$'\n/' build.rs

# Patch cargo configuration for modified crates
echo "[*] Patch cargo configuration in .cargo/config.toml"

printf "\n[patch.crates-io]\n" > /tmp/cargo_config-patch.toml
printf "openssl-sys = { path = 'crates/openssl-sys-0.9.103'}\n" >> /tmp/cargo_config-patch.toml
printf "zstd-sys = { path = 'crates/zstd-sys-2.0.10+zstd.1.5.6' }\n" >> /tmp/cargo_config-patch.toml

cat /tmp/cargo_config-patch.toml >> "${WRKDIR}"/.cargo/config.toml
rm -f /tmp/cargo_config-patch.toml

cd "${WRKDIR}"
# Build cargo-nextest with cargo - self-update feature disabled
echo "[*] Build cargo-nextest with profile ${PROFILE}"
if [ "${PROFILE}" = "release" ]; then
	OPENSSL_NO_VENDOR=1 RUSTFLAGS=-L/usr/local/lib cargo build --release --no-default-features --features default-no-update
else
	OPENSSL_NO_VENDOR=1 RUSTFLAGS=-L/usr/local/lib cargo build --no-default-features --features default-no-update
fi
