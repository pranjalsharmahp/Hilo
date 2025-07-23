import 'package:flutter/widgets.dart';
import 'package:hilo/crud/local_database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Testing extends StatefulWidget {
  const Testing({super.key});

  @override
  State<Testing> createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  @override
  void initState() {
    super.initState();
    delete();
  }

  Future<void> deleteWholeDatabase() async {
    await LocalDatabaseService().deleteDatabse();
  }

  Future<void> delete() async {
    await LocalDatabaseService().deleteAllData();
  }

  Future<void> printAllMessages() async {}

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
