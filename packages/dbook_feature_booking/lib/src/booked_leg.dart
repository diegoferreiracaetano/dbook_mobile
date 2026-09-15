import 'package:dbook_domain/dbook_domain.dart';

/// Um trecho já reservado (assento confirmado) durante a jornada de
/// escolher voo(s) → escolher assento(s) → revisar e pagar. Acumulado por
/// quem monta a seleção de assento (ver `SeatSelectionPage.onBooked`) e
/// consumido pela revisão/pagamento final — um `record`, não uma classe
/// própria, porque é só os três dados já existentes juntos, sem
/// comportamento novo.
typedef BookedLeg = ({Booking booking, Flight flight, Seat seat});
