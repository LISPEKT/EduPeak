import 'package:flutter/material.dart';
import '../localization.dart';
import '../data/dictionary.dart';

class DictionaryScreen extends StatefulWidget {
  final Function(int) onBottomNavTap;
  final int currentIndex;

  const DictionaryScreen({
    Key? key,
    required this.onBottomNavTap,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  List<DictionaryTerm> _filteredTerms = dictionaryTerms;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  Set<String> _favorites = {};
  Map<String, bool> _categoryExpandedState = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _filterTerms(_searchController.text);
    });

    // Инициализируем состояние раскрытия категорий
    _initializeCategories();
  }

  void _initializeCategories() {
    final categories = Set<String>.from(dictionaryTerms.map((e) => e.category));
    for (final category in categories) {
      _categoryExpandedState[category] = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTerms(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredTerms = dictionaryTerms;
      });
    } else {
      final searchQuery = query.toLowerCase();
      setState(() {
        _isSearching = true;
        _filteredTerms = dictionaryTerms.where((term) {
          return term.term.toLowerCase().contains(searchQuery) ||
              term.definition.toLowerCase().contains(searchQuery) ||
              term.category.toLowerCase().contains(searchQuery);
        }).toList();
      });
    }
  }

  void _toggleFavorite(String termId) {
    setState(() {
      if (_favorites.contains(termId)) {
        _favorites.remove(termId);
      } else {
        _favorites.add(termId);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = false;
      _filteredTerms = dictionaryTerms;
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      _categoryExpandedState[category] =
      !(_categoryExpandedState[category] ?? false);
    });
  }

  Map<String, List<DictionaryTerm>> _getTermsByCategory(
      List<DictionaryTerm> terms) {
    final map = <String, List<DictionaryTerm>>{};
    for (final term in terms) {
      if (!map.containsKey(term.category)) {
        map[term.category] = [];
      }
      map[term.category]!.add(term);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;

    final termsByCategory = _getTermsByCategory(_filteredTerms);
    final categories = termsByCategory.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
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
                  // Заголовок
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                              appLocalizations.dictionary,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleMedium?.color,
                              ),
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
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(
                              _favorites.isNotEmpty
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: _favorites.isNotEmpty
                                  ? Colors.amber
                                  : primaryColor,
                            ),
                            onPressed: () {
                              _showFavoritesDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Поле поиска
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _filterTerms(value);
                      },
                      decoration: InputDecoration(
                        hintText: appLocalizations.searchTerm,
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
                          fontSize: 15,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.search_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                            size: 22,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: surfaceVariant.withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon:
                          Icon(Icons.clear_rounded, color: theme.hintColor),
                          onPressed: _clearSearch,
                        )
                            : null,
                      ),
                    ),
                  ),

                  // Заголовок результатов
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Text(
                      _isSearching
                          ? appLocalizations.searchResults
                          : appLocalizations.allTerms,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ),

                  // Список терминов по категориям
                  Expanded(
                    child: _filteredTerms.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: theme.hintColor,
                          ),
                          SizedBox(height: 16),
                          Text(
                            appLocalizations.noResults,
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    )
                        : ListView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 8,
                        bottom: 100, // ДОБАВЛЕН ОТСТУП СНИЗУ
                      ),
                      children: categories.map((category) {
                        final categoryTerms = termsByCategory[category]!;
                        final isExpanded =
                            _categoryExpandedState[category] ?? false;
                        final categoryColor = getCategoryColor(category);

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(isDark ? 0.1 : 0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Заголовок категории
                              GestureDetector(
                                onTap: () => _toggleCategory(category),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: isExpanded
                                          ? Radius.zero
                                          : Radius.circular(20),
                                      bottomRight: isExpanded
                                          ? Radius.zero
                                          : Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                          categoryColor.withOpacity(0.2),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.category_rounded,
                                          color: categoryColor,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: theme
                                                .textTheme.titleMedium?.color,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${categoryTerms.length}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: categoryColor,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons
                                            .keyboard_arrow_down_rounded,
                                        color: categoryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Список терминов в категории
                              if (isExpanded)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    children: categoryTerms.map((term) {
                                      final isFavorite =
                                      _favorites.contains(term.id);
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            onTap: () {
                                              _showTermDetail(term);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? theme.cardColor
                                                    .withOpacity(0.7)
                                                    : Colors.grey[50],
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        Text(
                                                          term.term,
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                            FontWeight
                                                                .w600,
                                                            color: theme
                                                                .textTheme
                                                                .titleMedium
                                                                ?.color,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          term.definition,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: theme
                                                                .hintColor,
                                                          ),
                                                          maxLines: 2,
                                                          overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  IconButton(
                                                    icon: Icon(
                                                      isFavorite
                                                          ? Icons
                                                          .star_rounded
                                                          : Icons
                                                          .star_border_rounded,
                                                      color: isFavorite
                                                          ? Colors.amber
                                                          : categoryColor,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      _toggleFavorite(
                                                          term.id);
                                                    },
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                    BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BottomNavigationBar как в main_screen
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _buildBottomNavigationBar(
                theme, isDark, appLocalizations),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(
      ThemeData theme, bool isDark, AppLocalizations appLocalizations) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBottomNavItem(
            index: 0,
            icon: Icons.home_rounded,
            label: appLocalizations.home,
            isDark: isDark,
          ),
          _buildBottomNavItem(
            index: 1,
            icon: Icons.refresh_rounded,
            label: appLocalizations.review,
            isDark: isDark,
          ),
          _buildBottomNavItem(
            index: 2,
            icon: Icons.book_rounded,
            label: appLocalizations.dictionary,
            isDark: isDark,
          ),
          _buildBottomNavItem(
            index: 3,
            icon: Icons.star_rounded,
            label: appLocalizations.premium,
            isDark: isDark,
          ),
          _buildBottomNavItem(
            index: 4,
            icon: Icons.person_rounded,
            label: appLocalizations.profile,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = index == widget.currentIndex;
    final inactiveColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final textColor = isSelected ? Colors.white : inactiveColor;
    final iconColor = isSelected ? Colors.white : inactiveColor;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onBottomNavTap(index),
          borderRadius: BorderRadius.circular(35),
          child: Container(
            height: 70,
            margin: EdgeInsets.all(isSelected ? 4 : 0),
            decoration: isSelected
                ? BoxDecoration(
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
                SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }

  void _showTermDetail(DictionaryTerm term) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFavorite = _favorites.contains(term.id);
    final categoryColor = getCategoryColor(term.category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6, // Уменьшил высоту
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Хэндл для перетаскивания
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.hintColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Заголовок
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        term.category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: isFavorite ? Colors.amber : theme.hintColor,
                        size: 24,
                      ),
                      onPressed: () {
                        _toggleFavorite(term.id);
                        Navigator.pop(context);
                      },
                    ),
                    // Кнопка поделиться удалена
                  ],
                ),
              ),

              // Термин
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  term.term,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color,
                  ),
                ),
              ),

              // Контент
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Определение
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).definition,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.cardColor.withOpacity(0.7)
                                  : categoryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: categoryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              term.definition,
                              style: TextStyle(
                                fontSize: 15,
                                color: theme.textTheme.bodyMedium?.color,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24),

                      // Пример использования удален

                      // Связанные термины удалены

                      // Дата добавления
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).addedDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                          Text(
                            term.addedDate,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFavoritesDialog() {
    final favoriteTerms = dictionaryTerms
        .where((term) => _favorites.contains(term.id))
        .toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Хэндл
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.hintColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Заголовок
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).favorites,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: theme.textTheme.titleMedium?.color,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${favoriteTerms.length} ${AppLocalizations.of(context).results}',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: theme.hintColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Список избранных терминов
              Expanded(
                child: favoriteTerms.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border_rounded,
                        size: 64,
                        color: theme.hintColor,
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).noFavorites,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.hintColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Добавьте термины в избранное, нажав на звездочку',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: favoriteTerms.length,
                  itemBuilder: (context, index) {
                    final term = favoriteTerms[index];
                    final categoryColor = getCategoryColor(term.category);

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? theme.cardColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(isDark ? 0.1 : 0.05),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.pop(context);
                            _showTermDetail(term);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:
                                    categoryColor.withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.book_rounded,
                                    color: categoryColor,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        term.term,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: theme.textTheme
                                              .titleMedium?.color,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        term.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: categoryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: theme.hintColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}