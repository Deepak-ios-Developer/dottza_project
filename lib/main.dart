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
        primaryColor: const Color(0xFF8c64e4),
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFE8EAE6),
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

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
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
  double get completionRate => totalProjects > 0 ? (completedProjects / totalProjects) : 0.0;
  int get teamMembers => 21;
  int get hoursLogged => 0;
  int get highPriorityCount => projects.where((p) => p.priority == 'High').length;
  int get mediumPriorityCount => projects.where((p) => p.priority == 'Medium').length;
  int get lowPriorityCount => projects.where((p) => p.priority == 'Low').length;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: completionRate,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value,
      end: completionRate,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.reset();
    _progressController.forward();
  }

  void _showAddProjectDialog() {
    final nameController = TextEditingController();
    final daysController = TextEditingController();
    final deadlineController = TextEditingController();
    String selectedPriority = 'Medium';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: daysController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Days Remaining',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deadlineController,
                decoration: InputDecoration(
                  labelText: 'Deadline',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                items: ['High', 'Medium', 'Low'].map((priority) {
                  return DropdownMenuItem(value: priority, child: Text(priority));
                }).toList(),
                onChanged: (value) {
                  selectedPriority = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
                      ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8c64e4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty && daysController.text.isNotEmpty) {
                setState(() {
                  projects.add(Project(
                    name: nameController.text,
                    daysRemaining: int.tryParse(daysController.text) ?? 0,
                    deadline: deadlineController.text,
                    progress: 0.0,
                    priority: selectedPriority,
                  ));
                  _updateProgress();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateProjectProgress(int index, double newProgress) {
    setState(() {
      projects[index].progress = newProgress.clamp(0.0, 1.0);
      _updateProgress();
    });
  }

  void _deleteProject(int index) {
    setState(() {
      projects.removeAt(index);
      _updateProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (completionRate * 100).round();
    final isGoalReached = completionRate >= 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAE6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOTZZA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey[700],
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'PROJECT TRACKER',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Main Progress Circle with Wave (KEPT AS IS)
              SizedBox(
                height: 400,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_waveController, _progressAnimation]),
                        builder: (context, child) {
                          return CustomPaint(
                            painter: WaveCirclePainter(
                              waveAnimation: _waveController.value,
                              progress: _progressAnimation.value,
                            ),
                          );
                        },
                      ),
                    ),

                    // Percentage Text
                    Positioned(
                      left: 60,
                      top: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$percentage%',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right side stats
                    Positioned(
                      right: 40,
                      top: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Projects', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          const SizedBox(height: 4),
                          Text('$completedProjects/$totalProjects', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Color(0xFF8c64e4))),
                          const SizedBox(height: 2),
                          Text('Goal $totalProjects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                          const SizedBox(height: 40),
                          Text('${highPriorityCount}H ${mediumPriorityCount}M', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800])),
                          Text('Priority Mix', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          const SizedBox(height: 12),
                          Text('$teamMembers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                          Text('Team Members', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                        ],
                      ),
                    ),

                    // Emoji
                    Positioned(
                      right: 60,
                      bottom: 20,
                      child: Text(
                        isGoalReached ? '🎉' : (completionRate > 0.5 ? '😊' : '🙂'),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ],
                ),
              ),

              // Time to Go Section
              const SizedBox(height: 20),
              _buildTimeToGoCard(),
              const SizedBox(height: 20),

              // NEW SECTION: Grid Cards Below
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1
                    Expanded(
                      child: Column(
                        children: [
                          _buildSmallMetricCard('Active Projects', '$totalProjects', 'Ongoing', Icons.folder_outlined),
                          const SizedBox(height: 12),
                          _buildSmallMetricCard('Team Members', '$teamMembers', 'All Projects', Icons.people_outline),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Column 2
                    Expanded(
                      child: Column(
                        children: [
                          _buildSmallMetricCard('Completion', '${(completionRate * 100).round()}%', 'Rate', Icons.check_circle_outline),
                          const SizedBox(height: 12),
                          _buildSmallMetricCard('Hours', '$hoursLogged', 'This Month', Icons.access_time),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Column 3
                    Expanded(child: _buildPriorityMeterCard()),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // // Project List
              // if (projects.isNotEmpty) ...[
              //   Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 24),
              //     child: Align(
              //       alignment: Alignment.centerLeft,
              //       child: Text('Active Projects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
              //     ),
              //   ),
              //   const SizedBox(height: 12),
              //   SizedBox(
              //     height: 80,
              //     child: ListView.builder(
              //       scrollDirection: Axis.horizontal,
              //       padding: const EdgeInsets.symmetric(horizontal: 24),
              //       itemCount: projects.length,
              //       itemBuilder: (context, index) {
              //         return GestureDetector(
              //           onTap: () => _showProjectDetails(index),
              //           child: Container(
              //             width: 100,
              //             margin: const EdgeInsets.only(right: 12),
              //             padding: const EdgeInsets.all(12),
              //             decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(projects[index].name, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey[800]), maxLines: 2, overflow: TextOverflow.ellipsis),
              //                 const Spacer(),
              //                 LinearProgressIndicator(value: projects[index].progress, backgroundColor: Colors.grey[400], color: const Color(0xFF8c64e4), minHeight: 4, borderRadius: BorderRadius.circular(2)),
              //               ],
              //             ),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              //   const SizedBox(height: 8),
              //   Text('Tap to edit', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              //   const SizedBox(height: 20),
              // ],

              // // Add Project Button
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 24),
              //   child: Row(
              //     children: [
              //       Container(
              //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //         decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
              //         child: Row(
              //           children: [
              //             Icon(Icons.folder_outlined, color: Colors.grey[700], size: 20),
              //             const SizedBox(width: 8),
              //             Text('$totalProjects Projects', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[800])),
              //           ],
              //         ),
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: GestureDetector(
              //           onTap: _showAddProjectDialog,
              //           child: Container(
              //             padding: const EdgeInsets.symmetric(vertical: 14),
              //             decoration: BoxDecoration(
              //               color: const Color(0xFF8c64e4),
              //               borderRadius: BorderRadius.circular(12),
              //               boxShadow: [BoxShadow(color: const Color(0xFF8c64e4).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
              //             ),
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: [
              //                 Container(
              //                   padding: const EdgeInsets.all(4),
              //                   decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
              //                   child: const Icon(Icons.add, color: Colors.white, size: 18),
              //                 ),
              //                 const SizedBox(width: 8),
              //                 const Text('Add Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 30),

              // Bottom Navigation
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.dashboard, color: Colors.grey[800], size: 28),
                    Icon(Icons.access_time, color: Colors.grey[400], size: 28),
                    Icon(Icons.settings, color: Colors.grey[400], size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallMetricCard(String label, String value, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8c64e4)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.grey[800])),
          Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildTimeToGoCard() {
    // Find project with earliest deadline
    if (projects.isEmpty) return const SizedBox.shrink();
    
    final nearestProject = projects.reduce((a, b) => 
      a.daysRemaining < b.daysRemaining ? a : b
    );

    final isUrgent = nearestProject.daysRemaining < 30;
    final primaryColor = isUrgent ? const Color(0xFFFF6B9D) : const Color(0xFF8c64e4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Next Deadline',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  nearestProject.priority,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Main content - horizontal layout
          Row(
            children: [
              // Left side - Project info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nearestProject.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          nearestProject.deadline,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress indicator
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: nearestProject.progress,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(nearestProject.progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Right side - Days counter
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.15),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${nearestProject.daysRemaining}',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: primaryColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DAYS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: primaryColor.withOpacity(0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Bottom divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey[300]!,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityMeterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800])),
          const SizedBox(height: 16),
          CustomPaint(
            size: const Size(100, 100),
            painter: MultiSegmentCircularPainter(highCount: highPriorityCount, mediumCount: mediumPriorityCount, lowCount: lowPriorityCount, total: totalProjects),
            child: SizedBox(width: 100, height: 100, child: Center(child: Text('$totalProjects', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.grey[800])))),
          ),
          const SizedBox(height: 16),
          _buildLegendItem('High', highPriorityCount, const Color(0xFFFF6B9D)),
          const SizedBox(height: 6),
          _buildLegendItem('Medium', mediumPriorityCount, const Color(0xFF8B7BF7)),
          const SizedBox(height: 6),
          _buildLegendItem('Low', lowPriorityCount, const Color(0xFFE0E0E0)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label: $count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey[700])),
      ],
    );
  }

  void _showProjectDetails(int index) {
    final project = projects[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(project.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50)))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            Text('${project.daysRemaining} days • ${project.deadline}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 20),
            Text('Progress: ${(project.progress * 100).round()}%', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setSliderState) => Slider(
                value: project.progress,
                onChanged: (value) {
                  setSliderState(() => _updateProjectProgress(index, value));
                },
                activeColor: const Color(0xFF8c64e4),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _deleteProject(index);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 14)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8c64e4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WaveCirclePainter extends CustomPainter {
  final double waveAnimation;
  final double progress;

  WaveCirclePainter({required this.waveAnimation, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()..color = Colors.grey[300]!..style = PaintingStyle.stroke..strokeWidth = 35;
    canvas.drawCircle(center, radius - 20, bgPaint);

    canvas.save();
    final circlePath = Path()..addOval(Rect.fromCircle(center: center, radius: radius - 20));
    canvas.clipPath(circlePath);

    final waterLevel = size.height - (size.height * progress);
    final wavePath = Path();
    wavePath.moveTo(0, waterLevel);

    for (double i = 0; i <= size.width; i++) {
      final waveHeight = 15 * math.sin((i / size.width * 4 * math.pi) + (waveAnimation * 2 * math.pi));
      wavePath.lineTo(i, waterLevel + waveHeight);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.lineTo(0, size.height);
    wavePath.close();

    final waterPaint = Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFa88bd9), Color(0xFF8c64e4)]).createShader(Rect.fromLTWH(0, 0, size.width, size.height))..style = PaintingStyle.fill;
    canvas.drawPath(wavePath, waterPaint);
    canvas.restore();

    final progressPaint = Paint()..color = const Color(0xFF8c64e4)..style = PaintingStyle.stroke..strokeWidth = 35..strokeCap = StrokeCap.round;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 20), -math.pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MultiSegmentCircularPainter extends CustomPainter {
  final int highCount;
  final int mediumCount;
  final int lowCount;
  final int total;

  MultiSegmentCircularPainter({required this.highCount, required this.mediumCount, required this.lowCount, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()..color = const Color(0xFFE0E0E0)..style = PaintingStyle.stroke..strokeWidth = 14;
    canvas.drawCircle(center, radius - 7, bgPaint);

    if (total == 0) return;

    double startAngle = -math.pi / 2;

    if (highCount > 0) {
      final highPaint = Paint()..color = const Color(0xFFFF6B9D)..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round;
      final highSweep = (highCount / total) * 2 * math.pi;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 7), startAngle, highSweep, false, highPaint);
      startAngle += highSweep;
    }

    if (mediumCount > 0) {
      final mediumPaint = Paint()..color = const Color(0xFF8B7BF7)..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round;
      final mediumSweep = (mediumCount / total) * 2 * math.pi;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 7), startAngle, mediumSweep, false, mediumPaint);
      startAngle += mediumSweep;
    }

    if (lowCount > 0) {
      final lowPaint = Paint()..color = const Color(0xFFBDBDBD)..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round;
      final lowSweep = (lowCount / total) * 2 * math.pi;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 7), startAngle, lowSweep, false, lowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TimeToGoCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  TimeToGoCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Decorative dots
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final dotX = center.dx + (radius + 3) * math.cos(angle);
      final dotY = center.dy + (radius + 3) * math.sin(angle);
      
      final dotPaint = Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(dotX, dotY), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}