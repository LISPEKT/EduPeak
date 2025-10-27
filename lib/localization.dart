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
    },
    'en': {
      'app_title': 'EduPeak',
      'welcome': 'Welcome',
      'start_learning': 'Start Learning',
      'conquer_knowledge': 'Conquer Knowledge Peaks',
      'students': 'Students',
      'topics': 'Topics',
      'success': 'Success',
      'subjects': 'Subjects',
      'join_and_improve': 'Join and boost your brainpower',
      'exam_preparation': 'OGE/EGE Preparation • Olympiad Tasks',
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
    },
    'de': {
      'app_title': 'EduPeak',
      'welcome': 'Willkommen',
      'start_learning': 'Lernen beginnen',
      'conquer_knowledge': 'Erobere die Gipfel des Wissens',
      'students': 'Schüler',
      'topics': 'Themen',
      'success': 'Erfolg',
      'subjects': 'Fächer',
      'join_and_improve': 'Schließen Sie sich an und trainieren Sie Ihr Gehirn',
      'exam_preparation': 'OGE/EGE Vorbereitung • Olympiade-Aufgaben',
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
      'selectSubject': 'Betreff auswählen'
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
  String get allGrades => _localizedValues[locale.languageCode]?['all_classes'] ?? 'All classes';
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

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}