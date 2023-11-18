import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


void main() {
  runApp(MyApp());
}

class Contact {
  int? id;
  String name;
  String phoneNumber;
  String email;

  Contact({this.id, required this.name, required this.phoneNumber, required this.email});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  static Contact fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda de Contatos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      body: Center(
        child:Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
            Image.asset('assets/foto.png', width: 150,height: 150,),
            SizedBox(height: 20), ElevatedButton( onPressed: () {Navigator.push(context, MaterialPageRoute(builder:(context) => ContactsScreen() ),);}, child: Text('contatos novos'),),
            ],) 
        
      ),
    );
  }
}

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late Database _database;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _getContacts();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'contacts_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE contacts(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, phoneNumber TEXT, email TEXT)",
        );
      },
      version: 1,
    );
  }
 
  Future<void> _getContacts() async {
    final List<Map<String, dynamic>> maps = await _database.query('contacts');
    contacts = List.generate(maps.length, (index) {
      return Contact.fromMap(maps[index]);
    });
    setState(() {});
  }

  Future<void> _insertContact(Contact contact) async {
    await _database.insert('contacts', contact.toMap());
  }

  Future<void> _deleteContact(int id) async {
    await _database.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contatos'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(contacts[index].name),
            subtitle: Text(contacts[index].phoneNumber),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailsScreen(contacts[index]),
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteContact(contacts[index].id!);
                setState(() {
                  contacts.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddContactScreen()),
          ).then((newContact) {
            if (newContact != null) {
              _insertContact(newContact);
              setState(() {
                contacts.add(newContact);
              });
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddContactScreen extends StatefulWidget {
  @override
  _AddContactScreenState createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final nameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Contato'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Telefone'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'E-mail'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = nameController.text;
                String phoneNumber = phoneNumberController.text;
                String email = emailController.text;

                if (name.isNotEmpty && phoneNumber.isNotEmpty && email.isNotEmpty) {
                  Contact newContact = Contact(
                    name: name,
                    phoneNumber: phoneNumber,
                    email: email,
                  );
                  Navigator.pop(context, newContact);
                }
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactDetailsScreen extends StatelessWidget {
  final Contact contact;

  ContactDetailsScreen(this.contact);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Contato'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Nome: ${contact.name}'),
            Text('Telefone: ${contact.phoneNumber}'),
            Text('E-mail: ${contact.email}'),
          ],
        ),
      ),
    );
  }
}
