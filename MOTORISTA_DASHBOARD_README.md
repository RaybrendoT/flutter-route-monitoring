# 🚗 Interface Dashboard Motorista - Rota em Flutter

Uma interface completa de dashboard para motoristas em um aplicativo de transporte, inspirada no Figma que você forneceu. A interface inclui gerenciamento de corridas, mapa em tempo real, navegação e rastreamento de localização.

## ✨ Características

- **Dashboard Responsivo**: Funciona em desktop (layout lado a lado) e mobile (layout em coluna)
- **Google Maps Integrado**: Visualização de rotas em tempo real com markers e polylines
- **Gerenciamento de Corridas**: Fluxo completo de aceitar, iniciar e completar corridas
- **Localização em Tempo Real**: Rastreamento contínuo do motorista
- **Informações de Navegação**: Cards com instruções de direção e ETA
- **State Management com Provider**: Padrão clean architecture com MVVM
- **Componentes Reutilizáveis**: Widgets modulares e bem estruturados

## 📁 Estrutura de Arquivos Criados

```
lib/features/motorista/
├── domain/
│   └── models/
│       ├── driver_profile_model.dart      # Modelo do perfil do motorista
│       └── trip_model.dart                # Modelo de dados da corrida
├── data/
│   └── datasources/                       # Será implementado com API
├── presentation/
│   ├── viewmodels/
│   │   └── motorista_dashboard_viewmodel.dart  # ViewModel com lógica
│   ├── views/
│   │   └── motorista_dashboard_view.dart       # View principal
│   ├── widgets/
│   │   ├── search_trip_panel.dart              # Painel de busca
│   │   ├── trip_info_card.dart                 # Card de info da corrida
│   │   └── navigation_instruction_card.dart    # Card de navegação
│   └── examples/
│       └── motorista_dashboard_examples.dart   # Exemplos de uso

test/
└── features/motorista/
    └── presentation/viewmodels/
        └── motorista_dashboard_viewmodel_test.dart  # Testes unitários

📖 Guias de Documentação:
├── MOTORISTA_DASHBOARD_GUIDE.md    # Guia completo de uso
└── API_INTEGRATION_GUIDE.md         # Como integrar com backend
```

## 🚀 Como Usar

### 1. Instalação de Dependências

As principais dependências já estão no `pubspec.yaml`:

```yaml
google_maps_flutter: ^2.0.0
provider: ^6.0.0
geolocator: ^9.0.0  # Para localização em tempo real
dio: ^5.9.2          # Para requisições HTTP
```

### 2. Inicializar no Main

O ViewModel já foi adicionado ao Provider no `main.dart`:

```dart
ChangeNotifierProvider(create: (_) => MotoristaDashboardViewmodel()),
```

### 3. Usar a View

```dart
import 'package:rota_em_flutter/features/motorista/presentation/views/motorista_dashboard_view.dart';

// Navegar para a view
MotoristaDashboardView()
```

### 4. Interações Básicas

```dart
final viewModel = Provider.of<MotoristaDashboardViewmodel>(context);

// Ficar online/offline
viewModel.toggleOnlineStatus();

// Simular nova corrida (para testes)
viewModel.simulateIncomingTrip();

// Aceitar corrida
viewModel.acceptTrip(trip);

// Iniciar corrida
viewModel.startTrip();

// Atualizar localização
viewModel.updateCurrentLocation(lat, lng);

// Completar e finalizar
viewModel.completeTrip();
viewModel.endTrip();
```

## 📱 Responsividade

- **Desktop/Tablet (> 800px)**: Layout lado a lado com painel esquerdo e mapa à direita
- **Mobile (< 800px)**: Layout em coluna com painel flutuante sobre o mapa

## 🎨 Customização

### Cores e Tema

Edite em `lib/core/theme/app_theme.dart`:

```dart
primaryColor: const Color(0xFF1E88E5),  // Azul corporativo
// Cores customizadas:
- Vermelho (ações principal): 0xFFE53935
- Verde (pickup): Padrão do Google Maps
- Vermelho (dropoff): Padrão do Google Maps
```

### Textos

Edite em `lib/features/motorista/presentation/widgets/search_trip_panel.dart`

## 🧪 Testes

### Executar Testes Unitários

```bash
flutter test test/features/motorista/presentation/viewmodels/
```

Testes incluem:

- ✅ Alternância de status online/offline
- ✅ Fluxo completo de corrida
- ✅ Atualização de localização
- ✅ Simulação de múltiplas corridas
- ✅ Validação de dados do driver e trip

### Executar Exemplos

```dart
// Veja: lib/features/motorista/presentation/examples/motorista_dashboard_examples.dart
// Contains:
- exampleCompleteTrip()
- exampleToggleOnlineStatus()
- exampleListenerPattern()
- exampleCustomTrip()
- MotoristaDashboardExampleWidget() // Widget de exemplo interativo
```

## 🔌 Integração com API

Para conectar com um backend real:

1. Leia o guia: [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md)
2. Implemente `MotoristRemoteDataSource`
3. Implemente `MotoristRepository`
4. Atualize o `ViewModel` com chamadas da API
5. Configure autenticação com tokens

### Endpoints Necessários

```
GET    /api/v1/drivers/{id}                 # Buscar perfil
PATCH  /api/v1/drivers/{id}/status          # Atualizar status
POST   /api/v1/drivers/{id}/location        # Enviar localização
GET    /api/v1/drivers/{id}/new-trip        # Buscar nova corrida
POST   /api/v1/trips/{id}/accept            # Aceitar corrida
POST   /api/v1/trips/{id}/start             # Iniciar corrida
POST   /api/v1/trips/{id}/complete          # Completar corrida
```

## 📋 Dados de Exemplo

### Motorista (Driver)

```dart
DriverProfileModel(
  name: 'Isabelle',
  phone: '(11) 98765-4321',
  vehicleModel: 'Toyota Corolla 2022',
  vehiclePlate: 'ABC-1234',
  rating: 4.8,
  totalTrips: 156,
)
```

### Corrida (Trip)

```dart
TripModel(
  passengername: 'João Silva',
  pickupLocation: 'Rua A, 123',
  dropoffLocation: 'Avenida Paulista, 500',
  distance: 2.1,  // km
  estimatedTime: 4,  // minutos
  status: 'pending',
)
```

## 🔄 Fluxo de Estado

```
OFFLINE
  ↓
ONLINE (toggleOnlineStatus)
  ↓
[Aguardando corrida]
  ↓
PENDING TRIP (simulateIncomingTrip)
  ↓
ACCEPT (acceptTrip)
  ↓
ACCEPTED → IN_PROGRESS (startTrip)
  ↓
[Navegando]
  ↓
COMPLETED (completeTrip)
  ↓
END TRIP (endTrip)
  ↓
ONLINE (volta ao início)
```

## 📚 Documentação Adicional

- [MOTORISTA_DASHBOARD_GUIDE.md](MOTORISTA_DASHBOARD_GUIDE.md) - Guia completo de funcionalidades
- [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md) - Como integrar com backend
- [Exemplos de Uso](lib/features/motorista/presentation/examples/motorista_dashboard_examples.dart)

## 🛠️ Próximas Implementações

- [ ] Integração com API real
- [ ] Localização em tempo real com Geolocator
- [ ] WebSocket para atualizações em tempo real
- [ ] Sistema de chat com passageiro
- [ ] Rating e avaliação
- [ ] Histórico de corridas
- [ ] Gestão de ganhos/faturamento
- [ ] Modo offline com sincronização
- [ ] Notificações push

## 🐛 Troubleshooting

### Google Maps não aparece

```dart
// Adicione credenciais em:
// android/app/src/main/AndroidManifest.xml (API Key do Google Maps)
// ios/Runner/Info.plist (API Key do Google Maps)

<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

### Provider não funciona

```dart
// Certifique-se que o Provider está configurado em main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MotoristaDashboardViewmodel()),
  ],
)
```

## 📝 Licença

Este projeto é parte do Rota em Flutter.

## 👨‍💻 Autor

Desenvolvido com Flutter e Clean Architecture.

---

**Pronto para usar! 🎉**

Para dúvidas ou melhorias, consulte a documentação incluída.
