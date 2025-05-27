
## 📖 Sobre o Projeto

### 🎯 Funcionalidades

- **Cadastro e Login**: Os usuários podem criar uma conta e fazer login com email e senha.
- **Perfil do Relacionamento**: Adicione informações como a data de início do relacionamento, história do casal e apelidos.
- **Tarefas Românticas**: Acompanhe o progresso de tarefas como "Tenha um jantar romântico" ou "Surpreenda com um presente".
- **Design Atraente**: Interface com tema romântico, cores suaves (rosa claro e escuro) e animações interativas.
- **Integração com Backend**: Conexão com um servidor Dart que armazena os dados no PostgreSQL.

## 🚀 Como Começar

### Pré-requisitos

- [Flutter](https://flutter.dev/docs/get-started/install) (versão 3.x ou superior)
- [Dart](https://dart.dev/get-dart) (versão 3.x ou superior)
- [PostgreSQL](https://www.postgresql.org/download/) (versão 12 ou superior)
- Um editor de código como [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio)

### Instalação

1. **Clone o Repositório**:
   ```bash
   git clone https://github.com/seu-usuario/ties-of-love.git
   cd ties-of-love
   ```

2. **Instale as Dependências do Flutter**:
   Certifique-se de que você está na pasta do projeto e execute:
   ```bash
   flutter pub get
   ```

3. **Configure o Banco de Dados PostgreSQL**:
   - Crie um banco de dados chamado `ties_of_love`:
     ```sql
     CREATE DATABASE ties_of_love;
     ```
   - Atualize as credenciais no arquivo `server.dart` com o seu usuário e senha do PostgreSQL:
     ```dart
     final db = PostgreSQLConnection(
       'localhost',
       5432,
       'ties_of_love',
       username: 'postgres', // Substitua pelo seu usuário
       password: '123',      // Substitua pela sua senha
     );
     ```

4. **Inicie o Backend**:
   - Navegue até a pasta onde está o arquivo `server.dart` e execute:
     ```bash
     dart run server.dart
     ```
   - Você verá a mensagem `Server running on localhost:8080` se tudo estiver correto.

5. **Atualize o IP no Frontend**:
   - Nos arquivos `CriarContaPage.dart` e `LoginPage.dart`, substitua o IP pelo endereço IP da sua máquina (por exemplo, `192.168.1.5`):
     ```dart
     Uri.parse('http://192.168.1.5:8080/cadastrar')
     Uri.parse('http://192.168.1.5:8080/login')
     ```
   - Para encontrar o IP da sua máquina:
     - Windows: Execute `ipconfig` no terminal e procure o "IPv4 Address".
     - Linux/Mac: Execute `ifconfig` ou `ip addr` e procure o endereço IP.

6. **Execute o App**:
   - Conecte um dispositivo ou inicie um emulador.
   - Execute o comando:
     ```bash
     flutter run
     ```

## 📱 Como Usar

1. **Tela Inicial**:
   - Ao abrir o app, você verá a tela de boas-vindas com o botão "Iniciar".
   - Clique em "Iniciar" para ir para a tela de login.

2. **Criar Conta**:
   - Clique em "Criar conta" na tela de login.
   - Preencha os campos (nome, email, senha, confirmar senha) e clique em "Criar Conta".
   - Você será redirecionado para a tela de login.

3. **Fazer Login**:
   - Insira o email e a senha que você cadastrou.
   - Clique em "Confirmar" para acessar a próxima tela.

4. **Configurar o Relacionamento**:
   - Após o login, você será levado à tela de código de usuário.
   - Insira o código do(a) parceiro(a) (use `AMOR123` para testar) e confirme.
   - Preencha os detalhes do relacionamento, como data de início e história do casal.

5. **Acompanhar Tarefas**:
   - Na tela de status do relacionamento, você verá quantos dias estão juntos e poderá acompanhar tarefas românticas.
   - Clique no botão flutuante (ícone de coração) para expandir a lista de tarefas e marcar o progresso.

## 🛠️ Tecnologias Utilizadas

### Frontend
- **Flutter**: Framework para construção de interfaces nativas.
- **Dart**: Linguagem de programação usada pelo Flutter.
- **image_picker**: Pacote para selecionar imagens da galeria.
- **http**: Pacote para fazer requisições HTTP ao backend.

### Backend
- **Dart**: Usado para criar o servidor com o framework Shelf.
- **Shelf**: Framework para construir APIs em Dart.
- **postgres**: Pacote para integração com PostgreSQL.
- **PostgreSQL**: Banco de dados relacional para armazenar os dados dos usuários.

## 📂 Estrutura do Projeto

```
ties-of-love/
├── assets/
│   ├── images/
│   │   ├── logo.jpg
│   │   ├── coracao.png
│   │   ├── default_avatar.png
│   │   └── partner_avatar.png
├── lib/
│   ├── CriarContaPage.dart
│   ├── LoginPage.dart
│   ├── main.dart
│   ├── RelacionamentoPage.dart
│   ├── RelacionamentoStatusPage.dart
│   ├── TelaLoad.dart
│   ├── UserCodePage.dart
├── server.dart
├── pubspec.yaml
└── README.md
```

## ⚠️ Notas Importantes

- **Segurança**: Atualmente, as senhas são armazenadas como texto puro no banco de dados. Em um ambiente de produção, é altamente recomendado usar um mecanismo de hash (como `bcrypt`) para proteger as senhas.
- **Firewall**: Certifique-se de que a porta 8080 está liberada no firewall da sua máquina para que o frontend possa se comunicar com o backend.
- **Testes**: O código do parceiro(a) padrão para testes é `AMOR123`. Você pode ajustá-lo no arquivo `UserCodePage.dart`.

## 🤝 Contribuições

Contribuições são bem-vindas! Siga os passos abaixo para contribuir:

1. Faça um fork do repositório.
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`).
3. Commit suas alterações (`git commit -m 'Adiciona nova funcionalidade'`).
4. Faça o push para a branch (`git push origin feature/nova-funcionalidade`).
5. Abra um Pull Request.

## 📧 Contato

Se você tiver dúvidas ou sugestões, entre em contato:

- **Email**: ckzinho@example.com
- **GitHub**: 

---

Feito com 💖 para casais apaixonados!