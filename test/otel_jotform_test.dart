// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_jotform/otel_jotform.dart';
import 'package:test/test.dart';

void main() {
  group('otel_jotform', () {
    test('suppression toggles in zone', () async {
      expect(jotformInstrumentationSuppressed(), isFalse);
      await runWithoutJotformInstrumentationAsync(() async {
        expect(jotformInstrumentationSuppressed(), isTrue);
      });
      expect(jotformInstrumentationSuppressed(), isFalse);
    });

    test('JotformResult fields default null', () {
      const r = JotformResult();
      expect(r.statusCode, isNull);
    });
  });
}
