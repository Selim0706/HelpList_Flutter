import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'main.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contacts.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE contacts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT NOT NULL,
            department TEXT NOT NULL,
            anydeskId TEXT NOT NULL,
            link TEXT NOT NULL,
            ipPhone TEXT,
            domainName TEXT,
            cardId TEXT,
            vnc TEXT,
            email TEXT,
            notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE departments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE connection_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            contactName TEXT NOT NULL,
            anydeskId TEXT NOT NULL,
            connectionTime TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
        // Добавим дефолтные значения
        await db.insert('departments', {'name': 'IT'});
        await db.insert('departments', {'name': 'HR'});
        await db.insert('departments', {'name': 'Finance'});
        await db.insert('departments', {'name': 'Marketing'});
        await db.insert('departments', {'name': 'Sales'});
        await db.insert('users', {'username': 'admin', 'password': 'admin', 'role': 'Администратор'});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Гарантируем, что таблица connection_logs будет создана при любом апгрейде
        await db.execute('''CREATE TABLE IF NOT EXISTS connection_logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contactName TEXT NOT NULL,
          anydeskId TEXT NOT NULL,
          connectionTime TEXT NOT NULL,
          status TEXT NOT NULL
        )''');
      },
    );
  }

  Future<List<Contact>> getContacts() async {
    final db = await database;
    final maps = await db.query('contacts');
    return maps.map((map) => Contact(
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
    )).toList();
  }

  Future<void> insertContact(Contact contact) async {
    final db = await database;
    await db.insert('contacts', {
      'fullName': contact.fullName,
      'department': contact.department,
      'anydeskId': contact.anydeskId,
      'link': contact.link,
      'ipPhone': contact.ipPhone,
      'domainName': contact.domainName,
      'cardId': contact.cardId,
      'vnc': contact.vnc,
      'email': contact.email,
      'notes': contact.notes,
    });
  }

  Future<void> updateContact(int id, Contact contact) async {
    final db = await database;
    await db.update(
      'contacts',
      {
        'fullName': contact.fullName,
        'department': contact.department,
        'anydeskId': contact.anydeskId,
        'link': contact.link,
        'ipPhone': contact.ipPhone,
        'domainName': contact.domainName,
        'cardId': contact.cardId,
        'vnc': contact.vnc,
        'email': contact.email,
        'notes': contact.notes,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearContacts() async {
    final db = await database;
    await db.delete('contacts');
  }

  // --- Departments ---
  Future<List<String>> getDepartments() async {
    final db = await database;
    final maps = await db.query('departments');
    return maps.map((map) => map['name'] as String).toList();
  }
  Future<void> addDepartment(String name) async {
    final db = await database;
    await db.insert('departments', {'name': name}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  Future<void> updateDepartment(int id, String newName) async {
    final db = await database;
    await db.update('departments', {'name': newName}, where: 'id = ?', whereArgs: [id]);
  }
  Future<void> deleteDepartment(int id) async {
    final db = await database;
    await db.delete('departments', where: 'id = ?', whereArgs: [id]);
  }
  Future<int?> getDepartmentIdByName(String name) async {
    final db = await database;
    final maps = await db.query('departments', where: 'name = ?', whereArgs: [name]);
    if (maps.isNotEmpty) return maps.first['id'] as int?;
    return null;
  }

  // --- Users ---
  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }
  Future<void> addUser(String username, String password, String role) async {
    final db = await database;
    await db.insert('users', {'username': username, 'password': password, 'role': role}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  Future<void> updateUser(int id, String username, String? password, String role) async {
    final db = await database;
    final data = {'username': username, 'role': role};
    if (password != null && password.isNotEmpty) {
      data['password'] = password;
    }
    await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Методы для работы с журналом подключений
  Future<int> addConnectionLog(String contactName, String anydeskId, DateTime connectionTime, String status) async {
    final db = await database;
    return await db.insert('connection_logs', {
      'contactName': contactName,
      'anydeskId': anydeskId,
      'connectionTime': connectionTime.toIso8601String(),
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> getConnectionLogs() async {
    final db = await database;
    return await db.query('connection_logs', orderBy: 'connectionTime DESC');
  }
} 