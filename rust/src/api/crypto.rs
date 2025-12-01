//! Cryptographic functions for file encryption/decryption using pink072
//!
//! This module provides the encryption layer for Selona using pink072.
//! Files are encoded as .pnk (pink PNG) format with a 9-byte seed.

use flutter_rust_bridge::frb;
use pink072::{decode_auto, decode_file, encode_file};
use sha2::{Digest, Sha256};
use std::fs;
use std::path::Path;

/// Encodes a file to .pnk format
///
/// # Arguments
/// * `input_path` - Path to the source file
/// * `output_path` - Path for the output .pnk file
/// * `passphrase` - 9-character passphrase used as seed
///
/// # Returns
/// * `Ok(())` on success
/// * `Err(String)` on failure
#[frb(sync)]
pub fn encode_to_pnk(
    input_path: String,
    output_path: String,
    passphrase: String,
) -> Result<(), String> {
    let seed = passphrase_to_seed(&passphrase)?;

    encode_file(Path::new(&input_path), Path::new(&output_path), &seed)
        .map_err(|e| format!("Encode failed: {}", e))
}

/// Decodes a .pnk file to a temporary directory
///
/// # Arguments
/// * `input_path` - Path to the .pnk file
/// * `output_dir` - Directory to extract the file to
///
/// # Returns
/// * `Ok(String)` - The filename of the extracted file
/// * `Err(String)` on failure
#[frb(sync)]
pub fn decode_from_pnk(input_path: String, output_dir: String) -> Result<String, String> {
    decode_file(Path::new(&input_path), Path::new(&output_dir))
        .map_err(|e| format!("Decode failed: {}", e))
}

/// Decodes a .pnk file with auto-detection of payload type
///
/// # Arguments
/// * `input_path` - Path to the .pnk file
/// * `output_dir` - Directory to extract files to
///
/// # Returns
/// * `Ok(Vec<String>)` - List of extracted filenames
/// * `Err(String)` on failure
#[frb(sync)]
pub fn decode_from_pnk_auto(input_path: String, output_dir: String) -> Result<Vec<String>, String> {
    decode_auto(Path::new(&input_path), Path::new(&output_dir))
        .map_err(|e| format!("Decode failed: {}", e))
}

/// Deletes a temporary file
///
/// # Arguments
/// * `path` - Path to the file to delete
///
/// # Returns
/// * `Ok(())` on success
/// * `Err(String)` on failure
#[frb(sync)]
pub fn delete_temp_file(path: String) -> Result<(), String> {
    fs::remove_file(Path::new(&path)).map_err(|e| format!("Failed to delete temp file: {}", e))
}

/// Deletes a temporary directory and all its contents
///
/// # Arguments
/// * `path` - Path to the directory to delete
///
/// # Returns
/// * `Ok(())` on success
/// * `Err(String)` on failure
#[frb(sync)]
pub fn delete_temp_dir(path: String) -> Result<(), String> {
    fs::remove_dir_all(Path::new(&path))
        .map_err(|e| format!("Failed to delete temp directory: {}", e))
}

/// Converts a 9-character passphrase to a 9-byte seed
fn passphrase_to_seed(passphrase: &str) -> Result<[u8; 9], String> {
    if passphrase.len() != 9 {
        return Err("Passphrase must be exactly 9 characters".to_string());
    }

    let bytes = passphrase.as_bytes();
    let mut seed = [0u8; 9];
    seed.copy_from_slice(&bytes[0..9]);
    Ok(seed)
}

/// Hashes a passphrase for secure storage
///
/// # Arguments
/// * `passphrase` - The passphrase to hash
///
/// # Returns
/// * The hashed passphrase as a hex string
#[frb(sync)]
pub fn hash_passphrase(passphrase: String) -> String {
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
#[frb(sync)]
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
#[frb(sync)]
pub fn hash_pin(pin: String) -> String {
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
#[frb(sync)]
pub fn verify_pin(pin: String, hash: String) -> bool {
    let computed_hash = hash_pin(pin);
    computed_hash == hash
}

/// Decodes a .pnk file and returns its contents as bytes
/// Useful for thumbnails and small files that fit in memory
///
/// # Arguments
/// * `input_path` - Path to the .pnk file
///
/// # Returns
/// * `Ok(Vec<u8>)` - The decoded file contents
/// * `Err(String)` on failure
#[frb(sync)]
pub fn decode_to_bytes(input_path: String) -> Result<Vec<u8>, String> {
    // Create a temporary directory for decoding
    let temp_dir = std::env::temp_dir().join(format!("selona_decode_{}", std::process::id()));
    fs::create_dir_all(&temp_dir).map_err(|e| format!("Failed to create temp dir: {}", e))?;

    // Decode to temp directory
    let filename = decode_file(Path::new(&input_path), &temp_dir)
        .map_err(|e| format!("Decode failed: {}", e))?;

    // Read the decoded file
    let decoded_path = temp_dir.join(&filename);
    let data =
        fs::read(&decoded_path).map_err(|e| format!("Failed to read decoded file: {}", e))?;

    // Cleanup
    let _ = fs::remove_dir_all(&temp_dir);

    Ok(data)
}

// Hex encoding support
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
    use std::fs;
    use std::path::Path;

    #[test]
    fn test_passphrase_to_seed() {
        let seed = passphrase_to_seed("a3f7b2c1e").unwrap();
        assert_eq!(seed.len(), 9);
        assert_eq!(&seed, b"a3f7b2c1e");
    }

    #[test]
    fn test_invalid_passphrase_length() {
        assert!(passphrase_to_seed("short").is_err());
        assert!(passphrase_to_seed("toolongpassphrase").is_err());
    }

    #[test]
    fn test_encode_decode_roundtrip() {
        let test_dir = Path::new("/tmp/selona_test");
        let _ = fs::remove_dir_all(test_dir);
        fs::create_dir_all(test_dir).unwrap();

        let input_file = test_dir.join("test.txt");
        let pnk_file = test_dir.join("test.pnk");
        let output_dir = test_dir.join("output");

        fs::write(&input_file, b"Hello, Selona!").unwrap();

        // Encode
        encode_to_pnk(
            input_file.to_string_lossy().to_string(),
            pnk_file.to_string_lossy().to_string(),
            "a3f7b2c1e".to_string(),
        )
        .unwrap();

        assert!(pnk_file.exists());

        // Decode
        let filename = decode_from_pnk(
            pnk_file.to_string_lossy().to_string(),
            output_dir.to_string_lossy().to_string(),
        )
        .unwrap();

        assert_eq!(filename, "test.txt");

        let content = fs::read(output_dir.join(&filename)).unwrap();
        assert_eq!(content, b"Hello, Selona!");

        // Cleanup
        let _ = fs::remove_dir_all(test_dir);
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
