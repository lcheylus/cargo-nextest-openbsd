# Build of cargo-nextest on OpenBSD-stable version

[cargo-nextest](https://github.com/nextest-rs/nextest) is a next-generation test runner for Rust.

Build of this tool on OpenBSD-stable (**current version = 7.5**) and publication
of a release synced with official release of cargo-nextest.

## Why

For some Rust projects, regression tests are runned with `cargo-nextest` instead
of `cargo test`. For example, the [uutils/coreutils](https://github.com/uutils/coreutils) project uses
cargo-nextest to run their tests in GitHub workflows.

cargo-nextest releases are not available on OpenBSD (see
https://nexte.st/book/pre-built-binaries.html) and this tool is neither
available in OpenBSD-stable ports tree.

As a temporary solution, this repository allows to build cargo-nextest on
OpenBSD-stable version and publish "official" releases synced with cargo-nextest
releases.

## How

Install requirements to run build script:

  * Bash shell
  * Curl to download sources
  * Rust compiler (with cargo) : version 1.76.0 on OpenBSD 7.5
  * [zstd](https://facebook.github.io/zstd/) library

```shell
$ pkg_add -v bash curl rust zstd
```

Build `cargo-nextest` for an official release (`NEXTEST_VERSION`) on
OpenBSD-stable (current version = 7.5) with `build.sh` script:

```shell
$ ./build.sh <NEXTEST_VERSION>
```

By default, build is done in `/tmp/cargo-nextest-build-<NEXTEST_VERSION>`
directory (variable `WRKDIR` defined in `build.sh`).

## Prepare a release

When a new release of cargo-nextest is published:

1. Run `build.sh` on a local OpenBSD-stable host to check if the build is OK for
   this new version.
2. Update `NEXTEST_VERSION` in "Build" workflow (`.github/workflows/build.yml`)
   and run it manually to check if the build is OK on GitHub.
3. Tag the repository with the new version (tag = `major.minor.patch` without a
   preceding `v`) => the workflow "Build and publish" will build and publish
   the new release.
