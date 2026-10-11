import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';

import '../json.dart';

/// Um registro da trilha de auditoria (`GET /v1/admin/audit`). [action] fica
/// como texto: o enum do servidor cresce a cada marco e a tela traduz o que
/// conhece, mostrando o código cru (em fonte de código) para o que não conhece.
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.occurredAt,
    required this.actorId,
    required this.actorRole,
    required this.action,
    required this.outcome,
    required this.targetType,
    required this.targetId,
    this.before,
    this.after,
    this.reason,
    this.requestId,
    this.ip,
  });

  factory AuditEntry.fromJson(Json json) => AuditEntry(
    id: json.count('id'),
    occurredAt:
        json.time('occurredAt') ?? DateTime.fromMillisecondsSinceEpoch(0),
    actorId: json.count('actorId'),
    actorRole: roleFromWire(json.text('actorRole')),
    action: json.text('action'),
    outcome: json.text('outcome'),
    targetType: json.text('targetType'),
    targetId: json.text('targetId'),
    before: json.obj('before'),
    after: json.obj('after'),
    reason: json.str('reason'),
    requestId: json.str('requestId'),
    ip: json.str('ip'),
  );

  final int id;
  final DateTime occurredAt;
  final int actorId;
  final Role actorRole;
  final String action;
  final String outcome;
  final String targetType;
  final String targetId;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final String? reason;
  final String? requestId;
  final String? ip;

  bool get denied => outcome == 'DENIED';
  bool get hasDiff => before != null || after != null;
}

/// Filtros da consulta de auditoria (todos opcionais).
typedef AuditQuery = ({
  int? actorId,
  String? action,
  String? targetType,
  String? targetId,
  String? outcome,
  DateTime? from,
  DateTime? to,
  String? cursor,
  int size,
});

/// As diferenças entre `before` e `after`, campo a campo, para o "antes e
/// depois" legível. Cada linha diz o que mudou: criado, alterado ou removido.
enum AuditChangeKind { added, changed, removed, unchanged }

class AuditChange {
  const AuditChange(this.field, this.kind, this.before, this.after);

  final String field;
  final AuditChangeKind kind;
  final Object? before;
  final Object? after;
}

List<AuditChange> diffAudit(
  Map<String, dynamic>? before,
  Map<String, dynamic>? after,
) {
  final keys = {...?before?.keys, ...?after?.keys}.toList()..sort();
  return [
    for (final key in keys)
      () {
        final hasBefore = before?.containsKey(key) ?? false;
        final hasAfter = after?.containsKey(key) ?? false;
        final b = before?[key];
        final a = after?[key];
        if (!hasBefore) {
          return AuditChange(key, AuditChangeKind.added, null, a);
        }
        if (!hasAfter) {
          return AuditChange(key, AuditChangeKind.removed, b, null);
        }
        return AuditChange(
          key,
          '$b' == '$a' ? AuditChangeKind.unchanged : AuditChangeKind.changed,
          b,
          a,
        );
      }(),
  ];
}
