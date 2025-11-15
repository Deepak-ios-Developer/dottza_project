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
        primaryColor: const Color(0xFF9B87E8),
        fontFamily: 'SF Pro Display',
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
      daysRemaining: 72,
      deadline: 'Thesis 2026',
      progress: 0.75,
      priority: 'High',
    ),
    Project(
      name: 'Research Documentation',
      daysRemaining: 45,
      deadline: 'Q4 2024',
      progress: 0.6,
      priority: 'Medium',
    ),
    Project(
      name: 'Web Development',
      daysRemaining: 30,
      deadline: 'Dec 2024',
      progress: 0.4,
      priority: 'High',
    ),
  ];

  int get totalProjects => projects.length;
  int get completedProjects => projects.where((p) => p.progress >= 1.0).length;
  double get completionRate =>
      totalProjects > 0 ? (completedProjects / totalProjects) : 0.0;
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

    _progressAnimation = Tween<double>(begin: 0, end: completionRate).animate(
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
      backgroundColor: const Color(0xFFF8F8F6),
      body: SafeArea(
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
                      left: -140,
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
                              painter: OasisWaveCirclePainter(
                                waveAnimation: _waveController.value,
                                progress: _progressAnimation.value,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Percentage inside circle
                    Positioned(
                      left: 32,
                      top: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 58,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 15,
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
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$activeProjects Tasks',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF9B87E8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Goal $totalProjects Tasks',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            '100%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          Text(
                            'Daily Average',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '$completedProjects/$totalProjects',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 12,
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
                      bottom: 40,
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

              // Main action section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    // Project count button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.folder_outlined,
                            size: 22,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Projects',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[900],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Add Task button
                    Expanded(
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9B87E8), Color(0xFF7FB8E8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(27),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9B87E8).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(27),
                            onTap: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Add Task',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF9C4), Color(0xFFFFF59D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time to Go',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[700]),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nearestProject.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${nearestProject.daysRemaining}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                          height: 1,
                        ),
                      ),
                      Text(
                        'Days',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        nearestProject.deadline,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        nearestProject.deadline,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildPriorityMeterCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority Meter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Legend
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPriorityLegend(
                        'High',
                        highPriorityCount,
                        const Color(0xFFFF8A80),
                      ),
                      const SizedBox(height: 12),
                      _buildPriorityLegend(
                        'Medium',
                        mediumPriorityCount,
                        const Color(0xFF9B87E8),
                      ),
                      const SizedBox(height: 12),
                      _buildPriorityLegend(
                        'Low',
                        lowPriorityCount,
                        const Color(0xFFFFE082),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Circular chart
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: PriorityCirclePainter(
                      highCount: highPriorityCount,
                      mediumCount: mediumPriorityCount,
                      lowCount: lowPriorityCount,
                      total: totalProjects,
                    ),
                    child: Center(
                      child: Text(
                        '$totalProjects',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityLegend(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionRateCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE1BEE7), Color(0xFFCE93D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Feedback: Need to improve\non-time completion',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            // Circular progress
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: CompletionCirclePainter(progress: 0.5),
                  ),
                  Center(
                    child: Text(
                      '50%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
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

class OasisWaveCirclePainter extends CustomPainter {
  final double waveAnimation;
  final double progress;

  OasisWaveCirclePainter({required this.waveAnimation, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFE8E8E6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 10, bgPaint);

    // Thick border
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 10, borderPaint);

    // Clip to circle for wave
    canvas.save();
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - 10));
    canvas.clipPath(circlePath);

    // Calculate water level
    final waterLevel = size.height - (size.height * progress);
    final wavePath = Path();
    wavePath.moveTo(0, waterLevel);

    // Create wave
    for (double i = 0; i <= size.width; i++) {
      final waveHeight =
          15 *
          math.sin(
            (i / size.width * 2.5 * math.pi) + (waveAnimation * 2 * math.pi),
          );
      wavePath.lineTo(i, waterLevel + waveHeight);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    // Wave gradient - using green colors
    final waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF9CCC65), Color(0xFF7CB342)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(wavePath, waterPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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

    // High priority
    if (highCount > 0) {
      final highPaint = Paint()
        ..color = const Color(0xFFFF8A80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;
      final highSweep = (highCount / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 8),
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
        ..color = const Color(0xFF9B87E8)
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
        ..color = const Color(0xFFFFE082)
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
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius - 6, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = const Color(0xFF6A4C93)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
