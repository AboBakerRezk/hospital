import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class DoctorAnalyticsScreen extends StatefulWidget {
  const DoctorAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorAnalyticsScreen> createState() => _DoctorAnalyticsScreenState();
}

class _DoctorAnalyticsScreenState extends State<DoctorAnalyticsScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isInitialized = false;
  String _distinctId = '';
  String _featureFlagStatus = '';
  bool _debugEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializePostHog();
  }

  /// Initialize PostHog with configuration settings.
  Future<void> _initializePostHog() async {
    try {
      final config = PostHogConfig('phc_xWI3Ehu3mnSBVG2pSGY7NHJCbJ5WIzEfKusZ4kkdaWP'); // Replace with your API key.
      config.host = 'https://us.i.posthog.com'; // Replace with your host if needed.
      config.debug = true;
      config.captureApplicationLifecycleEvents = true;
      config.sessionReplay = true;
      config.sessionReplayConfig.maskAllTexts = false;
      config.sessionReplayConfig.maskAllImages = false;
      config.sessionReplayConfig.throttleDelay = const Duration(milliseconds: 1000);
      config.flushAt = 1;

      await Posthog().setup(config);

      setState(() {
        _isInitialized = true;
      });

      // Track screen view event.
      Posthog().capture(
        eventName: 'Doctor Analytics Screen Opened',
        properties: {
          'screen': 'DoctorAnalyticsScreen',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error initializing PostHog: $e');
    }
  }

  /// Track a custom event.
  void _trackEvent(String eventName, [Map<String, Object>? props]) {
    Posthog().capture(
      eventName: eventName,
      properties: props ?? {},
    );
  }

  /// Identify the doctor.
  void _identifyDoctor(String doctorId) {
    Posthog().identify(
      userId: doctorId,
      userProperties: {
        'role': 'doctor',
        'department': 'Cardiology',
      },
      userPropertiesSetOnce: {
        'initialSetup': true,
      },
    );
  }

  /// Flush pending events.
  Future<void> _flushEvents() async {
    await Posthog().flush();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Events flushed', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Disable event capture.
  void _disableCapture() {
    Posthog().disable();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Capture disabled', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Enable event capture.
  void _enableCapture() {
    Posthog().enable();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Capture enabled', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Get the distinct ID.
  Future<void> _getDistinctId() async {
    final result = await Posthog().getDistinctId();
    setState(() {
      _distinctId = result.toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Distinct ID fetched', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Check feature flag status.
  Future<void> _checkFeatureFlag() async {
    final result = await Posthog().getFeatureFlag('doctor_dashboard_feature');
    setState(() {
      _featureFlagStatus = result.toString();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature flag checked', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Assign doctor to a group.
  Future<void> _assignGroup() async {
    await Posthog().group(
      groupType: 'department',
      groupKey: 'Cardiology',
      groupProperties: {
        'floor': '2',
        'shift': 'morning',
      },
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Group assigned', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Create an alias for the doctor.
  Future<void> _aliasDoctor() async {
    await Posthog().alias(alias: 'doctor_alias_456');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Doctor alias created', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Reset the PostHog session.
  Future<void> _resetSession() async {
    await Posthog().reset();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session reset', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Toggle debug mode.
  Future<void> _toggleDebugMode() async {
    _debugEnabled = !_debugEnabled;
    await Posthog().debug(_debugEnabled);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Debug mode: ${_debugEnabled ? "ON" : "OFF"}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Record consultation start.
  void _recordConsultationStart() {
    _trackEvent('Consultation Started', {
      'doctorId': 'doctor-123',
      'timestamp': DateTime.now().toIso8601String(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation start recorded', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Record consultation end.
  void _recordConsultationEnd() {
    _trackEvent('Consultation Ended', {
      'doctorId': 'doctor-123',
      'timestamp': DateTime.now().toIso8601String(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation end recorded', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Helper function to build a consistent styled button.
  Widget _buildButton(String title, IconData icon, VoidCallback onPressed, {Color? backgroundColor}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.green,
        minimumSize: const Size(double.infinity, 50),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(title, style: const TextStyle(color: Colors.white)),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Doctor Analytics'),
          backgroundColor: Colors.green,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Analytics'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header: Doctor's information
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: const Text(
                  'Dr. John Doe',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                ),
                subtitle: const Text('Cardiology Specialist', style: TextStyle(color: Colors.green)),
              ),
            ),
            const SizedBox(height: 16),
            // Section: Patient Consultation Note
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Consultation Note',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Enter note here',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _trackEvent('Patient Note Changed', {'length': value.length});
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildButton('Save & Track Note', Icons.save, () {
                      _trackEvent('Patient Note Saved', {'note': _noteController.text});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Note saved & event tracked!', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Section: Consultation Actions
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consultation Actions',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildButton('Start Consultation', Icons.play_arrow, _recordConsultationStart),
                        _buildButton('End Consultation', Icons.stop, _recordConsultationEnd),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Section: System Controls & Tracking
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Controls & Tracking',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    _buildButton('Flush Events', Icons.brush, _flushEvents),
                    const SizedBox(height: 8),
                    _buildButton('Disable Capture', Icons.pause, _disableCapture),
                    const SizedBox(height: 8),
                    _buildButton('Enable Capture', Icons.play_arrow, _enableCapture),
                    const SizedBox(height: 8),
                    _buildButton('Get Distinct ID', Icons.fingerprint, _getDistinctId),
                    if (_distinctId.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Distinct ID: $_distinctId', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
                    const SizedBox(height: 8),
                    _buildButton('Check Feature Flag', Icons.flag, _checkFeatureFlag),
                    if (_featureFlagStatus.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Feature Flag: $_featureFlagStatus', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ),
                    const SizedBox(height: 8),
                    _buildButton('Assign Group', Icons.group, _assignGroup),
                    const SizedBox(height: 8),
                    _buildButton('Alias Doctor', Icons.alternate_email, _aliasDoctor),
                    const SizedBox(height: 8),
                    _buildButton('Reset Session', Icons.restart_alt, _resetSession),
                    const SizedBox(height: 8),
                    _buildButton('Toggle Debug Mode (${_debugEnabled ? "ON" : "OFF"})', Icons.bug_report, _toggleDebugMode),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Assuming Analytics is the current page.
        selectedItemColor: Colors.green,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/analytics');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
      ),
    );
  }
}
