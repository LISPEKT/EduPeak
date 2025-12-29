import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'avatar_crop_screen.dart';
import '../data/user_data_storage.dart';
import '../services/api_service.dart';
import 'dart:io';
import '../localization.dart';

class ProfileEditorScreen extends StatefulWidget {
  final String currentAvatar;
  final Function(String) onAvatarUpdate;
  final Function(String) onUsernameUpdate;
  final Function(int) onBottomNavTap;
  final int currentIndex;

  const ProfileEditorScreen({
    Key? key,
    required this.currentAvatar,
    required this.onAvatarUpdate,
    required this.onUsernameUpdate,
    required this.onBottomNavTap,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  String? _selectedImagePath; // Храним путь к только что выбранному фото

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
    final appLocalizations = AppLocalizations.of(context)!;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Сохраняем путь к выбранному фото
        setState(() {
          _selectedImagePath = image.path;
        });

        final editedImagePath = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AvatarCropScreen(imagePath: image.path),
          ),
        );

        if (editedImagePath != null && editedImagePath is String) {
          // Обновляем путь к отредактированному фото
          setState(() {
            _selectedImagePath = editedImagePath;
          });
          // Автоматически сохраняем после редактирования
          await _updateAvatar(editedImagePath);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.errorSelectingImage),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _updateAvatar(String imagePath) async {
    final appLocalizations = AppLocalizations.of(context)!;

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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? appLocalizations.avatarUpdateError),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLocalizations.avatarUpdateError}: $e'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateUsername() async {
    final appLocalizations = AppLocalizations.of(context)!;
    final newUsername = _usernameController.text.trim();

    if (newUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appLocalizations.enterUsername),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${appLocalizations.usernameUpdateError}: $e'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Метод для отображения аватара
  Widget _buildAvatar() {
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Если есть только что выбранное фото - показываем его
    if (_selectedImagePath != null && File(_selectedImagePath!).existsSync()) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: primaryColor.withOpacity(0.1),
        backgroundImage: FileImage(File(_selectedImagePath!)),
      );
    }

    // Иначе показываем текущий аватар
    final bool isPhotoAvatar = widget.currentAvatar.startsWith('/');

    return CircleAvatar(
      radius: 60,
      backgroundColor: primaryColor.withOpacity(0.1),
      backgroundImage: isPhotoAvatar && File(widget.currentAvatar).existsSync()
          ? FileImage(File(widget.currentAvatar)) as ImageProvider
          : null,
      child: !isPhotoAvatar
          ? Icon(
        Icons.person_rounded,
        size: 50,
        color: primaryColor,
      )
          : null,
    );
  }

  // Метод для определения текста информационной карточки
  String _getInfoCardText() {
    final appLocalizations = AppLocalizations.of(context)!;

    if (_selectedImagePath != null) {
      return 'Используется новое фото. Нажмите ✓ для сохранения изменений.';
    }

    final bool isPhotoAvatar = widget.currentAvatar.startsWith('/');
    return isPhotoAvatar
        ? appLocalizations.usingCustomPhoto
        : appLocalizations.usingDefaultAvatar;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.15),
              theme.scaffoldBackgroundColor.withOpacity(0.7),
              theme.scaffoldBackgroundColor,
            ],
            stops: [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя панель с заголовком
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Кнопка назад
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded),
                        color: primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Раздел',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            'Редактировать профиль',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Основной контент
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Аватар
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          GestureDetector(
                            onTap: _isLoading ? null : _pickImage,
                            child: Stack(
                              children: [
                                _buildAvatar(),
                                if (_isLoading)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: _isLoading ? null : _pickImage,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),
                      Text(
                        appLocalizations.clickToEdit,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.hintColor,
                        ),
                      ),

                      // Индикатор нового фото
                      if (_selectedImagePath != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.new_releases_rounded,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Новое фото выбрано',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 32),

                      // Поле ввода имени пользователя
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appLocalizations.username,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                            SizedBox(height: 12),
                            TextField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: appLocalizations.enterUsername,
                                filled: true,
                                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _updateUsername,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      appLocalizations.updateUsername,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Информационная карточка
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.info_rounded,
                                color: primaryColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getInfoCardText(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTheme.titleMedium?.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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