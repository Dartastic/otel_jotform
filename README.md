# otel_jotform

Dartastic OpenTelemetry bridge for Jotform (form builder).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_jotform/otel_jotform.dart';

await tracedJotform<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return JotformCallResult(value: r, result: JotformResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutJotformInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
