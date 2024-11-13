import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _sampleHistory = [];

  @override
  void initState() {
    super.initState();
    _deleteOldRecords();  // Call to delete older records
    _loadHistory();
  }

  // Fetch the history from Firestore
  void _loadHistory() async {
    var collections = ['arrived_office', 'arrived_university', 'left_office', 'left_university'];
    List<Map<String, dynamic>> historyList = [];
    DateTime todayStart = DateTime.now().subtract(Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute, seconds: DateTime.now().second, microseconds: DateTime.now().microsecond));
    DateTime todayEnd = todayStart.add(Duration(days: 1));

    for (var collection in collections) {
      var snapshot = await _firestore.collection(collection)
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

  // Delete documents older than today
  void _deleteOldRecords() async {
    var collections = ['arrived_office', 'arrived_university', 'left_office', 'left_university'];
    DateTime todayStart = DateTime.now().subtract(Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute, seconds: DateTime.now().second, microseconds: DateTime.now().microsecond));

    for (var collection in collections) {
      var snapshot = await _firestore.collection(collection)
          .where('created_at', isLessThan: Timestamp.fromDate(todayStart))
          .get();

      // Delete all documents older than today
      for (var doc in snapshot.docs) {
        await _firestore.collection(collection).doc(doc.id).delete();
      }
    }
  }
  // Delete history item from Firestore
  void _deleteHistoryItem(String documentId, String collection) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
      _loadHistory();
      _showSnackbar(context, 'Record deleted successfully!');
    } catch (e) {
      print("Error deleting document: $e");
      _showSnackbar(context, 'Error deleting record.');
    }
  }

  // Send data to Firestore after checking for today's record
  void _sendDataToFirestore(String event, String collection) async {
    var now = DateTime.now();
    var formattedDate = DateFormat('yyyy-MM-dd').format(now);

    var snapshot = await _firestore.collection(collection)
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(now.subtract(Duration(hours: 24))))
        .where('created_at', isLessThan: Timestamp.fromDate(now))
        .get();

    if (snapshot.docs.isNotEmpty) {
      var documentId = snapshot.docs.first.id;
      _showDeleteOrUpdateDialog(event, collection, documentId);
    } else {
      _addEventToFirestore(event, collection);
    }
  }

  void _addEventToFirestore(String event, String collection) async {
    try {
      var now = Timestamp.now();
      await _firestore.collection(collection).add({
        'event': event,
        'created_at': now,
      });
      _loadHistory();
      _showSnackbar(context, 'Event added successfully!');
    } catch (e) {
      print("Error adding document: $e");
      _showSnackbar(context, 'Error adding event to Firestore.');
    }
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
                // Greeting Section with more vibrant colors and design
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
                          '${_getGreeting()}, Sabeer!',
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
                // Action Buttons with icons and improved design
                Column(
                  children: [
                    _buildActionButton(
                      context,
                      label: 'Arrived University',
                      icon: Icons.school,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade500, Colors.blue.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        _sendDataToFirestore('Arrived University', 'arrived_university');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      context,
                      label: 'Left University',
                      icon: Icons.exit_to_app,
                      gradient: LinearGradient(
                        colors: [Colors.red.shade500, Colors.red.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        _sendDataToFirestore('Left University', 'left_university');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      context,
                      label: 'Arrived Office',
                      icon: Icons.work,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade500, Colors.green.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        _sendDataToFirestore('Arrived Office', 'arrived_office');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildActionButton(
                      context,
                      label: 'Left Office',
                      icon: Icons.logout,
                      gradient: LinearGradient(
                        colors: [Colors.orange.shade500, Colors.orange.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        _sendDataToFirestore('Left Office', 'left_office');
                      },
                    ),
                  ],
                ),


                const SizedBox(height: 30),
                // History Section with icons and color-coded events
                const Divider(thickness: 2),
                const SizedBox(height: 10),
                const Text(
                  'Timeline:',
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
                        leading: Icon(_getEventIcon(item['event']), color: Colors.teal),
                        title: Text(item['event'] ?? 'No Event'),
                        subtitle: Text(item['time'] ?? 'No Time'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteHistoryItem(item['document_id']!, item['collection']);
                          },
                        ),
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

  // Action Button widget with icon
  Widget _buildActionButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Gradient gradient,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }


  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDeleteOrUpdateDialog(String event, String collection, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate Record'),
          content: Text('You already have a record for "$event". Do you want to delete the previous one or keep both?'),
          actions: [
            TextButton(
              onPressed: () {
                _deleteHistoryItem(documentId, collection);
                _addEventToFirestore(event, collection);
                Navigator.pop(context);
              },
              child: Text('Delete and Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Keep Both'),
            ),
          ],
        );
      },
    );
  }
}
