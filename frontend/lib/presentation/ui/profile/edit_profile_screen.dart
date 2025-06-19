import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/application/user/user_bloc.dart';
import 'package:app/application/user/user_event.dart';
import 'package:app/application/user/user_state.dart';
import 'package:app/domain/entity/update_profile_entity.dart';
import 'package:app/presentation/ui/common/bottom_border_input_field.dart';
import 'package:app/presentation/ui/common/loading_button.dart';
import 'package:app/presentation/utils/localization_extension.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  final _picker = ImagePicker();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _controllersFilled = false;
  bool _isSaving = false;
  String? _initialLocation;

  @override
  void initState() {
    super.initState();
    final state = context.read<UserBloc>().state;
    if (state is UserLoaded) _fillControllers(state.user);
  }

  void _fillControllers(user) {
    _nameCtrl.text = user.name ?? '';
    _emailCtrl.text = user.email ?? '';
    _phoneCtrl.text = user.phoneNumber ?? '';
    _locationCtrl.text = user.location ?? '';
    _controllersFilled = true;
  }

  Future<void> _pickProfileImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _profileImage = File(picked.path));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locals = context.commonLocals;
    const green = Color(0xFF94C495);

    return Scaffold(
      appBar: AppBar(title: Text(locals.edit_profile)),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserLoaded && !_controllersFilled) {
            _fillControllers(state.user);
          }

          if (state is UserLoaded && _isSaving) {
            _isSaving = false;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Profile updated ✔',
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor),
                ),
                backgroundColor: Theme.of(context).primaryColor));
          }

          if (state is UserError) {
            _isSaving = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final loading = state is UserLoading;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  // onTap: _pickProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: green,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.person,
                            size: 50, color: Theme.of(context).focusColor)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                BottomBorderInputField(
                    controller: _nameCtrl, labelText: locals.name),
                const SizedBox(height: 16),
                BottomBorderInputField(
                    controller: _emailCtrl, labelText: locals.email),
                const SizedBox(height: 16),
                BottomBorderInputField(
                    controller: _phoneCtrl, labelText: locals.phone_number),
                const SizedBox(height: 16),
                BottomBorderInputField(
                    controller: _locationCtrl, labelText: locals.location),
                const SizedBox(height: 32),
                LoadingButton(
                  label: locals.save_changes,
                  loading: loading,
                  width: double.infinity,
                  onPressed: () {
                    final locText = _locationCtrl.text.trim();
                    final entity = UpdateProfileEntity(
                      name: _nameCtrl.text.trim().isEmpty
                          ? null
                          : _nameCtrl.text.trim(),
                      email: _emailCtrl.text.trim().isEmpty
                          ? null
                          : _emailCtrl.text.trim(),
                      phoneNumber: _phoneCtrl.text.trim().isEmpty
                          ? null
                          : _phoneCtrl.text.trim(),
                      location: locText.isEmpty ? _initialLocation : locText,

                    );
                    _isSaving = true;
                    context.read<UserBloc>().add(UpdateUserProfile(entity));
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
