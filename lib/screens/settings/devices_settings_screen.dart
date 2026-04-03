// lib/screens/settings/devices_settings_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../localization.dart';

class DevicesSettingsScreen extends StatefulWidget {
  const DevicesSettingsScreen({Key? key}) : super(key: key);

  @override
  State<DevicesSettingsScreen> createState() => _DevicesSettingsScreenState();
}

class _DevicesSettingsScreenState extends State<DevicesSettingsScreen> {
  final List<Map<String, dynamic>> _sessions = [
    {
      'name': 'Это устройство',
      'type': Platform.isAndroid ? 'Android' : (Platform.isIOS ? 'iOS' : 'Другое'),
      'location': 'Москва, Россия',
      'lastActive': 'Сейчас',
      'ip': '192.168.1.100',
      'isCurrent': true,
    },
    {
      'name': 'Chrome на Windows',
      'type': 'Браузер',
      'location': 'Москва, Россия',
      'lastActive': '2 часа назад',
      'ip': '95.73.82.144',
      'isCurrent': false,
    },
    {
      'name': 'Safari на iPhone',
      'type': 'Браузер',
      'location': 'Санкт-Петербург, Россия',
      'lastActive': 'Вчера',
      'ip': '91.122.45.67',
      'isCurrent': false,
    },
  ];

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
              // Верхняя панель
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
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
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: primaryColor,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appLocalizations.section,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            'Устройства',
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
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    // Текущее устройство
                    _buildDeviceCard(_sessions[0], isCurrent: true),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Другие устройства',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Остальные устройства
                    ..._sessions.skip(1).map((device) => _buildDeviceCard(device)),

                    const SizedBox(height: 20),

                    // Кнопка завершить все
                    OutlinedButton(
                      onPressed: () => _showConfirmDialog(
                        'Завершить все сессии',
                        'Вы уверены? Это завершит все сессии, кроме текущей.',
                            () => _showSuccess('Все сессии завершены'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Завершить все остальные'),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device, {bool isCurrent = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isCurrent
            ? Border.all(color: theme.colorScheme.primary, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (isCurrent ? theme.colorScheme.primary : Colors.teal).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                device['type'] == 'Браузер' ? Icons.language_rounded : Icons.phone_android_rounded,
                color: isCurrent ? theme.colorScheme.primary : Colors.teal,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        device['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                          color: isCurrent ? theme.colorScheme.primary : null,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Это устройство',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${device['type']} • ${device['location']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'IP: ${device['ip']} • Активно: ${device['lastActive']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.hintColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (!isCurrent)
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                onPressed: () => _showConfirmDialog(
                  'Завершить сессию',
                  'Завершить сессию на устройстве "${device['name']}"?',
                      () {
                    setState(() {
                      _sessions.remove(device);
                    });
                    _showSuccess('Сессия завершена');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}