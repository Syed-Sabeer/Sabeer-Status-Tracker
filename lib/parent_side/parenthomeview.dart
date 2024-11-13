import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParentHomeView extends StatefulWidget {
  const ParentHomeView({super.key});

  @override
  _ParentHomeViewState createState() => _ParentHomeViewState();
}

class _ParentHomeViewState extends State<ParentHomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _sampleHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // Fetch the history from Firestore
  void _loadHistory() async {
    var collections = [
      'arrived_office',
      'arrived_university',
      'left_office',
      'left_university'
    ];
    List<Map<String, dynamic>> historyList = [];
    DateTime todayStart = DateTime.now().subtract(
      Duration(
        hours: DateTime.now().hour,
        minutes: DateTime.now().minute,
        seconds: DateTime.now().second,
        microseconds: DateTime.now().microsecond,
      ),
    );
    DateTime todayEnd = todayStart.add(Duration(days: 1));

    for (var collection in collections) {
      var snapshot = await _firestore
          .collection(collection)
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('created_at', isLessThan: Timestamp.fromDate(todayEnd))
          .get();

      for (var doc in snapshot.docs) {
        var createdAt = (doc['created_at'] as Timestamp).toDate();
        var event = doc.data().containsKey('event') ? doc['event'] : 'N/A';

        historyList.add({
          'event': event,
          'time': DateFormat('h:mm a').format(createdAt),
          'document_id': doc.id,
          'collection': collection,
        });
      }
    }

    setState(() {
      _sampleHistory = historyList;
    });
  }

  // Greeting function based on time
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour > 7 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  // Build the status button
  Widget _buildStatusButton() {
    String status = _getCurrentStatus();

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Current Status:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                status,
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get the current status based on the most recent timeline event
  String _getCurrentStatus() {
    if (_sampleHistory.isEmpty) {
      return "No status available";
    }

    // Find the most recent event
    _sampleHistory.sort((a, b) {
      DateTime timeA = DateFormat('h:mm a').parse(a['time']);
      DateTime timeB = DateFormat('h:mm a').parse(b['time']);
      return timeB.compareTo(timeA); // Sort by descending time
    });

    String latestEvent = _sampleHistory.first['event'];

    switch (latestEvent) {
      case 'Arrived Office':
        return "In the Office";
      case 'Left Office':
        return "On the way to Home";
      case 'Arrived University':
        return "In the University";
      case 'Left University':
        return "On the way to the Office";
      default:
        return "No status available";
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
    final formattedTime = DateFormat('h:mm a').format(now);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text(
              'Welcome',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Greeting Section
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          '${_getGreeting()}, Faisal!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$formattedDate\n$formattedTime',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Current Status Section
                _buildStatusButton(),

                const SizedBox(height: 30),

                // History Section
                const Divider(thickness: 2),
                const SizedBox(height: 10),
                const Text(
                  "Sabeer's Timeline:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _sampleHistory.isEmpty
                    ? const Center(child: Text("No timeline found for today"))
                    : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _sampleHistory.length,
                  itemBuilder: (context, index) {
                    var item = _sampleHistory[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(_getEventIcon(item['event']),
                            color: Colors.teal),
                        title: Text(item['event'] ?? 'No Event'),
                        subtitle: Text(item['time'] ?? 'No Time'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to get the appropriate icon based on event
  IconData _getEventIcon(String event) {
    switch (event) {
      case 'Arrived University':
        return Icons.school;
      case 'Left University':
        return Icons.exit_to_app;
      case 'Arrived Office':
        return Icons.work;
      case 'Left Office':
        return Icons.exit_to_app;
      default:
        return Icons.help_outline;
    }
  }
}
