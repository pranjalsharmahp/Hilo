import 'dart:io';
import 'package:hilo/features/chat/chat_service.dart';
import 'package:hilo/features/inbox/inbox_service.dart';
import 'package:hilo/person.dart';
import 'package:hilo/socket/socket_service.dart';
import 'package:hilo/users/user.dart';
import 'package:path_provider/path_provider.dart';
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

  // ===================== USERS =====================
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    user['created_at'] ??= DateTime.now().toIso8601String();
    user['updated_at'] ??= DateTime.now().toIso8601String();
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDatabse() async {
    final db = await database;
    await db.close();
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, "local_chat.db");
    if (await File(path).exists()) {
      await File(path).delete();
    }
  }

  Future<String?> getProfileUrl(String email) async {
    print('Fetching profile URL for $email');
    final db = await database;
    final usersTable = await db.query('users');
    print('Current users table: $usersTable');
    final result = await db.query(
      'users',
      columns: ['profile_url'],
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      final url = result.first['profile_url'];
      if (url != null && url is String && url.isNotEmpty) {
        return url;
      }
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');

    return result.map((e) => User.fromJson(e)).toList();
  }

  Future<bool> updateProfileUrl(String email, String profileUrl) async {
    final db = await database;
    // Check if user exists
    final user = await getUserByEmail(email);
    if (user == null) {
      // If not, insert user with email and profile_url
      await insertUser({
        'email': email,
        'profile_url': profileUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } else {
      // If exists, just update
      final result = await db.update(
        'users',
        {
          'profile_url': profileUrl,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'email = ?',
        whereArgs: [email],
      );
      return result > 0;
    }
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'name ASC');
  }

  Future<Person?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      // Use fromJson (which works for both API and DB, since your keys match)
      return Person.fromJson(result.first);
    }
    return null;
  }

  Future<int> updateUser(String email, Map<String, dynamic> updates) async {
    final db = await database;
    updates['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(
      'users',
      updates,
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // ===================== CONVERSATIONS =====================
  Future<int> upsertConversation(Map<String, dynamic> convo) async {
    final db = await database;
    // Normalize emails to prevent duplicate combinations
    final emails = [convo['user1_email'], convo['user2_email']]..sort();
    convo['user1_email'] = emails[0];
    convo['user2_email'] = emails[1];
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
    final result = await db.rawQuery(sql, [email, email, email]);
    return result;
  }

  // ===================== MESSAGES =====================
  Future<int> insertMessage(Map<String, dynamic> msg) async {
    final db = await database;
    msg['timestamp'] ??= DateTime.now().toIso8601String();
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

  // ===================== INITIAL SYNC =====================
  Future<void> initialLocalSync(String currentUserEmail) async {
    try {
      final remoteConvos = await InboxService.fetchConversations(
        currentUserEmail,
      );
      final db = await database;

      // Insert/update conversations in a transaction
      await db.transaction((txn) async {
        for (final convo in remoteConvos) {
          final emails = [convo.user1Email, convo.user2Email]..sort();
          await txn.insert('conversations', {
            'user1_email': emails[0],
            'user2_email': emails[1],
            'last_message': convo.lastMessage,
            'last_sender_email': convo.lastSenderEmail,
            'last_updated': convo.lastUpdated.toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });

      // Get all unique other users
      final result = await db.rawQuery(
        '''
      SELECT DISTINCT 
        CASE 
          WHEN user1_email = ? THEN user2_email 
          ELSE user1_email 
        END AS other_user_email
      FROM conversations
      WHERE user1_email = ? OR user2_email = ?
      ''',
        [currentUserEmail, currentUserEmail, currentUserEmail],
      );

      final emailsToSync =
          result.map((row) => row['other_user_email'] as String).toList();
      emailsToSync.add(currentUserEmail);
      print('Emails to sync: $emailsToSync');

      for (final email in emailsToSync) {
        try {
          final remoteUser = await SocketService.fetchUserByEmail(email);
          if (remoteUser != null) {
            await insertUser({
              'email': remoteUser.email,
              'name': remoteUser.name,
              'profile_url': remoteUser.profilePictureUrl,
              'bio': remoteUser.bio,
            });
          }
        } catch (e) {
          // Optionally report error
        }
      }

      // Sync all messages
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
        try {
          final remoteMessages = await ChatService.fetchMessages(
            currentUserEmail,
            otherEmail,
          );
          for (final msg in remoteMessages) {
            await insertMessage({
              'sender_email': msg.senderEmail,
              'receiver_email': msg.receiverEmail,
              'content': msg.content,
              'timestamp': msg.timestamp,
            });
          }
        } catch (e) {
          // Optionally report error
        }
      }
    } catch (e) {
      // Optionally report error
    }
  }
}
