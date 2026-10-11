# Segurança do portal

| Controle | Onde | Efeito |
|---|---|---|
| Token de acesso só em memória | `SessionTokenManager` | Nada em `localStorage`/cookie legível; recarregar apaga e a sessão volta pelo cookie `httpOnly` de renovação |
| Renovação em voo único | `SessionTokenManager.refresh` e `AdminAuthInterceptor` | O refresh token é de uso único: chamadas paralelas esperam a mesma renovação, e uma chamada que recebe 401 depois de outra já ter renovado só repete com o token atual |
| Saída por ociosidade | `IdleGuard` | 15 min sem atividade, aviso 1 min antes |
| Rascunho protegido | `DraftStore`/`DraftGuard` | Sair com formulário sujo pede confirmação; rascunho não guarda segredo |
| CSP e cabeçalhos | `apps/dbook_admin/deploy/security-headers.json` | `default-src 'self'`, `connect-src 'self' API_ORIGIN`, `font-src 'self' data:`, `frame-ancestors 'none'`, HSTS, `no-referrer`, sem câmera/microfone/geolocalização |
| Sem HTML injetado | `tool/check_portal_source.sh` (CI) | Reprova `innerHTML`, `HtmlElementView`, `postMessage`, `window.open` e segredo escrito no código |
| Retorno após login | `safeReturnTo` | Só caminho interno; nunca URL externa |
| Auditoria de dependências | job `dependency-audit` no CI | |

A autorização real é do servidor; o cliente só esconde o que a pessoa não pode
usar.
