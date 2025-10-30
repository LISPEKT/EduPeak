// lib/data/social_studies/social_studies_data_en.dart
import '../../../models/topic.dart';
import '../../../models/question.dart';
import '../../../models/subject.dart';

// === GRADE 6 ===
final List<Subject> socialStudiesSubjects6 = [
  Subject(
    name: 'Social Studies',
    topicsByGrade: {
      6: [
        Topic(
          id: "social_studies_class6_topic1",
          name: 'Biological and Social in Man',
          imageAsset: '🧬',
          description: 'The ratio of natural and social qualities of a person',
          explanation: '''Key concepts of the topic:
• Heredity - the transmission of characteristic traits from parents to children through genes
• Instincts - innate patterns of behavior in animals and humans
• Biological beginning: physical qualities, emotions, needs for food, sleep, safety
• Social beginning: speech, thinking, culture, morality, rules of behavior
• Individual - a single representative of the human race
A person is born as a biological being, but becomes a person only in society.''',
          questions: [
            Question(
              text: 'What determines the behavior of animals?',
              options: ['Instincts', 'Consciousness', 'Culture', 'Education', 'Traditions'],
              correctIndex: 0,
              explanation: 'The behavior of animals is determined mainly by instincts - innate programs of behavior.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What is heredity?',
              options: [
                'Transmission of traits from parents to children',
                'Acquisition of knowledge in school',
                'Learning rules of behavior',
                'Development of abilities',
                'Formation of character'
              ],
              correctIndex: 0,
              explanation: 'Heredity is the transmission of characteristic traits of a species from parents to offspring through genes.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What biological traits does a person inherit?',
              options: [
                'Eye and hair color',
                'Body structure',
                'Features of emotions',
                'Language knowledge',
                'Cultural traditions',
                'Physical abilities'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Physical qualities and some features of the emotional sphere are inherited, but not social knowledge.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Why cannot feral children develop fully?',
              options: [
                'They do not receive social experience',
                'They have poor heredity',
                'They do not eat enough',
                'They live in a bad climate',
                'They do not have medical care',
                'They do not learn human speech'
              ],
              correctIndex: [0, 5],
              explanation: 'Without communication with people, a child does not acquire social skills, speech, culture, rules of behavior.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is necessary for the full development of a child?',
              options: [
                'Communication with people',
                'Upbringing and education',
                'Acquisition of culture',
                'Only nutrition and care',
                'Only heredity',
                'Social environment'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'For personality development, not only biological conditions are needed, but also social environment, communication, upbringing.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'How does a person differ from animals?',
              options: [
                'Ability to think',
                'Presence of speech',
                'Conscious activity',
                'Presence of instincts',
                'Need for food',
                'Creation of culture'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'The main differences are consciousness, speech, ability for purposeful activity and creation of culture.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is inherited?',
              options: [
                'Physical qualities',
                'Hair and eye color',
                'Features of temperament',
                'Knowledge and skills',
                'Moral principles',
                'Predisposition to diseases'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Biological characteristics are inherited, but not social knowledge and moral norms.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Is it possible to influence heredity?',
              options: [
                'Yes, through living conditions and upbringing',
                'No, heredity is unchangeable',
                'Only with the help of medicine',
                'Only in childhood',
                'Cannot be influenced in any way',
                'Through education and development'
              ],
              correctIndex: [0, 5],
              explanation: 'Although heredity determines potential, the development of abilities depends on living conditions, upbringing and education.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What are instincts?',
              options: [
                'Innate programs of behavior',
                'Acquired skills',
                'Conscious actions',
                'Cultural traditions',
                'Social norms',
                'Reflexes'
              ],
              correctIndex: 0,
              explanation: 'Instincts are complex innate patterns of behavior characteristic of a species.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Who are "feral children"?',
              options: [
                'Children raised among animals',
                'Children with special abilities',
                'Orphaned children',
                'Children from large families',
                'Children with disabilities',
                'Children raised by wolves'
              ],
              correctIndex: [0, 5],
              explanation: 'Feral children are children who, at an early age, were isolated from human society and grew up among animals.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What are genes?',
              options: [
                'Material carriers of heredity',
                'Units of learning',
                'Social norms',
                'Cultural traditions',
                'Acquired skills',
                'Elements of upbringing'
              ],
              correctIndex: 0,
              explanation: 'Genes are material carriers of hereditary information that are passed from parents to children.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What examples of animal instincts are given in the textbook?',
              options: [
                'Behavior of a cuckoo chick in a foreign nest',
                'Reaction of chicks to sounds',
                'Honeycomb construction by bees',
                'Learning at school',
                'Creation of works of art',
                'Sports activities'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'The textbook gives examples of instinctive behavior of cuckoo chicks, chicks and bees.',
              answerType: 'multiple_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic2",
          name: 'Man as a Person',
          imageAsset: '👤',
          description: 'The concept of personality and its formation',
          explanation: '''Key concepts of the topic:
• Personality - a person possessing consciousness, capable of activity and communication
• Individuality - a unique combination of a person's qualities
• Consciousness - the ability to think, evaluate oneself and the surrounding world
• Strong personality - a person with developed will, determination, capable of overcoming difficulties
• Self-esteem - a person's idea of their qualities and capabilities
Personality is formed in the process of activity, communication and upbringing.''',
          questions: [
            Question(
              text: 'Who is considered a person?',
              options: [
                'A person with consciousness and will',
                'Any person from birth',
                'Only famous people',
                'Only adults',
                'Only educated people',
                'A person capable of self-esteem'
              ],
              correctIndex: [0, 5],
              explanation: 'Personality is a person possessing consciousness, capable of activity, self-esteem and communication.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is individuality?',
              options: [
                'Unique qualities of a person',
                'Similarity to other people',
                'Average abilities',
                'Ordinary character traits',
                'Typical behavior',
                'Uniqueness of a person'
              ],
              correctIndex: [0, 5],
              explanation: 'Individuality is a unique combination of qualities that distinguishes a person from others.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What qualities characterize a strong personality?',
              options: [
                'Will and determination',
                'Strong musculature',
                'Wealth',
                'Fame',
                'Power',
                'Ability to overcome difficulties'
              ],
              correctIndex: [0, 5],
              explanation: 'A strong personality is manifested in volitional qualities, determination and ability to overcome difficulties.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is consciousness?',
              options: [
                'Ability to think and evaluate',
                'Physical strength',
                'Fast reaction',
                'Good memory',
                'Beautiful appearance',
                'Understanding of oneself and the world'
              ],
              correctIndex: [0, 5],
              explanation: 'Consciousness is a person\'s ability to think, understand oneself and the surrounding world, evaluate one\'s actions.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Can an animal be a person?',
              options: [
                'No, only a human',
                'Yes, some animals',
                'Only monkeys',
                'Only pets',
                'All living beings',
                'No, animals do not have consciousness'
              ],
              correctIndex: [0, 5],
              explanation: 'Only humans possess consciousness and can be a person. Animals act on the basis of instincts.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'When does a child begin to realize themselves as a person?',
              options: [
                'At 2-3 years old, when saying "I"',
                'Immediately after birth',
                'At school age',
                'In adolescence',
                'Only in adulthood',
                'When separating oneself from others'
              ],
              correctIndex: [0, 5],
              explanation: 'Self-awareness as a person begins when the child starts using the pronoun "I" and separating themselves from others.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What does it mean "to possess individuality"?',
              options: [
                'To have unique features',
                'To be like everyone else',
                'To obey others',
                'Not to have one\'s own opinion',
                'To follow fashion',
                'To be unique'
              ],
              correctIndex: [0, 5],
              explanation: 'Individuality is the uniqueness, distinctiveness of a person, their special qualities and abilities.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What qualities does a strong personality develop?',
              options: [
                'Will and perseverance',
                'Aggressiveness',
                'Cunning',
                'Laziness',
                'Irresponsibility',
                'Determination'
              ],
              correctIndex: [0, 5],
              explanation: 'A strong personality develops positive volitional qualities: will, perseverance, determination.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What helps to become a person?',
              options: [
                'Communication and activity',
                'Parents\' wealth',
                'Physical strength',
                'Beautiful appearance',
                'Luck',
                'Upbringing and education'
              ],
              correctIndex: [0, 5],
              explanation: 'Personality is formed through communication with others, various activities, upbringing and education.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Is it possible to become a person without communication with people?',
              options: [
                'No, it is impossible',
                'Yes, if reading a lot',
                'Yes, if possessing talent',
                'Yes, with good heredity',
                'Yes, with wealth',
                'No, social experience is needed'
              ],
              correctIndex: [0, 5],
              explanation: 'Without communication with people, it is impossible to acquire social experience, speech, culture and become a person.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What three questions help to understand if a person is a personality?',
              options: [
                'Can they control themselves',
                'Can they create their life',
                'Can they make themselves',
                'How much money they have',
                'What education they have',
                'What their social status is'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'Philosophers identify three key questions about self-control, self-determination and creation of life.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is self-esteem?',
              options: [
                'Assessment of one\'s qualities and capabilities',
                'Opinion of others about a person',
                'School grades',
                'Social status',
                'Financial position',
                'Self-concept'
              ],
              correctIndex: [0, 5],
              explanation: 'Self-esteem is a person\'s idea of their qualities, capabilities, place among other people.',
              answerType: 'multiple_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic3",
          name: 'Adolescence - A Special Time of Life',
          imageAsset: '🌟',
          description: 'Features of adolescence',
          explanation: '''Key concepts of the topic:
• Adolescence - period from 10-11 to 14-15 years
• Physical changes: rapid growth, change in body proportions
• Psychological features: mood swings, striving for independence
• Generation - a group of people of the same age, living at the same time
• Intergenerational relations - connections between different age groups
• Independence - an important indicator of adulthood
This is a time of active personality formation, self-discovery and finding one\'s place in life.''',
          questions: [
            Question(
              text: 'What is adolescence?',
              options: [
                'Teenage years',
                'Childhood age',
                'Adult age',
                'Old age',
                'Infant age',
                'Transitional period'
              ],
              correctIndex: [0, 5],
              explanation: 'Adolescence is the teenage years, a transitional period between childhood and youth.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What physical changes occur in adolescence?',
              options: [
                'Rapid growth',
                'Change in body proportions',
                'Voice change',
                'Stable growth',
                'Slowed development',
                'Formation of adult features'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Adolescence is characterized by rapid physical development and formation of adult features.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is a generation?',
              options: [
                'A group of people of the same age',
                'Family genealogy',
                'Historical period',
                'School class',
                'Group of friends',
                'People living at the same time'
              ],
              correctIndex: [0, 5],
              explanation: 'Generation is a group of people of approximately the same age, living at the same time and having common experience.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Why is adolescence called a transitional age?',
              options: [
                'Transition from childhood to adulthood',
                'Transition to another school',
                'Moving to another city',
                'Change of interests',
                'Change in appearance',
                'Period of personality formation'
              ],
              correctIndex: [0, 5],
              explanation: 'This is a transitional stage from childhood to adult life, a time of personality formation.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What psychological features are characteristic of teenagers?',
              options: [
                'Mood swings',
                'Striving for independence',
                'Need for communication',
                'Emotional stability',
                'Complete dependence on parents',
                'Search for one\'s place in life'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Teenagers are characterized by emotional instability, striving for independence and self-discovery.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is independence?',
              options: [
                'Ability to make decisions oneself',
                'Complete independence from everyone',
                'Refusal of others\' help',
                'Financial independence',
                'Living separately from parents',
                'Responsibility for one\'s actions'
              ],
              correctIndex: [0, 5],
              explanation: 'Independence is the ability to make responsible decisions and bear responsibility for one\'s actions.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'How do relations between generations develop?',
              options: [
                'Based on mutual respect',
                'Only through conflicts',
                'Without any communication',
                'Through subordination of younger ones',
                'Through rivalry',
                'Taking into account the experience of elders'
              ],
              correctIndex: [0, 5],
              explanation: 'Healthy intergenerational relations are built on mutual respect and taking into account the experience of older generations.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Why do teenagers strive for independence?',
              options: [
                'Want to feel adult',
                'Do not like parents',
                'Want to be independent',
                'Follow fashion',
                'Imitate friends',
                'Natural process of growing up'
              ],
              correctIndex: [0, 2, 5],
              explanation: 'Striving for independence is a natural manifestation of growing up, a desire to be independent.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What helps a teenager in personality formation?',
              options: [
                'Communication with peers',
                'Family support',
                'Learning activity',
                'Clubs and sections',
                'All of the above',
                'Development of interests and abilities'
              ],
              correctIndex: [4, 5],
              explanation: 'All aspects of a teenager\'s life contribute to the formation of their personality, development of interests and abilities.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is the significance of dreams in adolescence?',
              options: [
                'Helps to set goals',
                'Develops imagination',
                'Stimulates development',
                'Detaches from reality',
                'Interferes with studies',
                'Determines the future'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Dreams in adolescence play an important role in personal development and can determine the future.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What age stages are distinguished in human life?',
              options: [
                'Infancy',
                'Childhood',
                'Adolescence',
                'Youth',
                'Maturity',
                'All of the above'
              ],
              correctIndex: 5,
              explanation: 'Scientists distinguish consecutive age stages: infancy, childhood, adolescence, youth, maturity, old age.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What is hypodynamia and why is it dangerous?',
              options: [
                'Lack of physical activity',
                'Reduces immunity',
                'Leads to diseases',
                'Excess of movement',
                'Beneficial for health',
                'Improves well-being'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'Hypodynamia is insufficient physical activity, which is harmful to health.',
              answerType: 'multiple_choice',
            ),
          ],
        ),

        // Continuation for the remaining 16 topics in the same format...
        Topic(
          id: "social_studies_class6_topic4",
          name: 'Human Needs and Abilities',
          imageAsset: '🎯',
          description: 'Types of needs and development of abilities',
          explanation: '''Key concepts of the topic:
• Need - an awareness of needing something necessary
• Types of needs: biological, social, spiritual
• Abilities - individual features that help in activity
• Levels of abilities: giftedness, talent, genius
• Spiritual world - the inner world of thoughts and feelings of a person
• Emotions - experiences related to the satisfaction of needs
Needs motivate activity, and abilities help achieve goals.''',
          questions: [
            Question(
              text: 'What are needs?',
              options: [
                'Awareness of needing something',
                'Desires and whims',
                'Material goods',
                'Spiritual values',
                'Physical capabilities',
                'Necessary for life'
              ],
              correctIndex: [0, 5],
              explanation: 'A need is a person\'s awareness of needing what is necessary to maintain life and development.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What types of needs exist?',
              options: [
                'Biological',
                'Social',
                'Spiritual',
                'Only material',
                'Only physiological',
                'All listed except 4 and 5'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Three main types of needs are distinguished: biological, social and spiritual.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What are abilities?',
              options: [
                'Individual features of personality',
                'Conditions for successful activity',
                'Innate qualities',
                'Acquired knowledge',
                'Social status',
                'Developed skills'
              ],
              correctIndex: [0, 1, 5],
              explanation: 'Abilities are individual features of personality that are conditions for successful performance of activity.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What levels of ability development are distinguished?',
              options: [
                'Giftedness',
                'Talent',
                'Genius',
                'Average abilities',
                'Absence of abilities',
                'Highest level of development'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'Scientists distinguish levels: giftedness, talent and genius as the highest level.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is the spiritual world of a person?',
              options: [
                'Inner world of thoughts and feelings',
                'Material wealth',
                'Social position',
                'Physical health',
                'External beauty',
                'World of values and ideals'
              ],
              correctIndex: [0, 5],
              explanation: 'Spiritual world is the inner world of a person, the world of their thoughts, feelings, values and ideals.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What refers to biological needs?',
              options: [
                'Need for food',
                'Need for sleep',
                'Need for water',
                'Need for communication',
                'Need for knowledge',
                'Need for safety'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Biological needs are natural needs of the organism, necessary for survival.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What are inclinations?',
              options: [
                'Natural prerequisites of abilities',
                'Acquired skills',
                'Social conditions',
                'Material goods',
                'Ready abilities',
                'Innate features'
              ],
              correctIndex: [0, 5],
              explanation: 'Inclinations are natural prerequisites of abilities, innate anatomical and physiological features.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What are emotions?',
              options: [
                'Experiences and feelings',
                'Rational thoughts',
                'Logical conclusions',
                'Objective facts',
                'Scientific knowledge',
                'Subjective reactions'
              ],
              correctIndex: [0, 5],
              explanation: 'Emotions are a person\'s experiences related to the satisfaction or dissatisfaction of needs.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What kinds of feelings exist?',
              options: [
                'Moral',
                'Aesthetic',
                'Intellectual',
                'Only positive',
                'Only negative',
                'Higher feelings'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Moral, aesthetic and intellectual feelings are distinguished as higher feelings of a person.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What are imaginary needs?',
              options: [
                'Imposed by advertising',
                'Artificial desires',
                'Genuine needs',
                'Natural needs',
                'Necessary for life',
                'Prestigious consumption'
              ],
              correctIndex: [0, 1, 5],
              explanation: 'Imaginary needs are imposed, artificial desires, often related to prestigious consumption.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'How do abilities develop?',
              options: [
                'In the process of learning',
                'Through activity',
                'Only by heredity',
                'Independently',
                'Without effort',
                'With the presence of inclinations'
              ],
              correctIndex: [0, 1, 5],
              explanation: 'Abilities develop in the process of learning and activity with the presence of natural inclinations.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What is genius?',
              options: [
                'Highest level of abilities',
                'Average abilities',
                'Absence of talent',
                'Ordinary skills',
                'Acquired skills',
                'Outstanding achievements'
              ],
              correctIndex: [0, 5],
              explanation: 'Genius is the highest level of ability development, allowing to create outstanding creations.',
              answerType: 'multiple_choice',
            ),
          ],
        ),

        // Similarly continue for all remaining 15 topics...
        // Topic 5: If Opportunities Are Limited
        // Topic 6: Activity and Diversity of Its Types
        // Topic 7: Man's Cognition of the World and Himself
        // Topic 8: Communication
        // Topic 9: Conflicts and Their Resolution
        // Topic 10: Man in a Small Group
        // Topic 11: Family and Family Relations
        // Topic 12: School Education
        // Topic 13: How Society Is Structured
        // Topic 14: Our Country in the 21st Century
        // Topic 15: Economy - Foundation of Society's Life
        // Topic 16: Social Sphere of Society's Life
        // Topic 17: World of Politics
        // Topic 18: Culture and Its Achievements
        // Topic 19: Development of Society

        Topic(
          id: "social_studies_class6_topic5",
          name: 'If Opportunities Are Limited',
          imageAsset: '♿',
          description: 'Special needs and assistance for people with disabilities',
          explanation: '''Key concepts of the topic:
• Limited opportunities - conditions that hinder normal life activities
• Special needs - additional conditions for a full life
• Inclusion - inclusion of people with limitations into normal society life
• Adaptation - adjustment to living conditions
• Rehabilitation - restoration of lost capabilities
• Volunteering - voluntary help for those in need
Every person deserves respect and support regardless of their capabilities.''',
          questions: [
            Question(
              text: 'What are limited opportunities?',
              options: [
                'Conditions that hinder normal life',
                'Lack of abilities',
                'Laziness and lack of will',
                'Poverty',
                'Lack of education',
                'Health features'
              ],
              correctIndex: [0, 5],
              explanation: 'Limited opportunities are health conditions that hinder normal life activities.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'What special needs do people with limited opportunities have?',
              options: [
                'Additional help',
                'Special learning conditions',
                'Technical means',
                'Psychological support',
                'Medical help',
                'All of the above'
              ],
              correctIndex: 5,
              explanation: 'People with limited opportunities need comprehensive help and special conditions.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What is inclusion?',
              options: ['inclusion in society', 'Inclusion', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Inclusion is the inclusion of people with limited opportunities into normal society life.',
              answerType: 'text',
            ),
            Question(
              text: 'Who is Eduard Asadov?',
              options: [
                'A poet who lost his sight in the war',
                'Paralympic athlete',
                'Scientist',
                'Politician',
                'Artist',
                'Writer'
              ],
              correctIndex: 0,
              explanation: 'Eduard Asadov is a famous poet who lost his sight during the Great Patriotic War but continued to create.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What helps expand opportunities for people with limitations?',
              options: [
                'Knowledge and skills',
                'Willpower',
                'Support from others',
                'Special devices',
                'All of the above',
                'Only medical help'
              ],
              correctIndex: 4,
              explanation: 'To expand opportunities, knowledge, will, support and special means are needed.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Voluntary help for those in need is ______.',
              options: ['volunteering', 'Volunteering', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Volunteering is voluntary, unpaid help for people who need it.',
              answerType: 'text',
            ),
            Question(
              text: 'What is the Theater of Mime and Gesture?',
              options: [
                'Theater for deaf actors',
                'Regular drama theater',
                'Puppet theater',
                'Street theater',
                'Circus performance',
                'Musical theater'
              ],
              correctIndex: 0,
              explanation: 'The Theater of Mime and Gesture is a unique theater where deaf actors perform.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'How can we help people with limited opportunities?',
              options: [
                'Show attention',
                'Offer help',
                'Create accessible environment',
                'Treat with respect',
                'All of the above',
                'Ignore their problems'
              ],
              correctIndex: 4,
              explanation: 'Help includes attention, specific assistance, creating an accessible environment and respectful attitude.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'The process of adjustment to living conditions is ______.',
              options: ['adaptation', 'Adaptation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Adaptation is the process of a person\'s adjustment to changing living conditions.',
              answerType: 'text',
            ),
            Question(
              text: 'What is a ramp?',
              options: [
                'Inclined platform for wheelchairs',
                'Stairs',
                'Elevator',
                'Escalator',
                'Sidewalk',
                'Road'
              ],
              correctIndex: 0,
              explanation: 'A ramp is an inclined platform that provides accessibility to buildings for people in wheelchairs.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Restoration of lost capabilities is ______.',
              options: ['rehabilitation', 'Rehabilitation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Rehabilitation is a set of measures to restore lost functions and capabilities.',
              answerType: 'text',
            ),
            Question(
              text: 'Who are volunteers?',
              options: [
                'Voluntary helpers',
                'Professional workers',
                'Civil servants',
                'Businessmen',
                'Politicians',
                'Military personnel'
              ],
              correctIndex: 0,
              explanation: 'Volunteers are people who voluntarily and without payment help those in need.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic6",
          name: 'Activity and Diversity of Its Types',
          imageAsset: '⚙️',
          description: 'The concept of activity and its main types',
          explanation: '''Key concepts of the topic:
• Activity - conscious human activity
• Main types: play, learning, work, communication
• Structure of activity: goal, means, actions, result
• Work - activity to create material and spiritual values
• Play - activity important for children\'s development
• Learning - process of acquiring knowledge and skills
Activity distinguishes humans from animals and allows transforming the world.''',
          questions: [
            Question(
              text: 'Conscious human activity is ______.',
              options: ['activity', 'Activity', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Activity is conscious, purposeful human activity.',
              answerType: 'text',
            ),
            Question(
              text: 'What main types of activity are distinguished?',
              options: [
                'Play',
                'Learning',
                'Work',
                'Communication',
                'All of the above',
                'Only work'
              ],
              correctIndex: 4,
              explanation: 'Main types of activity: play, learning, work and communication.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What is the goal of activity?',
              options: [
                'Desired result',
                'Means of achievement',
                'Work process',
                'Mistakes and failures',
                'Random events',
                'Unconscious actions'
              ],
              correctIndex: 0,
              explanation: 'Goal is a conscious image of the desired result for which the activity is carried out.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Activity to create values is ______.',
              options: ['work', 'Work', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Work is human activity aimed at creating material and spiritual values.',
              answerType: 'text',
            ),
            Question(
              text: 'What is play as a type of activity?',
              options: [
                'Activity for the sake of process',
                'Serious work',
                'Compulsory occupation',
                'Useless pastime',
                'Only children\'s entertainment',
                'Method of learning'
              ],
              correctIndex: [0, 5],
              explanation: 'Play is activity whose motive is in the process itself, and also an important method of learning and development.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'The process of acquiring knowledge and skills is ______.',
              options: ['learning', 'Learning', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Learning is activity to master knowledge, skills and abilities.',
              answerType: 'text',
            ),
            Question(
              text: 'What elements does the structure of activity include?',
              options: [
                'Goal',
                'Means',
                'Actions',
                'Result',
                'All of the above',
                'Only goal and result'
              ],
              correctIndex: 4,
              explanation: 'The structure of activity includes goal, means, actions and result.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'How does human activity differ from animal behavior?',
              options: [
                'Consciousness and purposefulness',
                'Presence of instincts',
                'Need for food',
                'Ability to move',
                'All of the above',
                'Only brain size'
              ],
              correctIndex: 0,
              explanation: 'The main difference is consciousness, purposefulness and ability to plan activity.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What are means of activity?',
              options: [
                'Tools and instruments',
                'Knowledge and skills',
                'Material resources',
                'All of the above',
                'Only physical strength',
                'Only money'
              ],
              correctIndex: 3,
              explanation: 'Means of activity include tools, knowledge, skills and material resources.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What type of activity is main for a school student?',
              options: ['learning', 'Learning', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'For a school student, the main type of activity is learning, as it is through it that development and preparation for adult life occurs.',
              answerType: 'text',
            ),
            Question(
              text: 'What is the result of activity?',
              options: [
                'Final product of activity',
                'Beginning of new activity',
                'Work process',
                'Action planning',
                'Means of achievement',
                'Goal of activity'
              ],
              correctIndex: 0,
              explanation: 'Result is the final product, outcome of activity that can be evaluated.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Why is play important for children?',
              options: [
                'Develops imagination',
                'Teaches rules of behavior',
                'Helps master social roles',
                'All of the above',
                'Only entertains',
                'Distracts from studies'
              ],
              correctIndex: 3,
              explanation: 'Play performs important developmental functions: develops imagination, teaches rules and social roles.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic7",
          name: 'Man\'s Cognition of the World and Himself',
          imageAsset: '🔍',
          description: 'The process of cognition and self-cognition',
          explanation: '''Key concepts of the topic:
• Cognition - process of acquiring knowledge about the world
• Self-cognition - studying oneself, one\'s abilities
• Self-esteem - assessment of one\'s qualities and capabilities
• Self-development - work on self-improvement
• Abilities - individual features of personality
• Talent - outstanding abilities in a certain area
Cognition of oneself helps to find one\'s place in life and realize potential.''',
          questions: [
            Question(
              text: 'The process of acquiring knowledge about the world is ______.',
              options: ['cognition', 'Cognition', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Cognition is the process of acquiring knowledge about the surrounding world and about oneself.',
              answerType: 'text',
            ),
            Question(
              text: 'What is self-cognition?',
              options: [
                'Studying oneself',
                'Cognition of nature',
                'Studying society',
                'Scientific research',
                'Artistic creativity',
                'Communication with others'
              ],
              correctIndex: 0,
              explanation: 'Self-cognition is a person\'s study of their own qualities, abilities, capabilities.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'A person\'s assessment of their qualities is ______.',
              options: ['self-esteem', 'Self-esteem', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Self-esteem is a person\'s assessment of themselves, their capabilities, qualities and place among other people.',
              answerType: 'text',
            ),
            Question(
              text: 'What sources of world cognition exist?',
              options: [
                'Direct experience',
                'Learning from others',
                'Books and internet',
                'Observation and experiment',
                'All of the above',
                'Only school lessons'
              ],
              correctIndex: 4,
              explanation: 'A person cognizes the world through personal experience, learning, books, observations and other sources.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What is self-development?',
              options: [
                'Work on self-improvement',
                'Studying other people',
                'Criticism of others',
                'Passive waiting for changes',
                'Imitation of celebrities',
                'Following fashion'
              ],
              correctIndex: 0,
              explanation: 'Self-development is conscious work of a person on improving their qualities and abilities.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'The process of realizing one\'s inclinations and their realization is ______.',
              options: ['self-realization', 'Self-realization', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Self-realization is the process of realizing and realizing one\'s abilities and potential.',
              answerType: 'text',
            ),
            Question(
              text: 'What helps in self-cognition?',
              options: [
                'Self-analysis',
                'Feedback from others',
                'Keeping a diary',
                'All of the above',
                'Only intuition',
                'Only tests'
              ],
              correctIndex: 3,
              explanation: 'Self-cognition is helped by self-analysis, feedback, keeping a diary and other methods.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What is low self-esteem?',
              options: [
                'Underestimation of one\'s capabilities',
                'Adequate self-assessment',
                'Overestimated opinion of oneself',
                'Objective assessment',
                'Realistic view',
                'Self-confidence'
              ],
              correctIndex: 0,
              explanation: 'Low self-esteem is a person\'s underestimation of their abilities and capabilities.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Work on improving one\'s character is ______.',
              options: ['self-education', 'Self-education', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Self-education is conscious work of a person on forming positive qualities in themselves.',
              answerType: 'text',
            ),
            Question(
              text: 'What are abilities?',
              options: [
                'Individual features of personality',
                'Innate qualities',
                'Acquired knowledge',
                'All of the above',
                'Only talents',
                'Only skills'
              ],
              correctIndex: 3,
              explanation: 'Abilities are individual features of personality, including innate inclinations and acquired skills.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'How to find one\'s calling?',
              options: [
                'Try different types of activities',
                'Study one\'s interests',
                'Develop abilities',
                'All of the above',
                'Wait for chance',
                'Follow fashion'
              ],
              correctIndex: 3,
              explanation: 'To find a calling, one needs to try different activities, study oneself and develop abilities.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Outstanding abilities in a certain area are ______.',
              options: ['talent', 'Talent', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Talent is a high level of ability development in a certain activity.',
              answerType: 'text',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic8",
          name: 'Communication',
          imageAsset: '💬',
          description: 'The essence and types of communication',
          explanation: '''Key concepts of the topic:
• Communication - process of establishing contacts between people
• Types of communication: verbal and non-verbal
• Means of communication: speech, gestures, facial expressions
• Culture of communication - observance of rules during interaction
• Interpersonal relations - connections between people
• Conflict - clash of opposing interests
Communication is necessary for personality development and successful life in society.''',
          questions: [
            Question(
              text: 'The process of establishing contacts between people is ______.',
              options: ['communication', 'Communication', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Communication is the process of establishing and developing contacts between people.',
              answerType: 'text',
            ),
            Question(
              text: 'What types of communication exist?',
              options: [
                'Verbal',
                'Non-verbal',
                'Written',
                'All of the above',
                'Only oral',
                'Only gestural'
              ],
              correctIndex: 3,
              explanation: 'Verbal, non-verbal and written communication exist.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Communication with the help of words is called ______.',
              options: ['verbal', 'Verbal', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Verbal communication is communication with the help of words (oral and written speech).',
              answerType: 'text',
            ),
            Question(
              text: 'What refers to non-verbal communication?',
              options: [
                'Gestures',
                'Facial expressions',
                'Posture',
                'Intonation',
                'All of the above',
                'Only words'
              ],
              correctIndex: 4,
              explanation: 'Non-verbal communication includes gestures, facial expressions, postures, intonation and other non-verbal means.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Form of people\'s communication through language is ______.',
              options: ['speech', 'Speech', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Speech is a form of people\'s communication through language.',
              answerType: 'text',
            ),
            Question(
              text: 'What functions does communication perform?',
              options: [
                'Exchange of information',
                'Transmission of experience',
                'Expression of emotions',
                'Organization of joint activity',
                'All of the above',
                'Only transmission of information'
              ],
              correctIndex: 4,
              explanation: 'Communication performs informational, emotional, regulatory and other important functions.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Observance of rules when interacting with people is culture of ______.',
              options: ['communication', 'Communication', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Culture of communication is observance of rules and norms when interacting with people.',
              answerType: 'text',
            ),
            Question(
              text: 'What are interpersonal relations?',
              options: [
                'Connections between people',
                'Relations between states',
                'Economic connections',
                'Political relations',
                'Business contacts',
                'Only friendly relations'
              ],
              correctIndex: 0,
              explanation: 'Interpersonal relations are interconnections between people in the process of joint activity and communication.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What should a good interlocutor be like?',
              options: [
                'Be able to listen',
                'Show attention',
                'Respect others\' opinions',
                'All of the above',
                'Only talk a lot',
                'Only criticize'
              ],
              correctIndex: 3,
              explanation: 'A good interlocutor is able to listen, shows attention and respect to others.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Expression of a person\'s face is ______.',
              options: ['facial expressions', 'Facial expressions', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Facial expressions are movements of facial muscles expressing a person\'s inner state.',
              answerType: 'text',
            ),
            Question(
              text: 'Why is communication important for a person?',
              options: [
                'For information exchange',
                'For emotional support',
                'For joint activity',
                'All of the above',
                'Only for entertainment',
                'Only for work'
              ],
              correctIndex: 3,
              explanation: 'Communication is necessary for information exchange, emotional support and organization of joint activity.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Movements of hands during communication are ______.',
              options: ['gestures', 'Gestures', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Gestures are movements of hands and other body parts used during communication.',
              answerType: 'text',
            ),
          ],
        ),
        Topic(
          id: "social_studies_class6_topic9",
          name: 'Conflicts and Their Resolution',
          imageAsset: '⚡',
          description: 'Causes of conflicts and ways to resolve them',
          explanation: '''Key concepts of the topic:
• Conflict - clash of interests, opinions
• Causes: differences in goals, misunderstanding, limited resources
• Constructive conflict - leading to problem solution
• Behavior strategies: cooperation, compromise, avoidance
• Mediation - assistance of a third party in conflict resolution
• Integration - unification of positions after conflict
The ability to resolve conflicts is an important social skill.''',
          questions: [
            Question(
              text: 'Clash of opposing interests is ______.',
              options: ['conflict', 'Conflict', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Conflict is a clash of opposing interests, views, positions.',
              answerType: 'text',
            ),
            Question(
              text: 'What can be the causes of conflicts?',
              options: [
                'Differences in interests',
                'Misunderstanding',
                'Limited resources',
                'Opposite goals',
                'All of the above',
                'Only personal dislike'
              ],
              correctIndex: 4,
              explanation: 'Causes of conflicts include all the listed factors.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'An incident or occurrence that may lead to conflict is ______.',
              options: ['incident', 'Incident', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Incident is a case, occurrence, misunderstanding that may lead to conflict.',
              answerType: 'text',
            ),
            Question(
              text: 'What methods of conflict resolution are constructive?',
              options: [
                'Compromise',
                'Cooperation',
                'Negotiations',
                'Aggression',
                'Avoidance',
                'Coercion'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'Constructive methods: compromise, cooperation, negotiations.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Formation of a unified opinion in conflict is ______.',
              options: ['integration', 'Integration', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Integration in the conflict process means formation of a unified opinion as a result of changing positions of the parties.',
              answerType: 'text',
            ),
            Question(
              text: 'What is compromise?',
              options: [
                'Mutual concessions to achieve agreement',
                'Complete victory of one side',
                'Avoidance of problem solution',
                'Coercion to agreement',
                'Ignoring the conflict',
                'Break of relations'
              ],
              correctIndex: 0,
              explanation: 'Compromise is mutual concessions of parties to achieve agreement in conflict.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Assistance of a third party in conflict resolution is ______.',
              options: ['mediation', 'Mediation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Mediation is participation of a neutral person in resolving conflict between parties.',
              answerType: 'text',
            ),
            Question(
              text: 'What behavior strategies in conflict exist?',
              options: [
                'Competition',
                'Cooperation',
                'Compromise',
                'Avoidance',
                'Accommodation',
                'All of the above'
              ],
              correctIndex: 5,
              explanation: 'Five main behavior strategies in conflict are distinguished.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What is constructive conflict?',
              options: [
                'Conflict leading to problem solution',
                'Conflict with use of force',
                'Conflict without solution',
                'Hidden conflict',
                'Long-term conflict',
                'Interpersonal conflict'
              ],
              correctIndex: 0,
              explanation: 'Constructive conflict helps to identify and solve the problem, improve relations.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Way of solving conflict through mutual concessions is ______.',
              options: ['compromise', 'Compromise', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Compromise is a way of solving conflict through mutual concessions of parties.',
              answerType: 'text',
            ),
            Question(
              text: 'What communication barriers can lead to conflict?',
              options: [
                'Semantic barrier',
                'Emotional barrier',
                'Moral barrier',
                'All of the above',
                'Only language barrier',
                'Only age barrier'
              ],
              correctIndex: 3,
              explanation: 'All listed barriers can become causes of misunderstanding and conflicts.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Refusal to continue conflict is ______.',
              options: ['avoidance', 'Avoidance', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Avoidance is a behavior strategy in conflict when a person avoids confrontation.',
              answerType: 'text',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic10",
          name: 'Man in a Small Group',
          imageAsset: '👥',
          description: 'Position of a person in a group and group relations',
          explanation: '''Key concepts of the topic:
• Small group - small association of people (family, class, friends)
• Leader - person who influences the group
• Group norms - rules of behavior in the group
• Role - position of a person in the group
• Collective - group united by common goals
• Volunteering - voluntary activity for the benefit of others
The group influences personality development and formation of values.''',
          questions: [
            Question(
              text: 'Small association of people is ______ group.',
              options: ['small', 'Small', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Small group is a small in composition association of people connected by common activity.',
              answerType: 'text',
            ),
            Question(
              text: 'What examples of small groups do you know?',
              options: [
                'Family',
                'School class',
                'Friend company',
                'Sports team',
                'All of the above',
                'Only large organizations'
              ],
              correctIndex: 4,
              explanation: 'All listed are examples of small groups.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Person who influences the group is ______.',
              options: ['leader', 'Leader', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Leader is a group member who influences others and organizes their activity.',
              answerType: 'text',
            ),
            Question(
              text: 'What are group norms?',
              options: [
                'Rules of behavior in the group',
                'State laws',
                'Moral principles',
                'Personal beliefs',
                'Random actions',
                'Individual habits'
              ],
              correctIndex: 0,
              explanation: 'Group norms are rules and standards of behavior accepted in a specific group.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Position of a person in the group is their ______.',
              options: ['role', 'Role', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Role is a person\'s position in the group, determining their rights and duties.',
              answerType: 'text',
            ),
            Question(
              text: 'What is a collective?',
              options: [
                'Group with common goals',
                'Random association',
                'Crowd of people',
                'Queue in a store',
                'Bus passengers',
                'People at a concert'
              ],
              correctIndex: 0,
              explanation: 'Collective is a group of people united by common goals and joint activity.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'What qualities are important for a leader?',
              options: [
                'Responsibility',
                'Organizational abilities',
                'Ability to communicate',
                'All of the above',
                'Only physical strength',
                'Only wealth'
              ],
              correctIndex: 3,
              explanation: 'A leader needs responsibility, organizational abilities and ability to communicate with people.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Group united by common goals is ______.',
              options: ['collective', 'Collective', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Collective is a group united by common goals and joint activity.',
              answerType: 'text',
            ),
            Question(
              text: 'Why do people unite in groups?',
              options: [
                'To achieve common goals',
                'For communication and support',
                'To protect interests',
                'All of the above',
                'Only by coercion',
                'Only due to loneliness'
              ],
              correctIndex: 3,
              explanation: 'People unite in groups to achieve goals, communication, support and protection of interests.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Rules of behavior in the group are group ______.',
              options: ['norms', 'Norms', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Group norms are rules of behavior accepted in a specific group.',
              answerType: 'text',
            ),
            Question(
              text: 'What is the Timur movement?',
              options: [
                'Help for those in need',
                'Political organization',
                'Sports movement',
                'Commercial structure',
                'Religious community',
                'Scientific society'
              ],
              correctIndex: 0,
              explanation: 'Timur movement is a children\'s movement for providing help to those in need, which emerged after the publication of the book "Timur and His Team".',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Voluntary help to others is ______.',
              options: ['volunteering', 'Volunteering', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Volunteering is voluntary, unpaid activity for the benefit of other people.',
              answerType: 'text',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic11",
          name: 'Family and Family Relations',
          imageAsset: '🏠',
          description: 'Family as a small group and family values',
          explanation: '''Key concepts of the topic:
• Family - small group based on marriage or kinship
• Functions of family: upbringing, household, emotional
• Family traditions - customs passed from generation to generation
• Generation - people of the same age in a family
• Family values - important principles and beliefs for the family
• Mutual understanding - foundation of harmonious family relations
Family plays a key role in the formation of a person\'s personality.''',
          questions: [
            Question(
              text: 'Small group based on marriage or kinship is ______.',
              options: ['family', 'Family', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Family is a small group based on marriage, blood kinship or adoption.',
              answerType: 'text',
            ),
            Question(
              text: 'What functions does the family perform?',
              options: [
                'Upbringing',
                'Household',
                'Emotional',
                'Reproductive',
                'All of the above',
                'Only economic'
              ],
              correctIndex: 4,
              explanation: 'Family performs many functions: upbringing, household, emotional, reproductive and others.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Customs passed in the family from generation to generation are family ______.',
              options: ['traditions', 'Traditions', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Family traditions are customs, rituals, rules of behavior passed in the family from generation to generation.',
              answerType: 'text',
            ),
            Question(
              text: 'What types of families exist by composition?',
              options: [
                'Complete',
                'Incomplete',
                'Large',
                'Small',
                'All of the above',
                'Only traditional'
              ],
              correctIndex: 4,
              explanation: 'Families differ by composition: complete, incomplete, large, small and others.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'People of the same age in a family are ______.',
              options: ['generation', 'Generation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Generation is a group of people of the same age in a family or society.',
              answerType: 'text',
            ),
            Question(
              text: 'What is a three-generation family?',
              options: [
                'Family where children, parents and grandparents live together',
                'Family with three children',
                'Family existing for three generations',
                'Young family',
                'Family without children',
                'Family with adopted children'
              ],
              correctIndex: 0,
              explanation: 'Three-generation family is a family in which three generations of relatives live together.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Important principles and beliefs for the family are family ______.',
              options: ['values', 'Values', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Family values are important principles, beliefs and traditions for the family.',
              answerType: 'text',
            ),
            Question(
              text: 'What types of family relations exist?',
              options: [
                'Cooperation',
                'Guardianship',
                'Non-interference',
                'Dictatorship',
                'All of the above',
                'Only democratic'
              ],
              correctIndex: 4,
              explanation: 'Different types of relations can develop in families: cooperation, guardianship, non-interference, dictatorship.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Foundation of harmonious family relations is ______.',
              options: ['mutual understanding', 'Mutual understanding', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Mutual understanding is the ability to understand each other, foundation of harmonious family relations.',
              answerType: 'text',
            ),
            Question(
              text: 'What are family duties?',
              options: [
                'Duties of family members for household management',
                'State duties',
                'Professional duties',
                'Educational duties',
                'Social duties',
                'Personal matters'
              ],
              correctIndex: 0,
              explanation: 'Family duties are distribution of tasks and responsibilities among family members.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Joint dinner or reading books in the family is an example of family ______.',
              options: ['traditions', 'Traditions', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Joint meals, reading, rest are examples of family traditions that strengthen relations.',
              answerType: 'text',
            ),
            Question(
              text: 'Why is it important to respect elders in the family?',
              options: [
                'They have life experience',
                'They care for younger ones',
                'They pass on traditions',
                'All of the above',
                'Only out of politeness',
                'Only by duty'
              ],
              correctIndex: 3,
              explanation: 'Elder family members possess experience, care for younger ones and pass on family traditions.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic12",
          name: 'School Education',
          imageAsset: '🎓',
          description: 'Right to education and school life',
          explanation: '''Key concepts of the topic:
• Education - process of learning and upbringing
• Right to education - one of the basic human rights
• Universal accessibility - possibility to receive education for all
• Compulsoriness - requirement to receive education
• Student duties - rules of behavior in school
• Ability to learn - important skill for successful studies
Education plays a key role in the development of personality and society.''',
          questions: [
            Question(
              text: 'Process of learning and upbringing is ______.',
              options: ['education', 'Education', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Education is a purposeful process of learning and upbringing in the interests of the person and society.',
              answerType: 'text',
            ),
            Question(
              text: 'What does the right to education guarantee in Russia?',
              options: [
                'Universal accessibility',
                'Free of charge',
                'Compulsoriness',
                'All of the above',
                'Only paid education',
                'Only for some'
              ],
              correctIndex: 3,
              explanation: 'The Constitution guarantees universal accessibility, free of charge and compulsoriness of education.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Possibility to receive education for all is ______.',
              options: ['universal accessibility', 'Universal accessibility', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Universal accessibility of education means that everyone has the right to education regardless of various circumstances.',
              answerType: 'text',
            ),
            Question(
              text: 'What levels of general education exist in Russia?',
              options: [
                'Primary general',
                'Basic general',
                'Secondary general',
                'All of the above',
                'Only primary',
                'Only higher'
              ],
              correctIndex: 3,
              explanation: 'The system of general education includes primary, basic and secondary general education.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Requirement to receive education is its ______.',
              options: ['compulsoriness', 'Compulsoriness', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Compulsoriness of education means that all children must receive education in the established volume.',
              answerType: 'text',
            ),
            Question(
              text: 'What is the school charter?',
              options: [
                'Main document of the school',
                'List of teachers',
                'Lesson schedule',
                'School newspaper',
                'Graduates\' photos',
                'School library'
              ],
              correctIndex: 0,
              explanation: 'School charter is the main document defining rights and duties of participants in the educational process.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Rules of behavior in school are student ______.',
              options: ['duties', 'Duties', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Student duties include rules of behavior that students must observe.',
              answerType: 'text',
            ),
            Question(
              text: 'What rights do students have?',
              options: [
                'Right to receive education',
                'Right to respect of their dignity',
                'Right to participate in school management',
                'All of the above',
                'Only right to rest',
                'Only right to nutrition'
              ],
              correctIndex: 3,
              explanation: 'Students have a complex of rights including receiving education, respect of dignity, participation in school management.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Important skill for successful studies is ability to ______.',
              options: ['learn', 'Learn', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Ability to learn is the capacity to independently acquire knowledge, important for successful studies.',
              answerType: 'text',
            ),
            Question(
              text: 'What is self-education?',
              options: [
                'Independent acquisition of knowledge',
                'Learning at school',
                'Classes with a tutor',
                'Homework completion',
                'Participation in olympiads',
                'Attendance of clubs'
              ],
              correctIndex: 0,
              explanation: 'Self-education is independent study of material, acquisition of knowledge without a teacher\'s help.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Main type of activity for a school student is ______.',
              options: ['learning', 'Learning', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'For a school student, the main type of activity is learning, as it is through it that development occurs.',
              answerType: 'text',
            ),
            Question(
              text: 'Why is it important to study conscientiously?',
              options: [
                'To acquire knowledge',
                'To develop abilities',
                'To prepare for future life',
                'All of the above',
                'Only for good grades',
                'Only so parents don\'t scold'
              ],
              correctIndex: 3,
              explanation: 'Conscientious study is important for acquiring knowledge, developing abilities and preparing for adult life.',
              answerType: 'single_choice',
            ),
          ],
        ),

        // Continuation for the remaining 7 topics...
        Topic(
          id: "social_studies_class6_topic13",
          name: 'How Society Is Structured',
          imageAsset: '🏛️',
          description: 'Structure of society and social relations',
          explanation: '''Key concepts of the topic:
• Society - association of people having common interests
• Social relations - connections between people in society
• Spheres of society life: economic, political, social, spiritual
• Social groups - stable associations of people
• Social norms - rules of behavior in society
• Social control - mechanism of maintaining order
Society is a complex system in which all elements are interconnected.''',
          questions: [
            Question(
              text: 'Association of people having common interests is ______.',
              options: ['society', 'Society', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Society is an association of people connected by common interests, goals and activity.',
              answerType: 'text',
            ),
            Question(
              text: 'What spheres of society life are distinguished?',
              options: [
                'Economic',
                'Political',
                'Social',
                'Spiritual',
                'All of the above',
                'Only economic and political'
              ],
              correctIndex: 4,
              explanation: 'Four main spheres of society life are distinguished: economic, political, social and spiritual.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Connections between people in society are social ______.',
              options: ['relations', 'Relations', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Social relations are stable connections between people arising in the process of joint activity.',
              answerType: 'text',
            ),
            Question(
              text: 'What are social groups?',
              options: [
                'Stable associations of people',
                'Random gatherings of people',
                'Crowd at a concert',
                'Queue in a store',
                'Bus passengers',
                'People on the street'
              ],
              correctIndex: 0,
              explanation: 'Social groups are stable associations of people connected by common interests and activity.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Rules of behavior in society are social ______.',
              options: ['norms', 'Norms', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Social norms are rules of behavior accepted in society and regulating relations between people.',
              answerType: 'text',
            ),
            Question(
              text: 'What types of social relations exist?',
              options: [
                'Cooperation',
                'Competition',
                'Both',
                'Only cooperation',
                'Only competition',
                'Neither'
              ],
              correctIndex: 2,
              explanation: 'In society, both relations of cooperation and relations of competition exist.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Mechanism of maintaining order in society is social ______.',
              options: ['control', 'Control', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Social control is a mechanism of maintaining social order through social norms and sanctions.',
              answerType: 'text',
            ),
            Question(
              text: 'How are society and nature connected?',
              options: [
                'Society depends on nature',
                'Society transforms nature',
                'Nature influences society development',
                'All of the above',
                'Only society influences nature',
                'Only nature influences society'
              ],
              correctIndex: 3,
              explanation: 'Society and nature are interconnected: society depends on nature and simultaneously transforms it.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Stable associations of people are social ______.',
              options: ['groups', 'Groups', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Social groups are stable associations of people connected by common interests and activity.',
              answerType: 'text',
            ),
            Question(
              text: 'What is a social institution?',
              options: [
                'Stable form of organization of social life',
                'Temporary association',
                'Random group',
                'Informal community',
                'Crowd of people',
                'Queue'
              ],
              correctIndex: 0,
              explanation: 'Social institution is a stable form of organization of social life, regulating a certain sphere of relations.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Sphere of production and distribution of goods is ______ sphere.',
              options: ['economic', 'Economic', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Economic sphere is the sphere of social life connected with production, distribution and consumption of goods.',
              answerType: 'text',
            ),
            Question(
              text: 'Why is society considered a complex system?',
              options: [
                'Consists of interconnected elements',
                'All elements influence each other',
                'Changes in one part affect others',
                'All of the above',
                'Only because there are many people',
                'Only due to complex laws'
              ],
              correctIndex: 3,
              explanation: 'Society is a complex system because it consists of interconnected elements, changes in which affect the entire system.',
              answerType: 'single_choice',
            ),
          ],
        ),
        Topic(
          id: "social_studies_class6_topic14",
          name: 'Our Country in the 21st Century',
          imageAsset: '🇷🇺',
          description: 'Russia as a modern state',
          explanation: '''Key concepts of the topic:
• Russian Federation - sovereign state
• Constitution - fundamental law of the country
• State symbols: flag, emblem, anthem
• Multinationality - diversity of peoples of Russia
• Patriotism - love for the Motherland
• International relations - connections with other countries
Russia is the largest state in the world with rich history and culture.''',
          questions: [
            Question(
              text: 'The fundamental law of our country is ______.',
              options: ['Constitution', 'constitution', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'The Constitution of the Russian Federation is the fundamental law with supreme legal force.',
              answerType: 'text',
            ),
            Question(
              text: 'What state symbols of Russia do you know?',
              options: [
                'Flag',
                'Emblem',
                'Anthem',
                'All of the above',
                'Only flag',
                'Only emblem'
              ],
              correctIndex: 3,
              explanation: 'State symbols of Russia: flag, emblem and anthem.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Love for the Motherland is ______.',
              options: ['patriotism', 'Patriotism', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Patriotism is love for one\'s Fatherland, devotion to one\'s people.',
              answerType: 'text',
            ),
            Question(
              text: 'How many peoples live in Russia?',
              options: [
                'More than 100',
                'About 50',
                'Only Russians',
                '10-15 peoples',
                'Only Slavic peoples',
                '5-6 peoples'
              ],
              correctIndex: 0,
              explanation: 'Representatives of more than 100 peoples and nationalities live in Russia.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'The head of the Russian state is ______.',
              options: ['President', 'president', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'The President of the Russian Federation is the head of state, guarantor of the Constitution.',
              answerType: 'text',
            ),
            Question(
              text: 'What does the white color on the flag of Russia mean?',
              options: [
                'Peace and purity',
                'Blood of defenders',
                'Wealth',
                'Fertility of land',
                'Sky',
                'Loyalty'
              ],
              correctIndex: 0,
              explanation: 'The white color on the flag symbolizes peace, purity, innocence.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'The body adopting laws in Russia is ______ Assembly.',
              options: ['Federal', 'federal', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'The Federal Assembly is the parliament of Russia, consisting of two chambers.',
              answerType: 'text',
            ),
            Question(
              text: 'What values are enshrined in the Constitution of Russia?',
              options: [
                'Family and marriage',
                'Multinational culture',
                'Protection of children',
                'All of the above',
                'Only political rights',
                'Only economic freedoms'
              ],
              correctIndex: 3,
              explanation: 'Traditional values are enshrined in the Constitution: family, culture, protection of children.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'The double-headed eagle on the emblem of Russia symbolizes ______.',
              options: ['unity of peoples', 'Unity of peoples', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'The double-headed eagle symbolizes the unity of the peoples of Russia living in the European and Asian parts of the country.',
              answerType: 'text',
            ),
            Question(
              text: 'What are international relations?',
              options: [
                'Connections between states',
                'Relations within the country',
                'Local self-government',
                'Communication between people',
                'Business contacts',
                'Family connections'
              ],
              correctIndex: 0,
              explanation: 'International relations are connections and interactions between various states.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Russia is a ______ state.',
              options: ['federal', 'Federal', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'The Russian Federation is a federal state consisting of federal subjects.',
              answerType: 'text',
            ),
            Question(
              text: 'Why is Russia called a multinational country?',
              options: [
                'Different peoples live here',
                'Different cultures and traditions',
                'Many languages and religions',
                'All of the above',
                'Only because of large population',
                'Only because of territory size'
              ],
              correctIndex: 3,
              explanation: 'Russia is multinational because different peoples with unique cultures, languages and traditions live here.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic15",
          name: 'Economy - Foundation of Society\'s Life',
          imageAsset: '💰',
          description: 'Economic activity and its role',
          explanation: '''Key concepts of the topic:
• Economy - economic activity of society
• Production - creation of goods and services
• Consumption - use of goods and services
• Resources - means for production
• Commodity economy - production for exchange
• Natural economy - production for oneself
The economy satisfies people\'s needs through production and distribution of goods.''',
          questions: [
            Question(
              text: 'Economic activity of society is ______.',
              options: ['economy', 'Economy', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Economy is an economic system ensuring satisfaction of people\'s needs.',
              answerType: 'text',
            ),
            Question(
              text: 'What are the main stages of economic activity?',
              options: [
                'Production',
                'Distribution',
                'Exchange',
                'Consumption',
                'All of the above',
                'Only production'
              ],
              correctIndex: 4,
              explanation: 'The economic cycle includes production, distribution, exchange and consumption.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Creation of goods and services is ______.',
              options: ['production', 'Production', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Production is the process of creating economic goods (goods and services).',
              answerType: 'text',
            ),
            Question(
              text: 'What is natural economy?',
              options: [
                'Production for own consumption',
                'Production for sale',
                'Trade in goods',
                'Provision of services',
                'Industrial production',
                'Agriculture'
              ],
              correctIndex: 0,
              explanation: 'Natural economy is production of products for own consumption, not for sale.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Use of goods and services is ______.',
              options: ['consumption', 'Consumption', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Consumption is the use of goods and services to satisfy needs.',
              answerType: 'text',
            ),
            Question(
              text: 'Who are producers?',
              options: [
                'Those who create goods and services',
                'Those who buy goods',
                'Those who distribute wealth',
                'Those who consume products',
                'Those who save money',
                'Those who engage in trade'
              ],
              correctIndex: 0,
              explanation: 'Producers are participants in the economy who create goods and provide services.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Means for production are economic ______.',
              options: ['resources', 'Resources', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Economic resources are all types of means used in the production process.',
              answerType: 'text',
            ),
            Question(
              text: 'What is commodity economy?',
              options: [
                'Production for exchange and sale',
                'Production for oneself',
                'Free distribution',
                'Natural production',
                'Manual labor',
                'Household economy'
              ],
              correctIndex: 0,
              explanation: 'Commodity economy is production of products for exchange through buying and selling.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Participants in the economy who use goods are ______.',
              options: ['consumers', 'Consumers', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Consumers are participants in the economy who use goods and services to satisfy needs.',
              answerType: 'text',
            ),
            Question(
              text: 'What resources does Russia have?',
              options: [
                'Natural wealth',
                'Qualified personnel',
                'Developed industry',
                'All of the above',
                'Only mineral resources',
                'Only agriculture'
              ],
              correctIndex: 3,
              explanation: 'Russia possesses diverse resources: natural, human, industrial.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'The process of obtaining a desired product in exchange for another is ______.',
              options: ['exchange', 'Exchange', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Exchange is an economic operation in which one product is obtained in exchange for another.',
              answerType: 'text',
            ),
            Question(
              text: 'Why is the economy important for society?',
              options: [
                'Satisfies needs',
                'Provides employment',
                'Creates wealth',
                'All of the above',
                'Only produces goods',
                'Only creates jobs'
              ],
              correctIndex: 3,
              explanation: 'The economy is important because it satisfies needs, provides employment and creates wealth.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic16",
          name: 'Social Sphere of Society\'s Life',
          imageAsset: '👨‍👩‍👧‍👦',
          description: 'Social groups and relations',
          explanation: '''Key concepts of the topic:
• Social structure - structure of society
• Social groups - associations of people
• Social position - place in society
• Social mobility - change of position
• Professional qualification - level of skill
• Material position - level of income
The social sphere regulates relations between different groups in society.''',
          questions: [
            Question(
              text: 'Structure of society is social ______.',
              options: ['structure', 'Structure', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Social structure is the structure of society, a system of interconnected social groups.',
              answerType: 'text',
            ),
            Question(
              text: 'What social groups do you know?',
              options: [
                'By age',
                'By profession',
                'By place of residence',
                'By education level',
                'All of the above',
                'Only by income'
              ],
              correctIndex: 4,
              explanation: 'Social groups can be distinguished by various characteristics: age, profession, place of residence, education.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'A person\'s place in society is their social ______.',
              options: ['position', 'Position', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Social position is the place a person occupies in the social structure of society.',
              answerType: 'text',
            ),
            Question(
              text: 'What is social mobility?',
              options: [
                'Change of social position',
                'Stability in society',
                'Social inequality',
                'Group solidarity',
                'Professional growth',
                'Material well-being'
              ],
              correctIndex: 0,
              explanation: 'Social mobility is the change of place occupied by a person or group in the social structure.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Level of professional skill is ______.',
              options: ['qualification', 'Qualification', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Qualification is the level of preparedness for any type of labor, degree of professional skill.',
              answerType: 'text',
            ),
            Question(
              text: 'What influences a person\'s material position?',
              options: [
                'Profession and qualification',
                'Working conditions',
                'Responsibility',
                'All of the above',
                'Only education',
                'Only work experience'
              ],
              correctIndex: 3,
              explanation: 'Material position is influenced by profession, qualification, working conditions and level of responsibility.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Movement on the social ladder is social ______.',
              options: ['mobility', 'Mobility', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Social mobility is the movement of a person or group in social space.',
              answerType: 'text',
            ),
            Question(
              text: 'Who is Sergei Korolev?',
              options: [
                'Outstanding designer',
                'Famous doctor',
                'Renowned writer',
                'Great artist',
                'Famous politician',
                'Renowned athlete'
              ],
              correctIndex: 0,
              explanation: 'Sergei Korolev was an outstanding Soviet designer of rocket and space technology.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Associations of people in society are social ______.',
              options: ['groups', 'Groups', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Social groups are stable associations of people having common interests and values.',
              answerType: 'text',
            ),
            Question(
              text: 'What helps improve social position?',
              options: [
                'Education',
                'Professional growth',
                'Development of abilities',
                'All of the above',
                'Only wealth',
                'Only connections'
              ],
              correctIndex: 3,
              explanation: 'Social position improves through education, professional growth and development of abilities.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'A person\'s level of income is their material ______.',
              options: ['position', 'Position', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Material position is the economic condition of a person, determined by income level.',
              answerType: 'text',
            ),
            Question(
              text: 'Why do social differences exist in society?',
              options: [
                'Different abilities and efforts',
                'Different education',
                'Different professions',
                'All of the above',
                'Only due to injustice',
                'Only due to inheritance'
              ],
              correctIndex: 3,
              explanation: 'Social differences arise due to different abilities, education, professions and efforts applied.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic17",
          name: 'World of Politics',
          imageAsset: '⚖️',
          description: 'Political system and power',
          explanation: '''Key concepts of the topic:
• Politics - sphere of society management
• Power - ability to influence behavior of others
• State - political organization of society
• Democracy - rule by the people
• Federation - union state
• Rule-of-law state - supremacy of law
The political sphere regulates relations of power and management in society.''',
          questions: [
            Question(
              text: 'Sphere of society management is ______.',
              options: ['politics', 'Politics', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Politics is the sphere of activity connected with relations between social groups, the core of which is conquest and use of power.',
              answerType: 'text',
            ),
            Question(
              text: 'What signs of a state do you know?',
              options: [
                'Territory',
                'Population',
                'Power',
                'Laws',
                'All of the above',
                'Only army and police'
              ],
              correctIndex: 4,
              explanation: 'A state is characterized by the presence of territory, population, power, laws and sovereignty.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Ability to influence behavior of others is ______.',
              options: ['power', 'Power', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Power is the ability and possibility to exert determining influence on activity and behavior of people.',
              answerType: 'text',
            ),
            Question(
              text: 'What is democracy?',
              options: [
                'Rule by the people',
                'Rule by one person',
                'Rule by the rich',
                'Military dictatorship',
                'Aristocracy',
                'Monarchy'
              ],
              correctIndex: 0,
              explanation: 'Democracy is a political regime in which the people are the source of power.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Union state is ______.',
              options: ['federation', 'Federation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Federation is a form of state structure in which parts of the state are state formations.',
              answerType: 'text',
            ),
            Question(
              text: 'Who is the head of state in Russia?',
              options: [
                'President',
                'Prime Minister',
                'Chairman of parliament',
                'Mayor of Moscow',
                'Patriarch',
                'Prosecutor General'
              ],
              correctIndex: 0,
              explanation: 'The President of the Russian Federation is the head of state.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'State where law is above power is ______ state.',
              options: ['rule-of-law', 'Rule-of-law', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Rule-of-law state is a state in which supremacy of law is ensured.',
              answerType: 'text',
            ),
            Question(
              text: 'What is the Federal Assembly?',
              options: [
                'Parliament of Russia',
                'Government',
                'Courts',
                'Local authorities',
                'Presidential administration',
                'Central Bank'
              ],
              correctIndex: 0,
              explanation: 'The Federal Assembly is the parliament of the Russian Federation, the representative and legislative body.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Political organization of society is ______.',
              options: ['state', 'State', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'State is the main political organization of society, exercising management and protection of public order.',
              answerType: 'text',
            ),
            Question(
              text: 'What branches of power exist in a rule-of-law state?',
              options: [
                'Legislative',
                'Executive',
                'Judicial',
                'All of the above',
                'Only legislative',
                'Only executive'
              ],
              correctIndex: 3,
              explanation: 'In a rule-of-law state, there is separation of powers into legislative, executive and judicial.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'The fundamental law of Russia is ______.',
              options: ['Constitution', 'constitution', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'The Constitution of the Russian Federation is the fundamental law with supreme legal force.',
              answerType: 'text',
            ),
            Question(
              text: 'Why is politics important for society?',
              options: [
                'Regulates social relations',
                'Ensures order',
                'Protects citizens\' rights',
                'All of the above',
                'Only distributes power',
                'Only organizes elections'
              ],
              correctIndex: 3,
              explanation: 'Politics is important because it regulates social relations, ensures order and protects rights.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic18",
          name: 'Culture and Its Achievements',
          imageAsset: '🎨',
          description: 'Material and spiritual culture',
          explanation: '''Key concepts of the topic:
• Culture - everything created by man
• Material culture - objects and things
• Spiritual culture - knowledge, art, morality
• Cultured person - educated and well-mannered
• Traditions - cultural heritage
• Religion - influence on culture
Culture reflects achievements of humanity and is passed from generation to generation.''',
          questions: [
            Question(
              text: 'Everything created by man is ______.',
              options: ['culture', 'Culture', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Culture is the totality of achievements of humanity in production, social and spiritual respects.',
              answerType: 'text',
            ),
            Question(
              text: 'What types of culture are distinguished?',
              options: [
                'Material',
                'Spiritual',
                'Both',
                'Only material',
                'Only spiritual',
                'Neither'
              ],
              correctIndex: 2,
              explanation: 'Culture includes both material and spiritual achievements of humanity.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Objects and things created by man are ______ culture.',
              options: ['material', 'Material', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Material culture is all objects created by man: buildings, machines, clothing, etc.',
              answerType: 'text',
            ),
            Question(
              text: 'What belongs to spiritual culture?',
              options: [
                'Knowledge and science',
                'Art and literature',
                'Morality and religion',
                'All of the above',
                'Only technologies',
                'Only economy'
              ],
              correctIndex: 3,
              explanation: 'Spiritual culture includes knowledge, art, morality, religion and other non-material achievements.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Educated and well-mannered person is ______ person.',
              options: ['cultured', 'Cultured', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Cultured person is a person possessing education, upbringing and knowledge of cultural values.',
              answerType: 'text',
            ),
            Question(
              text: 'What is cultural heritage?',
              options: [
                'Values passed from generation to generation',
                'Modern technologies',
                'Fashion trends',
                'Economic achievements',
                'Political ideas',
                'Scientific discoveries'
              ],
              correctIndex: 0,
              explanation: 'Cultural heritage is values, traditions, customs passed from generation to generation.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Influence of religion on culture is manifested in ______.',
              options: ['architecture of temples', 'Architecture of temples', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Religion has had enormous influence on culture, especially in architecture of temples, icon painting, music.',
              answerType: 'text',
            ),
            Question(
              text: 'What are traditions?',
              options: [
                'Customs and rituals passed from generation to generation',
                'New trends',
                'Modern technologies',
                'Economic reforms',
                'Political programs',
                'Scientific theories'
              ],
              correctIndex: 0,
              explanation: 'Traditions are elements of social and cultural heritage passed from generation to generation.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Person with deep knowledge is ______ person.',
              options: ['erudite', 'Erudite', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Erudite person is one possessing deep knowledge in various fields.',
              answerType: 'text',
            ),
            Question(
              text: 'What cultural institutions do you know?',
              options: [
                'Museums',
                'Theaters',
                'Libraries',
                'All of the above',
                'Only cinemas',
                'Only concert halls'
              ],
              correctIndex: 3,
              explanation: 'Cultural institutions include museums, theaters, libraries, concert halls and others.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'The process of familiarization with culture requires ______.',
              options: ['efforts', 'Efforts', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Familiarization with culture requires efforts, labor and constant self-education.',
              answerType: 'text',
            ),
            Question(
              text: 'Why is it important to preserve cultural heritage?',
              options: [
                'For connection of generations',
                'For understanding history',
                'For development of culture',
                'All of the above',
                'Only for tourism',
                'Only for education'
              ],
              correctIndex: 3,
              explanation: 'Preservation of cultural heritage is important for connection of generations, understanding history and development of culture.',
              answerType: 'single_choice',
            ),
          ],
        ),
        Topic(
          id: "social_studies_class6_topic19",
          name: 'Development of Society',
          imageAsset: '📈',
          description: 'Progress and global problems',
          explanation: '''Key concepts of the topic:
• Progress - forward movement, improvement
• Global problems - affecting all humanity
• Ecological crisis - deterioration of nature\'s condition
• International organizations - UN, Red Cross
• Sustainable development - balance between needs and possibilities
• Price of progress - negative consequences of development
Society constantly develops, facing new challenges and problems.''',
          questions: [
            Question(
              text: 'Forward movement of society, toward better - is ______.',
              options: ['progress', 'Progress', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Progress is direction of development from lower to higher, from less perfect to more perfect.',
              answerType: 'text',
            ),
            Question(
              text: 'What global problems do you know?',
              options: [
                'Ecological',
                'Threat of war',
                'Economic inequality',
                'Terrorism',
                'All of the above',
                'Only ecological'
              ],
              correctIndex: 4,
              explanation: 'Global problems include ecological, political, economic and social challenges.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Deterioration of the natural environment condition is ecological ______.',
              options: ['crisis', 'Crisis', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Ecological crisis is disturbance of balance in nature as a result of human economic activity.',
              answerType: 'text',
            ),
            Question(
              text: 'What is the UN?',
              options: [
                'United Nations',
                'Association of European countries',
                'Military alliance',
                'Economic organization',
                'Cultural association',
                'Scientific society'
              ],
              correctIndex: 0,
              explanation: 'UN is an international organization created to maintain peace and security.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Development not threatening future generations is ______ development.',
              options: ['sustainable', 'Sustainable', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Sustainable development is development that satisfies needs of the present without threatening possibilities of future generations.',
              answerType: 'text',
            ),
            Question(
              text: 'What is the "price of progress"?',
              options: [
                'Negative consequences of development',
                'Cost of new technologies',
                'Expenses for research',
                'Price of equipment',
                'Cost of education',
                'Expenses for culture'
              ],
              correctIndex: 0,
              explanation: '"Price of progress" is negative consequences of technical and social development.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'International aid organization is Red ______.',
              options: ['Cross', 'cross', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Red Cross is an international movement providing aid to wounded, sick and victims.',
              answerType: 'text',
            ),
            Question(
              text: 'Why are problems called global?',
              options: [
                'Affect all humanity',
                'Require joint efforts',
                'Have planetary scale',
                'All of the above',
                'Only because they are serious',
                'Only because they are complex'
              ],
              correctIndex: 3,
              explanation: 'Problems are called global because they affect all humanity and require joint efforts for solution.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Negative consequences of development are the price of ______.',
              options: ['progress', 'Progress', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Price of progress is negative consequences of technical and social development of society.',
              answerType: 'text',
            ),
            Question(
              text: 'What are volunteers?',
              options: [
                'Voluntary helpers',
                'Professional rescuers',
                'Civil servants',
                'Military personnel',
                'Politicians',
                'Businessmen'
              ],
              correctIndex: 0,
              explanation: 'Volunteers are people voluntarily and without payment engaged in socially useful activity.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Balance between needs and possibilities of nature is ______ development.',
              options: ['sustainable', 'Sustainable', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Sustainable development assumes balance between needs of humanity and possibilities of nature.',
              answerType: 'text',
            ),
            Question(
              text: 'Why is it important to solve global problems?',
              options: [
                'For survival of humanity',
                'For improvement of life',
                'For future generations',
                'All of the above',
                'Only for economy',
                'Only for politics'
              ],
              correctIndex: 3,
              explanation: 'Solving global problems is important for survival of humanity, improvement of life and future of generations.',
              answerType: 'single_choice',
            ),
          ],
        ),
      ],
    },
  ),
];