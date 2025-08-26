import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/chart_widget.dart';
import '../screens/logic/data_logic.dart';

class DataScreen extends StatelessWidget {
  const DataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: const ChartWidget(),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 80, // Lower the text block to align with chart
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Driver Monitoring',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Colors.orange,
                                size: 10,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Medium Alarm',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.red, size: 10),
                              SizedBox(width: 6),
                              Text(
                                'High Alarm',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 10),
                              SizedBox(width: 6),
                              Text('Low Alarm', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Color.fromARGB(255, 0, 225, 255),
                                size: 10,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Time Usage',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Color.fromARGB(255, 190, 0, 117),
                                size: 10,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Driving Hours',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommendations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Consumer<DataLogic>(
              builder: (context, dataLogic, child) {
                return Column(
                  children: [
                    ...generateRecommendations(dataLogic).take(5),
                    // Add a section for detailed statistics
                    const SizedBox(height: 20),
                    const Text(
                      'Detailed Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStatsCard(
                      'Total Alerts',
                      dataLogic.totalAlerts.toString(),
                      Icons.warning,
                    ),
                    const SizedBox(height: 10),
                    _buildStatsCard(
                      'High Alarms',
                      dataLogic.highAlarms.toString(),
                      Icons.error,
                    ),
                    const SizedBox(height: 10),
                    _buildStatsCard(
                      'Safe Driving Score',
                      '${dataLogic.safeDrivingScore}%',
                      Icons.star,
                    ),
                    const SizedBox(height: 10),
                    _buildStatsCard(
                      'Usage Percentage',
                      '${dataLogic.usagePercentage}%',
                      Icons.timer,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF018ABD)),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF018ABD),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> generateRecommendations(DataLogic dataLogic) {
  List<Widget> recommendations = [];

  recommendations.add(
    RecommendationCard(
      title: 'Take Regular Breaks',
      description:
          'Frequent high alarms detected. Rest every 2 hours to stay alert.',
      icon: Icons.local_cafe,
      color: Colors.orange.withAlpha(102), // matched to pie chart orange
    ),
  );

  recommendations.add(
    RecommendationCard(
      title: 'Improve Driving Habits',
      description: 'Avoid distractions to keep your score high.',
      icon: Icons.warning,
      color: Colors.red.withAlpha(102), // matched to pie chart red
    ),
  );

  recommendations.add(
    RecommendationCard(
      title: 'Great Job!',
      description: 'Your safe driving score is excellent. Keep it up!',
      icon: Icons.thumb_up,
      color: Colors.green.withAlpha(102), // matched to pie chart green
    ),
  );

  recommendations.add(
    RecommendationCard(
      title: 'Monitor Fatigue',
      description: 'High usage detected. Ensure rest between drives.',
      icon: Icons.bedtime,
      color: Colors.blue.withAlpha(102), // matched to pie chart blue
    ),
  );

  recommendations.add(
    RecommendationCard(
      title: 'Check Vehicle',
      description: 'Routine vehicle checks improve safety.',
      icon: Icons.build,
      color: Colors.purple.withAlpha(102), // optional extra color
    ),
  );

  return recommendations;
}

class RecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const RecommendationCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
