//! Cryptographic functions for file encryption/decryption
//!
//! This module provides the encryption layer for Selona using AES-256-GCM
//! as a placeholder until pink-072 is integrated.

use aes_gcm::{
    aead::{Aead, KeyInit, OsRng},
    Aes256Gcm, Nonce,
};
use pbkdf2::pbkdf2_hmac_array;
use rand::RngCore;
use sha2::Sha256;

/// Nonce size for AES-GCM (96 bits / 12 bytes)
const NONCE_SIZE: usize = 12;

/// Salt size for key derivation (128 bits / 16 bytes)
const SALT_SIZE: usize = 16;

/// PBKDF2 iterations for key derivation
const PBKDF2_ITERATIONS: u32 = 100_000;

/// Derives a 256-bit key from a passphrase using PBKDF2
fn derive_key(passphrase: &[u8], salt: &[u8]) -> [u8; 32] {
    pbkdf2_hmac_array::<Sha256, 32>(passphrase, salt, PBKDF2_ITERATIONS)
}

/// Encrypts data using AES-256-GCM
///
/// # Arguments
/// * `data` - The plaintext data to encrypt
/// * `passphrase` - The user's 9-character passphrase
///
/// # Returns
/// * `Ok(Vec<u8>)` - The encrypted data with prepended salt and nonce
/// * `Err(String)` - Error message if encryption fails
///
/// # Format
/// The output format is: [salt (16 bytes)][nonce (12 bytes)][ciphertext]
pub fn encrypt(data: Vec<u8>, passphrase: String) -> Result<Vec<u8>, String> {
    // Validate passphrase length (exactly 9 characters for pink-072 compatibility)
    if passphrase.len() != 9 {
        return Err("Passphrase must be exactly 9 characters".to_string());
    }

    // Generate random salt
    let mut salt = [0u8; SALT_SIZE];
    OsRng.fill_bytes(&mut salt);

    // Derive key from passphrase
    let key = derive_key(passphrase.as_bytes(), &salt);

    // Create cipher
    let cipher = Aes256Gcm::new_from_slice(&key)
        .map_err(|e| format!("Failed to create cipher: {}", e))?;

    // Generate random nonce
    let mut nonce_bytes = [0u8; NONCE_SIZE];
    OsRng.fill_bytes(&mut nonce_bytes);
    let nonce = Nonce::from_slice(&nonce_bytes);

    // Encrypt
    let ciphertext = cipher
        .encrypt(nonce, data.as_ref())
        .map_err(|e| format!("Encryption failed: {}", e))?;

    // Combine salt + nonce + ciphertext
    let mut result = Vec::with_capacity(SALT_SIZE + NONCE_SIZE + ciphertext.len());
    result.extend_from_slice(&salt);
    result.extend_from_slice(&nonce_bytes);
    result.extend_from_slice(&ciphertext);

    Ok(result)
}

/// Decrypts data that was encrypted with the `encrypt` function
///
/// # Arguments
/// * `data` - The encrypted data (salt + nonce + ciphertext)
/// * `passphrase` - The user's 9-character passphrase
///
/// # Returns
/// * `Ok(Vec<u8>)` - The decrypted plaintext data
/// * `Err(String)` - Error message if decryption fails
pub fn decrypt(data: Vec<u8>, passphrase: String) -> Result<Vec<u8>, String> {
    // Validate passphrase length
    if passphrase.len() != 9 {
        return Err("Passphrase must be exactly 9 characters".to_string());
    }

    // Validate minimum data length
    let min_len = SALT_SIZE + NONCE_SIZE + 16; // 16 is minimum auth tag size
    if data.len() < min_len {
        return Err("Invalid encrypted data: too short".to_string());
    }

    // Extract salt, nonce, and ciphertext
    let salt = &data[..SALT_SIZE];
    let nonce_bytes = &data[SALT_SIZE..SALT_SIZE + NONCE_SIZE];
    let ciphertext = &data[SALT_SIZE + NONCE_SIZE..];

    // Derive key from passphrase
    let key = derive_key(passphrase.as_bytes(), salt);

    // Create cipher
    let cipher = Aes256Gcm::new_from_slice(&key)
        .map_err(|e| format!("Failed to create cipher: {}", e))?;

    // Create nonce
    let nonce = Nonce::from_slice(nonce_bytes);

    // Decrypt
    let plaintext = cipher
        .decrypt(nonce, ciphertext)
        .map_err(|_| "Decryption failed: invalid passphrase or corrupted data".to_string())?;

    Ok(plaintext)
}

/// Hashes a passphrase for secure storage
///
/// # Arguments
/// * `passphrase` - The passphrase to hash
///
/// # Returns
/// * The hashed passphrase as a hex string
pub fn hash_passphrase(passphrase: String) -> String {
    use sha2::Digest;

    let mut hasher = Sha256::new();
    hasher.update(passphrase.as_bytes());
    let result = hasher.finalize();

    hex::encode(result)
}

/// Verifies a passphrase against a stored hash
///
/// # Arguments
/// * `passphrase` - The passphrase to verify
/// * `hash` - The stored hash to compare against
///
/// # Returns
/// * `true` if the passphrase matches, `false` otherwise
pub fn verify_passphrase(passphrase: String, hash: String) -> bool {
    let computed_hash = hash_passphrase(passphrase);
    computed_hash == hash
}

/// Hashes a PIN for secure storage
///
/// # Arguments
/// * `pin` - The PIN to hash
///
/// # Returns
/// * The hashed PIN as a hex string
pub fn hash_pin(pin: String) -> String {
    use sha2::Digest;

    // Use a different prefix to distinguish from passphrase hashes
    let salted = format!("selona_pin_{}", pin);

    let mut hasher = Sha256::new();
    hasher.update(salted.as_bytes());
    let result = hasher.finalize();

    hex::encode(result)
}

/// Verifies a PIN against a stored hash
///
/// # Arguments
/// * `pin` - The PIN to verify
/// * `hash` - The stored hash to compare against
///
/// # Returns
/// * `true` if the PIN matches, `false` otherwise
pub fn verify_pin(pin: String, hash: String) -> bool {
    let computed_hash = hash_pin(pin);
    computed_hash == hash
}

// Add hex encoding support
mod hex {
    const HEX_CHARS: &[u8; 16] = b"0123456789abcdef";

    pub fn encode(data: impl AsRef<[u8]>) -> String {
        let bytes = data.as_ref();
        let mut result = String::with_capacity(bytes.len() * 2);
        for byte in bytes {
            result.push(HEX_CHARS[(byte >> 4) as usize] as char);
            result.push(HEX_CHARS[(byte & 0x0f) as usize] as char);
        }
        result
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encrypt_decrypt_roundtrip() {
        let original = b"Hello, Selona!".to_vec();
        let passphrase = "a3f7b2c1e".to_string(); // 9 characters

        let encrypted = encrypt(original.clone(), passphrase.clone()).unwrap();
        let decrypted = decrypt(encrypted, passphrase).unwrap();

        assert_eq!(original, decrypted);
    }

    #[test]
    fn test_invalid_passphrase_length() {
        let data = b"test".to_vec();

        // Too short
        let result = encrypt(data.clone(), "short".to_string());
        assert!(result.is_err());

        // Too long
        let result = encrypt(data, "toolongpassphrase".to_string());
        assert!(result.is_err());
    }

    #[test]
    fn test_wrong_passphrase_fails() {
        let original = b"Secret data".to_vec();
        let correct_passphrase = "a3f7b2c1e".to_string();
        let wrong_passphrase = "wrong1234".to_string();

        let encrypted = encrypt(original, correct_passphrase).unwrap();
        let result = decrypt(encrypted, wrong_passphrase);

        assert!(result.is_err());
    }

    #[test]
    fn test_passphrase_hashing() {
        let passphrase = "a3f7b2c1e".to_string();
        let hash = hash_passphrase(passphrase.clone());

        assert!(verify_passphrase(passphrase, hash.clone()));
        assert!(!verify_passphrase("wrong1234".to_string(), hash));
    }

    #[test]
    fn test_pin_hashing() {
        let pin = "123456".to_string();
        let hash = hash_pin(pin.clone());

        assert!(verify_pin(pin, hash.clone()));
        assert!(!verify_pin("654321".to_string(), hash));
    }
}
