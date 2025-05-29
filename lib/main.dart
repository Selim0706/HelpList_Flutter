import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'db_service.dart';
import 'dart:io' as io;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (io.Platform.isMacOS || io.Platform.isWindows || io.Platform.isLinux) {
    setWindowMinSize(const Size(900, 600));
    setWindowMaxSize(const Size(1920, 1200));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Help List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    setState(() {
      _isLoading = true;
    });

    // Имитация задержки сети
    Future.delayed(const Duration(seconds: 1), () {
      if (_usernameController.text == 'admin' && 
          _passwordController.text == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Неверное имя пользователя или пароль')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', height: 64),
                const SizedBox(height: 16),
                const Text(
                  'Вход в систему',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Имя пользователя',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Войти'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ContactsPage(),
    const ConnectionLogPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('Help List'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главное меню',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Контакты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Журнал подключений',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.png', height: 96),
          const SizedBox(height: 24),
          const Text(
            'Главное меню',
            style: TextStyle(fontSize: 24),
            ),
          ],
        ),
    );
  }
}

class Contact {
  final int? id;
  final String fullName;
  final String department;
  final String anydeskId;
  final String link;
  final String ipPhone;
  final String domainName;
  final String cardId;
  final String vnc;
  final String email;
  final String notes;

  static const List<Map<String, String>> fields = [
    {'key': 'fullName', 'label': 'Имя и Фамилия'},
    {'key': 'department', 'label': 'Отдел'},
    {'key': 'anydeskId', 'label': 'Anydesk ID'},
    {'key': 'ipPhone', 'label': 'IP телефон'},
    {'key': 'domainName', 'label': 'Domain name'},
    {'key': 'cardId', 'label': 'Card ID'},
    {'key': 'vnc', 'label': 'VNC'},
    {'key': 'email', 'label': 'Email'},
    {'key': 'notes', 'label': 'Заметки'},
  ];

  Contact({
    this.id,
    required this.fullName,
    required this.department,
    required this.anydeskId,
    required this.link,
    required this.ipPhone,
    required this.domainName,
    required this.cardId,
    required this.vnc,
    required this.email,
    required this.notes,
  });

  factory Contact.fromMap(Map<String, dynamic> map) => Contact(
    id: map['id'] as int?,
    fullName: map['fullName'] as String,
    department: map['department'] as String,
    anydeskId: map['anydeskId'] as String,
    link: map['link'] as String,
    ipPhone: map['ipPhone'] as String,
    domainName: map['domainName'] as String,
    cardId: map['cardId'] as String,
    vnc: map['vnc'] as String,
    email: map['email'] as String,
    notes: map['notes'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'department': department,
    'anydeskId': anydeskId,
    'link': link,
    'ipPhone': ipPhone,
    'domainName': domainName,
    'cardId': cardId,
    'vnc': vnc,
    'email': email,
    'notes': notes,
  };
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = 'Все';
  List<String> _departments = ['Все'];
  bool _isLoading = true;

  // Контроллеры для формы редактирования
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _anydeskIdController = TextEditingController();
  final TextEditingController _ipPhoneController = TextEditingController();
  final TextEditingController _domainNameController = TextEditingController();
  final TextEditingController _cardIdController = TextEditingController();
  final TextEditingController _vncController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedDepartmentEdit = 'IT';

  List<Contact> _contacts = [];
  bool _isLoadingContacts = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { 
      _isLoading = true;
      _isLoadingContacts = true;
    });
    
    final db = await DBService().database;
    
    // Загружаем отделы
    final deptMaps = await db.query('departments');
    setState(() {
      _departments = ['Все', ...deptMaps.map((map) => map['name'] as String).toList()];
      _isLoading = false;
    });
    
    // Загружаем контакты
    final contactMaps = await db.query('contacts');
    setState(() {
      _contacts = contactMaps.map((map) => Contact.fromMap(map)).toList();
      _isLoadingContacts = false;
    });
  }

  Future<void> _addContact(Contact contact) async {
    await DBService().insertContact(contact);
    await _loadData();
  }

  Future<void> _updateContact(Contact contact) async {
    if (contact.id == null) return;
    await DBService().updateContact(contact.id!, contact);
    await _loadData();
  }

  Future<void> _deleteContact(Contact contact) async {
    if (contact.id == null) return;
    await DBService().deleteContact(contact.id!);
    await _loadData();
  }

  List<Contact> get _filteredContacts {
    return _contacts.where((contact) {
      final searchLower = _searchController.text.toLowerCase();
      final matchesSearch = contact.fullName.toLowerCase().contains(searchLower) ||
          contact.department.toLowerCase().contains(searchLower) ||
          contact.anydeskId.contains(searchLower) ||
          contact.email.toLowerCase().contains(searchLower);
      
      final matchesDepartment = _selectedDepartment == 'Все' || 
          contact.department == _selectedDepartment;

      return matchesSearch && matchesDepartment;
    }).toList();
  }

  void _connectToAnyDesk(String anydeskId, String contactName) async {
    final Uri url = Uri.parse('anydesk:$anydeskId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      // Добавляем запись в журнал при успешном подключении
      if (context.mounted) {
        final connectionLogPage = context.findAncestorStateOfType<_ConnectionLogPageState>();
        connectionLogPage?.addConnectionLog(contactName, anydeskId, 'success');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть AnyDesk')),
        );
        // Добавляем запись в журнал при неудачном подключении
        final connectionLogPage = context.findAncestorStateOfType<_ConnectionLogPageState>();
        connectionLogPage?.addConnectionLog(contactName, anydeskId, 'failed');
      }
    }
  }

  void _showEditContactDialog(Contact contact) {
    // Заполняем контроллеры текущими данными
    _nameController.text = contact.fullName;
    _anydeskIdController.text = contact.anydeskId;
    _ipPhoneController.text = contact.ipPhone;
    _domainNameController.text = contact.domainName;
    _cardIdController.text = contact.cardId;
    _vncController.text = contact.vnc;
    _emailController.text = contact.email;
    _notesController.text = contact.notes;
    _selectedDepartmentEdit = contact.department;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать контакт'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
        child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Имя и Фамилия'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDepartmentEdit,
                  decoration: const InputDecoration(labelText: 'Отдел'),
                  items: _departments
                      .where((dept) => dept != 'Все')
                      .map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDepartmentEdit = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _anydeskIdController,
                  decoration: const InputDecoration(labelText: 'Anydesk ID'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ipPhoneController,
                  decoration: const InputDecoration(labelText: 'IP телефон'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _domainNameController,
                  decoration: const InputDecoration(labelText: 'Domain name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardIdController,
                  decoration: const InputDecoration(labelText: 'Card ID'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _vncController,
                  decoration: const InputDecoration(labelText: 'VNC'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Заметки'),
                  maxLines: 3,
            ),
          ],
        ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty && 
                  _anydeskIdController.text.isNotEmpty &&
                  _selectedDepartmentEdit.isNotEmpty) {
                final updatedContact = Contact(
                  id: contact.id,
                  fullName: _nameController.text,
                  department: _selectedDepartmentEdit,
                  anydeskId: _anydeskIdController.text,
                  link: 'https://anydesk.com/${_anydeskIdController.text}',
                  ipPhone: _ipPhoneController.text,
                  domainName: _domainNameController.text,
                  cardId: _cardIdController.text,
                  vnc: _vncController.text,
                  email: _emailController.text,
                  notes: _notesController.text,
                );
                await _updateContact(updatedContact);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Контакт успешно обновлен')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Имя, Anydesk ID и отдел обязательны для заполнения')),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить контакт'),
        content: Text('Вы уверены, что хотите удалить контакт ${contact.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _deleteContact(contact);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Контакт успешно удален')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog() {
    // Очищаем контроллеры
    _nameController.clear();
    _anydeskIdController.clear();
    _ipPhoneController.clear();
    _domainNameController.clear();
    _cardIdController.clear();
    _vncController.clear();
    _emailController.clear();
    _notesController.clear();
    _selectedDepartmentEdit = _departments.length > 1 ? _departments[1] : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить контакт'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Имя и Фамилия'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedDepartmentEdit,
                  decoration: const InputDecoration(labelText: 'Отдел'),
                  items: _departments
                      .where((dept) => dept != 'Все')
                      .map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDepartmentEdit = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _anydeskIdController,
                  decoration: const InputDecoration(labelText: 'Anydesk ID'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _ipPhoneController,
                  decoration: const InputDecoration(labelText: 'IP телефон'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _domainNameController,
                  decoration: const InputDecoration(labelText: 'Domain name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardIdController,
                  decoration: const InputDecoration(labelText: 'Card ID'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _vncController,
                  decoration: const InputDecoration(labelText: 'VNC'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Заметки'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty && 
                  _anydeskIdController.text.isNotEmpty &&
                  _selectedDepartmentEdit.isNotEmpty) {
                final newContact = Contact(
                  id: null,
                  fullName: _nameController.text,
                  department: _selectedDepartmentEdit,
                  anydeskId: _anydeskIdController.text,
                  link: 'https://anydesk.com/${_anydeskIdController.text}',
                  ipPhone: _ipPhoneController.text,
                  domainName: _domainNameController.text,
                  cardId: _cardIdController.text,
                  vnc: _vncController.text,
                  email: _emailController.text,
                  notes: _notesController.text,
                );
                await _addContact(newContact);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Контакт успешно добавлен')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Имя, Anydesk ID и отдел обязательны для заполнения')),
                );
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isLoadingContacts) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Поиск',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedDepartment,
                  items: _departments
                      .map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 900),
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Имя и Фамилия')),
                      DataColumn(label: Text('Отдел')),
                      DataColumn(label: Text('Anydesk ID')),
                      DataColumn(label: Text('Ссылка')),
                      DataColumn(label: Text('IP телефон')),
                      DataColumn(label: Text('Domain name')),
                      DataColumn(label: Text('Card ID')),
                      DataColumn(label: Text('VNC')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Заметки')),
                      DataColumn(label: Text('Действия')),
                    ],
                    rows: _filteredContacts.map((contact) {
                      return DataRow(
                        cells: [
                          DataCell(Text(contact.fullName)),
                          DataCell(Text(contact.department)),
                          DataCell(Text(contact.anydeskId)),
                          DataCell(
                            InkWell(
                              onTap: () => _connectToAnyDesk(contact.anydeskId, contact.fullName),
                              child: Text(
                                contact.link,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(contact.ipPhone)),
                          DataCell(Text(contact.domainName)),
                          DataCell(Text(contact.cardId)),
                          DataCell(Text(contact.vnc)),
                          DataCell(Text(contact.email)),
                          DataCell(Text(contact.notes)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditContactDialog(contact),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _showDeleteConfirmation(contact),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.link),
                                  onPressed: () => _connectToAnyDesk(contact.anydeskId, contact.fullName),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _anydeskIdController.dispose();
    _ipPhoneController.dispose();
    _domainNameController.dispose();
    _cardIdController.dispose();
    _vncController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class ConnectionLog {
  final String contactName;
  final String anydeskId;
  final DateTime connectionTime;
  final String status; // 'success' или 'failed'

  ConnectionLog({
    required this.contactName,
    required this.anydeskId,
    required this.connectionTime,
    required this.status,
  });
}

class ConnectionLogPage extends StatefulWidget {
  const ConnectionLogPage({super.key});

  @override
  State<ConnectionLogPage> createState() => _ConnectionLogPageState();
}

class _ConnectionLogPageState extends State<ConnectionLogPage> {
  List<ConnectionLog> _connectionLogs = [];
  final _dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');
  final _searchController = TextEditingController();
  String _selectedStatus = 'Все';
  bool _isLoading = true;

  List<ConnectionLog> get _filteredLogs {
    return _connectionLogs.where((log) {
      final searchLower = _searchController.text.toLowerCase();
      final matchesSearch = log.contactName.toLowerCase().contains(searchLower) ||
          log.anydeskId.contains(searchLower);
      
      final matchesStatus = _selectedStatus == 'Все' || 
          log.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadLogs() async {
    setState(() { _isLoading = true; });
    final maps = await DBService().getConnectionLogs();
    setState(() {
      _connectionLogs = maps.map((map) => ConnectionLog(
        contactName: map['contactName'],
        anydeskId: map['anydeskId'],
        connectionTime: DateTime.parse(map['connectionTime']),
        status: map['status'],
      )).toList();
      _isLoading = false;
    });
  }

  Future<void> addConnectionLog(String contactName, String anydeskId, String status) async {
    await DBService().addConnectionLog(contactName, anydeskId, DateTime.now(), status);
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Поиск по имени или ID',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'Все', child: Text('Все')),
                    DropdownMenuItem(value: 'success', child: Text('Успешные')),
                    DropdownMenuItem(value: 'failed', child: Text('Неудачные')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLogs.length,
              itemBuilder: (context, index) {
                final log = _filteredLogs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      log.status == 'success' ? Icons.check_circle : Icons.error,
                      color: log.status == 'success' ? Colors.green : Colors.red,
                    ),
                    title: Text(log.contactName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Anydesk ID: ${log.anydeskId}'),
                        Text('Время: ${_dateFormat.format(log.connectionTime)}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () {
                        _connectToAnyDesk(log.anydeskId, log.contactName);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _connectToAnyDesk(String anydeskId, String contactName) async {
    final Uri url = Uri.parse('anydesk:$anydeskId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
      if (context.mounted) {
        await addConnectionLog(contactName, anydeskId, 'success');
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось открыть AnyDesk')),
        );
        await addConnectionLog(contactName, anydeskId, 'failed');
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    final db = await DBService().database;
    final deptMaps = await db.query('departments');
    final userMaps = await db.query('users');
    setState(() {
      _departments = deptMaps;
      _users = userMaps;
      _isLoading = false;
    });
  }

  Future<void> _addDepartment(String name) async {
    await DBService().addDepartment(name);
    await _loadData();
  }
  Future<void> _editDepartment(int id, String newName) async {
    await DBService().updateDepartment(id, newName);
    await _loadData();
  }
  Future<void> _deleteDepartment(int id) async {
    await DBService().deleteDepartment(id);
    await _loadData();
  }

  Future<void> _addUser(String username, String password, String role) async {
    await DBService().addUser(username, password, role);
    await _loadData();
  }
  Future<void> _editUser(int id, String username, String? password, String role) async {
    await DBService().updateUser(id, username, password, role);
    await _loadData();
  }
  Future<void> _deleteUser(int id) async {
    await DBService().deleteUser(id);
    await _loadData();
  }

  Future<void> _importContacts() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes != null) {
          final csvString = String.fromCharCodes(bytes);
          final rows = const CsvToListConverter().convert(csvString);
          
          // Пропускаем заголовок
          for (var i = 1; i < rows.length; i++) {
            final row = rows[i];
            if (row.length >= 9) {
              final contact = Contact(
                fullName: row[0].toString(),
                department: row[1].toString(),
                anydeskId: row[2].toString(),
                link: 'https://anydesk.com/${row[2].toString()}',
                ipPhone: row[3].toString(),
                domainName: row[4].toString(),
                cardId: row[5].toString(),
                vnc: row[6].toString(),
                email: row[7].toString(),
                notes: row[8].toString(),
              );
              await DBService().insertContact(contact);
            }
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Контакты успешно импортированы')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при импорте: $e')),
        );
      }
    }
  }

  Future<void> _exportContacts() async {
    try {
      final db = await DBService().database;
      final contacts = await db.query('contacts');
      
      List<List<dynamic>> rows = [];
      // Добавляем заголовки
      rows.add([
        'Имя и Фамилия',
        'Отдел',
        'Anydesk ID',
        'IP телефон',
        'Domain name',
        'Card ID',
        'VNC',
        'Email',
        'Заметки'
      ]);
      
      // Добавляем данные
      for (var contact in contacts) {
        rows.add([
          contact['fullName'],
          contact['department'],
          contact['anydeskId'],
          contact['ipPhone'],
          contact['domainName'],
          contact['cardId'],
          contact['vnc'],
          contact['email'],
          contact['notes'],
        ]);
      }
      
      String csv = const ListToCsvConverter().convert(rows);
      
      // Получаем директорию для сохранения
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/contacts_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Файл сохранен: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при экспорте: $e')),
        );
      }
    }
  }

  void _showAddDepartmentDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить отдел'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Название отдела',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _addDepartment(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showEditDepartmentDialog(int index) {
    final controller = TextEditingController(text: _departments[index]['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать отдел'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Название отдела',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _editDepartment(_departments[index]['id'] as int, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'Пользователь';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить пользователя'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Имя пользователя',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Роль',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Администратор', child: Text('Администратор')),
                  DropdownMenuItem(value: 'Пользователь', child: Text('Пользователь')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (usernameController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                await _addUser(usernameController.text, passwordController.text, selectedRole);
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(int index) {
    final usernameController = TextEditingController(text: _users[index]['username']);
    final passwordController = TextEditingController();
    String selectedRole = _users[index]['role'] ?? 'Пользователь';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать пользователя'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Имя пользователя',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Новый пароль (необязательно)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Роль',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Администратор', child: Text('Администратор')),
                  DropdownMenuItem(value: 'Пользователь', child: Text('Пользователь')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _editUser(
                _users[index]['id'] as int,
                usernameController.text,
                passwordController.text.isNotEmpty ? passwordController.text : null,
                selectedRole,
              );
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('О приложении'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Help List',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset('assets/logo.png', height: 64),
                children: const [
                  Text('Приложение для управления контактами и подключениями через AnyDesk.'),
                ],
              );
            },
          ),
          const Divider(),
          ExpansionTile(
            title: const Text('Управление отделами'),
            leading: const Icon(Icons.business),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _departments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_departments[index]['name'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditDepartmentDialog(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _deleteDepartment(_departments[index]['id'] as int);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Добавить отдел'),
                onTap: _showAddDepartmentDialog,
              ),
            ],
          ),
          const Divider(),
          ExpansionTile(
            title: const Text('Управление пользователями'),
            leading: const Icon(Icons.people),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    title: Text(user['username'] ?? ''),
                    subtitle: Text(user['role'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditUserDialog(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await _deleteUser(user['id'] as int);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Добавить пользователя'),
                onTap: _showAddUserDialog,
              ),
            ],
          ),
          const Divider(),
          ExpansionTile(
            title: const Text('Импорт/Экспорт контактов'),
            leading: const Icon(Icons.import_export),
            children: [
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Импорт контактов'),
                subtitle: const Text('Импорт из CSV с сопоставлением полей'),
                onTap: _importContacts,
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Экспорт контактов'),
                subtitle: const Text('Экспорт в CSV формат'),
                onTap: _exportContacts,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<TodoItem> _todos = [];
  final _textController = TextEditingController();

  void _addTodo(String title) {
    if (title.isEmpty) return;
    setState(() {
      _todos.add(TodoItem(title: title));
      _textController.clear();
    });
  }

  void _toggleTodo(int index) {
    setState(() {
      _todos[index].isCompleted = !_todos[index].isCompleted;
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список задач'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Добавить новую задачу',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _addTodo(_textController.text),
                  child: const Text('Добавить'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return ListTile(
                  leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) => _toggleTodo(index),
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTodo(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class TodoItem {
  String title;
  bool isCompleted;

  TodoItem({
    required this.title,
    this.isCompleted = false,
  });
}
