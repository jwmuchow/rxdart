import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

void main() {
  test('rx.Observable.materialize.happyPath', () async {
    final observable = new Observable.just(1);
    final notifications = <Notification<int>>[];

    observable.materialize().listen(notifications.add, onDone: expectAsync0(() {
      expect(notifications,
          [new Notification.onData(1), new Notification<int>.onDone()]);
    }));
  });

  test('rx.Observable.materialize.reusable', () async {
    final transformer = new MaterializeStreamTransformer<int>();
    final observable = new Observable.just(1).asBroadcastStream();
    final notificationsA = <Notification<int>>[],
        notificationsB = <Notification<int>>[];

    observable.transform(transformer).listen(notificationsA.add,
        onDone: expectAsync0(() {
      expect(notificationsA,
          [new Notification.onData(1), new Notification<int>.onDone()]);
    }));

    observable.transform(transformer).listen(notificationsB.add,
        onDone: expectAsync0(() {
      expect(notificationsB,
          [new Notification.onData(1), new Notification<int>.onDone()]);
    }));
  });

  test('materializeTransformer.happyPath', () async {
    final stream = new Stream.fromIterable(const [1]);
    final notifications = <Notification<int>>[];

    stream
        .transform(new MaterializeStreamTransformer<int>())
        .listen(notifications.add, onDone: expectAsync0(() {
      expect(notifications,
          [new Notification.onData(1), new Notification<int>.onDone()]);
    }));
  });

  test('materializeTransformer.sadPath', () async {
    final stream = new ErrorStream<int>(new Exception());
    final notifications = <Notification<int>>[];

    stream
        .transform(new MaterializeStreamTransformer<int>())
        .listen(notifications.add,
            onError: expectAsync2((Exception e, StackTrace s) {
              // Check to ensure the stream does not come to this point
              expect(true, isFalse);
            }, count: 0), onDone: expectAsync0(() {
      expect(notifications.length, 2);
      expect(notifications[0].isOnError, isTrue);
      expect(notifications[1].isOnDone, isTrue);
    }));
  });

  test('materializeTransformer.onPause.onResume', () async {
    final stream = new Stream.fromIterable(const [1]);
    final notifications = <Notification<int>>[];

    stream
        .transform(new MaterializeStreamTransformer<int>())
        .listen(notifications.add, onDone: expectAsync0(() {
      expect(notifications, <Notification<int>>[
        new Notification.onData(1),
        new Notification<int>.onDone()
      ]);
    }))
          ..pause()
          ..resume();
  });
}
