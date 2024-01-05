# Build of cargo-nextest on OpenBSD-stable version

[cargo-nextest](https://github.com/nextest-rs/nextest) is next-generation test runner for Rust.

Build of this tool on OpenBSD-stable (current version = 7.4).

## Why

xx

## How

Install requirements:

  * Bash shell
  * Curl to download sources
  * Rust compiler (with cargo) : version 1.72.1 on OpenBSD 7.4
  * [zstd](https://facebook.github.io/zstd/) library

```shell
$ pkg_add -v bash curl rust zstd
```

Build `cargo-nextest` on OpenBSD-stable (current version = 7.4) with `build.sh` script.
