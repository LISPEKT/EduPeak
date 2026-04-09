// lib/screens/admin/admin_panel_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedTab = 0;
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};
  List<dynamic> _users = [];
  List<dynamic> _banners = [];
  List<dynamic> _news = [];
  List<dynamic> _games = [];
  List<dynamic> _adminLogs = [];
  List<dynamic> _systemLogs = [];
  Map<String, dynamic> _logsStats = {};

  // Пагинация для логов
  int _adminLogsPage = 1;
  int _systemLogsPage = 1;
  bool _isLoadingAdminLogs = false;
  bool _isLoadingSystemLogs = false;
  bool _hasMoreAdminLogs = true;
  bool _hasMoreSystemLogs = true;

  final List<String> _tabs = ['dashboard', 'people', 'sports_esports', 'newspaper', 'history'];
  final List<String> _tabNames = ['Дашборд', 'Пользователи', 'Игры', 'Контент', 'Логи'];

  // Формы
  final TextEditingController _newsTitleController = TextEditingController();
  final TextEditingController _newsDescriptionController = TextEditingController();
  final TextEditingController _newsContentController = TextEditingController();
  final TextEditingController _newsCategoryController = TextEditingController();
  final TextEditingController _newsImageUrlController = TextEditingController();

  final TextEditingController _bannerTitleController = TextEditingController();
  final TextEditingController _bannerDescriptionController = TextEditingController();
  final TextEditingController _bannerImageUrlController = TextEditingController();
  final TextEditingController _bannerActionTypeController = TextEditingController();
  final TextEditingController _bannerActionValueController = TextEditingController();

  bool _isAddingNews = false;
  bool _isAddingBanner = false;
  bool _isDeletingGame = false;

  // Для загрузки изображений
  File? _selectedNewsImage;
  File? _selectedBannerImage;
  bool _isUploadingImage = false;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadDashboard(),
      _loadUsers(),
      _loadBanners(),
      _loadNews(),
      _loadGames(),
      _loadLogsStats(),
    ]);
    await _loadAdminLogs(reset: true);
    await _loadSystemLogs(reset: true);
    setState(() => _isLoading = false);
  }

  Future<void> _loadDashboard() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/admin/dashboard'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _dashboardData = data['data'] ?? {});
      }
    } catch (e) {
      print('Ошибка загрузки дашборда: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/admin/users?per_page=20'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _users = data['data']['users'] ?? []);
      }
    } catch (e) {
      print('Ошибка загрузки пользователей: $e');
    }
  }

  Future<void> _loadBanners() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/admin/content/banners'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _banners = data['data'] ?? []);
      }
    } catch (e) {
      print('Ошибка загрузки баннеров: $e');
    }
  }

  Future<void> _loadNews() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/admin/content/news'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _news = data['data'] ?? []);
      }
    } catch (e) {
      print('Ошибка загрузки новостей: $e');
    }
  }

  Future<void> _loadGames() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/admin/multiplayer/recent-games?limit=50'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _games = data['data'] ?? []);
      }
    } catch (e) {
      print('Ошибка загрузки игр: $e');
    }
  }

  Future<void> _loadAdminLogs({bool reset = false, int page = 1}) async {
    if (_isLoadingAdminLogs) return;
    if (reset) {
      _adminLogsPage = 1;
      _adminLogs = [];
      _hasMoreAdminLogs = true;
    }
    if (!_hasMoreAdminLogs) return;

    setState(() => _isLoadingAdminLogs = true);

    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/admin/logs/admin?page=$page&per_page=30'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newLogs = data['data'] ?? [];
        setState(() {
          if (reset) {
            _adminLogs = newLogs;
          } else {
            _adminLogs.addAll(newLogs);
          }
          _adminLogsPage = page;
          _hasMoreAdminLogs = newLogs.length >= 30;
          _isLoadingAdminLogs = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки админ-логов: $e');
      setState(() => _isLoadingAdminLogs = false);
    }
  }

  Future<void> _loadSystemLogs({bool reset = false, int page = 1}) async {
    if (_isLoadingSystemLogs) return;
    if (reset) {
      _systemLogsPage = 1;
      _systemLogs = [];
      _hasMoreSystemLogs = true;
    }
    if (!_hasMoreSystemLogs) return;

    setState(() => _isLoadingSystemLogs = true);

    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/admin/logs/system?page=$page&per_page=30'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newLogs = data['data'] ?? [];
        setState(() {
          if (reset) {
            _systemLogs = newLogs;
          } else {
            _systemLogs.addAll(newLogs);
          }
          _systemLogsPage = page;
          _hasMoreSystemLogs = newLogs.length >= 30;
          _isLoadingSystemLogs = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки системных логов: $e');
      setState(() => _isLoadingSystemLogs = false);
    }
  }

  Future<void> _loadLogsStats() async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.get(
        Uri.parse('https://edupeak.ru/api/admin/logs/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _logsStats = data['data'] ?? {});
      }
    } catch (e) {
      print('Ошибка загрузки статистики логов: $e');
    }
  }

  Future<void> _toggleAdmin(int userId, bool isAdmin) async {
    try {
      final token = await _getToken();
      if (token == null) return;
      final response = await http.put(
        Uri.parse('https://edupeak.ru/api/admin/users/$userId/admin'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        await _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Статус администратора изменён')),
          );
        }
      }
    } catch (e) {
      print('Ошибка: $e');
    }
  }

  Future<void> _deleteUser(int userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить пользователя'),
        content: Text('Вы уверены, что хотите удалить пользователя "$userName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await _getToken();
        if (token == null) return;
        final response = await http.delete(
          Uri.parse('https://edupeak.ru/api/admin/users/$userId'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          await _loadUsers();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Пользователь удалён')),
            );
          }
        }
      } catch (e) {
        print('Ошибка: $e');
      }
    }
  }

  // ==================== ЗАГРУЗКА ИЗОБРАЖЕНИЙ ====================

  Future<void> _pickImageForNews() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedNewsImage = File(pickedFile.path);
        });

        await _uploadNewsImage(_selectedNewsImage!);
      }
    } catch (e) {
      print('Ошибка выбора изображения: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка выбора изображения')),
        );
      }
    }
  }

  Future<void> _pickImageForBanner() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedBannerImage = File(pickedFile.path);
        });

        await _uploadBannerImage(_selectedBannerImage!);
      }
    } catch (e) {
      print('Ошибка выбора изображения: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка выбора изображения')),
        );
      }
    }
  }

  Future<void> _uploadNewsImage(File imageFile) async {
    setState(() => _isUploadingImage = true);

    try {
      final token = await _getToken();
      if (token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://edupeak.ru/api/admin/upload/news-image'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: 'news_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final imageUrl = data['url'];

        setState(() {
          _newsImageUrlController.text = imageUrl;
          _isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Изображение загружено!')),
          );
        }
      } else {
        throw Exception('Ошибка загрузки');
      }
    } catch (e) {
      print('Ошибка загрузки изображения: $e');
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
  }

  Future<void> _uploadBannerImage(File imageFile) async {
    setState(() => _isUploadingImage = true);

    try {
      final token = await _getToken();
      if (token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://edupeak.ru/api/admin/upload/banner-image'),  // ← правильный URL
      );

      request.headers['Authorization'] = 'Bearer $token';

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final imageUrl = data['url'];

        setState(() {
          _bannerImageUrlController.text = imageUrl;
          _isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Изображение загружено!')),
          );
        }
      } else {
        throw Exception('Ошибка загрузки');
      }
    } catch (e) {
      print('Ошибка загрузки изображения: $e');
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
  }

  // ==================== БАННЕРЫ ====================

  Future<void> _createBanner() async {
    if (_bannerTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите заголовок баннера')),
      );
      return;
    }

    setState(() => _isAddingBanner = true);

    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('https://edupeak.ru/api/admin/content/banners'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _bannerTitleController.text.trim(),
          'description': _bannerDescriptionController.text.trim(),
          'image_url': _bannerImageUrlController.text.trim().isEmpty ? null : _bannerImageUrlController.text.trim(),
          'action_type': _bannerActionTypeController.text.trim().isEmpty ? 'screen' : _bannerActionTypeController.text.trim(),
          'action_value': _bannerActionValueController.text.trim().isEmpty ? null : _bannerActionValueController.text.trim(),
          'order': _banners.length + 1,
          'is_active': true,
        }),
      );

      if (response.statusCode == 201) {
        _bannerTitleController.clear();
        _bannerDescriptionController.clear();
        _bannerImageUrlController.clear();
        _bannerActionTypeController.clear();
        _bannerActionValueController.clear();
        setState(() => _selectedBannerImage = null);

        await _loadBanners();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Баннер создан!')),
          );
        }
      }
    } catch (e) {
      print('Ошибка создания баннера: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      setState(() => _isAddingBanner = false);
    }
  }

  Future<void> _deleteBanner(int bannerId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить баннер'),
        content: Text('Вы уверены, что хотите удалить баннер "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await _getToken();
        if (token == null) return;
        final response = await http.delete(
          Uri.parse('https://edupeak.ru/api/admin/content/banners/$bannerId'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          await _loadBanners();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Баннер удалён')),
            );
          }
        }
      } catch (e) {
        print('Ошибка удаления баннера: $e');
      }
    }
  }

  // ==================== НОВОСТИ ====================

  Future<void> _createNews() async {
    if (_newsTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите заголовок новости')),
      );
      return;
    }

    setState(() => _isAddingNews = true);

    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('https://edupeak.ru/api/admin/content/news'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _newsTitleController.text.trim(),
          'description': _newsDescriptionController.text.trim(),
          'content': _newsContentController.text.trim().isEmpty
              ? _newsDescriptionController.text.trim()
              : _newsContentController.text.trim(),
          'category': _newsCategoryController.text.trim().isEmpty ? 'Обновления' : _newsCategoryController.text.trim(),
          'image_url': _newsImageUrlController.text.trim().isEmpty ? null : _newsImageUrlController.text.trim(),
          'is_active': true,
          'is_pinned': false,
        }),
      );

      if (response.statusCode == 201) {
        _newsTitleController.clear();
        _newsDescriptionController.clear();
        _newsContentController.clear();
        _newsCategoryController.clear();
        _newsImageUrlController.clear();
        setState(() => _selectedNewsImage = null);

        await _loadNews();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Новость создана!')),
          );
        }
      }
    } catch (e) {
      print('Ошибка создания новости: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      setState(() => _isAddingNews = false);
    }
  }

  Future<void> _updateNews(int newsId, Map<String, dynamic> currentNews) async {
    final titleController = TextEditingController(text: currentNews['title']);
    final descriptionController = TextEditingController(text: currentNews['description']);
    final contentController = TextEditingController(text: currentNews['content'] ?? currentNews['description']);
    final categoryController = TextEditingController(text: currentNews['category'] ?? 'Обновления');
    final imageUrlController = TextEditingController(text: currentNews['image_url'] ?? '');

    bool isUpdating = false;
    File? selectedImage;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.orange, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Редактировать новость',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: Theme.of(context).hintColor),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Заголовок *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Краткое описание *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: contentController,
                          decoration: InputDecoration(
                            labelText: 'Полный текст',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: categoryController,
                          decoration: InputDecoration(
                            labelText: 'Категория',
                            hintText: 'Обновления, Новости, События...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Поле для изображения с кнопкой выбора
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: imageUrlController,
                                decoration: InputDecoration(
                                  labelText: 'URL изображения',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.photo_library_rounded, color: Colors.blue),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1024,
                                    maxHeight: 1024,
                                    imageQuality: 80,
                                  );
                                  if (pickedFile != null) {
                                    selectedImage = File(pickedFile.path);
                                    setModalState(() {});
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        if (selectedImage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Новое изображение выбрано (будет загружено при сохранении)',
                            style: TextStyle(fontSize: 11, color: Colors.green),
                          ),
                        ],

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isUpdating ? null : () async {
                              setModalState(() => isUpdating = true);

                              try {
                                String? imageUrl = imageUrlController.text.trim();

                                // Загружаем новое изображение если выбрано
                                if (selectedImage != null) {
                                  setModalState(() => _isUploadingImage = true);

                                  final token = await _getToken();
                                  if (token != null) {
                                    final request = http.MultipartRequest(
                                      'POST',
                                      Uri.parse('https://edupeak.ru/api/admin/upload/news-image'),  // ← правильный URL
                                    );
                                    request.headers['Authorization'] = 'Bearer $token';

                                    final stream = http.ByteStream(selectedImage!.openRead());
                                    final length = await selectedImage!.length();

                                    final multipartFile = http.MultipartFile(
                                      'image',
                                      stream,
                                      length,
                                      filename: 'news_${DateTime.now().millisecondsSinceEpoch}.jpg',
                                      contentType: MediaType('image', 'jpeg'),
                                    );

                                    request.files.add(multipartFile);

                                    final response = await request.send();
                                    final responseBody = await response.stream.bytesToString();

                                    if (response.statusCode == 200) {
                                      final data = jsonDecode(responseBody);
                                      imageUrl = data['url'];
                                    }
                                  }
                                  setModalState(() => _isUploadingImage = false);
                                }

                                final token = await _getToken();
                                if (token == null) return;

                                final response = await http.put(
                                  Uri.parse('https://edupeak.ru/api/admin/content/news/$newsId'),
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({
                                    'title': titleController.text.trim(),
                                    'description': descriptionController.text.trim(),
                                    'content': contentController.text.trim().isEmpty
                                        ? descriptionController.text.trim()
                                        : contentController.text.trim(),
                                    'category': categoryController.text.trim().isEmpty ? 'Обновления' : categoryController.text.trim(),
                                    'image_url': imageUrl == null || imageUrl.isEmpty ? null : imageUrl,
                                    'is_active': true,
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  await _loadNews();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Новость обновлена!')),
                                    );
                                    Navigator.pop(context, true);
                                  }
                                } else {
                                  throw Exception('Ошибка обновления');
                                }
                              } catch (e) {
                                print('Ошибка обновления новости: $e');
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ошибка: $e')),
                                  );
                                }
                                setModalState(() => isUpdating = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: isUpdating || _isUploadingImage
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text('Сохранить изменения'),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (result == true) {
      await _loadNews();
    }
  }

  Future<void> _deleteNews(int newsId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить новость'),
        content: Text('Вы уверены, что хотите удалить новость "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await _getToken();
        if (token == null) return;
        final response = await http.delete(
          Uri.parse('https://edupeak.ru/api/admin/content/news/$newsId'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          await _loadNews();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Новость удалена')),
            );
          }
        }
      } catch (e) {
        print('Ошибка удаления новости: $e');
      }
    }
  }

  // ==================== ИГРЫ ====================

  Future<void> _cancelGame(int gameId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить игру'),
        content: const Text('Вы уверены, что хотите отменить эту игру?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Отменить', style: TextStyle(color: Colors.orange))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeletingGame = true);
      try {
        final token = await _getToken();
        if (token == null) return;

        final response = await http.put(
          Uri.parse('https://edupeak.ru/api/admin/multiplayer/games/$gameId/cancel'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          await http.post(
            Uri.parse('https://edupeak.ru/api/admin/multiplayer/cancel-all'),
            headers: {'Authorization': 'Bearer $token'},
          );
        }

        await _loadGames();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Игра отменена')),
          );
        }
      } catch (e) {
        print('Ошибка отмены игры: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: $e')),
          );
        }
      } finally {
        setState(() => _isDeletingGame = false);
      }
    }
  }

  // ==================== ДИАЛОГИ ====================

  void _showAddBannerDialog(ThemeData theme, bool isDark) {
    _bannerTitleController.clear();
    _bannerDescriptionController.clear();
    _bannerImageUrlController.clear();
    _bannerActionTypeController.clear();
    _bannerActionValueController.clear();
    setState(() => _selectedBannerImage = null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.hintColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Создать баннер',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: theme.hintColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _bannerTitleController,
                          decoration: InputDecoration(
                            labelText: 'Заголовок *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bannerDescriptionController,
                          decoration: InputDecoration(
                            labelText: 'Описание',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),

                        // Поле для изображения с кнопкой выбора
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _bannerImageUrlController,
                                decoration: InputDecoration(
                                  labelText: 'URL изображения',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.photo_library_rounded, color: Colors.blue),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1024,
                                    maxHeight: 1024,
                                    imageQuality: 80,
                                  );
                                  if (pickedFile != null) {
                                    setState(() => _selectedBannerImage = File(pickedFile.path));
                                    await _uploadBannerImage(_selectedBannerImage!);
                                    setModalState(() {});
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        if (_selectedBannerImage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_selectedBannerImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        TextField(
                          controller: _bannerActionTypeController,
                          decoration: InputDecoration(
                            labelText: 'Тип действия (screen/url/none)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _bannerActionValueController,
                          decoration: InputDecoration(
                            labelText: 'Значение действия',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isAddingBanner ? null : () async {
                              await _createBanner();
                              if (mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isAddingBanner
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text('Создать баннер'),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddNewsDialog(ThemeData theme, bool isDark) {
    _newsTitleController.clear();
    _newsDescriptionController.clear();
    _newsContentController.clear();
    _newsCategoryController.clear();
    _newsImageUrlController.clear();
    setState(() => _selectedNewsImage = null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.hintColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.green, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Создать новость',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: theme.hintColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        TextField(
                          controller: _newsTitleController,
                          decoration: InputDecoration(
                            labelText: 'Заголовок *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _newsDescriptionController,
                          decoration: InputDecoration(
                            labelText: 'Краткое описание *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _newsContentController,
                          decoration: InputDecoration(
                            labelText: 'Полный текст',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _newsCategoryController,
                          decoration: InputDecoration(
                            labelText: 'Категория',
                            hintText: 'Обновления, Новости, События...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Поле для изображения с кнопкой выбора
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newsImageUrlController,
                                decoration: InputDecoration(
                                  labelText: 'URL изображения',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.photo_library_rounded, color: Colors.green),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    maxWidth: 1024,
                                    maxHeight: 1024,
                                    imageQuality: 80,
                                  );
                                  if (pickedFile != null) {
                                    setState(() => _selectedNewsImage = File(pickedFile.path));
                                    await _uploadNewsImage(_selectedNewsImage!);
                                    setModalState(() {});
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        if (_selectedNewsImage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(_selectedNewsImage!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Изображение загружено',
                            style: TextStyle(fontSize: 11, color: Colors.green),
                          ),
                        ],

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isAddingNews ? null : () async {
                              await _createNews();
                              if (mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isAddingNews
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text('Создать новость'),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAdminLogsDialog(ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.hintColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.history_rounded, color: Colors.blue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Действия администраторов',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: theme.hintColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _adminLogs.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 64, color: theme.hintColor),
                        const SizedBox(height: 16),
                        Text('Нет действий', style: TextStyle(color: theme.hintColor)),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _adminLogs.length,
                    itemBuilder: (context, index) {
                      final log = _adminLogs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor.withOpacity(0.7) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.admin_panel_settings_rounded, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  log['admin_name'] ?? 'Unknown',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color),
                                ),
                                const Spacer(),
                                Text(
                                  log['created_at_human'] ?? '',
                                  style: TextStyle(fontSize: 11, color: theme.hintColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Действие: ${log['action'] ?? 'unknown'}',
                              style: TextStyle(fontSize: 13, color: theme.hintColor),
                            ),
                            if (log['target_type'] != null)
                              Text(
                                'Цель: ${log['target_type']} #${log['target_id']}',
                                style: TextStyle(fontSize: 12, color: theme.hintColor),
                              ),
                            if (log['ip_address'] != null)
                              Text(
                                'IP: ${log['ip_address']}',
                                style: TextStyle(fontSize: 11, color: theme.hintColor),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSystemLogsDialog(ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.hintColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.bug_report_rounded, color: Colors.red, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Системные логи',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: theme.hintColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _systemLogs.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bug_report_rounded, size: 64, color: theme.hintColor),
                        const SizedBox(height: 16),
                        Text('Нет системных логов', style: TextStyle(color: theme.hintColor)),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _systemLogs.length,
                    itemBuilder: (context, index) {
                      final log = _systemLogs[index];
                      Color levelColor = Colors.grey;
                      switch (log['level']) {
                        case 'error': levelColor = Colors.red; break;
                        case 'warning': levelColor = Colors.orange; break;
                        case 'info': levelColor = Colors.blue; break;
                        case 'debug': levelColor = Colors.green; break;
                      }
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? theme.cardColor.withOpacity(0.7) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: levelColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: levelColor),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  log['level']?.toUpperCase() ?? 'INFO',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: levelColor, fontSize: 12),
                                ),
                                const Spacer(),
                                Text(
                                  log['created_at'] != null
                                      ? DateTime.parse(log['created_at']).toString().substring(0, 19)
                                      : '',
                                  style: TextStyle(fontSize: 10, color: theme.hintColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              log['message'] ?? '',
                              style: TextStyle(fontSize: 13, color: theme.textTheme.titleMedium?.color),
                            ),
                            if (log['channel'] != null)
                              Text(
                                'Канал: ${log['channel']}',
                                style: TextStyle(fontSize: 11, color: theme.hintColor),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

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
            stops: const [0.0, 0.3, 0.7],
          )
              : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.08),
              Colors.white.withOpacity(0.7),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Заголовок
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Раздел',
                          style: TextStyle(fontSize: 14, color: theme.hintColor),
                        ),
                        Text(
                          'Админ-панель',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close_rounded, color: primaryColor),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),

              // Табы
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _selectedTab == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTab = index),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getIconForTab(index), color: isSelected ? primaryColor : theme.hintColor, size: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tabNames[index],
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? primaryColor : theme.hintColor,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const Divider(height: 1),

              // Контент
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : IndexedStack(
                  index: _selectedTab,
                  children: [
                    _buildDashboardTab(theme, isDark),
                    _buildUsersTab(theme, isDark),
                    _buildGamesTab(theme, isDark),
                    _buildContentTab(theme, isDark),
                    _buildLogsTab(theme, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForTab(int index) {
    switch (index) {
      case 0: return Icons.dashboard_rounded;
      case 1: return Icons.people_rounded;
      case 2: return Icons.sports_esports_rounded;
      case 3: return Icons.newspaper_rounded;
      case 4: return Icons.history_rounded;
      default: return Icons.dashboard_rounded;
    }
  }

  Widget _buildDashboardTab(ThemeData theme, bool isDark) {
    final data = _dashboardData;
    final topUsers = data['top_users_by_xp'] as List? ?? [];
    final leagueDistribution = data['league_distribution'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildMetricCard('Пользователей', '${data['total_users'] ?? 0}', Icons.people_rounded, Colors.blue, theme, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Завершённых тем', '${data['completed_topics'] ?? 0}', Icons.check_circle_rounded, Colors.green, theme, isDark)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMetricCard('Новых за неделю', '${data['new_this_week'] ?? 0}', Icons.person_add_rounded, Colors.orange, theme, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildMetricCard('Активных сегодня', '${data['active_today'] ?? 0}', Icons.trending_up_rounded, Colors.purple, theme, isDark)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Топ пользователей по XP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
          const SizedBox(height: 12),
          for (int i = 0; i < topUsers.length; i++) _buildTopUserTile(topUsers[i], i, theme, isDark),
          const SizedBox(height: 24),
          Text('Распределение по лигам', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
          const SizedBox(height: 12),
          for (var league in leagueDistribution) _buildLeagueTile(league, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildUsersTab(ThemeData theme, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.1 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: user['avatar'] != null
                    ? ClipOval(child: Image.network(user['avatar'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.person, color: theme.colorScheme.primary)))
                    : Icon(Icons.person, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['name'] ?? 'Unknown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                    const SizedBox(height: 4),
                    Text(user['email'] ?? '', style: TextStyle(fontSize: 12, color: theme.hintColor)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: user['is_admin'] == true ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(user['is_admin'] == true ? 'Админ' : 'Пользователь', style: TextStyle(fontSize: 10, color: user['is_admin'] == true ? Colors.red : Colors.green)),
                        ),
                        const SizedBox(width: 8),
                        Text('${user['total_xp'] ?? 0} XP', style: TextStyle(fontSize: 12, color: theme.hintColor)),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(user['is_admin'] == true ? Icons.admin_panel_settings : Icons.person_outline, size: 20),
                    color: Colors.orange,
                    onPressed: () => _toggleAdmin(user['id'], user['is_admin']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red,
                    onPressed: () => _deleteUser(user['id'], user['name']),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGamesTab(ThemeData theme, bool isDark) {
    if (_games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports_rounded, size: 64, color: theme.hintColor),
            const SizedBox(height: 16),
            Text('Нет игр', style: TextStyle(color: theme.hintColor)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final game = _games[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.sports_esports_rounded, color: Colors.purple),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Игра #${game['id']}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: _getStatusColor(game['status']).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text(game['status'] ?? 'unknown', style: TextStyle(fontSize: 11, color: _getStatusColor(game['status']))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Предмет: ${game['subject'] ?? 'unknown'}', style: TextStyle(fontSize: 13, color: theme.hintColor)),
                    Text('Игроков: ${game['players_count'] ?? 0}/${game['max_players'] ?? 0}', style: TextStyle(fontSize: 13, color: theme.hintColor)),
                  ],
                ),
              ),
              if (game['status'] == 'waiting' || game['status'] == 'in_progress')
                IconButton(
                  icon: const Icon(Icons.cancel_rounded, color: Colors.orange),
                  onPressed: () => _cancelGame(game['id']),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContentTab(ThemeData theme, bool isDark) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [Tab(text: 'Баннеры'), Tab(text: 'Новости')],
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            dividerColor: Colors.transparent,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBannersList(theme, isDark),
                _buildNewsList(theme, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannersList(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddBannerDialog(theme, isDark),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить баннер'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        Expanded(
          child: _banners.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_rounded, size: 64, color: theme.hintColor),
                const SizedBox(height: 16),
                Text('Нет баннеров', style: TextStyle(color: theme.hintColor)),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.photo_library_rounded, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  banner['title'] ?? 'Без названия',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: banner['is_active'] == true ? Colors.green : Colors.red),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner['description'] ?? '',
                            style: TextStyle(fontSize: 12, color: theme.hintColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteBanner(banner['id'], banner['title']),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsList(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddNewsDialog(theme, isDark),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Добавить новость'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
        ),
        Expanded(
          child: _news.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.newspaper_rounded, size: 64, color: theme.hintColor),
                const SizedBox(height: 16),
                Text('Нет новостей', style: TextStyle(color: theme.hintColor)),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _news.length,
            itemBuilder: (context, index) {
              final news = _news[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: news['image_url'] != null && news['image_url'].toString().isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(news['image_url'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.newspaper_rounded, color: Colors.green)),
                      )
                          : Icon(Icons.newspaper_rounded, color: Colors.green),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  news['title'] ?? 'Без названия',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color),
                                ),
                              ),
                              if (news['is_pinned'] == true)
                                Icon(Icons.push_pin, size: 16, color: Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            news['description'] ?? '',
                            style: TextStyle(fontSize: 12, color: theme.hintColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            news['category'] ?? 'Обновления',
                            style: TextStyle(fontSize: 10, color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                      onPressed: () => _updateNews(news['id'], news),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteNews(news['id'], news['title']),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLogsTab(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetricCard('Всего админ-логов', '${_logsStats['total_admin_logs'] ?? 0}', Icons.history_rounded, Colors.blue, theme, isDark),
          const SizedBox(height: 12),
          _buildMetricCard('Всего системных логов', '${_logsStats['total_system_logs'] ?? 0}', Icons.bug_report_rounded, Colors.red, theme, isDark),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAdminLogsDialog(theme, isDark),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Действия админов'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSystemLogsDialog(theme, isDark),
                  icon: const Icon(Icons.bug_report_rounded),
                  label: const Text('Системные логи'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: theme.hintColor)),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.titleMedium?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopUserTile(dynamic user, int index, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
            child: Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(user['name'] ?? 'Unknown', style: TextStyle(color: theme.textTheme.titleMedium?.color))),
          Text('${user['total_xp']} XP', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLeagueTile(dynamic league, ThemeData theme, bool isDark) {
    final percentage = league['percentage'] ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(league['name'] ?? '', style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[300],
              color: _getLeagueColor(league['name']),
            ),
          ),
          const SizedBox(width: 12),
          Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text('(${league['count']})', style: TextStyle(color: theme.hintColor)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'waiting': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'finished': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color _getLeagueColor(String? league) {
    switch (league) {
      case 'Бронзовая': return const Color(0xFFCD7F32);
      case 'Серебряная': return const Color(0xFFC0C0C0);
      case 'Золотая': return const Color(0xFFFFD700);
      case 'Платиновая': return const Color(0xFFE5E4E2);
      case 'Бриллиантовая': return const Color(0xFFB9F2FF);
      case 'Элитная': return const Color(0xFF7F7F7F);
      case 'Легендарная': return const Color(0xFFFF4500);
      case 'Нереальная': return const Color(0xFFE6E6FA);
      default: return Colors.grey;
    }
  }
}