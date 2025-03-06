import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../storage.dart';

class MoodTrendsScreen extends StatefulWidget {
  final Storage storage; // Accept the Storage instance

  const MoodTrendsScreen({super.key, required this.storage});

  @override
  _MoodTrendsScreenState createState() => _MoodTrendsScreenState();
}

class _MoodTrendsScreenState extends State<MoodTrendsScreen> {
  List<Map<String, dynamic>> moodEntries = [];

  @override
  void initState() {
    super.initState();
    loadMoodEntries();
  }

  Future<void> loadMoodEntries() async {
    try {
      final entries = await widget.storage.getAllMoodJournalEntries();
      setState(() {
        moodEntries = entries;
      });
    } catch (e) {
      debugPrint('Error loading mood entries: $e');
    }
  }

  List<FlSpot> getMoodData() {
    List<FlSpot> data = [];
    for (int i = 0; i < moodEntries.length; i++) {
      final entry = moodEntries[i];
      double intensity = double.tryParse(entry['intensity'].toString()) ?? 0.0;
      data.add(FlSpot(i.toDouble(), intensity));
    }
    return data;
  }

  List<String> getMoodLabels() {
    return moodEntries.map((e) => e['mood'] as String).toList();
  }

  @override
  Widget build(BuildContext context) {
    final moodData = getMoodData();
    final moodLabels = getMoodLabels();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Trends'),
      ),
      body: moodData.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval:
                            1, // Show a title every 1 interval to prevent overcrowding
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < moodLabels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                moodLabels[index],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          } else {
                            return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize:
                            40, // Reserve more space for better readability
                        interval:
                            1, // Interval of values on the y-axis for better visualization
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: moodData,
                      isCurved: true,
                      barWidth: 3,
                      color:
                          Colors.blue, // Single color to avoid list type error
                      dotData: const FlDotData(
                        show: true,
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.lightBlue.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: Text('No mood entries yet.'),
            ),
    );
  }
}
