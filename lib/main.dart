import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String _baseURL = '1mohamad.atwebpages.com';


class Student {
  final int _id;
  final String _name;
  final String _present;

  Student(this._id, this._name, this._present);

  @override
  String toString() {
    return 'ID: $_id\nName: $_name\nPresent: $_present';
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _load = false;
  String _text = '';
  final TextEditingController _controllerSearch = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPresent = TextEditingController();


  void update(String text) {
    setState(() {
      _text = text;
    });
  }

  void addStudent() async {
    if (_controllerName.text.isEmpty || _controllerPresent.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      final response = await http.post(
        Uri.http(_baseURL, 'add.php'),
        body: {
          'name': _controllerName.text,
          'present': _controllerPresent.text,
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        setState(() {
          _text = 'Student Added Successfully';
        });
      } else {
        setState(() {
          _text = 'Failed to Add Student';
        });
      }
    } catch (e) {
      setState(() {
        _text = 'Error: $e';
      });
    }
  }

  void searchStudent(String searchBy, String value) async {
    try {
      final queryParams = {
        searchBy: value,
      };
      final url = Uri.http(_baseURL, 'show.php', queryParams);
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse.isNotEmpty) {
          var row = jsonResponse[0];
          Student s = Student(
            int.parse(row['id']),
            row['name'],
            row['present'],
          );
          setState(() {
            _text = s.toString();
          });
        } else {
          setState(() {
            _text = 'No student found matching your criteria.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _text = "Can't load data";
      });
    }
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    _controllerName.dispose();
    _controllerPresent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Attendance Tracker'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _load = false;

              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _controllerName,
              decoration: const InputDecoration(
                labelText: 'Enter Student Name',
                border: OutlineInputBorder(),
                hintText: 'John Doe',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controllerPresent,
              decoration: const InputDecoration(
                labelText: 'Enter Present Status (Yes/No)',
                border: OutlineInputBorder(),
                hintText: 'Yes',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addStudent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Colors.green,
              ),
              child: const Text('Add Student'),
            ),
            const SizedBox(height: 40),

            const Text('Search Students by:'),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: 'id',
                    items: const [
                      DropdownMenuItem(value: 'id', child: Text('Search by ID')),
                      DropdownMenuItem(value: 'name', child: Text('Search by Name')),
                      DropdownMenuItem(value: 'present', child: Text('Search by Present')),
                    ],
                    onChanged: (value) {
                      setState(() {
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controllerSearch,
                    decoration: const InputDecoration(
                      labelText: 'Enter Search Value',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    searchStudent('id', _controllerSearch.text);
                  },
                  child: const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 40),

            Text(
              _text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _load
                ? const CircularProgressIndicator()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Tracker',
      home: Home(),
    );
  }
}
