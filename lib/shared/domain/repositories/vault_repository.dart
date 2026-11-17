import '../../../core/errors/result.dart';
import '../entities/resume.dart';
import '../entities/vault_item.dart';

/// Encrypted, device-only storage of resume versions (F6).
abstract interface class VaultRepository {
  Future<Result<List<VaultItem>>> listItems();

  /// Encrypts and stores a new version of [resume] in [folder].
  Future<Result<VaultItem>> saveResume(Resume resume, {required String folder});

  /// Decrypts one version. Only call after the user has authenticated.
  Future<Result<Resume>> openItem(String id);

  /// Writes a decrypted export file and returns its path.
  Future<Result<String>> exportItem(String id);

  Future<Result<void>> moveItem(String id, String folder);

  Future<Result<void>> deleteItem(String id);

  /// Removes every vault file and the encryption key (account deletion).
  Future<Result<void>> deleteAll();
}
