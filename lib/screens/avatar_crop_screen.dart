import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class AvatarCropScreen extends StatefulWidget {
  final String imagePath;

  const AvatarCropScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  File? _croppedImage;
  bool _isLoading = false;
  bool _hasError = false;

  // Зеленый цвет для кнопок
  final Color _primaryColor = Colors.green;

  @override
  void initState() {
    super.initState();
    // Убираем автоматическое кадрирование, сразу показываем экран предпросмотра
    _croppedImage = File(widget.imagePath);
  }

  void _saveImage() {
    if (_croppedImage != null) {
      Navigator.pop(context, _croppedImage!.path);
    } else {
      Navigator.pop(context, widget.imagePath);
    }
  }

  void _cancelEditing() {
    Navigator.pop(context);
  }

  // Функция для открытия кадрирования вручную с кастомным интерфейсом
  Future<void> _openCropManually() async {
    final imageFile = File(widget.imagePath);
    if (!await imageFile.exists()) return;

    // Открываем кастомный экран кадрирования
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomCropScreen(imagePath: widget.imagePath),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        _croppedImage = File(result);
        _hasError = false;
      });
    }
  }

  // Функция для получения цветов в зависимости от темы
  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _getDarkThemeBackgroundColor()
        : Colors.white;
  }

  Color _getDarkThemeBackgroundColor() {
    return const Color(0xFF121212);
  }

  Color _getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.grey[50]!;
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Color _getSubtitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: null,
      body: _buildBodyWithCustomHeader(),
    );
  }

  Widget _buildBodyWithCustomHeader() {
    return SafeArea(
      child: Column(
        children: [
          _buildCustomHeader(),
          Expanded(
            child: _buildPreviewWidget(),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Крестик
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.close,
                size: 20,
                color: _getTextColor(context),
              ),
              onPressed: _cancelEditing,
              padding: EdgeInsets.zero,
            ),
          ),
          // Заголовок
          Text(
            'Редактирование',
            style: TextStyle(
              color: _getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Галочка
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.check,
                size: 20,
                color: Colors.white,
              ),
              onPressed: _saveImage,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewWidget() {
    return Center(
      child: _croppedImage != null
          ? Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getTextColor(context).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _croppedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageErrorWidget();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      )
          : _buildImageErrorWidget(),
    );
  }

  Widget _buildImageErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_rounded,
            color: _getSubtitleColor(context),
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Изображение не доступно',
            style: TextStyle(
              color: _getSubtitleColor(context),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getSurfaceColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: _getTextColor(context).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Квадратная аватарка 1:1',
            style: TextStyle(
              color: _getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Настройте обрезку для идеальной аватарки',
            style: TextStyle(
              color: _getSubtitleColor(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openCropManually,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit, size: 20),
              label: const Text(
                'Редактировать',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Класс для кастомного экрана кадрирования
class CustomCropScreen extends StatefulWidget {
  final String imagePath;

  const CustomCropScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<CustomCropScreen> createState() => _CustomCropScreenState();
}

class _CustomCropScreenState extends State<CustomCropScreen> {
  File? _croppedImage;
  bool _isLoading = false;

  final Color _primaryColor = Colors.green;

  Color _getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF121212)
        : Colors.white;
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  Future<void> _cropImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Редактирование',
            toolbarColor: _getBackgroundColor(context),
            toolbarWidgetColor: _primaryColor,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true,
            showCropGrid: false,
            activeControlsWidgetColor: _primaryColor,
            statusBarColor: _getBackgroundColor(context),
            backgroundColor: _getBackgroundColor(context),
            cropFrameColor: _getTextColor(context),
            cropGridColor: Colors.transparent,
            dimmedLayerColor: _getBackgroundColor(context).withOpacity(0.8),
          ),
          IOSUiSettings(
            title: 'Редактирование',
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            resetButtonHidden: true,
            rotateButtonsHidden: true,
            rotateClockwiseButtonHidden: true,
            doneButtonTitle: 'Готово',
            cancelButtonTitle: 'Отмена',
            showCancelConfirmationDialog: true,
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (croppedFile != null) {
        _croppedImage = File(croppedFile.path);
        Navigator.pop(context, croppedFile.path);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelCrop() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(context),
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            // Кастомный заголовок такой же как на основном экране
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Крестик
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: _getTextColor(context),
                      ),
                      onPressed: _cancelCrop,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  // Заголовок
                  Text(
                    'Редактирование',
                    style: TextStyle(
                      color: _getTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Галочка
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.check,
                        size: 20,
                        color: Colors.white,
                      ),
                      onPressed: _cropImage,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: _primaryColor,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Обрезка...',
                      style: TextStyle(
                        color: _getTextColor(context).withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}