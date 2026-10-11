import 'package:dbook_admin_data/dbook_admin_data.dart';
import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';

/// Uma entrada do menu. Só aparece para quem tem [permission] (`null` = todo
/// membro da equipe); a rota correspondente leva a "sem acesso" para quem não
/// tem. Quem autoriza de verdade é sempre o servidor.
class PortalDestination {
  const PortalDestination({
    required this.path,
    required this.icon,
    required this.label,
    this.permission,
  });

  final String path;
  final IconData icon;
  final String Function(AppLocalizations l10n) label;
  final Permission? permission;
}

/// O menu do portal, na ordem em que aparece.
final portalDestinations = <PortalDestination>[
  PortalDestination(
    path: '/',
    icon: Icons.home_outlined,
    label: (l) => l.homeWelcomeTitle,
  ),
  PortalDestination(
    path: '/dashboard',
    icon: Icons.insights_outlined,
    label: (l) => l.navDashboard,
    permission: Permission.dashboardRead,
  ),
  PortalDestination(
    path: '/customers',
    icon: Icons.people_outline,
    label: (l) => l.navCustomers,
    permission: Permission.customerRead,
  ),
  PortalDestination(
    path: '/bookings',
    icon: Icons.confirmation_number_outlined,
    label: (l) => l.navBookings,
    permission: Permission.bookingReadAny,
  ),
  PortalDestination(
    path: '/refunds',
    icon: Icons.currency_exchange,
    label: (l) => l.navRefunds,
    permission: Permission.paymentRefund,
  ),
  PortalDestination(
    path: '/flights',
    icon: Icons.flight_outlined,
    label: (l) => l.navFlights,
    permission: Permission.flightRead,
  ),
  PortalDestination(
    path: '/airlines',
    icon: Icons.airlines_outlined,
    label: (l) => l.navAirlines,
    permission: Permission.flightRead,
  ),
  PortalDestination(
    path: '/airports',
    icon: Icons.location_city_outlined,
    label: (l) => l.navAirports,
    permission: Permission.flightRead,
  ),
  PortalDestination(
    path: '/reviews',
    icon: Icons.rate_review_outlined,
    label: (l) => l.navReviews,
    permission: Permission.reviewModerate,
  ),
  PortalDestination(
    path: '/promos',
    icon: Icons.local_offer_outlined,
    label: (l) => l.navPromos,
    permission: Permission.promoWrite,
  ),
  PortalDestination(
    path: '/audit',
    icon: Icons.fact_check_outlined,
    label: (l) => l.navAudit,
    permission: Permission.auditRead,
  ),
  PortalDestination(
    path: '/team',
    icon: Icons.admin_panel_settings_outlined,
    label: (l) => l.navTeam,
    permission: Permission.adminManage,
  ),
];

/// A destinação a que um endereço pertence (`/customers/12` é `/customers`).
PortalDestination? destinationFor(String location) {
  final path = Uri.parse(location).path;
  PortalDestination? best;
  for (final destination in portalDestinations) {
    final matches = destination.path == '/'
        ? path == '/'
        : path == destination.path || path.startsWith('${destination.path}/');
    if (matches &&
        (best == null || destination.path.length > best.path.length)) {
      best = destination;
    }
  }
  return best;
}

/// As entradas do menu que quem está logado pode ver. Sem perfil, nenhuma.
List<PortalDestination> visibleDestinations(StaffProfile? profile) => [
  if (profile != null)
    for (final destination in portalDestinations)
      if (destination.permission == null ||
          profile.can(destination.permission!))
        destination,
];
