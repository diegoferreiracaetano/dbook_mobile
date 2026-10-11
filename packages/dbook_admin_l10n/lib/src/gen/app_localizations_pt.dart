// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'DBook Admin';

  @override
  String get commonRetry => 'Tentar de novo';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonLoading => 'Carregando…';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonClear => 'Limpar';

  @override
  String get commonNone => '—';

  @override
  String get commonYes => 'Sim';

  @override
  String get commonNo => 'Não';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonCopied => 'Copiado';

  @override
  String get commonDownload => 'Baixar';

  @override
  String get commonNext => 'Próximo';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonDelete => 'Apagar';

  @override
  String get commonCreate => 'Criar';

  @override
  String get commonSending => 'Enviando…';

  @override
  String get commonDismiss => 'Dispensar';

  @override
  String get commonTryOtherFilters => 'Ajuste os filtros e tente de novo.';

  @override
  String get commonNoResults => 'Nenhum resultado';

  @override
  String get commonSomethingWrong => 'Algo deu errado';

  @override
  String get errInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get errAccountBlocked =>
      'Esta conta está bloqueada. Fale com um administrador.';

  @override
  String get errInvalidTwoFactorCode =>
      'Código incorreto ou já usado. Confira o autenticador e tente de novo.';

  @override
  String get errInvalidInvitation =>
      'Este convite não é válido. Peça um novo a um administrador.';

  @override
  String get errForbidden => 'Você não tem permissão para fazer isso.';

  @override
  String get errUnauthorized => 'Sua sessão terminou. Entre de novo.';

  @override
  String get errNotFound => 'Não encontramos o que você procura.';

  @override
  String get errConflict =>
      'A situação mudou desde que você abriu esta tela. Recarregue e tente de novo.';

  @override
  String get errStaleVersion =>
      'Outra pessoa alterou este registro antes de você.';

  @override
  String get errValidation => 'Confira os dados informados.';

  @override
  String get errPayloadTooLarge => 'O arquivo ou o pedido é grande demais.';

  @override
  String get errUnprocessable =>
      'O pedido não pôde ser concluído com esses dados.';

  @override
  String get errIdempotencyKeyReused =>
      'Esta tentativa já foi usada para outro pedido. Comece de novo.';

  @override
  String get errServer =>
      'O servidor não conseguiu responder. Tente de novo em instantes.';

  @override
  String get errNetwork =>
      'Sem conexão com o servidor. Confira a rede e tente de novo.';

  @override
  String get errGeneric => 'Não foi possível concluir. Tente de novo.';

  @override
  String get errRefundWindowClosed =>
      'Faltam menos de 24 horas para a partida: o reembolso não é mais possível.';

  @override
  String errTooManyAttempts(int seconds) {
    return 'Muitas tentativas. Tente de novo em $seconds s.';
  }

  @override
  String errRateLimited(int seconds) {
    return 'Muitas chamadas em pouco tempo. Tente de novo em $seconds s.';
  }

  @override
  String get navDashboard => 'Painel';

  @override
  String get navCustomers => 'Clientes';

  @override
  String get navBookings => 'Reservas';

  @override
  String get navRefunds => 'Reembolsos';

  @override
  String get navFlights => 'Voos';

  @override
  String get navAirlines => 'Companhias';

  @override
  String get navAirports => 'Aeroportos';

  @override
  String get navTeam => 'Equipe';

  @override
  String get navAudit => 'Auditoria';

  @override
  String get navReviews => 'Avaliações';

  @override
  String get navPromos => 'Promoções';

  @override
  String get navAccount => 'Minha conta';

  @override
  String get navMenu => 'Menu';

  @override
  String get navLogout => 'Sair';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get notFoundTitle => 'Página não encontrada';

  @override
  String get notFoundMessage => 'O endereço não existe ou foi movido.';

  @override
  String get forbiddenTitle => 'Sem acesso a esta área';

  @override
  String get forbiddenMessage =>
      'Seu papel não inclui esta página. Se você precisa dela, fale com um administrador.';

  @override
  String get goHome => 'Ir para o início';

  @override
  String get offlineBanner =>
      'Sem conexão com a API. Algumas telas podem não atualizar.';

  @override
  String get crashTitle => 'Algo quebrou nesta tela';

  @override
  String get crashMessage =>
      'O erro foi registrado. Recarregue a página para continuar.';

  @override
  String get crashReload => 'Recarregar';

  @override
  String get homeWelcomeTitle => 'Bem-vindo ao portal';

  @override
  String get homeWelcomeMessage =>
      'Escolha uma área no menu. O que você vê depende do seu papel.';

  @override
  String envBanner(String environment) {
    return 'Ambiente de $environment: os dados desta tela não são de produção.';
  }

  @override
  String homeGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String get loginTitle => 'Entrar no portal';

  @override
  String get loginSubtitle => 'Acesso restrito à equipe do DBook.';

  @override
  String get loginEmail => 'E-mail';

  @override
  String get loginPassword => 'Senha';

  @override
  String get loginSubmit => 'Entrar';

  @override
  String get loginRequired => 'Preencha este campo.';

  @override
  String get loginShowPassword => 'Mostrar senha';

  @override
  String get loginHidePassword => 'Ocultar senha';

  @override
  String get loginRestoring => 'Restaurando sua sessão…';

  @override
  String get idleTitle => 'Você ainda está aí?';

  @override
  String get idleStay => 'Continuar conectado';

  @override
  String get idleLogout => 'Sair agora';

  @override
  String idleMessage(int seconds) {
    return 'Por segurança, a sessão termina em $seconds s sem atividade.';
  }

  @override
  String get sessionExpiredMessage =>
      'Sua sessão terminou por inatividade. Entre de novo; o que estava aberto foi guardado.';

  @override
  String get draftRestoreTitle => 'Recuperar o que você estava escrevendo?';

  @override
  String get draftRestore => 'Recuperar';

  @override
  String get draftDiscard => 'Descartar';

  @override
  String get passwordChangeTitle => 'Trocar a senha';

  @override
  String get passwordCurrent => 'Senha atual';

  @override
  String get passwordNew => 'Nova senha';

  @override
  String get passwordConfirm => 'Repita a nova senha';

  @override
  String get passwordChangeSubmit => 'Trocar senha';

  @override
  String get passwordChanged => 'Senha trocada. Entre de novo.';

  @override
  String get passwordMismatch => 'As senhas não são iguais.';

  @override
  String get passwordRequirementsTitle => 'A senha precisa ter:';

  @override
  String get passwordReqLength => 'Pelo menos 12 caracteres';

  @override
  String get passwordStrengthWeak => 'Fraca';

  @override
  String get passwordStrengthMedium => 'Razoável';

  @override
  String get passwordStrengthStrong => 'Forte';

  @override
  String get passwordMustChange =>
      'Por segurança, troque a senha antes de continuar.';

  @override
  String get inviteAcceptTitle => 'Aceitar convite';

  @override
  String get inviteAcceptSubtitle =>
      'Escolha seu nome e uma senha para entrar na equipe.';

  @override
  String get inviteName => 'Seu nome';

  @override
  String get inviteAcceptSubmit => 'Criar minha conta';

  @override
  String get inviteAccepted => 'Conta criada. Agora é só entrar.';

  @override
  String get inviteMissingToken => 'O link do convite está incompleto.';

  @override
  String get inviteInvalid =>
      'Este convite não é válido: pode ter vencido, já ter sido usado ou ter sido cancelado. Peça um novo a um administrador.';

  @override
  String get inviteGoToLogin => 'Ir para o login';

  @override
  String get twoFactorTitle => 'Verificação em duas etapas';

  @override
  String get twoFactorSubtitle =>
      'Digite o código de 6 dígitos do seu autenticador.';

  @override
  String get twoFactorVerify => 'Verificar';

  @override
  String get twoFactorUseRecovery => 'Usar um código de recuperação';

  @override
  String get twoFactorUseApp => 'Usar o código do autenticador';

  @override
  String get twoFactorRecoveryLabel => 'Código de recuperação';

  @override
  String get twoFactorEnrollTitle => 'Ative a verificação em duas etapas';

  @override
  String get twoFactorEnrollSteps =>
      '1. Abra um app autenticador (Google Authenticator, 1Password, Authy).\n2. Leia o QR code ou digite a chave.\n3. Informe o código de 6 dígitos que o app mostrar.';

  @override
  String get twoFactorManualKey => 'Não consegue ler o QR? Digite esta chave:';

  @override
  String get twoFactorConfirm => 'Confirmar e ativar';

  @override
  String get twoFactorRecoveryTitle => 'Guarde seus códigos de recuperação';

  @override
  String get twoFactorRecoveryMessage =>
      'Cada código vale uma vez e serve se você perder o autenticador. Eles aparecem só agora: guarde em lugar seguro.';

  @override
  String get twoFactorRecoveryDone => 'Guardei os códigos';

  @override
  String get twoFactorRecoveryFile => 'codigos-de-recuperacao-dbook.txt';

  @override
  String twoFactorDigit(int n) {
    return 'Dígito $n';
  }

  @override
  String get twoFactorEnabled => 'Verificação em duas etapas ativa';

  @override
  String get twoFactorDisabled => 'Verificação em duas etapas desligada';

  @override
  String get accountTitle => 'Minha conta';

  @override
  String get accountRole => 'Papel';

  @override
  String get accountEmail => 'E-mail';

  @override
  String get accountChangePassword => 'Trocar a senha';

  @override
  String get accountTwoFactor => 'Verificação em duas etapas';

  @override
  String get accountEnableTwoFactor => 'Ativar';

  @override
  String get accountDisableTwoFactor => 'Desligar';

  @override
  String get accountPermissions => 'O que você pode fazer';

  @override
  String get roleClient => 'Cliente';

  @override
  String get roleSupport => 'Suporte';

  @override
  String get roleCatalogManager => 'Catálogo';

  @override
  String get roleSuperAdmin => 'Administrador';

  @override
  String get roleUnknown => 'Papel desconhecido';

  @override
  String get passwordReqMax => 'No máximo 72 caracteres';

  @override
  String get passwordReqNotEmail => 'Diferente do seu e-mail';

  @override
  String get passwordReqNotCommon =>
      'Fora das listas de senhas comuns (o servidor confere)';

  @override
  String get loginReasonIdle =>
      'Sua sessão terminou por inatividade. Entre de novo; o que você estava escrevendo foi guardado nesta aba.';

  @override
  String get loginReasonExpired => 'Sua sessão expirou. Entre de novo.';

  @override
  String get loginReasonLoggedOut => 'Você saiu do portal.';

  @override
  String get twoFactorBack => 'Voltar ao login';

  @override
  String get twoFactorDisableTitle => 'Desligar a verificação em duas etapas';

  @override
  String get twoFactorDisablePassword => 'Sua senha';

  @override
  String get twoFactorDisableCode => 'Código do autenticador';

  @override
  String get twoFactorDisableSubmit => 'Desligar';

  @override
  String get twoFactorRequiredByRole =>
      'Seu papel exige a verificação em duas etapas, então ela não pode ser desligada.';

  @override
  String get twoFactorEnrollLoading => 'Preparando o cadastro…';

  @override
  String get twoFactorRecoveryAck => 'Guardei os códigos em um lugar seguro';

  @override
  String get passwordRepeatHint => 'Digite a mesma senha de novo';

  @override
  String get passwordShow => 'Mostrar senha';

  @override
  String get passwordHide => 'Ocultar senha';

  @override
  String get inviteSuccessTitle => 'Tudo certo';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get accountSessionNote =>
      'Trocar a senha encerra todas as suas sessões.';

  @override
  String get accountNoPermissions =>
      'Seu papel não inclui permissões de gestão.';

  @override
  String accountPermissionCount(int count) {
    return '$count permissões';
  }

  @override
  String get envNameLocal => 'desenvolvimento local';

  @override
  String get envNameStaging => 'homologação';

  @override
  String get navSkipToContent => 'Pular para o conteúdo';

  @override
  String get roleDescSupport =>
      'Atende clientes: consulta clientes e reservas, cancela, reembolsa, modera avaliações e vê o painel.';

  @override
  String get roleDescCatalogManager =>
      'Cuida do catálogo: voos, companhias, aeroportos, promoções e vê o painel.';

  @override
  String get roleDescSuperAdmin =>
      'Acesso total, inclusive equipe, auditoria, exportação e anonimização de dados de clientes.';

  @override
  String get teamTitle => 'Equipe';

  @override
  String get teamTabStaff => 'Pessoas';

  @override
  String get teamTabInvitations => 'Convites';

  @override
  String get teamInvite => 'Convidar pessoa';

  @override
  String get teamColName => 'Nome';

  @override
  String get teamColRole => 'Papel';

  @override
  String get teamColStatus => 'Situação';

  @override
  String get teamColLastAccess => 'Último acesso';

  @override
  String get teamColActions => 'Ações';

  @override
  String get teamNeverAccessed => 'Nunca entrou';

  @override
  String get teamStatusActive => 'Ativa';

  @override
  String get teamStatusBlocked => 'Bloqueada';

  @override
  String get teamStatusUnknown => 'Desconhecida';

  @override
  String get teamEmpty => 'Ninguém na equipe ainda';

  @override
  String get teamEmptyMessage => 'Convide a primeira pessoa.';

  @override
  String get teamChangeRole => 'Alterar papel';

  @override
  String get teamBlock => 'Bloquear';

  @override
  String get teamUnblock => 'Desbloquear';

  @override
  String teamActionsFor(String name) {
    return 'Ações para $name';
  }

  @override
  String get teamSelfReason =>
      'Você não pode alterar a si mesmo. Peça a outro administrador.';

  @override
  String get teamLastSuperAdminReason =>
      'Esta é a última pessoa com acesso total ativa. Dê o papel a outra antes.';

  @override
  String teamChangeRoleTitle(String name) {
    return 'Alterar o papel de $name';
  }

  @override
  String teamChangeRoleConsequence(String name) {
    return 'As sessões de $name serão encerradas e ela entra de novo já com o novo papel.';
  }

  @override
  String get teamChangeRoleSubmit => 'Alterar papel';

  @override
  String get teamRoleChanged => 'Papel alterado.';

  @override
  String teamBlockTitle(String name) {
    return 'Bloquear $name';
  }

  @override
  String teamBlockConsequence(String name) {
    return '$name perde o acesso agora e as sessões abertas são encerradas. Dá para desbloquear depois.';
  }

  @override
  String get teamBlockReason => 'Motivo do bloqueio';

  @override
  String get teamBlocked => 'Pessoa bloqueada.';

  @override
  String get teamUnblocked => 'Pessoa desbloqueada.';

  @override
  String teamUnblockTitle(String name) {
    return 'Desbloquear $name';
  }

  @override
  String teamUnblockMessage(String name) {
    return '$name volta a poder entrar no portal.';
  }

  @override
  String get inviteTitle => 'Convidar pessoa para a equipe';

  @override
  String get inviteEmail => 'E-mail';

  @override
  String get inviteRole => 'Papel';

  @override
  String get inviteSubmit => 'Enviar convite';

  @override
  String get inviteSent => 'Convite enviado.';

  @override
  String get inviteResent => 'Novo link enviado; o anterior parou de valer.';

  @override
  String get inviteRevoked => 'Convite cancelado.';

  @override
  String get inviteColEmail => 'E-mail';

  @override
  String get inviteColRole => 'Papel';

  @override
  String get inviteColStatus => 'Situação';

  @override
  String get inviteColExpires => 'Vale até';

  @override
  String get inviteStatusPending => 'Válido';

  @override
  String get inviteStatusAccepted => 'Aceito';

  @override
  String get inviteStatusExpired => 'Vencido';

  @override
  String get inviteStatusRevoked => 'Cancelado';

  @override
  String get inviteStatusUnknown => 'Desconhecido';

  @override
  String get inviteResend => 'Reenviar';

  @override
  String get inviteRevoke => 'Cancelar convite';

  @override
  String inviteRevokeTitle(String email) {
    return 'Cancelar o convite de $email?';
  }

  @override
  String get inviteRevokeMessage =>
      'O link deixa de funcionar na hora. Dá para convidar de novo depois.';

  @override
  String get inviteEmpty => 'Nenhum convite';

  @override
  String get inviteEmptyMessage =>
      'Os convites enviados aparecem aqui, com a situação de cada um.';

  @override
  String get inviteInvalidEmail => 'Informe um e-mail válido.';

  @override
  String get inviteAlreadyHasAccount => 'Já existe uma conta com este e-mail.';

  @override
  String get customersTitle => 'Clientes';

  @override
  String get customersSearchHint => 'Buscar por nome ou e-mail';

  @override
  String get customersColName => 'Cliente';

  @override
  String get customersColStatus => 'Situação';

  @override
  String get customersColBookings => 'Reservas';

  @override
  String get customersColCreated => 'Cliente desde';

  @override
  String get customersColLastLogin => 'Último acesso';

  @override
  String get customersFilterActive => 'Ativos';

  @override
  String get customersFilterBlocked => 'Bloqueados';

  @override
  String get customersFilterWithBookings => 'Com reservas';

  @override
  String get customersFilterWithoutBookings => 'Sem reservas';

  @override
  String get customersEmpty => 'Nenhum cliente encontrado';

  @override
  String get customersEmptyMessage => 'Tente outra busca ou limpe os filtros.';

  @override
  String get customerStatusActive => 'Ativo';

  @override
  String get customerStatusBlocked => 'Bloqueado';

  @override
  String get customerStatusUnknown => 'Desconhecido';

  @override
  String get customerAnonymizedBadge => 'Anonimizado';

  @override
  String get customerNeverAccessed => 'Nunca acessou';

  @override
  String get customerBackToList => 'Clientes';

  @override
  String get kpiBookings => 'Reservas';

  @override
  String get kpiTotalPaid => 'Total pago';

  @override
  String get kpiAverageRating => 'Nota média';

  @override
  String get kpiNoRating => 'Sem avaliações';

  @override
  String get tabBookings => 'Reservas';

  @override
  String get tabPayments => 'Pagamentos';

  @override
  String get tabReviews => 'Avaliações';

  @override
  String get tabNotes => 'Notas';

  @override
  String get tabHistory => 'Histórico';

  @override
  String get customerBlock => 'Bloquear cliente';

  @override
  String get customerUnblock => 'Desbloquear cliente';

  @override
  String get customerAnonymize => 'Anonimizar dados';

  @override
  String get customerExport => 'Exportar CSV';

  @override
  String get customerBlockMessage =>
      'O cliente não consegue mais entrar nem reservar. Dá para desbloquear depois.';

  @override
  String get customerBlockReason => 'Motivo (obrigatório)';

  @override
  String get customerBlockSubmit => 'Bloquear';

  @override
  String get customerBlocked => 'Cliente bloqueado.';

  @override
  String get customerUnblocked => 'Cliente desbloqueado.';

  @override
  String get customerUnblockMessage =>
      'O cliente volta a poder entrar e reservar.';

  @override
  String get noteTitle => 'Notas internas';

  @override
  String get noteLabel => 'Nota interna (só a equipe vê)';

  @override
  String get noteAdd => 'Adicionar nota';

  @override
  String get notePin => 'Fixar';

  @override
  String get noteUnpin => 'Desafixar';

  @override
  String get notePinned => 'Fixada';

  @override
  String get noteEdited => 'editada';

  @override
  String get noteEdit => 'Editar nota';

  @override
  String get noteDelete => 'Apagar nota';

  @override
  String get noteDeleteTitle => 'Apagar esta nota?';

  @override
  String get noteDeleteMessage => 'A nota some para toda a equipe.';

  @override
  String get noteSaved => 'Nota salva.';

  @override
  String get noteDeleted => 'Nota apagada.';

  @override
  String get notesEmpty => 'Nenhuma nota ainda';

  @override
  String get notesEmptyMessage =>
      'Registre aqui o que a equipe precisa saber sobre este cliente.';

  @override
  String get customerAnonymizeConsequence =>
      'Nome, e-mail e dados pessoais deste cliente serão apagados de forma definitiva. As reservas e os pagamentos ficam, sem identificação. Não dá para desfazer.';

  @override
  String get customerAnonymizeReason => 'Motivo (obrigatório)';

  @override
  String get customerAnonymizeSubmit => 'Anonimizar para sempre';

  @override
  String get customerAnonymizedDone => 'Dados anonimizados.';

  @override
  String get exportTitle => 'Exportar clientes';

  @override
  String get exportCeiling => 'O arquivo tem no máximo 50.000 linhas.';

  @override
  String get exportContents =>
      'Colunas: id, nome, e-mail, situação, cadastro, último acesso e total de reservas. A exportação fica registrada na auditoria.';

  @override
  String get exportStart => 'Exportar';

  @override
  String get exportRunning => 'Gerando o arquivo…';

  @override
  String get exportDone => 'Arquivo baixado.';

  @override
  String get exportAllCustomers => 'todos os clientes';

  @override
  String get exportNotAvailable => 'O download só funciona no navegador.';

  @override
  String get bookingColId => 'Reserva';

  @override
  String get bookingColItem => 'Item';

  @override
  String get bookingColStatus => 'Situação';

  @override
  String get bookingColPrice => 'Valor';

  @override
  String get bookingColDeparture => 'Partida';

  @override
  String get bookingColCustomer => 'Cliente';

  @override
  String get bookingColCreated => 'Criada em';

  @override
  String get paymentColId => 'Pagamento';

  @override
  String get paymentColAmount => 'Valor';

  @override
  String get paymentColCard => 'Cartão';

  @override
  String get paymentColDate => 'Data';

  @override
  String get reviewColRating => 'Nota';

  @override
  String get reviewColComment => 'Comentário';

  @override
  String get reviewColDate => 'Data';

  @override
  String get tabEmptyBookings => 'Sem reservas';

  @override
  String get tabEmptyPayments => 'Sem pagamentos';

  @override
  String get tabEmptyReviews => 'Sem avaliações';

  @override
  String get tabEmptyHistory => 'Sem registros';

  @override
  String get tabEmptyHint => 'Nada para mostrar aqui ainda.';

  @override
  String get bookingStatusPending => 'Pendente';

  @override
  String get bookingStatusConfirmed => 'Confirmada';

  @override
  String get bookingStatusCancelled => 'Cancelada';

  @override
  String get bookingStatusExpired => 'Expirada';

  @override
  String get bookingStatusRefunded => 'Reembolsada';

  @override
  String get bookingStatusUnknown => 'Desconhecida';

  @override
  String get auditColWhen => 'Quando';

  @override
  String get auditColAction => 'Ação';

  @override
  String get auditColActor => 'Quem';

  @override
  String get auditColOutcome => 'Resultado';

  @override
  String get auditColTarget => 'Alvo';

  @override
  String get auditOutcomeSuccess => 'Feito';

  @override
  String get auditOutcomeDenied => 'Negado';

  @override
  String customerSince(String date) {
    return 'Cliente desde $date';
  }

  @override
  String customerLastAccess(String date) {
    return 'Último acesso $date';
  }

  @override
  String customerBlockedBanner(String date, String reason) {
    return 'Cliente bloqueado desde $date. Motivo: $reason';
  }

  @override
  String customerAnonymizedBanner(String date) {
    return 'Dados anonimizados em $date. Esta conta não pode ser reativada.';
  }

  @override
  String customerBlockTitle(String name) {
    return 'Bloquear $name';
  }

  @override
  String customerUnblockTitle(String name) {
    return 'Desbloquear $name';
  }

  @override
  String customerBlockReasonCounter(int min, int count) {
    return 'Mínimo de $min caracteres ($count escritos)';
  }

  @override
  String customerAnonymizeTitle(String name) {
    return 'Anonimizar $name';
  }

  @override
  String customerAnonymizePhrase(String phrase) {
    return 'Para confirmar, digite $phrase';
  }

  @override
  String noteBy(String author, String date) {
    return 'por $author em $date';
  }

  @override
  String exportMessage(String filters) {
    return 'Será gerado um CSV com o que os filtros atuais mostram: $filters.';
  }

  @override
  String customersChipStatus(String value) {
    return 'Situação: $value';
  }

  @override
  String customersChipBookings(String value) {
    return 'Reservas: $value';
  }

  @override
  String customersChipSort(String value) {
    return 'Ordem: $value';
  }

  @override
  String get auditActionFlightCreated => 'Voo cadastrado';

  @override
  String get auditActionBookingCancelledByStaff =>
      'Reserva cancelada pela equipe';

  @override
  String get auditActionAccessDenied => 'Acesso negado';

  @override
  String get auditActionStaffInvited => 'Convite enviado';

  @override
  String get auditActionStaffInvitationResent => 'Convite reenviado';

  @override
  String get auditActionStaffInvitationRevoked => 'Convite cancelado';

  @override
  String get auditActionStaffInvitationAccepted => 'Convite aceito';

  @override
  String get auditActionStaffRoleChanged => 'Papel alterado';

  @override
  String get auditActionStaffBlocked => 'Pessoa da equipe bloqueada';

  @override
  String get auditActionStaffUnblocked => 'Pessoa da equipe desbloqueada';

  @override
  String get auditActionCustomerViewed => 'Cliente consultado';

  @override
  String get auditActionCustomerBlocked => 'Cliente bloqueado';

  @override
  String get auditActionCustomerUnblocked => 'Cliente desbloqueado';

  @override
  String get auditActionCustomerNoteAdded => 'Nota adicionada';

  @override
  String get auditActionCustomerNoteEdited => 'Nota editada';

  @override
  String get auditActionCustomerNoteDeleted => 'Nota apagada';

  @override
  String get auditActionCustomerExported => 'Clientes exportados';

  @override
  String get auditActionCustomerAnonymized => 'Cliente anonimizado';

  @override
  String get auditActionCustomerDataExported => 'Dados do cliente exportados';

  @override
  String get auditActionFlightUpdated => 'Voo alterado';

  @override
  String get auditActionFlightCancelled => 'Voo cancelado';

  @override
  String get auditActionFlightsImported => 'Voos importados';

  @override
  String get auditActionAirlineCreated => 'Companhia criada';

  @override
  String get auditActionAirlineUpdated => 'Companhia alterada';

  @override
  String get auditActionAirlineDeleted => 'Companhia removida';

  @override
  String get auditActionAirportCreated => 'Aeroporto criado';

  @override
  String get auditActionAirportUpdated => 'Aeroporto alterado';

  @override
  String get auditActionAirportDeleted => 'Aeroporto removido';

  @override
  String get auditActionRefundRequested => 'Reembolso pedido';

  @override
  String get auditActionRefundRetried => 'Reembolso tentado de novo';

  @override
  String get auditActionRefundCompleted => 'Reembolso concluído';

  @override
  String get auditActionRefundFailed => 'Reembolso falhou';

  @override
  String get auditActionReviewHidden => 'Avaliação ocultada';

  @override
  String get auditActionReviewRestored => 'Avaliação restaurada';

  @override
  String get auditActionReviewReportsDismissed => 'Denúncias dispensadas';

  @override
  String get auditActionPromoCreated => 'Promoção criada';

  @override
  String get auditActionPromoUpdated => 'Promoção alterada';

  @override
  String get auditActionPromoActivated => 'Promoção ativada';

  @override
  String get auditActionPromoDeactivated => 'Promoção desativada';

  @override
  String get auditActionAccommodationCreated => 'Hotel criado';

  @override
  String get auditActionAccommodationUpdated => 'Hotel alterado';

  @override
  String get auditActionAccommodationActivated => 'Hotel ativado';

  @override
  String get auditActionAccommodationDeactivated => 'Hotel desativado';

  @override
  String get auditActionRoomTypeChanged => 'Quarto alterado';

  @override
  String get auditActionTwoFactorEnabled => 'Segundo fator ligado';

  @override
  String get auditActionTwoFactorDisabled => 'Segundo fator desligado';

  @override
  String get auditActionTwoFactorReset => 'Segundo fator removido';

  @override
  String get bookingsTitle => 'Reservas';

  @override
  String get bookingsEmpty => 'Nenhuma reserva encontrada';

  @override
  String get bookingsEmptyMessage =>
      'Ajuste os filtros ou limpe-os para ver todas.';

  @override
  String get bookingsFilterPaid => 'Pagas';

  @override
  String get bookingsFilterUnpaid => 'Não pagas';

  @override
  String get bookingsFilterStatusAll => 'Todas as situações';

  @override
  String get bookingsFilterStatus => 'Situação';

  @override
  String get bookingColPaid => 'Pagamento';

  @override
  String get bookingPaidYes => 'Pago';

  @override
  String get bookingPaidNo => 'Em aberto';

  @override
  String get bookingTimelineTitle => 'Linha do tempo';

  @override
  String get bookingTimelineCreated => 'Reserva criada';

  @override
  String get bookingTimelineBySystem => 'pelo sistema';

  @override
  String get bookingPaymentTitle => 'Pagamento';

  @override
  String get bookingRefundTitle => 'Reembolso';

  @override
  String get bookingNoPayment => 'Ainda não foi paga.';

  @override
  String get bookingNoRefund => 'Sem reembolso.';

  @override
  String get bookingCustomerLink => 'Abrir cliente';

  @override
  String get bookingPaidAmount => 'Valor pago';

  @override
  String get bookingDiscount => 'Desconto';

  @override
  String get bookingFrozenPrice => 'Valor da reserva';

  @override
  String get bookingCard => 'Cartão';

  @override
  String get bookingItem => 'Item';

  @override
  String get bookingSeat => 'Assento';

  @override
  String get bookingRoute => 'Trajeto';

  @override
  String get bookingCustomer => 'Cliente';

  @override
  String get bookingCancel => 'Cancelar reserva';

  @override
  String get bookingCancelMessage =>
      'O assento volta a ficar livre. Só reservas pendentes podem ser canceladas.';

  @override
  String get bookingCancelDone => 'Reserva cancelada.';

  @override
  String get bookingRefund => 'Reembolsar';

  @override
  String get bookingsBackToList => 'Reservas';

  @override
  String get refundReasonLabel => 'Motivo';

  @override
  String get refundReasonCustomerRequest => 'Pedido do cliente';

  @override
  String get refundReasonFlightCancelled => 'Voo cancelado';

  @override
  String get refundReasonDuplicate => 'Cobrança duplicada';

  @override
  String get refundReasonOther => 'Outro motivo';

  @override
  String get refundNoteLabel => 'Observação';

  @override
  String get refundNoteRequired =>
      'A observação é obrigatória para uma exceção de política.';

  @override
  String get refundOverride => 'Exceção de política (ignorar o prazo)';

  @override
  String get refundOverrideHelp =>
      'Só administradores. Exige uma observação e fica registrada na auditoria.';

  @override
  String get refundSubmit => 'Reembolsar';

  @override
  String get refundProcessing => 'Processando…';

  @override
  String get refundDone => 'Reembolso concluído.';

  @override
  String get refundFailedTitle => 'O reembolso falhou';

  @override
  String get refundFailedMessage =>
      'O dinheiro não saiu. Você pode tentar de novo: nada será devolvido em duplicidade.';

  @override
  String get refundRetry => 'Tentar de novo';

  @override
  String get refundRequestedNote =>
      'O pedido foi registrado e ainda não terminou. Tente de novo para concluir.';

  @override
  String get refundStatusRequested => 'Pedido';

  @override
  String get refundStatusCompleted => 'Concluído';

  @override
  String get refundStatusFailed => 'Falhou';

  @override
  String get refundStatusUnknown => 'Desconhecido';

  @override
  String get refundsTitle => 'Reembolsos';

  @override
  String get refundsFilterAll => 'Todos';

  @override
  String get refundColId => 'Reembolso';

  @override
  String get refundColBooking => 'Reserva';

  @override
  String get refundColAmount => 'Valor';

  @override
  String get refundColStatus => 'Situação';

  @override
  String get refundColReason => 'Motivo';

  @override
  String get refundColDate => 'Pedido em';

  @override
  String get refundOpenBooking => 'Abrir reserva';

  @override
  String get refundsEmpty => 'Nenhum reembolso';

  @override
  String get refundsEmptyMessage =>
      'Os reembolsos aparecem aqui, com a situação de cada um.';

  @override
  String get refundConflict =>
      'Outra pessoa mexeu nesta reserva agora. Recarreguei os dados: confira e tente de novo.';

  @override
  String bookingsChipCustomer(int id) {
    return 'Cliente #$id';
  }

  @override
  String bookingsChipFlight(int id) {
    return 'Voo #$id';
  }

  @override
  String bookingsChipStatus(String value) {
    return 'Situação: $value';
  }

  @override
  String bookingsChipPaid(String value) {
    return 'Pagamento: $value';
  }

  @override
  String bookingDetailTitle(int id) {
    return 'Reserva #$id';
  }

  @override
  String bookingTimelineChanged(String from, String to) {
    return '$from → $to';
  }

  @override
  String bookingTimelineBy(int actor) {
    return 'por pessoa #$actor';
  }

  @override
  String bookingCancelTitle(int id) {
    return 'Cancelar a reserva #$id?';
  }

  @override
  String refundTitle(int id) {
    return 'Reembolsar a reserva #$id';
  }

  @override
  String refundSummaryAmount(String amount) {
    return 'Valor a devolver: $amount';
  }

  @override
  String get refundPolicy =>
      'O reembolso é do valor pago, por inteiro. Só é possível até 24 horas antes da partida.';

  @override
  String refundPolicyDeadline(String date) {
    return 'O reembolso é do valor pago, por inteiro. Só é possível até 24 horas antes da partida (limite: $date).';
  }

  @override
  String get flightsTitle => 'Voos';

  @override
  String get flightsNew => 'Novo voo';

  @override
  String get flightsImport => 'Importar CSV';

  @override
  String get flightsEmpty => 'Nenhum voo encontrado';

  @override
  String get flightsEmptyMessage => 'Ajuste os filtros ou cadastre um voo.';

  @override
  String get flightsFilterOrigin => 'Origem (IATA)';

  @override
  String get flightsFilterDestination => 'Destino (IATA)';

  @override
  String get flightsFilterAirline => 'Companhia (IATA)';

  @override
  String get flightsFilterStatus => 'Situação';

  @override
  String get flightsFilterStatusAll => 'Todas';

  @override
  String get flightStatusScheduled => 'Programado';

  @override
  String get flightStatusCancelled => 'Cancelado';

  @override
  String get flightStatusUnknown => 'Desconhecido';

  @override
  String get flightColNumber => 'Voo';

  @override
  String get flightColRoute => 'Trajeto';

  @override
  String get flightColDeparture => 'Partida';

  @override
  String get flightColArrival => 'Chegada';

  @override
  String get flightColPrice => 'Preço';

  @override
  String get flightColSeats => 'Assentos';

  @override
  String get flightColStatus => 'Situação';

  @override
  String get flightColClass => 'Classe';

  @override
  String get flightSeatsFree => 'livres';

  @override
  String get flightSeatsReserved => 'reservados';

  @override
  String get seatClassEconomy => 'Econômica';

  @override
  String get seatClassPremiumEconomy => 'Econômica premium';

  @override
  String get seatClassBusiness => 'Executiva';

  @override
  String get seatClassFirst => 'Primeira classe';

  @override
  String get seatClassUnknown => 'Desconhecida';

  @override
  String get flightFormNewTitle => 'Novo voo';

  @override
  String get flightFormNumber => 'Número do voo';

  @override
  String get flightFormAirline => 'Companhia';

  @override
  String get flightFormOrigin => 'Origem';

  @override
  String get flightFormDestination => 'Destino';

  @override
  String get flightFormDeparture => 'Partida';

  @override
  String get flightFormArrival => 'Chegada';

  @override
  String get flightFormClass => 'Classe';

  @override
  String get flightFormPrice => 'Preço (R\$)';

  @override
  String get flightFormCapacity => 'Capacidade';

  @override
  String get flightFormAircraft => 'Avião';

  @override
  String get flightFormPickDateTime => 'Escolher data e hora';

  @override
  String get flightFormSave => 'Salvar voo';

  @override
  String get flightFormSaved => 'Voo salvo.';

  @override
  String get flightFormCreated => 'Voo cadastrado.';

  @override
  String get flightFormRequired => 'Preencha este campo.';

  @override
  String get flightFormArrivalAfterDeparture =>
      'A chegada precisa ser depois da partida.';

  @override
  String get flightFormSameAirport =>
      'Origem e destino não podem ser o mesmo aeroporto.';

  @override
  String get flightFormPriceInvalid => 'Informe um preço maior que zero.';

  @override
  String get flightFormCapacityInvalid =>
      'Informe uma capacidade inteira maior que zero.';

  @override
  String get flightFormCancelledReadOnly =>
      'Este voo está cancelado e não pode mais ser editado.';

  @override
  String get flightFormAircraftLocked =>
      'O avião não pode mudar: já há assentos reservados neste voo.';

  @override
  String get flightFormBackToList => 'Voos';

  @override
  String get flightCancel => 'Cancelar voo';

  @override
  String get flightCancelDone => 'Voo cancelado.';

  @override
  String get flightCancelBlocked =>
      'Este voo tem reservas ativas. Reembolse ou cancele cada uma antes de cancelar o voo.';

  @override
  String get flightCancelMessage =>
      'O voo sai da busca e não pode mais ser reservado nem editado. Não dá para desfazer.';

  @override
  String get conflictTitle => 'Outro administrador alterou este voo';

  @override
  String get conflictMessage =>
      'Enquanto você editava, o voo mudou. Veja abaixo o que é diferente e escolha o que fazer.';

  @override
  String get conflictColField => 'Campo';

  @override
  String get conflictColMine => 'Sua versão';

  @override
  String get conflictColTheirs => 'No servidor agora';

  @override
  String get conflictReload => 'Recarregar e descartar minhas mudanças';

  @override
  String get conflictKeepMine => 'Salvar as minhas mudanças por cima';

  @override
  String get conflictNoDifferences =>
      'Nada que você editou difere do que está salvo. Dá para recarregar com segurança.';

  @override
  String get airlinesTitle => 'Companhias';

  @override
  String get airlinesNew => 'Nova companhia';

  @override
  String get airlineColCode => 'Código IATA';

  @override
  String get airlineColName => 'Nome';

  @override
  String get airlineSaved => 'Companhia salva.';

  @override
  String get airlineDeleted => 'Companhia removida.';

  @override
  String get airlineFormTitleNew => 'Nova companhia';

  @override
  String get airlineFormTitleEdit => 'Editar companhia';

  @override
  String get airlineFormCode => 'Código IATA (2 letras ou números)';

  @override
  String get airlineFormName => 'Nome';

  @override
  String get airlineFormLogo => 'Logo (endereço https, opcional)';

  @override
  String get airlineLogoInvalid => 'Use um endereço que comece com https://';

  @override
  String get airlineCodeInvalid =>
      'São 2 letras ou números (por exemplo LA ou G3).';

  @override
  String get airportsTitle => 'Aeroportos';

  @override
  String get airportsNew => 'Novo aeroporto';

  @override
  String get airportColCode => 'Código IATA';

  @override
  String get airportColName => 'Nome';

  @override
  String get airportColCity => 'Cidade';

  @override
  String get airportColCountry => 'País';

  @override
  String get airportColRegion => 'Região';

  @override
  String get airportColPopular => 'Destaque';

  @override
  String get airportSaved => 'Aeroporto salvo.';

  @override
  String get airportDeleted => 'Aeroporto removido.';

  @override
  String get airportFormTitleNew => 'Novo aeroporto';

  @override
  String get airportFormTitleEdit => 'Editar aeroporto';

  @override
  String get airportFormCode => 'Código IATA (3 letras)';

  @override
  String get airportFormName => 'Nome';

  @override
  String get airportFormCity => 'Cidade';

  @override
  String get airportFormCountry => 'País';

  @override
  String get airportFormPhoto => 'Endereço da foto';

  @override
  String get airportFormRegion => 'Região';

  @override
  String get airportFormPopular => 'Aparece nos destinos em destaque';

  @override
  String get airportCodeInvalid => 'São 3 letras (por exemplo GRU).';

  @override
  String get catalogEdit => 'Editar';

  @override
  String get catalogDelete => 'Remover';

  @override
  String get catalogDeleteInUse => 'Só dá para remover o que nenhum voo usa.';

  @override
  String get catalogDeleteMessage => 'Esta ação não pode ser desfeita.';

  @override
  String get importTitle => 'Importar voos por CSV';

  @override
  String get importIntro =>
      'Escolha um arquivo CSV. Primeiro conferimos tudo sem gravar nada; só depois de você confirmar os voos são criados.';

  @override
  String get importColumns =>
      'Colunas: flightNumber, airlineIataCode, originIataCode, destinationIataCode, departureTime, arrivalTime, seatClass, price, totalCapacity, aircraftType. Máximo de 5.000 linhas.';

  @override
  String get importChoose => 'Escolher arquivo';

  @override
  String get importChooseAnother => 'Escolher outro arquivo';

  @override
  String get importChecking => 'Conferindo o arquivo…';

  @override
  String get importConfirm => 'Confirmar importação';

  @override
  String get importConfirming => 'Importando…';

  @override
  String get importErrorsTitle => 'Há linhas com erro. Nada foi gravado.';

  @override
  String get importErrorsHint =>
      'Corrija o arquivo e escolha-o de novo. Todas as linhas com erro estão destacadas abaixo.';

  @override
  String get importOkTitle => 'O arquivo está certo.';

  @override
  String get importDoneTitle => 'Importação concluída';

  @override
  String get importColLine => 'Linha';

  @override
  String get importColProblem => 'Problema';

  @override
  String get importPreviewTitle => 'Pré-visualização';

  @override
  String get importPreviewTruncated =>
      'Mostrando só as primeiras linhas do arquivo.';

  @override
  String get importNotAvailable => 'Escolher arquivo só funciona no navegador.';

  @override
  String flightFormEditTitle(String number) {
    return 'Editar voo $number';
  }

  @override
  String flightFormReserved(int count) {
    return '$count assentos reservados: a capacidade não pode ficar abaixo disso.';
  }

  @override
  String flightCancelTitle(String number) {
    return 'Cancelar o voo $number?';
  }

  @override
  String flightCancelActive(int count) {
    return '$count reservas ativas';
  }

  @override
  String airlinesDeleteTitle(String name) {
    return 'Remover a companhia $name?';
  }

  @override
  String airportsDeleteTitle(String name) {
    return 'Remover o aeroporto $name?';
  }

  @override
  String importSummaryOk(int total, int create, int existing) {
    return '$total linhas: $create voos serão criados e $existing já existem.';
  }

  @override
  String importSummaryDone(int created, int existing) {
    return '$created voos criados; $existing já existiam.';
  }

  @override
  String importLineErrors(int count) {
    return '$count linhas com erro';
  }

  @override
  String get errFlightRule =>
      'O servidor recusou a alteração por uma regra do voo: capacidade abaixo dos assentos reservados, assento com histórico ou avião bloqueado. Confira os campos.';

  @override
  String get dashboardTitle => 'Painel';

  @override
  String get dashboardRefresh => 'Atualizar agora';

  @override
  String get dashboardNow => 'agora';

  @override
  String get kpiNetRevenue => 'Receita líquida';

  @override
  String get kpiGrossRevenue => 'Receita bruta';

  @override
  String get kpiRefunded => 'Reembolsado';

  @override
  String get kpiCreatedBookings => 'Reservas criadas';

  @override
  String get kpiNewCustomers => 'Clientes novos';

  @override
  String get kpiConversion => 'Conversão';

  @override
  String get kpiExpiration => 'Expiração';

  @override
  String get kpiOccupancy => 'Ocupação';

  @override
  String get kpiNotApplicable => 'Sem reservas no período';

  @override
  String get kpiVsPrevious => 'vs. período anterior';

  @override
  String get glossNetRevenue =>
      'Receita bruta menos o que foi reembolsado, no período.';

  @override
  String get glossGrossRevenue =>
      'Soma do valor das reservas pagas no período. Conta o dia do pagamento, não o da criação.';

  @override
  String get glossRefunded =>
      'Soma dos reembolsos concluídos no período, no dia em que concluíram.';

  @override
  String get glossBookings =>
      'Reservas criadas no período, pela situação de agora.';

  @override
  String get glossNewCustomers =>
      'Contas de cliente criadas no período (a equipe não conta).';

  @override
  String get glossConversion =>
      'Das reservas criadas no período, quantas foram pagas alguma vez (mesmo reembolsadas depois).';

  @override
  String get glossExpiration =>
      'Das reservas criadas no período, quantas o sistema cancelou por falta de pagamento.';

  @override
  String get glossOccupancy =>
      'Assentos reservados dos voos que partem no período, sobre a capacidade deles. Só voos à venda; reserva pendente também ocupa assento.';

  @override
  String get seriesTitle => 'Evolução';

  @override
  String get metricRevenue => 'Receita líquida';

  @override
  String get metricBookings => 'Reservas';

  @override
  String get metricNewCustomers => 'Clientes novos';

  @override
  String get granularityDay => 'Por dia';

  @override
  String get granularityWeek => 'Por semana';

  @override
  String get chartAsTable => 'Ver como tabela';

  @override
  String get chartAsChart => 'Ver como gráfico';

  @override
  String get chartColDate => 'Data';

  @override
  String get chartColValue => 'Valor';

  @override
  String get chartEmpty => 'Sem dados no período.';

  @override
  String get topRoutesTitle => 'Rotas mais vendidas';

  @override
  String get topRoutesColRoute => 'Rota';

  @override
  String get topRoutesColBookings => 'Reservas pagas';

  @override
  String get topRoutesColRevenue => 'Receita';

  @override
  String get topRoutesEmpty => 'Nenhuma venda no período.';

  @override
  String get periodLabel => 'Período';

  @override
  String dashboardUpdated(String ago) {
    return 'Atualizado $ago';
  }

  @override
  String chartSummary(
    String metric,
    int count,
    String min,
    String max,
    String total,
  ) {
    return '$metric: $count pontos, de $min a $max, total de $total.';
  }

  @override
  String get auditTitle => 'Auditoria';

  @override
  String get auditFilterAction => 'Ação';

  @override
  String get auditFilterActionAll => 'Todas as ações';

  @override
  String get auditFilterOutcome => 'Resultado';

  @override
  String get auditFilterOutcomeAll => 'Todos';

  @override
  String get auditFilterActor => 'Quem (id)';

  @override
  String get auditFilterTargetType => 'Tipo do alvo';

  @override
  String get auditFilterTargetId => 'Id do alvo';

  @override
  String get auditApply => 'Filtrar';

  @override
  String get auditExpand => 'Ver antes e depois';

  @override
  String get auditCollapse => 'Recolher';

  @override
  String get auditNoState => 'Esta ação não guarda estado antes e depois.';

  @override
  String get auditChangeAdded => 'Criado';

  @override
  String get auditChangeChanged => 'Alterado';

  @override
  String get auditChangeRemoved => 'Removido';

  @override
  String get auditChangeUnchanged => 'Igual';

  @override
  String get auditColField => 'Campo';

  @override
  String get auditColBefore => 'Antes';

  @override
  String get auditColAfter => 'Depois';

  @override
  String get auditLoadMore => 'Carregar mais';

  @override
  String get auditLoadingMore => 'Carregando…';

  @override
  String get auditEmpty => 'Nenhum registro';

  @override
  String get auditEmptyMessage =>
      'Ajuste os filtros: nada na trilha combina com eles.';

  @override
  String get auditShowUnchanged => 'Mostrar campos iguais';

  @override
  String get auditReasonLabel => 'Motivo';

  @override
  String get auditRequestLabel => 'Requisição';

  @override
  String get auditIpLabel => 'IP';

  @override
  String get reviewsTitle => 'Avaliações';

  @override
  String get reviewsQueueReported => 'Denunciadas';

  @override
  String get reviewsQueueHidden => 'Ocultas';

  @override
  String get reviewsQueueVisible => 'Visíveis';

  @override
  String get reviewColCustomer => 'Cliente';

  @override
  String get reviewColDestination => 'Destino';

  @override
  String get reviewColReports => 'Denúncias';

  @override
  String get reviewColStatus => 'Situação';

  @override
  String get reviewColText => 'Avaliação';

  @override
  String get reviewHide => 'Ocultar';

  @override
  String get reviewRestore => 'Restaurar';

  @override
  String get reviewDismiss => 'Dispensar denúncias';

  @override
  String get reviewHideReason => 'Motivo (10 a 500 caracteres)';

  @override
  String get reviewHideSubmit => 'Ocultar avaliação';

  @override
  String get reviewHiddenDone => 'Avaliação ocultada.';

  @override
  String get reviewRestoredDone => 'Avaliação restaurada.';

  @override
  String get reviewDismissedDone => 'Denúncias dispensadas.';

  @override
  String get reviewsEmpty => 'Nada por aqui';

  @override
  String get reviewsEmptyMessage => 'Nenhuma avaliação nesta fila.';

  @override
  String get reviewStatusHidden => 'Oculta';

  @override
  String get reviewStatusVisible => 'Visível';

  @override
  String get reviewDismissMessage =>
      'As denúncias abertas são encerradas e a avaliação continua visível.';

  @override
  String get reviewHideMessage =>
      'A avaliação some da tela dos clientes e da média do destino. Dá para restaurar depois.';

  @override
  String get promosTitle => 'Promoções';

  @override
  String get promosNew => 'Novo código';

  @override
  String get promoColCode => 'Código';

  @override
  String get promoColRule => 'Regra';

  @override
  String get promoColUsage => 'Usos';

  @override
  String get promoColWindow => 'Validade';

  @override
  String get promoColStatus => 'Situação';

  @override
  String get promoStatusActive => 'Ativo';

  @override
  String get promoStatusOff => 'Desligado';

  @override
  String get promoEdit => 'Editar';

  @override
  String get promoActivate => 'Ativar';

  @override
  String get promoDeactivate => 'Desligar';

  @override
  String get promoRedemptionsAction => 'Ver resgates';

  @override
  String get promoFormTitleNew => 'Novo código promocional';

  @override
  String get promoFormTitleEdit => 'Editar código';

  @override
  String get promoFormCode => 'Código (3 a 32 letras, números, - ou _)';

  @override
  String get promoFormType => 'Tipo';

  @override
  String get promoTypePercent => 'Percentual';

  @override
  String get promoTypeFixed => 'Valor fixo';

  @override
  String get promoFormValue => 'Valor';

  @override
  String get promoFormValuePercent => 'Percentual (menor que 100)';

  @override
  String get promoFormValueFixed => 'Valor do desconto (R\$)';

  @override
  String get promoFormMin => 'Compra mínima (R\$, opcional)';

  @override
  String get promoFormFrom => 'Válido a partir de';

  @override
  String get promoFormUntil => 'Válido até';

  @override
  String get promoFormMaxTotal => 'Limite de usos (vazio = sem limite)';

  @override
  String get promoFormMaxPerUser => 'Usos por cliente (padrão 1)';

  @override
  String get promoFormImmutable =>
      'Código, tipo e valor não mudam depois de criado: outro desconto é outro código.';

  @override
  String get promoCodeInvalid => 'De 3 a 32 letras, números, - ou _.';

  @override
  String get promoValueInvalid =>
      'Informe um valor maior que zero (percentual abaixo de 100).';

  @override
  String get promoWindowInvalid => 'O fim precisa ser depois do início.';

  @override
  String get promoSaved => 'Código salvo.';

  @override
  String get promoActivated => 'Código ativado.';

  @override
  String get promoDeactivated => 'Código desligado.';

  @override
  String get promosEmpty => 'Nenhum código';

  @override
  String get promosEmptyMessage => 'Crie o primeiro código promocional.';

  @override
  String get promoFilterAll => 'Todos';

  @override
  String get promoFilterActive => 'Ativos';

  @override
  String get promoFilterOff => 'Desligados';

  @override
  String get promoRedeemColCustomer => 'Cliente';

  @override
  String get promoRedeemColPayment => 'Pagamento';

  @override
  String get promoRedeemColDiscount => 'Desconto';

  @override
  String get promoRedeemColDate => 'Quando';

  @override
  String get promoRedemptionsEmpty => 'Ninguém usou este código ainda.';

  @override
  String get promoDeactivateMessage =>
      'Os clientes deixam de poder usar o código. Os pagamentos que já o usaram não mudam. Dá para ligar de novo.';

  @override
  String get promoNoLimit => 'sem limite';

  @override
  String promoUsageUnlimited(Object used) {
    return '$used usos';
  }

  @override
  String auditOpenTarget(String type, String id) {
    return 'Abrir $type $id';
  }

  @override
  String reviewHideTitle(String name) {
    return 'Ocultar a avaliação de $name?';
  }

  @override
  String reviewReportedReason(String reason) {
    return 'Última denúncia: $reason';
  }

  @override
  String reviewHiddenReason(String reason) {
    return 'Ocultada: $reason';
  }

  @override
  String reviewOpenReports(int count) {
    return '$count denúncias abertas';
  }

  @override
  String promoDeactivateTitle(String code) {
    return 'Desligar o código $code?';
  }

  @override
  String promoRedemptionsTitle(String code) {
    return 'Resgates de $code';
  }

  @override
  String promoRulePercent(String value) {
    return '$value% de desconto';
  }

  @override
  String promoRuleFixed(String value) {
    return '$value de desconto';
  }

  @override
  String promoRuleMin(String min) {
    return 'em compras a partir de $min';
  }

  @override
  String promoRuleMax(int max) {
    return 'até $max usos';
  }

  @override
  String promoRulePerUser(int n) {
    return '$n por cliente';
  }

  @override
  String promoUsage(int used, int max) {
    return '$used de $max';
  }

  @override
  String promoWindow(String from, String until) {
    return '$from a $until';
  }
}
