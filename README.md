<div align="center">
  <h1>Sistema de Ordem de Serviço e Manutenção Técnica</h1>
  <p>Aplicativo multiplataforma (Desktop e Mobile) desenvolvido em Flutter para gestão completa de chamados operacionais e ordens de serviço técnico.</p>
  <p>O sistema centraliza fluxos operacionais, cadastros de clientes, técnicos, equipamentos e relatórios financeiros, substituindo processos manuais e garantindo rastreabilidade por meio do ciclo de vida da OS, persistência local e registro de evidências fotográficas.</p>
</div>

<p align="center">
  <a href="https://flutter.dev/" title="Flutter"><img src="https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59d587711b45.png" alt="Flutter" height="24px"></a>
  +
  <a href="https://dart.dev/" title="Dart"><img src="https://upload.wikimedia.org/wikipedia/commons/7/7e/Dart-logo.png" alt="Dart" height="24px"></a>
  +
  <a href="https://www.sqlite.org/" title="SQLite"><img src="https://upload.wikimedia.org/wikipedia/commons/3/38/SQLite370.svg" alt="SQLite" height="24px"></a>
  +
  <a href="https://pub.dev/packages/provider" title="Provider">Provider</a>
</p>

## Arquitetura do Projeto

A aplicação adota uma arquitetura em camadas orientada a objetos (POO), desacoplando a interface, o estado, a persistência e as regras de negócio:

```text
 ┌──────────────────────────────────────────────────────────┐
 │                    Camada de Interface                   │
 │     (Pages / Screens / Dialogs / Form Validation)       │
 └────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
 ┌──────────────────────────────────────────────────────────┐
 │               Camada de Estado / Apresentação            │
 │            (Controllers com Provider / ChangeNotifier)   │
 └──────────────┬─────────────────────────────┬─────────────┘
                │                             │
                ▼                             ▼
 ┌───────────────────────────┐  ┌───────────────────────────┐
 │     Regras e Padrões      │  │   Camada de Repositório   │
 │ (State Pattern / Factory) │  │    (Repository Pattern)   │
 └───────────────────────────┘  └─────────────┬─────────────┘
                                              │
                                              ▼
                                ┌───────────────────────────┐
                                │     Persistência Local    │
                                │ (SQLite / Singleton DB)   │
                                └───────────────────────────┘
