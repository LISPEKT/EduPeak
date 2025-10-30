import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../data/user_data_storage.dart';
import '../localization.dart';

class SyncScreen extends StatefulWidget {
  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _isSyncing = false;
  Map<String, dynamic> _syncStatus = {};
  Map<String, dynamic> _lastSyncResult = {};

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    final status = await UserDataStorage.getSyncStatus();
    setState(() {
      _syncStatus = status;
    });
  }

  Future<void> _forceSync() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      final result = await UserDataStorage.forceSync();

      setState(() {
        _lastSyncResult = result;
      });

      await _loadSyncStatus();

      if (result['success'] == true) {
        _showSuccessMessage(result['message'] ?? AppLocalizations.of(context).syncCompleted);
      } else {
        _showErrorMessage(result['message'] ?? AppLocalizations.of(context).syncError);
      }

    } catch (e) {
      _showErrorMessage('${AppLocalizations.of(context).error}: $e');
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatTimeSinceLastSync() {
    final localizations = AppLocalizations.of(context);
    final timeSince = _syncStatus['timeSinceLastSync'];
    if (timeSince == null) return localizations.never;

    if (timeSince.inMinutes < 1) return localizations.justNow;
    if (timeSince.inMinutes < 60) return '${timeSince.inMinutes} ${localizations.minutesAgo}';
    if (timeSince.inHours < 24) return '${timeSince.inHours} ${localizations.hoursAgo}';
    return '${timeSince.inDays} ${localizations.daysAgo}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.dataSync),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.syncStatus,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _SyncStatusItem(
                      icon: Icons.sync,
                      label: '${localizations.lastSync}:',
                      value: _formatTimeSinceLastSync(),
                      color: _syncStatus['isRecent'] == true ? Colors.green : Colors.orange,
                    ),
                    SizedBox(height: 8),
                    _SyncStatusItem(
                      icon: Icons.cloud_done,
                      label: '${localizations.status}:',
                      value: _syncStatus['isRecent'] == true ? localizations.upToDate : localizations.syncRequired,
                      color: _syncStatus['isRecent'] == true ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            if (_lastSyncResult.isNotEmpty) ...[
              Card(
                color: _lastSyncResult['success'] == true
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _lastSyncResult['success'] == true
                                ? Icons.check_circle
                                : Icons.error,
                            color: _lastSyncResult['success'] == true
                                ? Colors.green
                                : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _lastSyncResult['success'] == true
                                ? localizations.syncSuccessful
                                : localizations.syncError,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _lastSyncResult['success'] == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        _lastSyncResult['message'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (_lastSyncResult['stats'] != null) ...[
                        SizedBox(height: 8),
                        Text(
                          localizations.syncedItems,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• ${_lastSyncResult['stats']['topics_synced']} ${localizations.topics}\n'
                              '• ${_lastSyncResult['stats']['xp_synced']} XP\n'
                              '• ${_lastSyncResult['stats']['streak_synced']} ${localizations.daysStreak}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSyncing ? null : _forceSync,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSyncing
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(localizations.syncing),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sync),
                    SizedBox(width: 8),
                    Text(localizations.syncNow),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.aboutSync,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _InfoItem(
                      icon: Icons.auto_mode,
                      text: localizations.autoSyncInfo,
                    ),
                    _InfoItem(
                      icon: Icons.merge,
                      text: localizations.conflictResolutionInfo,
                    ),
                    _InfoItem(
                      icon: Icons.cloud_off,
                      text: localizations.offlineSyncInfo,
                    ),
                    _InfoItem(
                      icon: Icons.security,
                      text: localizations.secureSyncInfo,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncStatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SyncStatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}