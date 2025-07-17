// import 'dart:async';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart'
//     show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
// import 'package:sqflite/sqflite.dart';

// // Custom Exceptions for the Database Service
// class DatabaseAlreadyOpenException implements Exception {}

// class DatabaseIsNotOpen implements Exception {}

// class CouldNotDeleteMessage implements Exception {}

// class CouldNotFindMessage implements Exception {}

// class CouldNotUpdateMessage implements Exception {}

// class UnableToGetDocumentsDirectory implements Exception {}

// class DatabaseService {
//   Database? _db;

//   // Private constructor for the singleton pattern
//   DatabaseService._sharedInstance();

//   // Singleton instance
//   static final DatabaseService _shared = DatabaseService._sharedInstance();

//   // Factory constructor to return the singleton instance
//   factory DatabaseService() => _shared;

//   // Opens the database and initializes it
//   Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;

//       // Create the messages table if it doesn't exist
//       await db.execute(createMessagesTable);
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }

//   // Ensures the database is open before any operation
//   Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       // Ignore if already open
//     }
//   }

//   // Closes the database connection
//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   // Throws an exception if the database is not open
//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   // Fetches all messages directly from the database
//   Future<Iterable<Message>> getAllMessages() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final messages = await db.query(messagesTable);
//     return messages.map((row) => Message.fromMap(row));
//   }

//   // Fetches a single message by its ID
//   Future<Message> getMessage({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final messages = await db.query(
//       messagesTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (messages.isEmpty) {
//       throw CouldNotFindMessage();
//     }
//     return Message.fromMap(messages.first);
//   }

//   // Creates a new message in the database
//   Future<Message> createMessage({
//     required String senderId,
//     required String receiverId,
//     required String text,
//     required String messageType,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final timestamp = DateTime.now().toIso8601String();

//     final messageId = await db.insert(messagesTable, {
//       senderIdColumn: senderId,
//       receiverIdColumn: receiverId,
//       textColumn: text,
//       timeStampColumn: timestamp,
//       isSentByMeColumn: 1, // Assuming the creator is the sender
//       isSyncedWithCloudColumn: 0,
//       messageTypeColumn: messageType,
//     });

//     return Message(
//       id: messageId,
//       senderId: senderId,
//       receiverId: receiverId,
//       text: text,
//       timeStamp: timestamp,
//       isSentByMe: true,
//       isSyncedWithCloud: false,
//       messageType: messageType,
//     );
//   }

//   // Deletes a message by its ID
//   Future<void> deleteMessage({required int id}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       messagesTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (deletedCount == 0) {
//       throw CouldNotDeleteMessage();
//     }
//   }

//   // Updates the text of a message
//   Future<Message> updateMessage({
//     required int messageId,
//     required String text,
//   }) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();

//     final updatesCount = await db.update(
//       messagesTable,
//       {textColumn: text, isSyncedWithCloudColumn: 0},
//       where: 'id = ?',
//       whereArgs: [messageId],
//     );

//     if (updatesCount == 0) {
//       throw CouldNotUpdateMessage();
//     } else {
//       // Fetch the updated message from the DB to return it
//       return await getMessage(id: messageId);
//     }
//   }
// }

// // Data class for a message
// class Message {
//   final int id;
//   final String senderId;
//   final String receiverId;
//   final String text;
//   final String timeStamp;
//   final bool isSentByMe;
//   final bool isSyncedWithCloud;
//   final String messageType;

//   Message({
//     required this.id,
//     required this.senderId,
//     required this.receiverId,
//     required this.text,
//     required this.timeStamp,
//     required this.isSentByMe,
//     required this.isSyncedWithCloud,
//     required this.messageType,
//   });

//   // Factory constructor to create a Message from a map
//   factory Message.fromMap(Map<String, dynamic> map) {
//     return Message(
//       id: map[idColumn] as int,
//       senderId: map[senderIdColumn] as String,
//       receiverId: map[receiverIdColumn] as String,
//       text: map[textColumn] as String,
//       timeStamp: map[timeStampColumn] as String,
//       isSentByMe: (map[isSentByMeColumn] as int) == 1,
//       isSyncedWithCloud: (map[isSyncedWithCloudColumn] as int) == 1,
//       messageType: map[messageTypeColumn] as String,
//     );
//   }

//   @override
//   String toString() =>
//       'Message, ID: $id, From: $senderId, To: $receiverId, Type: $messageType';

//   @override
//   bool operator ==(covariant Message other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// // Database and table constants
// const dbName = 'messages.db';
// const messagesTable = 'messages';
// const idColumn = 'id';
// const senderIdColumn = 'sender_id';
// const receiverIdColumn = 'receiver_id';
// const textColumn = 'text';
// const timeStampColumn = 'timestamp';
// const isSentByMeColumn = 'is_sent_by_me';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const messageTypeColumn = 'message_type';

// // SQL statement to create the messages table
// const createMessagesTable = '''CREATE TABLE IF NOT EXISTS "messages" (
//   "id"  INTEGER NOT NULL,
//   "sender_id" TEXT NOT NULL,
//   "receiver_id" TEXT NOT NULL,
//   "text"  TEXT,
//   "timestamp" TEXT NOT NULL,
//   "is_sent_by_me" INTEGER NOT NULL,
//   "is_synced_with_cloud"  INTEGER NOT NULL DEFAULT 0,
//   "message_type"  TEXT NOT NULL DEFAULT 'text',
//   PRIMARY KEY("id" AUTOINCREMENT)
// );''';
