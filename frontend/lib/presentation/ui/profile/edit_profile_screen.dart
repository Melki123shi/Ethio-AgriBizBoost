import 'package:app/presentation/ui/common/bottom_border_input_field.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF94C495);

    return Scaffold(
      appBar: AppBar(title: Text(context.commonLocals.edit_profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: green,
                backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Icon(Icons.person, size: 50, color: Theme.of(context).focusColor)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            BottomBorderInputField(
              controller: _nameController,
              labelText: context.commonLocals.name,
            ),
            const SizedBox(height: 16),
            BottomBorderInputField(
              controller: _emailController,
              labelText: context.commonLocals.email,
            ),
            const SizedBox(height: 16),
            BottomBorderInputField(
              controller: _phoneController,
              labelText: context.commonLocals.phone_number,
            ),
            const SizedBox(height: 16),
            BottomBorderInputField(
              controller: _locationController,
              labelText: context.commonLocals.location,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.commonLocals.save_changes,
                  style: TextStyle(color: Theme.of(context).focusColor, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
