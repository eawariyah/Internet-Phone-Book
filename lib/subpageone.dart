import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Contact>> fetchContacts() async {
  final response = await http.get(Uri.parse(
      "https://apps.ashesi.edu.gh/contactmgt/actions/get_all_contact_mob")); // Replace with your actual endpoint

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List;
    return data.map((item) => Contact.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load contacts');
  }
}

class Contact {
  final String pid;
  final String pname;
  final String pphone;

  const Contact({
    required this.pid,
    required this.pname,
    required this.pphone,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        pid: json['pid'] as String,
        pname: json['pname'] as String,
        pphone: json['pphone'] as String,
      );
}

class SubPageOne extends StatefulWidget {
  const SubPageOne({super.key});

  @override
  State<SubPageOne> createState() => _SubPageOneState();
}

class _SubPageOneState extends State<SubPageOne> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contacts",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Contact>>(
        future: fetchContacts(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final contacts = snapshot.data!;
            return Column(
              children: [
                const Spacer(),
                SizedBox(
                  height: 610.0, // Adjust height as needed
                  child: ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blueGrey[700],
                              child: contact.pname.isNotEmpty
                                  ? Text(contact.pname[0].toUpperCase())
                                  : const Text(""),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.pname,
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    // 'pid: ${contact.pid}, phone: ${contact.pphone}',
                                    'phone: ${contact.pphone}',
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Spacer(),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: "View Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: "Manage Contacts",
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, "/second");
          }
        },
      ),
    );
  }
}
