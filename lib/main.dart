import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const DotzzaApp());
}

class DotzzaApp extends StatelessWidget {
  const DotzzaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dotzza Project Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Lato',
        primaryColor: const Color(0xFF9B87E8),
        scaffoldBackgroundColor: const Color(0xFFF8F8F6),
      ),
      home: const DashboardScreen(),
    );
  }
}

class Project {
  String name;
  int daysRemaining;
  String deadline;
  double progress;
  String priority;

  Project({
    required this.name,
    required this.daysRemaining,
    required this.deadline,
    required this.progress,
    required this.priority,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  List<Project> projects = [
    Project(
      name: 'Community Health Project',
      daysRemaining: 79,
      deadline: 'Thesis 2026',
      progress: 0.7,
      priority: 'High',
    ),
    Project(
      name: 'Research Documentation',
      daysRemaining: 45,
      deadline: 'Q4 2024',
      progress: 0.9,
      priority: 'Medium',
    ),
    Project(
      name: 'Web Development',
      daysRemaining: 30,
      deadline: 'Dec 2024',
      progress: 0.9,
      priority: 'High',
    ),
  ];

  int get totalProjects => projects.length;
  int get completedProjects => projects.where((p) => p.progress >= 1.0).length;
  double get completionRate {
    if (totalProjects == 0) return 0.0;
    double totalProgress = projects.fold(0.0, (sum, project) => sum + project.progress);
    return totalProgress / totalProjects;
  }
  int get activeProjects => projects.where((p) => p.progress < 1.0).length;
  int get highPriorityCount =>
      projects.where((p) => p.priority == 'High').length;
  int get mediumPriorityCount =>
      projects.where((p) => p.priority == 'Medium').length;
  int get lowPriorityCount => projects.where((p) => p.priority == 'Low').length;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: completionRate).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _progressController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (completionRate * 100).round();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0X9873e7),
              Color(0X9873e7),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DOTZZA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[800],
                          letterSpacing: 3,
                        ),
                      ),
                      Text(
                        'TASK TRACKER',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Main Wave Circle with Stats
                SizedBox(
                  height: 380,
                  child: Stack(
                    children: [
                      // Wave Circle (left side) - positioned as half circle
                      Positioned(
                        left: -120,
                        top: 50,
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([
                              _waveController,
                              _progressAnimation,
                            ]),
                            builder: (context, child) {
                              return CustomPaint(
                                painter: OasisProgressCirclePainter(
                                  progress: _progressAnimation.value,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Percentage inside circle
                      Positioned(
                        left: 20,
                        top: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF9B87E8),
                                  Color(0xFF7FB8E8),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                '${(completionRate * 100).round()}%',
                                style: const TextStyle(
                                  fontSize: 45,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right side stats
                      Positioned(
                        right: 32,
                        top: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFF9B87E8),
                                  Color(0xFF7FB8E8),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                '$activeProjects Tasks',
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Goal $totalProjects Tasks',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              '100%',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              'Daily Average',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '$completedProjects/$totalProjects',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[900],
                              ),
                            ),
                            Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Emoji
                      Positioned(
                        right: 70,
                        bottom: 10,
                        child: Text(
                          completionRate >= 1.0
                              ? '🎉'
                              : (completionRate >= 0.5 ? '😊' : '🙂'),
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Time to Go Card
                _buildTimeToGoCard(),

                const SizedBox(height: 20),

                // Priority Meter Card
                _buildPriorityMeterCard(),

                const SizedBox(height: 20),

                // Completion Rate Card
                _buildCompletionRateCard(),

                const SizedBox(height: 30),

               
                    
                  
                

                const SizedBox(height: 50),

                // Bottom Navigation
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(Icons.water_drop, true),
                      _buildNavIcon(Icons.access_time_outlined, false),
                      _buildNavIcon(Icons.settings_outlined, false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildTimeToGoCard() {
  if (projects.isEmpty) return const SizedBox.shrink();

  final nearestProject = projects.reduce(
    (a, b) => a.daysRemaining < b.daysRemaining ? a : b,
  );

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9B87E8),
            Color(0xFF8A73D6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B87E8).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'UPCOMING DEADLINE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            nearestProject.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${nearestProject.daysRemaining}',
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 0.9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'DAYS LEFT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'DUE DATE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nearestProject.deadline,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildPriorityMeterCard() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B87E8).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9B87E8).withOpacity(0.15),
                      const Color(0xFF7FB8E8).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF9B87E8), Color(0xFF7FB8E8)],
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF9B87E8), Color(0xFF7FB8E8)],
                ).createShader(bounds),
                child: const Text(
                  'PRIORITY OVERVIEW',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildPriorityItem(
            'High Priority',
            highPriorityCount,
            const Color(0xFF9B87E8),
            Icons.priority_high,
          ),
          const SizedBox(height: 12),
          _buildPriorityItem(
            'Medium Priority',
            mediumPriorityCount,
            const Color(0xFFB39DFF),
            Icons.adjust,
          ),
          const SizedBox(height: 12),
          _buildPriorityItem(
            'Low Priority',
            lowPriorityCount,
            const Color(0xFFD4C5FF),
            Icons.low_priority,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9B87E8).withOpacity(0.15),
                  const Color(0xFF7FB8E8).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF9B87E8), Color(0xFF7FB8E8)],
                  ).createShader(bounds),
                  child: Text(
                    '$totalProjects',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF9B87E8), Color(0xFF7FB8E8)],
                      ).createShader(bounds),
                      child: const Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Text(
                      'Projects',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPriorityItem(String label, int count, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withOpacity(0.12),
          color.withOpacity(0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _buildCompletionRateCard() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF9B87E8),
            Color(0xFF7FB8E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B87E8).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insert_chart,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'COMPLETION RATE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CustomPaint(
                  painter: CompletionCirclePainter(progress: completionRate),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${(completionRate * 100).round()}',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Text(
                    '%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Focus on improving on-time delivery',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildNavIcon(IconData icon, bool isActive) {
    return Icon(
      icon,
      color: isActive ? Colors.grey[900] : Colors.grey[400],
      size: 28,
    );
  }
}

class OasisProgressCirclePainter extends CustomPainter {
  final double progress;

  OasisProgressCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle with subtle gradient effect
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFAF8FF),
          const Color(0xFFF3F0FF),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, bgPaint);

    // Background ring (unfilled portion)
    final bgRingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 2, bgRingPaint);

    // Progress ring with gradient
    final progressRect = Rect.fromCircle(center: center, radius: radius - 2);
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF9B87E8),
          const Color(0xFF9B87E8),
        ],
      ).createShader(progressRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;

    final startAngle = -math.pi / 2;
    final sweepAngle = math.pi * progress;
    
    canvas.drawArc(
      progressRect,
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant OasisProgressCirclePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class PriorityCirclePainter extends CustomPainter {
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final int total;

  PriorityCirclePainter({
    required this.highCount,
    required this.mediumCount,
    required this.lowCount,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawCircle(center, radius - 8, bgPaint);

    if (total == 0) return;

    double startAngle = -math.pi / 2;

    // High priority with gradient
    if (highCount > 0) {
      final highRect = Rect.fromCircle(center: center, radius: radius - 8);
      final highPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF9B87E8),
            const Color(0xFF8A73D6),
          ],
        ).createShader(highRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      final highSweep = (highCount / total) * 2 * math.pi;
      canvas.drawArc(
        highRect,
        startAngle,
        highSweep,
        false,
        highPaint,
      );
      startAngle += highSweep;
    }

    // Medium priority
    if (mediumCount > 0) {
      final mediumPaint = Paint()
        ..color = const Color(0xFFB39DFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      final mediumSweep = (mediumCount / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        startAngle,
        mediumSweep,
        false,
        mediumPaint,
      );
      startAngle += mediumSweep;
    }

    // Low priority
    if (lowCount > 0) {
      final lowPaint = Paint()
        ..color = const Color(0xFFD4C5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      final lowSweep = (lowCount / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
        startAngle,
        lowSweep,
        false,
        lowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CompletionCirclePainter extends CustomPainter {
  final double progress;

  CompletionCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 6, bgPaint);

    // Progress arc with gradient
    final progressRect = Rect.fromCircle(center: center, radius: radius - 6);
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white,
        ],
      ).createShader(progressRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      progressRect,
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}