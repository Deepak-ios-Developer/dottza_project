import 'package:dotzza_project/data/project_data.dart';
import 'package:dotzza_project/widgets/progress_circle_widgets.dart';
import 'package:flutter/material.dart';

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
      progress: 0.90,
      priority: 'Low',
    ),
    Project(
      name: 'Research Documentation',
      daysRemaining: 45,
      deadline: 'Q4 2024',
      progress: 0.28,
      priority: 'Medium',
    ),
    Project(
      name: 'Web Development',
      daysRemaining: 40,
      deadline: 'Dec 2024',
      progress: 0.87,
      priority: 'High',
    ),
    Project(
      name: 'App Development',
      daysRemaining: 15,
      deadline: 'Feb 2025',
      progress: 0.12,
      priority: 'Least',
    ),
  ];

  int get totalProjects => projects.length;
  int get completedProjects => projects.where((p) => p.progress >= 1.0).length;
  double get completionRate {
    if (totalProjects == 0) return 0.0;
    return projects.fold(0.0, (sum, p) => sum + p.progress) / totalProjects;
  }
  int get activeProjects => projects.where((p) => p.progress < 1.0).length;
  int get highPriorityCount => projects.where((p) => p.priority == 'High').length;
  int get mediumPriorityCount => projects.where((p) => p.priority == 'Medium').length;
  int get lowPriorityCount => projects.where((p) => p.priority == 'Low').length;
  int get leastPriorityCount => projects.where((p) => p.priority == 'Least').length;

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
    return Scaffold(
      body: Container(
 decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFDFD4F8), // primary100
              Color(0xFFF5F1FD), // primary50
              Color(0xFFDFD4F8), // primary100
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
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
                SizedBox(
                  height: 380,
                  child: Stack(
                    children: [
                      Positioned(
                        left: -120,
                        top: 50,
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_waveController, _progressAnimation]),
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
                      Positioned(
                        left: 20,
                        top: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF9B87E8), Color(0xFF7FB8E8)],
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
                      Positioned(
                        right: 32,
                        top: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Today', style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w400)),
                            const SizedBox(height: 4),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF9B87E8), Color(0xFF7FB8E8)],
                              ).createShader(bounds),
                              child: Text('$activeProjects Tasks', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                            const SizedBox(height: 4),
                            Text('Goal $totalProjects Tasks', style: TextStyle(fontSize: 20, color: Colors.grey[800], fontWeight: FontWeight.w500)),
                            const SizedBox(height: 40),
                            Text('100%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.grey[900])),
                            Text('Daily Average', style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w400)),
                            const SizedBox(height: 20),
                            Text('$completedProjects/$totalProjects', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.grey[900])),
                            Text('Completed', style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 25,
                        bottom: -10,
                        child: Text(
                          completionRate >= 1.0 ? '🎉' : (completionRate >= 0.5 ? '😊' : '🙂'),
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _taskCompletionWidget(),
                const SizedBox(height: 30),
                _taskBoardWidget(),
                const SizedBox(height: 30),
                _sectionTitle("Time to Go"),
                const SizedBox(height: 15),
                _buildTimeToGoCard(),
                const SizedBox(height: 30),
                _sectionTitle("Priority Meter"),
                const SizedBox(height: 40),
                _buildPriorityMeterCard(),
                const SizedBox(height: 30),
                _sectionTitle("Project Overview"),
                const SizedBox(height: 15),
                _buildProjectCards(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _taskCompletionWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: const [
              Text("23", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black)),
              SizedBox(height: 4),
              Text("To Do", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 25),
          Container(height: 35, width: 2, color: Colors.black),
          const SizedBox(width: 25),
          Column(
            children: const [
              Text("32", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.black)),
              SizedBox(height: 4),
              Text("Doing", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 25),
          Container(height: 35, width: 2, color: Colors.black),
          const SizedBox(width: 25),
          Column(
            children: const [
              Text("12", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black)),
              SizedBox(height: 4),
              Text("Done", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _taskBoardWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text("Task Board", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              children: [
                Text("+ ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Add Task", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeToGoCard() {
    if (projects.isEmpty) return const SizedBox.shrink();
    final nearestProject = projects.reduce((a, b) => a.daysRemaining < b.daysRemaining ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: primary100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nearestProject.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),
                  const Text("Team members", style: TextStyle(fontSize: 13, color: Colors.black45)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _avatar("https://i.pravatar.cc/100?img=1"),
                      const SizedBox(width: 8),
                      _avatar("https://i.pravatar.cc/100?img=2"),
                      const SizedBox(width: 8),
                      _avatar("https://i.pravatar.cc/100?img=3"),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(width: 12, height: 12, decoration: const BoxDecoration(color: Color(0xFFE4775D), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(nearestProject.deadline, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                  child: Text("${nearestProject.daysRemaining}d", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        value: nearestProject.progress,
                        strokeWidth: 5,
                        backgroundColor: Colors.white.withOpacity(0.4),
                        valueColor: const AlwaysStoppedAnimation(Colors.black),
                      ),
                    ),
                    Text("${(nearestProject.progress * 100).round()}%", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String url) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white,
      child: CircleAvatar(radius: 14, backgroundImage: NetworkImage(url)),
    );
  }

  Widget _buildPriorityMeterCard() {
    return SizedBox(
      height: 200,
      child: Center(
        child: MultiRingProgress(
          high: highPriorityCount / totalProjects,
          medium: mediumPriorityCount / totalProjects,
          low: lowPriorityCount / totalProjects,
          least: leastPriorityCount / totalProjects,
        ),
      ),
    );
  }

  Widget _buildProjectCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildActiveProjectsCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildCompletionRateCard()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTeamMembersCard()),
              const SizedBox(width: 16),
              Expanded(child: _buildHoursLoggedCard()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProjectsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFFFF6DD), borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(alignment: Alignment.topRight, child: Icon(Icons.wb_sunny_outlined, color: Colors.orange.shade300, size: 26)),
          const SizedBox(height: 12),
          Text("$activeProjects", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 4),
          const Text("Active Projects", style: TextStyle(color: Colors.orange, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCompletionRateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFE5F0FF), borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(alignment: Alignment.topRight, child: Icon(Icons.nightlight_round, color: Colors.blue.shade400, size: 26)),
          const SizedBox(height: 6),
          Text("${(completionRate * 100).round()}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Color(0xFF2B3A55))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [48.0, 64.0, 58.0, 40.0, 70.0, 55.0].map((h) => Container(
              width: 6,
              height: h,
              decoration: BoxDecoration(color: Colors.blue.shade300.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          const Text("Completion Rate", style: TextStyle(fontSize: 14, color: Color(0xFF6E86A6))),
        ],
      ),
    );
  }

  Widget _buildTeamMembersCard() {
    const int teamMembers = 1;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF7E7E9), borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(alignment: Alignment.topRight, child: Icon(Icons.people_outline, color: Colors.pink.shade300, size: 26)),
          const SizedBox(height: 10),
          Center(
            child: SizedBox(
              height: 140,
              width: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: teamMembers / 100,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation(Colors.pink.shade300),
                    backgroundColor: Colors.white.withOpacity(0.45),
                  ),
                  Text("$teamMembers", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.pink.shade300)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text("Team Members", style: TextStyle(fontSize: 15, color: Color(0xFFB27C84))),
        ],
      ),
    );
  }

  Widget _buildHoursLoggedCard() {
    const int hoursLogged = 12;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFE2F4FF), borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(alignment: Alignment.topRight, child: Icon(Icons.cloud_outlined, color: Colors.blue.shade400, size: 26)),
          const SizedBox(height: 6),
          const Text("$hoursLogged h", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Color(0xFF2B3A55))),
          const SizedBox(height: 8),
          CustomPaint(size: const Size(double.infinity, 40), painter: SleepGraphPainter()),
          const SizedBox(height: 8),
          const Text("Hours Logged", style: TextStyle(fontSize: 14, color: Color(0xFF6E86A6))),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2B3A55)), textAlign: TextAlign.left),
        ),
      ],
    );
  }
}

const Color primary50 = Color(0xFFF5F1FD);
const Color primary100 = Color(0xFFDFD4F8);
const Color primary200 = Color(0xFFD0BFF4);
const Color primary300 = Color(0xFFBAAEEF);
const Color primary400 = Color(0xFFAADFEC);
const Color primary500 = Color(0xFF9873E7);
const Color primary600 = Color(0xFF8A6BD2);
const Color primary700 = Color(0xFF6C52A4);
const Color primary800 = Color(0xFF543F71);
const Color primary900 = Color(0xFF403061);
const Color blue500 = Color(0xFF6EB2E0);
const Color red500 = Color(0xFFE48686);
const Color yellow500 = Color(0xFFF9E76E);