# Rota em Flutter

Aplicativo de gerenciamento e acompanhamento de rotas corporativas desenvolvido em Flutter usando Clean Architecture + MVVM.

## Arquitetura

- **Clean Architecture**: Separação em camadas (Presentation, Domain, Data)
- **MVVM**: ViewModels para lógica de apresentação
- **Provider**: Gerenciamento de estado
- **Go Router**: Navegação nomeada
- **Organização por Features**: auth, motorista, colaborador

## Estrutura do Projeto

```
lib/
├── core/                 # Configurações globais
│   ├── theme/           # Tema e estilos
│   ├── routes/          # Rotas da aplicação
│   └── utils/           # Utilitários
├── shared/              # Componentes compartilhados
│   └── widgets/        # Widgets reutilizáveis
├── features/           # Features da aplicação
│   ├── auth/           # Autenticação
│   │   ├── data/       # Repositories, Models
│   │   ├── domain/     # Entities, Usecases
│   │   └── presentation/ # Views, ViewModels
│   ├── motorista/      # Dashboard motorista
│   └── colaborador/    # Dashboard colaborador
```

## Funcionalidades

### Autenticação
- Login com seleção de perfil (Motorista/Colaborador)
- Cadastro de novos usuários
- Controle de sessão

### Dashboard Motorista
- Visualização da rota atual
- Mapa integrado
- Lista de paradas
- Status em tempo real

### Dashboard Colaborador
- Acompanhamento da rota
- ETA (Tempo estimado de chegada)
- Timeline de atualizações
- Marcar presença/ausência

## Como Executar

1. Instale as dependências:
   ```bash
   flutter pub get
   ```

2. Execute o aplicativo:
   ```bash
   flutter run
   ```

## Credenciais de Teste

- Email: test@test.com
- Senha: 123

## Tecnologias Utilizadas

- Flutter
- Dart
- Provider
- Go Router
- Google Maps Flutter
- HTTP
- Shared Preferences

## Desenvolvimento Futuro

- Integração com API REST
- Autenticação JWT
- Notificações push
- Offline mode
- Testes unitários e de integração

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
