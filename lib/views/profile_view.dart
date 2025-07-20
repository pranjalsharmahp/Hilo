import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hilo/crud/local_database_service.dart';
import 'package:hilo/features/profile/profile_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileView extends StatefulWidget {
  final String email;
  final String name;
  final String bio;

  const ProfileView({
    super.key,
    required this.email,
    required this.name,
    required this.bio,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  File? _imageFile;
  String? _profilePictureUrl; // Store the URL as a String

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    print('Loading profile image for ${widget.email}');
    final profileUrl = await LocalDatabaseService().getProfileUrl(widget.email);
    if (profileUrl != null && profileUrl.isNotEmpty) {
      setState(() {
        _profilePictureUrl = profileUrl;
        print('Profile image URL loaded: $_profilePictureUrl');
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
        ProfileService.uploadProfileImage(
          File(pickedFile.path),
          widget.email,
        ).then((profileUrl) async {
          if (profileUrl != null) {
            await LocalDatabaseService().updateProfileUrl(
              widget.email,
              profileUrl,
            );
            setState(() {
              _profilePictureUrl = profileUrl;
              _imageFile = File(pickedFile.path);
            });
            print('Profile image uploaded: $profileUrl');
          } else {
            print('Profile image upload failed');
          }
        });

        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_profilePictureUrl != null &&
                                  _profilePictureUrl!.isNotEmpty
                              ? NetworkImage(_profilePictureUrl!)
                              : null),
                  child:
                      (_imageFile == null &&
                              (_profilePictureUrl == null ||
                                  _profilePictureUrl!.isEmpty))
                          ? const Icon(Icons.person, size: 60)
                          : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap to change photo',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // Name
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // Bio
              Text(
                widget.bio,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Edit Button
              ElevatedButton.icon(
                onPressed: () {
                  // Handle edit logic
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
