import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/user.dart';
import '../models/racer.dart';
import '../services/auth_service.dart';
import 'race_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _RaceMusicManager {
  static final AudioPlayer _bgPlayer = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> playBGM() async {
    if (_isPlaying) return;
    await _bgPlayer.setSource(AssetSource('sound/wings_of_freedom-f1-racing-car-sound-430459.mp3'));
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setVolume(0.3); // Nhạc nền ở sảnh nên để nhỏ vừa phải
    await _bgPlayer.resume();
    _isPlaying = true;
  }

  static Future<void> stopBGM() async {
    await _bgPlayer.stop();
    _isPlaying = false;
  }
  
  static Future<void> setVolume(double volume) async {
    await _bgPlayer.setVolume(volume);
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Racer> _racers;
  final List<TextEditingController> _betControllers = [];
  String? _errorMessage;
  late PageController _bannerController;
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<String> _banners = [
    'img/BMW.jpg',
    'img/mercedes.jpg',
    'img/Bentley-Continental-GT-1.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _initRacers();
    _bannerController = PageController();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _banners.length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
    _RaceMusicManager.playBGM();
  }

  void _initRacers() {
    _racers = [
      Racer(id: 0, name: 'RED PHANTOM', emoji: '🏎️', color: Colors.redAccent),
      Racer(id: 1, name: 'BLUE THUNDER', emoji: '🚙', color: Colors.blueAccent),
      Racer(id: 2, name: 'NEON GREEN', emoji: '🏎️', color: Colors.greenAccent),
    ];
    _betControllers.clear();
    for (final _ in _racers) {
      _betControllers.add(TextEditingController(text: '0'));
    }
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    for (final c in _betControllers) {
      c.dispose();
    }
    super.dispose();
  }

  double get _totalBet {
    double total = 0;
    for (final c in _betControllers) {
      total += double.tryParse(c.text) ?? 0;
    }
    return total;
  }

  void _startRace() {
    double totalBet = 0;
    for (int i = 0; i < _racers.length; i++) {
      final bet = double.tryParse(_betControllers[i].text) ?? 0;
      if (bet < 0) {
        setState(() => _errorMessage = 'Bet cannot be negative');
        return;
      }
      _racers[i].bet = bet;
      totalBet += bet;
    }

    if (totalBet == 0) {
      setState(() => _errorMessage = 'Place at least one bet');
      return;
    }
    if (totalBet > widget.user.balance) {
      setState(() => _errorMessage = 'Insufficient balance');
      return;
    }

    setState(() => _errorMessage = null);

    // Khi vào đua, tạm dừng hoặc giảm volume nhạc nền lobby nếu RaceScreen có âm thanh riêng
    // Ở đây tôi chọn dừng để RaceScreen phát tiếng động cơ to hơn
    _RaceMusicManager.stopBGM();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RaceScreen(user: widget.user, racers: _racers),
      ),
    ).then((_) {
      // Khi quay lại từ cuộc đua, phát lại nhạc nền lobby
      _RaceMusicManager.playBGM();
      setState(() {});
    });
  }

  void _logout() {
    _RaceMusicManager.stopBGM();
    AuthService().logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ARENA OF SPEED',
          style: GoogleFonts.orbitron(fontSize: 18, letterSpacing: 2, fontWeight: FontWeight.bold, color: Colors.amber),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            _buildBanner(),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  _buildBalanceCard().animate().fadeIn().slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'SELECT YOUR RACER',
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.amber,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 16),

                  // Racer bet rows
                  ...List.generate(_racers.length, (i) {
                    return _buildBetRow(i)
                        .animate()
                        .fadeIn(delay: (300 + (i * 100)).ms)
                        .slideX(begin: 0.1, end: 0);
                  }),

                  const SizedBox(height: 24),

                  // Summary
                  _buildSummarySection().animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 32),

                  // Start Button
                  _buildStartButton().animate().scale(delay: 800.ms, curve: Curves.elasticOut),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) => setState(() => _currentBannerIndex = index),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(_banners[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_banners.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentBannerIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentBannerIndex == index ? Colors.amber : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT BALANCE',
                style: GoogleFonts.montserrat(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${widget.user.balance.toStringAsFixed(0)}',
            style: GoogleFonts.orbitron(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetRow(int index) {
    final racer = _racers[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/car-choose-${index + 1}.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  racer.name,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Odds: 1:${(index + 2) * 0.5 + 1}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
          ),
          _buildBetCounter(index),
        ],
      ),
    );
  }

  Widget _buildBetCounter(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16, color: Colors.amber),
            onPressed: () {
              final val = (double.tryParse(_betControllers[index].text) ?? 0) - 100;
              _betControllers[index].text = val < 0 ? '0' : val.toStringAsFixed(0);
              setState(() {});
            },
          ),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _betControllers[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.orbitron(fontSize: 14, color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              onChanged: (_) => setState(() {}),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16, color: Colors.amber),
            onPressed: () {
              final val = (double.tryParse(_betControllers[index].text) ?? 0) + 100;
              _betControllers[index].text = val.toStringAsFixed(0);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final bool isOverBalance = _totalBet > widget.user.balance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL WAGER', style: GoogleFonts.montserrat(color: Colors.grey, fontSize: 12)),
              Text(
                '\$${_totalBet.toStringAsFixed(0)}',
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  color: isOverBalance ? Colors.redAccent : Colors.white,
                ),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _startRace,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: Colors.redAccent.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flag_rounded),
            const SizedBox(width: 12),
            Text(
              'START ENGINE',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
