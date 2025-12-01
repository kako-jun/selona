import 'package:flutter/material.dart';

/// Fake weather screen for panic mode
class FakeWeatherScreen extends StatefulWidget {
  final VoidCallback onExit;

  const FakeWeatherScreen({
    super.key,
    required this.onExit,
  });

  @override
  State<FakeWeatherScreen> createState() => _FakeWeatherScreenState();
}

class _FakeWeatherScreenState extends State<FakeWeatherScreen> {
  // Secret exit: long press on temperature
  void _onSecretExit() {
    widget.onExit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90D9),
              Color(0xFF87CEEB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Location
              const Text(
                'Tokyo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getCurrentDate(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              // Weather icon
              const Icon(
                Icons.wb_sunny,
                color: Colors.yellow,
                size: 100,
              ),
              const SizedBox(height: 20),
              // Temperature (secret exit on long press)
              GestureDetector(
                onLongPress: _onSecretExit,
                child: const Text(
                  '23°',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 96,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              const Text(
                'Sunny',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Spacer(),
              // Hourly forecast
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hourly Forecast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHourlyItem('Now', Icons.wb_sunny, '23°'),
                        _buildHourlyItem('14:00', Icons.wb_sunny, '24°'),
                        _buildHourlyItem('15:00', Icons.wb_cloudy, '22°'),
                        _buildHourlyItem('16:00', Icons.wb_cloudy, '21°'),
                        _buildHourlyItem('17:00', Icons.nights_stay, '19°'),
                      ],
                    ),
                  ],
                ),
              ),
              // Weekly forecast
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weekly Forecast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDailyItem('Today', Icons.wb_sunny, '24°', '18°'),
                    _buildDailyItem('Tomorrow', Icons.wb_cloudy, '22°', '17°'),
                    _buildDailyItem('Wednesday', Icons.grain, '20°', '15°'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  Widget _buildHourlyItem(String time, IconData icon, String temp) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          temp,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyItem(String day, IconData icon, String high, String low) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(
            high,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            low,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
