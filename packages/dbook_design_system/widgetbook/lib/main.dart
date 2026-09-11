import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const DbookWidgetbook());
}

class DbookWidgetbook extends StatelessWidget {
  const DbookWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Claro', data: DbookTheme.light),
            WidgetbookTheme(name: 'Escuro', data: DbookTheme.dark),
          ],
        ),
      ],
      directories: [
        WidgetbookCategory(
          name: 'Ação',
          children: [
            WidgetbookComponent(
              name: 'DbookButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Primário',
                  builder: (context) =>
                      DbookButton(label: 'Buscar voos', onPressed: () {}),
                ),
                WidgetbookUseCase(
                  name: 'Carregando',
                  builder: (context) => const DbookButton(
                    label: 'Confirmar',
                    onPressed: null,
                    isLoading: true,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookSearchField',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => DbookSearchField(
                    controller: TextEditingController(),
                    hintText: 'Para onde você vai?',
                    onSubmitted: (_) {},
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Formulário',
          children: [
            WidgetbookComponent(
              name: 'DbookLegendItem',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => const DbookLegendItem(
                    label: 'Selecionado',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookSocialLoginRow',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => DbookSocialLoginRow(
                    buttons: [
                      DbookSocialLoginButton(
                        icon: Icons.g_mobiledata,
                        label: 'Google',
                        onPressed: () {},
                      ),
                      DbookSocialLoginButton(
                        icon: Icons.apple,
                        label: 'Apple',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Exibição de dados',
          children: [
            WidgetbookComponent(
              name: 'DbookAvatar',
              useCases: [
                WidgetbookUseCase(
                  name: 'Iniciais',
                  builder: (context) => const DbookAvatar(
                    initials: 'DB',
                    size: DbookAvatarSize.large,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookStatusBadge',
              useCases: [
                WidgetbookUseCase(
                  name: 'Confirmado',
                  builder: (context) => const DbookStatusBadge(
                    status: DbookStatus.confirmed,
                    label: 'Confirmado',
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookDestinationCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => SizedBox(
                    height: 160,
                    child: DbookDestinationCard(
                      title: 'Madri, Espanha',
                      subtitle: 'a partir de R\$480',
                      background: const BoxDecoration(color: Colors.blue),
                      onTap: () {},
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookFlightResultTile',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => const DbookFlightResultTile(
                    airlineName: 'Iberia',
                    flightNumber: 'IB 6821',
                    departureTime: '10:30',
                    departureAirport: 'GRU',
                    arrivalTime: '06:45',
                    arrivalAirport: 'MAD',
                    durationLabel: '2h 15m',
                    price: '\$450',
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookFareDateStrip',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => DbookFareDateStrip(
                    options: const [
                      DbookFareDateOption(
                        dayLabel: 'Sun',
                        dateLabel: '11',
                        price: '\$529',
                      ),
                      DbookFareDateOption(
                        dayLabel: 'Mon',
                        dateLabel: '12',
                        price: '\$499',
                      ),
                    ],
                    selectedIndex: 0,
                    onSelected: (_) {},
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookSeatCell',
              useCases: [
                WidgetbookUseCase(
                  name: 'Selecionado',
                  builder: (context) =>
                      const DbookSeatCell(state: DbookSeatState.selected),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookQrPlaceholder',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => const DbookQrPlaceholder(),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookPriceDisplay',
              useCases: [
                WidgetbookUseCase(
                  name: 'Com legenda',
                  builder: (context) => const DbookPriceDisplay(
                    amount: 'R\$ 612',
                    caption: 'por pessoa',
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookNotificationBadge',
              useCases: [
                WidgetbookUseCase(
                  name: 'Com contador',
                  builder: (context) => const DbookNotificationBadge(
                    count: 3,
                    child: Icon(Icons.notifications_outlined),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookPricedListItem',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => const DbookPricedListItem(
                    icon: Icons.event_seat_outlined,
                    title: 'Seat Selection',
                    subtitle: 'Choose your seat',
                    price: '\$15',
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookSummaryRow',
              useCases: [
                WidgetbookUseCase(
                  name: 'Total',
                  builder: (context) => const DbookSummaryRow(
                    label: 'Total',
                    value: '\$585',
                    emphasize: true,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookTripSummaryCard',
              useCases: [
                WidgetbookUseCase(
                  name: 'Cheio',
                  builder: (context) => const DbookTripSummaryCard(
                    origin: 'São Paulo (GRU)',
                    destination: 'Madrid (MAD)',
                    dateRangeLabel: 'Jan 13 - Jan 30, 2026',
                    passengersLabel: '1 Adult, Economy',
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Compacto',
                  builder: (context) => const DbookTripSummaryCard(
                    origin: 'GRU',
                    destination: 'MAD',
                    dateRangeLabel: 'Jan 13 - Jan 30',
                    passengersLabel: '1 Adult',
                    compact: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Navegação e estrutura',
          children: [
            WidgetbookComponent(
              name: 'DbookAppBar',
              useCases: [
                WidgetbookUseCase(
                  name: 'Com subtítulo',
                  builder: (context) => const DbookAppBar(
                    title: 'Madrid, Spain',
                    subtitle: 'Tue, Jan 13, 2026',
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookSectionLabel',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => const DbookSectionLabel(
                    text: 'Sugestões pra você',
                    icon: Icons.star_outline,
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookDashedDivider',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => const DbookDashedDivider(),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Feedback',
          children: [
            WidgetbookComponent(
              name: 'DbookLoadingIndicator',
              useCases: [
                WidgetbookUseCase(
                  name: 'Com mensagem',
                  builder: (context) =>
                      const DbookLoadingIndicator(message: 'Buscando voos...'),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookStatusPlaceholder',
              useCases: [
                WidgetbookUseCase(
                  name: 'Vazio',
                  builder: (context) => const DbookStatusPlaceholder(
                    icon: Icons.search_off,
                    title: 'Nenhum voo encontrado',
                    message: 'Tente outra data ou destino.',
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookInlineStatusBanner',
              useCases: [
                WidgetbookUseCase(
                  name: 'Info',
                  builder: (context) => const DbookInlineStatusBanner(
                    message: 'Disponibilidade em tempo real',
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookSuccessScreen',
              useCases: [
                WidgetbookUseCase(
                  name: 'Confirmação de reserva',
                  builder: (context) => const DbookSuccessScreen(
                    title: 'Booking Confirmed!',
                    message: 'Your flight to Madrid is all set.',
                    referenceLabel: 'Booking Reference',
                    referenceValue: 'HF123456',
                    primaryActionLabel: 'View My Trip',
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Overlays',
          children: [
            WidgetbookComponent(
              name: 'DbookConfirmationDialog',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => Center(
                    child: DbookButton(
                      label: 'Abrir dialog',
                      onPressed: () => showDbookConfirmationDialog(
                        context,
                        title: 'Cancelar reserva?',
                        message: 'Essa ação não pode ser desfeita.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookPageIndicator',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => const ColoredBox(
                    color: Colors.black87,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: DbookPageIndicator(pageCount: 3, currentIndex: 1),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'DbookOnboardingSlide',
              useCases: [
                WidgetbookUseCase(
                  name: 'Padrão',
                  builder: (context) => DbookOnboardingSlide(
                    background: const ColoredBox(color: Colors.blue),
                    title: 'Discover New Horizons',
                    subtitle: 'Find and book the best flights.',
                    pageCount: 3,
                    currentIndex: 0,
                    primaryActionLabel: 'Next',
                    onPrimaryAction: () {},
                    onSkip: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
