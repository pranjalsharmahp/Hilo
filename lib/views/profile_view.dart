import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:hilo/crud/local_database_service.dart';
import 'package:hilo/features/inbox/bloc/inbox_bloc.dart';
import 'package:hilo/features/inbox/bloc/inbox_event.dart';
import 'package:hilo/features/profile/profile_service.dart';
import 'package:hilo/person.dart';

class ProfileView extends StatefulWidget {
  final Person user;

  const ProfileView({super.key, required this.user});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _imageFile;
  String? _profilePictureUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final profileUrl = await LocalDatabaseService().getProfileUrl(
      widget.user.email,
    );
    if (profileUrl != null && profileUrl.isNotEmpty) {
      setState(() {
        _profilePictureUrl = profileUrl;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final profileUrl = await ProfileService.uploadProfileImage(
          file,
          widget.user.email,
        );
        if (profileUrl != null) {
          await LocalDatabaseService().updateProfileUrl(
            widget.user.email,
            profileUrl,
          );
          setState(() {
            _profilePictureUrl = profileUrl;
            _imageFile = file;
          });
        }
      }
    } catch (e) {
      print('Image pick error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        widget.user.email == FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            final email = FirebaseAuth.instance.currentUser?.email;
            if (email != null) {
              context.read<InboxBloc>().add(LoadInbox(email));
            }
          },
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: Column(
            children: [
              // Avatar
              GestureDetector(
                onTap: () {
                  if (isCurrentUser) _pickImage();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_profilePictureUrl != null &&
                                      _profilePictureUrl!.isNotEmpty
                                  ? NetworkImage(_profilePictureUrl!)
                                  : null)
                              as ImageProvider<Object>?,
                  child:
                      (_imageFile == null &&
                              (_profilePictureUrl == null ||
                                  _profilePictureUrl!.isEmpty))
                          ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )
                          : null,
                ),
              ),

              const SizedBox(height: 10),

              if (isCurrentUser)
                const Text(
                  'Tap to change photo',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),

              const SizedBox(height: 30),

              // Name
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),

              // Email
              Text(
                widget.user.email,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              // Bio
              // Text(
              //   widget.user.bio.isNotEmpty ? widget.user.bio : "No bio added.",
              //   style: const TextStyle(fontSize: 16, color: Colors.black87),
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 40),

              // Edit Profile
              // if (isCurrentUser)
              //   ElevatedButton.icon(
              //     onPressed: () {
              //       // Add your edit profile logic here
              //     },
              //     icon: const Icon(Icons.edit, size: 20),
              //     label: const Text("Edit Profile"),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.black,
              //       foregroundColor: Colors.white,
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 32,
              //         vertical: 14,
              //       ),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(14),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
