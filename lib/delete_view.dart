import 'package:flutter/material.dart';
import 'package:hilo/crud/local_database_service.dart';

class DeleteView extends StatefulWidget {
  const DeleteView({super.key});

  @override
  State<DeleteView> createState() => _DeleteViewState();
}

class _DeleteViewState extends State<DeleteView> {
  @override
  void initState() {
    super.initState();
    // LocalDatabaseService()
    //     .deleteDatabse()
    //     .then((_) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(content: Text('Database deleted successfully')),
    //       );
    //     })
    //     .catchError((error) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(content: Text('Error deleting database: $error')),
    //       );
    //     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
