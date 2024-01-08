#!/usr/bin/env bash
#
# Bash script to run build on GitHub CI
#

set -e

# NEXTEST_VERSION variable from GH env

REPO_NAME=${GITHUB_WORKSPACE##*/}
WORKSPACE_PARENT="/home/runner/work/${REPO_NAME}"
WORKSPACE="${WORKSPACE_PARENT}/${REPO_NAME}"

echo "## whoami"
whoami

# Increase the number of file descriptors - See https://github.com/rust-lang/cargo/issues/11435
ulimit -n 1024

# Check environment
echo "## environment"
echo "CI='${CI}'"
echo "REPO_NAME='${REPO_NAME}'"
echo "WORKSPACE_PARENT='${WORKSPACE_PARENT}'"
echo "WORKSPACE='${WORKSPACE}'"
echo "NEXTEST_VERSION='${NEXTEST_VERSION}'"
env | sort

# Tooling info
echo "## tooling infos"
cargo -V
rustc -V

## Run build script for cargo-nextest
echo "##################################"
echo "Run build script for cargo-nextest"
echo "##################################"

cd "${WORKSPACE}"
export CARGO_TERM_COLOR=always
./build.sh "${NEXTEST_VERSION}"

echo "# ls -l /tmp/cargo-nextest-build-${NEXTEST_VERSION}/target/release"
ls -l /tmp/cargo-nextest-build-"${NEXTEST_VERSION}"/target/release

echo "# /tmp/cargo-nextest-build-${NEXTEST_VERSION}/target/release/cargo-nextest -V"
/tmp/cargo-nextest-build-"${NEXTEST_VERSION}"/target/release/cargo-nextest -V

## Copy cargo-nextest binary to GITHUB_WORKSPACE => copy back to Ubuntu host
echo "# Copy cargo-nextest-${NEXTEST_VERSION} to working directory"
cp -v /tmp/cargo-nextest-build-"${NEXTEST_VERSION}"/target/release/cargo-nextest "${GITHUB_WORKSPACE}"
