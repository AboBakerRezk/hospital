import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientDetailScreen extends StatefulWidget {
  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final DBHelper _dbHelper = DBHelper();
  Patient? _patient;
  bool isLoadingChartData = false;
  List<FlSpot> spots = [];

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() {
      isLoadingChartData = true;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      spots = [
        FlSpot(0, 80),
        FlSpot(1, 90),
        FlSpot(2, 85),
        FlSpot(3, 95),
        FlSpot(4, 90),
        FlSpot(5, 100),
        FlSpot(6, 98),
      ];
      isLoadingChartData = false;
    });
  }

  Widget _getBottomTitle(double value, TitleMeta meta) {
    String label;
    switch (value.toInt()) {
      case 0:
        label = 'Saturday';
        break;
      case 1:
        label = 'Sunday';
        break;
      case 2:
        label = 'Monday';
        break;
      case 3:
        label = 'Tuesday';
        break;
      case 4:
        label = 'Wednesday';
        break;
      case 5:
        label = 'Thursday';
        break;
      case 6:
        label = 'Friday';
        break;
      default:
        label = '';
        break;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(label, style: TextStyle(fontSize: 12)),
    );
  }

  Future<void> _fetchPatient(int id) async {
    final patient = await _dbHelper.getPatientById(id);
    if (patient != null) {
      setState(() {
        _patient = patient;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient data not found')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int patientId = args['id'];

    if (_patient == null) {
      _fetchPatient(patientId);
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.teal[700]),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final String name = _patient!.name;
    final int age = _patient!.age;
    final String condition = _patient!.condition;
    final String analysisResult = _patient!.analysisResult;
    final String filePath = _patient!.filePath;

    // يمكنك إضافة المزيد من الحقول هنا لعرض باقي البيانات مثل قياسات الضغط، الوزن، إلخ.
    // على سبيل المثال:
    final int systolicBP = _patient!.systolicBP;
    final int diastolicBP = _patient!.diastolicBP;
    final int heartRate = _patient!.heartRate;
    final double weight = _patient!.weight;
    final double height = _patient!.height;
    final double temperature = _patient!.temperature;
    final int respiratoryRate = _patient!.respiratoryRate;
    final int cholesterol = _patient!.cholesterol;
    final int bloodSugar = _patient!.bloodSugar;
    final int oxygenSaturation = _patient!.oxygenSaturation;
    final String smokingStatus = _patient!.smokingStatus;
    final String exerciseFrequency = _patient!.exerciseFrequency;
    final String medicalHistory = _patient!.medicalHistory;
    final String medications = _patient!.medications;
    final String notes = _patient!.notes;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: Colors.teal[700],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(name),
              background: Container(color: Colors.teal[300]),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh),
                tooltip: 'Refresh Chart',
                onPressed: _loadChartData,
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Basic Information
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.person, color: Colors.teal[700]),
                              title: Text(name),
                              subtitle: Text('Age: $age'),
                            ),
                            ListTile(
                              leading: Icon(Icons.health_and_safety, color: Colors.teal[700]),
                              title: Text('Condition: $condition'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Detailed Measurements
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.only(top: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Patient Measurements:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Divider(),
                            Text('Blood Pressure: $systolicBP/$diastolicBP mmHg'),
                            Text('Heart Rate: $heartRate bpm'),
                            Text('Weight: ${weight.toStringAsFixed(1)} kg'),
                            Text('Height: ${height.toStringAsFixed(1)} cm'),
                            Text('Temperature: ${temperature.toStringAsFixed(1)} °C'),
                            Text('Respiratory Rate: $respiratoryRate breaths/min'),
                            Text('Cholesterol: $cholesterol mg/dL'),
                            Text('Blood Sugar: $bloodSugar mg/dL'),
                            Text('Oxygen Saturation: $oxygenSaturation %'),
                            Text('Smoking Status: $smokingStatus'),
                            Text('Exercise Frequency: $exerciseFrequency'),
                            Text('Medical History: $medicalHistory'),
                            Text('Medications: $medications'),
                            Text('Notes: $notes'),
                          ],
                        ),
                      ),
                    ),

                    // Display PDF file if exists
                    if (filePath.isNotEmpty)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.only(top: 16),
                        child: ListTile(
                          leading: Icon(Icons.picture_as_pdf, color: Colors.red),
                          title: Text('Local PDF File'),
                          subtitle: Text(filePath),
                          onTap: () async {
                            final uri = Uri.file(filePath);
                            if (!await launchUrl(uri)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not open the file')),
                              );
                            }
                          },
                        ),
                      ),

                    // AI Analysis Results
                    if (analysisResult.isNotEmpty)
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        margin: EdgeInsets.only(top: 16),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Analysis Results:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(),
                              Text(analysisResult),
                            ],
                          ),
                        ),
                      ),

                    // Chart Section
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.only(top: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Blood Pressure / Heart Rate Chart (Weekly)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              height: 250,
                              child: isLoadingChartData
                                  ? Center(child: CircularProgressIndicator())
                                  : LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: 6,
                                  minY: 70,
                                  maxY: 110,
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: _getBottomTitle,
                                        reservedSize: 32,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(fontSize: 12),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: spots,
                                      isCurved: true,
                                      barWidth: 3,
                                      color: Colors.teal,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(show: true),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Additional Predictive Results (Example)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.only(top: 16),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Predictive Results',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(),
                            Text(
                              'Risk Percentage: 70% - It is advised to consult a doctor and perform regular checkups.',
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.calendar_today),
                          label: Text('Schedule Appointment'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Feature under development')),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.share),
                          label: Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[700],
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Data shared successfully')),
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[700],
        child: Icon(Icons.refresh),
        onPressed: _loadChartData,
      ),
    );
  }
}
