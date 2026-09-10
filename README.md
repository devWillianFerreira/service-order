<div align="center">
  <h1>Sistema de Ordem de Serviço e Manutenção Técnica</h1>

  <p>
    Aplicativo multiplataforma desenvolvido em Flutter para gerenciamento de chamados operacionais e Ordens de Serviço técnico.
  </p>

  <p>
    O sistema centraliza o gerenciamento de clientes, técnicos, equipamentos e Ordens de Serviço, permitindo acompanhar todo o ciclo de atendimento, controlar informações financeiras, registrar evidências fotográficas e manter os dados persistidos localmente.
  </p>
</div>

<p align="center">
  <a href="https://flutter.dev/" title="Flutter">
   Flutter
  </a>
  +
  <a href="https://dart.dev/" title="Dart">
    Dart
  </a>
  +
  <a href="https://www.sqlite.org/" title="SQLite">
    <img src="https://upload.wikimedia.org/wikipedia/commons/3/38/SQLite370.svg" alt="SQLite" height="24px">
  </a>
  +
  <a href="https://pub.dev/packages/provider" title="Provider">
    Provider
  </a>
  +
  <a href="https://pub.dev/packages/image_picker" title="Image Picker">
    image_picker
  </a>
</p>

## Arquitetura do Projeto

```text
                           Usuário
                              │
                              ▼
                 ┌────────────────────────┐
                 │   Interface Flutter    │
                 │ Pages / Screens / UI   │
                 └────────────┬───────────┘
                              │
                              ▼
                 ┌────────────────────────┐
                 │      Controllers       │
                 │ ChangeNotifier/Provider│
                 └────────────┬───────────┘
                              │
              ┌───────────────┴────────────────┐
              ▼                                ▼
   ┌─────────────────────┐          ┌─────────────────────┐
   │  Regras de Negócio  │          │    Repositories     │
   │                     │          │                     │
   │ State Pattern       │          │ Repository Pattern  │
   │ Factory Method      │          │                     │
   │ Cálculos Financeiros│          └──────────┬──────────┘
   └─────────────────────┘                     │
                                                ▼
                                     ┌─────────────────────┐
                                     │       SQLite        │
                                     │ Persistência Local  │
                                     │ Singleton Database  │
                                     └─────────────────────┘
```

A aplicação utiliza uma arquitetura em camadas orientada a objetos, separando as responsabilidades entre interface, gerenciamento de estado, regras de negócio e persistência.

O fluxo principal da aplicação ocorre da seguinte forma:

```text
Interface Flutter
       │
       ▼
Controllers
       │
       ▼
Repositories / Regras de Negócio
       │
       ▼
SQLite
```

Essa organização permite reduzir o acoplamento entre as diferentes partes da aplicação e facilita a manutenção e evolução do projeto.

---

## Tecnologias utilizadas

* Dart
* Flutter
* Firebase 
* SQLite
* sqflite
* sqflite_common_ffi
* Provider
* ChangeNotifier
* image_picker

### Design Patterns

* Repository Pattern
* Singleton Pattern
* State Pattern
* Factory Method

---

## Funcionalidades do Sistema

| Módulo                | Funcionalidades                                                          |
| --------------------- | ------------------------------------------------------------------------ |
| **Dashboard**         | Visualização de indicadores operacionais e financeiros.                  |
| **Autenticação**      | Tela de entrada para acesso ao sistema.                                  |
| **Clientes**          | Cadastro, consulta, edição e exclusão de clientes.                       |
| **Técnicos**          | Gerenciamento dos técnicos responsáveis pelos atendimentos.              |
| **Equipamentos**      | Cadastro e gerenciamento de equipamentos vinculados aos clientes.        |
| **Ordens de Serviço** | Criação, edição, acompanhamento e gerenciamento das OS.                  |
| **Ciclo da OS**       | Controle das transições entre os diferentes estados da Ordem de Serviço. |
| **Imagens**           | Registro de evidências fotográficas relacionadas ao atendimento.         |
| **Busca e Filtros**   | Busca dinâmica e filtros combinados para localizar Ordens de Serviço.    |
| **Financeiro**        | Controle de mão de obra e valores relacionados às Ordens de Serviço.     |

---

## Estrutura final do projeto

```text
```text
ordem_servico/
├── lib/
│   ├── controllers/               # Controllers e gerenciamento de estado
│   ├── core/
│   │   ├── states/                # Implementação do State Pattern para OS
│   │   └── utils/                 # Utilitários e cálculos financeiros
│   ├── database/                  # Configuração e acesso ao banco SQLite
│   ├── models/                    # Models do sistema
│   ├── pages/
│   │   ├── auth/                  # Controle do estado da autenticação
│   │   ├── login/                 # Tela de login
│   │   ├── dashboard/             # Dashboard e indicadores
│   │   ├── clientes/              # Gerenciamento de clientes
│   │   ├── tecnicos/              # Gerenciamento de técnicos
│   │   ├── equipamentos/          # Gerenciamento de equipamentos
│   │   └── ordens_servico/        # Gerenciamento das Ordens de Serviço
│   ├── repositories/              # Camada de acesso e persistência de dados
│   ├── services/                  # Serviços da aplicação
│   ├── widgets/                   # Componentes reutilizáveis da interface
│   ├── firebase_options.dart      # Configuração do Firebase
│   └── main.dart                  # Ponto de entrada da aplicação
│
├── pubspec.yaml                   # Dependências do projeto
└── README.md                      # Documentação principal
```

---

## Como executar o projeto

### 1. Clonar o projeto

Clone o repositório do GitHub:

```bash
git clone https://github.com/devWillianFerreira/service-order.git
cd ordem_servico
```

---

### 2. Verificar a instalação do Flutter

Execute:

```bash
flutter doctor
```

O comando verifica se o ambiente está corretamente configurado para o desenvolvimento Flutter.

---

### 3. Instalar as dependências

Execute:

```bash
flutter pub get
```

O comando instalará todas as dependências definidas no arquivo `pubspec.yaml`.

---

### 4. Executar no Desktop Windows

Certifique-se de possuir o ambiente de desenvolvimento Windows configurado, incluindo as ferramentas de desenvolvimento C++ necessárias.

Execute:

```bash
flutter run -d windows
```

---

### 5. Acessar o sistema

Após iniciar a aplicação, será apresentada a tela de login.

Para acessar o sistema, utilize as credenciais de demonstração:

| Email             | Senha                                                                    |
| ------------------| ------------------------------------------------------------------------ |
| **Email**         | admin@gmail.com                                                          |
| **Senha**         | admin123                                                                 |

Após informar as credenciais, clique no botão de login para acessar o sistema.

### 6. Executar no Android

Com um dispositivo físico conectado ou um emulador iniciado, execute:

```bash
flutter run
```

Para verificar os dispositivos disponíveis:

```bash
flutter devices
```

Caso necessário, execute o projeto em um dispositivo específico:

```bash
flutter run -d ID_DO_DISPOSITIVO
```

---

## Licença

Projeto desenvolvido exclusivamente para fins acadêmicos.
