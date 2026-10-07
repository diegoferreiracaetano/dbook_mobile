import 'package:dbook_domain/dbook_domain.dart';

/// Chamado quando o servidor manda um valor que este app ainda não conhece.
/// O `main` de cada app liga isto ao registro de erros; por padrão não faz nada.
void Function(String enumName, String value) onUnknownWireValue = (_, _) {};

T _unknown<T>(String enumName, String value, T fallback) {
  onUnknownWireValue(enumName, value);
  return fallback;
}

/// Os enums do domínio são Dart puro (sem `json_serializable`, de
/// propósito — serialização é preocupação de `dbook_core_network`, não do
/// domínio). Essas funções traduzem o valor de fio (`UPPER_SNAKE_CASE`,
/// igual ao nome do enum Kotlin no backend) pro enum Dart correspondente.
Role roleFromWire(String value) => switch (value) {
  'CLIENT' => Role.client,
  'SUPPORT' => Role.support,
  'CATALOG_MANAGER' => Role.catalogManager,
  'SUPER_ADMIN' => Role.superAdmin,
  _ => _unknown('Role', value, Role.unknown),
};

/// Uma permissão que o app não conhece não tem controle correspondente na
/// tela: some da lista (e é reportada) em vez de virar um valor fantasma.
Set<Permission> permissionsFromWire(Iterable<String> values) {
  final byWire = const {
    'ADMIN_PORTAL_ACCESS': Permission.adminPortalAccess,
    'CUSTOMER_READ': Permission.customerRead,
    'CUSTOMER_NOTE': Permission.customerNote,
    'CUSTOMER_BLOCK': Permission.customerBlock,
    'CUSTOMER_EXPORT': Permission.customerExport,
    'CUSTOMER_ERASE': Permission.customerErase,
    'BOOKING_READ_ANY': Permission.bookingReadAny,
    'BOOKING_CANCEL_ANY': Permission.bookingCancelAny,
    'PAYMENT_REFUND': Permission.paymentRefund,
    'FLIGHT_READ': Permission.flightRead,
    'FLIGHT_WRITE': Permission.flightWrite,
    'CATALOG_WRITE': Permission.catalogWrite,
    'PROMO_WRITE': Permission.promoWrite,
    'REVIEW_MODERATE': Permission.reviewModerate,
    'DASHBOARD_READ': Permission.dashboardRead,
    'AUDIT_READ': Permission.auditRead,
    'ADMIN_MANAGE': Permission.adminManage,
  };
  final result = <Permission>{};
  for (final value in values) {
    final permission = byWire[value];
    if (permission == null) {
      onUnknownWireValue('Permission', value);
    } else {
      result.add(permission);
    }
  }
  return result;
}

SeatClass seatClassFromWire(String value) => switch (value) {
  'ECONOMY' => SeatClass.economy,
  'PREMIUM_ECONOMY' => SeatClass.premiumEconomy,
  'BUSINESS' => SeatClass.business,
  'FIRST' => SeatClass.first,
  _ => _unknown('SeatClass', value, SeatClass.unknown),
};

SeatStatus seatStatusFromWire(String value) => switch (value) {
  'AVAILABLE' => SeatStatus.available,
  'RESERVED' => SeatStatus.reserved,
  _ => _unknown('SeatStatus', value, SeatStatus.unknown),
};

BookingStatus bookingStatusFromWire(String value) => switch (value) {
  'PENDING' => BookingStatus.pending,
  'CONFIRMED' => BookingStatus.confirmed,
  'CANCELLED' => BookingStatus.cancelled,
  _ => _unknown('BookingStatus', value, BookingStatus.unknown),
};
