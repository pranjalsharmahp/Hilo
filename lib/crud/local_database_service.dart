import 'dart:io';
import 'package:hilo/features/chat/chat_service.dart';
import 'package:hilo/features/inbox/inbox_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance =
      LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  static Database? _db;

  LocalDatabaseService._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "local_chat.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        name TEXT,
        profile_url TEXT,
        bio TEXT,
        updated_at TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user1_email TEXT NOT NULL,
        user2_email TEXT NOT NULL,
        last_message TEXT,
        last_sender_email TEXT,
        last_updated TEXT,
        UNIQUE(user1_email, user2_email)
      )
    ''');
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_email TEXT NOT NULL,
        receiver_email TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT DEFAULT 'TEXT',
        isSeen INTEGER NOT NULL DEFAULT 0,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'name ASC');
  }

  Future<int> upsertConversation(Map<String, dynamic> convo) async {
    final db = await database;
    // Try update first
    int count = await db.update(
      'conversations',
      convo,
      where: 'user1_email = ? AND user2_email = ?',
      whereArgs: [convo['user1_email'], convo['user2_email']],
    );
    if (count == 0) {
      return await db.insert('conversations', convo);
    }
    return count;
  }

  Future<List<Map<String, dynamic>>> getConversations(String email) async {
    final db = await database;
    const sql = '''
    SELECT *,
      CASE WHEN user1_email = ? THEN user2_email ELSE user1_email END AS other_user_email
    FROM conversations
    WHERE user1_email = ? OR user2_email = ?
    ORDER BY last_updated DESC
  ''';

    // Use the email for all three bindings ($1, $2, $3 in your original) — in SQLite use ? as placeholders.
    final result = await db.rawQuery(sql, [email, email, email]);
    return result;
  }

  // MESSAGES CRUD

  Future<int> insertMessage(Map<String, dynamic> msg) async {
    final db = await database;
    return await db.insert('messages', msg);
  }

  Future<List<Map<String, dynamic>>> getMessages(
    String user1,
    String user2,
  ) async {
    final db = await database;
    return await db.query(
      'messages',
      where:
          '(sender_email = ? AND receiver_email = ?) OR (sender_email = ? AND receiver_email = ?)',
      whereArgs: [user1, user2, user2, user1],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> initialLocalSync(String currentUserEmail) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('isDbInitialized') ?? false)) {
      // Fetch all from backend
      final remoteConvos = await InboxService.fetchConversations(
        currentUserEmail,
      );
      for (final convo in remoteConvos) {
        await LocalDatabaseService().upsertConversation({
          'user1_email': convo.user1Email,
          'user2_email': convo.user2Email,
          'last_message': convo.lastMessage,
          'last_sender_email': convo.lastSenderEmail,
          'last_updated': convo.lastUpdated.toIso8601String(),
        });
      }
      // Fetch all messages (backend endpoint must support this!)
      final allOtherEmails =
          remoteConvos
              .map(
                (c) =>
                    c.user1Email == currentUserEmail
                        ? c.user2Email
                        : c.user1Email,
              )
              .toSet();

      for (final otherEmail in allOtherEmails) {
        final remoteMessages = await ChatService.fetchMessages(
          currentUserEmail,
          otherEmail,
        );
        for (final msg in remoteMessages) {
          await LocalDatabaseService().insertMessage({
            'sender_email': msg.senderEmail,
            'receiver_email': msg.receiverEmail,
            'content': msg.content,
            'timestamp': msg.timestamp,
          });
        }
      }
      prefs.setBool('isDbInitialized', true);
    }
  }
}
