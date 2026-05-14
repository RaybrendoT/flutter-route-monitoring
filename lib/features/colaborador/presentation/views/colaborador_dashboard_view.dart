import 'package:flutter/material.dart';
import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rota_em_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';

const primaryBlue = Color(0xFF4DA6FF);
const darkBg      = Color(0xFF0F1923);
const cardBg      = Color(0xFF1A2535);
const navBg       = Color(0xFF111E2D);

class ColaboradorDashboardView extends StatefulWidget {
  const ColaboradorDashboardView({super.key});

  @override
  State<ColaboradorDashboardView> createState() => _ColaboradorDashboardViewState();
}

class _ColaboradorDashboardViewState extends State<ColaboradorDashboardView> {
  int _currentIndex = 0;
  final pages = const [MapaView(), AgendaView(), AvisosView(), PerfilView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: navBg,
        selectedItemColor: primaryBlue,
        unselectedItemColor: const Color(0xFF8A9BB0),
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined),           activeIcon: Icon(Icons.map),           label: "Mapa"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: "Agenda"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none),      activeIcon: Icon(Icons.notifications),  label: "Avisos"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),          activeIcon: Icon(Icons.person),         label: "Perfil"),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// MAPA VIEW
// ─────────────────────────────────────────
class MapaView extends StatefulWidget {
  const MapaView({super.key});
  @override
  State<MapaView> createState() => _MapaViewState();
}

class _MapaViewState extends State<MapaView> {
  bool? _resposta;
  double _progresso = 0.0;
  Timer? _timer;

  static const _rotaPontos = [
    Offset(0.38, 0.02),
    Offset(0.38, 0.38),
    Offset(0.70, 0.38),
    Offset(0.70, 0.68),
    Offset(0.42, 0.68),
  ];

  @override
  void initState() {
    super.initState();
    _iniciarAnimacao();
  }

  void _iniciarAnimacao() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      if (_resposta == false) return;
      setState(() {
        _progresso += 0.004;
        if (_progresso >= 1.0) _progresso = 0.0;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Offset _posicaoOnibus(Size size) {
    final pontos = _rotaPontos;
    final n = pontos.length - 1;
    double totalLen = 0;
    final lens = <double>[];
    for (int i = 0; i < n; i++) {
      final d = Offset((pontos[i + 1].dx - pontos[i].dx) * size.width,
          (pontos[i + 1].dy - pontos[i].dy) * size.height);
      lens.add(d.distance);
      totalLen += d.distance;
    }
    double alvo = _progresso * totalLen;
    for (int i = 0; i < n; i++) {
      if (alvo <= lens[i]) {
        final t = alvo / lens[i];
        final p0 = Offset(pontos[i].dx * size.width, pontos[i].dy * size.height);
        final p1 = Offset(pontos[i + 1].dx * size.width, pontos[i + 1].dy * size.height);
        return Offset(p0.dx + (p1.dx - p0.dx) * t, p0.dy + (p1.dy - p0.dy) * t);
      }
      alvo -= lens[i];
    }
    return Offset(pontos.last.dx * size.width, pontos.last.dy * size.height);
  }

  String get _paradasTexto {
    if (_progresso < 0.30) return "4 paradas de você";
    if (_progresso < 0.55) return "3 paradas de você";
    if (_progresso < 0.75) return "2 paradas de você";
    if (_progresso < 0.90) return "1 parada de você";
    return "chegando agora!";
  }

  String get _tempoTexto {
    if (_progresso < 0.30) return "12 min";
    if (_progresso < 0.55) return "8 min";
    if (_progresso < 0.75) return "5 min";
    if (_progresso < 0.90) return "2 min";
    return "1 min";
  }

  void _responder(bool vai) {
    setState(() => _resposta = vai);
    if (!vai) _progresso = 0.0;
    final msg = vai
        ? "Motorista recebeu sua confirmação 👍"
        : "Tudo bem! O motorista foi avisado que você não irá.";
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: vai ? primaryBlue : Colors.orange,
      duration: const Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final respondeu = _resposta != null;

    return Scaffold(
      backgroundColor: const Color(0xFFEAE6DF),
      appBar: respondeu
          ? null
          : AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_bus, color: primaryBlue, size: 20),
            const SizedBox(width: 8),
            Text("Rota chegando em $_tempoTexto",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final mapSize = Size(constraints.maxWidth, constraints.maxHeight);
        final onibusPos = _posicaoOnibus(mapSize);
        final pontoFuncionario = Offset(0.42 * mapSize.width, 0.68 * mapSize.height);

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: MapaPainter(
                  progresso: _progresso,
                  mostrarRota: _resposta != false,
                ),
              ),
            ),
            Positioned(
              left: pontoFuncionario.dx - 22,
              top: pontoFuncionario.dy - 52,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text("Seu ponto",
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  const Icon(Icons.location_on, color: Colors.red, size: 40),
                ],
              ),
            ),
            if (_resposta != false)
              Positioned(
                left: onibusPos.dx - 18,
                top: onibusPos.dy - 50,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text("Rota",
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                    const Icon(Icons.directions_bus, color: primaryBlue, size: 36),
                  ],
                ),
              ),
            if (!respondeu)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [BoxShadow(blurRadius: 16, color: Colors.black26)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Rota a $_paradasTexto",
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                                const SizedBox(height: 4),
                                const Text("agora · rota Norte", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryBlue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: primaryBlue, size: 14),
                                const SizedBox(width: 4),
                                Text(_tempoTexto,
                                    style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _responder(true),
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text("Vou embarcar"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _responder(false),
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text("Não irei hoje"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (respondeu) ...[
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _resposta == true ? Icons.directions_bus : Icons.do_not_disturb_alt,
                        color: _resposta == true ? primaryBlue : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _resposta == true
                              ? "Você confirmou embarque · rota Norte"
                              : "Você não irá hoje · motorista avisado",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _resposta == true ? primaryBlue : Colors.orange,
                          ),
                        ),
                      ),
                      if (_resposta == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_tempoTexto,
                              style: const TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24,
                left: 40,
                right: 40,
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _resposta = null),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Alterar resposta"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryBlue,
                    side: const BorderSide(color: primaryBlue),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────
// MAPA PAINTER
// ─────────────────────────────────────────
class MapaPainter extends CustomPainter {
  final double progresso;
  final bool mostrarRota;
  const MapaPainter({required this.progresso, required this.mostrarRota});

  static const _rota = [
    Offset(0.38, 0.02),
    Offset(0.38, 0.38),
    Offset(0.70, 0.38),
    Offset(0.70, 0.68),
    Offset(0.42, 0.68),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFEAE6DF));

    final qPaint = Paint()..color = const Color(0xFFD4CFC6);
    for (final q in [
      Rect.fromLTWH(0, 0, size.width * 0.35, size.height * 0.35),
      Rect.fromLTWH(size.width * 0.42, 0, size.width * 0.25, size.height * 0.35),
      Rect.fromLTWH(size.width * 0.72, 0, size.width * 0.28, size.height * 0.35),
      Rect.fromLTWH(0, size.height * 0.42, size.width * 0.35, size.height * 0.22),
      Rect.fromLTWH(size.width * 0.42, size.height * 0.42, size.width * 0.25, size.height * 0.22),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.42, size.width * 0.28, size.height * 0.22),
      Rect.fromLTWH(0, size.height * 0.72, size.width * 0.35, size.height * 0.28),
      Rect.fromLTWH(size.width * 0.42, size.height * 0.72, size.width * 0.25, size.height * 0.28),
      Rect.fromLTWH(size.width * 0.72, size.height * 0.72, size.width * 0.28, size.height * 0.28),
    ]) {
      canvas.drawRRect(RRect.fromRectAndRadius(q, const Radius.circular(4)), qPaint);
    }

    final rPrinc = Paint()..color = Colors.white..strokeWidth = 9..strokeCap = StrokeCap.round;
    final rSecun = Paint()..color = const Color(0xFFF5F0E8)..strokeWidth = 6..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.38), Offset(size.width, size.height * 0.38), rPrinc);
    canvas.drawLine(Offset(0, size.height * 0.68), Offset(size.width, size.height * 0.68), rSecun);
    canvas.drawLine(Offset(size.width * 0.38, 0), Offset(size.width * 0.38, size.height), rPrinc);
    canvas.drawLine(Offset(size.width * 0.70, 0), Offset(size.width * 0.70, size.height), rSecun);

    if (mostrarRota) {
      final rotaCinza = Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
      final pFundo = Path()..moveTo(_rota[0].dx * size.width, _rota[0].dy * size.height);
      for (final p in _rota.skip(1)) pFundo.lineTo(p.dx * size.width, p.dy * size.height);
      canvas.drawPath(pFundo, rotaCinza);

      final rotaAzul = Paint()
        ..color = primaryBlue..strokeWidth = 5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;

      final n = _rota.length - 1;
      double totalLen = 0;
      final lens = <double>[];
      for (int i = 0; i < n; i++) {
        final d = Offset((_rota[i + 1].dx - _rota[i].dx) * size.width,
            (_rota[i + 1].dy - _rota[i].dy) * size.height);
        lens.add(d.distance);
        totalLen += d.distance;
      }

      double alvo = progresso * totalLen;
      final pAzul = Path()..moveTo(_rota[0].dx * size.width, _rota[0].dy * size.height);
      for (int i = 0; i < n; i++) {
        final p0 = Offset(_rota[i].dx * size.width, _rota[i].dy * size.height);
        final p1 = Offset(_rota[i + 1].dx * size.width, _rota[i + 1].dy * size.height);
        if (alvo >= lens[i]) {
          pAzul.lineTo(p1.dx, p1.dy);
          alvo -= lens[i];
        } else {
          final t = alvo / lens[i];
          pAzul.lineTo(p0.dx + (p1.dx - p0.dx) * t, p0.dy + (p1.dy - p0.dy) * t);
          break;
        }
      }
      canvas.drawPath(pAzul, rotaAzul);
    }

    _label(canvas, "Av. Brasil", Offset(size.width * 0.05, size.height * 0.33));
    _label(canvas, "R. das Flores", Offset(size.width * 0.05, size.height * 0.63));
    _label(canvas, "Av. Djalma Batista", Offset(size.width * 0.40, size.height * 0.04), vertical: true);
  }

  void _label(Canvas canvas, String text, Offset pos, {bool vertical = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text,
          style: const TextStyle(color: Color(0xFF888070), fontSize: 10, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    if (vertical) canvas.rotate(-1.5708);
    tp.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(MapaPainter old) =>
      old.progresso != progresso || old.mostrarRota != mostrarRota;
}

// ─────────────────────────────────────────
// AGENDA VIEW
// ─────────────────────────────────────────
class AgendaView extends StatefulWidget {
  const AgendaView({super.key});
  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  bool ida = false, volta = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Confirmação de presença",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _tripCard("Ida • 07:30", ida, () => setState(() => ida = !ida)),
          const SizedBox(height: 16),
          _tripCard("Volta • 18:00", volta, () => setState(() => volta = !volta)),
        ],
      ),
    );
  }

  Widget _tripCard(String title, bool confirmed, VoidCallback tap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: confirmed ? Colors.green.withOpacity(0.4) : Colors.transparent),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmed ? Colors.green : primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: tap,
            child: Text(confirmed ? "✓ Confirmado" : "Confirmar"),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// AVISOS VIEW
// ─────────────────────────────────────────
class AvisosView extends StatelessWidget {
  const AvisosView({super.key});
  @override
  Widget build(BuildContext context) {
    final avisos = [
      {"msg": "Rota chegando em 5 min", "hora": "agora · rota Norte", "icon": Icons.directions_bus, "cor": primaryBlue},
      {"msg": "Atraso de 10 min na rota Sul", "hora": "há 15 min", "icon": Icons.warning_amber_rounded, "cor": Colors.orange},
      {"msg": "Presença confirmada para amanhã", "hora": "há 1h", "icon": Icons.check_circle_outline, "cor": Colors.green},
      {"msg": "Ponto alterado: Av. Djalma, 1200", "hora": "ontem", "icon": Icons.location_on_outlined, "cor": Colors.red},
    ];
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text("Avisos",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: avisos.length,
              itemBuilder: (context, i) {
                final a = avisos[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (a["cor"] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(a["icon"] as IconData, color: a["cor"] as Color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(a["msg"] as String, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(a["hora"] as String, style: const TextStyle(color: Color(0xFF8A9BB0), fontSize: 12)),
                      ]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// PERFIL VIEW
// ─────────────────────────────────────────
class PerfilView extends StatelessWidget {
  const PerfilView({super.key});

  Widget _card(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Color(0xFF8A9BB0), fontSize: 12)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white)),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final userName = authViewModel.currentUser?.name ?? "Usuário";

    // Pega apenas nome e sobrenome
    final partes = userName.split(' ');
    final nomeCompleto = partes.length >= 2
        ? "${partes[0]} ${partes[1]}"
        : userName;

    // Gera as iniciais (ex: João Silva → JS)
    final iniciais = partes.length >= 2
        ? "${partes[0][0]}${partes[1][0]}"
        : userName.substring(0, 1);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 45),
        Center(
          child: Stack(children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: primaryBlue.withOpacity(0.2),
              child: Text(
                iniciais.toUpperCase(),
                style: const TextStyle(color: primaryBlue, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: primaryBlue, shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            nomeCompleto,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const Center(child: Text("Analista de TI · Empresa XYZ", style: TextStyle(color: Color(0xFF8A9BB0)))),
        const SizedBox(height: 24),
        _card("Rota", "ROTA NORTE · PONTO A", Icons.route),
        _card("Ponto de embarque", "Av. Brasil, 450", Icons.location_on),
        _card("Notificações", "Push · SMS · Email", Icons.notifications),
        _card("Histórico", "Últimos 30 dias", Icons.history),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {
            context.go('/login');
          },
          icon: const Icon(Icons.logout),
          label: const Text("Sair"),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}