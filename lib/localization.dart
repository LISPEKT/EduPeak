import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'app_title': 'EduPeak',
      'welcome': 'Добро пожаловать',
      'start_learning': 'Начать обучение',
      'conquer_knowledge': 'Покоряй вершины знаний',
      'students': 'Учеников',
      'topics': 'Тем',
      'topicCompleted': 'Тема завершена',
      'experienceShort': 'XP',
      'success': 'Успех',
      'subjects': 'Предметов',
      'join_and_improve': 'Присоединяйтесь и прокачивайте свои мозги',
      'exam_preparation': 'Подготовка к ОГЭ/ЕГЭ • Олимпиадные задачи',
      'choose_language': 'Выберите язык',
      'russian': 'Русский (Русский) 🇷🇺',
      'english': 'Английский (English) 🇬🇧 ',
      'german': 'Немецкий (Deutsch) 🇩🇪',
      'login': 'Войти',
      'register': 'Зарегистрироваться',
      'settings': 'Настройки',
      'profile': 'Профиль',
      'statistics': 'Статистика',
      'subscription': 'Подписка',
      'logout': 'Выйти',
      'appearance': 'Внешний вид',
      'theme_applied_instantly': 'Тема применится мгновенно',
      'system_theme': 'Системная тема',
      'follow_system_settings': 'Следовать настройкам системы',
      'dark_theme': 'Тёмная тема',
      'always_use_dark_theme': 'Всегда использовать тёмную тему',
      'light_theme': 'Светлая тема',
      'always_use_light_theme': 'Всегда использовать светлую тему',
      'progress_management': 'Управление прогрессом',
      'reset_learning_progress': 'Сбросить прогресс обучения',
      'reset_progress_description': 'Сбросить весь прогресс обучения. Для подтверждения потребуется пароль.',
      'reset_progress_button': 'Сбросить прогресс обучения',
      'feedback': 'Обратная связь',
      'send_feedback_telegram': 'Отправить через Telegram',
      'send_telegram_button': 'Отправить через Telegram',
      'feedback_description': 'Отправьте ваш отзыв или предложение. Мы получим его мгновенно!',
      'feedback_hint': 'Напишите ваш отзыв, идею или сообщите об ошибке...',
      'about_app': 'О приложении',
      'version': 'Версия',
      'developer': 'Разработчик',
      'support': 'Поддержка',
      'build_date': 'Дата сборки',
      'account_logout': 'Выход из аккаунта',
      'logout_description': 'Завершите текущую сессию и выйдите из аккаунта',
      'language': 'Язык',
      'language_settings': 'Настройки языка',
      'select_app_language': 'Выберите язык приложения',
      'change_language_restart': 'Изменение языка потребует перезапуска приложения',
      'please_fill_all_fields': 'Заполните все поля',
      'enter_valid_email': 'Введите корректный email',
      'server_unavailable_check_connection': 'Сервер недоступен. Проверьте подключение к интернету.',
      'connection_error': 'Ошибка соединения',
      'login_error': 'Ошибка входа',
      'registration_error': 'Ошибка регистрации',
      'create_account': 'Создание аккаунта',
      'username': 'Имя пользователя',
      'password': 'Пароль',
      'confirm_password': 'Подтвердите пароль',
      'passwords_do_not_match': 'Пароли не совпадают',
      'password_min_length': 'Пароль должен содержать не менее 6 символов',
      'error': 'Ошибка',
      'loading': 'Загрузка...',
      'correct': 'Правильно',
      'incorrect': 'Неправильно',
      'your_answer': 'Ваш ответ',
      'correct_answer': 'Правильный ответ',
      'explanation': 'Объяснение',
      'continue_text': 'Продолжить',
      'finish_test': 'Завершить тест',
      'next_question': 'Следующий вопрос',
      'check_answer': 'Проверить ответ',
      'please_enter_answer': 'Пожалуйста, введите ответ',
      'please_select_answer': 'Пожалуйста, выберите ответ',
      'question': 'Вопрос',
      'test_results': 'Результаты теста',
      'correct_answers': 'правильно',
      'perfect_expert': 'Идеально! Ты настоящий эксперт!',
      'excellent_almost_all': 'Отлично! Ты почти все знаешь!',
      'good_work_continue': 'Хорошая работа! Продолжай в том же духе!',
      'not_bad_room_to_grow': 'Неплохо, но есть куда расти!',
      'dont_worry_try_again': 'Не расстраивайся! Попробуй еще раз!',
      'return_to_topics': 'Вернуться к темам',
      'retake_test': 'Пройти тест еще раз',
      'topic_description': 'Описание',
      'start_lesson': 'Начать занятие',
      'topic_explanation': 'Объяснение темы',
      'start_test': 'Начать тест',
      'hello': 'Привет',
      'start_lesson_text': 'Начни урок',
      'today_completed': 'Сегодня все сделал',
      'all_grades': 'Все классы',
      'search_topics': 'Поиск по темам...',
      'no_topics_found': 'Темы не найдены',
      'try_changing_search': 'Попробуйте изменить поисковый запрос',
      'edit_profile': 'Редактирование',
      'click_to_edit': 'Нажмите на фото для редактирования',
      'update_username': 'Обновить имя',
      'using_custom_photo': 'Используется загруженное фото',
      'using_default_avatar': 'Используется стандартный аватар',
      'days_streak': 'Дней подряд',
      'completed_topics': 'Пройдено тем',
      'correct_answers_count': 'Правильных ответов',
      'subject_progress': 'Прогресс по предметам',
      'no_completed_topics': 'Пока нет пройденных тем',
      'premium_features': 'Расширенные возможности',
      'learning_progress': 'Прогресс обучения',
      'app_settings': 'Настройки приложения',
      'enter_username': 'Введите имя пользователя',
      'username_updated': 'Имя пользователя обновлено!',
      'username_update_error': 'Ошибка обновления имени',
      'error_selecting_image': 'Ошибка при выборе изображения',
      'avatar_updated': 'Фото профиля обновлено',
      'avatar_update_error': 'Ошибка обновления аватара',
      'enter_answer': 'Введите ваш ответ...',
      'test_completed': 'Тест завершен',
      'correct_count': 'Правильных ответов',
      'percentage_correct': '% правильных ответов',
      'back_to_topics': 'Вернуться к темам',
      'topic': 'Тема',
      'grade_class': 'класс',
      'edit': 'Редактирование',
      'square_avatar': 'Квадратная аватарка 1:1',
      'adjust_crop': 'Настройте обрезку для идеальной аватарки',
      'edit_photo': 'Редактировать',
      'crop': 'Обрезка',
      'done': 'Готово',
      'cancel': 'Отмена',
      'back': 'Назад',
      'choose_auth_method': 'Выберите способ входа',
      'email': 'Email',
      'enter_email': 'Введите email',
      'enter_password': 'Введите пароль',
      'forgot_password': 'Забыли пароль?',
      'remember_me': 'Запомнить меня',
      'guest_mode': 'Гостевой режим',
      'continue_as_guest': 'Продолжить как гость',
      'select_language': 'Выберите язык',
      'language_changed': 'Язык изменен',
      'restart_required': 'Требуется перезапуск приложения',
      'enter_your_account': 'Войдите в свой аккаунт',
      'enter_credentials': 'Введите ваши учетные данные для входа',
      'no_account': 'Нет аккаунта?',
      'enter_email_and_password': 'Введите вашу почту и придумайте пароль',
      'premium_subscription': 'Премиум подписка',
      'offline_mode': 'Оффлайн режим',
      'study_without_internet': 'Изучайте темы без интернета',
      'advanced_statistics': 'Расширенная статистика',
      'detailed_progress_analytics': 'Подробная аналитика прогресса',
      'exclusive_themes': 'Эксклюзивные темы',
      'unique_app_design': 'Уникальный дизайн приложения',
      'priority_support': 'Приоритетная поддержка',
      'fast_answers': 'Быстрые ответы на вопросы',
      'subscribe_button': 'Оформить подписку - 299₽/мес',
      'subscription_development': 'Функция подписки в разработке',
      'days_in_row': 'Дней подряд',
      'completed_topics_count': 'Пройдено тем',
      'progress_by_subjects': 'Прогресс по предметам',
      'lesson_explanation': 'Объяснение темы',
      'start_lesson_button': 'Начать занятие',
      'start_test_button': 'Начать тест',
      'correctly': 'правильно',
      'excellent_knowledge': 'Отлично! Ты почти все знаешь!',
      'not_bad_grow': 'Неплохо, но есть куда расти!',
      'continue_next': 'Продолжить',
      'completing_test': 'Завершение теста...',
      'russian_language': 'Русский язык',
      'math': 'Математика',
      'algebra': 'Алгебра',
      'geometry': 'Геометрия',
      'english_language': 'Английский язык',
      'literature': 'Литература',
      'biology': 'Биология',
      'physics': 'Физика',
      'chemistry': 'Химия',
      'geography': 'География',
      'russian_history': 'История России',
      'world_history': 'Всеобщая история',
      'social_studies': 'Обществознание',
      'computer_science': 'Информатика',
      'statistics_probability': 'Статистика и вероятность',
      'of_text': 'из',
      'avatar_crop_title': 'Редактирование',
      'avatar_crop_subtitle': 'Настройте обрезку для идеальной аватарки',
      'edit_button': 'Редактировать',
      'crop_title': 'Обрезка',
      'saving': 'Сохранение...',
      'grade': 'Класс',
      'correct_answer_not_found': 'Правильный ответ не найден',
      'answer_load_error': 'Ошибка загрузки ответа',
      'question_not_found': 'Вопрос не найден',
      'no_answer': 'Нет ответа',
      'explanation_not_found': 'Объяснение не найдено',
      'selectSubject': 'Выбрать предмет',
      // Достижения
      'achievements': 'Достижения',
      'achievementProgress': 'Прогресс достижений',
      'achievementUnlocked': 'Достижение разблокировано!',
      'achievementDetails': 'Детали достижения',
      'unlocked': 'Разблокировано',
      'locked': 'Не получено',
      'progress': 'Прогресс',
      'totalAchievements': 'Всего достижений',
      'completedAchievements': 'Получено',
      'remainingAchievements': 'Осталось',
      'overallProgress': 'Прогресс',
      'completed': 'Выполнено',
      'retakeTestButton': 'Повторить тест',


      // Типы достижений
      'testsCompleted': 'Тесты пройдены',
      'streakDays': 'Дней подряд',
      'perfectTests': 'Идеальные тесты',
      'subjectsCompleted': 'Предметы завершены',
      'testsInOneDay': 'Тестов за день',
      'totalXP': 'Всего XP',
      'league': 'Лига',
      'correctAnswers': 'Правильные ответы',
      'dailyActivity': 'Ежедневная активность',
      'special': 'Специальные',

      // Друзья
      'friends': 'Друзья',
      'friendRequests': 'Запросы в друзья',
      'pendingRequests': 'Ожидающие запросы',
      'addFriend': 'Добавить друга',
      'removeFriend': 'Удалить из друзей',
      'acceptRequest': 'Принять запрос',
      'declineRequest': 'Отклонить запрос',
      'sendRequest': 'Отправить запрос',
      'searchUsers': 'Поиск пользователей',
      'enterUsername': 'Введите имя пользователя',
      'usersNotFound': 'Пользователи не найдены',
      'noFriends': 'У вас пока нет друзей',
      'findUsersAndAdd': 'Найдите пользователей и добавьте их в друзья',
      'noRequests': 'Нет запросов в друзья',
      'incomingRequests': 'Входящие запросы появятся здесь',
      'friendRequestSent': 'Запрос на дружбу отправлен пользователю @%s',
      'requestAccepted': 'Запрос принят',
      'requestDeclined': 'Запрос отклонен',
      'friendRemoved': 'Друг удален',

      // Статистика друзей
      'streak': 'Стрик',
      'completedTopics': 'Пройдено тем',
      'weeklyXP': 'XP за неделю',

      // Уведомления
      'requestFailed': 'Не удалось отправить запрос',
      'acceptFailed': 'Не удалось принять запрос',
      'declineFailed': 'Не удалось отклонить запрос',
      'removeFailed': 'Не удалось удалить друга',
      'searchError': 'Ошибка поиска пользователей',

      // Достижения - названия
      'firstStep': 'Первый шаг',
      'testMaster': 'Мастер тестов',
      'testExpert': 'Эксперт тестов',
      'testLegend': 'Легенда тестов',
      'journeyStart': 'Начало пути',
      'weekOfStrength': 'Неделя силы',
      'twoWeeks': 'Две недели',
      'monthOfDiscipline': 'Месяц дисциплины',
      'quarterChampion': 'Квартал чемпиона',
      'perfectionist': 'Перфекционист',
      'flawless': 'Безупречно',
      'perfectResult': 'Идеальный результат',
      'subjectExpert': 'Эксперт предмета',
      'subjectMaster': 'Мастер предметов',
      'grandmaster': 'Грандмастер',
      'fastLearner': 'Быстрый ученик',
      'marathoner': 'Марафонец',
      'dailyWarrior': 'Ежедневный воин',
      'knowledgeSeeker': 'Искатель знаний',
      'wisdomKeeper': 'Хранитель мудрости',
      'knowledgeMaster': 'Мастер знаний',
      'bronzeFighter': 'Бронзовый боец',
      'silverStrategist': 'Серебряный стратег',
      'goldChampion': 'Золотой чемпион',
      'platinumGenius': 'Платиновый гений',
      'diamondMaster': 'Бриллиантовый мастер',
      'accurateAnswer': 'Точный ответ',
      'erudite': 'Эрудит',
      'knowItAll': 'Всезнайка',
      'walkingEncyclopedia': 'Ходячая энциклопедия',
      'earlyBird': 'Ранняя пташка',
      'nightOwl': 'Ночная сова',
      'weekendWarrior': 'Воитель выходного дня',

      // Достижения - описания
      'completeFirstTest': 'Пройдите первый тест',
      'complete10Tests': 'Пройдите 10 тестов',
      'complete50Tests': 'Пройдите 50 тестов',
      'complete100Tests': 'Пройдите 100 тестов',
      'study3Days': 'Занимайтесь 3 дня подряд',
      'study7Days': 'Занимайтесь 7 дней подряд',
      'study14Days': 'Занимайтесь 14 дней подряд',
      'study30Days': 'Занимайтесь 30 дней подряд',
      'study90Days': 'Занимайтесь 90 дней подряд',
      'get100Percent': 'Получите 100% в тесте',
      'get100Percent5Tests': 'Получите 100% в 5 тестах',
      'get100Percent20Tests': 'Получите 100% в 20 тестах',
      'completeAllTopics': 'Завершите все темы по одному предмету',
      'completeAllTopics3Subjects': 'Завершите все темы по 3 предметам',
      'completeAllTopics5Subjects': 'Завершите все темы по 5 предметам',
      'complete5TestsDay': 'Пройдите 5 тестов за один день',
      'complete10TestsDay': 'Пройдите 10 тестов за один день',
      'studyEveryDayWeek': 'Занимайтесь каждый день в течение недели',
      'earn1000XP': 'Заработайте 1000 XP',
      'earn5000XP': 'Заработайте 5000 XP',
      'earn10000XP': 'Заработайте 10000 XP',
      'reachBronzeLeague': 'Достигните бронзовой лиги',
      'reachSilverLeague': 'Достигните серебряной лиги',
      'reachGoldLeague': 'Достигните золотой лиги',
      'reachPlatinumLeague': 'Достигните платиновой лиги',
      'reachDiamondLeague': 'Достигните бриллиантовой лиги',
      'give100Correct': 'Дайте 100 правильных ответов',
      'give500Correct': 'Дайте 500 правильных ответов',
      'give1000Correct': 'Дайте 1000 правильных ответов',
      'give5000Correct': 'Дайте 5000 правильных ответов',
      'studyMorning': 'Занимайтесь утром (6:00-9:00)',
      'studyNight': 'Занимайтесь ночью (22:00-2:00)',
      'studyWeekends': 'Занимайтесь в выходные дни',
      'experienceEarned': 'Опыт получен',
      'testAlreadyCompleted': 'Тест уже пройден',
      'questionsCompleted': 'Вопросов пройдено',
      'alreadyCompleted': 'уже пройдено',
      'currentLeague': 'Текущая лига',
      'totalExperience': 'Всего опыта',
      'weeklyExperience': 'Опыт за неделю',
      'leagueProgress': 'Прогресс лиги',
      'toNextLeague': 'До следующей лиги',
      'excellentWork': 'Отличная работа!',
      'youEarnedXP': 'Вы получили',
      'forTestCompletion': 'за завершение теста',
      'continueLearning': 'Продолжить обучение',
      'animationInProgress': 'Анимация...',
      'you': 'Вы',
      'educationalLeague': 'EduLeague',
      'yourLeague': 'Ваша лига',
      'needMoreXP': 'Нужно еще',
      'noDataInLeague': 'Нет данных в лиге',

      // Дополнительные
      'daysShort': 'д',
      'topicsShort': 'т',
      'searchResults': 'Результаты поиска:',
      'close': 'Закрыть',

      'rank': 'Ранг',
      'noRank': 'Без ранга',
      'playersInLeague': 'Игроки в лиге',
      'noPlayersInLeague': 'Нет игроков в лиге',
      'beFirstInLeague': 'Станьте первым в лиге!',

      'please_select_at_least_one_answer': "Пожалуйста, выберите хотя бы один ответ",
      'select_multiple_answers': "Выберите несколько вариантов ответа",
      'questions': 'вопросов',
      'tryDifferentSearch': 'Попробуйте изменить поисковый запрос',
      'sendMessage': 'Написать сообщение',
      'noMessages': 'Нет сообщений',
      'startConversation': 'Начните общение с другом',
      'typeMessage': 'Введите сообщение...',
      'viewProfile': 'Посмотреть профиль',
      'clearChat': 'Очистить чат',

      'reportError': 'Сообщить об ошибке',
      'reportErrorDescription': 'Если вы нашли ошибку в вопросе или ответах, сообщите нам об этом',
      'reportErrorHint': 'Опишите ошибку...',
      'pleaseEnterErrorMessage': 'Пожалуйста, опишите ошибку',
      'sendingErrorReport': 'Отправка сообщения об ошибке...',
      'errorReportSent': 'Сообщение об ошибке отправлено!',
      'errorReportFailed': 'Ошибка отправки. Проверьте интернет соединение.',
      'send': 'Отправить',
      'guest':'Гость',
      'subject':'Предмет',
      'review':'Повторение',
      'dictionary':'Словарь',
      'home':'Главная',
      'refresh': 'Обновить',
      'categories': 'Категории',
      'learning': 'Обучение',
      'perfect': 'Идеально',
      'leagues': 'Лиги',
      'loadingAchievements': 'Загрузка достижений',
      'remaining': 'Осталось',
      'experience': 'Опыт',
      'earnedXP': 'Заработано XP',
      'navigationHint': 'Навигация',
      'useBottomNavigation': 'Используйте нижнюю навигацию',
      'progressToNextLeague': 'Прогресс до следующей лиги',
      'leaderboard': 'Таблица лидеров',
      'players': 'Игроков',
      'level': 'Уровень',
      // В разделе 'ru' добавьте:
      'statistics_plural': 'Статистика',
      'edupeak_plus': 'EduPeak+',
      'premium_access': 'Премиум доступ',
      'all_features': 'Все возможности платформы без ограничений',
      'pricing': 'Тарифы',
      'whats_included': 'Что включено',
      'features_count': 'преимуществ',
      'month': 'Месяц',
      'year': 'Год',
      'savings': 'Экономия',
      'no_ads': 'Без рекламы',
      'focus_on_learning': 'Полностью сосредоточьтесь на обучении',
      'extended_materials': 'Расширенные материалы',
      'additional_resources': 'Дополнительные учебные материалы и тесты',
      'try_free': 'Попробовать 7 дней бесплатно',
      'coming_soon': 'Скоро будет доступно',
      'got_it': 'Понятно',
      'terms_and_definitions': 'Термины и определения',
      'all_concepts': 'Все важные понятия из школьной программы в одном месте',
      'development_status': 'Статус',
      'in_development': 'В разработке',
      'actively_developed': 'Раздел находится в активной разработке',
      'dictionary_preview': 'Что будет в словаре',
      'subject_terms': 'Термины по предметам',
      'subject_concepts': 'Все важные понятия из разных школьных предметов',
      'detailed_definitions': 'Подробные определения',
      'clear_explanations': 'Понятные объяснения с примерами и иллюстрациями',
      'quick_search': 'Быстрый поиск',
      'instant_search': 'Находите термины мгновенно по названию или теме',
      'favorites': 'Избранное',
      'save_important': 'Сохраняйте важные термины для быстрого доступа',
      'see_news': 'Посмотреть новости и обновления',
      'section': 'Раздел',
      'hello_what_to_study': 'Привет, что будем изучать сегодня?',
      'my_subjects': 'Мои предметы',
      'management': 'Управление',
      'add_subjects': 'Добавить предметы',
      'remove_subjects': 'Удалить предметы',
      'recommended': 'Рекомендуем',
      'all_subjects_added': 'Все предметы добавлены',
      'all_subjects_message': 'Вы добавили все доступные предметы',
      'no_subjects_to_remove': 'Нет предметов для удаления',
      'add_subjects_message': 'Добавьте предметы в список изучения',
      'no_selected_subjects': 'Нет выбранных предметов',
      'add_subjects_to_learn': 'Добавьте предметы для обучения',
      'add_subjects_button': 'Добавить предметы',
      'started_topics': 'Начатые темы',
      'study_some_topics': 'Начните изучать темы, и они появятся здесь для повторения',
      'start_studying': 'Начать изучение',
      'since': 'На EduPeak с',
      'studied_subjects': 'Изучаемые предметы',
      'achievements_completed': 'завершено',
      'xp_earned': 'Опыта получено',
      'topics_completed': 'Тем завершено',

// Дополнительно для main_screen:
      'what_to_study_today': 'что будем изучать сегодня?',
      'your_xp': 'Твой опыт',
      'latest_news': 'Последняя новость',
      'your_league': 'Твоя лига',
      'new_unread': 'НОВАЯ',
      'read': 'ПРОЧИТАНО',
      'updated_today': 'Обновлено сегодня',
      'youre_legend': 'Ты легенда! Продолжай в том же духе',
      'almost_at_top': 'Почти на вершине! Осталось немного',
      'excellent_result': 'Отличный результат! Продолжай развиваться',
      'great_work_top': 'Отличная работа! Ты в топе игроков',
      'good_progress': 'Хороший прогресс! Двигайся дальше',
      'not_bad_aim_higher': 'Неплохо! Стремись к большему',
      'good_start': 'Хороший старт! Развивайся дальше',
      'beginner_ahead': 'Начинающий! Все впереди',

// Для review_screen:
      'review_questions': 'Вопросы для повторения',
      'started_topics_questions': 'вопросов из начатых тем',
      'start_learning_topics': 'Начните изучение тем',
      'grades_active': 'Классов активно',
      'questions_total': 'Вопросов всего',
      'started_topics_count': 'Тем начаты',
      'subjectAdded': 'Предмет добавлен',
      'subjectRemoved': 'Предмет удален',
      'excellentProgress': 'Отличный прогресс!',
      'goodResult': 'хороший результат!',
      'youAlreadyHave': 'У тебя уже',
      'moveForward': 'Двигайся дальше!',
      'passFirstTestAndGetXP': 'Пройди первый тест и получи свои первые XP!',
      'noData': 'Нет данных',
      'mockFriend1Name': 'Александр Иванов',
      'mockFriend2Name': 'Мария Петрова',
      'mockFriend3Name': 'Иван Сидоров',
      'mockTestFriend1': 'Тестовый друг 1',
      'unknown': 'Неизвестно',
      'noName': 'Без имени',
      'inRow': 'подряд',
      'earned': 'получено',
      'premium': 'Premium',
    },
    'en': {
      'app_title': 'EduPeak',
      'experienceShort': 'XP',
      'welcome': 'Welcome',
      'start_learning': 'Start Learning',
      'conquer_knowledge': 'Conquer Knowledge Peaks',
      'students': 'Students',
      'topics': 'Topics',
      'success': 'Success',
      'subjects': 'Subjects',
      'join_and_improve': 'Join and boost your brainpower',
      'exam_preparation': 'GSE/USE Preparation • Olympiad Tasks',
      'choose_language': 'Choose Language',
      'russian': 'Russian (Русский) 🇷🇺',
      'english': 'English (English) 🇬🇧 ',
      'german': 'German (Deutsch) 🇩🇪',
      'login': 'Login',
      'register': 'Register',
      'settings': 'Settings',
      'profile': 'Profile',
      'statistics': 'Statistics',
      'subscription': 'Subscription',
      'logout': 'Logout',
      'appearance': 'Appearance',
      'theme_applied_instantly': 'Theme will be applied instantly',
      'system_theme': 'System Theme',
      'follow_system_settings': 'Follow system settings',
      'dark_theme': 'Dark Theme',
      'always_use_dark_theme': 'Always use dark theme',
      'light_theme': 'Light Theme',
      'always_use_light_theme': 'Always use light theme',
      'progress_management': 'Progress Management',
      'reset_learning_progress': 'Reset Learning Progress',
      'reset_progress_description': 'Reset all learning progress. Password confirmation required.',
      'reset_progress_button': 'Reset Learning Progress',
      'feedback': 'Feedback',
      'send_feedback_telegram': 'Send via Telegram',
      'send_telegram_button': 'Send via Telegram',
      'feedback_description': 'Send your feedback or suggestion. We will receive it instantly!',
      'feedback_hint': 'Write your feedback, idea or report an error...',
      'about_app': 'About App',
      'version': 'Version',
      'developer': 'Developer',
      'support': 'Support',
      'build_date': 'Build Date',
      'account_logout': 'Account Logout',
      'logout_description': 'End current session and logout from account',
      'language': 'Language',
      'language_settings': 'Language Settings',
      'select_app_language': 'Select app language',
      'change_language_restart': 'Language change will require app restart',
      'please_fill_all_fields': 'Please fill all fields',
      'enter_valid_email': 'Please enter a valid email',
      'server_unavailable_check_connection': 'Server unavailable. Check your internet connection.',
      'connection_error': 'Connection error',
      'login_error': 'Login error',
      'registration_error': 'Registration error',
      'create_account': 'Create Account',
      'username': 'Username',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'passwords_do_not_match': 'Passwords do not match',
      'password_min_length': 'Password must be at least 6 characters',
      'error': 'Error',
      'loading': 'Loading...',
      'correct': 'Correct',
      'incorrect': 'Incorrect',
      'your_answer': 'Your answer',
      'correct_answer': 'Correct answer',
      'explanation': 'Explanation',
      'continue_text': 'Continue',
      'finish_test': 'Finish test',
      'next_question': 'Next question',
      'check_answer': 'Check answer',
      'please_enter_answer': 'Please enter answer',
      'please_select_answer': 'Please select answer',
      'question': 'Question',
      'test_results': 'Test Results',
      'correct_answers': 'correct',
      'perfect_expert': 'Perfect! You are a real expert!',
      'excellent_almost_all': 'Excellent! You know almost everything!',
      'good_work_continue': 'Good work! Keep it up!',
      'not_bad_room_to_grow': 'Not bad, but there is room to grow!',
      'dont_worry_try_again': "Don't worry! Try again!",
      'return_to_topics': 'Return to topics',
      'retake_test': 'Retake test',
      'topic_description': 'Description',
      'start_lesson': 'Start lesson',
      'topic_explanation': 'Topic explanation',
      'start_test': 'Start test',
      'hello': 'Hello',
      'start_lesson_text': 'Start lesson',
      'today_completed': 'Today completed',
      'all_grades': 'All grades',
      'search_topics': 'Search topics...',
      'no_topics_found': 'No topics found',
      'try_changing_search': 'Try changing search query',
      'edit_profile': 'Edit Profile',
      'click_to_edit': 'Click on photo to edit',
      'update_username': 'Update username',
      'using_custom_photo': 'Using custom photo',
      'using_default_avatar': 'Using default avatar',
      'days_streak': 'Days streak',
      'completed_topics': 'Completed topics',
      'correct_answers_count': 'Correct answers',
      'subject_progress': 'Subject progress',
      'no_completed_topics': 'No completed topics yet',
      'premium_features': 'Premium features',
      'learning_progress': 'Learning progress',
      'app_settings': 'App settings',
      'enter_username': 'Enter username',
      'username_updated': 'Username updated!',
      'username_update_error': 'Error updating username',
      'error_selecting_image': 'Error selecting image',
      'avatar_updated': 'Profile photo updated',
      'avatar_update_error': 'Error updating avatar',
      'enter_answer': 'Enter your answer...',
      'test_completed': 'Test completed',
      'correct_count': 'Correct answers',
      'percentage_correct': '% correct answers',
      'back_to_topics': 'Back to topics',
      'topic': 'Topic',
      'grade_class': 'class',
      'edit': 'Editing',
      'square_avatar': 'Square avatar 1:1',
      'adjust_crop': 'Adjust crop for perfect avatar',
      'edit_photo': 'Edit',
      'crop': 'Crop',
      'done': 'Done',
      'cancel': 'Cancel',
      'back': 'Back',
      'choose_auth_method': 'Choose authentication method',
      'email': 'Email',
      'enter_email': 'Enter email',
      'enter_password': 'Enter password',
      'forgot_password': 'Forgot password?',
      'remember_me': 'Remember me',
      'guest_mode': 'Guest mode',
      'continue_as_guest': 'Continue as guest',
      'select_language': 'Select language',
      'language_changed': 'Language changed',
      'restart_required': 'App restart required',
      'enter_your_account': 'Enter your account',
      'enter_credentials': 'Enter your login credentials',
      'no_account': 'No account?',
      'enter_email_and_password': 'Enter your email and create a password',
      'premium_subscription': 'Premium Subscription',
      'offline_mode': 'Offline Mode',
      'study_without_internet': 'Study topics without internet',
      'advanced_statistics': 'Advanced Statistics',
      'detailed_progress_analytics': 'Detailed progress analytics',
      'exclusive_themes': 'Exclusive Themes',
      'unique_app_design': 'Unique app design',
      'priority_support': 'Priority Support',
      'fast_answers': 'Fast answers to questions',
      'subscribe_button': 'Subscribe - 299₽/month',
      'subscription_development': 'Subscription feature in development',
      'days_in_row': 'Days in row',
      'completed_topics_count': 'Completed topics',
      'progress_by_subjects': 'Progress by subjects',
      'lesson_explanation': 'Topic Explanation',
      'start_lesson_button': 'Start Lesson',
      'start_test_button': 'Start Test',
      'correctly': 'correct',
      'excellent_knowledge': 'Excellent! You know almost everything!',
      'not_bad_grow': 'Not bad, but there is room to grow!',
      'continue_next': 'Continue',
      'completing_test': 'Completing test...',
      'russian_language': 'Russian Language',
      'math': 'Mathematics',
      'algebra': 'Algebra',
      'geometry': 'Geometry',
      'english_language': 'English Language',
      'literature': 'Literature',
      'biology': 'Biology',
      'physics': 'Physics',
      'chemistry': 'Chemistry',
      'geography': 'Geography',
      'russian_history': 'Russian History',
      'world_history': 'World History',
      'social_studies': 'Social Studies',
      'computer_science': 'Computer Science',
      'statistics_probability': 'Statistics and Probability',
      'of_text': 'of',
      'avatar_crop_title': 'Editing',
      'avatar_crop_subtitle': 'Adjust crop for perfect avatar',
      'edit_button': 'Edit',
      'crop_title': 'Crop',
      'saving': 'Saving...',
      'grade': 'Class',
      'correct_answer_not_found': 'Correct answer not found',
      'answer_load_error': 'Error loading answer',
      'question_not_found': 'Question not found',
      'no_answer': 'No answer',
      'explanation_not_found': 'Explanation not found',
      'selectSubject': 'Select subject',
      // Achievements
      'achievements': 'Achievements',
      'achievementProgress': 'Achievement Progress',
      'achievementUnlocked': 'Achievement Unlocked!',
      'achievementDetails': 'Achievement Details',
      'unlocked': 'Unlocked',
      'locked': 'Locked',
      'progress': 'Progress',
      'totalAchievements': 'Total Achievements',
      'completedAchievements': 'Completed',
      'remainingAchievements': 'Remaining',
      'overallProgress': 'Progress',
      'completed': 'Completed',

      // Achievement types
      'testsCompleted': 'Tests Completed',
      'streakDays': 'Streak Days',
      'perfectTests': 'Perfect Tests',
      'subjectsCompleted': 'Subjects Completed',
      'testsInOneDay': 'Tests in One Day',
      'totalXP': 'Total XP',
      'league': 'League',
      'correctAnswers': 'Correct Answers',
      'dailyActivity': 'Daily Activity',
      'special': 'Special',

      // Friends
      'friends': 'Friends',
      'friendRequests': 'Friend Requests',
      'pendingRequests': 'Pending Requests',
      'addFriend': 'Add Friend',
      'removeFriend': 'Remove Friend',
      'acceptRequest': 'Accept Request',
      'declineRequest': 'Decline Request',
      'sendRequest': 'Send Request',
      'searchUsers': 'Search Users',
      'enterUsername': 'Enter username',
      'usersNotFound': 'Users not found',
      'noFriends': 'You have no friends yet',
      'findUsersAndAdd': 'Find users and add them as friends',
      'noRequests': 'No friend requests',
      'incomingRequests': 'Incoming requests will appear here',
      'friendRequestSent': 'Friend request sent to @%s',
      'requestAccepted': 'Request accepted',
      'requestDeclined': 'Request declined',
      'friendRemoved': 'Friend removed',

      // Friend stats
      'streak': 'Streak',
      'completedTopics': 'Completed topics',
      'weeklyXP': 'Weekly XP',

      // Notifications
      'requestFailed': 'Failed to send request',
      'acceptFailed': 'Failed to accept request',
      'declineFailed': 'Failed to decline request',
      'removeFailed': 'Failed to remove friend',
      'searchError': 'Error searching users',

      // Achievements - names
      'firstStep': 'First Step',
      'testMaster': 'Test Master',
      'testExpert': 'Test Expert',
      'testLegend': 'Test Legend',
      'journeyStart': 'Journey Start',
      'weekOfStrength': 'Week of Strength',
      'twoWeeks': 'Two Weeks',
      'monthOfDiscipline': 'Month of Discipline',
      'quarterChampion': 'Quarter Champion',
      'perfectionist': 'Perfectionist',
      'flawless': 'Flawless',
      'perfectResult': 'Perfect Result',
      'subjectExpert': 'Subject Expert',
      'subjectMaster': 'Subject Master',
      'grandmaster': 'Grandmaster',
      'fastLearner': 'Fast Learner',
      'marathoner': 'Marathoner',
      'dailyWarrior': 'Daily Warrior',
      'knowledgeSeeker': 'Knowledge Seeker',
      'wisdomKeeper': 'Wisdom Keeper',
      'knowledgeMaster': 'Knowledge Master',
      'bronzeFighter': 'Bronze Fighter',
      'silverStrategist': 'Silver Strategist',
      'goldChampion': 'Gold Champion',
      'platinumGenius': 'Platinum Genius',
      'diamondMaster': 'Diamond Master',
      'accurateAnswer': 'Accurate Answer',
      'erudite': 'Erudite',
      'knowItAll': 'Know-It-All',
      'walkingEncyclopedia': 'Walking Encyclopedia',
      'earlyBird': 'Early Bird',
      'nightOwl': 'Night Owl',
      'weekendWarrior': 'Weekend Warrior',

      // Achievements - descriptions
      'completeFirstTest': 'Complete your first test',
      'complete10Tests': 'Complete 10 tests',
      'complete50Tests': 'Complete 50 tests',
      'complete100Tests': 'Complete 100 tests',
      'study3Days': 'Study for 3 days in a row',
      'study7Days': 'Study for 7 days in a row',
      'study14Days': 'Study for 14 days in a row',
      'study30Days': 'Study for 30 days in a row',
      'study90Days': 'Study for 90 days in a row',
      'get100Percent': 'Get 100% on a test',
      'get100Percent5Tests': 'Get 100% on 5 tests',
      'get100Percent20Tests': 'Get 100% on 20 tests',
      'completeAllTopics': 'Complete all topics in one subject',
      'completeAllTopics3Subjects': 'Complete all topics in 3 subjects',
      'completeAllTopics5Subjects': 'Complete all topics in 5 subjects',
      'complete5TestsDay': 'Complete 5 tests in one day',
      'complete10TestsDay': 'Complete 10 tests in one day',
      'studyEveryDayWeek': 'Study every day for a week',
      'earn1000XP': 'Earn 1000 XP',
      'earn5000XP': 'Earn 5000 XP',
      'earn10000XP': 'Earn 10000 XP',
      'reachBronzeLeague': 'Reach Bronze league',
      'reachSilverLeague': 'Reach Silver league',
      'reachGoldLeague': 'Reach Gold league',
      'reachPlatinumLeague': 'Reach Platinum league',
      'reachDiamondLeague': 'Reach Diamond league',
      'give100Correct': 'Give 100 correct answers',
      'give500Correct': 'Give 500 correct answers',
      'give1000Correct': 'Give 1000 correct answers',
      'give5000Correct': 'Give 5000 correct answers',
      'studyMorning': 'Study in the morning (6:00-9:00)',
      'studyNight': 'Study at night (22:00-2:00)',
      'studyWeekends': 'Study on weekends',

      // Additional
      'daysShort': 'd',
      'topicsShort': 't',
      'searchResults': 'Search results:',
      'close': 'Close',

      'experienceEarned': 'Experience earned',
      'testAlreadyCompleted': 'Test already completed',
      'questionsCompleted': 'Questions completed',
      'alreadyCompleted': 'already completed',
      'currentLeague': 'Current league',
      'totalExperience': 'Total experience',
      'weeklyExperience': 'Weekly experience',
      'leagueProgress': 'League progress',
      'toNextLeague': 'To next league',
      'excellentWork': 'Excellent work!',
      'youEarnedXP': 'You earned',
      'forTestCompletion': 'for test completion',
      'continueLearning': 'Continue learning',
      'animationInProgress': 'Animation in progress',
      'you': 'You',
      'educationalLeague': 'EduLeague',
      'yourLeague': 'Your league',
      'needMoreXP': 'Need more',
      'noDataInLeague': 'No data in league',
      'rank': 'Rank',
      'noRank': 'No rank',
      'playersInLeague': 'Players in league',
      'noPlayersInLeague': 'No players in league',
      'beFirstInLeague': 'Be the first in league!',
      'please_select_at_least_one_answer': "Please select at least one answer",
      'select_multiple_answers': "Select multiple answers",
      'questions': 'questions',
      'tryDifferentSearch': 'Try changing your search query',
      'sendMessage': 'Send message',
      'noMessages': 'No messages',
      'startConversation': 'Start a conversation with your friend',
      'typeMessage': 'Type a message...',
      'viewProfile': 'View profile',
      'clearChat': 'Clear chat',
      'reportError': 'Report error',
      'reportErrorDescription': 'If you found an error in the question or answers, please let us know',
      'reportErrorHint': 'Describe the error...',
      'pleaseEnterErrorMessage': 'Please describe the error',
      'sendingErrorReport': 'Sending error report...',
      'errorReportSent': 'Error report sent!',
      'errorReportFailed': 'Sending failed. Check your internet connection.',
      'send': 'Send',
      'guest':'Guest',
      'subject':'Subject',
      'review':'Review',
      'dictionary':'Dictionary',
      'home':'Home',
      'refresh': 'Refresh',
      'categories': 'Categories',
      'learning': 'Learning',
      'perfect': 'Perfect',
      'leagues': 'Leagues',
      'loadingAchievements': 'Loading achievements',
      'remaining': 'Remaining',
      'experience': 'Experience',
      'earnedXP': 'Earned XP',
      'navigationHint': 'Navigation',
      'useBottomNavigation': 'Use bottom navigation',
      'progressToNextLeague': 'Progress to next league',
      'leaderboard': 'Leaderboard',
      'players': 'Players',
      'level': 'Level',
      'statistics_plural': 'Statistics',
      'edupeak_plus': 'EduPeak+',
      'premium_access': 'Premium Access',
      'all_features': 'All platform features without restrictions',
      'pricing': 'Pricing',
      'whats_included': 'What\'s Included',
      'features_count': 'features',
      'month': 'Month',
      'year': 'Year',
      'savings': 'Savings',
      'no_ads': 'No Ads',
      'focus_on_learning': 'Focus completely on learning',
      'extended_materials': 'Extended Materials',
      'additional_resources': 'Additional learning materials and tests',
      'try_free': 'Try 7 days free',
      'coming_soon': 'Coming Soon',
      'got_it': 'Got it',
      'terms_and_definitions': 'Terms and Definitions',
      'all_concepts': 'All important concepts from the school curriculum in one place',
      'development_status': 'Status',
      'in_development': 'In Development',
      'actively_developed': 'Section is actively being developed',
      'dictionary_preview': 'What will be in the dictionary',
      'subject_terms': 'Subject Terms',
      'subject_concepts': 'All important concepts from different school subjects',
      'detailed_definitions': 'Detailed Definitions',
      'clear_explanations': 'Clear explanations with examples and illustrations',
      'quick_search': 'Quick Search',
      'instant_search': 'Find terms instantly by name or topic',
      'favorites': 'Favorites',
      'save_important': 'Save important terms for quick access',
      'see_news': 'See news and updates',
      'section': 'Section',
      'hello_what_to_study': 'Hello, what shall we study today?',
      'my_subjects': 'My Subjects',
      'management': 'Management',
      'add_subjects': 'Add Subjects',
      'remove_subjects': 'Remove Subjects',
      'recommended': 'Recommended',
      'all_subjects_added': 'All subjects added',
      'all_subjects_message': 'You have added all available subjects',
      'no_subjects_to_remove': 'No subjects to remove',
      'add_subjects_message': 'Add subjects to study list',
      'no_selected_subjects': 'No selected subjects',
      'add_subjects_to_learn': 'Add subjects for learning',
      'add_subjects_button': 'Add Subjects',
      'started_topics': 'Started Topics',
      'study_some_topics': 'Start studying topics and they will appear here for review',
      'start_studying': 'Start Studying',
      'since': 'On EduPeak since',
      'studied_subjects': 'Studied Subjects',
      'achievements_completed': 'completed',
      'xp_earned': 'XP earned',
      'topics_completed': 'Topics completed',
      'what_to_study_today': 'what shall we study today?',
      'your_xp': 'Your XP',
      'latest_news': 'Latest News',
      'your_league': 'Your League',
      'new_unread': 'NEW',
      'read': 'READ',
      'updated_today': 'Updated today',
      'youre_legend': 'You are a legend! Keep it up',
      'almost_at_top': 'Almost at the top! A little left',
      'excellent_result': 'Excellent result! Keep developing',
      'great_work_top': 'Great work! You are in top players',
      'good_progress': 'Good progress! Move forward',
      'not_bad_aim_higher': 'Not bad! Aim higher',
      'good_start': 'Good start! Develop further',
      'beginner_ahead': 'Beginner! Everything ahead',
      'review_questions': 'Review Questions',
      'started_topics_questions': 'questions from started topics',
      'start_learning_topics': 'Start Learning Topics',
      'grades_active': 'Grades active',
      'questions_total': 'Questions total',
      'started_topics_count': 'Topics started',
      'subjectAdded': 'Subject added',
      'subjectRemoved': 'Subject removed',
      'excellentProgress': 'Excellent progress!',
      'goodResult': 'good result!',
      'youAlreadyHave': 'You already have',
      'moveForward': 'Move forward!',
      'passFirstTestAndGetXP': 'Pass the first test and get your first XP!',
      'noData': 'No data',
      'mockFriend1Name': 'Alexander Ivanov',
      'mockFriend2Name': 'Maria Petrova',
      'mockFriend3Name': 'Ivan Sidorov',
      'mockTestFriend1': 'Test friend 1',
      'unknown': 'Unknown',
      'noName': 'No name',
      'inRow': 'in a row',
      'earned': 'earned',
      'premium': 'Premium',
    },
    'de': {
      'app_title': 'EduPeak',
      'experienceShort': 'XP',
      'welcome': 'Willkommen',
      'start_learning': 'Lernen beginnen',
      'conquer_knowledge': 'Erobere die Gipfel des Wissens',
      'students': 'Schüler',
      'topics': 'Themen',
      'success': 'Erfolg',
      'subjects': 'Fächer',
      'join_and_improve': 'Schließen Sie sich an und trainieren Sie Ihr Gehirn',
      'exam_preparation': 'AS/ES Vorbereitung • Olympiade-Aufgaben',
      'choose_language': 'Sprache auswählen',
      'russian': 'Russisch (Русский) 🇷🇺',
      'english': 'Englisch (English) 🇬🇧 ',
      'german': 'Deutsch (Deutsch)  🇩🇪',
      'login': 'Anmelden',
      'register': 'Registrieren',
      'settings': 'Einstellungen',
      'profile': 'Profil',
      'statistics': 'Statistiken',
      'subscription': 'Abonnement',
      'logout': 'Abmelden',
      'appearance': 'Erscheinungsbild',
      'theme_applied_instantly': 'Theme wird sofort angewendet',
      'system_theme': 'System-Theme',
      'follow_system_settings': 'Systemeinstellungen folgen',
      'dark_theme': 'Dunkles Theme',
      'always_use_dark_theme': 'Immer dunkles Theme verwenden',
      'light_theme': 'Helles Theme',
      'always_use_light_theme': 'Immer helles Theme verwenden',
      'progress_management': 'Fortschrittsverwaltung',
      'reset_learning_progress': 'Lernfortschritt zurücksetzen',
      'reset_progress_description': 'Setzen Sie den gesamten Lernfortschritt zurück. Passwortbestätigung erforderlich.',
      'reset_progress_button': 'Lernfortschritt zurücksetzen',
      'feedback': 'Feedback',
      'send_feedback_telegram': 'Über Telegram senden',
      'send_telegram_button': 'Über Telegram senden',
      'feedback_description': 'Senden Sie Ihr Feedback oder Ihren Vorschlag. Wir erhalten es sofort!',
      'feedback_hint': 'Schreiben Sie Ihr Feedback, Ihre Idee oder melden Sie einen Fehler...',
      'about_app': 'Über die App',
      'version': 'Version',
      'developer': 'Entwickler',
      'support': 'Support',
      'build_date': 'Build-Datum',
      'account_logout': 'Konto abmelden',
      'logout_description': 'Beenden Sie die aktuelle Sitzung und melden Sie sich vom Konto ab',
      'language': 'Sprache',
      'language_settings': 'Spracheinstellungen',
      'select_app_language': 'App-Sprache auswählen',
      'change_language_restart': 'Sprachänderung erfordert Neustart der App',
      'please_fill_all_fields': 'Bitte füllen Sie alle Felder aus',
      'enter_valid_email': 'Bitte geben Sie eine gültige E-Mail-Adresse ein',
      'server_unavailable_check_connection': 'Server nicht verfügbar. Überprüfen Sie Ihre Internetverbindung.',
      'connection_error': 'Verbindungsfehler',
      'login_error': 'Anmeldefehler',
      'registration_error': 'Registrierungsfehler',
      'create_account': 'Konto erstellen',
      'username': 'Benutzername',
      'password': 'Passwort',
      'confirm_password': 'Passwort bestätigen',
      'passwords_do_not_match': 'Passwörter stimmen nicht überein',
      'password_min_length': 'Passwort muss mindestens 6 Zeichen lang sein',
      'error': 'Fehler',
      'loading': 'Laden...',
      'correct': 'Richtig',
      'incorrect': 'Falsch',
      'your_answer': 'Ihre Antwort',
      'correct_answer': 'Richtige Antwort',
      'explanation': 'Erklärung',
      'continue_text': 'Weiter',
      'finish_test': 'Test beenden',
      'next_question': 'Nächste Frage',
      'check_answer': 'Antwort prüfen',
      'please_enter_answer': 'Bitte geben Sie eine Antwort ein',
      'please_select_answer': 'Bitte wählen Sie eine Antwort aus',
      'question': 'Frage',
      'test_results': 'Testergebnisse',
      'correct_answers': 'richtig',
      'perfect_expert': 'Perfekt! Sie sind ein echter Experte!',
      'excellent_almost_all': 'Ausgezeichnet! Sie wissen fast alles!',
      'good_work_continue': 'Gute Arbeit! Weiter so!',
      'not_bad_room_to_grow': 'Nicht schlecht, aber es gibt Raum zum Wachsen!',
      'dont_worry_try_again': 'Keine Sorge! Versuchen Sie es noch einmal!',
      'return_to_topics': 'Zurück zu Themen',
      'retake_test': 'Test wiederholen',
      'topic_description': 'Beschreibung',
      'start_lesson': 'Lektion starten',
      'topic_explanation': 'Thema Erklärung',
      'start_test': 'Test starten',
      'hello': 'Hallo',
      'start_lesson_text': 'Lektion starten',
      'today_completed': 'Heute abgeschlossen',
      'all_grades': 'Alle Klassen',
      'search_topics': 'Themen durchsuchen...',
      'no_topics_found': 'Keine Themen gefunden',
      'try_changing_search': 'Versuchen Sie, die Suchanfrage zu ändern',
      'edit_profile': 'Profil bearbeiten',
      'click_to_edit': 'Zum Bearbeiten auf das Foto klicken',
      'update_username': 'Benutzernamen aktualisieren',
      'using_custom_photo': 'Verwendetes benutzerdefiniertes Foto',
      'using_default_avatar': 'Standard-Avatar wird verwendet',
      'days_streak': 'Tage in Folge',
      'completed_topics': 'Abgeschlossene Themen',
      'correct_answers_count': 'Richtige Antworten',
      'subject_progress': 'Fortschritt nach Fächern',
      'no_completed_topics': 'Noch keine abgeschlossenen Themen',
      'premium_features': 'Erweiterte Funktionen',
      'learning_progress': 'Lernfortschritt',
      'app_settings': 'App-Einstellungen',
      'enter_username': 'Benutzernamen eingeben',
      'username_updated': 'Benutzername aktualisiert!',
      'username_update_error': 'Fehler beim Aktualisieren des Benutzernamens',
      'error_selecting_image': 'Fehler bei der Bildauswahl',
      'avatar_updated': 'Profilfoto aktualisiert',
      'avatar_update_error': 'Fehler beim Aktualisieren des Avatars',
      'enter_answer': 'Geben Sie Ihre Antwort ein...',
      'test_completed': 'Test abgeschlossen',
      'correct_count': 'Richtige Antworten',
      'percentage_correct': '% richtige Antworten',
      'back_to_topics': 'Zurück zu Themen',
      'topic': 'Thema',
      'grade_class': 'Klasse',
      'edit': 'Bearbeiten',
      'square_avatar': 'Quadratischer Avatar 1:1',
      'adjust_crop': 'Passen Sie den Zuschnitt für den perfekten Avatar an',
      'edit_photo': 'Bearbeiten',
      'crop': 'Zuschneiden',
      'done': 'Fertig',
      'cancel': 'Abbrechen',
      'back': 'Zurück',
      'choose_auth_method': 'Authentifizierungsmethode wählen',
      'email': 'E-Mail',
      'enter_email': 'E-Mail eingeben',
      'enter_password': 'Passwort eingeben',
      'forgot_password': 'Passwort vergessen?',
      'remember_me': 'Angemeldet bleiben',
      'guest_mode': 'Gastmodus',
      'continue_as_guest': 'Als Gast fortfahren',
      'select_language': 'Sprache auswählen',
      'language_changed': 'Sprache geändert',
      'restart_required': 'App-Neustart erforderlich',
      'enter_your_account': 'Melden Sie sich in Ihrem Konto an',
      'enter_credentials': 'Geben Sie Ihre Anmeldedaten ein',
      'no_account': 'Kein Konto?',
      'enter_email_and_password': 'Geben Sie Ihre E-Mail ein und erstellen Sie ein Passwort',
      'premium_subscription': 'Premium-Abonnement',
      'offline_mode': 'Offline-Modus',
      'study_without_internet': 'Themen ohne Internet studieren',
      'advanced_statistics': 'Erweiterte Statistiken',
      'detailed_progress_analytics': 'Detaillierte Fortschrittsanalytik',
      'exclusive_themes': 'Exklusive Themen',
      'unique_app_design': 'Einzigartiges App-Design',
      'priority_support': 'Prioritätsunterstützung',
      'fast_answers': 'Schnelle Antworten auf Fragen',
      'subscribe_button': 'Abonnieren - 299₽/Monat',
      'subscription_development': 'Abonnementfunktion in Entwicklung',
      'days_in_row': 'Tage in Folge',
      'completed_topics_count': 'Abgeschlossene Themen',
      'progress_by_subjects': 'Fortschritt nach Fächern',
      'lesson_explanation': 'Thema Erklärung',
      'start_lesson_button': 'Lektion starten',
      'start_test_button': 'Test starten',
      'correctly': 'richtig',
      'excellent_knowledge': 'Ausgezeichnet! Du weißt fast alles!',
      'not_bad_grow': 'Nicht schlecht, aber es gibt Raum zum Wachsen!',
      'continue_next': 'Weiter',
      'completing_test': 'Test wird abgeschlossen...',
      'russian_language': 'Russische Sprache',
      'math': 'Mathematik',
      'algebra': 'Algebra',
      'geometry': 'Geometrie',
      'english_language': 'Englische Sprache',
      'literature': 'Literatur',
      'biology': 'Biologie',
      'physics': 'Physik',
      'chemistry': 'Chemie',
      'geography': 'Geographie',
      'russian_history': 'Russische Geschichte',
      'world_history': 'Weltgeschichte',
      'social_studies': 'Sozialkunde',
      'computer_science': 'Informatik',
      'statistics_probability': 'Statistik und Wahrscheinlichkeit',
      'of_text': 'von',
      'avatar_crop_title': 'Bearbeiten',
      'avatar_crop_subtitle': 'Passen Sie den Zuschnitt für den perfekten Avatar an',
      'edit_button': 'Bearbeiten',
      'crop_title': 'Zuschneiden',
      'saving': 'Speichern...',
      'grade': 'Klasse',
      'correct_answer_not_found': 'Richtige Antwort nicht gefunden',
      'answer_load_error': 'Fehler beim Laden der Antwort',
      'question_not_found': 'Frage nicht gefunden',
      'no_answer': 'Keine Antwort',
      'explanation_not_found': 'Erklärung nicht gefunden',
      'selectSubject': 'Betreff auswählen',
      // Achievements
      'achievements': 'Erfolge',
      'achievementProgress': 'Erfolgsfortschritt',
      'achievementUnlocked': 'Erfolg freigeschaltet!',
      'achievementDetails': 'Erfolgsdetails',
      'unlocked': 'Freigeschaltet',
      'locked': 'Gesperrt',
      'progress': 'Fortschritt',
      'totalAchievements': 'Gesamterfolge',
      'completedAchievements': 'Abgeschlossene Erfolge',
      'remainingAchievements': 'Verbleibende Erfolge',
      'overallProgress': 'Gesamtfortschritt',
      'completed': 'Abgeschlossen',

      // Achievement types
      'testsCompleted': 'Tests abgeschlossen',
      'streakDays': 'Tage in Folge',
      'perfectTests': 'Perfekte Tests',
      'subjectsCompleted': 'Fächer abgeschlossen',
      'testsInOneDay': 'Tests an einem Tag',
      'totalXP': 'Gesamt-XP',
      'league': 'Liga',
      'correctAnswers': 'Richtige Antworten',
      'dailyActivity': 'Tägliche Aktivität',
      'special': 'Spezial',

      // Friends
      'friends': 'Freunde',
      'friendRequests': 'Freundschaftsanfragen',
      'pendingRequests': 'Ausstehende Anfragen',
      'addFriend': 'Freund hinzufügen',
      'removeFriend': 'Freund entfernen',
      'acceptRequest': 'Anfrage annehmen',
      'declineRequest': 'Anfrage ablehnen',
      'sendRequest': 'Anfrage senden',
      'searchUsers': 'Benutzer suchen',
      'enterUsername': 'Benutzernamen eingeben',
      'usersNotFound': 'Benutzer nicht gefunden',
      'noFriends': 'Sie haben noch keine Freunde',
      'findUsersAndAdd': 'Finden Sie Benutzer und fügen Sie sie als Freunde hinzu',
      'noRequests': 'Keine Freundschaftsanfragen',
      'incomingRequests': 'Eingehende Anfragen erscheinen hier',
      'friendRequestSent': 'Freundschaftsanfrage an @%s gesendet',
      'requestAccepted': 'Anfrage angenommen',
      'requestDeclined': 'Anfrage abgelehnt',
      'friendRemoved': 'Freund entfernt',

      // Friend stats
      'streak': 'Serie',
      'completedTopics': 'Abgeschlossene Themen',
      'weeklyXP': 'Wöchentliche XP',

      // Notifications
      'requestFailed': 'Anfrage konnte nicht gesendet werden',
      'acceptFailed': 'Anfrage konnte nicht angenommen werden',
      'declineFailed': 'Anfrage konnte nicht abgelehnt werden',
      'removeFailed': 'Freund konnte nicht entfernt werden',
      'searchError': 'Fehler bei der Benutzersuche',

      // Достижения - названия
      'firstStep': 'Erster Schritt',
      'testMaster': 'Testmeister',
      'testExpert': 'Testexperte',
      'testLegend': 'Testlegende',
      'journeyStart': 'Reisebeginn',
      'weekOfStrength': 'Woche der Stärke',
      'twoWeeks': 'Zwei Wochen',
      'monthOfDiscipline': 'Monat der Disziplin',
      'quarterChampion': 'Vierteljahres-Champion',
      'perfectionist': 'Perfektionist',
      'flawless': 'Fehlerfrei',
      'perfectResult': 'Perfektes Ergebnis',
      'subjectExpert': 'Fachexperte',
      'subjectMaster': 'Fachmeister',
      'grandmaster': 'Großmeister',
      'fastLearner': 'Schneller Lerner',
      'marathoner': 'Marathonläufer',
      'dailyWarrior': 'Täglicher Kämpfer',
      'knowledgeSeeker': 'Wissenssuchender',
      'wisdomKeeper': 'Weisheitshüter',
      'knowledgeMaster': 'Wissensmeister',
      'bronzeFighter': 'Bronzekämpfer',
      'silverStrategist': 'Silberstratege',
      'goldChampion': 'Goldchampion',
      'platinumGenius': 'Platin-Genie',
      'diamondMaster': 'Diamantmeister',
      'accurateAnswer': 'Genaue Antwort',
      'erudite': 'Gelehrter',
      'knowItAll': 'Alleswisser',
      'walkingEncyclopedia': 'Wandelnde Enzyklopädie',
      'earlyBird': 'Früher Vogel',
      'nightOwl': 'Nachteule',
      'weekendWarrior': 'Wochenendkrieger',

      // Достижения - описания
      'completeFirstTest': 'Absolviere deinen ersten Test',
      'complete10Tests': 'Absolviere 10 Tests',
      'complete50Tests': 'Absolviere 50 Tests',
      'complete100Tests': 'Absolviere 100 Tests',
      'study3Days': 'Lerne 3 Tage hintereinander',
      'study7Days': 'Lerne 7 Tage hintereinander',
      'study14Days': 'Lerne 14 Tage hintereinander',
      'study30Days': 'Lerne 30 Tage hintereinander',
      'study90Days': 'Lerne 90 Tage hintereinander',
      'get100Percent': 'Erziele 100% in einem Test',
      'get100Percent5Tests': 'Erziele 100% in 5 Tests',
      'get100Percent20Tests': 'Erziele 100% in 20 Tests',
      'completeAllTopics': 'Schließe alle Themen in einem Fach ab',
      'completeAllTopics3Subjects': 'Schließe alle Themen in 3 Fächern ab',
      'completeAllTopics5Subjects': 'Schließe alle Themen in 5 Fächern ab',
      'complete5TestsDay': 'Absolviere 5 Tests an einem Tag',
      'complete10TestsDay': 'Absolviere 10 Tests an einem Tag',
      'studyEveryDayWeek': 'Lerne jeden Tag für eine Woche',
      'earn1000XP': 'Verdiene 1000 XP',
      'earn5000XP': 'Verdiene 5000 XP',
      'earn10000XP': 'Verdiene 10000 XP',
      'reachBronzeLeague': 'Erreiche die Bronze-Liga',
      'reachSilverLeague': 'Erreiche die Silber-Liga',
      'reachGoldLeague': 'Erreiche die Gold-Liga',
      'reachPlatinumLeague': 'Erreiche die Platin-Liga',
      'reachDiamondLeague': 'Erreiche die Diamant-Liga',
      'give100Correct': 'Gib 100 richtige Antworten',
      'give500Correct': 'Gib 500 richtige Antworten',
      'give1000Correct': 'Gib 1000 richtige Antworten',
      'give5000Correct': 'Gib 5000 richtige Antworten',
      'studyMorning': 'Lerne morgens (6:00-9:00)',
      'studyNight': 'Lerne nachts (22:00-2:00)',
      'studyWeekends': 'Lerne an Wochenenden',

      // Дополнительные
      'daysShort': 'T',
      'topicsShort': 'Th',
      'searchResults': 'Suchergebnisse:',
      'close': 'Schließen',

      'experienceEarned': 'Erfahrung verdient',
      'testAlreadyCompleted': 'Test bereits',
      'questionsCompleted': 'Fragen',
      'alreadyCompleted': 'Bereits',
      'currentLeague': 'Aktuelle Liga',
      'totalExperience': 'Gesamterfahrung',
      'weeklyExperience': 'Wöchentliche Erfahrung',
      'leagueProgress': 'Liga-Fortschritt',
      'toNextLeague': 'Zur nächsten Liga',
      'excellentWork': 'Ausgezeichnete Arbeit!',
      'youEarnedXP': 'Du hast verdient',
      'forTestCompletion': 'für Testabschluss',
      'continueLearning': 'Weiter lernen',
      'animationInProgress': 'Animation läuft',
      'you': 'Du',
      'educationalLeague': 'EduLeague',
      'yourLeague': 'Deine Liga',
      'needMoreXP': 'Brauche mehr',
      'noDataInLeague': 'Keine Daten in der Liga',
      'rank': 'Rang',
      'noRank': 'Kein Rang',
      'playersInLeague': 'Spieler in der Liga',
      'noPlayersInLeague': 'Keine Spieler in der Liga',
      'beFirstInLeague': 'Sei der Erste in der Liga!',
      'please_select_at_least_one_answer': "Bitte wählen Sie mindestens eine Antwort aus",
      'select_multiple_answers': "Wählen Sie mehrere Antworten aus",
      'questions': 'Fragen',
      'tryDifferentSearch': 'Versuchen Sie, Ihre Suchanfrage zu ändern',
      'sendMessage': 'Nachricht senden',
      'noMessages': 'Keine Nachrichten',
      'startConversation': 'Starten Sie eine Unterhaltung mit Ihrem Freund',
      'typeMessage': 'Nachricht eingeben...',
      'viewProfile': 'Profil anzeigen',
      'clearChat': 'Chat löschen',
      'reportError': 'Fehler melden',
      'reportErrorDescription': 'Wenn Sie einen Fehler in der Frage oder den Antworten gefunden haben, teilen Sie uns dies bitte mit',
      'reportErrorHint': 'Beschreiben Sie den Fehler...',
      'pleaseEnterErrorMessage': 'Bitte beschreiben Sie den Fehler',
      'sendingErrorReport': 'Fehlerbericht wird gesendet...',
      'errorReportSent': 'Fehlerbericht gesendet!',
      'errorReportFailed': 'Senden fehlgeschlagen. Überprüfen Sie Ihre Internetverbindung.',
      'send': 'Senden',
      'guest':'Gast',
      'subject':'Thema',
      'review':'Rezension',
      'dictionary':'Wörterbuch',
      'home':'Heim',
      'refresh': 'Aktualisieren',
      'categories': 'Kategorien',
      'learning': 'Lernen',
      'perfect': 'Perfekt',
      'leagues': 'Ligen',
      'loadingAchievements': 'Erfolge werden geladen',
      'remaining': 'Verbleibend',
      'experience': 'Erfahrung',
      'earnedXP': 'Verdiente XP',
      'navigationHint': 'Navigation',
      'useBottomNavigation': 'Verwende die untere Navigation',
      'progressToNextLeague': 'Fortschritt zur nächsten Liga',
      'leaderboard': 'Bestenliste',
      'players': 'Spieler',
      'level': 'Level',
      'statistics_plural': 'Statistiken',
      'edupeak_plus': 'EduPeak+',
      'premium_access': 'Premium-Zugang',
      'all_features': 'Alle Plattformfunktionen ohne Einschränkungen',
      'pricing': 'Preise',
      'whats_included': 'Was enthalten ist',
      'features_count': 'Vorteile',
      'month': 'Monat',
      'year': 'Jahr',
      'savings': 'Einsparung',
      'no_ads': 'Keine Werbung',
      'focus_on_learning': 'Konzentrieren Sie sich vollständig auf das Lernen',
      'extended_materials': 'Erweiterte Materialien',
      'additional_resources': 'Zusätzliche Lernmaterialien und Tests',
      'try_free': '7 Tage kostenlos testen',
      'coming_soon': 'Demnächst verfügbar',
      'got_it': 'Verstanden',
      'terms_and_definitions': 'Begriffe und Definitionen',
      'all_concepts': 'Alle wichtigen Konzepte des Schullehrplans an einem Ort',
      'development_status': 'Status',
      'in_development': 'In Entwicklung',
      'actively_developed': 'Bereich wird aktiv entwickelt',
      'dictionary_preview': 'Was wird im Wörterbuch sein',
      'subject_terms': 'Fachbegriffe',
      'subject_concepts': 'Alle wichtigen Konzepte aus verschiedenen Schulfächern',
      'detailed_definitions': 'Detaillierte Definitionen',
      'clear_explanations': 'Klar verständliche Erklärungen mit Beispielen und Illustrationen',
      'quick_search': 'Schnellsuche',
      'instant_search': 'Finden Sie Begriffe sofort nach Name oder Thema',
      'favorites': 'Favoriten',
      'save_important': 'Speichern Sie wichtige Begriffe für schnellen Zugriff',
      'see_news': 'Neuigkeiten und Updates ansehen',
      'section': 'Bereich',
      'hello_what_to_study': 'Hallo, was wollen wir heute lernen?',
      'my_subjects': 'Meine Fächer',
      'management': 'Verwaltung',
      'add_subjects': 'Fächer hinzufügen',
      'remove_subjects': 'Fächer entfernen',
      'recommended': 'Empfohlen',
      'all_subjects_added': 'Alle Fächer hinzugefügt',
      'all_subjects_message': 'Sie haben alle verfügbaren Fächer hinzugefügt',
      'no_subjects_to_remove': 'Keine Fächer zum Entfernen',
      'add_subjects_message': 'Fügen Sie Fächer zur Lernliste hinzu',
      'no_selected_subjects': 'Keine ausgewählten Fächer',
      'add_subjects_to_learn': 'Fügen Sie Fächer zum Lernen hinzu',
      'add_subjects_button': 'Fächer hinzufügen',
      'started_topics': 'Begonnene Themen',
      'study_some_topics': 'Beginnen Sie mit dem Lernen von Themen, und sie erscheinen hier zur Wiederholung',
      'start_studying': 'Lernen beginnen',
      'since': 'Auf EduPeak seit',
      'studied_subjects': 'Gelernte Fächer',
      'achievements_completed': 'abgeschlossen',
      'xp_earned': 'XP verdient',
      'topics_completed': 'Themen abgeschlossen',
      'what_to_study_today': 'was wollen wir heute lernen?',
      'your_xp': 'Deine XP',
      'latest_news': 'Letzte Neuigkeit',
      'your_league': 'Deine Liga',
      'new_unread': 'NEU',
      'read': 'GELESEN',
      'updated_today': 'Heute aktualisiert',
      'youre_legend': 'Du bist eine Legende! Weiter so',
      'almost_at_top': 'Fast oben! Noch ein wenig',
      'excellent_result': 'Ausgezeichnetes Ergebnis! Entwickle dich weiter',
      'great_work_top': 'Großartige Arbeit! Du bist unter den Top-Spielern',
      'good_progress': 'Guter Fortschritt! Geh weiter',
      'not_bad_aim_higher': 'Nicht schlecht! Strebe nach Höherem',
      'good_start': 'Guter Start! Entwickle dich weiter',
      'beginner_ahead': 'Anfänger! Alles liegt vor dir',
      'review_questions': 'Wiederholungsfragen',
      'started_topics_questions': 'Fragen aus begonnenen Themen',
      'start_learning_topics': 'Themen lernen beginnen',
      'grades_active': 'Klassen aktiv',
      'questions_total': 'Fragen insgesamt',
      'started_topics_count': 'Themen begonnen',
      'subjectAdded': 'Fach hinzugefügt',
      'subjectRemoved': 'Fach entfernt',
      'excellentProgress': 'Ausgezeichneter Fortschritt!',
      'goodResult': 'gutes Ergebnis!',
      'youAlreadyHave': 'Du hast bereits',
      'moveForward': 'Weitergehen!',
      'passFirstTestAndGetXP': 'Bestehe den ersten Test und erhalte deine ersten XP!',
      'noData': 'Keine Daten',
      'mockFriend1Name': 'Alexander Iwanow',
      'mockFriend2Name': 'Maria Petrova',
      'mockFriend3Name': 'Iwan Sidorow',
      'mockTestFriend1': 'Testfreund 1',
      'unknown': 'Unbekannt',
      'noName': 'Kein Name',
      'inRow': 'hintereinander',
      'earned': 'verdient',
      'premium': 'Premium',
      '':'',
    },
  };

  // Геттеры для всех переводов
  String get appTitle => _localizedValues[locale.languageCode]?['app_title'] ?? 'EduPeak';
  String get welcome => _localizedValues[locale.languageCode]?['welcome'] ?? 'Welcome';
  String get startLearning => _localizedValues[locale.languageCode]?['start_learning'] ?? 'Start Learning';
  String get conquerKnowledge => _localizedValues[locale.languageCode]?['conquer_knowledge'] ?? 'Conquer Knowledge';
  String get students => _localizedValues[locale.languageCode]?['students'] ?? 'Students';
  String get topics => _localizedValues[locale.languageCode]?['topics'] ?? 'Topics';
  String get success => _localizedValues[locale.languageCode]?['success'] ?? 'Success';
  String get subjects => _localizedValues[locale.languageCode]?['subjects'] ?? 'Subjects';
  String get joinAndImprove => _localizedValues[locale.languageCode]?['join_and_improve'] ?? 'Join and improve';
  String get examPreparation => _localizedValues[locale.languageCode]?['exam_preparation'] ?? 'Exam Preparation';
  String get chooseLanguage => _localizedValues[locale.languageCode]?['choose_language'] ?? 'Choose Language';
  String get russian => _localizedValues[locale.languageCode]?['russian'] ?? 'Русский 🇷🇺';
  String get english => _localizedValues[locale.languageCode]?['english'] ?? 'English 🇬🇧 ';
  String get german => _localizedValues[locale.languageCode]?['german'] ?? 'Deutsch 🇩🇪';
  String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Login';
  String get register => _localizedValues[locale.languageCode]?['register'] ?? 'Register';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  String get statistics => _localizedValues[locale.languageCode]?['statistics'] ?? 'Statistics';
  String get subscription => _localizedValues[locale.languageCode]?['subscription'] ?? 'Subscription';
  String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';
  String get appearance => _localizedValues[locale.languageCode]?['appearance'] ?? 'Appearance';
  String get themeAppliedInstantly => _localizedValues[locale.languageCode]?['theme_applied_instantly'] ?? 'Theme applied instantly';
  String get systemTheme => _localizedValues[locale.languageCode]?['system_theme'] ?? 'System Theme';
  String get followSystemSettings => _localizedValues[locale.languageCode]?['follow_system_settings'] ?? 'Follow system settings';
  String get darkTheme => _localizedValues[locale.languageCode]?['dark_theme'] ?? 'Dark Theme';
  String get alwaysUseDarkTheme => _localizedValues[locale.languageCode]?['always_use_dark_theme'] ?? 'Always use dark theme';
  String get lightTheme => _localizedValues[locale.languageCode]?['light_theme'] ?? 'Light Theme';
  String get alwaysUseLightTheme => _localizedValues[locale.languageCode]?['always_use_light_theme'] ?? 'Always use light theme';
  String get progressManagement => _localizedValues[locale.languageCode]?['progress_management'] ?? 'Progress Management';
  String get resetLearningProgress => _localizedValues[locale.languageCode]?['reset_learning_progress'] ?? 'Reset Learning Progress';
  String get resetProgressDescription => _localizedValues[locale.languageCode]?['reset_progress_description'] ?? 'Reset progress description';
  String get resetProgressButton => _localizedValues[locale.languageCode]?['reset_progress_button'] ?? 'Reset Learning Progress';
  String get feedback => _localizedValues[locale.languageCode]?['feedback'] ?? 'Feedback';
  String get sendFeedbackTelegram => _localizedValues[locale.languageCode]?['send_feedback_telegram'] ?? 'Send via Telegram';
  String get sendTelegramButton => _localizedValues[locale.languageCode]?['send_telegram_button'] ?? 'Send via Telegram';
  String get feedbackDescription => _localizedValues[locale.languageCode]?['feedback_description'] ?? 'Feedback description';
  String get feedbackHint => _localizedValues[locale.languageCode]?['feedback_hint'] ?? 'Write your feedback...';
  String get aboutApp => _localizedValues[locale.languageCode]?['about_app'] ?? 'About App';
  String get version => _localizedValues[locale.languageCode]?['version'] ?? 'Version';
  String get developer => _localizedValues[locale.languageCode]?['developer'] ?? 'Developer';
  String get support => _localizedValues[locale.languageCode]?['support'] ?? 'Support';
  String get buildDate => _localizedValues[locale.languageCode]?['build_date'] ?? 'Build Date';
  String get accountLogout => _localizedValues[locale.languageCode]?['account_logout'] ?? 'Account Logout';
  String get logoutDescription => _localizedValues[locale.languageCode]?['logout_description'] ?? 'Logout description';
  String get language => _localizedValues[locale.languageCode]?['language'] ?? 'Language';
  String get languageSettings => _localizedValues[locale.languageCode]?['language_settings'] ?? 'Language Settings';
  String get selectAppLanguage => _localizedValues[locale.languageCode]?['select_app_language'] ?? 'Select app language';
  String get changeLanguageRestart => _localizedValues[locale.languageCode]?['change_language_restart'] ?? 'Language change requires restart';
  String get pleaseFillAllFields => _localizedValues[locale.languageCode]?['please_fill_all_fields'] ?? 'Please fill all fields';
  String get enterValidEmail => _localizedValues[locale.languageCode]?['enter_valid_email'] ?? 'Enter valid email';
  String get serverUnavailableCheckConnection => _localizedValues[locale.languageCode]?['server_unavailable_check_connection'] ?? 'Server unavailable';
  String get connectionError => _localizedValues[locale.languageCode]?['connection_error'] ?? 'Connection error';
  String get loginError => _localizedValues[locale.languageCode]?['login_error'] ?? 'Login error';
  String get registrationError => _localizedValues[locale.languageCode]?['registration_error'] ?? 'Registration error';
  String get createAccount => _localizedValues[locale.languageCode]?['create_account'] ?? 'Create Account';
  String get username => _localizedValues[locale.languageCode]?['username'] ?? 'Username';
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Password';
  String get confirmPassword => _localizedValues[locale.languageCode]?['confirm_password'] ?? 'Confirm Password';
  String get passwordsDoNotMatch => _localizedValues[locale.languageCode]?['passwords_do_not_match'] ?? 'Passwords do not match';
  String get passwordMinLength => _localizedValues[locale.languageCode]?['password_min_length'] ?? 'Password min length';
  String get error => _localizedValues[locale.languageCode]?['error'] ?? 'Error';
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Loading';
  String get correct => _localizedValues[locale.languageCode]?['correct'] ?? 'Correct';
  String get incorrect => _localizedValues[locale.languageCode]?['incorrect'] ?? 'Incorrect';
  String get yourAnswer => _localizedValues[locale.languageCode]?['your_answer'] ?? 'Your answer';
  String get correctAnswer => _localizedValues[locale.languageCode]?['correct_answer'] ?? 'Correct answer';
  String get explanation => _localizedValues[locale.languageCode]?['explanation'] ?? 'Explanation';
  String get continueText => _localizedValues[locale.languageCode]?['continue_text'] ?? 'Continue';
  String get finishTest => _localizedValues[locale.languageCode]?['finish_test'] ?? 'Finish test';
  String get nextQuestion => _localizedValues[locale.languageCode]?['next_question'] ?? 'Next question';
  String get checkAnswer => _localizedValues[locale.languageCode]?['check_answer'] ?? 'Check answer';
  String get pleaseEnterAnswer => _localizedValues[locale.languageCode]?['please_enter_answer'] ?? 'Please enter answer';
  String get pleaseSelectAnswer => _localizedValues[locale.languageCode]?['please_select_answer'] ?? 'Please select answer';
  String get question => _localizedValues[locale.languageCode]?['question'] ?? 'Question';
  String get testResults => _localizedValues[locale.languageCode]?['test_results'] ?? 'Test results';
  String get correctAnswers => _localizedValues[locale.languageCode]?['correct_answers'] ?? 'correct';
  String get perfectExpert => _localizedValues[locale.languageCode]?['perfect_expert'] ?? 'Perfect expert';
  String get excellentAlmostAll => _localizedValues[locale.languageCode]?['excellent_almost_all'] ?? 'Excellent almost all';
  String get goodWorkContinue => _localizedValues[locale.languageCode]?['good_work_continue'] ?? 'Good work continue';
  String get notBadRoomToGrow => _localizedValues[locale.languageCode]?['not_bad_room_to_grow'] ?? 'Not bad room to grow';
  String get dontWorryTryAgain => _localizedValues[locale.languageCode]?['dont_worry_try_again'] ?? 'Dont worry try again';
  String get returnToTopics => _localizedValues[locale.languageCode]?['return_to_topics'] ?? 'Return to topics';
  String get retakeTest => _localizedValues[locale.languageCode]?['retake_test'] ?? 'Retake test';
  String get topicDescription => _localizedValues[locale.languageCode]?['topic_description'] ?? 'Topic description';
  String get startLesson => _localizedValues[locale.languageCode]?['start_lesson'] ?? 'Start lesson';
  String get topicExplanation => _localizedValues[locale.languageCode]?['topic_explanation'] ?? 'Topic explanation';
  String get startTest => _localizedValues[locale.languageCode]?['start_test'] ?? 'Start test';
  String get hello => _localizedValues[locale.languageCode]?['hello'] ?? 'Hello';
  String get startLessonText => _localizedValues[locale.languageCode]?['start_lesson_text'] ?? 'Start lesson';
  String get todayCompleted => _localizedValues[locale.languageCode]?['today_completed'] ?? 'Today completed';
  String get allGrades => _localizedValues[locale.languageCode]?['all_grades'] ?? 'All classes';
  String get searchTopics => _localizedValues[locale.languageCode]?['search_topics'] ?? 'Search topics';
  String get noTopicsFound => _localizedValues[locale.languageCode]?['no_topics_found'] ?? 'No topics found';
  String get tryChangingSearch => _localizedValues[locale.languageCode]?['try_changing_search'] ?? 'Try changing search';
  String get editProfile => _localizedValues[locale.languageCode]?['edit_profile'] ?? 'Edit profile';
  String get clickToEdit => _localizedValues[locale.languageCode]?['click_to_edit'] ?? 'Click to edit';
  String get updateUsername => _localizedValues[locale.languageCode]?['update_username'] ?? 'Update username';
  String get usingCustomPhoto => _localizedValues[locale.languageCode]?['using_custom_photo'] ?? 'Using custom photo';
  String get usingDefaultAvatar => _localizedValues[locale.languageCode]?['using_default_avatar'] ?? 'Using default avatar';
  String get daysStreak => _localizedValues[locale.languageCode]?['days_streak'] ?? 'Days streak';
  String get completedTopics => _localizedValues[locale.languageCode]?['completed_topics'] ?? 'Completed topics';
  String get correctAnswersCount => _localizedValues[locale.languageCode]?['correct_answers_count'] ?? 'Correct answers';
  String get subjectProgress => _localizedValues[locale.languageCode]?['subject_progress'] ?? 'Subject progress';
  String get noCompletedTopics => _localizedValues[locale.languageCode]?['no_completed_topics'] ?? 'No completed topics';
  String get premiumFeatures => _localizedValues[locale.languageCode]?['premium_features'] ?? 'Premium features';
  String get learningProgress => _localizedValues[locale.languageCode]?['learning_progress'] ?? 'Learning progress';
  String get appSettings => _localizedValues[locale.languageCode]?['app_settings'] ?? 'App settings';
  String get enterUsername => _localizedValues[locale.languageCode]?['enter_username'] ?? 'Enter username';
  String get usernameUpdated => _localizedValues[locale.languageCode]?['username_updated'] ?? 'Username updated';
  String get usernameUpdateError => _localizedValues[locale.languageCode]?['username_update_error'] ?? 'Username update error';
  String get errorSelectingImage => _localizedValues[locale.languageCode]?['error_selecting_image'] ?? 'Error selecting image';
  String get avatarUpdated => _localizedValues[locale.languageCode]?['avatar_updated'] ?? 'Avatar updated';
  String get avatarUpdateError => _localizedValues[locale.languageCode]?['avatar_update_error'] ?? 'Avatar update error';
  String get enterAnswer => _localizedValues[locale.languageCode]?['enter_answer'] ?? 'Enter your answer';
  String get testCompleted => _localizedValues[locale.languageCode]?['test_completed'] ?? 'Test completed';
  String get correctCount => _localizedValues[locale.languageCode]?['correct_count'] ?? 'Correct answers';
  String get percentageCorrect => _localizedValues[locale.languageCode]?['percentage_correct'] ?? '% correct';
  String get backToTopics => _localizedValues[locale.languageCode]?['back_to_topics'] ?? 'Back to topics';
  String get topic => _localizedValues[locale.languageCode]?['topic'] ?? 'Topic';
  String get gradeClass => _localizedValues[locale.languageCode]?['grade_class'] ?? 'class';
  String get edit => _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
  String get squareAvatar => _localizedValues[locale.languageCode]?['square_avatar'] ?? 'Square avatar';
  String get adjustCrop => _localizedValues[locale.languageCode]?['adjust_crop'] ?? 'Adjust crop';
  String get editPhoto => _localizedValues[locale.languageCode]?['edit_photo'] ?? 'Edit';
  String get crop => _localizedValues[locale.languageCode]?['crop'] ?? 'Crop';
  String get done => _localizedValues[locale.languageCode]?['done'] ?? 'Done';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get back => _localizedValues[locale.languageCode]?['back'] ?? 'Back';
  String get chooseAuthMethod => _localizedValues[locale.languageCode]?['choose_auth_method'] ?? 'Choose authentication method';
  String get email => _localizedValues[locale.languageCode]?['email'] ?? 'Email';
  String get enterEmail => _localizedValues[locale.languageCode]?['enter_email'] ?? 'Enter email';
  String get enterPassword => _localizedValues[locale.languageCode]?['enter_password'] ?? 'Enter password';
  String get forgotPassword => _localizedValues[locale.languageCode]?['forgot_password'] ?? 'Forgot password?';
  String get rememberMe => _localizedValues[locale.languageCode]?['remember_me'] ?? 'Remember me';
  String get guestMode => _localizedValues[locale.languageCode]?['guest_mode'] ?? 'Guest mode';
  String get continueAsGuest => _localizedValues[locale.languageCode]?['continue_as_guest'] ?? 'Continue as guest';
  String get selectLanguage => _localizedValues[locale.languageCode]?['select_language'] ?? 'Select language';
  String get languageChanged => _localizedValues[locale.languageCode]?['language_changed'] ?? 'Language changed';
  String get restartRequired => _localizedValues[locale.languageCode]?['restart_required'] ?? 'App restart required';
  String get enterYourAccount => _localizedValues[locale.languageCode]?['enter_your_account'] ?? 'Enter your account';
  String get enterCredentials => _localizedValues[locale.languageCode]?['enter_credentials'] ?? 'Enter your credentials';
  String get noAccount => _localizedValues[locale.languageCode]?['no_account'] ?? 'No account?';
  String get enterEmailAndPassword => _localizedValues[locale.languageCode]?['enter_email_and_password'] ?? 'Enter email and password';
  String get premiumSubscription => _localizedValues[locale.languageCode]?['premium_subscription'] ?? 'Premium Subscription';
  String get offlineMode => _localizedValues[locale.languageCode]?['offline_mode'] ?? 'Offline Mode';
  String get studyWithoutInternet => _localizedValues[locale.languageCode]?['study_without_internet'] ?? 'Study without internet';
  String get advancedStatistics => _localizedValues[locale.languageCode]?['advanced_statistics'] ?? 'Advanced Statistics';
  String get detailedProgressAnalytics => _localizedValues[locale.languageCode]?['detailed_progress_analytics'] ?? 'Detailed progress analytics';
  String get exclusiveThemes => _localizedValues[locale.languageCode]?['exclusive_themes'] ?? 'Exclusive Themes';
  String get uniqueAppDesign => _localizedValues[locale.languageCode]?['unique_app_design'] ?? 'Unique app design';
  String get prioritySupport => _localizedValues[locale.languageCode]?['priority_support'] ?? 'Priority Support';
  String get fastAnswers => _localizedValues[locale.languageCode]?['fast_answers'] ?? 'Fast answers';
  String get subscribeButton => _localizedValues[locale.languageCode]?['subscribe_button'] ?? 'Subscribe';
  String get subscriptionDevelopment => _localizedValues[locale.languageCode]?['subscription_development'] ?? 'Subscription in development';
  String get daysInRow => _localizedValues[locale.languageCode]?['days_in_row'] ?? 'Days in row';
  String get completedTopicsCount => _localizedValues[locale.languageCode]?['completed_topics_count'] ?? 'Completed topics';
  String get progressBySubjects => _localizedValues[locale.languageCode]?['progress_by_subjects'] ?? 'Progress by subjects';
  String get lessonExplanation => _localizedValues[locale.languageCode]?['lesson_explanation'] ?? 'Lesson Explanation';
  String get startLessonButton => _localizedValues[locale.languageCode]?['start_lesson_button'] ?? 'Start Lesson';
  String get startTestButton => _localizedValues[locale.languageCode]?['start_test_button'] ?? 'Start Test';
  String get correctly => _localizedValues[locale.languageCode]?['correctly'] ?? 'correct';
  String get excellentKnowledge => _localizedValues[locale.languageCode]?['excellent_knowledge'] ?? 'Excellent knowledge';
  String get notBadGrow => _localizedValues[locale.languageCode]?['not_bad_grow'] ?? 'Not bad grow';
  String get continueNext => _localizedValues[locale.languageCode]?['continue_next'] ?? 'Continue';
  String get completingTest => _localizedValues[locale.languageCode]?['completing_test'] ?? 'Completing test';
  String get russianLanguage => _localizedValues[locale.languageCode]?['russian_language'] ?? 'Russian Language';
  String get math => _localizedValues[locale.languageCode]?['math'] ?? 'Mathematics';
  String get algebra => _localizedValues[locale.languageCode]?['algebra'] ?? 'Algebra';
  String get geometry => _localizedValues[locale.languageCode]?['geometry'] ?? 'Geometry';
  String get englishLanguage => _localizedValues[locale.languageCode]?['english_language'] ?? 'English Language';
  String get literature => _localizedValues[locale.languageCode]?['literature'] ?? 'Literature';
  String get biology => _localizedValues[locale.languageCode]?['biology'] ?? 'Biology';
  String get physics => _localizedValues[locale.languageCode]?['physics'] ?? 'Physics';
  String get chemistry => _localizedValues[locale.languageCode]?['chemistry'] ?? 'Chemistry';
  String get geography => _localizedValues[locale.languageCode]?['geography'] ?? 'Geography';
  String get russianHistory => _localizedValues[locale.languageCode]?['russian_history'] ?? 'Russian History';
  String get worldHistory => _localizedValues[locale.languageCode]?['world_history'] ?? 'World History';
  String get socialStudies => _localizedValues[locale.languageCode]?['social_studies'] ?? 'Social Studies';
  String get computerScience => _localizedValues[locale.languageCode]?['computer_science'] ?? 'Computer Science';
  String get statisticsProbability => _localizedValues[locale.languageCode]?['statistics_probability'] ?? 'Statistics and Probability';
  String get ofText => _localizedValues[locale.languageCode]?['of_text'] ?? 'of';
  String get avatarCropTitle => _localizedValues[locale.languageCode]?['avatar_crop_title'] ?? 'Editing';
  String get avatarCropSubtitle => _localizedValues[locale.languageCode]?['avatar_crop_subtitle'] ?? 'Adjust crop for perfect avatar';
  String get editButton => _localizedValues[locale.languageCode]?['edit_button'] ?? 'Edit';
  String get cropTitle => _localizedValues[locale.languageCode]?['crop_title'] ?? 'Crop';
  String get saving => _localizedValues[locale.languageCode]?['saving'] ?? 'Saving...';
  String get grade => _localizedValues[locale.languageCode]?['grade'] ?? 'Grade';
  String get correctAnswerNotFound => _localizedValues[locale.languageCode]?['correct_answer_not_found'] ?? 'Correct answer not found';
  String get answerLoadError => _localizedValues[locale.languageCode]?['answer_load_error'] ?? 'Error loading answer';
  String get questionNotFound => _localizedValues[locale.languageCode]?['question_not_found'] ?? 'Question not found';
  String get noAnswer => _localizedValues[locale.languageCode]?['no_answer'] ?? 'No answer';
  String get explanationNotFound => _localizedValues[locale.languageCode]?['explanation_not_found'] ?? 'Explanation not found';
  String get selectSubject => _localizedValues[locale.languageCode]?['select_subject'] ?? 'Select subject';
  String get close => _localizedValues[locale.languageCode]?['close'] ?? 'Close';

  // Achievements
  String get achievements => _localizedValues[locale.languageCode]?['achievements'] ?? 'Achievements';
  String get achievementProgress => _localizedValues[locale.languageCode]?['achievementProgress'] ?? 'Achievement Progress';
  String get achievementUnlocked => _localizedValues[locale.languageCode]?['achievementUnlocked'] ?? 'Achievement Unlocked!';
  String get achievementDetails => _localizedValues[locale.languageCode]?['achievementDetails'] ?? 'Achievement Details';
  String get unlocked => _localizedValues[locale.languageCode]?['unlocked'] ?? 'Unlocked';
  String get locked => _localizedValues[locale.languageCode]?['locked'] ?? 'Locked';
  String get progress => _localizedValues[locale.languageCode]?['progress'] ?? 'Progress';
  String get totalAchievements => _localizedValues[locale.languageCode]?['totalAchievements'] ?? 'Total Achievements';
  String get completedAchievements => _localizedValues[locale.languageCode]?['completedAchievements'] ?? 'Completed Achievements';
  String get remainingAchievements => _localizedValues[locale.languageCode]?['remainingAchievements'] ?? 'Remaining Achievements';
  String get overallProgress => _localizedValues[locale.languageCode]?['overallProgress'] ?? 'Overall Progress';
  String get completed => _localizedValues[locale.languageCode]?['completed'] ?? 'Completed';

  // Achievement types
  String get testsCompleted => _localizedValues[locale.languageCode]?['testsCompleted'] ?? 'Tests Completed';
  String get streakDays => _localizedValues[locale.languageCode]?['streakDays'] ?? 'Streak Days';
  String get perfectTests => _localizedValues[locale.languageCode]?['perfectTests'] ?? 'Perfect Tests';
  String get subjectsCompleted => _localizedValues[locale.languageCode]?['subjectsCompleted'] ?? 'Subjects Completed';
  String get testsInOneDay => _localizedValues[locale.languageCode]?['testsInOneDay'] ?? 'Tests in One Day';
  String get totalXP => _localizedValues[locale.languageCode]?['totalXP'] ?? 'Total XP';
  String get league => _localizedValues[locale.languageCode]?['league'] ?? 'League';
  String get dailyActivity => _localizedValues[locale.languageCode]?['dailyActivity'] ?? 'Daily Activity';
  String get special => _localizedValues[locale.languageCode]?['special'] ?? 'Special';

  // Friends
  String get friends => _localizedValues[locale.languageCode]?['friends'] ?? 'Friends';
  String get friendRequests => _localizedValues[locale.languageCode]?['friendRequests'] ?? 'Friend Requests';
  String get pendingRequests => _localizedValues[locale.languageCode]?['pendingRequests'] ?? 'Pending Requests';
  String get addFriend => _localizedValues[locale.languageCode]?['addFriend'] ?? 'Add Friend';
  String get removeFriend => _localizedValues[locale.languageCode]?['removeFriend'] ?? 'Remove Friend';
  String get acceptRequest => _localizedValues[locale.languageCode]?['acceptRequest'] ?? 'Accept Request';
  String get declineRequest => _localizedValues[locale.languageCode]?['declineRequest'] ?? 'Decline Request';
  String get sendRequest => _localizedValues[locale.languageCode]?['sendRequest'] ?? 'Send Request';
  String get searchUsers => _localizedValues[locale.languageCode]?['searchUsers'] ?? 'Search Users';
  String get usersNotFound => _localizedValues[locale.languageCode]?['usersNotFound'] ?? 'Users not found';
  String get noFriends => _localizedValues[locale.languageCode]?['noFriends'] ?? 'You have no friends yet';
  String get findUsersAndAdd => _localizedValues[locale.languageCode]?['findUsersAndAdd'] ?? 'Find users and add them as friends';
  String get noRequests => _localizedValues[locale.languageCode]?['noRequests'] ?? 'No friend requests';
  String get incomingRequests => _localizedValues[locale.languageCode]?['incomingRequests'] ?? 'Incoming requests will appear here';
  String get friendRequestSent => _localizedValues[locale.languageCode]?['friendRequestSent'] ?? 'Friend request sent to @%s';
  String get requestAccepted => _localizedValues[locale.languageCode]?['requestAccepted'] ?? 'Request accepted';
  String get requestDeclined => _localizedValues[locale.languageCode]?['requestDeclined'] ?? 'Request declined';
  String get friendRemoved => _localizedValues[locale.languageCode]?['friendRemoved'] ?? 'Friend removed';

  // Friend stats
  String get streak => _localizedValues[locale.languageCode]?['streak'] ?? 'Streak';
  String get weeklyXP => _localizedValues[locale.languageCode]?['weeklyXP'] ?? 'Weekly XP';

  // Notifications
  String get requestFailed => _localizedValues[locale.languageCode]?['requestFailed'] ?? 'Failed to send request';
  String get acceptFailed => _localizedValues[locale.languageCode]?['acceptFailed'] ?? 'Failed to accept request';
  String get declineFailed => _localizedValues[locale.languageCode]?['declineFailed'] ?? 'Failed to decline request';
  String get removeFailed => _localizedValues[locale.languageCode]?['removeFailed'] ?? 'Failed to remove friend';
  String get searchError => _localizedValues[locale.languageCode]?['searchError'] ?? 'Error searching users';

  // Achievement names
  String get firstStep => _localizedValues[locale.languageCode]?['firstStep'] ?? 'First Step';
  String get testMaster => _localizedValues[locale.languageCode]?['testMaster'] ?? 'Test Master';
  String get testExpert => _localizedValues[locale.languageCode]?['testExpert'] ?? 'Test Expert';
  String get testLegend => _localizedValues[locale.languageCode]?['testLegend'] ?? 'Test Legend';
  String get journeyStart => _localizedValues[locale.languageCode]?['journeyStart'] ?? 'Journey Start';
  String get weekOfStrength => _localizedValues[locale.languageCode]?['weekOfStrength'] ?? 'Week of Strength';
  String get twoWeeks => _localizedValues[locale.languageCode]?['twoWeeks'] ?? 'Two Weeks';
  String get monthOfDiscipline => _localizedValues[locale.languageCode]?['monthOfDiscipline'] ?? 'Month of Discipline';
  String get quarterChampion => _localizedValues[locale.languageCode]?['quarterChampion'] ?? 'Quarter Champion';
  String get perfectionist => _localizedValues[locale.languageCode]?['perfectionist'] ?? 'Perfectionist';
  String get flawless => _localizedValues[locale.languageCode]?['flawless'] ?? 'Flawless';
  String get perfectResult => _localizedValues[locale.languageCode]?['perfectResult'] ?? 'Perfect Result';
  String get subjectExpert => _localizedValues[locale.languageCode]?['subjectExpert'] ?? 'Subject Expert';
  String get subjectMaster => _localizedValues[locale.languageCode]?['subjectMaster'] ?? 'Subject Master';
  String get grandmaster => _localizedValues[locale.languageCode]?['grandmaster'] ?? 'Grandmaster';
  String get fastLearner => _localizedValues[locale.languageCode]?['fastLearner'] ?? 'Fast Learner';
  String get marathoner => _localizedValues[locale.languageCode]?['marathoner'] ?? 'Marathoner';
  String get dailyWarrior => _localizedValues[locale.languageCode]?['dailyWarrior'] ?? 'Daily Warrior';
  String get knowledgeSeeker => _localizedValues[locale.languageCode]?['knowledgeSeeker'] ?? 'Knowledge Seeker';
  String get wisdomKeeper => _localizedValues[locale.languageCode]?['wisdomKeeper'] ?? 'Wisdom Keeper';
  String get knowledgeMaster => _localizedValues[locale.languageCode]?['knowledgeMaster'] ?? 'Knowledge Master';
  String get bronzeFighter => _localizedValues[locale.languageCode]?['bronzeFighter'] ?? 'Bronze Fighter';
  String get silverStrategist => _localizedValues[locale.languageCode]?['silverStrategist'] ?? 'Silver Strategist';
  String get goldChampion => _localizedValues[locale.languageCode]?['goldChampion'] ?? 'Gold Champion';
  String get platinumGenius => _localizedValues[locale.languageCode]?['platinumGenius'] ?? 'Platinum Genius';
  String get diamondMaster => _localizedValues[locale.languageCode]?['diamondMaster'] ?? 'Diamond Master';
  String get accurateAnswer => _localizedValues[locale.languageCode]?['accurateAnswer'] ?? 'Accurate Answer';
  String get erudite => _localizedValues[locale.languageCode]?['erudite'] ?? 'Erudite';
  String get knowItAll => _localizedValues[locale.languageCode]?['knowItAll'] ?? 'Know-It-All';
  String get walkingEncyclopedia => _localizedValues[locale.languageCode]?['walkingEncyclopedia'] ?? 'Walking Encyclopedia';
  String get earlyBird => _localizedValues[locale.languageCode]?['earlyBird'] ?? 'Early Bird';
  String get nightOwl => _localizedValues[locale.languageCode]?['nightOwl'] ?? 'Night Owl';
  String get weekendWarrior => _localizedValues[locale.languageCode]?['weekendWarrior'] ?? 'Weekend Warrior';

  // Achievement descriptions
  String get completeFirstTest => _localizedValues[locale.languageCode]?['completeFirstTest'] ?? 'Complete your first test';
  String get complete10Tests => _localizedValues[locale.languageCode]?['complete10Tests'] ?? 'Complete 10 tests';
  String get complete50Tests => _localizedValues[locale.languageCode]?['complete50Tests'] ?? 'Complete 50 tests';
  String get complete100Tests => _localizedValues[locale.languageCode]?['complete100Tests'] ?? 'Complete 100 tests';
  String get study3Days => _localizedValues[locale.languageCode]?['study3Days'] ?? 'Study for 3 days in a row';
  String get study7Days => _localizedValues[locale.languageCode]?['study7Days'] ?? 'Study for 7 days in a row';
  String get study14Days => _localizedValues[locale.languageCode]?['study14Days'] ?? 'Study for 14 days in a row';
  String get study30Days => _localizedValues[locale.languageCode]?['study30Days'] ?? 'Study for 30 days in a row';
  String get study90Days => _localizedValues[locale.languageCode]?['study90Days'] ?? 'Study for 90 days in a row';
  String get get100Percent => _localizedValues[locale.languageCode]?['get100Percent'] ?? 'Get 100% on a test';
  String get get100Percent5Tests => _localizedValues[locale.languageCode]?['get100Percent5Tests'] ?? 'Get 100% on 5 tests';
  String get get100Percent20Tests => _localizedValues[locale.languageCode]?['get100Percent20Tests'] ?? 'Get 100% on 20 tests';
  String get completeAllTopics => _localizedValues[locale.languageCode]?['completeAllTopics'] ?? 'Complete all topics in one subject';
  String get completeAllTopics3Subjects => _localizedValues[locale.languageCode]?['completeAllTopics3Subjects'] ?? 'Complete all topics in 3 subjects';
  String get completeAllTopics5Subjects => _localizedValues[locale.languageCode]?['completeAllTopics5Subjects'] ?? 'Complete all topics in 5 subjects';
  String get complete5TestsDay => _localizedValues[locale.languageCode]?['complete5TestsDay'] ?? 'Complete 5 tests in one day';
  String get complete10TestsDay => _localizedValues[locale.languageCode]?['complete10TestsDay'] ?? 'Complete 10 tests in one day';
  String get studyEveryDayWeek => _localizedValues[locale.languageCode]?['studyEveryDayWeek'] ?? 'Study every day for a week';
  String get earn1000XP => _localizedValues[locale.languageCode]?['earn1000XP'] ?? 'Earn 1000 XP';
  String get earn5000XP => _localizedValues[locale.languageCode]?['earn5000XP'] ?? 'Earn 5000 XP';
  String get earn10000XP => _localizedValues[locale.languageCode]?['earn10000XP'] ?? 'Earn 10000 XP';
  String get reachBronzeLeague => _localizedValues[locale.languageCode]?['reachBronzeLeague'] ?? 'Reach Bronze league';
  String get reachSilverLeague => _localizedValues[locale.languageCode]?['reachSilverLeague'] ?? 'Reach Silver league';
  String get reachGoldLeague => _localizedValues[locale.languageCode]?['reachGoldLeague'] ?? 'Reach Gold league';
  String get reachPlatinumLeague => _localizedValues[locale.languageCode]?['reachPlatinumLeague'] ?? 'Reach Platinum league';
  String get reachDiamondLeague => _localizedValues[locale.languageCode]?['reachDiamondLeague'] ?? 'Reach Diamond league';
  String get give100Correct => _localizedValues[locale.languageCode]?['give100Correct'] ?? 'Give 100 correct answers';
  String get give500Correct => _localizedValues[locale.languageCode]?['give500Correct'] ?? 'Give 500 correct answers';
  String get give1000Correct => _localizedValues[locale.languageCode]?['give1000Correct'] ?? 'Give 1000 correct answers';
  String get give5000Correct => _localizedValues[locale.languageCode]?['give5000Correct'] ?? 'Give 5000 correct answers';
  String get studyMorning => _localizedValues[locale.languageCode]?['studyMorning'] ?? 'Study in the morning (6:00-9:00)';
  String get studyNight => _localizedValues[locale.languageCode]?['studyNight'] ?? 'Study at night (22:00-2:00)';
  String get studyWeekends => _localizedValues[locale.languageCode]?['studyWeekends'] ?? 'Study on weekends';

  // Additional
  String get daysShort => _localizedValues[locale.languageCode]?['daysShort'] ?? 'd';
  String get topicsShort => _localizedValues[locale.languageCode]?['topicsShort'] ?? 't';
  String get searchResults => _localizedValues[locale.languageCode]?['searchResults'] ?? 'Search results:';

  String get experienceEarned => _localizedValues[locale.languageCode]?['experienceEarned'] ?? 'Experience earned';
  String get testAlreadyCompleted => _localizedValues[locale.languageCode]?['testAlreadyCompleted'] ?? 'Test already completed';
  String get questionsCompleted => _localizedValues[locale.languageCode]?['questionsCompleted'] ?? 'Questions completed';
  String get alreadyCompleted => _localizedValues[locale.languageCode]?['alreadyCompleted'] ?? 'already completed';
  String get currentLeague => _localizedValues[locale.languageCode]?['currentLeague'] ?? 'Current league';
  String get totalExperience => _localizedValues[locale.languageCode]?['totalExperience'] ?? 'Total experience';
  String get weeklyExperience => _localizedValues[locale.languageCode]?['weeklyExperience'] ?? 'Weekly experience';
  String get leagueProgress => _localizedValues[locale.languageCode]?['leagueProgress'] ?? 'League progress';
  String get toNextLeague => _localizedValues[locale.languageCode]?['toNextLeague'] ?? 'To next league';
  String get excellentWork => _localizedValues[locale.languageCode]?['excellentWork'] ?? 'Excellent work!';
  String get youEarnedXP => _localizedValues[locale.languageCode]?['youEarnedXP'] ?? 'You earned';
  String get forTestCompletion => _localizedValues[locale.languageCode]?['forTestCompletion'] ?? 'for test completion';
  String get continueLearning => _localizedValues[locale.languageCode]?['continueLearning'] ?? 'Continue learning';
  String get animationInProgress => _localizedValues[locale.languageCode]?['animationInProgress'] ?? 'Animation in progress';
  String get you => _localizedValues[locale.languageCode]?['you'] ?? 'You';
  String get educationalLeague => _localizedValues[locale.languageCode]?['educationalLeague'] ?? 'Educational League';
  String get yourLeague => _localizedValues[locale.languageCode]?['yourLeague'] ?? 'Your league';
  String get needMoreXP => _localizedValues[locale.languageCode]?['needMoreXP'] ?? 'Need more';
  String get noDataInLeague => _localizedValues[locale.languageCode]?['noDataInLeague'] ?? 'No data in league';

  // Добавьте эти геттеры в класс AppLocalizations:

  String get rank => _localizedValues[locale.languageCode]?['rank'] ?? 'Rank';
  String get noRank => _localizedValues[locale.languageCode]?['noRank'] ?? 'No rank';
  String get playersInLeague => _localizedValues[locale.languageCode]?['playersInLeague'] ?? 'Players in league';
  String get noPlayersInLeague => _localizedValues[locale.languageCode]?['noPlayersInLeague'] ?? 'No players in league';
  String get beFirstInLeague => _localizedValues[locale.languageCode]?['beFirstInLeague'] ?? 'Be the first in league!';

  String get pleaseSelectAtLeastOneAnswer => _localizedValues[locale.languageCode]?['please_select_at_least_one_answer'] ?? 'Please select at least one answer';
  String get selectMultipleAnswers => _localizedValues[locale.languageCode]?['select_multiple_answers'] ?? 'Select multiple answers';
  String get noAnswerSelected => _localizedValues[locale.languageCode]?['no_answer_selected'] ?? 'No answer selected';
  String get unknownAnswerType => _localizedValues[locale.languageCode]?['unknown_answer_type'] ?? 'Unknown answer type';
  String get noAnswerProvided => _localizedValues[locale.languageCode]?['no_answer_provided'] ?? 'No answer provided';
  String get questions => _localizedValues[locale.languageCode]?['questions'] ?? 'questions';
  String get tryDifferentSearch => _localizedValues[locale.languageCode]?['tryDifferentSearch'] ?? 'Try changing search';
  String get sendMessage => _localizedValues[locale.languageCode]?['sendMessage'] ?? 'Send message';
  String get noMessages => _localizedValues[locale.languageCode]?['noMessages'] ?? 'No messages';
  String get startConversation => _localizedValues[locale.languageCode]?['startConversation'] ?? 'Start a conversation with your friend';
  String get typeMessage => _localizedValues[locale.languageCode]?['typeMessage'] ?? 'Type a message...';
  String get viewProfile => _localizedValues[locale.languageCode]?['viewProfile'] ?? 'View profile';
  String get clearChat => _localizedValues[locale.languageCode]?['clearChat'] ?? 'Clear chat';
  String get reportError => _localizedValues[locale.languageCode]?['reportError'] ?? 'Report error';
  String get reportErrorDescription => _localizedValues[locale.languageCode]?['reportErrorDescription'] ?? 'If you found an error in the question or answers, please let us know';
  String get reportErrorHint => _localizedValues[locale.languageCode]?['reportErrorHint'] ?? 'Describe the error...';
  String get pleaseEnterErrorMessage => _localizedValues[locale.languageCode]?['pleaseEnterErrorMessage'] ?? 'Please describe the error';
  String get sendingErrorReport => _localizedValues[locale.languageCode]?['sendingErrorReport'] ?? 'Sending error report...';
  String get errorReportSent => _localizedValues[locale.languageCode]?['errorReportSent'] ?? 'Error report sent!';
  String get errorReportFailed => _localizedValues[locale.languageCode]?['errorReportFailed'] ?? 'Sending failed. Check your internet connection.';
  String get send => _localizedValues[locale.languageCode]?['send'] ?? 'Send';
  String get guest => _localizedValues[locale.languageCode]?['guest'] ?? 'Guest';
  String get subject => _localizedValues[locale.languageCode]?['subject'] ?? 'Subject';
  String get review => _localizedValues[locale.languageCode]?['review'] ?? 'Review';
  String get dictionary => _localizedValues[locale.languageCode]?['dictionary'] ?? 'Dictionary';
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  String get experienceShort => _localizedValues[locale.languageCode]?['xp'] ?? 'XP';
  String get topicCompleted => _localizedValues[locale.languageCode]?['темазавершена'] ?? 'Тема завершена';
  String get retakeTestButton => _localizedValues[locale.languageCode]?['повторитьтест'] ?? 'Повторить тест';
  String get refresh => _localizedValues[locale.languageCode]?['refresh'] ?? 'Refresh';
  String get categories => _localizedValues[locale.languageCode]?['categories'] ?? 'Categories';
  String get learning => _localizedValues[locale.languageCode]?['learning'] ?? 'Learning';
  String get perfect => _localizedValues[locale.languageCode]?['perfect'] ?? 'Perfect';
  String get leagues => _localizedValues[locale.languageCode]?['leagues'] ?? 'Leagues';
  String get loadingAchievements => _localizedValues[locale.languageCode]?['loadingAchievements'] ?? 'Loading achievements';
  String get remaining => _localizedValues[locale.languageCode]?['remaining'] ?? 'Remaining';
  String get experience => _localizedValues[locale.languageCode]?['experience'] ?? 'Experience';
  String get earnedXP => _localizedValues[locale.languageCode]?['earnedXP'] ?? 'Earned XP';
  String get navigationHint => _localizedValues[locale.languageCode]?['navigationHint'] ?? 'Navigation';
  String get useBottomNavigation => _localizedValues[locale.languageCode]?['useBottomNavigation'] ?? 'Use bottom navigation';
  String get progressToNextLeague => _localizedValues[locale.languageCode]?['progressToNextLeague'] ?? 'Progress to next league';
  String get leaderboard => _localizedValues[locale.languageCode]?['leaderboard'] ?? 'Leaderboard';
  String get players => _localizedValues[locale.languageCode]?['players'] ?? 'Players';
  String get level => _localizedValues[locale.languageCode]?['level'] ?? 'Level';
  // Добавьте эти геттеры в класс AppLocalizations:

  String get statisticsPlural => _localizedValues[locale.languageCode]?['statistics_plural'] ?? 'Statistics';
  String get edupeakPlus => _localizedValues[locale.languageCode]?['edupeak_plus'] ?? 'EduPeak+';
  String get premiumAccess => _localizedValues[locale.languageCode]?['premium_access'] ?? 'Premium Access';
  String get allFeatures => _localizedValues[locale.languageCode]?['all_features'] ?? 'All features';
  String get pricing => _localizedValues[locale.languageCode]?['pricing'] ?? 'Pricing';
  String get whatsIncluded => _localizedValues[locale.languageCode]?['whats_included'] ?? 'What\'s Included';
  String get featuresCount => _localizedValues[locale.languageCode]?['features_count'] ?? 'features';
  String get month => _localizedValues[locale.languageCode]?['month'] ?? 'Month';
  String get year => _localizedValues[locale.languageCode]?['year'] ?? 'Year';
  String get savings => _localizedValues[locale.languageCode]?['savings'] ?? 'Savings';
  String get noAds => _localizedValues[locale.languageCode]?['no_ads'] ?? 'No Ads';
  String get focusOnLearning => _localizedValues[locale.languageCode]?['focus_on_learning'] ?? 'Focus on learning';
  String get extendedMaterials => _localizedValues[locale.languageCode]?['extended_materials'] ?? 'Extended Materials';
  String get additionalResources => _localizedValues[locale.languageCode]?['additional_resources'] ?? 'Additional resources';
  String get tryFree => _localizedValues[locale.languageCode]?['try_free'] ?? 'Try free';
  String get comingSoon => _localizedValues[locale.languageCode]?['coming_soon'] ?? 'Coming soon';
  String get gotIt => _localizedValues[locale.languageCode]?['got_it'] ?? 'Got it';
  String get termsAndDefinitions => _localizedValues[locale.languageCode]?['terms_and_definitions'] ?? 'Terms and Definitions';
  String get allConcepts => _localizedValues[locale.languageCode]?['all_concepts'] ?? 'All concepts';
  String get developmentStatus => _localizedValues[locale.languageCode]?['development_status'] ?? 'Status';
  String get inDevelopment => _localizedValues[locale.languageCode]?['in_development'] ?? 'In Development';
  String get activelyDeveloped => _localizedValues[locale.languageCode]?['actively_developed'] ?? 'Actively developed';
  String get dictionaryPreview => _localizedValues[locale.languageCode]?['dictionary_preview'] ?? 'Dictionary Preview';
  String get subjectTerms => _localizedValues[locale.languageCode]?['subject_terms'] ?? 'Subject Terms';
  String get subjectConcepts => _localizedValues[locale.languageCode]?['subject_concepts'] ?? 'Subject concepts';
  String get detailedDefinitions => _localizedValues[locale.languageCode]?['detailed_definitions'] ?? 'Detailed Definitions';
  String get clearExplanations => _localizedValues[locale.languageCode]?['clear_explanations'] ?? 'Clear explanations';
  String get quickSearch => _localizedValues[locale.languageCode]?['quick_search'] ?? 'Quick Search';
  String get instantSearch => _localizedValues[locale.languageCode]?['instant_search'] ?? 'Instant search';
  String get favorites => _localizedValues[locale.languageCode]?['favorites'] ?? 'Favorites';
  String get saveImportant => _localizedValues[locale.languageCode]?['save_important'] ?? 'Save important';
  String get seeNews => _localizedValues[locale.languageCode]?['see_news'] ?? 'See news';
  String get section => _localizedValues[locale.languageCode]?['section'] ?? 'Section';
  String get helloWhatToStudy => _localizedValues[locale.languageCode]?['hello_what_to_study'] ?? 'Hello, what to study?';
  String get mySubjects => _localizedValues[locale.languageCode]?['my_subjects'] ?? 'My Subjects';
  String get management => _localizedValues[locale.languageCode]?['management'] ?? 'Management';
  String get addSubjects => _localizedValues[locale.languageCode]?['add_subjects'] ?? 'Add Subjects';
  String get removeSubjects => _localizedValues[locale.languageCode]?['remove_subjects'] ?? 'Remove Subjects';
  String get recommended => _localizedValues[locale.languageCode]?['recommended'] ?? 'Recommended';
  String get allSubjectsAdded => _localizedValues[locale.languageCode]?['all_subjects_added'] ?? 'All subjects added';
  String get allSubjectsMessage => _localizedValues[locale.languageCode]?['all_subjects_message'] ?? 'All subjects message';
  String get noSubjectsToRemove => _localizedValues[locale.languageCode]?['no_subjects_to_remove'] ?? 'No subjects to remove';
  String get addSubjectsMessage => _localizedValues[locale.languageCode]?['add_subjects_message'] ?? 'Add subjects message';
  String get noSelectedSubjects => _localizedValues[locale.languageCode]?['no_selected_subjects'] ?? 'No selected subjects';
  String get addSubjectsToLearn => _localizedValues[locale.languageCode]?['add_subjects_to_learn'] ?? 'Add subjects to learn';
  String get addSubjectsButton => _localizedValues[locale.languageCode]?['add_subjects_button'] ?? 'Add Subjects';
  String get startedTopics => _localizedValues[locale.languageCode]?['started_topics'] ?? 'Started Topics';
  String get studySomeTopics => _localizedValues[locale.languageCode]?['study_some_topics'] ?? 'Study some topics';
  String get startStudying => _localizedValues[locale.languageCode]?['start_studying'] ?? 'Start Studying';
  String get friendsCount => _localizedValues[locale.languageCode]?['friends'] ?? 'friends';
  String get since => _localizedValues[locale.languageCode]?['since'] ?? 'Since';
  String get studiedSubjects => _localizedValues[locale.languageCode]?['studied_subjects'] ?? 'Studied Subjects';
  String get achievementsCompleted => _localizedValues[locale.languageCode]?['achievements_completed'] ?? 'completed';
  String get xpEarned => _localizedValues[locale.languageCode]?['xp_earned'] ?? 'XP earned';
  String get topicsCompleted => _localizedValues[locale.languageCode]?['topics_completed'] ?? 'Topics completed';
  String get yourXp => _localizedValues[locale.languageCode]?['your_xp'] ?? 'Your XP';
  String get latestNews => _localizedValues[locale.languageCode]?['latest_news'] ?? 'Latest News';
  String get newUnread => _localizedValues[locale.languageCode]?['new_unread'] ?? 'NEW';
  String get read => _localizedValues[locale.languageCode]?['read'] ?? 'READ';
  String get updatedToday => _localizedValues[locale.languageCode]?['updated_today'] ?? 'Updated today';
  String get youreLegend => _localizedValues[locale.languageCode]?['youre_legend'] ?? 'You\'re legend';
  String get almostAtTop => _localizedValues[locale.languageCode]?['almost_at_top'] ?? 'Almost at top';
  String get excellentResult => _localizedValues[locale.languageCode]?['excellent_result'] ?? 'Excellent result';
  String get greatWorkTop => _localizedValues[locale.languageCode]?['great_work_top'] ?? 'Great work top';
  String get goodProgress => _localizedValues[locale.languageCode]?['good_progress'] ?? 'Good progress';
  String get notBadAimHigher => _localizedValues[locale.languageCode]?['not_bad_aim_higher'] ?? 'Not bad aim higher';
  String get goodStart => _localizedValues[locale.languageCode]?['good_start'] ?? 'Good start';
  String get beginnerAhead => _localizedValues[locale.languageCode]?['beginner_ahead'] ?? 'Beginner ahead';
  String get reviewQuestions => _localizedValues[locale.languageCode]?['review_questions'] ?? 'Review Questions';
  String get startedTopicsQuestions => _localizedValues[locale.languageCode]?['started_topics_questions'] ?? 'Started topics questions';
  String get startLearningTopics => _localizedValues[locale.languageCode]?['start_learning_topics'] ?? 'Start learning topics';
  String get gradesActive => _localizedValues[locale.languageCode]?['grades_active'] ?? 'Grades active';
  String get questionsTotal => _localizedValues[locale.languageCode]?['questions_total'] ?? 'Questions total';
  String get startedTopicsCount => _localizedValues[locale.languageCode]?['started_topics_count'] ?? 'Started topics count';
  String get subjectAdded => _localizedValues[locale.languageCode]?['subjectAdded'] ?? 'Subject added';
  String get subjectRemoved => _localizedValues[locale.languageCode]?['subjectRemoved'] ?? 'Subject removed';
  String get excellentProgress => _localizedValues[locale.languageCode]?['excellentProgress'] ?? 'Excellent progress';
  String get goodResult => _localizedValues[locale.languageCode]?['goodResult'] ?? 'Good result';
  String get youAlreadyHave => _localizedValues[locale.languageCode]?['youAlreadyHave'] ?? 'You already have';
  String get moveForward => _localizedValues[locale.languageCode]?['moveForward'] ?? 'Move forward';
  String get passFirstTestAndGetXP => _localizedValues[locale.languageCode]?['passFirstTestAndGetXP'] ?? 'Pass first test';
  String get noData => _localizedValues[locale.languageCode]?['noData'] ?? 'No data';
  String get mockFriend1Name => _localizedValues[locale.languageCode]?['mockFriend1Name'] ?? 'Alexander Ivanov';
  String get mockFriend2Name => _localizedValues[locale.languageCode]?['mockFriend2Name'] ?? 'Maria Petrova';
  String get mockFriend3Name => _localizedValues[locale.languageCode]?['mockFriend3Name'] ?? 'Ivan Sidorov';
  String get mockTestFriend1 => _localizedValues[locale.languageCode]?['mockTestFriend1'] ?? 'Test friend 1';
  String get unknown => _localizedValues[locale.languageCode]?['unknown'] ?? 'Unknown';
  String get noName => _localizedValues[locale.languageCode]?['noName'] ?? 'No name';
  String get inRow => _localizedValues[locale.languageCode]?['inRow'] ?? 'in a row';
  String get earned => _localizedValues[locale.languageCode]?['earned'] ?? 'earned';
  String get premium => _localizedValues[locale.languageCode]?['premium'] ?? 'Premium';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en', 'de'].contains(locale.languageCode);

  static const List<Locale> supportedLocales = [
    Locale('ru', 'RU'),
    Locale('en', 'US'),
    Locale('de', 'DE'),
    Locale('lt', 'LT'),
    Locale('vi', 'VN'),
    Locale('kz', 'KZ'),
  ];

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}