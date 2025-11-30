//! Selona Rust library for encryption/decryption
//!
//! This module provides secure file encryption using the pink-072 algorithm
//! (or a compatible substitute until pink-072 is available).

mod api;

pub use api::crypto::*;
