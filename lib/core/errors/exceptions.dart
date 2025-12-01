/// Base exception class for Selona
abstract class SelonaException implements Exception {
  final String message;
  final Object? cause;

  const SelonaException(this.message, [this.cause]);

  @override
  String toString() => message;
}

/// Exception for encryption/decryption failures
class CryptoException extends SelonaException {
  const CryptoException(super.message, [super.cause]);
}

/// Exception for invalid passphrase
class InvalidPassphraseException extends CryptoException {
  const InvalidPassphraseException([String? message])
      : super(message ?? 'Invalid passphrase');
}

/// Exception for authentication failures
class AuthenticationException extends SelonaException {
  const AuthenticationException(super.message, [super.cause]);
}

/// Exception for invalid PIN
class InvalidPinException extends AuthenticationException {
  const InvalidPinException([String? message])
      : super(message ?? 'Invalid PIN');
}

/// Exception for storage/file operations
class StorageException extends SelonaException {
  const StorageException(super.message, [super.cause]);
}

/// Exception for file not found
class FileNotFoundException extends StorageException {
  final String path;

  const FileNotFoundException(this.path) : super('File not found: $path');
}

/// Exception for import failures
class ImportException extends SelonaException {
  const ImportException(super.message, [super.cause]);
}

/// Exception for unsupported file type
class UnsupportedFileTypeException extends ImportException {
  final String extension;

  const UnsupportedFileTypeException(this.extension)
      : super('Unsupported file type: $extension');
}

/// Exception for database operations
class DatabaseException extends SelonaException {
  const DatabaseException(super.message, [super.cause]);
}
