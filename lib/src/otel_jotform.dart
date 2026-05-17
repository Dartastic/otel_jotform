// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_jotform_suppression.dart';

class JotformResult {
  const JotformResult({
    this.accountId,
    this.formId,
    this.formTitle,
    this.submissionId,
    this.status,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? accountId;
  final String? formId;
  final String? formTitle;
  final String? submissionId;
  final String? status;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class JotformCallResult<T> {
  const JotformCallResult({required this.value, this.result});
  final T value;
  final JotformResult? result;
}

Future<T> tracedJotform<T>({
  required String operation,
  required Future<JotformCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (jotformInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_jotform');
  final span = t.startSpan('jotform $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('rpc.system', 'jotform');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.accountId != null) {
        span.setStringAttribute('jotform.account.id', res.accountId!);
      }
      if (res.formId != null) {
        span.setStringAttribute('jotform.form.id', res.formId!);
      }
      if (res.formTitle != null) {
        span.setStringAttribute('jotform.form.title', res.formTitle!);
      }
      if (res.submissionId != null) {
        span.setStringAttribute('jotform.submission.id', res.submissionId!);
      }
      if (res.status != null) {
        span.setStringAttribute('jotform.submission.status', res.status!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('jotform.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'jotform.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
