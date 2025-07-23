import 'package:flutter/widgets.dart';
import 'package:hilo/crud/local_database_service.dart';

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

  Future<void> delete() async {
    await LocalDatabaseService().deleteAllData();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
