import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:image/image.dart' as img;
import '../localization.dart';

class AvatarCropScreen extends StatefulWidget {
  final String imagePath;

  const AvatarCropScreen({super.key, required this.imagePath});

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  File? _originalImage;
  File? _editedImage;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final file = File(widget.imagePath);
      if (await file.exists()) {
        setState(() {
          _originalImage = file;
          _editedImage = file; // Начинаем с оригинала
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveImage() {
    // Возвращаем путь к отредактированному изображению
    Navigator.pop(context, _editedImage?.path ?? widget.imagePath);
  }

  void _cancelEditing() {
    Navigator.pop(context);
  }

  Future<void> _openCustomCrop() async {
    final imageFile = _originalImage ?? File(widget.imagePath);
    if (!await imageFile.exists()) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomImageCropper(
          imagePath: imageFile.path,
          onImageEdited: (editedPath) {
            // Обновляем отредактированное изображение
            setState(() {
              _editedImage = File(editedPath);
              _hasChanges = true;
            });
          },
        ),
      ),
    );

    // Если пользователь сохранил изменения в редакторе
    if (result != null && result is String) {
      setState(() {
        _editedImage = File(result);
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
              // Верхняя панель
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
                        icon: Icon(Icons.close_rounded),
                        color: primaryColor,
                        onPressed: _cancelEditing,
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
                            appLocalizations.avatarCropTitle,
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
                  child: Column(
                    children: [
                      // Превью аватара
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
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
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Предпросмотр',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: theme.textTheme.titleMedium?.color,
                                          ),
                                        ),
                                        Text(
                                          'Так будет выглядеть аватар',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: theme.hintColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Превью изображения
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor.withOpacity(0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: _isLoading
                                    ? Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                )
                                    : _editedImage != null
                                    ? ClipOval(
                                  child: Image.file(
                                    _editedImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildErrorPreview();
                                    },
                                  ),
                                )
                                    : _buildErrorPreview(),
                              ),
                              SizedBox(height: 16),

                              // Индикатор изменений
                              if (_hasChanges)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Изменения применены',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Кнопки действий
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          children: [
                            // Кнопка редактирования
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _openCustomCrop,
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      _hasChanges ? 'Продолжить редактирование' : 'Редактировать',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),

                            // Кнопка сохранения
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading || !_hasChanges ? null : _saveImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasChanges ? Colors.green : Colors.grey,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Сохранить изменения',
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

  Widget _buildErrorPreview() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: primaryColor,
          size: 60,
        ),
      ),
    );
  }
}

class CustomImageCropper extends StatefulWidget {
  final String imagePath;
  final Function(String)? onImageEdited;

  const CustomImageCropper({
    super.key,
    required this.imagePath,
    this.onImageEdited,
  });

  @override
  State<CustomImageCropper> createState() => _CustomImageCropperState();
}

class _CustomImageCropperState extends State<CustomImageCropper> {
  final TransformationController _transformationController = TransformationController();
  File? _originalImage;
  bool _isLoading = false;
  bool _isSaving = false;
  double _minScale = 0.5;
  double _maxScale = 5.0;
  bool _hasChanges = false;
  double _imageAspectRatio = 1.0;
  int _originalWidth = 0;
  int _originalHeight = 0;
  double _cropSize = 400.0;
  double _containerSize = 300.0;

  @override
  void initState() {
    super.initState();
    _loadImage();

    // Отслеживаем изменения
    _transformationController.addListener(() {
      if (!_transformationController.value.isIdentity()) {
        setState(() {
          _hasChanges = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final file = File(widget.imagePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final decodedImage = img.decodeImage(bytes);
        if (decodedImage != null) {
          _originalWidth = decodedImage.width;
          _originalHeight = decodedImage.height;
          _imageAspectRatio = _originalWidth / _originalHeight;

          // Рассчитываем размер обрезки на основе оригинального изображения
          final minSize = math.min(_originalWidth, _originalHeight);
          _cropSize = math.min(minSize.toDouble(), 400.0);

          print('Original image: $_originalWidth x $_originalHeight, cropSize: $_cropSize');
        }

        setState(() {
          _originalImage = file;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCroppedImage() async {
    if (!_hasChanges) {
      // Если нет изменений, возвращаем оригинальное фото
      Navigator.pop(context, widget.imagePath);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Применяем трансформации к изображению
      final editedImagePath = await _applyTransformations();

      // Сообщаем о сохранении
      if (widget.onImageEdited != null) {
        widget.onImageEdited!(editedImagePath);
      }

      Navigator.pop(context, editedImagePath);
    } catch (e) {
      print('Error saving edited image: $e');
      // В случае ошибки возвращаем оригинальный путь
      Navigator.pop(context, widget.imagePath);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<String> _applyTransformations() async {
    if (_originalImage == null) {
      throw Exception('Original image is null');
    }

    // Загружаем изображение
    final imageBytes = await _originalImage!.readAsBytes();
    var decodedImage = img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception('Failed to decode image');
    }

    // Получаем текущую матрицу трансформации
    final matrix = _transformationController.value;
    final translation = matrix.getTranslation();
    final scale = matrix.getMaxScaleOnAxis();
    final rotationAngle = _extractRotationAngle(matrix);

    print('Transform params: scale=$scale, translation=$translation, rotation=$rotationAngle');

    // 1. Поворот
    if (rotationAngle.abs() > 0.01) {
      final angleDegrees = rotationAngle * 180 / math.pi;
      decodedImage = img.copyRotate(decodedImage, angle: angleDegrees);
    }

    // 2. Масштабирование оригинального изображения
    final scaledWidth = (_originalWidth * scale).toInt();
    final scaledHeight = (_originalHeight * scale).toInt();

    decodedImage = img.copyResize(
      decodedImage,
      width: scaledWidth,
      height: scaledHeight,
    );

    // 3. ПРОСТАЯ ЛОГИКА: InteractiveViewer показывает часть изображения
    // В центре вьювера находится точка, которую мы хотим сделать центром обрезки

    // InteractiveViewer использует систему координат, где:
    // - (0,0) - центр вьювера
    // - translation - смещение центра изображения относительно центра вьювера

    // Преобразуем координаты InteractiveViewer в координаты изображения
    // translation.x/y находятся в диапазоне примерно [-1, 1], но могут быть больше

    // Размер видимой области в пикселях оригинального изображения
    final visibleWidth = _containerSize * scale;
    final visibleHeight = _containerSize * scale;

    // Центр вьювера (0,0) соответствует центру видимой области
    // Вычисляем координаты центра видимой области в масштабированном изображении
    final viewCenterX = scaledWidth / 2 - translation.x * (visibleWidth / 2);
    final viewCenterY = scaledHeight / 2 - translation.y * (visibleHeight / 2);

    // Теперь viewCenterX и viewCenterY - координаты точки, которая находится в центре вьювера

    // Вычисляем координаты левого верхнего угла для обрезки (центрируем на viewCenter)
    final cropX = (viewCenterX - _cropSize / 2).toInt();
    final cropY = (viewCenterY - _cropSize / 2).toInt();

    // Ограничиваем координаты обрезки
    final clampedCropX = math.max(0, math.min(cropX, scaledWidth - _cropSize.toInt()));
    final clampedCropY = math.max(0, math.min(cropY, scaledHeight - _cropSize.toInt()));

    print('View center: ($viewCenterX, $viewCenterY)');
    print('Crop params: x=$clampedCropX, y=$clampedCropY, size=${_cropSize.toInt()}');
    print('Scaled image: width=$scaledWidth, height=$scaledHeight');

    // 4. Обрезка
    decodedImage = img.copyCrop(
      decodedImage,
      x: clampedCropX,
      y: clampedCropY,
      width: _cropSize.toInt(),
      height: _cropSize.toInt(),
    );

    // 5. Масштабируем до стандартного размера аватара
    decodedImage = img.copyResize(
      decodedImage,
      width: 400,
      height: 400,
    );

    // Создаем временный файл
    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempFile = File('${tempDir.path}/edited_avatar_$timestamp.jpg');

    // Сохраняем изображение
    final encodedImage = img.encodeJpg(decodedImage, quality: 85);
    await tempFile.writeAsBytes(encodedImage);

    return tempFile.path;
  }

  double _extractRotationAngle(Matrix4 matrix) {
    final m = matrix.storage;
    final sinTheta = m[1];
    final cosTheta = m[0];
    return math.atan2(sinTheta, cosTheta);
  }

  void _cancelCrop() {
    Navigator.pop(context);
  }

  void _resetTransform() {
    _transformationController.value = Matrix4.identity();
    setState(() {
      _hasChanges = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    _containerSize = screenWidth - 60;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
            children: [
              // Верхняя панель
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                        icon: Icon(Icons.close_rounded),
                        color: primaryColor,
                        onPressed: _cancelCrop,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Редактирование',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                        if (_hasChanges)
                          Text(
                            'Есть изменения',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                    if (_isSaving)
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.green,
                          ),
                        ),
                      )
                    else
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
                          icon: Icon(Icons.check_rounded),
                          color: _hasChanges ? Colors.green : Colors.grey,
                          onPressed: _isSaving ? null : _saveCroppedImage,
                        ),
                      ),
                  ],
                ),
              ),

              // Кнопка сброса
              if (_hasChanges)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetTransform,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        foregroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restart_alt_rounded, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Сбросить',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Область изображения
              Expanded(
                child: Center(
                  child: _isLoading
                      ? CircularProgressIndicator(color: primaryColor)
                      : _originalImage != null
                      ? Container(
                    width: _containerSize,
                    height: _containerSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Stack(
                        children: [
                          // Полупрозрачный оверлей для области обрезки
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                              ),
                              child: CustomPaint(
                                painter: _CropOverlayPainter(),
                              ),
                            ),
                          ),

                          // InteractiveViewer с изображением
                          InteractiveViewer(
                            transformationController: _transformationController,
                            minScale: _minScale,
                            maxScale: _maxScale,
                            boundaryMargin: EdgeInsets.all(double.infinity),
                            panEnabled: true,
                            scaleEnabled: true,
                            child: Container(
                              color: isDark ? Colors.black : Colors.white,
                              child: Image.file(
                                _originalImage!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Container(
                    width: _containerSize,
                    height: _containerSize,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: primaryColor.withOpacity(0.5),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Ошибка загрузки',
                          style: TextStyle(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Инструкция
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Передвигайте и масштабируйте фото. В центре круга будет аватар',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    // Рисуем затемнение вокруг
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Очищаем центральную область (круг для аватара)
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    canvas.drawCircle(center, radius, clearPaint);

    // Рисуем границу круга
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}