import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'avatar_crop_screen.dart';
import '../data/user_data_storage.dart';
import '../services/api_service.dart';
import 'dart:io';
import '../localization.dart';

class ProfileScreen extends StatefulWidget {
  final String currentAvatar;
  final Function(String) onAvatarUpdate;
  final Function(String) onUsernameUpdate;

  const ProfileScreen({
    Key? key,
    required this.currentAvatar,
    required this.onAvatarUpdate,
    required this.onUsernameUpdate,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final username = await UserDataStorage.getUsername();
    setState(() {
      _usernameController.text = username;
    });
  }

  Future<void> _pickImage() async {
    final appLocalizations = AppLocalizations.of(context);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final editedImagePath = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AvatarCropScreen(imagePath: image.path),
          ),
        );

        if (editedImagePath != null && editedImagePath is String) {
          await _updateAvatar(editedImagePath);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.errorSelectingImage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateAvatar(String imagePath) async {
    final appLocalizations = AppLocalizations.of(context);

    setState(() => _isLoading = true);
    try {
      await UserDataStorage.saveAvatar(imagePath);
      widget.onAvatarUpdate(imagePath);

      final response = await ApiService.updateAvatar(imagePath);
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? appLocalizations.avatarUpdated),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? appLocalizations.avatarUpdateError),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLocalizations.avatarUpdateError}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUsername() async {
    final appLocalizations = AppLocalizations.of(context);
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.enterUsername),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await UserDataStorage.saveUsername(newUsername);
      await UserDataStorage.updateUsernameOnServer(newUsername);
      widget.onUsernameUpdate(newUsername);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.usernameUpdated),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLocalizations.usernameUpdateError}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isPhotoAvatar() {
    return widget.currentAvatar.startsWith('/');
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(appLocalizations.profile),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Аватарка с кнопкой редактирования
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        backgroundImage: _isPhotoAvatar()
                            ? FileImage(File(widget.currentAvatar)) as ImageProvider
                            : null,
                        child: _isPhotoAvatar()
                            ? null
                            : Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Кнопка редактирования
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _isLoading ? null : _pickImage,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              appLocalizations.clickToEdit,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 32),

            // Поле имени пользователя
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: appLocalizations.username,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _updateUsername,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Кнопка обновления имени
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateUsername,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : Text(appLocalizations.updateUsername),
              ),
            ),

            const SizedBox(height: 20),

            // Информация о текущем аватаре
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isPhotoAvatar()
                          ? appLocalizations.usingCustomPhoto
                          : appLocalizations.usingDefaultAvatar,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}