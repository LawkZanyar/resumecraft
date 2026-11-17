import 'map_utils.dart';

/// The signed-in account, as reported by the authentication provider.
class AuthUser {
  const AuthUser({required this.uid, required this.email, this.displayName});

  final String uid;
  final String email;
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      other is AuthUser && other.uid == uid && other.email == email;

  @override
  int get hashCode => Object.hash(uid, email);
}

/// `users` collection document.
class UserProfile {
  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.profileImage,
    this.location,
    this.aiConsentAt,
  });

  final String userId;
  final String fullName;
  final String email;

  /// Local file reference or null; the UI falls back to initials.
  final String? profileImage;
  final String? location;

  /// When the user agreed to send resume text to AI; null means no consent.
  final DateTime? aiConsentAt;
  final DateTime createdAt;

  bool get hasAiConsent => aiConsentAt != null;

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? profileImage,
    String? location,
    DateTime? aiConsentAt,
    bool clearAiConsent = false,
    bool clearProfileImage = false,
  }) =>
      UserProfile(
        userId: userId,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        profileImage: clearProfileImage ? null : profileImage ?? this.profileImage,
        location: location ?? this.location,
        aiConsentAt: clearAiConsent ? null : aiConsentAt ?? this.aiConsentAt,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'profileImage': profileImage,
        'location': location,
        'aiConsentAt': dateToStr(aiConsentAt),
        'createdAt': dateToStr(createdAt),
      };

  factory UserProfile.fromMap(Map<String, Object?> m) => UserProfile(
        userId: str(m['userId']),
        fullName: str(m['fullName']),
        email: str(m['email']),
        profileImage: strOrNull(m['profileImage']),
        location: strOrNull(m['location']),
        aiConsentAt: dateOrNull(m['aiConsentAt']),
        createdAt: dateOf(m['createdAt']),
      );
}
