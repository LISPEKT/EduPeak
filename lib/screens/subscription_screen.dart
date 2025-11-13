import 'package:flutter/material.dart';
import '../localization.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'EduPeak+',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero секция
            _buildHeroSection(context, appLocalizations),

            const SizedBox(height: 32),

            // Список преимуществ
            _buildFeaturesSection(context, appLocalizations),

            const SizedBox(height: 32),

            // Цены и кнопка
            _buildPricingSection(context, appLocalizations),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, AppLocalizations appLocalizations) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        child: Column(
          children: [
            // Иконка и заголовок
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'EduPeak+',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              appLocalizations.premiumSubscription,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, AppLocalizations appLocalizations) {
    final features = [
      _Feature(
        icon: Icons.offline_bolt_rounded,
        title: appLocalizations.offlineMode,
        description: appLocalizations.studyWithoutInternet,
        color: Colors.blue,
      ),
      _Feature(
        icon: Icons.analytics_rounded,
        title: appLocalizations.advancedStatistics,
        description: appLocalizations.detailedProgressAnalytics,
        color: Colors.green,
      ),
      _Feature(
        icon: Icons.palette_rounded,
        title: appLocalizations.exclusiveThemes,
        description: appLocalizations.uniqueAppDesign,
        color: Colors.purple,
      ),
      _Feature(
        icon: Icons.support_agent_rounded,
        title: appLocalizations.prioritySupport,
        description: appLocalizations.fastAnswers,
        color: Colors.orange,
      ),
      _Feature(
        icon: Icons.workspace_premium_rounded,
        title: 'Без рекламы',
        description: 'Полностью сосредоточьтесь на обучении без отвлекающих элементов',
        color: Colors.red,
      ),
      _Feature(
        icon: Icons.cloud_download_rounded,
        title: 'Расширенные материалы',
        description: 'Дополнительные учебные материалы и тесты для углубленного изучения',
        color: Colors.teal,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Что включено в подписку',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Адаптивная сетка
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8, // Более квадратное соотношение
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return _AdaptiveGridFeatureCard(feature: feature);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingSection(BuildContext context, AppLocalizations appLocalizations) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Цены
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '299₽',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/месяц',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'или 2 990₽ за год (экономия 40%)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка подписки
            FilledButton(
              onPressed: () {
                _showSubscriptionDialog(context, appLocalizations);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(double.infinity, 54),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rocket_launch_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ПОПРОБОВАТЬ 7 ДНЕЙ БЕСПЛАТНО',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Затем 299₽ в месяц. Отменить можно в любой момент.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Гарантия возврата
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '14-дневная гарантия возврата',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context, AppLocalizations appLocalizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              Icons.construction_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Скоро будет доступно',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          appLocalizations.subscriptionDevelopment,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('ПОНЯТНО'),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _AdaptiveGridFeatureCard extends StatelessWidget {
  final _Feature feature;

  const _AdaptiveGridFeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                feature.icon,
                color: feature.color,
                size: 20,
              ),
            ),

            const SizedBox(height: 12),

            // Заголовок
            Text(
              feature.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // Описание - занимает все доступное пространство
            Expanded(
              child: Text(
                feature.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  height: 1.3,
                ),
                maxLines: 4, // Ограничиваем максимум 4 строки
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                feature.icon,
                color: feature.color,
                size: 20,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              feature.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            Text(
              feature.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}