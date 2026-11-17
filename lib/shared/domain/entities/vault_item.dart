import 'map_utils.dart';

/// Metadata for one encrypted resume version in the local vault.
/// The resume contents themselves only exist encrypted on disk.
class VaultItem {
  const VaultItem({
    required this.id,
    required this.title,
    required this.folder,
    required this.version,
    required this.createdAt,
    this.sourceResumeId,
    this.sizeBytes = 0,
  });

  final String id;
  final String title;
  final String folder;

  /// Increases each time the same resume is saved to the vault again.
  final int version;
  final String? sourceResumeId;
  final int sizeBytes;
  final DateTime createdAt;

  VaultItem copyWith({String? folder}) => VaultItem(
        id: id,
        title: title,
        folder: folder ?? this.folder,
        version: version,
        createdAt: createdAt,
        sourceResumeId: sourceResumeId,
        sizeBytes: sizeBytes,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'folder': folder,
        'version': version,
        'sourceResumeId': sourceResumeId,
        'sizeBytes': sizeBytes,
        'createdAt': dateToStr(createdAt),
      };

  factory VaultItem.fromMap(Map<String, Object?> m) => VaultItem(
        id: str(m['id']),
        title: str(m['title']),
        folder: str(m['folder'], 'General'),
        version: intOf(m['version'], 1),
        sourceResumeId: strOrNull(m['sourceResumeId']),
        sizeBytes: intOf(m['sizeBytes']),
        createdAt: dateOf(m['createdAt']),
      );
}
