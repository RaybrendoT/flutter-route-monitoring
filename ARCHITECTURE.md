# 🏗️ Arquitetura do Dashboard Motorista

## Diagrama Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                       │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │          MotoristaDashboardView (UI Principal)             │ │
│  │                                                             │ │
│  │  ┌─────────────────────┐        ┌──────────────────────┐  │ │
│  │  │  SearchTripPanel    │        │   Google Maps        │  │ │
│  │  │  - Header           │        │   - Markers          │  │ │
│  │  │  - Input fields     │        │   - Polylines        │  │ │
│  │  │  - Start button     │        │   - Camera control   │  │ │
│  │  │  - Nav icons        │        └──────────────────────┘  │ │
│  │  └─────────────────────┘                                   │ │
│  │                                                             │ │
│  │  ┌──────────────────────┐  ┌────────────────────────────┐  │ │
│  │  │  Navigation Card     │  │  Trip Info Card            │  │ │
│  │  │  - Direction arrow   │  │  - ETA                     │  │ │
│  │  │  - Street name       │  │  - Time/Distance/Cost      │  │ │
│  │  │  - Distance          │  │  - End button              │  │ │
│  │  └──────────────────────┘  └────────────────────────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                           │                                      │
│                           │ Consumer                             │
│                           ▼                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │    MotoristaDashboardViewmodel (State Management)          │ │
│  │                                                             │ │
│  │  Properties:                                               │ │
│  │  - driver: DriverProfileModel                              │ │
│  │  - currentTrip: TripModel?                                 │ │
│  │  - isOnline: bool                                          │ │
│  │  - showTripDetails: bool                                   │ │
│  │                                                             │ │
│  │  Methods:                                                  │ │
│  │  + toggleOnlineStatus()                                    │ │
│  │  + simulateIncomingTrip()                                  │ │
│  │  + acceptTrip(trip)                                        │ │
│  │  + startTrip()                                             │ │
│  │  + completeTrip()                                          │ │
│  │  + endTrip()                                               │ │
│  │  + updateCurrentLocation(lat, lng)                         │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────┬──────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DOMAIN LAYER (Models)                      │
│                                                                   │
│  ┌────────────────────────────┐  ┌──────────────────────────┐   │
│  │   DriverProfileModel       │  │    TripModel             │   │
│  │                            │  │                          │   │
│  │  - id: String              │  │  - id: String            │   │
│  │  - name: String            │  │  - passengername: String │   │
│  │  - phone: String           │  │  - pickupLocation        │   │
│  │  - email: String           │  │  - dropoffLocation       │   │
│  │  - profilePhoto: String    │  │  - pickupLat/Lng         │   │
│  │  - vehicleModel: String    │  │  - dropoffLat/Lng        │   │
│  │  - vehiclePlate: String    │  │  - distance: double      │   │
│  │  - rating: double          │  │  - estimatedTime: int    │   │
│  │  - totalTrips: int         │  │  - status: String        │   │
│  │  - status: String          │  │  - earnings: double?     │   │
│  │  - currentLat/Lng: double  │  │                          │   │
│  │                            │  │  Status Values:          │   │
│  │  Status Values:            │  │  - pending               │   │
│  │  - online                  │  │  - accepted              │   │
│  │  - offline                 │  │  - in_progress           │   │
│  │  - on_trip                 │  │  - completed             │   │
│  └────────────────────────────┘  └──────────────────────────┘   │
└────────────────────────────────────────────────────────────────────┘
             │
             ▼ (será implementado)
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER (APIs)                          │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │         MotoristRemoteDataSource (API Calls)               │ │
│  │                                                             │ │
│  │  + getDriverProfile(driverId)                              │ │
│  │  + updateDriverStatus(driverId, status)                    │ │
│  │  + getNewTrip(driverId)                                    │ │
│  │  + acceptTrip(tripId)                                      │ │
│  │  + startTrip(tripId)                                       │ │
│  │  + completeTrip(tripId)                                    │ │
│  │  + updateLocation(driverId, lat, lng)                      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │      MotoristLocalDataSource (Cached Data)                 │ │
│  │                                                             │ │
│  │  + cacheDriverProfile(profile)                             │ │
│  │  + getCachedDriverProfile()                                │ │
│  │  + clearCache()                                            │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │        MotoristRepository (Interface)                       │ │
│  │                                                             │ │
│  │  Abstrai lógica de busca de dados (local ou remote)        │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────────────────────────────┐
│                   EXTERNAL SERVICES                              │
│                                                                   │
│  ┌─────────────────┐  ┌──────────────────┐  ┌─────────────────┐ │
│  │  Google Maps    │  │  Geolocator      │  │  Dio (HTTP)     │ │
│  │  - GoogleMap    │  │  - Real-time     │  │  - API calls    │ │
│  │  - Markers      │  │    location      │  │  - Error        │ │
│  │  - Polylines    │  │                  │  │    handling     │ │
│  └─────────────────┘  └──────────────────┘  └─────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  SharedPreferences / Device Storage                        │ │
│  │  - Local caching                                           │ │
│  │  - Offline data                                            │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────────┘
```

## Fluxo de Dados

```
┌─────────────────────┐
│   User Action       │
│   (tap Start)       │
└──────────┬──────────┘
           │
           ▼
┌────────────────────────────────────┐
│  Widget calls ViewModel method      │
│  viewModel.simulateIncomingTrip()   │
└──────────┬─────────────────────────┘
           │
           ▼
┌────────────────────────────────────┐
│  ViewModel updates state            │
│  - _currentTrip = new trip          │
│  - notifyListeners()                │
└──────────┬─────────────────────────┘
           │
           ▼
┌────────────────────────────────────┐
│  UI rebuilds (Consumer/Builder)     │
│  - Mostra trip cards                │
│  - Atualiza mapa                    │
│  - Exibe botões de ação             │
└────────────────────────────────────┘
```

## Clean Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│ PRESENTATION (UI & State Management)                │
│ - Views (MotoristaDashboardView)                    │
│ - ViewModels (MotoristaDashboardViewmodel)          │
│ - Widgets (SearchTripPanel, TripInfoCard, etc)      │
└──────────────┬──────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────┐
│ DOMAIN (Business Logic & Entities)                  │
│ - Models (DriverProfileModel, TripModel)            │
│ - Repositories (Interfaces)                         │
│ - Use Cases (não implementado ainda)                │
└──────────────┬──────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────┐
│ DATA (Data Sources & Repositories)                  │
│ - Remote Data Sources (API)                         │
│ - Local Data Sources (Cache)                        │
│ - Repository Implementations                        │
└──────────────┬──────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────┐
│ EXTERNAL (Third-party Services)                     │
│ - Google Maps API                                   │
│ - Geolocator Plugin                                 │
│ - Dio HTTP Client                                   │
│ - SharedPreferences                                 │
└─────────────────────────────────────────────────────┘
```

## Dependências Entre Componentes

```
MotoristaDashboardView
    │
    ├─→ SearchTripPanel (widget)
    ├─→ NavigationInstructionCard (widget)
    ├─→ TripInfoCard (widget)
    └─→ GoogleMap (external)
    
    │ consome
    ▼
MotoristaDashboardViewmodel
    │ usa
    ├─→ DriverProfileModel
    ├─→ TripModel
    └─→ MotoristRepository (será implementado)
            │ usa
            ├─→ MotoristRemoteDataSource (será implementado)
            ├─→ MotoristLocalDataSource (será implementado)
            └─→ Externals
                ├─→ Dio
                ├─→ Geolocator
                └─→ SharedPreferences
```

## Estado do ViewModel

```
Inicialização:
- driver: Loaded (com dados padrão)
- currentTrip: null
- isOnline: false
- showTripDetails: false
- isLoading: false
- error: null

Após toggleOnlineStatus():
- isOnline: true/false (alternado)
- driver.status: "online"/"offline"

Após simulateIncomingTrip():
- currentTrip: TripModel (status: "pending")
- notifyListeners() → UI atualiza

Após acceptTrip(trip):
- currentTrip: TripModel (status: "accepted")
- driver.status: "on_trip"

Após startTrip():
- currentTrip: TripModel (status: "in_progress")
- showTripDetails: true

Após completeTrip():
- currentTrip: TripModel (status: "completed")
- currentTrip.earnings: 45.50

Após endTrip():
- currentTrip: null
- driver.status: "online"
- showTripDetails: false
```

## Padrão Provider

```
main.dart
    │
    └─→ MultiProvider
        │
        └─→ ChangeNotifierProvider
            │
            ├─→ MotoristaDashboardViewmodel
            │   │
            │   └─→ notifyListeners() quando estado muda
            │
            └─→ Consumers na UI
                │
                ├─→ Consumer<MotoristaDashboardViewmodel>
                ├─→ Selector<MotoristaDashboardViewmodel, ...>
                └─→ watch(motoristaDashboardViewmoel)
```

## Padrão Responsividade

```
LayoutBuilder
    │
    ├─→ constraints.maxWidth > 800px
    │   └─→ Row Layout (Desktop)
    │       ├─ SearchTripPanel (320px fixed)
    │       ├─ Divider
    │       └─ GoogleMap (expanded)
    │
    └─→ constraints.maxWidth ≤ 800px
        └─→ Stack Layout (Mobile)
            ├─ GoogleMap (full screen)
            └─ Floating SearchTripPanel (bottom)
```

---

## Como Esta Arquitetura Escala

✅ **Testabilidade**: ViewModels podem ser testados sem UI
✅ **Modularidade**: Cada camada tem responsabilidade clara
✅ **Flexibilidade**: Fácil trocar fonte de dados (mock → real API)
✅ **Manutenibilidade**: Código organizado e bem estruturado
✅ **Reusabilidade**: Componentes podem ser usados em outras telas
✅ **Independência**: UI não depende de implementação da API

## Próximas Etapas

1. Implementar Data Layer (Remote/Local data sources)
2. Implementar Repository
3. Conectar com API real
4. Adicionar tratamento de erros
5. Implementar autenticação
6. Adicionar testes de integração
7. Implementar offline mode
