import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'DBook Admin'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get commonClose;

  /// No description provided for @commonBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get commonBack;

  /// No description provided for @commonLoading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando…'**
  String get commonLoading;

  /// No description provided for @commonSearch.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get commonSearch;

  /// No description provided for @commonClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get commonClear;

  /// No description provided for @commonNone.
  ///
  /// In pt, this message translates to:
  /// **'—'**
  String get commonNone;

  /// No description provided for @commonYes.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get commonNo;

  /// No description provided for @commonCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get commonCopy;

  /// No description provided for @commonCopied.
  ///
  /// In pt, this message translates to:
  /// **'Copiado'**
  String get commonCopied;

  /// No description provided for @commonDownload.
  ///
  /// In pt, this message translates to:
  /// **'Baixar'**
  String get commonDownload;

  /// No description provided for @commonNext.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get commonNext;

  /// No description provided for @commonEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get commonDelete;

  /// No description provided for @commonCreate.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get commonCreate;

  /// No description provided for @commonSending.
  ///
  /// In pt, this message translates to:
  /// **'Enviando…'**
  String get commonSending;

  /// No description provided for @commonDismiss.
  ///
  /// In pt, this message translates to:
  /// **'Dispensar'**
  String get commonDismiss;

  /// No description provided for @commonTryOtherFilters.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste os filtros e tente de novo.'**
  String get commonTryOtherFilters;

  /// No description provided for @commonNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado'**
  String get commonNoResults;

  /// No description provided for @commonSomethingWrong.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado'**
  String get commonSomethingWrong;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos.'**
  String get errInvalidCredentials;

  /// No description provided for @errAccountBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Esta conta está bloqueada. Fale com um administrador.'**
  String get errAccountBlocked;

  /// No description provided for @errInvalidTwoFactorCode.
  ///
  /// In pt, this message translates to:
  /// **'Código incorreto ou já usado. Confira o autenticador e tente de novo.'**
  String get errInvalidTwoFactorCode;

  /// No description provided for @errInvalidInvitation.
  ///
  /// In pt, this message translates to:
  /// **'Este convite não é válido. Peça um novo a um administrador.'**
  String get errInvalidInvitation;

  /// No description provided for @errForbidden.
  ///
  /// In pt, this message translates to:
  /// **'Você não tem permissão para fazer isso.'**
  String get errForbidden;

  /// No description provided for @errUnauthorized.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão terminou. Entre de novo.'**
  String get errUnauthorized;

  /// No description provided for @errNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Não encontramos o que você procura.'**
  String get errNotFound;

  /// No description provided for @errConflict.
  ///
  /// In pt, this message translates to:
  /// **'A situação mudou desde que você abriu esta tela. Recarregue e tente de novo.'**
  String get errConflict;

  /// No description provided for @errStaleVersion.
  ///
  /// In pt, this message translates to:
  /// **'Outra pessoa alterou este registro antes de você.'**
  String get errStaleVersion;

  /// No description provided for @errValidation.
  ///
  /// In pt, this message translates to:
  /// **'Confira os dados informados.'**
  String get errValidation;

  /// No description provided for @errPayloadTooLarge.
  ///
  /// In pt, this message translates to:
  /// **'O arquivo ou o pedido é grande demais.'**
  String get errPayloadTooLarge;

  /// No description provided for @errUnprocessable.
  ///
  /// In pt, this message translates to:
  /// **'O pedido não pôde ser concluído com esses dados.'**
  String get errUnprocessable;

  /// No description provided for @errIdempotencyKeyReused.
  ///
  /// In pt, this message translates to:
  /// **'Esta tentativa já foi usada para outro pedido. Comece de novo.'**
  String get errIdempotencyKeyReused;

  /// No description provided for @errServer.
  ///
  /// In pt, this message translates to:
  /// **'O servidor não conseguiu responder. Tente de novo em instantes.'**
  String get errServer;

  /// No description provided for @errNetwork.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com o servidor. Confira a rede e tente de novo.'**
  String get errNetwork;

  /// No description provided for @errGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir. Tente de novo.'**
  String get errGeneric;

  /// No description provided for @errRefundWindowClosed.
  ///
  /// In pt, this message translates to:
  /// **'Faltam menos de 24 horas para a partida: o reembolso não é mais possível.'**
  String get errRefundWindowClosed;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Tente de novo em {seconds} s.'**
  String errTooManyAttempts(int seconds);

  /// No description provided for @errRateLimited.
  ///
  /// In pt, this message translates to:
  /// **'Muitas chamadas em pouco tempo. Tente de novo em {seconds} s.'**
  String errRateLimited(int seconds);

  /// No description provided for @navDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Painel'**
  String get navDashboard;

  /// No description provided for @navCustomers.
  ///
  /// In pt, this message translates to:
  /// **'Clientes'**
  String get navCustomers;

  /// No description provided for @navBookings.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get navBookings;

  /// No description provided for @navRefunds.
  ///
  /// In pt, this message translates to:
  /// **'Reembolsos'**
  String get navRefunds;

  /// No description provided for @navFlights.
  ///
  /// In pt, this message translates to:
  /// **'Voos'**
  String get navFlights;

  /// No description provided for @navAirlines.
  ///
  /// In pt, this message translates to:
  /// **'Companhias'**
  String get navAirlines;

  /// No description provided for @navAirports.
  ///
  /// In pt, this message translates to:
  /// **'Aeroportos'**
  String get navAirports;

  /// No description provided for @navTeam.
  ///
  /// In pt, this message translates to:
  /// **'Equipe'**
  String get navTeam;

  /// No description provided for @navAudit.
  ///
  /// In pt, this message translates to:
  /// **'Auditoria'**
  String get navAudit;

  /// No description provided for @navReviews.
  ///
  /// In pt, this message translates to:
  /// **'Avaliações'**
  String get navReviews;

  /// No description provided for @navPromos.
  ///
  /// In pt, this message translates to:
  /// **'Promoções'**
  String get navPromos;

  /// No description provided for @navAccount.
  ///
  /// In pt, this message translates to:
  /// **'Minha conta'**
  String get navAccount;

  /// No description provided for @navMenu.
  ///
  /// In pt, this message translates to:
  /// **'Menu'**
  String get navMenu;

  /// No description provided for @navLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get navLogout;

  /// No description provided for @navCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo'**
  String get navCatalog;

  /// No description provided for @notFoundTitle.
  ///
  /// In pt, this message translates to:
  /// **'Página não encontrada'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In pt, this message translates to:
  /// **'O endereço não existe ou foi movido.'**
  String get notFoundMessage;

  /// No description provided for @forbiddenTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sem acesso a esta área'**
  String get forbiddenTitle;

  /// No description provided for @forbiddenMessage.
  ///
  /// In pt, this message translates to:
  /// **'Seu papel não inclui esta página. Se você precisa dela, fale com um administrador.'**
  String get forbiddenMessage;

  /// No description provided for @goHome.
  ///
  /// In pt, this message translates to:
  /// **'Ir para o início'**
  String get goHome;

  /// No description provided for @offlineBanner.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com a API. Algumas telas podem não atualizar.'**
  String get offlineBanner;

  /// No description provided for @crashTitle.
  ///
  /// In pt, this message translates to:
  /// **'Algo quebrou nesta tela'**
  String get crashTitle;

  /// No description provided for @crashMessage.
  ///
  /// In pt, this message translates to:
  /// **'O erro foi registrado. Recarregue a página para continuar.'**
  String get crashMessage;

  /// No description provided for @crashReload.
  ///
  /// In pt, this message translates to:
  /// **'Recarregar'**
  String get crashReload;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo ao portal'**
  String get homeWelcomeTitle;

  /// No description provided for @homeWelcomeMessage.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma área no menu. O que você vê depende do seu papel.'**
  String get homeWelcomeMessage;

  /// No description provided for @envBanner.
  ///
  /// In pt, this message translates to:
  /// **'Ambiente de {environment}: os dados desta tela não são de produção.'**
  String envBanner(String environment);

  /// No description provided for @homeGreeting.
  ///
  /// In pt, this message translates to:
  /// **'Olá, {name}'**
  String homeGreeting(String name);

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar no portal'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesso restrito à equipe do DBook.'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginPassword;

  /// No description provided for @loginSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginSubmit;

  /// No description provided for @loginRequired.
  ///
  /// In pt, this message translates to:
  /// **'Preencha este campo.'**
  String get loginRequired;

  /// No description provided for @loginShowPassword.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get loginHidePassword;

  /// No description provided for @loginRestoring.
  ///
  /// In pt, this message translates to:
  /// **'Restaurando sua sessão…'**
  String get loginRestoring;

  /// No description provided for @idleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda está aí?'**
  String get idleTitle;

  /// No description provided for @idleStay.
  ///
  /// In pt, this message translates to:
  /// **'Continuar conectado'**
  String get idleStay;

  /// No description provided for @idleLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair agora'**
  String get idleLogout;

  /// No description provided for @idleMessage.
  ///
  /// In pt, this message translates to:
  /// **'Por segurança, a sessão termina em {seconds} s sem atividade.'**
  String idleMessage(int seconds);

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão terminou por inatividade. Entre de novo; o que estava aberto foi guardado.'**
  String get sessionExpiredMessage;

  /// No description provided for @draftRestoreTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar o que você estava escrevendo?'**
  String get draftRestoreTitle;

  /// No description provided for @draftRestore.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar'**
  String get draftRestore;

  /// No description provided for @draftDiscard.
  ///
  /// In pt, this message translates to:
  /// **'Descartar'**
  String get draftDiscard;

  /// No description provided for @passwordChangeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Trocar a senha'**
  String get passwordChangeTitle;

  /// No description provided for @passwordCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Senha atual'**
  String get passwordCurrent;

  /// No description provided for @passwordNew.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get passwordNew;

  /// No description provided for @passwordConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Repita a nova senha'**
  String get passwordConfirm;

  /// No description provided for @passwordChangeSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Trocar senha'**
  String get passwordChangeSubmit;

  /// No description provided for @passwordChanged.
  ///
  /// In pt, this message translates to:
  /// **'Senha trocada. Entre de novo.'**
  String get passwordChanged;

  /// No description provided for @passwordMismatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não são iguais.'**
  String get passwordMismatch;

  /// No description provided for @passwordRequirementsTitle.
  ///
  /// In pt, this message translates to:
  /// **'A senha precisa ter:'**
  String get passwordRequirementsTitle;

  /// No description provided for @passwordReqLength.
  ///
  /// In pt, this message translates to:
  /// **'Pelo menos 12 caracteres'**
  String get passwordReqLength;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In pt, this message translates to:
  /// **'Fraca'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthMedium.
  ///
  /// In pt, this message translates to:
  /// **'Razoável'**
  String get passwordStrengthMedium;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In pt, this message translates to:
  /// **'Forte'**
  String get passwordStrengthStrong;

  /// No description provided for @passwordMustChange.
  ///
  /// In pt, this message translates to:
  /// **'Por segurança, troque a senha antes de continuar.'**
  String get passwordMustChange;

  /// No description provided for @inviteAcceptTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar convite'**
  String get inviteAcceptTitle;

  /// No description provided for @inviteAcceptSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha seu nome e uma senha para entrar na equipe.'**
  String get inviteAcceptSubtitle;

  /// No description provided for @inviteName.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome'**
  String get inviteName;

  /// No description provided for @inviteAcceptSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Criar minha conta'**
  String get inviteAcceptSubmit;

  /// No description provided for @inviteAccepted.
  ///
  /// In pt, this message translates to:
  /// **'Conta criada. Agora é só entrar.'**
  String get inviteAccepted;

  /// No description provided for @inviteMissingToken.
  ///
  /// In pt, this message translates to:
  /// **'O link do convite está incompleto.'**
  String get inviteMissingToken;

  /// No description provided for @inviteInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Este convite não é válido: pode ter vencido, já ter sido usado ou ter sido cancelado. Peça um novo a um administrador.'**
  String get inviteInvalid;

  /// No description provided for @inviteGoToLogin.
  ///
  /// In pt, this message translates to:
  /// **'Ir para o login'**
  String get inviteGoToLogin;

  /// No description provided for @twoFactorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Verificação em duas etapas'**
  String get twoFactorTitle;

  /// No description provided for @twoFactorSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Digite o código de 6 dígitos do seu autenticador.'**
  String get twoFactorSubtitle;

  /// No description provided for @twoFactorVerify.
  ///
  /// In pt, this message translates to:
  /// **'Verificar'**
  String get twoFactorVerify;

  /// No description provided for @twoFactorUseRecovery.
  ///
  /// In pt, this message translates to:
  /// **'Usar um código de recuperação'**
  String get twoFactorUseRecovery;

  /// No description provided for @twoFactorUseApp.
  ///
  /// In pt, this message translates to:
  /// **'Usar o código do autenticador'**
  String get twoFactorUseApp;

  /// No description provided for @twoFactorRecoveryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Código de recuperação'**
  String get twoFactorRecoveryLabel;

  /// No description provided for @twoFactorEnrollTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ative a verificação em duas etapas'**
  String get twoFactorEnrollTitle;

  /// No description provided for @twoFactorEnrollSteps.
  ///
  /// In pt, this message translates to:
  /// **'1. Abra um app autenticador (Google Authenticator, 1Password, Authy).\n2. Leia o QR code ou digite a chave.\n3. Informe o código de 6 dígitos que o app mostrar.'**
  String get twoFactorEnrollSteps;

  /// No description provided for @twoFactorManualKey.
  ///
  /// In pt, this message translates to:
  /// **'Não consegue ler o QR? Digite esta chave:'**
  String get twoFactorManualKey;

  /// No description provided for @twoFactorConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar e ativar'**
  String get twoFactorConfirm;

  /// No description provided for @twoFactorRecoveryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Guarde seus códigos de recuperação'**
  String get twoFactorRecoveryTitle;

  /// No description provided for @twoFactorRecoveryMessage.
  ///
  /// In pt, this message translates to:
  /// **'Cada código vale uma vez e serve se você perder o autenticador. Eles aparecem só agora: guarde em lugar seguro.'**
  String get twoFactorRecoveryMessage;

  /// No description provided for @twoFactorRecoveryDone.
  ///
  /// In pt, this message translates to:
  /// **'Guardei os códigos'**
  String get twoFactorRecoveryDone;

  /// No description provided for @twoFactorRecoveryFile.
  ///
  /// In pt, this message translates to:
  /// **'codigos-de-recuperacao-dbook.txt'**
  String get twoFactorRecoveryFile;

  /// No description provided for @twoFactorDigit.
  ///
  /// In pt, this message translates to:
  /// **'Dígito {n}'**
  String twoFactorDigit(int n);

  /// No description provided for @twoFactorEnabled.
  ///
  /// In pt, this message translates to:
  /// **'Verificação em duas etapas ativa'**
  String get twoFactorEnabled;

  /// No description provided for @twoFactorDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Verificação em duas etapas desligada'**
  String get twoFactorDisabled;

  /// No description provided for @accountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Minha conta'**
  String get accountTitle;

  /// No description provided for @accountRole.
  ///
  /// In pt, this message translates to:
  /// **'Papel'**
  String get accountRole;

  /// No description provided for @accountEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get accountEmail;

  /// No description provided for @accountChangePassword.
  ///
  /// In pt, this message translates to:
  /// **'Trocar a senha'**
  String get accountChangePassword;

  /// No description provided for @accountTwoFactor.
  ///
  /// In pt, this message translates to:
  /// **'Verificação em duas etapas'**
  String get accountTwoFactor;

  /// No description provided for @accountEnableTwoFactor.
  ///
  /// In pt, this message translates to:
  /// **'Ativar'**
  String get accountEnableTwoFactor;

  /// No description provided for @accountDisableTwoFactor.
  ///
  /// In pt, this message translates to:
  /// **'Desligar'**
  String get accountDisableTwoFactor;

  /// No description provided for @accountPermissions.
  ///
  /// In pt, this message translates to:
  /// **'O que você pode fazer'**
  String get accountPermissions;

  /// No description provided for @roleClient.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get roleClient;

  /// No description provided for @roleSupport.
  ///
  /// In pt, this message translates to:
  /// **'Suporte'**
  String get roleSupport;

  /// No description provided for @roleCatalogManager.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo'**
  String get roleCatalogManager;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Administrador'**
  String get roleSuperAdmin;

  /// No description provided for @roleUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Papel desconhecido'**
  String get roleUnknown;

  /// No description provided for @passwordReqMax.
  ///
  /// In pt, this message translates to:
  /// **'No máximo 72 caracteres'**
  String get passwordReqMax;

  /// No description provided for @passwordReqNotEmail.
  ///
  /// In pt, this message translates to:
  /// **'Diferente do seu e-mail'**
  String get passwordReqNotEmail;

  /// No description provided for @passwordReqNotCommon.
  ///
  /// In pt, this message translates to:
  /// **'Fora das listas de senhas comuns (o servidor confere)'**
  String get passwordReqNotCommon;

  /// No description provided for @loginReasonIdle.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão terminou por inatividade. Entre de novo; o que você estava escrevendo foi guardado nesta aba.'**
  String get loginReasonIdle;

  /// No description provided for @loginReasonExpired.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão expirou. Entre de novo.'**
  String get loginReasonExpired;

  /// No description provided for @loginReasonLoggedOut.
  ///
  /// In pt, this message translates to:
  /// **'Você saiu do portal.'**
  String get loginReasonLoggedOut;

  /// No description provided for @twoFactorBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao login'**
  String get twoFactorBack;

  /// No description provided for @twoFactorDisableTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desligar a verificação em duas etapas'**
  String get twoFactorDisableTitle;

  /// No description provided for @twoFactorDisablePassword.
  ///
  /// In pt, this message translates to:
  /// **'Sua senha'**
  String get twoFactorDisablePassword;

  /// No description provided for @twoFactorDisableCode.
  ///
  /// In pt, this message translates to:
  /// **'Código do autenticador'**
  String get twoFactorDisableCode;

  /// No description provided for @twoFactorDisableSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Desligar'**
  String get twoFactorDisableSubmit;

  /// No description provided for @twoFactorRequiredByRole.
  ///
  /// In pt, this message translates to:
  /// **'Seu papel exige a verificação em duas etapas, então ela não pode ser desligada.'**
  String get twoFactorRequiredByRole;

  /// No description provided for @twoFactorEnrollLoading.
  ///
  /// In pt, this message translates to:
  /// **'Preparando o cadastro…'**
  String get twoFactorEnrollLoading;

  /// No description provided for @twoFactorRecoveryAck.
  ///
  /// In pt, this message translates to:
  /// **'Guardei os códigos em um lugar seguro'**
  String get twoFactorRecoveryAck;

  /// No description provided for @passwordRepeatHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite a mesma senha de novo'**
  String get passwordRepeatHint;

  /// No description provided for @passwordShow.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get passwordShow;

  /// No description provided for @passwordHide.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get passwordHide;

  /// No description provided for @inviteSuccessTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tudo certo'**
  String get inviteSuccessTitle;

  /// No description provided for @commonContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @accountSessionNote.
  ///
  /// In pt, this message translates to:
  /// **'Trocar a senha encerra todas as suas sessões.'**
  String get accountSessionNote;

  /// No description provided for @accountNoPermissions.
  ///
  /// In pt, this message translates to:
  /// **'Seu papel não inclui permissões de gestão.'**
  String get accountNoPermissions;

  /// No description provided for @accountPermissionCount.
  ///
  /// In pt, this message translates to:
  /// **'{count} permissões'**
  String accountPermissionCount(int count);

  /// No description provided for @envNameLocal.
  ///
  /// In pt, this message translates to:
  /// **'desenvolvimento local'**
  String get envNameLocal;

  /// No description provided for @envNameStaging.
  ///
  /// In pt, this message translates to:
  /// **'homologação'**
  String get envNameStaging;

  /// No description provided for @navSkipToContent.
  ///
  /// In pt, this message translates to:
  /// **'Pular para o conteúdo'**
  String get navSkipToContent;

  /// No description provided for @roleDescSupport.
  ///
  /// In pt, this message translates to:
  /// **'Atende clientes: consulta clientes e reservas, cancela, reembolsa, modera avaliações e vê o painel.'**
  String get roleDescSupport;

  /// No description provided for @roleDescCatalogManager.
  ///
  /// In pt, this message translates to:
  /// **'Cuida do catálogo: voos, companhias, aeroportos, promoções e vê o painel.'**
  String get roleDescCatalogManager;

  /// No description provided for @roleDescSuperAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Acesso total, inclusive equipe, auditoria, exportação e anonimização de dados de clientes.'**
  String get roleDescSuperAdmin;

  /// No description provided for @teamTitle.
  ///
  /// In pt, this message translates to:
  /// **'Equipe'**
  String get teamTitle;

  /// No description provided for @teamTabStaff.
  ///
  /// In pt, this message translates to:
  /// **'Pessoas'**
  String get teamTabStaff;

  /// No description provided for @teamTabInvitations.
  ///
  /// In pt, this message translates to:
  /// **'Convites'**
  String get teamTabInvitations;

  /// No description provided for @teamInvite.
  ///
  /// In pt, this message translates to:
  /// **'Convidar pessoa'**
  String get teamInvite;

  /// No description provided for @teamColName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get teamColName;

  /// No description provided for @teamColRole.
  ///
  /// In pt, this message translates to:
  /// **'Papel'**
  String get teamColRole;

  /// No description provided for @teamColStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get teamColStatus;

  /// No description provided for @teamColLastAccess.
  ///
  /// In pt, this message translates to:
  /// **'Último acesso'**
  String get teamColLastAccess;

  /// No description provided for @teamColActions.
  ///
  /// In pt, this message translates to:
  /// **'Ações'**
  String get teamColActions;

  /// No description provided for @teamNeverAccessed.
  ///
  /// In pt, this message translates to:
  /// **'Nunca entrou'**
  String get teamNeverAccessed;

  /// No description provided for @teamStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativa'**
  String get teamStatusActive;

  /// No description provided for @teamStatusBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueada'**
  String get teamStatusBlocked;

  /// No description provided for @teamStatusUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecida'**
  String get teamStatusUnknown;

  /// No description provided for @teamEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém na equipe ainda'**
  String get teamEmpty;

  /// No description provided for @teamEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Convide a primeira pessoa.'**
  String get teamEmptyMessage;

  /// No description provided for @teamChangeRole.
  ///
  /// In pt, this message translates to:
  /// **'Alterar papel'**
  String get teamChangeRole;

  /// No description provided for @teamBlock.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear'**
  String get teamBlock;

  /// No description provided for @teamUnblock.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear'**
  String get teamUnblock;

  /// No description provided for @teamActionsFor.
  ///
  /// In pt, this message translates to:
  /// **'Ações para {name}'**
  String teamActionsFor(String name);

  /// No description provided for @teamSelfReason.
  ///
  /// In pt, this message translates to:
  /// **'Você não pode alterar a si mesmo. Peça a outro administrador.'**
  String get teamSelfReason;

  /// No description provided for @teamLastSuperAdminReason.
  ///
  /// In pt, this message translates to:
  /// **'Esta é a última pessoa com acesso total ativa. Dê o papel a outra antes.'**
  String get teamLastSuperAdminReason;

  /// No description provided for @teamChangeRoleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterar o papel de {name}'**
  String teamChangeRoleTitle(String name);

  /// No description provided for @teamChangeRoleConsequence.
  ///
  /// In pt, this message translates to:
  /// **'As sessões de {name} serão encerradas e ela entra de novo já com o novo papel.'**
  String teamChangeRoleConsequence(String name);

  /// No description provided for @teamChangeRoleSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Alterar papel'**
  String get teamChangeRoleSubmit;

  /// No description provided for @teamRoleChanged.
  ///
  /// In pt, this message translates to:
  /// **'Papel alterado.'**
  String get teamRoleChanged;

  /// No description provided for @teamBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear {name}'**
  String teamBlockTitle(String name);

  /// No description provided for @teamBlockConsequence.
  ///
  /// In pt, this message translates to:
  /// **'{name} perde o acesso agora e as sessões abertas são encerradas. Dá para desbloquear depois.'**
  String teamBlockConsequence(String name);

  /// No description provided for @teamBlockReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo do bloqueio'**
  String get teamBlockReason;

  /// No description provided for @teamBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Pessoa bloqueada.'**
  String get teamBlocked;

  /// No description provided for @teamUnblocked.
  ///
  /// In pt, this message translates to:
  /// **'Pessoa desbloqueada.'**
  String get teamUnblocked;

  /// No description provided for @teamUnblockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear {name}'**
  String teamUnblockTitle(String name);

  /// No description provided for @teamUnblockMessage.
  ///
  /// In pt, this message translates to:
  /// **'{name} volta a poder entrar no portal.'**
  String teamUnblockMessage(String name);

  /// No description provided for @inviteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Convidar pessoa para a equipe'**
  String get inviteTitle;

  /// No description provided for @inviteEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get inviteEmail;

  /// No description provided for @inviteRole.
  ///
  /// In pt, this message translates to:
  /// **'Papel'**
  String get inviteRole;

  /// No description provided for @inviteSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Enviar convite'**
  String get inviteSubmit;

  /// No description provided for @inviteSent.
  ///
  /// In pt, this message translates to:
  /// **'Convite enviado.'**
  String get inviteSent;

  /// No description provided for @inviteResent.
  ///
  /// In pt, this message translates to:
  /// **'Novo link enviado; o anterior parou de valer.'**
  String get inviteResent;

  /// No description provided for @inviteRevoked.
  ///
  /// In pt, this message translates to:
  /// **'Convite cancelado.'**
  String get inviteRevoked;

  /// No description provided for @inviteColEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get inviteColEmail;

  /// No description provided for @inviteColRole.
  ///
  /// In pt, this message translates to:
  /// **'Papel'**
  String get inviteColRole;

  /// No description provided for @inviteColStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get inviteColStatus;

  /// No description provided for @inviteColExpires.
  ///
  /// In pt, this message translates to:
  /// **'Vale até'**
  String get inviteColExpires;

  /// No description provided for @inviteStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Válido'**
  String get inviteStatusPending;

  /// No description provided for @inviteStatusAccepted.
  ///
  /// In pt, this message translates to:
  /// **'Aceito'**
  String get inviteStatusAccepted;

  /// No description provided for @inviteStatusExpired.
  ///
  /// In pt, this message translates to:
  /// **'Vencido'**
  String get inviteStatusExpired;

  /// No description provided for @inviteStatusRevoked.
  ///
  /// In pt, this message translates to:
  /// **'Cancelado'**
  String get inviteStatusRevoked;

  /// No description provided for @inviteStatusUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecido'**
  String get inviteStatusUnknown;

  /// No description provided for @inviteResend.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar'**
  String get inviteResend;

  /// No description provided for @inviteRevoke.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar convite'**
  String get inviteRevoke;

  /// No description provided for @inviteRevokeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar o convite de {email}?'**
  String inviteRevokeTitle(String email);

  /// No description provided for @inviteRevokeMessage.
  ///
  /// In pt, this message translates to:
  /// **'O link deixa de funcionar na hora. Dá para convidar de novo depois.'**
  String get inviteRevokeMessage;

  /// No description provided for @inviteEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum convite'**
  String get inviteEmpty;

  /// No description provided for @inviteEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Os convites enviados aparecem aqui, com a situação de cada um.'**
  String get inviteEmptyMessage;

  /// No description provided for @inviteInvalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido.'**
  String get inviteInvalidEmail;

  /// No description provided for @inviteAlreadyHasAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já existe uma conta com este e-mail.'**
  String get inviteAlreadyHasAccount;

  /// No description provided for @customersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Clientes'**
  String get customersTitle;

  /// No description provided for @customersSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por nome ou e-mail'**
  String get customersSearchHint;

  /// No description provided for @customersColName.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get customersColName;

  /// No description provided for @customersColStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get customersColStatus;

  /// No description provided for @customersColBookings.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get customersColBookings;

  /// No description provided for @customersColCreated.
  ///
  /// In pt, this message translates to:
  /// **'Cliente desde'**
  String get customersColCreated;

  /// No description provided for @customersColLastLogin.
  ///
  /// In pt, this message translates to:
  /// **'Último acesso'**
  String get customersColLastLogin;

  /// No description provided for @customersFilterActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativos'**
  String get customersFilterActive;

  /// No description provided for @customersFilterBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueados'**
  String get customersFilterBlocked;

  /// No description provided for @customersFilterWithBookings.
  ///
  /// In pt, this message translates to:
  /// **'Com reservas'**
  String get customersFilterWithBookings;

  /// No description provided for @customersFilterWithoutBookings.
  ///
  /// In pt, this message translates to:
  /// **'Sem reservas'**
  String get customersFilterWithoutBookings;

  /// No description provided for @customersEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum cliente encontrado'**
  String get customersEmpty;

  /// No description provided for @customersEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Tente outra busca ou limpe os filtros.'**
  String get customersEmptyMessage;

  /// No description provided for @customerStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get customerStatusActive;

  /// No description provided for @customerStatusBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueado'**
  String get customerStatusBlocked;

  /// No description provided for @customerStatusUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecido'**
  String get customerStatusUnknown;

  /// No description provided for @customerAnonymizedBadge.
  ///
  /// In pt, this message translates to:
  /// **'Anonimizado'**
  String get customerAnonymizedBadge;

  /// No description provided for @customerNeverAccessed.
  ///
  /// In pt, this message translates to:
  /// **'Nunca acessou'**
  String get customerNeverAccessed;

  /// No description provided for @customerBackToList.
  ///
  /// In pt, this message translates to:
  /// **'Clientes'**
  String get customerBackToList;

  /// No description provided for @kpiBookings.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get kpiBookings;

  /// No description provided for @kpiTotalPaid.
  ///
  /// In pt, this message translates to:
  /// **'Total pago'**
  String get kpiTotalPaid;

  /// No description provided for @kpiAverageRating.
  ///
  /// In pt, this message translates to:
  /// **'Nota média'**
  String get kpiAverageRating;

  /// No description provided for @kpiNoRating.
  ///
  /// In pt, this message translates to:
  /// **'Sem avaliações'**
  String get kpiNoRating;

  /// No description provided for @tabBookings.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get tabBookings;

  /// No description provided for @tabPayments.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos'**
  String get tabPayments;

  /// No description provided for @tabReviews.
  ///
  /// In pt, this message translates to:
  /// **'Avaliações'**
  String get tabReviews;

  /// No description provided for @tabNotes.
  ///
  /// In pt, this message translates to:
  /// **'Notas'**
  String get tabNotes;

  /// No description provided for @tabHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get tabHistory;

  /// No description provided for @customerBlock.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear cliente'**
  String get customerBlock;

  /// No description provided for @customerUnblock.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear cliente'**
  String get customerUnblock;

  /// No description provided for @customerAnonymize.
  ///
  /// In pt, this message translates to:
  /// **'Anonimizar dados'**
  String get customerAnonymize;

  /// No description provided for @customerExport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar CSV'**
  String get customerExport;

  /// No description provided for @customerBlockMessage.
  ///
  /// In pt, this message translates to:
  /// **'O cliente não consegue mais entrar nem reservar. Dá para desbloquear depois.'**
  String get customerBlockMessage;

  /// No description provided for @customerBlockReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo (obrigatório)'**
  String get customerBlockReason;

  /// No description provided for @customerBlockSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear'**
  String get customerBlockSubmit;

  /// No description provided for @customerBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Cliente bloqueado.'**
  String get customerBlocked;

  /// No description provided for @customerUnblocked.
  ///
  /// In pt, this message translates to:
  /// **'Cliente desbloqueado.'**
  String get customerUnblocked;

  /// No description provided for @customerUnblockMessage.
  ///
  /// In pt, this message translates to:
  /// **'O cliente volta a poder entrar e reservar.'**
  String get customerUnblockMessage;

  /// No description provided for @noteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Notas internas'**
  String get noteTitle;

  /// No description provided for @noteLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nota interna (só a equipe vê)'**
  String get noteLabel;

  /// No description provided for @noteAdd.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar nota'**
  String get noteAdd;

  /// No description provided for @notePin.
  ///
  /// In pt, this message translates to:
  /// **'Fixar'**
  String get notePin;

  /// No description provided for @noteUnpin.
  ///
  /// In pt, this message translates to:
  /// **'Desafixar'**
  String get noteUnpin;

  /// No description provided for @notePinned.
  ///
  /// In pt, this message translates to:
  /// **'Fixada'**
  String get notePinned;

  /// No description provided for @noteEdited.
  ///
  /// In pt, this message translates to:
  /// **'editada'**
  String get noteEdited;

  /// No description provided for @noteEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar nota'**
  String get noteEdit;

  /// No description provided for @noteDelete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar nota'**
  String get noteDelete;

  /// No description provided for @noteDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar esta nota?'**
  String get noteDeleteTitle;

  /// No description provided for @noteDeleteMessage.
  ///
  /// In pt, this message translates to:
  /// **'A nota some para toda a equipe.'**
  String get noteDeleteMessage;

  /// No description provided for @noteSaved.
  ///
  /// In pt, this message translates to:
  /// **'Nota salva.'**
  String get noteSaved;

  /// No description provided for @noteDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Nota apagada.'**
  String get noteDeleted;

  /// No description provided for @notesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma nota ainda'**
  String get notesEmpty;

  /// No description provided for @notesEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Registre aqui o que a equipe precisa saber sobre este cliente.'**
  String get notesEmptyMessage;

  /// No description provided for @customerAnonymizeConsequence.
  ///
  /// In pt, this message translates to:
  /// **'Nome, e-mail e dados pessoais deste cliente serão apagados de forma definitiva. As reservas e os pagamentos ficam, sem identificação. Não dá para desfazer.'**
  String get customerAnonymizeConsequence;

  /// No description provided for @customerAnonymizeReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo (obrigatório)'**
  String get customerAnonymizeReason;

  /// No description provided for @customerAnonymizeSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Anonimizar para sempre'**
  String get customerAnonymizeSubmit;

  /// No description provided for @customerAnonymizedDone.
  ///
  /// In pt, this message translates to:
  /// **'Dados anonimizados.'**
  String get customerAnonymizedDone;

  /// No description provided for @exportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Exportar clientes'**
  String get exportTitle;

  /// No description provided for @exportCeiling.
  ///
  /// In pt, this message translates to:
  /// **'O arquivo tem no máximo 50.000 linhas.'**
  String get exportCeiling;

  /// No description provided for @exportContents.
  ///
  /// In pt, this message translates to:
  /// **'Colunas: id, nome, e-mail, situação, cadastro, último acesso e total de reservas. A exportação fica registrada na auditoria.'**
  String get exportContents;

  /// No description provided for @exportStart.
  ///
  /// In pt, this message translates to:
  /// **'Exportar'**
  String get exportStart;

  /// No description provided for @exportRunning.
  ///
  /// In pt, this message translates to:
  /// **'Gerando o arquivo…'**
  String get exportRunning;

  /// No description provided for @exportDone.
  ///
  /// In pt, this message translates to:
  /// **'Arquivo baixado.'**
  String get exportDone;

  /// No description provided for @exportAllCustomers.
  ///
  /// In pt, this message translates to:
  /// **'todos os clientes'**
  String get exportAllCustomers;

  /// No description provided for @exportNotAvailable.
  ///
  /// In pt, this message translates to:
  /// **'O download só funciona no navegador.'**
  String get exportNotAvailable;

  /// No description provided for @bookingColId.
  ///
  /// In pt, this message translates to:
  /// **'Reserva'**
  String get bookingColId;

  /// No description provided for @bookingColItem.
  ///
  /// In pt, this message translates to:
  /// **'Item'**
  String get bookingColItem;

  /// No description provided for @bookingColStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get bookingColStatus;

  /// No description provided for @bookingColPrice.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get bookingColPrice;

  /// No description provided for @bookingColDeparture.
  ///
  /// In pt, this message translates to:
  /// **'Partida'**
  String get bookingColDeparture;

  /// No description provided for @bookingColCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get bookingColCustomer;

  /// No description provided for @bookingColCreated.
  ///
  /// In pt, this message translates to:
  /// **'Criada em'**
  String get bookingColCreated;

  /// No description provided for @paymentColId.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get paymentColId;

  /// No description provided for @paymentColAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get paymentColAmount;

  /// No description provided for @paymentColCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão'**
  String get paymentColCard;

  /// No description provided for @paymentColDate.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get paymentColDate;

  /// No description provided for @reviewColRating.
  ///
  /// In pt, this message translates to:
  /// **'Nota'**
  String get reviewColRating;

  /// No description provided for @reviewColComment.
  ///
  /// In pt, this message translates to:
  /// **'Comentário'**
  String get reviewColComment;

  /// No description provided for @reviewColDate.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get reviewColDate;

  /// No description provided for @tabEmptyBookings.
  ///
  /// In pt, this message translates to:
  /// **'Sem reservas'**
  String get tabEmptyBookings;

  /// No description provided for @tabEmptyPayments.
  ///
  /// In pt, this message translates to:
  /// **'Sem pagamentos'**
  String get tabEmptyPayments;

  /// No description provided for @tabEmptyReviews.
  ///
  /// In pt, this message translates to:
  /// **'Sem avaliações'**
  String get tabEmptyReviews;

  /// No description provided for @tabEmptyHistory.
  ///
  /// In pt, this message translates to:
  /// **'Sem registros'**
  String get tabEmptyHistory;

  /// No description provided for @tabEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Nada para mostrar aqui ainda.'**
  String get tabEmptyHint;

  /// No description provided for @bookingStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get bookingStatusPending;

  /// No description provided for @bookingStatusConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Confirmada'**
  String get bookingStatusConfirmed;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Cancelada'**
  String get bookingStatusCancelled;

  /// No description provided for @bookingStatusExpired.
  ///
  /// In pt, this message translates to:
  /// **'Expirada'**
  String get bookingStatusExpired;

  /// No description provided for @bookingStatusRefunded.
  ///
  /// In pt, this message translates to:
  /// **'Reembolsada'**
  String get bookingStatusRefunded;

  /// No description provided for @bookingStatusUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecida'**
  String get bookingStatusUnknown;

  /// No description provided for @auditColWhen.
  ///
  /// In pt, this message translates to:
  /// **'Quando'**
  String get auditColWhen;

  /// No description provided for @auditColAction.
  ///
  /// In pt, this message translates to:
  /// **'Ação'**
  String get auditColAction;

  /// No description provided for @auditColActor.
  ///
  /// In pt, this message translates to:
  /// **'Quem'**
  String get auditColActor;

  /// No description provided for @auditColOutcome.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get auditColOutcome;

  /// No description provided for @auditColTarget.
  ///
  /// In pt, this message translates to:
  /// **'Alvo'**
  String get auditColTarget;

  /// No description provided for @auditOutcomeSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Feito'**
  String get auditOutcomeSuccess;

  /// No description provided for @auditOutcomeDenied.
  ///
  /// In pt, this message translates to:
  /// **'Negado'**
  String get auditOutcomeDenied;

  /// No description provided for @customerSince.
  ///
  /// In pt, this message translates to:
  /// **'Cliente desde {date}'**
  String customerSince(String date);

  /// No description provided for @customerLastAccess.
  ///
  /// In pt, this message translates to:
  /// **'Último acesso {date}'**
  String customerLastAccess(String date);

  /// No description provided for @customerBlockedBanner.
  ///
  /// In pt, this message translates to:
  /// **'Cliente bloqueado desde {date}. Motivo: {reason}'**
  String customerBlockedBanner(String date, String reason);

  /// No description provided for @customerAnonymizedBanner.
  ///
  /// In pt, this message translates to:
  /// **'Dados anonimizados em {date}. Esta conta não pode ser reativada.'**
  String customerAnonymizedBanner(String date);

  /// No description provided for @customerBlockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bloquear {name}'**
  String customerBlockTitle(String name);

  /// No description provided for @customerUnblockTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear {name}'**
  String customerUnblockTitle(String name);

  /// No description provided for @customerBlockReasonCounter.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo de {min} caracteres ({count} escritos)'**
  String customerBlockReasonCounter(int min, int count);

  /// No description provided for @customerAnonymizeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Anonimizar {name}'**
  String customerAnonymizeTitle(String name);

  /// No description provided for @customerAnonymizePhrase.
  ///
  /// In pt, this message translates to:
  /// **'Para confirmar, digite {phrase}'**
  String customerAnonymizePhrase(String phrase);

  /// No description provided for @noteBy.
  ///
  /// In pt, this message translates to:
  /// **'por {author} em {date}'**
  String noteBy(String author, String date);

  /// No description provided for @exportMessage.
  ///
  /// In pt, this message translates to:
  /// **'Será gerado um CSV com o que os filtros atuais mostram: {filters}.'**
  String exportMessage(String filters);

  /// No description provided for @customersChipStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação: {value}'**
  String customersChipStatus(String value);

  /// No description provided for @customersChipBookings.
  ///
  /// In pt, this message translates to:
  /// **'Reservas: {value}'**
  String customersChipBookings(String value);

  /// No description provided for @customersChipSort.
  ///
  /// In pt, this message translates to:
  /// **'Ordem: {value}'**
  String customersChipSort(String value);

  /// No description provided for @auditActionFlightCreated.
  ///
  /// In pt, this message translates to:
  /// **'Voo cadastrado'**
  String get auditActionFlightCreated;

  /// No description provided for @auditActionBookingCancelledByStaff.
  ///
  /// In pt, this message translates to:
  /// **'Reserva cancelada pela equipe'**
  String get auditActionBookingCancelledByStaff;

  /// No description provided for @auditActionAccessDenied.
  ///
  /// In pt, this message translates to:
  /// **'Acesso negado'**
  String get auditActionAccessDenied;

  /// No description provided for @auditActionStaffInvited.
  ///
  /// In pt, this message translates to:
  /// **'Convite enviado'**
  String get auditActionStaffInvited;

  /// No description provided for @auditActionStaffInvitationResent.
  ///
  /// In pt, this message translates to:
  /// **'Convite reenviado'**
  String get auditActionStaffInvitationResent;

  /// No description provided for @auditActionStaffInvitationRevoked.
  ///
  /// In pt, this message translates to:
  /// **'Convite cancelado'**
  String get auditActionStaffInvitationRevoked;

  /// No description provided for @auditActionStaffInvitationAccepted.
  ///
  /// In pt, this message translates to:
  /// **'Convite aceito'**
  String get auditActionStaffInvitationAccepted;

  /// No description provided for @auditActionStaffRoleChanged.
  ///
  /// In pt, this message translates to:
  /// **'Papel alterado'**
  String get auditActionStaffRoleChanged;

  /// No description provided for @auditActionStaffBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Pessoa da equipe bloqueada'**
  String get auditActionStaffBlocked;

  /// No description provided for @auditActionStaffUnblocked.
  ///
  /// In pt, this message translates to:
  /// **'Pessoa da equipe desbloqueada'**
  String get auditActionStaffUnblocked;

  /// No description provided for @auditActionCustomerViewed.
  ///
  /// In pt, this message translates to:
  /// **'Cliente consultado'**
  String get auditActionCustomerViewed;

  /// No description provided for @auditActionCustomerBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Cliente bloqueado'**
  String get auditActionCustomerBlocked;

  /// No description provided for @auditActionCustomerUnblocked.
  ///
  /// In pt, this message translates to:
  /// **'Cliente desbloqueado'**
  String get auditActionCustomerUnblocked;

  /// No description provided for @auditActionCustomerNoteAdded.
  ///
  /// In pt, this message translates to:
  /// **'Nota adicionada'**
  String get auditActionCustomerNoteAdded;

  /// No description provided for @auditActionCustomerNoteEdited.
  ///
  /// In pt, this message translates to:
  /// **'Nota editada'**
  String get auditActionCustomerNoteEdited;

  /// No description provided for @auditActionCustomerNoteDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Nota apagada'**
  String get auditActionCustomerNoteDeleted;

  /// No description provided for @auditActionCustomerExported.
  ///
  /// In pt, this message translates to:
  /// **'Clientes exportados'**
  String get auditActionCustomerExported;

  /// No description provided for @auditActionCustomerAnonymized.
  ///
  /// In pt, this message translates to:
  /// **'Cliente anonimizado'**
  String get auditActionCustomerAnonymized;

  /// No description provided for @auditActionCustomerDataExported.
  ///
  /// In pt, this message translates to:
  /// **'Dados do cliente exportados'**
  String get auditActionCustomerDataExported;

  /// No description provided for @auditActionFlightUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Voo alterado'**
  String get auditActionFlightUpdated;

  /// No description provided for @auditActionFlightCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Voo cancelado'**
  String get auditActionFlightCancelled;

  /// No description provided for @auditActionFlightsImported.
  ///
  /// In pt, this message translates to:
  /// **'Voos importados'**
  String get auditActionFlightsImported;

  /// No description provided for @auditActionAirlineCreated.
  ///
  /// In pt, this message translates to:
  /// **'Companhia criada'**
  String get auditActionAirlineCreated;

  /// No description provided for @auditActionAirlineUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Companhia alterada'**
  String get auditActionAirlineUpdated;

  /// No description provided for @auditActionAirlineDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Companhia removida'**
  String get auditActionAirlineDeleted;

  /// No description provided for @auditActionAirportCreated.
  ///
  /// In pt, this message translates to:
  /// **'Aeroporto criado'**
  String get auditActionAirportCreated;

  /// No description provided for @auditActionAirportUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Aeroporto alterado'**
  String get auditActionAirportUpdated;

  /// No description provided for @auditActionAirportDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Aeroporto removido'**
  String get auditActionAirportDeleted;

  /// No description provided for @auditActionRefundRequested.
  ///
  /// In pt, this message translates to:
  /// **'Reembolso pedido'**
  String get auditActionRefundRequested;

  /// No description provided for @auditActionRefundRetried.
  ///
  /// In pt, this message translates to:
  /// **'Reembolso tentado de novo'**
  String get auditActionRefundRetried;

  /// No description provided for @auditActionRefundCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Reembolso concluído'**
  String get auditActionRefundCompleted;

  /// No description provided for @auditActionRefundFailed.
  ///
  /// In pt, this message translates to:
  /// **'Reembolso falhou'**
  String get auditActionRefundFailed;

  /// No description provided for @auditActionReviewHidden.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação ocultada'**
  String get auditActionReviewHidden;

  /// No description provided for @auditActionReviewRestored.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação restaurada'**
  String get auditActionReviewRestored;

  /// No description provided for @auditActionReviewReportsDismissed.
  ///
  /// In pt, this message translates to:
  /// **'Denúncias dispensadas'**
  String get auditActionReviewReportsDismissed;

  /// No description provided for @auditActionPromoCreated.
  ///
  /// In pt, this message translates to:
  /// **'Promoção criada'**
  String get auditActionPromoCreated;

  /// No description provided for @auditActionPromoUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Promoção alterada'**
  String get auditActionPromoUpdated;

  /// No description provided for @auditActionPromoActivated.
  ///
  /// In pt, this message translates to:
  /// **'Promoção ativada'**
  String get auditActionPromoActivated;

  /// No description provided for @auditActionPromoDeactivated.
  ///
  /// In pt, this message translates to:
  /// **'Promoção desativada'**
  String get auditActionPromoDeactivated;

  /// No description provided for @auditActionAccommodationCreated.
  ///
  /// In pt, this message translates to:
  /// **'Hotel criado'**
  String get auditActionAccommodationCreated;

  /// No description provided for @auditActionAccommodationUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Hotel alterado'**
  String get auditActionAccommodationUpdated;

  /// No description provided for @auditActionAccommodationActivated.
  ///
  /// In pt, this message translates to:
  /// **'Hotel ativado'**
  String get auditActionAccommodationActivated;

  /// No description provided for @auditActionAccommodationDeactivated.
  ///
  /// In pt, this message translates to:
  /// **'Hotel desativado'**
  String get auditActionAccommodationDeactivated;

  /// No description provided for @auditActionRoomTypeChanged.
  ///
  /// In pt, this message translates to:
  /// **'Quarto alterado'**
  String get auditActionRoomTypeChanged;

  /// No description provided for @auditActionTwoFactorEnabled.
  ///
  /// In pt, this message translates to:
  /// **'Segundo fator ligado'**
  String get auditActionTwoFactorEnabled;

  /// No description provided for @auditActionTwoFactorDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Segundo fator desligado'**
  String get auditActionTwoFactorDisabled;

  /// No description provided for @auditActionTwoFactorReset.
  ///
  /// In pt, this message translates to:
  /// **'Segundo fator removido'**
  String get auditActionTwoFactorReset;

  /// No description provided for @bookingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get bookingsTitle;

  /// No description provided for @bookingsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma reserva encontrada'**
  String get bookingsEmpty;

  /// No description provided for @bookingsEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste os filtros ou limpe-os para ver todas.'**
  String get bookingsEmptyMessage;

  /// No description provided for @bookingsFilterPaid.
  ///
  /// In pt, this message translates to:
  /// **'Pagas'**
  String get bookingsFilterPaid;

  /// No description provided for @bookingsFilterUnpaid.
  ///
  /// In pt, this message translates to:
  /// **'Não pagas'**
  String get bookingsFilterUnpaid;

  /// No description provided for @bookingsFilterStatusAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas as situações'**
  String get bookingsFilterStatusAll;

  /// No description provided for @bookingsFilterStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get bookingsFilterStatus;

  /// No description provided for @bookingColPaid.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get bookingColPaid;

  /// No description provided for @bookingPaidYes.
  ///
  /// In pt, this message translates to:
  /// **'Pago'**
  String get bookingPaidYes;

  /// No description provided for @bookingPaidNo.
  ///
  /// In pt, this message translates to:
  /// **'Em aberto'**
  String get bookingPaidNo;

  /// No description provided for @bookingTimelineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Linha do tempo'**
  String get bookingTimelineTitle;

  /// No description provided for @bookingTimelineCreated.
  ///
  /// In pt, this message translates to:
  /// **'Reserva criada'**
  String get bookingTimelineCreated;

  /// No description provided for @bookingTimelineBySystem.
  ///
  /// In pt, this message translates to:
  /// **'pelo sistema'**
  String get bookingTimelineBySystem;

  /// No description provided for @bookingPaymentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get bookingPaymentTitle;

  /// No description provided for @bookingRefundTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reembolso'**
  String get bookingRefundTitle;

  /// No description provided for @bookingNoPayment.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não foi paga.'**
  String get bookingNoPayment;

  /// No description provided for @bookingNoRefund.
  ///
  /// In pt, this message translates to:
  /// **'Sem reembolso.'**
  String get bookingNoRefund;

  /// No description provided for @bookingCustomerLink.
  ///
  /// In pt, this message translates to:
  /// **'Abrir cliente'**
  String get bookingCustomerLink;

  /// No description provided for @bookingPaidAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor pago'**
  String get bookingPaidAmount;

  /// No description provided for @bookingDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get bookingDiscount;

  /// No description provided for @bookingFrozenPrice.
  ///
  /// In pt, this message translates to:
  /// **'Valor da reserva'**
  String get bookingFrozenPrice;

  /// No description provided for @bookingCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão'**
  String get bookingCard;

  /// No description provided for @bookingItem.
  ///
  /// In pt, this message translates to:
  /// **'Item'**
  String get bookingItem;

  /// No description provided for @bookingSeat.
  ///
  /// In pt, this message translates to:
  /// **'Assento'**
  String get bookingSeat;

  /// No description provided for @bookingRoute.
  ///
  /// In pt, this message translates to:
  /// **'Trajeto'**
  String get bookingRoute;

  /// No description provided for @bookingCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get bookingCustomer;

  /// No description provided for @bookingCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar reserva'**
  String get bookingCancel;

  /// No description provided for @bookingCancelMessage.
  ///
  /// In pt, this message translates to:
  /// **'O assento volta a ficar livre. Só reservas pendentes podem ser canceladas.'**
  String get bookingCancelMessage;

  /// No description provided for @bookingCancelDone.
  ///
  /// In pt, this message translates to:
  /// **'Reserva cancelada.'**
  String get bookingCancelDone;

  /// No description provided for @bookingRefund.
  ///
  /// In pt, this message translates to:
  /// **'Reembolsar'**
  String get bookingRefund;

  /// No description provided for @bookingsBackToList.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get bookingsBackToList;

  /// No description provided for @refundReasonLabel.
  ///
  /// In pt, this message translates to:
  /// **'Motivo'**
  String get refundReasonLabel;

  /// No description provided for @refundReasonCustomerRequest.
  ///
  /// In pt, this message translates to:
  /// **'Pedido do cliente'**
  String get refundReasonCustomerRequest;

  /// No description provided for @refundReasonFlightCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Voo cancelado'**
  String get refundReasonFlightCancelled;

  /// No description provided for @refundReasonDuplicate.
  ///
  /// In pt, this message translates to:
  /// **'Cobrança duplicada'**
  String get refundReasonDuplicate;

  /// No description provided for @refundReasonOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro motivo'**
  String get refundReasonOther;

  /// No description provided for @refundNoteLabel.
  ///
  /// In pt, this message translates to:
  /// **'Observação'**
  String get refundNoteLabel;

  /// No description provided for @refundNoteRequired.
  ///
  /// In pt, this message translates to:
  /// **'A observação é obrigatória para uma exceção de política.'**
  String get refundNoteRequired;

  /// No description provided for @refundOverride.
  ///
  /// In pt, this message translates to:
  /// **'Exceção de política (ignorar o prazo)'**
  String get refundOverride;

  /// No description provided for @refundOverrideHelp.
  ///
  /// In pt, this message translates to:
  /// **'Só administradores. Exige uma observação e fica registrada na auditoria.'**
  String get refundOverrideHelp;

  /// No description provided for @refundSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Reembolsar'**
  String get refundSubmit;

  /// No description provided for @refundProcessing.
  ///
  /// In pt, this message translates to:
  /// **'Processando…'**
  String get refundProcessing;

  /// No description provided for @refundDone.
  ///
  /// In pt, this message translates to:
  /// **'Reembolso concluído.'**
  String get refundDone;

  /// No description provided for @refundFailedTitle.
  ///
  /// In pt, this message translates to:
  /// **'O reembolso falhou'**
  String get refundFailedTitle;

  /// No description provided for @refundFailedMessage.
  ///
  /// In pt, this message translates to:
  /// **'O dinheiro não saiu. Você pode tentar de novo: nada será devolvido em duplicidade.'**
  String get refundFailedMessage;

  /// No description provided for @refundRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get refundRetry;

  /// No description provided for @refundRequestedNote.
  ///
  /// In pt, this message translates to:
  /// **'O pedido foi registrado e ainda não terminou. Tente de novo para concluir.'**
  String get refundRequestedNote;

  /// No description provided for @refundStatusRequested.
  ///
  /// In pt, this message translates to:
  /// **'Pedido'**
  String get refundStatusRequested;

  /// No description provided for @refundStatusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluído'**
  String get refundStatusCompleted;

  /// No description provided for @refundStatusFailed.
  ///
  /// In pt, this message translates to:
  /// **'Falhou'**
  String get refundStatusFailed;

  /// No description provided for @refundStatusUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecido'**
  String get refundStatusUnknown;

  /// No description provided for @refundsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reembolsos'**
  String get refundsTitle;

  /// No description provided for @refundsFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get refundsFilterAll;

  /// No description provided for @refundColId.
  ///
  /// In pt, this message translates to:
  /// **'Reembolso'**
  String get refundColId;

  /// No description provided for @refundColBooking.
  ///
  /// In pt, this message translates to:
  /// **'Reserva'**
  String get refundColBooking;

  /// No description provided for @refundColAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get refundColAmount;

  /// No description provided for @refundColStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get refundColStatus;

  /// No description provided for @refundColReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo'**
  String get refundColReason;

  /// No description provided for @refundColDate.
  ///
  /// In pt, this message translates to:
  /// **'Pedido em'**
  String get refundColDate;

  /// No description provided for @refundOpenBooking.
  ///
  /// In pt, this message translates to:
  /// **'Abrir reserva'**
  String get refundOpenBooking;

  /// No description provided for @refundsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum reembolso'**
  String get refundsEmpty;

  /// No description provided for @refundsEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Os reembolsos aparecem aqui, com a situação de cada um.'**
  String get refundsEmptyMessage;

  /// No description provided for @refundConflict.
  ///
  /// In pt, this message translates to:
  /// **'Outra pessoa mexeu nesta reserva agora. Recarreguei os dados: confira e tente de novo.'**
  String get refundConflict;

  /// No description provided for @bookingsChipCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Cliente #{id}'**
  String bookingsChipCustomer(int id);

  /// No description provided for @bookingsChipFlight.
  ///
  /// In pt, this message translates to:
  /// **'Voo #{id}'**
  String bookingsChipFlight(int id);

  /// No description provided for @bookingsChipStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação: {value}'**
  String bookingsChipStatus(String value);

  /// No description provided for @bookingsChipPaid.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento: {value}'**
  String bookingsChipPaid(String value);

  /// No description provided for @bookingDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reserva #{id}'**
  String bookingDetailTitle(int id);

  /// No description provided for @bookingTimelineChanged.
  ///
  /// In pt, this message translates to:
  /// **'{from} → {to}'**
  String bookingTimelineChanged(String from, String to);

  /// No description provided for @bookingTimelineBy.
  ///
  /// In pt, this message translates to:
  /// **'por pessoa #{actor}'**
  String bookingTimelineBy(int actor);

  /// No description provided for @bookingCancelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar a reserva #{id}?'**
  String bookingCancelTitle(int id);

  /// No description provided for @refundTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reembolsar a reserva #{id}'**
  String refundTitle(int id);

  /// No description provided for @refundSummaryAmount.
  ///
  /// In pt, this message translates to:
  /// **'Valor a devolver: {amount}'**
  String refundSummaryAmount(String amount);

  /// No description provided for @refundPolicy.
  ///
  /// In pt, this message translates to:
  /// **'O reembolso é do valor pago, por inteiro. Só é possível até 24 horas antes da partida.'**
  String get refundPolicy;

  /// No description provided for @refundPolicyDeadline.
  ///
  /// In pt, this message translates to:
  /// **'O reembolso é do valor pago, por inteiro. Só é possível até 24 horas antes da partida (limite: {date}).'**
  String refundPolicyDeadline(String date);

  /// No description provided for @flightsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Voos'**
  String get flightsTitle;

  /// No description provided for @flightsNew.
  ///
  /// In pt, this message translates to:
  /// **'Novo voo'**
  String get flightsNew;

  /// No description provided for @flightsImport.
  ///
  /// In pt, this message translates to:
  /// **'Importar CSV'**
  String get flightsImport;

  /// No description provided for @flightsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum voo encontrado'**
  String get flightsEmpty;

  /// No description provided for @flightsEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste os filtros ou cadastre um voo.'**
  String get flightsEmptyMessage;

  /// No description provided for @flightsFilterOrigin.
  ///
  /// In pt, this message translates to:
  /// **'Origem (IATA)'**
  String get flightsFilterOrigin;

  /// No description provided for @flightsFilterDestination.
  ///
  /// In pt, this message translates to:
  /// **'Destino (IATA)'**
  String get flightsFilterDestination;

  /// No description provided for @flightsFilterAirline.
  ///
  /// In pt, this message translates to:
  /// **'Companhia (IATA)'**
  String get flightsFilterAirline;

  /// No description provided for @flightsFilterStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get flightsFilterStatus;

  /// No description provided for @flightsFilterStatusAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get flightsFilterStatusAll;

  /// No description provided for @flightStatusScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Programado'**
  String get flightStatusScheduled;

  /// No description provided for @flightStatusCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Cancelado'**
  String get flightStatusCancelled;

  /// No description provided for @flightStatusUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecido'**
  String get flightStatusUnknown;

  /// No description provided for @flightColNumber.
  ///
  /// In pt, this message translates to:
  /// **'Voo'**
  String get flightColNumber;

  /// No description provided for @flightColRoute.
  ///
  /// In pt, this message translates to:
  /// **'Trajeto'**
  String get flightColRoute;

  /// No description provided for @flightColDeparture.
  ///
  /// In pt, this message translates to:
  /// **'Partida'**
  String get flightColDeparture;

  /// No description provided for @flightColArrival.
  ///
  /// In pt, this message translates to:
  /// **'Chegada'**
  String get flightColArrival;

  /// No description provided for @flightColPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço'**
  String get flightColPrice;

  /// No description provided for @flightColSeats.
  ///
  /// In pt, this message translates to:
  /// **'Assentos'**
  String get flightColSeats;

  /// No description provided for @flightColStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get flightColStatus;

  /// No description provided for @flightColClass.
  ///
  /// In pt, this message translates to:
  /// **'Classe'**
  String get flightColClass;

  /// No description provided for @flightSeatsFree.
  ///
  /// In pt, this message translates to:
  /// **'livres'**
  String get flightSeatsFree;

  /// No description provided for @flightSeatsReserved.
  ///
  /// In pt, this message translates to:
  /// **'reservados'**
  String get flightSeatsReserved;

  /// No description provided for @seatClassEconomy.
  ///
  /// In pt, this message translates to:
  /// **'Econômica'**
  String get seatClassEconomy;

  /// No description provided for @seatClassPremiumEconomy.
  ///
  /// In pt, this message translates to:
  /// **'Econômica premium'**
  String get seatClassPremiumEconomy;

  /// No description provided for @seatClassBusiness.
  ///
  /// In pt, this message translates to:
  /// **'Executiva'**
  String get seatClassBusiness;

  /// No description provided for @seatClassFirst.
  ///
  /// In pt, this message translates to:
  /// **'Primeira classe'**
  String get seatClassFirst;

  /// No description provided for @seatClassUnknown.
  ///
  /// In pt, this message translates to:
  /// **'Desconhecida'**
  String get seatClassUnknown;

  /// No description provided for @flightFormNewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo voo'**
  String get flightFormNewTitle;

  /// No description provided for @flightFormNumber.
  ///
  /// In pt, this message translates to:
  /// **'Número do voo'**
  String get flightFormNumber;

  /// No description provided for @flightFormAirline.
  ///
  /// In pt, this message translates to:
  /// **'Companhia'**
  String get flightFormAirline;

  /// No description provided for @flightFormOrigin.
  ///
  /// In pt, this message translates to:
  /// **'Origem'**
  String get flightFormOrigin;

  /// No description provided for @flightFormDestination.
  ///
  /// In pt, this message translates to:
  /// **'Destino'**
  String get flightFormDestination;

  /// No description provided for @flightFormDeparture.
  ///
  /// In pt, this message translates to:
  /// **'Partida'**
  String get flightFormDeparture;

  /// No description provided for @flightFormArrival.
  ///
  /// In pt, this message translates to:
  /// **'Chegada'**
  String get flightFormArrival;

  /// No description provided for @flightFormClass.
  ///
  /// In pt, this message translates to:
  /// **'Classe'**
  String get flightFormClass;

  /// No description provided for @flightFormPrice.
  ///
  /// In pt, this message translates to:
  /// **'Preço (R\$)'**
  String get flightFormPrice;

  /// No description provided for @flightFormCapacity.
  ///
  /// In pt, this message translates to:
  /// **'Capacidade'**
  String get flightFormCapacity;

  /// No description provided for @flightFormAircraft.
  ///
  /// In pt, this message translates to:
  /// **'Avião'**
  String get flightFormAircraft;

  /// No description provided for @flightFormPickDateTime.
  ///
  /// In pt, this message translates to:
  /// **'Escolher data e hora'**
  String get flightFormPickDateTime;

  /// No description provided for @flightFormSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar voo'**
  String get flightFormSave;

  /// No description provided for @flightFormSaved.
  ///
  /// In pt, this message translates to:
  /// **'Voo salvo.'**
  String get flightFormSaved;

  /// No description provided for @flightFormCreated.
  ///
  /// In pt, this message translates to:
  /// **'Voo cadastrado.'**
  String get flightFormCreated;

  /// No description provided for @flightFormRequired.
  ///
  /// In pt, this message translates to:
  /// **'Preencha este campo.'**
  String get flightFormRequired;

  /// No description provided for @flightFormArrivalAfterDeparture.
  ///
  /// In pt, this message translates to:
  /// **'A chegada precisa ser depois da partida.'**
  String get flightFormArrivalAfterDeparture;

  /// No description provided for @flightFormSameAirport.
  ///
  /// In pt, this message translates to:
  /// **'Origem e destino não podem ser o mesmo aeroporto.'**
  String get flightFormSameAirport;

  /// No description provided for @flightFormPriceInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe um preço maior que zero.'**
  String get flightFormPriceInvalid;

  /// No description provided for @flightFormCapacityInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe uma capacidade inteira maior que zero.'**
  String get flightFormCapacityInvalid;

  /// No description provided for @flightFormCancelledReadOnly.
  ///
  /// In pt, this message translates to:
  /// **'Este voo está cancelado e não pode mais ser editado.'**
  String get flightFormCancelledReadOnly;

  /// No description provided for @flightFormAircraftLocked.
  ///
  /// In pt, this message translates to:
  /// **'O avião não pode mudar: já há assentos reservados neste voo.'**
  String get flightFormAircraftLocked;

  /// No description provided for @flightFormBackToList.
  ///
  /// In pt, this message translates to:
  /// **'Voos'**
  String get flightFormBackToList;

  /// No description provided for @flightCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar voo'**
  String get flightCancel;

  /// No description provided for @flightCancelDone.
  ///
  /// In pt, this message translates to:
  /// **'Voo cancelado.'**
  String get flightCancelDone;

  /// No description provided for @flightCancelBlocked.
  ///
  /// In pt, this message translates to:
  /// **'Este voo tem reservas ativas. Reembolse ou cancele cada uma antes de cancelar o voo.'**
  String get flightCancelBlocked;

  /// No description provided for @flightCancelMessage.
  ///
  /// In pt, this message translates to:
  /// **'O voo sai da busca e não pode mais ser reservado nem editado. Não dá para desfazer.'**
  String get flightCancelMessage;

  /// No description provided for @conflictTitle.
  ///
  /// In pt, this message translates to:
  /// **'Outro administrador alterou este voo'**
  String get conflictTitle;

  /// No description provided for @conflictMessage.
  ///
  /// In pt, this message translates to:
  /// **'Enquanto você editava, o voo mudou. Veja abaixo o que é diferente e escolha o que fazer.'**
  String get conflictMessage;

  /// No description provided for @conflictColField.
  ///
  /// In pt, this message translates to:
  /// **'Campo'**
  String get conflictColField;

  /// No description provided for @conflictColMine.
  ///
  /// In pt, this message translates to:
  /// **'Sua versão'**
  String get conflictColMine;

  /// No description provided for @conflictColTheirs.
  ///
  /// In pt, this message translates to:
  /// **'No servidor agora'**
  String get conflictColTheirs;

  /// No description provided for @conflictReload.
  ///
  /// In pt, this message translates to:
  /// **'Recarregar e descartar minhas mudanças'**
  String get conflictReload;

  /// No description provided for @conflictKeepMine.
  ///
  /// In pt, this message translates to:
  /// **'Salvar as minhas mudanças por cima'**
  String get conflictKeepMine;

  /// No description provided for @conflictNoDifferences.
  ///
  /// In pt, this message translates to:
  /// **'Nada que você editou difere do que está salvo. Dá para recarregar com segurança.'**
  String get conflictNoDifferences;

  /// No description provided for @airlinesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Companhias'**
  String get airlinesTitle;

  /// No description provided for @airlinesNew.
  ///
  /// In pt, this message translates to:
  /// **'Nova companhia'**
  String get airlinesNew;

  /// No description provided for @airlineColCode.
  ///
  /// In pt, this message translates to:
  /// **'Código IATA'**
  String get airlineColCode;

  /// No description provided for @airlineColName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get airlineColName;

  /// No description provided for @airlineSaved.
  ///
  /// In pt, this message translates to:
  /// **'Companhia salva.'**
  String get airlineSaved;

  /// No description provided for @airlineDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Companhia removida.'**
  String get airlineDeleted;

  /// No description provided for @airlineFormTitleNew.
  ///
  /// In pt, this message translates to:
  /// **'Nova companhia'**
  String get airlineFormTitleNew;

  /// No description provided for @airlineFormTitleEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar companhia'**
  String get airlineFormTitleEdit;

  /// No description provided for @airlineFormCode.
  ///
  /// In pt, this message translates to:
  /// **'Código IATA (2 letras ou números)'**
  String get airlineFormCode;

  /// No description provided for @airlineFormName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get airlineFormName;

  /// No description provided for @airlineFormLogo.
  ///
  /// In pt, this message translates to:
  /// **'Logo (endereço https, opcional)'**
  String get airlineFormLogo;

  /// No description provided for @airlineLogoInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Use um endereço que comece com https://'**
  String get airlineLogoInvalid;

  /// No description provided for @airlineCodeInvalid.
  ///
  /// In pt, this message translates to:
  /// **'São 2 letras ou números (por exemplo LA ou G3).'**
  String get airlineCodeInvalid;

  /// No description provided for @airportsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aeroportos'**
  String get airportsTitle;

  /// No description provided for @airportsNew.
  ///
  /// In pt, this message translates to:
  /// **'Novo aeroporto'**
  String get airportsNew;

  /// No description provided for @airportColCode.
  ///
  /// In pt, this message translates to:
  /// **'Código IATA'**
  String get airportColCode;

  /// No description provided for @airportColName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get airportColName;

  /// No description provided for @airportColCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get airportColCity;

  /// No description provided for @airportColCountry.
  ///
  /// In pt, this message translates to:
  /// **'País'**
  String get airportColCountry;

  /// No description provided for @airportColRegion.
  ///
  /// In pt, this message translates to:
  /// **'Região'**
  String get airportColRegion;

  /// No description provided for @airportColPopular.
  ///
  /// In pt, this message translates to:
  /// **'Destaque'**
  String get airportColPopular;

  /// No description provided for @airportSaved.
  ///
  /// In pt, this message translates to:
  /// **'Aeroporto salvo.'**
  String get airportSaved;

  /// No description provided for @airportDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Aeroporto removido.'**
  String get airportDeleted;

  /// No description provided for @airportFormTitleNew.
  ///
  /// In pt, this message translates to:
  /// **'Novo aeroporto'**
  String get airportFormTitleNew;

  /// No description provided for @airportFormTitleEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar aeroporto'**
  String get airportFormTitleEdit;

  /// No description provided for @airportFormCode.
  ///
  /// In pt, this message translates to:
  /// **'Código IATA (3 letras)'**
  String get airportFormCode;

  /// No description provided for @airportFormName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get airportFormName;

  /// No description provided for @airportFormCity.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get airportFormCity;

  /// No description provided for @airportFormCountry.
  ///
  /// In pt, this message translates to:
  /// **'País'**
  String get airportFormCountry;

  /// No description provided for @airportFormPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Endereço da foto'**
  String get airportFormPhoto;

  /// No description provided for @airportFormRegion.
  ///
  /// In pt, this message translates to:
  /// **'Região'**
  String get airportFormRegion;

  /// No description provided for @airportFormPopular.
  ///
  /// In pt, this message translates to:
  /// **'Aparece nos destinos em destaque'**
  String get airportFormPopular;

  /// No description provided for @airportCodeInvalid.
  ///
  /// In pt, this message translates to:
  /// **'São 3 letras (por exemplo GRU).'**
  String get airportCodeInvalid;

  /// No description provided for @catalogEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get catalogEdit;

  /// No description provided for @catalogDelete.
  ///
  /// In pt, this message translates to:
  /// **'Remover'**
  String get catalogDelete;

  /// No description provided for @catalogDeleteInUse.
  ///
  /// In pt, this message translates to:
  /// **'Só dá para remover o que nenhum voo usa.'**
  String get catalogDeleteInUse;

  /// No description provided for @catalogDeleteMessage.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação não pode ser desfeita.'**
  String get catalogDeleteMessage;

  /// No description provided for @importTitle.
  ///
  /// In pt, this message translates to:
  /// **'Importar voos por CSV'**
  String get importTitle;

  /// No description provided for @importIntro.
  ///
  /// In pt, this message translates to:
  /// **'Escolha um arquivo CSV. Primeiro conferimos tudo sem gravar nada; só depois de você confirmar os voos são criados.'**
  String get importIntro;

  /// No description provided for @importColumns.
  ///
  /// In pt, this message translates to:
  /// **'Colunas: flightNumber, airlineIataCode, originIataCode, destinationIataCode, departureTime, arrivalTime, seatClass, price, totalCapacity, aircraftType. Máximo de 5.000 linhas.'**
  String get importColumns;

  /// No description provided for @importChoose.
  ///
  /// In pt, this message translates to:
  /// **'Escolher arquivo'**
  String get importChoose;

  /// No description provided for @importChooseAnother.
  ///
  /// In pt, this message translates to:
  /// **'Escolher outro arquivo'**
  String get importChooseAnother;

  /// No description provided for @importChecking.
  ///
  /// In pt, this message translates to:
  /// **'Conferindo o arquivo…'**
  String get importChecking;

  /// No description provided for @importConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar importação'**
  String get importConfirm;

  /// No description provided for @importConfirming.
  ///
  /// In pt, this message translates to:
  /// **'Importando…'**
  String get importConfirming;

  /// No description provided for @importErrorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Há linhas com erro. Nada foi gravado.'**
  String get importErrorsTitle;

  /// No description provided for @importErrorsHint.
  ///
  /// In pt, this message translates to:
  /// **'Corrija o arquivo e escolha-o de novo. Todas as linhas com erro estão destacadas abaixo.'**
  String get importErrorsHint;

  /// No description provided for @importOkTitle.
  ///
  /// In pt, this message translates to:
  /// **'O arquivo está certo.'**
  String get importOkTitle;

  /// No description provided for @importDoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Importação concluída'**
  String get importDoneTitle;

  /// No description provided for @importColLine.
  ///
  /// In pt, this message translates to:
  /// **'Linha'**
  String get importColLine;

  /// No description provided for @importColProblem.
  ///
  /// In pt, this message translates to:
  /// **'Problema'**
  String get importColProblem;

  /// No description provided for @importPreviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pré-visualização'**
  String get importPreviewTitle;

  /// No description provided for @importPreviewTruncated.
  ///
  /// In pt, this message translates to:
  /// **'Mostrando só as primeiras linhas do arquivo.'**
  String get importPreviewTruncated;

  /// No description provided for @importNotAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Escolher arquivo só funciona no navegador.'**
  String get importNotAvailable;

  /// No description provided for @flightFormEditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar voo {number}'**
  String flightFormEditTitle(String number);

  /// No description provided for @flightFormReserved.
  ///
  /// In pt, this message translates to:
  /// **'{count} assentos reservados: a capacidade não pode ficar abaixo disso.'**
  String flightFormReserved(int count);

  /// No description provided for @flightCancelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar o voo {number}?'**
  String flightCancelTitle(String number);

  /// No description provided for @flightCancelActive.
  ///
  /// In pt, this message translates to:
  /// **'{count} reservas ativas'**
  String flightCancelActive(int count);

  /// No description provided for @airlinesDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover a companhia {name}?'**
  String airlinesDeleteTitle(String name);

  /// No description provided for @airportsDeleteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Remover o aeroporto {name}?'**
  String airportsDeleteTitle(String name);

  /// No description provided for @importSummaryOk.
  ///
  /// In pt, this message translates to:
  /// **'{total} linhas: {create} voos serão criados e {existing} já existem.'**
  String importSummaryOk(int total, int create, int existing);

  /// No description provided for @importSummaryDone.
  ///
  /// In pt, this message translates to:
  /// **'{created} voos criados; {existing} já existiam.'**
  String importSummaryDone(int created, int existing);

  /// No description provided for @importLineErrors.
  ///
  /// In pt, this message translates to:
  /// **'{count} linhas com erro'**
  String importLineErrors(int count);

  /// No description provided for @errFlightRule.
  ///
  /// In pt, this message translates to:
  /// **'O servidor recusou a alteração por uma regra do voo: capacidade abaixo dos assentos reservados, assento com histórico ou avião bloqueado. Confira os campos.'**
  String get errFlightRule;

  /// No description provided for @dashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Painel'**
  String get dashboardTitle;

  /// No description provided for @dashboardRefresh.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar agora'**
  String get dashboardRefresh;

  /// No description provided for @dashboardNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get dashboardNow;

  /// No description provided for @kpiNetRevenue.
  ///
  /// In pt, this message translates to:
  /// **'Receita líquida'**
  String get kpiNetRevenue;

  /// No description provided for @kpiGrossRevenue.
  ///
  /// In pt, this message translates to:
  /// **'Receita bruta'**
  String get kpiGrossRevenue;

  /// No description provided for @kpiRefunded.
  ///
  /// In pt, this message translates to:
  /// **'Reembolsado'**
  String get kpiRefunded;

  /// No description provided for @kpiCreatedBookings.
  ///
  /// In pt, this message translates to:
  /// **'Reservas criadas'**
  String get kpiCreatedBookings;

  /// No description provided for @kpiNewCustomers.
  ///
  /// In pt, this message translates to:
  /// **'Clientes novos'**
  String get kpiNewCustomers;

  /// No description provided for @kpiConversion.
  ///
  /// In pt, this message translates to:
  /// **'Conversão'**
  String get kpiConversion;

  /// No description provided for @kpiExpiration.
  ///
  /// In pt, this message translates to:
  /// **'Expiração'**
  String get kpiExpiration;

  /// No description provided for @kpiOccupancy.
  ///
  /// In pt, this message translates to:
  /// **'Ocupação'**
  String get kpiOccupancy;

  /// No description provided for @kpiNotApplicable.
  ///
  /// In pt, this message translates to:
  /// **'Sem reservas no período'**
  String get kpiNotApplicable;

  /// No description provided for @kpiVsPrevious.
  ///
  /// In pt, this message translates to:
  /// **'vs. período anterior'**
  String get kpiVsPrevious;

  /// No description provided for @glossNetRevenue.
  ///
  /// In pt, this message translates to:
  /// **'Receita bruta menos o que foi reembolsado, no período.'**
  String get glossNetRevenue;

  /// No description provided for @glossGrossRevenue.
  ///
  /// In pt, this message translates to:
  /// **'Soma do valor das reservas pagas no período. Conta o dia do pagamento, não o da criação.'**
  String get glossGrossRevenue;

  /// No description provided for @glossRefunded.
  ///
  /// In pt, this message translates to:
  /// **'Soma dos reembolsos concluídos no período, no dia em que concluíram.'**
  String get glossRefunded;

  /// No description provided for @glossBookings.
  ///
  /// In pt, this message translates to:
  /// **'Reservas criadas no período, pela situação de agora.'**
  String get glossBookings;

  /// No description provided for @glossNewCustomers.
  ///
  /// In pt, this message translates to:
  /// **'Contas de cliente criadas no período (a equipe não conta).'**
  String get glossNewCustomers;

  /// No description provided for @glossConversion.
  ///
  /// In pt, this message translates to:
  /// **'Das reservas criadas no período, quantas foram pagas alguma vez (mesmo reembolsadas depois).'**
  String get glossConversion;

  /// No description provided for @glossExpiration.
  ///
  /// In pt, this message translates to:
  /// **'Das reservas criadas no período, quantas o sistema cancelou por falta de pagamento.'**
  String get glossExpiration;

  /// No description provided for @glossOccupancy.
  ///
  /// In pt, this message translates to:
  /// **'Assentos reservados dos voos que partem no período, sobre a capacidade deles. Só voos à venda; reserva pendente também ocupa assento.'**
  String get glossOccupancy;

  /// No description provided for @seriesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Evolução'**
  String get seriesTitle;

  /// No description provided for @metricRevenue.
  ///
  /// In pt, this message translates to:
  /// **'Receita líquida'**
  String get metricRevenue;

  /// No description provided for @metricBookings.
  ///
  /// In pt, this message translates to:
  /// **'Reservas'**
  String get metricBookings;

  /// No description provided for @metricNewCustomers.
  ///
  /// In pt, this message translates to:
  /// **'Clientes novos'**
  String get metricNewCustomers;

  /// No description provided for @granularityDay.
  ///
  /// In pt, this message translates to:
  /// **'Por dia'**
  String get granularityDay;

  /// No description provided for @granularityWeek.
  ///
  /// In pt, this message translates to:
  /// **'Por semana'**
  String get granularityWeek;

  /// No description provided for @chartAsTable.
  ///
  /// In pt, this message translates to:
  /// **'Ver como tabela'**
  String get chartAsTable;

  /// No description provided for @chartAsChart.
  ///
  /// In pt, this message translates to:
  /// **'Ver como gráfico'**
  String get chartAsChart;

  /// No description provided for @chartColDate.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get chartColDate;

  /// No description provided for @chartColValue.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get chartColValue;

  /// No description provided for @chartEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados no período.'**
  String get chartEmpty;

  /// No description provided for @topRoutesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Rotas mais vendidas'**
  String get topRoutesTitle;

  /// No description provided for @topRoutesColRoute.
  ///
  /// In pt, this message translates to:
  /// **'Rota'**
  String get topRoutesColRoute;

  /// No description provided for @topRoutesColBookings.
  ///
  /// In pt, this message translates to:
  /// **'Reservas pagas'**
  String get topRoutesColBookings;

  /// No description provided for @topRoutesColRevenue.
  ///
  /// In pt, this message translates to:
  /// **'Receita'**
  String get topRoutesColRevenue;

  /// No description provided for @topRoutesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma venda no período.'**
  String get topRoutesEmpty;

  /// No description provided for @periodLabel.
  ///
  /// In pt, this message translates to:
  /// **'Período'**
  String get periodLabel;

  /// No description provided for @dashboardUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Atualizado {ago}'**
  String dashboardUpdated(String ago);

  /// No description provided for @chartSummary.
  ///
  /// In pt, this message translates to:
  /// **'{metric}: {count} pontos, de {min} a {max}, total de {total}.'**
  String chartSummary(
    String metric,
    int count,
    String min,
    String max,
    String total,
  );

  /// No description provided for @auditTitle.
  ///
  /// In pt, this message translates to:
  /// **'Auditoria'**
  String get auditTitle;

  /// No description provided for @auditFilterAction.
  ///
  /// In pt, this message translates to:
  /// **'Ação'**
  String get auditFilterAction;

  /// No description provided for @auditFilterActionAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas as ações'**
  String get auditFilterActionAll;

  /// No description provided for @auditFilterOutcome.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get auditFilterOutcome;

  /// No description provided for @auditFilterOutcomeAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get auditFilterOutcomeAll;

  /// No description provided for @auditFilterActor.
  ///
  /// In pt, this message translates to:
  /// **'Quem (id)'**
  String get auditFilterActor;

  /// No description provided for @auditFilterTargetType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo do alvo'**
  String get auditFilterTargetType;

  /// No description provided for @auditFilterTargetId.
  ///
  /// In pt, this message translates to:
  /// **'Id do alvo'**
  String get auditFilterTargetId;

  /// No description provided for @auditApply.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar'**
  String get auditApply;

  /// No description provided for @auditExpand.
  ///
  /// In pt, this message translates to:
  /// **'Ver antes e depois'**
  String get auditExpand;

  /// No description provided for @auditCollapse.
  ///
  /// In pt, this message translates to:
  /// **'Recolher'**
  String get auditCollapse;

  /// No description provided for @auditNoState.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação não guarda estado antes e depois.'**
  String get auditNoState;

  /// No description provided for @auditChangeAdded.
  ///
  /// In pt, this message translates to:
  /// **'Criado'**
  String get auditChangeAdded;

  /// No description provided for @auditChangeChanged.
  ///
  /// In pt, this message translates to:
  /// **'Alterado'**
  String get auditChangeChanged;

  /// No description provided for @auditChangeRemoved.
  ///
  /// In pt, this message translates to:
  /// **'Removido'**
  String get auditChangeRemoved;

  /// No description provided for @auditChangeUnchanged.
  ///
  /// In pt, this message translates to:
  /// **'Igual'**
  String get auditChangeUnchanged;

  /// No description provided for @auditColField.
  ///
  /// In pt, this message translates to:
  /// **'Campo'**
  String get auditColField;

  /// No description provided for @auditColBefore.
  ///
  /// In pt, this message translates to:
  /// **'Antes'**
  String get auditColBefore;

  /// No description provided for @auditColAfter.
  ///
  /// In pt, this message translates to:
  /// **'Depois'**
  String get auditColAfter;

  /// No description provided for @auditLoadMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregar mais'**
  String get auditLoadMore;

  /// No description provided for @auditLoadingMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregando…'**
  String get auditLoadingMore;

  /// No description provided for @auditEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum registro'**
  String get auditEmpty;

  /// No description provided for @auditEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste os filtros: nada na trilha combina com eles.'**
  String get auditEmptyMessage;

  /// No description provided for @auditShowUnchanged.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar campos iguais'**
  String get auditShowUnchanged;

  /// No description provided for @auditReasonLabel.
  ///
  /// In pt, this message translates to:
  /// **'Motivo'**
  String get auditReasonLabel;

  /// No description provided for @auditRequestLabel.
  ///
  /// In pt, this message translates to:
  /// **'Requisição'**
  String get auditRequestLabel;

  /// No description provided for @auditIpLabel.
  ///
  /// In pt, this message translates to:
  /// **'IP'**
  String get auditIpLabel;

  /// No description provided for @reviewsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Avaliações'**
  String get reviewsTitle;

  /// No description provided for @reviewsQueueReported.
  ///
  /// In pt, this message translates to:
  /// **'Denunciadas'**
  String get reviewsQueueReported;

  /// No description provided for @reviewsQueueHidden.
  ///
  /// In pt, this message translates to:
  /// **'Ocultas'**
  String get reviewsQueueHidden;

  /// No description provided for @reviewsQueueVisible.
  ///
  /// In pt, this message translates to:
  /// **'Visíveis'**
  String get reviewsQueueVisible;

  /// No description provided for @reviewColCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get reviewColCustomer;

  /// No description provided for @reviewColDestination.
  ///
  /// In pt, this message translates to:
  /// **'Destino'**
  String get reviewColDestination;

  /// No description provided for @reviewColReports.
  ///
  /// In pt, this message translates to:
  /// **'Denúncias'**
  String get reviewColReports;

  /// No description provided for @reviewColStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get reviewColStatus;

  /// No description provided for @reviewColText.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação'**
  String get reviewColText;

  /// No description provided for @reviewHide.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar'**
  String get reviewHide;

  /// No description provided for @reviewRestore.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar'**
  String get reviewRestore;

  /// No description provided for @reviewDismiss.
  ///
  /// In pt, this message translates to:
  /// **'Dispensar denúncias'**
  String get reviewDismiss;

  /// No description provided for @reviewHideReason.
  ///
  /// In pt, this message translates to:
  /// **'Motivo (10 a 500 caracteres)'**
  String get reviewHideReason;

  /// No description provided for @reviewHideSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar avaliação'**
  String get reviewHideSubmit;

  /// No description provided for @reviewHiddenDone.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação ocultada.'**
  String get reviewHiddenDone;

  /// No description provided for @reviewRestoredDone.
  ///
  /// In pt, this message translates to:
  /// **'Avaliação restaurada.'**
  String get reviewRestoredDone;

  /// No description provided for @reviewDismissedDone.
  ///
  /// In pt, this message translates to:
  /// **'Denúncias dispensadas.'**
  String get reviewDismissedDone;

  /// No description provided for @reviewsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui'**
  String get reviewsEmpty;

  /// No description provided for @reviewsEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma avaliação nesta fila.'**
  String get reviewsEmptyMessage;

  /// No description provided for @reviewStatusHidden.
  ///
  /// In pt, this message translates to:
  /// **'Oculta'**
  String get reviewStatusHidden;

  /// No description provided for @reviewStatusVisible.
  ///
  /// In pt, this message translates to:
  /// **'Visível'**
  String get reviewStatusVisible;

  /// No description provided for @reviewDismissMessage.
  ///
  /// In pt, this message translates to:
  /// **'As denúncias abertas são encerradas e a avaliação continua visível.'**
  String get reviewDismissMessage;

  /// No description provided for @reviewHideMessage.
  ///
  /// In pt, this message translates to:
  /// **'A avaliação some da tela dos clientes e da média do destino. Dá para restaurar depois.'**
  String get reviewHideMessage;

  /// No description provided for @promosTitle.
  ///
  /// In pt, this message translates to:
  /// **'Promoções'**
  String get promosTitle;

  /// No description provided for @promosNew.
  ///
  /// In pt, this message translates to:
  /// **'Novo código'**
  String get promosNew;

  /// No description provided for @promoColCode.
  ///
  /// In pt, this message translates to:
  /// **'Código'**
  String get promoColCode;

  /// No description provided for @promoColRule.
  ///
  /// In pt, this message translates to:
  /// **'Regra'**
  String get promoColRule;

  /// No description provided for @promoColUsage.
  ///
  /// In pt, this message translates to:
  /// **'Usos'**
  String get promoColUsage;

  /// No description provided for @promoColWindow.
  ///
  /// In pt, this message translates to:
  /// **'Validade'**
  String get promoColWindow;

  /// No description provided for @promoColStatus.
  ///
  /// In pt, this message translates to:
  /// **'Situação'**
  String get promoColStatus;

  /// No description provided for @promoStatusActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get promoStatusActive;

  /// No description provided for @promoStatusOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligado'**
  String get promoStatusOff;

  /// No description provided for @promoEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get promoEdit;

  /// No description provided for @promoActivate.
  ///
  /// In pt, this message translates to:
  /// **'Ativar'**
  String get promoActivate;

  /// No description provided for @promoDeactivate.
  ///
  /// In pt, this message translates to:
  /// **'Desligar'**
  String get promoDeactivate;

  /// No description provided for @promoRedemptionsAction.
  ///
  /// In pt, this message translates to:
  /// **'Ver resgates'**
  String get promoRedemptionsAction;

  /// No description provided for @promoFormTitleNew.
  ///
  /// In pt, this message translates to:
  /// **'Novo código promocional'**
  String get promoFormTitleNew;

  /// No description provided for @promoFormTitleEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar código'**
  String get promoFormTitleEdit;

  /// No description provided for @promoFormCode.
  ///
  /// In pt, this message translates to:
  /// **'Código (3 a 32 letras, números, - ou _)'**
  String get promoFormCode;

  /// No description provided for @promoFormType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get promoFormType;

  /// No description provided for @promoTypePercent.
  ///
  /// In pt, this message translates to:
  /// **'Percentual'**
  String get promoTypePercent;

  /// No description provided for @promoTypeFixed.
  ///
  /// In pt, this message translates to:
  /// **'Valor fixo'**
  String get promoTypeFixed;

  /// No description provided for @promoFormValue.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get promoFormValue;

  /// No description provided for @promoFormValuePercent.
  ///
  /// In pt, this message translates to:
  /// **'Percentual (menor que 100)'**
  String get promoFormValuePercent;

  /// No description provided for @promoFormValueFixed.
  ///
  /// In pt, this message translates to:
  /// **'Valor do desconto (R\$)'**
  String get promoFormValueFixed;

  /// No description provided for @promoFormMin.
  ///
  /// In pt, this message translates to:
  /// **'Compra mínima (R\$, opcional)'**
  String get promoFormMin;

  /// No description provided for @promoFormFrom.
  ///
  /// In pt, this message translates to:
  /// **'Válido a partir de'**
  String get promoFormFrom;

  /// No description provided for @promoFormUntil.
  ///
  /// In pt, this message translates to:
  /// **'Válido até'**
  String get promoFormUntil;

  /// No description provided for @promoFormMaxTotal.
  ///
  /// In pt, this message translates to:
  /// **'Limite de usos (vazio = sem limite)'**
  String get promoFormMaxTotal;

  /// No description provided for @promoFormMaxPerUser.
  ///
  /// In pt, this message translates to:
  /// **'Usos por cliente (padrão 1)'**
  String get promoFormMaxPerUser;

  /// No description provided for @promoFormImmutable.
  ///
  /// In pt, this message translates to:
  /// **'Código, tipo e valor não mudam depois de criado: outro desconto é outro código.'**
  String get promoFormImmutable;

  /// No description provided for @promoCodeInvalid.
  ///
  /// In pt, this message translates to:
  /// **'De 3 a 32 letras, números, - ou _.'**
  String get promoCodeInvalid;

  /// No description provided for @promoValueInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe um valor maior que zero (percentual abaixo de 100).'**
  String get promoValueInvalid;

  /// No description provided for @promoWindowInvalid.
  ///
  /// In pt, this message translates to:
  /// **'O fim precisa ser depois do início.'**
  String get promoWindowInvalid;

  /// No description provided for @promoSaved.
  ///
  /// In pt, this message translates to:
  /// **'Código salvo.'**
  String get promoSaved;

  /// No description provided for @promoActivated.
  ///
  /// In pt, this message translates to:
  /// **'Código ativado.'**
  String get promoActivated;

  /// No description provided for @promoDeactivated.
  ///
  /// In pt, this message translates to:
  /// **'Código desligado.'**
  String get promoDeactivated;

  /// No description provided for @promosEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum código'**
  String get promosEmpty;

  /// No description provided for @promosEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Crie o primeiro código promocional.'**
  String get promosEmptyMessage;

  /// No description provided for @promoFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get promoFilterAll;

  /// No description provided for @promoFilterActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativos'**
  String get promoFilterActive;

  /// No description provided for @promoFilterOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligados'**
  String get promoFilterOff;

  /// No description provided for @promoRedeemColCustomer.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get promoRedeemColCustomer;

  /// No description provided for @promoRedeemColPayment.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento'**
  String get promoRedeemColPayment;

  /// No description provided for @promoRedeemColDiscount.
  ///
  /// In pt, this message translates to:
  /// **'Desconto'**
  String get promoRedeemColDiscount;

  /// No description provided for @promoRedeemColDate.
  ///
  /// In pt, this message translates to:
  /// **'Quando'**
  String get promoRedeemColDate;

  /// No description provided for @promoRedemptionsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém usou este código ainda.'**
  String get promoRedemptionsEmpty;

  /// No description provided for @promoDeactivateMessage.
  ///
  /// In pt, this message translates to:
  /// **'Os clientes deixam de poder usar o código. Os pagamentos que já o usaram não mudam. Dá para ligar de novo.'**
  String get promoDeactivateMessage;

  /// No description provided for @promoNoLimit.
  ///
  /// In pt, this message translates to:
  /// **'sem limite'**
  String get promoNoLimit;

  /// No description provided for @promoUsageUnlimited.
  ///
  /// In pt, this message translates to:
  /// **'{used} usos'**
  String promoUsageUnlimited(Object used);

  /// No description provided for @auditOpenTarget.
  ///
  /// In pt, this message translates to:
  /// **'Abrir {type} {id}'**
  String auditOpenTarget(String type, String id);

  /// No description provided for @reviewHideTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar a avaliação de {name}?'**
  String reviewHideTitle(String name);

  /// No description provided for @reviewReportedReason.
  ///
  /// In pt, this message translates to:
  /// **'Última denúncia: {reason}'**
  String reviewReportedReason(String reason);

  /// No description provided for @reviewHiddenReason.
  ///
  /// In pt, this message translates to:
  /// **'Ocultada: {reason}'**
  String reviewHiddenReason(String reason);

  /// No description provided for @reviewOpenReports.
  ///
  /// In pt, this message translates to:
  /// **'{count} denúncias abertas'**
  String reviewOpenReports(int count);

  /// No description provided for @promoDeactivateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desligar o código {code}?'**
  String promoDeactivateTitle(String code);

  /// No description provided for @promoRedemptionsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resgates de {code}'**
  String promoRedemptionsTitle(String code);

  /// No description provided for @promoRulePercent.
  ///
  /// In pt, this message translates to:
  /// **'{value}% de desconto'**
  String promoRulePercent(String value);

  /// No description provided for @promoRuleFixed.
  ///
  /// In pt, this message translates to:
  /// **'{value} de desconto'**
  String promoRuleFixed(String value);

  /// No description provided for @promoRuleMin.
  ///
  /// In pt, this message translates to:
  /// **'em compras a partir de {min}'**
  String promoRuleMin(String min);

  /// No description provided for @promoRuleMax.
  ///
  /// In pt, this message translates to:
  /// **'até {max} usos'**
  String promoRuleMax(int max);

  /// No description provided for @promoRulePerUser.
  ///
  /// In pt, this message translates to:
  /// **'{n} por cliente'**
  String promoRulePerUser(int n);

  /// No description provided for @promoUsage.
  ///
  /// In pt, this message translates to:
  /// **'{used} de {max}'**
  String promoUsage(int used, int max);

  /// No description provided for @promoWindow.
  ///
  /// In pt, this message translates to:
  /// **'{from} a {until}'**
  String promoWindow(String from, String until);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
