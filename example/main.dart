// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_jotform/otel_jotform.dart';

/// Traces Jotform calls with OpenTelemetry.
///
/// `otel_jotform` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Jotform call in
/// [tracedJotform]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'jotform-example');

  // Traces a Jotform call.
  final jotformId = await tracedJotform<String>(
    operation: 'create',
    invoke: () async {
      // Make the Jotform call here, then report what it returned.
      const id = 'jotform_8f3a2c';
      return const JotformCallResult(
          value: id,
          result: JotformResult(
              accountId: 'account_8f3a2c',
              formId: 'form_8f3a2c',
              formTitle: 'example',
              submissionId: 'submission_8f3a2c',
              status: 'succeeded',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedJotform create returned $jotformId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutJotformInstrumentationAsync.
  await runWithoutJotformInstrumentationAsync(
    () => tracedJotform<String>(
      operation: 'create',
      invoke: () async {
        const id = 'jotform_8f3a2c';
        return const JotformCallResult(
            value: id,
            result: JotformResult(
                accountId: 'account_8f3a2c',
                formId: 'form_8f3a2c',
                formTitle: 'example',
                submissionId: 'submission_8f3a2c',
                status: 'succeeded',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
