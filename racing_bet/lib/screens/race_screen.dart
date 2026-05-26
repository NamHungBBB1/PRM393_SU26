import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/user.dart';
import '../models/racer.dart';
import 'result_screen.dart';

class RaceScreen extends StatefulWidget {
  final User user;
  final List<Racer> racers;

  const RaceScreen({super.key, required this.user, required this.racers});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  static const double _trackWidthValue = 1000.0;
  static const Duration _tickInterval = Duration(milliseconds: 50);

  static const double _minBaseSpeed = 0.5;
  static const double _maxBaseSpeed = 2.0;

  Timer? _timer;
  bool _raceStarted = false;
  bool _raceFinished = false;
  Racer? _winner;
  final Random _random = Random();
  int _countdown = 3;

  final Map<int, int> _boostTicks = {};
  final Map<int, double> _currentSpeeds = {};
  
  final AudioPlayer _enginePlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    for (final racer in widget.racers) {
      racer.reset();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _enginePlayer.dispose();
    _bgmPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRaceSounds() async {
    // Chơi nhạc Deja Vu trước
    try {
      await _bgmPlayer.setSource(AssetSource('sound/Dejavu.mp3'));
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.8);
      await _bgmPlayer.resume();
      debugPrint("Đang phát nhạc Deja Vu");
    } catch (e) {
      debugPrint("Lỗi phát nhạc Deja Vu: $e");
    }

    // Chơi tiếng động cơ sau
    try {
      await _enginePlayer.setSource(AssetSource('sound/wings_of_freedom-f1-racing-car-sound-430459.mp3'));
      await _enginePlayer.setReleaseMode(ReleaseMode.loop);
      await _enginePlayer.setVolume(0.4); 
      await _enginePlayer.resume();
      debugPrint("Đang phát tiếng động cơ");
    } catch (e) {
      debugPrint("Lỗi phát tiếng động cơ: $e");
    }
  }

  void _startCountdown() {
    setState(() => _raceStarted = true);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 1) {
          _countdown--;
        } else {
          timer.cancel();
          _countdown = 0;
          _beginRace();
        }
      });
    });
  }

  void _beginRace() {
    _playRaceSounds();
    _currentSpeeds.clear();
    _boostTicks.clear();
    
    for (final racer in widget.racers) {
      _currentSpeeds[racer.id] = _minBaseSpeed + _random.nextDouble() * (_maxBaseSpeed - _minBaseSpeed);
      _boostTicks[racer.id] = 0;
    }
    _timer = Timer.periodic(_tickInterval, _onTick);
  }

  void _onTick(Timer timer) {
    if (!mounted) return;
    setState(() {
      final racerIndices = List.generate(widget.racers.length, (i) => i)..shuffle(_random);

      for (final i in racerIndices) {
        final racer = widget.racers[i];
        double currentSpeed = _currentSpeeds[racer.id] ?? 1.0;
        
        if (_boostTicks[racer.id]! > 0) {
          currentSpeed *= 3.0;
          _boostTicks[racer.id] = _boostTicks[racer.id]! - 1;
        } else {
          if (_random.nextDouble() < 0.018) {
            _boostTicks[racer.id] = 8 + _random.nextInt(12);
          }
          
          _currentSpeeds[racer.id] = (currentSpeed + (_random.nextDouble() * 0.8 - 0.4))
              .clamp(_minBaseSpeed, _maxBaseSpeed);
        }

        racer.position = (racer.position + currentSpeed).clamp(0.0, _trackWidthValue);
      }

      final finished = widget.racers.where((r) => r.position >= _trackWidthValue).toList();
      if (finished.isNotEmpty && !_raceFinished) {
        _raceFinished = true;
        timer.cancel();
        _enginePlayer.stop();
        _bgmPlayer.stop();
        _winner = finished.reduce((a, b) => a.position >= b.position ? a : b);
        _navigateToResult();
      }
    });
  }

  void _navigateToResult() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            user: widget.user,
            racers: widget.racers,
            winner: _winner!,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ARENA OF SPEED',
          style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildLiveStats(),
                const SizedBox(height: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widget.racers.map((r) => _buildRaceLane(r, screenWidth)).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                if (!_raceStarted)
                  _buildStartButton()
                else if (_raceFinished)
                  _buildWinnerAnnouncement()
                else
                  const SizedBox(height: 60),
              ],
            ),
          ),
          
          if (_raceStarted && _countdown > 0)
            _buildCountdownOverlay(),
        ],
      ),
    );
  }

  Widget _buildLiveStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.racers.map((r) => Column(
          children: [
            Image.asset('assets/car-choose-${r.id + 1}.png', width: 40, height: 40, fit: BoxFit.contain),
            const SizedBox(height: 4),
            Text(
              _raceStarted && _countdown == 0 
                ? (_boostTicks[r.id]! > 0 ? '⚡ BOOST' : '${(r.position / _trackWidthValue * 100).toInt()}%') 
                : 'READY',
              style: GoogleFonts.orbitron(
                fontSize: 10, 
                color: _boostTicks[r.id] != null && _boostTicks[r.id]! > 0 ? Colors.amber : r.color,
                fontWeight: _boostTicks[r.id] != null && _boostTicks[r.id]! > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildRaceLane(Racer racer, double screenWidth) {
    final double realTrackWidth = screenWidth - 110;
    final double currentLeft = (racer.position / _trackWidthValue) * realTrackWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              racer.name,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (racer.bet > 0)
              Text(
                'BET: \$${racer.bet.toStringAsFixed(0)}',
                style: GoogleFonts.orbitron(color: Colors.amber, fontSize: 10),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: RoadPainter(offset: _raceStarted && !_raceFinished ? (DateTime.now().millisecondsSinceEpoch / 10) % 40 : 0),
                ),
              ),
              
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Column(
                    children: List.generate(6, (i) => Expanded(
                      child: Container(
                        width: 20,
                        color: i.isEven ? Colors.white : Colors.black,
                      ),
                    )),
                  ),
                ),
              ),
              
              AnimatedPositioned(
                duration: _tickInterval,
                left: currentLeft,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    if (_boostTicks[racer.id] != null && _boostTicks[racer.id]! > 0)
                      Positioned(
                        left: -35,
                        child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 32)
                            .animate(onPlay: (c) => c.repeat())
                            .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3))
                            .shimmer(color: Colors.red)
                            .fadeOut(),
                      ),
                    
                    Image.asset(
                      'assets/car-race-${racer.id + 1}.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ).animate(target: (_boostTicks[racer.id] ?? 0) > 0 ? 1 : 0)
                     .shake(duration: 100.ms, hz: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _startCountdown,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          'RELEASE THE BEASTS',
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Text(
          '$_countdown',
          style: GoogleFonts.orbitron(
            fontSize: 120,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ).animate(key: ValueKey(_countdown))
         .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.5, 1.5))
         .fadeOut(duration: 800.ms),
      ),
    );
  }

  Widget _buildWinnerAnnouncement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
          const SizedBox(width: 12),
          Text(
            'WINNER: ${_winner?.name}',
            style: GoogleFonts.orbitron(
              color: Colors.amber,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }
}

class RoadPainter extends CustomPainter {
  final double offset;

  RoadPainter({this.offset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 2;

    for (double i = -offset; i < size.width; i += 40) {
      if (i + 20 < 0) continue;
      canvas.drawLine(Offset(i, size.height / 2), Offset(i + 20, size.height / 2), paint);
    }
  }

  @override
  bool shouldRepaint(RoadPainter oldDelegate) => oldDelegate.offset != offset;
}
