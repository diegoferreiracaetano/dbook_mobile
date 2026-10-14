# Projeto das telas (M49)

Projeto visual de todas as telas do app de clientes, desenhado antes de implementar, com a **estrutura** do Traveline (UI8) e a identidade do DBook (azul da marca, Roboto, cartão plano com contorno, botão em pílula, **sem** o amarelo do kit).

- **Canvas (fonte viva):** https://claude.ai/artifact/XRHxZ8WiLsn3R7SBvKHdLK (privado: só quem tem acesso abre).
- **Neste diretório:** a cópia do projeto. Cada `NN-nome.dc.html` é uma tela (390 × 844); `dbook.css` guarda os tokens e componentes usados nos desenhos; `canvas.json` guarda a posição das telas no canvas. Os `.dc.html` dependem do `support.js` do canvas para abrir; sem ele servem como fonte de consulta.
- **Referência:** [Traveline, Travel and Lifestyle App UI Kit](https://ui8.net/unpixel/products/traveline---travel-and-lifestyle-app-ui-kit), Unpixel. Kit pago: nenhuma imagem dele está no repositório.

## Telas e estado da aplicação

| # | Tela | Marca no projeto | Aplicada no app |
|---|---|---|---|
| 01-03 | Onboarding, Entrar, Cadastro | mantém | já era assim |
| Main | Home · Voos | ajusta | sim (aba Favoritos na barra) |
| 05 | Home · Hotéis, com buscas recentes | ajusta | sim |
| 06 | Destino + buscas recentes (página cheia) | novo | **parcial**: o seletor segue em folha; o histórico aparece sob o cartão de busca |
| 07 | Explorar | mantém | já era assim |
| 08 | Favoritos | novo | sim |
| 09 | Resultados de voo | mantém | já era assim |
| 10 | Detalhe do voo, barra de preço | ajusta | sim |
| 11 | Assentos com barra de preço | ajusta | ver CHECKLIST M49 |
| 12 | Revisão e pagamento | mantém | já era assim |
| 13 | Resultados de hotel + filtros | novo | sim |
| 14 | Detalhe do hotel | novo | sim |
| 15 | Filtros do hotel (folha) | novo | sim |
| 16-19 | Viagens, Perfil, Preferências, Notificações | mantém | já era assim |
| 20 | Perguntar à IA | mantém | os botões "Ver voo" e "Reservar" **não** foram aplicados: a API só devolve `flightId` e o motivo |
| 21-22 | Tema escuro | — | verificado nas capturas de `docs/screenshots` |
