// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

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
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'jotform')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.accountId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('jotform.account.id', res.accountId!)]));
      }
      if (res.formId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('jotform.form.id', res.formId!)]));
      }
      if (res.formTitle != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('jotform.form.title', res.formTitle!)]));
      }
      if (res.submissionId != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('jotform.submission.id', res.submissionId!)
        ]));
      }
      if (res.status != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('jotform.submission.status', res.status!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('jotform.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
            res.errorCode ?? 'jotform.error',
          )
        ]));
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
