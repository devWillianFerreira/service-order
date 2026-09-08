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
    <img src="https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59d587711b45.png" alt="Flutter" height="24px">
  </a>
  +
  <a href="https://dart.dev/" title="Dart">
    <img src="https://upload.wikimedia.org/wikipedia/commons/7/7e/Dart-logo.png" alt="Dart" height="24px">
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

## Dashboard

O Dashboard apresenta uma visão geral da situação operacional do sistema.

Entre os indicadores disponíveis estão:

| Indicador       | Descrição                                          |
| --------------- | -------------------------------------------------- |
| Total de Ordens | Quantidade total de Ordens de Serviço cadastradas. |
| Abertas         | Ordens aguardando início do atendimento.           |
| Em Atendimento  | Ordens atualmente em execução.                     |
| Concluídas      | Ordens com o serviço finalizado.                   |
| Canceladas      | Ordens que foram canceladas.                       |
| Atrasadas       | Ordens cujo prazo de atendimento foi ultrapassado. |
| Urgentes        | Ordens classificadas com prioridade elevada.       |
| Faturamento     | Valor financeiro total das Ordens de Serviço.      |

---

## Clientes

O módulo de clientes permite realizar o gerenciamento completo dos dados dos clientes.

As informações cadastradas incluem:

* Nome;
* CPF ou CNPJ;
* Telefone;
* E-mail;
* Endereço.

As operações disponíveis seguem o modelo CRUD:

| Operação | Descrição                          |
| -------- | ---------------------------------- |
| Create   | Cadastro de novos clientes.        |
| Read     | Consulta e listagem de clientes.   |
| Update   | Atualização dos dados cadastrados. |
| Delete   | Remoção de clientes.               |

---

## Técnicos

O sistema permite cadastrar e gerenciar os profissionais responsáveis pelos atendimentos técnicos.

Cada técnico possui informações como:

* Nome;
* Contato;
* Especialidade;
* Status.

O status permite identificar se o técnico está:

```text
Ativo
Inativo
```

Os técnicos podem ser associados às Ordens de Serviço como responsáveis pelo atendimento.

---

## Equipamentos

Os equipamentos são cadastrados e vinculados aos respectivos clientes proprietários.

Cada equipamento pode possuir informações como:

* Tipo;
* Marca;
* Modelo;
* Número de série.

A relação entre clientes e equipamentos permite associar corretamente uma Ordem de Serviço ao equipamento que necessita de atendimento.

```text
Cliente
   │
   ├── Equipamento 1
   │
   ├── Equipamento 2
   │
   └── Equipamento 3
```

---

## Ordens de Serviço

As Ordens de Serviço representam o principal fluxo operacional da aplicação.

Durante o cadastro e gerenciamento de uma OS, podem ser controladas informações relacionadas a:

* Cliente;
* Equipamento;
* Técnico responsável;
* Prioridade;
* Descrição do serviço;
* Prazo;
* Status;
* Valor da mão de obra;
* Valor total.

O sistema permite acompanhar a Ordem de Serviço durante todas as etapas do atendimento.

---

## Ciclo de Vida da Ordem de Serviço

O ciclo de vida das Ordens de Serviço é controlado utilizando o **State Pattern**.

Os estados disponíveis são:

```text
                 ┌──────────────┐
                 │    Aberta    │
                 └──────┬───────┘
                        │
                        ▼
              ┌──────────────────────┐
              │   Em Atendimento    │
              └──────────┬───────────┘
                         │
                         ▼
                  ┌─────────────┐
                  │ Concluída   │
                  └─────────────┘
```

Dependendo das regras estabelecidas pelo sistema, uma Ordem de Serviço também pode ser cancelada.

```text
Aberta ─────────────────► Cancelada

Em Atendimento ─────────► Cancelada
```

As transições entre estados são validadas para impedir alterações inválidas no ciclo de atendimento.

O **Factory Method** é utilizado para determinar e criar a implementação correspondente ao estado atual da Ordem de Serviço.

---

## Imagens e Evidências

O sistema permite registrar imagens relacionadas às Ordens de Serviço.

Esse recurso pode ser utilizado para documentar:

* Estado do equipamento antes do atendimento;
* Problemas identificados;
* Processo de manutenção;
* Resultado final do serviço.

As imagens podem ser obtidas através de:

```text
Câmera
   │
   ▼
image_picker
   │
   ├── Galeria
   │
   └── Sistema de Arquivos
```

As evidências ficam associadas à Ordem de Serviço correspondente.

---

## Busca e Filtros

A aplicação disponibiliza mecanismos de busca dinâmica para facilitar a localização das Ordens de Serviço.

A busca pode ser realizada por:

* Número da OS;
* Cliente;
* Equipamento;
* Técnico.

Também podem ser utilizados filtros combinados para organizar os resultados de acordo com as necessidades do usuário.

---

## Controle Financeiro

As Ordens de Serviço possuem informações relacionadas aos valores cobrados pelos serviços.

Entre os dados financeiros controlados estão:

* Valor da mão de obra;
* Valores relacionados aos serviços;
* Valor total da Ordem de Serviço.

Os cálculos financeiros são centralizados em classes utilitárias para evitar duplicação de lógica e manter as regras de cálculo separadas da interface.

---

## Persistência Local

A aplicação utiliza o **SQLite** como banco de dados local.

A persistência é implementada utilizando:

```text
sqflite
sqflite_common_ffi
```

O `sqflite` é utilizado para plataformas compatíveis com o pacote principal, enquanto o `sqflite_common_ffi` permite a utilização do SQLite em ambientes Desktop.

A inicialização do banco de dados utiliza o **Singleton Pattern**, garantindo um ponto centralizado de acesso à instância do banco.

```text
Aplicação
    │
    ▼
Database Singleton
    │
    ▼
SQLite Database
```

---

## Estrutura final do projeto

```text
ordem_servico/
├── lib/
│   │
│   ├── core/
│   │   ├── states/                # State Pattern para ciclo da OS
│   │   └── utils/                 # Utilitários e cálculos financeiros
│   │
│   ├── database/                  # Configuração e Singleton do SQLite
│   │
│   ├── models/                    # Models do sistema
│   │   ├── cliente.dart
│   │   ├── tecnico.dart
│   │   ├── equipamento.dart
│   │   ├── ordem_servico.dart
│   │   └── item.dart
│   │
│   ├── repositories/              # Repository Pattern
│   │
│   ├── controllers/               # ChangeNotifier / gerenciamento de estado
│   │
│   ├── pages/
│   │   ├── auth/                  # Autenticação
│   │   ├── dashboard/             # Dashboard e indicadores
│   │   ├── clientes/              # Clientes
│   │   ├── tecnicos/              # Técnicos
│   │   ├── equipamentos/          # Equipamentos
│   │   └── ordens_servico/        # Gerenciamento das OS
│   │
│   └── main.dart                  # Ponto de entrada e MultiProvider
│
├── pubspec.yaml
│
└── README.md
```

---

## Como executar o projeto

### 1. Clonar o projeto

Clone o repositório do GitHub:

```bash
git clone https://github.com/SEU-USUARIO/ordem_servico.git
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

### 5. Executar no Android

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

## Padrões de Projeto

### Repository Pattern

O acesso aos dados é isolado em classes de repositório.

Essa abordagem separa a lógica de persistência da lógica de apresentação.

```text
Controller
    │
    ▼
Repository
    │
    ▼
SQLite
```

Os repositórios são responsáveis pelas operações relacionadas aos dados, como:

* Inserção;
* Consulta;
* Atualização;
* Exclusão.

---

### Singleton Pattern

Utilizado para garantir uma única instância responsável pela conexão e inicialização do banco SQLite.

```text
Application
     │
     ▼
Database Singleton
     │
     ▼
SQLite Instance
```

---

### State Pattern

Utilizado para controlar o comportamento da Ordem de Serviço de acordo com seu status atual.

Cada estado possui regras específicas relacionadas às transições permitidas.

Isso evita alterações inválidas e mantém o fluxo da OS consistente.

---

### Factory Method

Utilizado para determinar dinamicamente qual implementação de estado deve ser utilizada com base no status atual da Ordem de Serviço.

```text
Status da OS
     │
     ▼
State Factory
     │
     ├── AbertaState
     ├── EmAtendimentoState
     ├── ConcluidaState
     └── CanceladaState
```

---

## Objetivo Acadêmico

Este projeto foi desenvolvido com finalidade acadêmica para aplicação prática de conceitos relacionados ao desenvolvimento de aplicações multiplataforma.

Os principais conceitos explorados incluem:

* Desenvolvimento Desktop e Mobile;
* Flutter e Dart;
* Programação Orientada a Objetos;
* Gerenciamento de estado;
* Persistência local;
* Banco de dados relacional;
* Arquitetura em camadas;
* Repository Pattern;
* Singleton Pattern;
* State Pattern;
* Factory Method.

---

## Licença

Projeto desenvolvido exclusivamente para fins acadêmicos.
