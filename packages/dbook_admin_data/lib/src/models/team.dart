import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';

import '../json.dart';

/// O valor de fio de um papel (`SUPPORT`...), para convidar e mudar papel.
String roleToWire(Role role) => switch (role) {
  Role.client => 'CLIENT',
  Role.support => 'SUPPORT',
  Role.catalogManager => 'CATALOG_MANAGER',
  Role.superAdmin => 'SUPER_ADMIN',
  Role.unknown => 'UNKNOWN',
};

/// Os papéis que um convite pode dar (a equipe; nunca `CLIENT`).
const invitableRoles = [Role.support, Role.catalogManager, Role.superAdmin];

enum StaffStatus { active, blocked, unknown }

StaffStatus _staffStatus(String value) => switch (value) {
  'ACTIVE' => StaffStatus.active,
  'BLOCKED' => StaffStatus.blocked,
  _ => () {
    onUnknownWireValue('StaffStatus', value);
    return StaffStatus.unknown;
  }(),
};

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.blockedReason,
    this.lastLoginAt,
  });

  factory StaffMember.fromJson(Json json) => StaffMember(
    id: json.count('id'),
    name: json.text('name'),
    email: json.text('email'),
    role: roleFromWire(json.text('role')),
    status: _staffStatus(json.text('status')),
    blockedReason: json.str('blockedReason'),
    lastLoginAt: json.time('lastLoginAt'),
  );

  final int id;
  final String name;
  final String email;
  final Role role;
  final StaffStatus status;
  final String? blockedReason;
  final DateTime? lastLoginAt;

  bool get isBlocked => status == StaffStatus.blocked;
}

enum InvitationStatus { pending, accepted, expired, revoked, unknown }

InvitationStatus _invitationStatus(String value) => switch (value) {
  'PENDING' => InvitationStatus.pending,
  'ACCEPTED' => InvitationStatus.accepted,
  'EXPIRED' => InvitationStatus.expired,
  'REVOKED' => InvitationStatus.revoked,
  _ => () {
    onUnknownWireValue('InvitationStatus', value);
    return InvitationStatus.unknown;
  }(),
};

class Invitation {
  const Invitation({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.invitedBy,
    this.createdAt,
    this.expiresAt,
  });

  factory Invitation.fromJson(Json json) => Invitation(
    id: json.count('id'),
    email: json.text('email'),
    role: roleFromWire(json.text('role')),
    status: _invitationStatus(json.text('status')),
    invitedBy: json.integer('invitedBy'),
    createdAt: json.time('createdAt'),
    expiresAt: json.time('expiresAt'),
  );

  final int id;
  final String email;
  final Role role;
  final InvitationStatus status;
  final int? invitedBy;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  /// Só um convite em aberto pode ser reenviado ou cancelado.
  bool get isOpen => status == InvitationStatus.pending;
}
