import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../models/racer.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final User user;
  final List<Racer> racers;
  final Racer winner;

  const ResultScreen({
    super.key,
    required this.user,
    required this.racers,
    required this.winner,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late double _balanceBefore;
  late double _totalWin;

  @override
  void initState() {
    super.initState();
    _balanceBefore = widget.user.balance;
    _applyBetResults();
  }

  void _applyBetResults() {
    _totalWin = 0;
    for (final racer in widget.racers) {
      if (racer.bet <= 0) continue;
      if (racer.id == widget.winner.id) {
        _totalWin += racer.bet * 2;
      }
    }
    final totalBet = widget.racers.fold(0.0, (sum, r) => sum + r.bet);
    widget.user.balance = _balanceBefore - totalBet + _totalWin;
  }

  void _backToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(user: widget.user)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double balanceDiff = widget.user.balance - _balanceBefore;
    final bool isProfit = balanceDiff >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              Text(
                'RACE RESULTS',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Colors.grey.shade500,
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 40),

              // Winner Spotlight
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.05),
                      blurRadius: 40,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/car-choose-${widget.winner.id + 1}.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ).animate().scale(delay: 400.ms, curve: Curves.elasticOut, duration: 800.ms),
                    const SizedBox(height: 16),
                    Text(
                      widget.winner.name,
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'CHAMPION',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ).animate().slideY(begin: 0.5, end: 0).fadeIn(delay: 800.ms),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              // Financial Summary
              _buildFinanceCard(balanceDiff, isProfit).animate().fadeIn(delay: 1.seconds),

              const Spacer(),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: TextButton(
                        onPressed: _backToHome,
                        child: Text(
                          'EXIT TO LOBBY',
                          style: GoogleFonts.orbitron(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _backToHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isProfit ? Colors.greenAccent.shade700 : Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text(
                          'PLAY AGAIN',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 1.2.seconds),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceCard(double diff, bool isProfit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _buildFinanceRow('PREVIOUS BALANCE', '\$${_balanceBefore.toStringAsFixed(0)}', Colors.grey),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10),
          ),
          _buildFinanceRow(
            'TOTAL RETURN',
            '${isProfit ? '+' : ''}\$${diff.toStringAsFixed(0)}',
            isProfit ? Colors.greenAccent : Colors.redAccent,
            large: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white10),
          ),
          _buildFinanceRow(
            'NEW BALANCE',
            '\$${widget.user.balance.toStringAsFixed(0)}',
            Colors.amber,
            large: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value, Color color, {bool large = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: large ? 20 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
