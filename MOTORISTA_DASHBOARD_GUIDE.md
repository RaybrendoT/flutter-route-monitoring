# Interface de Dashboard do Motorista - Guia de Uso

## Descrição Geral
A interface de dashboard do motorista foi projetada seguindo o design do Figma que você forneceu. Ela oferece uma experiência intuitiva para motoristas gerenciarem suas corridas com mapa em tempo real, informações de trajeto e navegação.

## Componentes Principais

### 1. **SearchTripPanel** 
Painel esquerdo (ou inferior em dispositivos móveis) com:
- **Header**: Foto de perfil + Saudação personalizada
- **Local Atual**: Campo de entrada para localização atual (com ícone de localização)
- **Destino/Empresa**: Campo de entrada para destino
- **Botão Start**: Botão vermelho para iniciar a busca/aceitar corrida
- **Ícones de Navegação**: Atalhos para Passageiros, Veículos, Locais, Avisos

### 2. **GoogleMap**
Mapa interativo que mostra:
- Localização atual do motorista (marcador azul)
- Localização de pickup (marcador verde)
- Localização de dropoff (marcador vermelho)
- Rota traçada entre pickup e dropoff (linha azul)

### 3. **NavigationInstructionCard**
Card de instrução de navegação flutuante no topo do mapa com:
- Ícone de direção (Ex: Turn Right)
- Nome da rua
- Distância até a próxima ação

### 4. **TripInfoCard**
Card de informações de corrida no rodapé do mapa com:
- Hora de chegada estimada
- Tempo estimado de viagem
- Distância total
- Botão "End" para finalizar a corrida

## Estrutura de Dados

### TripModel
Representa uma corrida com:
```dart
- id: String
- passengername: String
- passengerPhone: String
- passengerPhoto: String
- pickupLocation: String
- dropoffLocation: String
- status: String (pending, accepted, in_progress, completed)
- pickupLat/pickupLng: double
- dropoffLat/dropoffLng: double
- distance: double (em km)
- estimatedTime: int (em minutos)
- earnings: double (ganho estimado)
```

### DriverProfileModel
Representa o perfil do motorista com:
```dart
- id: String
- name: String
- phone: String
- email: String
- profilePhoto: String
- vehicleModel: String
- vehiclePlate: String
- vehicleColor: String
- rating: double
- totalTrips: int
- status: String (online, offline, on_trip)
- currentLat/currentLng: double
```

## ViewModel - MotoristaDashboardViewmodel

### Métodos Principais

1. **toggleOnlineStatus()**
   - Alterna entre online e offline
   - Atualiza o status no modelo do motorista

2. **simulateIncomingTrip()**
   - Simula o recebimento de uma nova corrida
   - Cria um TripModel com dados de teste

3. **acceptTrip(TripModel trip)**
   - Aceita uma corrida pendente
   - Atualiza o status para "accepted"
   - Altera status do motorista para "on_trip"

4. **startTrip()**
   - Inicia a corrida
   - Atualiza status para "in_progress"
   - Exibe instruções de navegação

5. **endTrip()**
   - Finaliza a corrida
   - Retorna o motorista ao status "online"
   - Limpa dados da corrida

6. **completeTrip()**
   - Marca a corrida como concluída
   - Define ganho da corrida

7. **updateCurrentLocation(double lat, double lng)**
   - Atualiza a localização atual do motorista

## Responsividade

A interface é responsiva e adapta-se a diferentes tamanhos de tela:

### Desktop/Tablet (> 800px)
- Layout lado a lado
- Painel de busca à esquerda (320px)
- Mapa à direita (expandido)
- Cards de navegação sobrepostos ao mapa

### Mobile (< 800px)
- Painel de busca flutuante na parte inferior
- Mapa ocupa toda a tela
- Cards de navegação sobrepostos

## Fluxo de Uso

1. **Motorista abre o app** → Dashboard carrega com painel de busca
2. **Clica "Start"** ou recebe uma corrida → Simula incomingTrip()
3. **Aceita a corrida** → Mapa carrega com markers e rota
4. **Inicia a navegação** → Exibe instruções de direção
5. **Chegando ao destino** → Clica "End" → Finalmente a corrida
6. **App retorna ao estado inicial**

## Personalização

### Para conectar com API real:

1. **Substitua simulateIncomingTrip()** com chamada à API
2. **Implemente listeners** de localização em tempo real
3. **Adicione notificações push** para novas corridas
4. **Integre pagamento** na conclusão da corrida

### Para alterar cores e estilos:

- Cores principais em `app_theme.dart`
- Botões customizados: Cor vermelha (0xFFE53935) para ações principais
- Azul (0xFF1E88E5) para ações secundárias
- Verde para pickup, Vermelho para dropoff

## Dependências Necessárias

```yaml
google_maps_flutter: ^2.0.0
provider: ^6.0.0
flutter:
  sdk: flutter
```

## Próximas Implementações Sugeridas

1. ✅ Integração com API real de corridas
2. ✅ Gerenciamento de localização em tempo real
3. ✅ Notificações push para novas corridas
4. ✅ Sistema de rating/avaliação
5. ✅ Histórico de corridas
6. ✅ Gestão de ganhos/faturamento
7. ✅ Chat em tempo real com passageiro
8. ✅ Suporte offline com sincronização
