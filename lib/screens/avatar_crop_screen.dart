// avatar_crop_screen.dart - РЕДИЗАЙН В MD3
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import '../localization.dart';

class AvatarCropScreen extends StatefulWidget {
  final String imagePath;

  const AvatarCropScreen({super.key, required this.imagePath});

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  File? _croppedImage;
  final bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _openCropManually() async {
    final imageFile = File(widget.imagePath);
    if (!await imageFile.exists()) return;

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

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(appLocalizations.avatarCropTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancelEditing,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveImage,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildPreviewWidget(appLocalizations),
            ),
            _buildBottomPanel(appLocalizations),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewWidget(AppLocalizations appLocalizations) {
    return Center(
      child: _croppedImage != null
          ? Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  _croppedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImageErrorWidget(appLocalizations);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      )
          : _buildImageErrorWidget(appLocalizations),
    );
  }

  Widget _buildImageErrorWidget(AppLocalizations appLocalizations) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            appLocalizations.errorSelectingImage,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(AppLocalizations appLocalizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appLocalizations.squareAvatar,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            appLocalizations.avatarCropSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openCropManually,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: Text(
                appLocalizations.editButton,
                style: const TextStyle(
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

class CustomCropScreen extends StatefulWidget {
  final String imagePath;

  const CustomCropScreen({super.key, required this.imagePath});

  @override
  State<CustomCropScreen> createState() => _CustomCropScreenState();
}

class _CustomCropScreenState extends State<CustomCropScreen> {
  File? _croppedImage;
  bool _isLoading = false;

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
            toolbarTitle: AppLocalizations.of(context).cropTitle,
            toolbarColor: Theme.of(context).colorScheme.surface,
            toolbarWidgetColor: Theme.of(context).colorScheme.primary,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: true,
            showCropGrid: false,
            activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
            statusBarColor: Theme.of(context).colorScheme.surface,
            backgroundColor: Theme.of(context).colorScheme.background,
            cropFrameColor: Theme.of(context).colorScheme.onSurface,
            cropGridColor: Colors.transparent,
            dimmedLayerColor: Theme.of(context).colorScheme.background.withOpacity(0.8),
          ),
          IOSUiSettings(
            title: AppLocalizations.of(context).cropTitle,
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
            resetButtonHidden: true,
            rotateButtonsHidden: true,
            rotateClockwiseButtonHidden: true,
            doneButtonTitle: AppLocalizations.of(context).done,
            cancelButtonTitle: AppLocalizations.of(context).cancel,
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
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(appLocalizations.avatarCropTitle),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _cancelCrop,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _cropImage,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                appLocalizations.saving,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }
}