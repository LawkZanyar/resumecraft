import 'dart:async';

/// Builds a stream that emits [read]() immediately on listen and again after
/// every event on [changes]. Subscribes synchronously so no change is missed.
/// Used by all in-memory fakes to mimic Firestore snapshot streams.
Stream<T> watchWithInitial<T>(T Function() read, Stream<void> changes) {
  late final StreamController<T> controller;
  StreamSubscription<void>? sub;
  controller = StreamController<T>(
    onListen: () {
      controller.add(read());
      sub = changes.listen((_) => controller.add(read()));
    },
    onCancel: () => sub?.cancel(),
  );
  return controller.stream;
}

/// Simulated network delay for fakes; zero in tests.
Future<void> fakeDelay(Duration latency) =>
    latency == Duration.zero ? Future.value() : Future.delayed(latency);
