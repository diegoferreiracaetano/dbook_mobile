/// Permissão de ação — espelha `Permission` do backend. O front só a usa para
/// mostrar ou esconder controles; quem autoriza de verdade é o servidor.
enum Permission {
  adminPortalAccess,
  customerRead,
  customerNote,
  customerBlock,
  customerExport,
  customerErase,
  bookingReadAny,
  bookingCancelAny,
  paymentRefund,
  flightRead,
  flightWrite,
  catalogWrite,
  promoWrite,
  reviewModerate,
  dashboardRead,
  auditRead,
  adminManage,
}
