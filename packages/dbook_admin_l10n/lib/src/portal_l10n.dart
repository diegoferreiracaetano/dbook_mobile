import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';
import 'portal_formats.dart';

export 'gen/app_localizations.dart';

/// `context.l10n.loginTitle` em vez de `AppLocalizations.of(context)`.
extension PortalL10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Traduz um erro em mensagem para a pessoa, **pelo `code`** do backend.
/// Nunca devolve o texto cru do servidor: ele pode mudar e não é feito para
/// a tela.
String portalErrorMessage(AppLocalizations l10n, Object error) {
  if (error is! DbookNetworkException) return l10n.errGeneric;

  final byCode = switch (error.code) {
    'INVALID_CREDENTIALS' => l10n.errInvalidCredentials,
    'ACCOUNT_BLOCKED' => l10n.errAccountBlocked,
    'INVALID_TWO_FACTOR_CODE' => l10n.errInvalidTwoFactorCode,
    'INVALID_INVITATION' => l10n.errInvalidInvitation,
    'STALE_VERSION' => l10n.errStaleVersion,
    'IDEMPOTENCY_KEY_REUSED' => l10n.errIdempotencyKeyReused,
    'REFUND_WINDOW_CLOSED' => l10n.errRefundWindowClosed,
    'PAYLOAD_TOO_LARGE' => l10n.errPayloadTooLarge,
    'TOO_MANY_ATTEMPTS' => l10n.errTooManyAttempts(error.retryAfter ?? 60),
    'RATE_LIMITED' => l10n.errRateLimited(error.retryAfter ?? 60),
    _ => null,
  };
  if (byCode != null) return byCode;

  return switch (error) {
    DbookValidationException() => l10n.errValidation,
    DbookUnauthorizedException() => l10n.errUnauthorized,
    DbookForbiddenException() => l10n.errForbidden,
    DbookNotFoundException() => l10n.errNotFound,
    DbookConflictException() => l10n.errConflict,
    DbookUnprocessableException() => l10n.errUnprocessable,
    DbookRateLimitException() => l10n.errRateLimited(error.retryAfter ?? 60),
    DbookBadGatewayException() ||
    DbookServiceUnavailableException() => l10n.errServer,
    DbookUnknownNetworkException() => l10n.errNetwork,
  };
}

String roleLabel(AppLocalizations l10n, Role role) => switch (role) {
  Role.client => l10n.roleClient,
  Role.support => l10n.roleSupport,
  Role.catalogManager => l10n.roleCatalogManager,
  Role.superAdmin => l10n.roleSuperAdmin,
  Role.unknown => l10n.roleUnknown,
};

String roleDescription(AppLocalizations l10n, Role role) => switch (role) {
  Role.support => l10n.roleDescSupport,
  Role.catalogManager => l10n.roleDescCatalogManager,
  Role.superAdmin => l10n.roleDescSuperAdmin,
  Role.client || Role.unknown => '',
};

/// O rótulo de uma ação da auditoria; o que o app ainda não conhece aparece
/// como o código cru (o servidor ganha ações a cada marco).
String auditActionLabel(AppLocalizations l10n, String action) =>
    switch (action) {
      'FLIGHT_CREATED' => l10n.auditActionFlightCreated,
      'BOOKING_CANCELLED_BY_STAFF' => l10n.auditActionBookingCancelledByStaff,
      'ACCESS_DENIED' => l10n.auditActionAccessDenied,
      'STAFF_INVITED' => l10n.auditActionStaffInvited,
      'STAFF_INVITATION_RESENT' => l10n.auditActionStaffInvitationResent,
      'STAFF_INVITATION_REVOKED' => l10n.auditActionStaffInvitationRevoked,
      'STAFF_INVITATION_ACCEPTED' => l10n.auditActionStaffInvitationAccepted,
      'STAFF_ROLE_CHANGED' => l10n.auditActionStaffRoleChanged,
      'STAFF_BLOCKED' => l10n.auditActionStaffBlocked,
      'STAFF_UNBLOCKED' => l10n.auditActionStaffUnblocked,
      'CUSTOMER_VIEWED' => l10n.auditActionCustomerViewed,
      'CUSTOMER_BLOCKED' => l10n.auditActionCustomerBlocked,
      'CUSTOMER_UNBLOCKED' => l10n.auditActionCustomerUnblocked,
      'CUSTOMER_NOTE_ADDED' => l10n.auditActionCustomerNoteAdded,
      'CUSTOMER_NOTE_EDITED' => l10n.auditActionCustomerNoteEdited,
      'CUSTOMER_NOTE_DELETED' => l10n.auditActionCustomerNoteDeleted,
      'CUSTOMER_EXPORTED' => l10n.auditActionCustomerExported,
      'CUSTOMER_ANONYMIZED' => l10n.auditActionCustomerAnonymized,
      'CUSTOMER_DATA_EXPORTED' => l10n.auditActionCustomerDataExported,
      'FLIGHT_UPDATED' => l10n.auditActionFlightUpdated,
      'FLIGHT_CANCELLED' => l10n.auditActionFlightCancelled,
      'FLIGHTS_IMPORTED' => l10n.auditActionFlightsImported,
      'AIRLINE_CREATED' => l10n.auditActionAirlineCreated,
      'AIRLINE_UPDATED' => l10n.auditActionAirlineUpdated,
      'AIRLINE_DELETED' => l10n.auditActionAirlineDeleted,
      'AIRPORT_CREATED' => l10n.auditActionAirportCreated,
      'AIRPORT_UPDATED' => l10n.auditActionAirportUpdated,
      'AIRPORT_DELETED' => l10n.auditActionAirportDeleted,
      'REFUND_REQUESTED' => l10n.auditActionRefundRequested,
      'REFUND_RETRIED' => l10n.auditActionRefundRetried,
      'REFUND_COMPLETED' => l10n.auditActionRefundCompleted,
      'REFUND_FAILED' => l10n.auditActionRefundFailed,
      'REVIEW_HIDDEN' => l10n.auditActionReviewHidden,
      'REVIEW_RESTORED' => l10n.auditActionReviewRestored,
      'REVIEW_REPORTS_DISMISSED' => l10n.auditActionReviewReportsDismissed,
      'PROMO_CREATED' => l10n.auditActionPromoCreated,
      'PROMO_UPDATED' => l10n.auditActionPromoUpdated,
      'PROMO_ACTIVATED' => l10n.auditActionPromoActivated,
      'PROMO_DEACTIVATED' => l10n.auditActionPromoDeactivated,
      'ACCOMMODATION_CREATED' => l10n.auditActionAccommodationCreated,
      'ACCOMMODATION_UPDATED' => l10n.auditActionAccommodationUpdated,
      'ACCOMMODATION_ACTIVATED' => l10n.auditActionAccommodationActivated,
      'ACCOMMODATION_DEACTIVATED' => l10n.auditActionAccommodationDeactivated,
      'ROOM_TYPE_CHANGED' => l10n.auditActionRoomTypeChanged,
      'TWO_FACTOR_ENABLED' => l10n.auditActionTwoFactorEnabled,
      'TWO_FACTOR_DISABLED' => l10n.auditActionTwoFactorDisabled,
      'TWO_FACTOR_RESET' => l10n.auditActionTwoFactorReset,
      _ => action,
    };

String bookingStatusLabel(AppLocalizations l10n, BookingStatus status) =>
    switch (status) {
      BookingStatus.pending => l10n.bookingStatusPending,
      BookingStatus.confirmed => l10n.bookingStatusConfirmed,
      BookingStatus.cancelled => l10n.bookingStatusCancelled,
      BookingStatus.expired => l10n.bookingStatusExpired,
      BookingStatus.refunded => l10n.bookingStatusRefunded,
      BookingStatus.unknown => l10n.bookingStatusUnknown,
    };

String refundReasonLabel(AppLocalizations l10n, RefundReason? reason) =>
    switch (reason) {
      RefundReason.customerRequest => l10n.refundReasonCustomerRequest,
      RefundReason.flightCancelled => l10n.refundReasonFlightCancelled,
      RefundReason.duplicate => l10n.refundReasonDuplicate,
      RefundReason.other => l10n.refundReasonOther,
      null => l10n.commonNone,
    };

String refundStatusLabel(AppLocalizations l10n, RefundStatus status) =>
    switch (status) {
      RefundStatus.requested => l10n.refundStatusRequested,
      RefundStatus.completed => l10n.refundStatusCompleted,
      RefundStatus.failed => l10n.refundStatusFailed,
      RefundStatus.unknown => l10n.refundStatusUnknown,
    };

String seatClassLabel(AppLocalizations l10n, SeatClass seatClass) =>
    switch (seatClass) {
      SeatClass.economy => l10n.seatClassEconomy,
      SeatClass.premiumEconomy => l10n.seatClassPremiumEconomy,
      SeatClass.business => l10n.seatClassBusiness,
      SeatClass.first => l10n.seatClassFirst,
      SeatClass.unknown => l10n.seatClassUnknown,
    };

String flightStatusLabel(AppLocalizations l10n, FlightStatus status) =>
    switch (status) {
      FlightStatus.scheduled => l10n.flightStatusScheduled,
      FlightStatus.cancelled => l10n.flightStatusCancelled,
      FlightStatus.unknown => l10n.flightStatusUnknown,
    };

/// As ações de auditoria que o servidor conhece, para o filtro por ação.
const knownAuditActions = <String>[
  'FLIGHT_CREATED',
  'FLIGHT_UPDATED',
  'FLIGHT_CANCELLED',
  'FLIGHTS_IMPORTED',
  'BOOKING_CANCELLED_BY_STAFF',
  'REFUND_REQUESTED',
  'REFUND_RETRIED',
  'REFUND_COMPLETED',
  'REFUND_FAILED',
  'CUSTOMER_VIEWED',
  'CUSTOMER_BLOCKED',
  'CUSTOMER_UNBLOCKED',
  'CUSTOMER_NOTE_ADDED',
  'CUSTOMER_NOTE_EDITED',
  'CUSTOMER_NOTE_DELETED',
  'CUSTOMER_EXPORTED',
  'CUSTOMER_ANONYMIZED',
  'CUSTOMER_DATA_EXPORTED',
  'STAFF_INVITED',
  'STAFF_INVITATION_RESENT',
  'STAFF_INVITATION_REVOKED',
  'STAFF_INVITATION_ACCEPTED',
  'STAFF_ROLE_CHANGED',
  'STAFF_BLOCKED',
  'STAFF_UNBLOCKED',
  'AIRLINE_CREATED',
  'AIRLINE_UPDATED',
  'AIRLINE_DELETED',
  'AIRPORT_CREATED',
  'AIRPORT_UPDATED',
  'AIRPORT_DELETED',
  'REVIEW_HIDDEN',
  'REVIEW_RESTORED',
  'REVIEW_REPORTS_DISMISSED',
  'PROMO_CREATED',
  'PROMO_UPDATED',
  'PROMO_ACTIVATED',
  'PROMO_DEACTIVATED',
  'ACCOMMODATION_CREATED',
  'ACCOMMODATION_UPDATED',
  'ACCOMMODATION_ACTIVATED',
  'ACCOMMODATION_DEACTIVATED',
  'ROOM_TYPE_CHANGED',
  'TWO_FACTOR_ENABLED',
  'TWO_FACTOR_DISABLED',
  'TWO_FACTOR_RESET',
  'ACCESS_DENIED',
];

/// A regra de um código em linguagem natural ("10% de desconto, em compras a
/// partir de R$ 500,00, até 100 usos, 1 por cliente").
String describePromo(AppLocalizations l10n, Promo promo) {
  final base = promo.type == PromoType.percent
      ? l10n.promoRulePercent(
          promo.value == promo.value.roundToDouble()
              ? promo.value.round().toString()
              : promo.value.toString(),
        )
      : l10n.promoRuleFixed(PortalFormats.money(promo.value));
  return [
    base,
    if (promo.minAmount > 0)
      l10n.promoRuleMin(PortalFormats.money(promo.minAmount)),
    if (promo.maxRedemptions != null) l10n.promoRuleMax(promo.maxRedemptions!),
    l10n.promoRulePerUser(promo.maxPerUser),
  ].join(', ');
}
