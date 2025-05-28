
## 📖 Sobre o Projeto

## ✨ Visão Geral

**Ties of Love** é um aplicativo para casais que desejam acompanhar sua jornada de amor. Ele permite que os usuários:
- Criem uma conta e conectem-se com seu parceiro usando códigos únicos. 🔗
- Registrem a data de início do relacionamento e acompanhem os dias juntos. 📅
- Compartilhem histórias e apelidos carinhosos. 💬
- Participem de desafios românticos para manter a chama acesa! 🎁

Com uma interface em tons de rosa suave e um design intuitivo, o aplicativo é perfeito para casais que querem celebrar cada momento juntos. 💕

---

## 🚀 Funcionalidades

- **Autenticação Segura**: Cadastro e login com email e senha. 🔒
- **Vínculo de Parceiros**: Conecte-se ao seu parceiro usando códigos únicos gerados automaticamente. 💑
- **Acompanhamento de Relacionamento**: Registre a data de início e veja quantos dias vocês estão juntos. ⏳
- **Histórias e Apelidos**: Compartilhe como vocês se conheceram e os apelidos carinhosos que usam. 📖
- **Desafios Românticos**: Complete tarefas como "Jantar Romântico" ou "Presente Surpresa" para ganhar pontos e manter a conexão viva. 🌟
- **Verificação Automática**: Quando ambos os parceiros confirmam o vínculo, o app redireciona automaticamente para a tela de relacionamento. 🔄

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia        | Descrição                          |
|-------------------|------------------------------------|
| **Flutter**       | Framework para a interface do app. 🌐 |
| **Dart**          | Linguagem para o front-end e back-end. 🛠️ |
| **PostgreSQL**    | Banco de dados relacional. 🗄️ |
| **Shelf**         | Framework para criar o servidor Dart. 🌍 |
| **HTTP**          | Comunicação entre o app e o servidor. 📡 |

---

## 📦 Como Executar o Projeto

### Pré-requisitos
- [Flutter](https://flutter.dev/docs/get-started/install) instalado.
- [Dart](https://dart.dev/get-dart) instalado.
- [PostgreSQL](https://www.postgresql.org/download/) instalado e configurado.
- Um editor como [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio).

### Passos para Configuração

1. **Clone o Repositório**  
   ```bash
   git clone https://github.com/seu-usuario/ties-of-love.git
   cd ties-of-love
   ```

2. **Instale as Dependências do Flutter**  
   Dentro da pasta do projeto, execute:
   ```bash
   flutter pub get
   ```

3. **Configure o Banco de Dados PostgreSQL**  
   - Crie um banco de dados chamado `ties_of_love`.
   - Atualize as credenciais no arquivo `server.dart` (usuário e senha do PostgreSQL):
     ```dart
     final db = PostgreSQLConnection(
       'localhost',
       5432,
       'ties_of_love',
       username: 'postgres',
       password: 'sua-senha',
     );
     ```
   - O script de criação da tabela `usuarios` já está no `server.dart` e será executado automaticamente.

4. **Inicie o Servidor**  
   Na pasta do projeto, execute:
   ```bash
   dart server.dart
   ```
   O servidor estará rodando em `http://localhost:8080`.

5. **Execute o Aplicativo**  
   Certifique-se de que o servidor está rodando e, em outro terminal, execute:
   ```bash
   flutter run -d chrome
   ```
   O app será aberto no Google Chrome.

---

## 🌟 Estrutura do Projeto

```
TIES-OF-LOVE/
├── .dart_tool/               # Arquivos gerados pelo Dart
├── .vscode/                  # Configurações do VS Code
├── android/                  # Configurações para Android
├── assets/                   # Recursos como imagens
│   └── images/               # Imagens do app (ex.: logo.jpg, imagem_quests.png)
├── backend/                  # Backend do projeto
│   ├── .dart_tool/           # Arquivos gerados pelo Dart no backend
│   ├── config/               # Configurações do backend
│   ├── models/               # Modelos de dados
│   ├── routes/               # Rotas do servidor
│   ├── services/             # Serviços do backend
│   ├── server.dart           # Arquivo principal do servidor
│   ├── pubspec.lock          # Dependências bloqueadas do backend
│   └── pubspec.yaml          # Configuração das dependências do backend
├── build/                    # Arquivos de build gerados
├── ios/                      # Configurações para iOS
├── lib/                      # Código do aplicativo Flutter
│   ├── AguardandoConfirmacaoPage.dart  # Tela de espera para confirmação
│   ├── CriarContaPage.dart             # Tela de cadastro
│   ├── LoginPage.dart                  # Tela de login
│   ├── main.dart                       # Ponto de entrada do app
│   ├── RelacionamentoPage.dart         # Tela de detalhes do relacionamento
│   ├── RelacionamentoStatusPage.dart   # Tela principal com desafios
│   ├── TelaLoad.dart                   # Tela de carregamento
│   └── UserCodePage.dart               # Tela de códigos de vínculo
├── linux/                    # Configurações para Linux
├── macos/                    # Configurações para macOS
├── test/                     # Testes do projeto
├── web/                      # Configurações para web
├── windows/                  # Configurações para Windows
├── .flutter-plugins          # Plugins Flutter
├── .flutter-plugins-dependencies # Dependências dos plugins
├── .gitignore                # Arquivos ignorados pelo Git
├── .metadata                 # Metadados do projeto
├── analysis_options.yaml     # Configurações de análise estática
├── pubspec.lock              # Dependências bloqueadas do app
└── pubspec.yaml              # Configuração das dependências do app
```

---

## 👥 Equipe de Desenvolvimento

Este projeto foi criado por:

| Nome                   | Papel           | GitHub                                                                  |
|------------------------|-----------------|-------------------------------------------------------------------------|
| [oustyy]               | Developer       | [github.com/oustyy](https://github.com/oustyy)                          |
| [kauack14]             | Developer       | [github.com/kauack14](https://github.com/kauack14)                      |
| [ViniciusMenezes-dev]  | Developer       | [github.com/ViniciusMenezes-dev](https://github.com/ViniciusMenezes-dev)|
| [Jhenrique8]           | Developer       | [github.com/Jhenrique8](https://github.com/Jhenrique8)                  |
| [Kakanosh]             | Developer       | [github.com/Kakanosh](https://github.com/Kakanosh)                      |
| [GustavoSousa-dev]     | Developer       | [github.com/GustavoSousa-dev](https://github.com/GustavoSousa-dev)      |
| [GabbSilva]            | Developer       | [github.com/GabbSilva](https://github.com/GabbSilva)                    |
| [NicollyAlcantara]     | Developer       | [github.com/NicollyAlcantara](https://github.com/NicollyAlcantara)      |


---