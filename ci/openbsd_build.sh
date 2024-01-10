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
printf "\n## tooling infos\n"
cargo -V
rustc -V
echo

## Run build script for cargo-nextest
echo "##################################"
echo "Run build script for cargo-nextest"
echo "##################################"

cd "${WORKSPACE}"
mkdir -p cargo-nextest-build
export CARGO_TERM_COLOR=always
./build.sh "${NEXTEST_VERSION}" "${WORKSPACE}/cargo-nextest-build"

printf "\n# ls -l %s/target/release\n" "${WORKSPACE}/cargo-nextest-build"
ls -l "${WORKSPACE}"/cargo-nextest-build/target/release

echo "# ${WORKSPACE}/cargo-nextest-build/target/release/cargo-nextest -V"
"${WORKSPACE}"/cargo-nextest-build/target/release/cargo-nextest -V
