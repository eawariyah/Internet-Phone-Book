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

Future<Contact> fetchContactById(String id) async {
  final response = await http.get(Uri.parse(
      "https://apps.ashesi.edu.gh/contactmgt/actions/get_a_contact_mob?contid=$id")); // Replace with your actual endpoint

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Contact.fromJson(data);
  } else {
    throw Exception('Failed to load contact');
  }
}

Future<bool> deleteContact(String id) async {
  final response = await http.post(
    Uri.parse("https://apps.ashesi.edu.gh/contactmgt/actions/delete_contact"),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {"cid": id},
  );

  if (response.statusCode == 200) {
    try {
      if (response.body.isEmpty) {
        return true;
      }
      return jsonDecode(response.body) == true;
    } catch (e) {
      return false;
    }
  } else {
    return false;
  }
}

Future<String> addContact(String fullname, String phone) async {
  final response = await http.post(
    Uri.parse("https://apps.ashesi.edu.gh/contactmgt/actions/add_contact"),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {"ufullname": fullname, "uphonename": phone},
  );

  if (response.statusCode == 200) {
    return 'success';
  } else {
    return 'failed';
  }
}

Future<String> updateContact(String id, String name, String phone) async {
  final response = await http.post(
    Uri.parse("https://apps.ashesi.edu.gh/contactmgt/actions/update_contact"),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {"cid": id, "cname": name, "cnum": phone},
  );

  if (response.statusCode == 200) {
    return response.body == 'success' ? 'success' : 'failed';
  } else {
    return 'failed';
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

class SubPageTwo extends StatefulWidget {
  const SubPageTwo({super.key});

  @override
  State<SubPageTwo> createState() => _SubPageTwoState();
}

class _SubPageTwoState extends State<SubPageTwo> {
  final _contactIdController = TextEditingController();
  Contact? _selectedContact;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showAddContactDialog(BuildContext context) async {
    final mainformKey = GlobalKey<FormState>();
    final TextEditingController mainnameController = TextEditingController();
    final TextEditingController mainphoneController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Contact'),
          content: Form(
            key: mainformKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: mainnameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: mainphoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (mainformKey.currentState!.validate()) {
                  final result = await addContact(
                    mainnameController.text,
                    mainphoneController.text,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Add contact $result')),
                  );
                  setState(() {}); // Refresh the list of contacts
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUpdateContactDialog(BuildContext context, String id) async {
    final mainformKey = GlobalKey<FormState>();
    final TextEditingController mainnameController = TextEditingController();
    final TextEditingController mainphoneController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Contact'),
          content: Form(
            key: mainformKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: mainnameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: mainphoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                if (mainformKey.currentState!.validate()) {
                  final result = await updateContact(
                    id,
                    mainnameController.text,
                    mainphoneController.text,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Update contact $result')),
                  );
                  setState(() {}); // Refresh the list of contacts
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFetchContactDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fetch Contact by ID'),
          content: TextFormField(
            controller: _contactIdController,
            decoration: const InputDecoration(labelText: 'Contact ID'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Fetch'),
              onPressed: () async {
                final id = _contactIdController.text;
                if (id.isNotEmpty) {
                  try {
                    final contact = await fetchContactById(id);
                    setState(() {
                      _selectedContact = contact;
                    });
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to fetch contact: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteContactDialog(BuildContext context, String id) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Contact'),
          content: const Text('Are you sure you want to delete this contact?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                final result = await deleteContact(id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Delete contact ${result ? 'success' : 'failed'}')),
                );
                setState(() {}); // Refresh the list of contacts
              },
            ),
          ],
        );
      },
    );
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
      body: Column(
        children: [
          FutureBuilder<List<Contact>>(
            future: fetchContacts(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final contacts = snapshot.data!;
                return Expanded(
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
                                    'phone: ${contact.pphone}',
                                    style: const TextStyle(fontSize: 12.0),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showUpdateContactDialog(
                                  context, contact.pid),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteContactDialog(
                                  context, contact.pid),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
          if (_selectedContact != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected Contact",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text('ID: ${_selectedContact!.pid}'),
                  Text('Name: ${_selectedContact!.pname}'),
                  Text('Phone: ${_selectedContact!.pphone}'),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showAddContactDialog(context),
            tooltip: 'Add Contact',
            heroTag: 'addContact',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: () => _showFetchContactDialog(context),
            tooltip: 'Fetch Contact by ID',
            heroTag: 'fetchContact',
            child: const Icon(Icons.search),
          ),
        ],
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
          if (index == 0) {
            Navigator.pushNamed(context, "/");
          }
        },
      ),
    );
  }
}
