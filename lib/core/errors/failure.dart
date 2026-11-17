/// The kind of a [Failure]. Screens use it to choose a message and an action.
enum FailureKind {
  network,
  offline,
  timeout,
  auth,
  permission,
  notFound,
  validation,
  quota,
  invalidResponse,
  emptyResponse,
  notConfigured,
  consentRequired,
  storage,
  cancelled,
  unknown,
}

/// A typed, user-presentable error. Never put resume contents in [message].
class Failure implements Exception {
  const Failure(this.kind, this.message, {this.cause});

  const Failure.network([String message = 'A network error occurred.'])
      : this(FailureKind.network, message);
  const Failure.offline([
    String message = 'You appear to be offline. Check your connection.',
  ]) : this(FailureKind.offline, message);
  const Failure.timeout([String message = 'The request took too long.'])
      : this(FailureKind.timeout, message);
  const Failure.auth(String message) : this(FailureKind.auth, message);
  const Failure.permission(String message)
      : this(FailureKind.permission, message);
  const Failure.notFound([String message = 'The item could not be found.'])
      : this(FailureKind.notFound, message);
  const Failure.validation(String message)
      : this(FailureKind.validation, message);
  const Failure.storage([String message = 'Could not save your data.'])
      : this(FailureKind.storage, message);
  const Failure.unknown([String message = 'Something went wrong.'])
      : this(FailureKind.unknown, message);

  final FailureKind kind;
  final String message;
  final Object? cause;

  @override
  String toString() => 'Failure(${kind.name}): $message';
}
