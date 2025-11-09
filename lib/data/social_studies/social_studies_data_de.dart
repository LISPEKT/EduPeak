// lib/data/social_studies/social_studies_data_de.dart
import '../../../models/topic.dart';
import '../../../models/question.dart';
import '../../../models/subject.dart';

// === KLASSE 6 ===
final List<Subject> socialStudiesSubjects6DE = [
  Subject(
    name: 'Sozialkunde',
    topicsByGrade: {
      6: [
        Topic(
          id: "social_studies_class6_topic1",
          name: 'Biologisches und Soziales im Menschen',
          imageAsset: '🧬',
          description: 'Verhältnis von natürlichen und gesellschaftlichen Eigenschaften des Menschen',
          explanation: '''Schlüsselbegriffe des Themas:
• Vererbung - Übertragung von Merkmalen von Eltern auf Kinder durch Gene
• Instinkte - angeborene Verhaltensmuster bei Tieren und Menschen
• Biologischer Ursprung: körperliche Eigenschaften, Emotionen, Bedürfnisse nach Nahrung, Schlaf, Sicherheit
• Sozialer Ursprung: Sprache, Denken, Kultur, Moral, Verhaltensregeln
• Individuum - ein einzelner Vertreter der menschlichen Spezies
Der Mensch wird als biologisches Wesen geboren, wird aber erst in der Gesellschaft zur Persönlichkeit.''',
          questions: [
            Question(
              text: 'Was bestimmt das Verhalten von Tieren?',
              options: ['Instinkte', 'Bewusstsein', 'Kultur', 'Bildung', 'Traditionen'],
              correctIndex: 0,
              explanation: 'Das Verhalten von Tieren wird hauptsächlich durch Instinkte bestimmt - angeborene Verhaltensprogramme.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Was ist Vererbung?',
              options: [
                'Übertragung von Merkmalen von Eltern auf Kinder',
                'Erwerb von Wissen in der Schule',
                'Erlernen von Verhaltensregeln',
                'Entwicklung von Fähigkeiten',
                'Charakterbildung'
              ],
              correctIndex: 0,
              explanation: 'Vererbung - Übertragung charakteristischer Merkmale der Art von Eltern auf Nachkommen durch Gene.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Welche biologischen Merkmale erbt der Mensch?',
              options: [
                'Augen- und Haarfarbe',
                'Körperbau',
                'Besonderheiten der Emotionen',
                'Sprachkenntnisse',
                'Kulturelle Traditionen',
                'Körperliche Fähigkeiten'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Körperliche Eigenschaften und einige Besonderheiten des emotionalen Bereichs werden vererbt, aber nicht soziales Wissen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Warum können Wolfskinder sich nicht vollständig entwickeln?',
              options: [
                'Erhalten keine soziale Erfahrung',
                'Haben schlechte Vererbung',
                'Essen nicht genug',
                'Leben in schlechtem Klima',
                'Haben keine medizinische Versorgung',
                'Lernen keine menschliche Sprache'
              ],
              correctIndex: [0, 5],
              explanation: 'Ohne Kommunikation mit Menschen eignet sich das Kind keine sozialen Fähigkeiten, Sprache, Kultur und Verhaltensregeln an.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was ist für die vollständige Entwicklung eines Kindes notwendig?',
              options: [
                'Kommunikation mit Menschen',
                'Erziehung und Ausbildung',
                'Aneignung von Kultur',
                'Nur Ernährung und Pflege',
                'Nur Vererbung',
                'Soziales Umfeld'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Für die Entwicklung der Persönlichkeit sind nicht nur biologische Bedingungen, sondern auch soziales Umfeld, Kommunikation und Erziehung notwendig.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Worin unterscheidet sich der Mensch vom Tier?',
              options: [
                'Fähigkeit zu denken',
                'Vorhandensein von Sprache',
                'Bewusstes Handeln',
                'Vorhandensein von Instinkten',
                'Bedürfnis nach Nahrung',
                'Schaffung von Kultur'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Die Hauptunterschiede sind Bewusstsein, Sprache, Fähigkeit zu zielgerichtetem Handeln und Schaffung von Kultur.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was wird vererbt?',
              options: [
                'Körperliche Eigenschaften',
                'Haar- und Augenfarbe',
                'Besonderheiten des Temperaments',
                'Kenntnisse und Fertigkeiten',
                'Moralische Prinzipien',
                'Veranlagung für Krankheiten'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Biologische Eigenschaften werden vererbt, aber nicht soziales Wissen und moralische Normen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Kann man auf die Vererbung Einfluss nehmen?',
              options: [
                'Ja, durch Lebensbedingungen und Erziehung',
                'Nein, Vererbung ist unveränderlich',
                'Nur mit Hilfe der Medizin',
                'Nur im Kindesalter',
                'Man kann überhaupt keinen Einfluss nehmen',
                'Durch Bildung und Entwicklung'
              ],
              correctIndex: [0, 5],
              explanation: 'Obwohl die Vererbung das Potenzial bestimmt, hängt die Entwicklung der Fähigkeiten von Lebensbedingungen, Erziehung und Bildung ab.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was sind Instinkte?',
              options: [
                'Angeborene Verhaltensprogramme',
                'Erworbene Fähigkeiten',
                'Bewusste Handlungen',
                'Kulturelle Traditionen',
                'Soziale Normen',
                'Reflexe'
              ],
              correctIndex: 0,
              explanation: 'Instinkte - komplexe angeborene Verhaltensmuster, die für die Art charakteristisch sind.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Wer sind "Wolfskinder"?',
              options: [
                'Kinder, die unter Tieren aufgewachsen sind',
                'Kinder mit besonderen Fähigkeiten',
                'Waisenkinder',
                'Kinder aus kinderreichen Familien',
                'Kinder mit Behinderungen',
                'Kinder, die von Wölfen aufgezogen wurden'
              ],
              correctIndex: [0, 5],
              explanation: 'Wolfskinder - das sind Kinder, die in frühem Alter von der menschlichen Gesellschaft isoliert wurden und unter Tieren aufgewachsen sind.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was sind Gene?',
              options: [
                'Materielle Träger der Vererbung',
                'Lerneinheiten',
                'Soziale Normen',
                'Kulturelle Traditionen',
                'Erworbene Fähigkeiten',
                'Elemente der Erziehung'
              ],
              correctIndex: 0,
              explanation: 'Gene - materielle Träger der Erbinformation, die von Eltern an Kinder weitergegeben werden.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Welche Beispiele für Instinkte bei Tieren sind im Lehrbuch angegeben?',
              options: [
                'Verhalten des Kuckuckskükens in fremdem Nest',
                'Reaktion von Küken auf Geräusche',
                'Bau von Waben durch Bienen',
                'Lernen in der Schule',
                'Schaffen von Kunstwerken',
                'Sport treiben'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'Im Lehrbuch sind Beispiele für instinktives Verhalten von Kuckuckskindern, Küken und Bienen angeführt.',
              answerType: 'multiple_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic2",
          name: 'Der Mensch — eine Persönlichkeit',
          imageAsset: '👤',
          description: 'Begriff der Persönlichkeit und ihre Entwicklung',
          explanation: '''Schlüsselbegriffe des Themas:
• Persönlichkeit - ein Mensch mit Bewusstsein, der zu Handeln und Kommunikation fähig ist
• Individualität - einzigartige Kombination von Eigenschaften eines Menschen
• Bewusstsein - Fähigkeit zu denken, sich selbst und die Umgebung zu bewerten
• Starke Persönlichkeit - ein Mensch mit entwickeltem Willen, Zielstrebigkeit, der Schwierigkeiten überwinden kann
• Selbstwertgefühl - Vorstellung eines Menschen über seine Eigenschaften und Möglichkeiten
Die Persönlichkeit bildet sich im Prozess des Handelns, der Kommunikation und der Erziehung.''',
          questions: [
            Question(
              text: 'Wen betrachtet man als Persönlichkeit?',
              options: [
                'Menschen mit Bewusstsein und Willen',
                'Jeden Menschen von Geburt an',
                'Nur bekannte Menschen',
                'Nur erwachsene Menschen',
                'Nur gebildete Menschen',
                'Menschen, die zur Selbstbewertung fähig sind'
              ],
              correctIndex: [0, 5],
              explanation: 'Persönlichkeit - ein Mensch, der Bewusstsein besitzt, zu Handeln, Selbstbewertung und Kommunikation fähig ist.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was ist Individualität?',
              options: [
                'Einzigartige Eigenschaften eines Menschen',
                'Ähnlichkeit mit anderen Menschen',
                'Durchschnittliche Fähigkeiten',
                'Gewöhnliche Charakterzüge',
                'Typisches Verhalten',
                'Einzigartigkeit des Menschen'
              ],
              correctIndex: [0, 5],
              explanation: 'Individualität - einzigartige Kombination von Eigenschaften, die den Menschen von anderen unterscheidet.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Durch welche Eigenschaften zeichnet sich eine starke Persönlichkeit aus?',
              options: [
                'Willen und Zielstrebigkeit',
                'Starke Muskulatur',
                'Reichtum',
                'Bekanntheit',
                'Macht',
                'Fähigkeit, Schwierigkeiten zu überwinden'
              ],
              correctIndex: [0, 5],
              explanation: 'Eine starke Persönlichkeit zeigt sich in willentlichen Eigenschaften, Zielstrebigkeit und der Fähigkeit, Schwierigkeiten zu überwinden.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was ist Bewusstsein?',
              options: [
                'Fähigkeit zu denken und zu bewerten',
                'Körperliche Stärke',
                'Schnelle Reaktion',
                'Gutes Gedächtnis',
                'Schönes Aussehen',
                'Verstehen von sich selbst und der Welt'
              ],
              correctIndex: [0, 5],
              explanation: 'Bewusstsein - Fähigkeit des Menschen zu denken, sich selbst und die Umgebung zu verstehen, seine Handlungen zu bewerten.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Kann ein Tier eine Persönlichkeit sein?',
              options: [
                'Nein, nur der Mensch',
                'Ja, einige Tiere',
                'Nur Affen',
                'Nur Haustiere',
                'Alle Lebewesen',
                'Nein, Tiere haben kein Bewusstsein'
              ],
              correctIndex: [0, 5],
              explanation: 'Nur der Mensch besitzt Bewusstsein und kann eine Persönlichkeit sein. Tiere handeln auf der Grundlage von Instinkten.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Wann beginnt ein Kind, sich als Persönlichkeit zu begreifen?',
              options: [
                'Mit 2-3 Jahren, wenn es "ich" sagt',
                'Direkt nach der Geburt',
                'Im Schulalter',
                'Im Jugendalter',
                'Erst im Erwachsenenalter',
                'Wenn es sich von anderen abgrenzt'
              ],
              correctIndex: [0, 5],
              explanation: 'Die Erkenntnis seiner selbst als Persönlichkeit beginnt, wenn das Kind anfängt, das Pronomen "ich" zu verwenden und sich von anderen abzugrenzen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was bedeutet "Individualität besitzen"?',
              options: [
                'Einzigartige Züge haben',
                'Wie alle anderen sein',
                'Sich anderen unterordnen',
                'Keine eigene Meinung haben',
                'Der Mode folgen',
                'Einzigartig sein'
              ],
              correctIndex: [0, 5],
              explanation: 'Individualität - das ist die Einzigartigkeit, die Einmaligkeit des Menschen, seine besonderen Eigenschaften und Fähigkeiten.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche Eigenschaften entwickelt eine starke Persönlichkeit?',
              options: [
                'Willen und Beharrlichkeit',
                'Aggressivität',
                'List',
                'Faulheit',
                'Verantwortungslosigkeit',
                'Zielstrebigkeit'
              ],
              correctIndex: [0, 5],
              explanation: 'Eine starke Persönlichkeit entwickelt positive willentliche Eigenschaften: Willen, Beharrlichkeit, Zielstrebigkeit.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was hilft, eine Persönlichkeit zu werden?',
              options: [
                'Kommunikation und Tätigkeit',
                'Reichtum der Eltern',
                'Körperliche Stärke',
                'Schönes Aussehen',
                'Glück',
                'Erziehung und Bildung'
              ],
              correctIndex: [0, 5],
              explanation: 'Die Persönlichkeit bildet sich durch Kommunikation mit anderen, verschiedene Tätigkeiten, Erziehung und Bildung.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Kann man ohne Kommunikation mit Menschen eine Persönlichkeit werden?',
              options: [
                'Nein, unmöglich',
                'Ja, wenn man viel liest',
                'Ja, wenn man Talent besitzt',
                'Ja, bei guter Vererbung',
                'Ja, bei Reichtum',
                'Nein, soziale Erfahrung ist nötig'
              ],
              correctIndex: [0, 5],
              explanation: 'Ohne Kommunikation mit Menschen ist es unmöglich, soziale Erfahrung, Sprache, Kultur anzueignen und eine Persönlichkeit zu werden.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche drei Fragen helfen zu verstehen, ob ein Mensch eine Persönlichkeit ist?',
              options: [
                'Kann er sich selbst steuern',
                'Kann er sein Leben gestalten',
                'Kann er sich selbst machen',
                'Wie viel Geld er hat',
                'Welche Bildung er hat',
                'Welchen sozialen Status er hat'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'Philosophen heben drei Schlüsselfragen zur Selbstkontrolle, Selbstbestimmung und Gestaltung des Lebens hervor.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was ist Selbstwertgefühl?',
              options: [
                'Bewertung der eigenen Eigenschaften und Möglichkeiten',
                'Meinung anderer über den Menschen',
                'Schulnoten',
                'Sozialer Status',
                'Finanzielle Lage',
                'Vorstellung von sich selbst'
              ],
              correctIndex: [0, 5],
              explanation: 'Selbstwertgefühl - das ist die Vorstellung des Menschen über seine Eigenschaften, Möglichkeiten, seinen Platz unter anderen Menschen.',
              answerType: 'multiple_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic3",
          name: 'Jugendalter — eine besondere Lebensphase',
          imageAsset: '🌟',
          description: 'Besonderheiten des Jugendalters',
          explanation: '''Schlüsselbegriffe des Themas:
• Jugendalter (Adoleszenz) - Zeitraum von 10-11 bis 14-15 Jahren
• Körperliche Veränderungen: schnelles Wachstum, Veränderung der Körperproportionen
• Psychologische Besonderheiten: Stimmungswechsel, Streben nach Selbständigkeit
• Generation - Gruppe von Menschen gleichen Alters, die zur gleichen Zeit leben
• Generationenbeziehungen - Verbindungen zwischen verschiedenen Altersgruppen
• Selbständigkeit - ein wichtiger Indikator für Erwachsenwerden
Dies ist eine Zeit der aktiven Persönlichkeitsbildung, der Selbstsuche und der Suche nach dem Platz im Leben.''',
          questions: [
            Question(
              text: 'Was ist das Jugendalter?',
              options: [
                'Adoleszenz',
                'Kindesalter',
                'Erwachsenenalter',
                'Alter',
                'Säuglingsalter',
                'Übergangsperiode'
              ],
              correctIndex: [0, 5],
              explanation: 'Jugendalter - das ist die Adoleszenz, die Übergangsperiode zwischen Kindheit und Jugend.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche körperlichen Veränderungen finden im Jugendalter statt?',
              options: [
                'Schnelles Wachstum',
                'Veränderung der Körperproportionen',
                'Stimmwechsel',
                'Stabiles Wachstum',
                'Verlangsamung der Entwicklung',
                'Herausbildung erwachsener Züge'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Das Jugendalter ist durch stürmische körperliche Entwicklung und Herausbildung erwachsener Züge gekennzeichnet.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was ist eine Generation?',
              options: [
                'Gruppe von Menschen gleichen Alters',
                'Familienstammbaum',
                'Historischer Zeitraum',
                'Schulklasse',
                'Gruppe von Freunden',
                'Menschen, die zur gleichen Zeit leben'
              ],
              correctIndex: [0, 5],
              explanation: 'Generation - Gruppe von Menschen etwa gleichen Alters, die zur gleichen Zeit leben und gemeinsame Erfahrungen haben.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Warum nennt man das Jugendalter Übergangsalter?',
              options: [
                'Übergang von der Kindheit zum Erwachsensein',
                'Übergang zu einer anderen Schule',
                'Umzug in eine andere Stadt',
                'Wechsel der Interessen',
                'Veränderung des Aussehens',
                'Periode der Persönlichkeitsbildung'
              ],
              correctIndex: [0, 5],
              explanation: 'Dies ist eine Übergangsphase von der Kindheit zum Erwachsenenleben, Zeit der Persönlichkeitsbildung.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche psychologischen Besonderheiten sind für Jugendliche charakteristisch?',
              options: [
                'Stimmungswechsel',
                'Streben nach Selbständigkeit',
                'Bedürfnis nach Kommunikation',
                'Stabilität der Emotionen',
                'Volle Abhängigkeit von den Eltern',
                'Suche nach dem Platz im Leben'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Jugendlichen sind emotionale Labilität, Streben nach Unabhängigkeit und Selbstsuche eigen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was ist Selbständigkeit?',
              options: [
                'Fähigkeit, selbst Entscheidungen zu treffen',
                'Volle Unabhängigkeit von allen',
                'Ablehnung der Hilfe anderer',
                'Finanzielle Unabhängigkeit',
                'Getrennt von den Eltern leben',
                'Verantwortung für die eigenen Taten'
              ],
              correctIndex: [0, 5],
              explanation: 'Selbständigkeit - Fähigkeit, verantwortungsvolle Entscheidungen zu treffen und Verantwortung für die eigenen Taten zu tragen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Wie gestalten sich die Beziehungen zwischen den Generationen?',
              options: [
                'Auf der Grundlage gegenseitigen Respekts',
                'Nur durch Konflikte',
                'Ohne jede Kommunikation',
                'Durch Unterordnung der Jüngeren',
                'Durch Rivalität',
                'Unter Berücksichtigung der Erfahrung der Älteren'
              ],
              correctIndex: [0, 5],
              explanation: 'Gesunde Generationenbeziehungen bauen auf gegenseitigem Respekt und Berücksichtigung der Erfahrung älterer Generationen auf.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Warum streben Jugendliche nach Selbständigkeit?',
              options: [
                'Wollen sich erwachsen fühlen',
                'Mögen die Eltern nicht',
                'Wollen unabhängig sein',
                'Folgen der Mode',
                'Ahmen Freunde nach',
                'Natürlicher Prozess des Erwachsenwerdens'
              ],
              correctIndex: [0, 2, 5],
              explanation: 'Das Streben nach Selbständigkeit - natürliche Äußerung des Erwachsenwerdens, Wunsch nach Unabhängigkeit.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was hilft dem Jugendlichen bei der Persönlichkeitsbildung?',
              options: [
                'Kommunikation mit Gleichaltrigen',
                'Unterstützung der Familie',
                'Lerntätigkeit',
                'Arbeitsgemeinschaften und Sektionen',
                'Alles Genannte',
                'Entwicklung von Interessen und Fähigkeiten'
              ],
              correctIndex: [4, 5],
              explanation: 'Alle Lebensbereiche des Jugendlichen tragen zur Bildung seiner Persönlichkeit, Entwicklung von Interessen und Fähigkeiten bei.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche Bedeutung hat der Traum im Jugendalter?',
              options: [
                'Hilft, Ziele zu setzen',
                'Entwickelt die Vorstellungskraft',
                'Stimuliert die Entwicklung',
                'Entfernt von der Realität',
                'Stört das Lernen',
                'Bestimmt die Zukunft'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Träume im Jugendalter spielen eine wichtige Rolle in der Persönlichkeitsentwicklung und können die Zukunft bestimmen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche Altersetappen werden im Leben des Menschen unterschieden?',
              options: [
                'Säuglingsalter',
                'Kindheit',
                'Jugendalter',
                'Jugend',
                'Reife',
                'Alle genannten'
              ],
              correctIndex: 5,
              explanation: 'Wissenschaftler unterscheiden aufeinanderfolgende Altersetappen: Säuglingsalter, Kindheit, Jugendalter, Jugend, Reife, Alter.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Was ist Hypodynamie und warum ist sie gefährlich?',
              options: [
                'Mangel an körperlicher Aktivität',
                'Senkt die Immunität',
                'Führt zu Erkrankungen',
                'Übermaß an Bewegung',
                'Nützlich für die Gesundheit',
                'Verbessert das Wohlbefinden'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'Hypodynamie - ungenügende körperliche Aktivität, die gesundheitsschädlich ist.',
              answerType: 'multiple_choice',
            ),
          ],
        ),

        // Fortsetzung für die restlichen 16 Themen im gleichen Format...
        Topic(
          id: "social_studies_class6_topic4",
          name: 'Bedürfnisse und Fähigkeiten des Menschen',
          imageAsset: '🎯',
          description: 'Arten von Bedürfnissen und Entwicklung von Fähigkeiten',
          explanation: '''Schlüsselbegriffe des Themas:
• Bedürfnis - empfundener Mangel an etwas Notwendigem
• Arten von Bedürfnissen: biologische, soziale, geistige
• Fähigkeiten - individuelle Besonderheiten, die bei der Tätigkeit helfen
• Fähigkeitsniveaus: Begabung, Talent, Genie
• Geistige Welt - innere Welt der Gedanken und Gefühle des Menschen
• Emotionen - Erlebnisse, verbunden mit der Befriedigung von Bedürfnissen
Bedürfnisse motivieren die Tätigkeit, und Fähigkeiten helfen, Ziele zu erreichen.''',
          questions: [
            Question(
              text: 'Was sind Bedürfnisse?',
              options: [
                'Empfundener Mangel an etwas',
                'Wünsche und Launen',
                'Materielle Güter',
                'Geistige Werte',
                'Körperliche Möglichkeiten',
                'Notwendiges für das Leben'
              ],
              correctIndex: [0, 5],
              explanation: 'Bedürfnis - das ist der vom Menschen empfundene Mangel an dem, was für die Lebenserhaltung und Entwicklung notwendig ist.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche Arten von Bedürfnissen gibt es?',
              options: [
                'Biologische',
                'Soziale',
                'Geistige',
                'Nur materielle',
                'Nur physiologische',
                'Alle genannten außer 4 und 5'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Man unterscheidet drei Hauptarten von Bedürfnissen: biologische, soziale und geistige.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was sind Fähigkeiten?',
              options: [
                'Individuelle Besonderheiten der Persönlichkeit',
                'Bedingungen erfolgreicher Tätigkeit',
                'Angeborene Eigenschaften',
                'Erworbenes Wissen',
                'Sozialer Status',
                'Entwickelte Fertigkeiten'
              ],
              correctIndex: [0, 1, 5],
              explanation: 'Fähigkeiten - individuelle Besonderheiten der Persönlichkeit, die Bedingungen für die erfolgreiche Ausführung von Tätigkeiten sind.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche Entwicklungsstufen von Fähigkeiten werden unterschieden?',
              options: [
                'Begabung',
                'Talent',
                'Genie',
                'Durchschnittliche Fähigkeiten',
                'Fehlen von Fähigkeiten',
                'Höchste Entwicklungsstufe'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'Wissenschaftler unterscheiden Stufen: Begabung, Talent und Genie als höchste Stufe.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was ist die geistige Welt des Menschen?',
              options: [
                'Innere Welt der Gedanken und Gefühle',
                'Materielle Reichtümer',
                'Soziale Stellung',
                'Körperliche Gesundheit',
                'Äußere Schönheit',
                'Welt der Werte und Ideale'
              ],
              correctIndex: [0, 5],
              explanation: 'Geistige Welt - das ist die innere Welt des Menschen, die Welt seiner Gedanken, Gefühle, Werte und Ideale.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was gehört zu den biologischen Bedürfnissen?',
              options: [
                'Bedürfnis nach Nahrung',
                'Bedürfnis nach Schlaf',
                'Bedürfnis nach Wasser',
                'Bedürfnis nach Kommunikation',
                'Bedürfnis nach Wissen',
                'Bedürfnis nach Sicherheit'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Biologische Bedürfnisse - natürliche Bedürfnisse des Organismus, die zum Überleben notwendig sind.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was sind Anlagen?',
              options: [
                'Natürliche Voraussetzungen für Fähigkeiten',
                'Erworbene Fertigkeiten',
                'Soziale Bedingungen',
                'Materielle Güter',
                'Fertige Fähigkeiten',
                'Angeborene Besonderheiten'
              ],
              correctIndex: [0, 5],
              explanation: 'Anlagen - das sind natürliche Voraussetzungen für Fähigkeiten, angeborene anatomisch-physiologische Besonderheiten.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was sind Emotionen?',
              options: [
                'Erlebnisse und Gefühle',
                'Rationale Gedanken',
                'Logische Schlussfolgerungen',
                'Objektive Fakten',
                'Wissenschaftliche Kenntnisse',
                'Subjektive Reaktionen'
              ],
              correctIndex: [0, 5],
              explanation: 'Emotionen - das sind Erlebnisse des Menschen, verbunden mit der Befriedigung oder Nichtbefriedigung von Bedürfnissen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche Gefühle gibt es?',
              options: [
                'Moralische',
                'Ästhetische',
                'Intellektuelle',
                'Nur positive',
                'Nur negative',
                'Höhere Gefühle'
              ],
              correctIndex: [0, 1, 2, 5],
              explanation: 'Man unterscheidet moralische, ästhetische und intellektuelle Gefühle als höhere Gefühle des Menschen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was sind scheinbare Bedürfnisse?',
              options: [
                'Durch Werbung aufgezwungene',
                'Künstliche Wünsche',
                'Echte Bedürfnisse',
                'Natürliche Bedürfnisse',
                'Notwendige für das Leben',
                'Prestigeträchtiger Konsum'
              ],
              correctIndex: [0, 1, 5],
              explanation: 'Scheinbare Bedürfnisse - das sind aufgezwungene, künstliche Wünsche, oft verbunden mit prestigeträchtigem Konsum.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Wie entwickeln sich Fähigkeiten?',
              options: [
                'Im Lernprozess',
                'Durch Tätigkeit',
                'Nur durch Vererbung',
                'Selbständig',
                'Ohne Anstrengung',
                'Bei Vorhandensein von Anlagen'
              ],
              correctIndex: [0, 1, 5],
              explanation: 'Fähigkeiten entwickeln sich im Prozess des Lernens und der Tätigkeit bei Vorhandensein natürlicher Anlagen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Was ist Genie?',
              options: [
                'Höchstes Niveau der Fähigkeiten',
                'Durchschnittliche Fähigkeiten',
                'Fehlen von Talent',
                'Gewöhnliche Fertigkeiten',
                'Erworbene Fertigkeiten',
                'Hervorragende Leistungen'
              ],
              correctIndex: [0, 5],
              explanation: 'Genie - höchstes Niveau der Fähigkeitsentwicklung, das ermöglicht, hervorragende Schöpfungen zu schaffen.',
              answerType: 'multiple_choice',
            ),
          ],
        ),

        // Analog fahren wir für alle verbleibenden 15 Themen fort...
        // Thema 5: Wenn die Möglichkeiten begrenzt sind
        // Thema 6: Tätigkeit und Vielfalt ihrer Arten
        // Thema 7: Erkenntnis der Welt und seiner selbst durch den Menschen
        // Thema 8: Kommunikation
        // Thema 9: Konflikte und ihre Lösung
        // Thema 10: Der Mensch in der Kleingruppe
        // Thema 11: Familie und Familienbeziehungen
        // Thema 12: Schulbildung
        // Thema 13: Wie ist die Gesellschaft aufgebaut
        // Thema 14: Unser Land im 21. Jahrhundert
        // Thema 15: Wirtschaft - Grundlage des Gesellschaftslebens
        // Thema 16: Sozialer Bereich des Gesellschaftslebens
        // Thema 17: Welt der Politik
        // Thema 18: Kultur und ihre Errungenschaften
        // Thema 19: Entwicklung der Gesellschaft

        Topic(
          id: "social_studies_class6_topic5",
          name: 'Wenn die Möglichkeiten begrenzt sind',
          imageAsset: '♿',
          description: 'Besondere Bedürfnisse und Hilfe für Menschen mit Behinderungen',
          explanation: '''Schlüsselbegriffe des Themas:
• Eingeschränkte Möglichkeiten - Zustände, die die normale Lebensaktivität erschweren
• Besondere Bedürfnisse - zusätzliche Bedingungen für ein erfülltes Leben
• Inklusion - Einbeziehung von Menschen mit Einschränkungen in das normale Leben der Gesellschaft
• Anpassung - Anpassung an die Lebensbedingungen
• Rehabilitation - Wiederherstellung verlorener Möglichkeiten
• Freiwilligenarbeit - freiwillige Hilfe für Bedürftige
Jeder Mensch verdient Respekt und Unterstützung unabhängig von seinen Möglichkeiten.''',
          questions: [
            Question(
              text: 'Was sind eingeschränkte Möglichkeiten?',
              options: [
                'Zustände, die das normale Leben erschweren',
                'Mangel an Fähigkeiten',
                'Faulheit und Willensschwäche',
                'Armut',
                'Unbildung',
                'Besonderheiten der Gesundheit'
              ],
              correctIndex: [0, 5],
              explanation: 'Eingeschränkte Möglichkeiten - das sind Gesundheitszustände, die die normale Lebensaktivität erschweren.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Welche besonderen Bedürfnisse haben Menschen mit eingeschränkten Möglichkeiten?',
              options: [
                'Zusätzliche Hilfe',
                'Spezielle Lernbedingungen',
                'Technische Hilfsmittel',
                'Psychologische Unterstützung',
                'Medizinische Hilfe',
                'Alles Genannte'
              ],
              correctIndex: 5,
              explanation: 'Menschen mit eingeschränkten Möglichkeiten benötigen umfassende Hilfe und spezielle Bedingungen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Was ist Inklusion?',
              options: ['Einbeziehung in die Gesellschaft', 'Inklusion', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Inklusion - Einbeziehung von Menschen mit eingeschränkten Möglichkeiten in das normale Leben der Gesellschaft.',
              answerType: 'text',
            ),
            Question(
              text: 'Wer ist Eduard Assadow?',
              options: [
                'Dichter, der im Krieg sein Augenlicht verlor',
                'Paralympischer Sportler',
                'Wissenschaftler',
                'Politiker',
                'Künstler',
                'Schriftsteller'
              ],
              correctIndex: 0,
              explanation: 'Eduard Assadow - ein bekannter Dichter, der während des Großen Vaterländischen Krieges sein Augenlicht verlor, aber weiterhin schuf.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Was hilft, die Möglichkeiten von Menschen mit Einschränkungen zu erweitern?',
              options: [
                'Kenntnisse und Fertigkeiten',
                'Willenskraft',
                'Unterstützung der Umgebung',
                'Spezielle Vorrichtungen',
                'Alles Genannte',
                'Nur medizinische Hilfe'
              ],
              correctIndex: 4,
              explanation: 'Zur Erweiterung der Möglichkeiten sind Kenntnisse, Wille, Unterstützung und spezielle Mittel nötig.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Freiwillige Hilfe für Bedürftige - das ist ______.',
              options: ['Freiwilligenarbeit', 'Freiwilligenarbeit', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Freiwilligenarbeit - freiwillige, unentgeltliche Hilfe für Menschen, die sie benötigen.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist das Theater der Mimik und Gestik?',
              options: [
                'Theater für nicht hörende Schauspieler',
                'Gewöhnliches Schauspieltheater',
                'Puppentheater',
                'Straßentheater',
                'Zirkusvorstellung',
                'Musiktheater'
              ],
              correctIndex: 0,
              explanation: 'Theater der Mimik und Gestik - ein einzigartiges Theater, in dem nicht hörende Schauspieler spielen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Wie kann man Menschen mit eingeschränkten Möglichkeiten helfen?',
              options: [
                'Aufmerksamkeit zeigen',
                'Hilfe anbieten',
                'Barrierefreie Umgebung schaffen',
                'Mit Respekt behandeln',
                'Alles Genannte',
                'Ihre Probleme ignorieren'
              ],
              correctIndex: 4,
              explanation: 'Hilfe umfasst Aufmerksamkeit, konkrete Hilfe, Schaffung einer barrierefreien Umgebung und respektvollen Umgang.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Der Prozess der Anpassung an die Lebensbedingungen - das ist ______.',
              options: ['Anpassung', 'Anpassung', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Anpassung - Prozess der Anpassung des Menschen an sich verändernde Lebensbedingungen.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist eine Rampe?',
              options: [
                'Schräge Fläche für Rollstühle',
                'Treppe',
                'Aufzug',
                'Rolltreppe',
                'Gehweg',
                'Straße'
              ],
              correctIndex: 0,
              explanation: 'Rampe - eine schräge Fläche, die die Zugänglichkeit von Gebäuden für Rollstuhlfahrer gewährleistet.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Wiederherstellung verlorener Möglichkeiten - das ist ______.',
              options: ['Rehabilitation', 'Rehabilitation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Rehabilitation - Komplex von Maßnahmen zur Wiederherstellung verlorener Funktionen und Möglichkeiten.',
              answerType: 'text',
            ),
            Question(
              text: 'Wer sind Freiwillige?',
              options: [
                'Freiwillige Helfer',
                'Berufliche Arbeiter',
                'Staatsbedienstete',
                'Geschäftsleute',
                'Politiker',
                'Militärangehörige'
              ],
              correctIndex: 0,
              explanation: 'Freiwillige - Menschen, die freiwillig und unentgeltlich denen helfen, die es benötigen.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic6",
          name: 'Tätigkeit und Vielfalt ihrer Arten',
          imageAsset: '⚙️',
          description: 'Begriff der Tätigkeit und ihre Hauptarten',
          explanation: '''Schlüsselbegriffe des Themas:
• Tätigkeit - bewusste Aktivität des Menschen
• Hauptarten: Spiel, Lernen, Arbeit, Kommunikation
• Struktur der Tätigkeit: Ziel, Mittel, Handlungen, Ergebnis
• Arbeit - Tätigkeit zur Schaffung materieller und geistiger Werte
• Spiel - Tätigkeit, die für die Entwicklung von Kindern wichtig ist
• Lernen - Prozess des Erwerbs von Kenntnissen und Fertigkeiten
Tätigkeit unterscheidet den Menschen vom Tier und ermöglicht es, die Welt zu verändern.''',
          questions: [
            Question(
              text: 'Bewusste Aktivität des Menschen - das ist ______.',
              options: ['Tätigkeit', 'Tätigkeit', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Tätigkeit - das ist bewusste, zielgerichtete Aktivität des Menschen.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Hauptarten von Tätigkeit werden unterschieden?',
              options: [
                'Spiel',
                'Lernen',
                'Arbeit',
                'Kommunikation',
                'Alle Genannten',
                'Nur Arbeit'
              ],
              correctIndex: 4,
              explanation: 'Hauptarten der Tätigkeit: Spiel, Lernen, Arbeit und Kommunikation.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Was ist das Ziel der Tätigkeit?',
              options: [
                'Gewünschtes Ergebnis',
                'Mittel zur Erreichung',
                'Arbeitsprozess',
                'Fehler und Misserfolge',
                'Zufällige Ereignisse',
                'Unbewusste Handlungen'
              ],
              correctIndex: 0,
              explanation: 'Ziel - das ist das bewusste Bild des gewünschten Ergebnisses, um dessentwillen die Tätigkeit ausgeübt wird.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Tätigkeit zur Schaffung von Werten - das ist ______.',
              options: ['Arbeit', 'Arbeit', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Arbeit - Tätigkeit des Menschen, gerichtet auf die Schaffung materieller und geistiger Werte.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist Spiel als Art der Tätigkeit?',
              options: [
                'Tätigkeit um des Prozesses willen',
                'Ernsthafte Arbeit',
                'Zwangstätigkeit',
                'Nutzlose Zeitvertreibung',
                'Nur Kinderunterhaltung',
                'Lernmethode'
              ],
              correctIndex: [0, 5],
              explanation: 'Spiel - Tätigkeit, deren Motiv im Prozess selbst liegt, sowie wichtige Methode des Lernens und der Entwicklung.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Prozess des Erwerbs von Kenntnissen und Fertigkeiten - das ist ______.',
              options: ['Lernen', 'Lernen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Lernen - Tätigkeit zur Aneignung von Kenntnissen, Fertigkeiten und Fähigkeiten.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Elemente umfasst die Struktur der Tätigkeit?',
              options: [
                'Ziel',
                'Mittel',
                'Handlungen',
                'Ergebnis',
                'Alle Genannten',
                'Nur Ziel und Ergebnis'
              ],
              correctIndex: 4,
              explanation: 'Struktur der Tätigkeit umfasst Ziel, Mittel, Handlungen und Ergebnis.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Worin unterscheidet sich die Tätigkeit des Menschen vom Verhalten der Tiere?',
              options: [
                'Bewusstheit und Zielgerichtetheit',
                'Vorhandensein von Instinkten',
                'Bedürfnis nach Nahrung',
                'Fähigkeit zur Bewegung',
                'Alles Genannte',
                'Nur Größe des Gehirns'
              ],
              correctIndex: 0,
              explanation: 'Hauptunterschied - Bewusstheit, Zielgerichtetheit und Fähigkeit, Tätigkeit zu planen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Was sind Mittel der Tätigkeit?',
              options: [
                'Werkzeuge und Instrumente',
                'Kenntnisse und Fertigkeiten',
                'Materielle Ressourcen',
                'Alle Genannten',
                'Nur körperliche Kraft',
                'Nur Geld'
              ],
              correctIndex: 3,
              explanation: 'Mittel der Tätigkeit umfassen Werkzeuge, Kenntnisse, Fertigkeiten und materielle Ressourcen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Welche Art von Tätigkeit ist für einen Schüler grundlegend?',
              options: ['Lernen', 'Lernen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Für einen Schüler ist die grundlegende Art der Tätigkeit - Lernen, da gerade durch es die Entwicklung und Vorbereitung auf das Erwachsenenleben erfolgt.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist das Ergebnis der Tätigkeit?',
              options: [
                'Endprodukt der Tätigkeit',
                'Beginn neuer Tätigkeit',
                'Arbeitsprozess',
                'Planung von Handlungen',
                'Mittel zur Erreichung',
                'Ziel der Tätigkeit'
              ],
              correctIndex: 0,
              explanation: 'Ergebnis - das ist das Endprodukt, das Resultat der Tätigkeit, das bewertet werden kann.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Warum ist Spiel für Kinder wichtig?',
              options: [
                'Entwickelt die Vorstellungskraft',
                'Lehrt Verhaltensregeln',
                'Hilft, soziale Rollen zu meistern',
                'Alle Genannten',
                'Nur unterhält',
                'Lenkt vom Lernen ab'
              ],
              correctIndex: 3,
              explanation: 'Spiel erfüllt wichtige entwicklungsfördernde Funktionen: entwickelt Vorstellungskraft, lehrt Regeln und soziale Rollen.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic7",
          name: 'Erkenntnis der Welt und seiner selbst durch den Menschen',
          imageAsset: '🔍',
          description: 'Prozess der Erkenntnis und Selbsterkenntnis',
          explanation: '''Schlüsselbegriffe des Themas:
• Erkenntnis - Prozess des Erwerbs von Kenntnissen über die Welt
• Selbsterkenntnis - Erforschung seiner selbst, seiner Fähigkeiten
• Selbstwertgefühl - Bewertung der eigenen Eigenschaften und Möglichkeiten
• Selbstentwicklung - Arbeit an der Vervollkommnung seiner selbst
• Fähigkeiten - individuelle Besonderheiten der Persönlichkeit
• Talent - herausragende Fähigkeiten in einem bestimmten Bereich
Selbsterkenntnis hilft, den Platz im Leben zu finden und das Potenzial zu verwirklichen.''',
          questions: [
            Question(
              text: 'Prozess des Erwerbs von Kenntnissen über die Welt - das ist ______.',
              options: ['Erkenntnis', 'Erkenntnis', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Erkenntnis - Prozess des Erwerbs von Kenntnissen über die umgebende Welt und über sich selbst.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist Selbsterkenntnis?',
              options: [
                'Erforschung seiner selbst',
                'Erkenntnis der Natur',
                'Erforschung der Gesellschaft',
                'Wissenschaftliche Forschung',
                'Künstlerisches Schaffen',
                'Kommunikation mit anderen'
              ],
              correctIndex: 0,
              explanation: 'Selbsterkenntnis - das ist die Erforschung des Menschen seiner eigenen Eigenschaften, Fähigkeiten, Möglichkeiten.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Bewertung der eigenen Eigenschaften durch die Persönlichkeit - das ist ______.',
              options: ['Selbstwertgefühl', 'Selbstwertgefühl', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Selbstwertgefühl - Bewertung der Persönlichkeit ihrer selbst, ihrer Möglichkeiten, Eigenschaften und ihres Platzes unter anderen Menschen.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Erkenntnisquellen der Welt gibt es?',
              options: [
                'Unmittelbare Erfahrung',
                'Lernen von anderen',
                'Bücher und Internet',
                'Beobachtung und Experiment',
                'Alle Genannten',
                'Nur Schulunterricht'
              ],
              correctIndex: 4,
              explanation: 'Der Mensch erkennt die Welt durch eigene Erfahrung, Lernen, Bücher, Beobachtungen und andere Quellen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Was ist Selbstentwicklung?',
              options: [
                'Arbeit an der Vervollkommnung seiner selbst',
                'Erforschung anderer Menschen',
                'Kritik an der Umgebung',
                'Passives Abwarten von Veränderungen',
                'Nachahmung von Berühmtheiten',
                'Folgen der Mode'
              ],
              correctIndex: 0,
              explanation: 'Selbstentwicklung - bewusste Arbeit des Menschen an der Vervollkommnung seiner Eigenschaften und Fähigkeiten.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Prozess des Erkennens seiner Anlagen und ihrer Verwirklichung - das ist ______.',
              options: ['Selbstverwirklichung', 'Selbstverwirklichung', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Selbstverwirklichung - Prozess des Erkennens und Verwirklichens der eigenen Fähigkeiten und des Potenzials.',
              answerType: 'text',
            ),
            Question(
              text: 'Was hilft bei der Selbsterkenntnis?',
              options: [
                'Selbstanalyse',
                'Rückmeldung von anderen',
                'Tagebuch führen',
                'Alle Genannten',
                'Nur Intuition',
                'Nur Tests'
              ],
              correctIndex: 3,
              explanation: 'Selbsterkenntnis werden durch Selbstanalyse, Rückmeldung, Tagebuch führen und andere Methoden geholfen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Was ist ein geringes Selbstwertgefühl?',
              options: [
                'Unterschätzung der eigenen Möglichkeiten',
                'Adäquate Selbsteinschätzung',
                'Überhöhte Meinung von sich selbst',
                'Objektive Bewertung',
                'Realistischer Blick',
                'Selbstvertrauen'
              ],
              correctIndex: 0,
              explanation: 'Geringes Selbstwertgefühl - das ist die Unterschätzung des Menschen seiner Fähigkeiten und Möglichkeiten.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Arbeit an der Vervollkommnung des eigenen Charakters - das ist ______.',
              options: ['Selbsterziehung', 'Selbsterziehung', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Selbsterziehung - bewusste Arbeit des Menschen an der Herausbildung positiver Eigenschaften bei sich selbst.',
              answerType: 'text',
            ),
            Question(
              text: 'Was sind Fähigkeiten?',
              options: [
                'Individuelle Besonderheiten der Persönlichkeit',
                'Angeborene Eigenschaften',
                'Erworbenes Wissen',
                'Alle Genannten',
                'Nur Talente',
                'Nur Fertigkeiten'
              ],
              correctIndex: 3,
              explanation: 'Fähigkeiten - individuelle Besonderheiten der Persönlichkeit, die angeborene Anlagen und erworbene Fertigkeiten einschließen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Wie findet man seine Berufung?',
              options: [
                'Verschiedene Arten von Tätigkeiten ausprobieren',
                'Die eigenen Interessen erforschen',
                'Fähigkeiten entwickeln',
                'Alle Genannten',
                'Auf den Zufall warten',
                'Der Mode folgen'
              ],
              correctIndex: 3,
              explanation: 'Zur Suche nach der Berufung muss man verschiedene Beschäftigungen ausprobieren, sich selbst erforschen und Fähigkeiten entwickeln.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Herausragende Fähigkeiten in einem bestimmten Bereich - das ist ______.',
              options: ['Talent', 'Talent', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Talent - hohes Niveau der Fähigkeitsentwicklung in einer bestimmten Tätigkeit.',
              answerType: 'text',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic8",
          name: 'Kommunikation',
          imageAsset: '💬',
          description: 'Wesen und Arten der Kommunikation',
          explanation: '''Schlüsselbegriffe des Themas:
• Kommunikation - Prozess der Herstellung von Kontakten zwischen Menschen
• Arten der Kommunikation: verbale und nonverbale
• Mittel der Kommunikation: Sprache, Gesten, Mimik
• Kommunikationskultur - Einhaltung von Regeln bei der Interaktion
• Zwischenmenschliche Beziehungen - Verbindungen zwischen Menschen
• Konflikt - Aufeinandertreffen entgegengesetzter Interessen
Kommunikation ist für die Persönlichkeitsentwicklung und ein erfolgreiches Leben in der Gesellschaft notwendig.''',
          questions: [
            Question(
              text: 'Prozess der Herstellung von Kontakten zwischen Menschen - das ist ______.',
              options: ['Kommunikation', 'Kommunikation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Kommunikation - Prozess der Herstellung und Entwicklung von Kontakten zwischen Menschen.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Arten von Kommunikation gibt es?',
              options: [
                'Verbale',
                'Nonverbale',
                'Schriftliche',
                'Alle Genannten',
                'Nur mündliche',
                'Nur Gebärdensprache'
              ],
              correctIndex: 3,
              explanation: 'Es gibt verbale, nonverbale und schriftliche Kommunikation.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Kommunikation mit Hilfe von Wörtern heißt ______.',
              options: ['verbale', 'Verbale', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Verbale Kommunikation - das ist Kommunikation mit Hilfe von Wörtern (mündliche und schriftliche Sprache).',
              answerType: 'text',
            ),
            Question(
              text: 'Was gehört zur nonverbalen Kommunikation?',
              options: [
                'Gesten',
                'Mimik',
                'Körperhaltung',
                'Intonation',
                'Alle Genannten',
                'Nur Wörter'
              ],
              correctIndex: 4,
              explanation: 'Nonverbale Kommunikation umfasst Gesten, Mimik, Körperhaltungen, Intonation und andere nichtsprachliche Mittel.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Form der Kommunikation von Menschen mittels Sprache - das ist ______.',
              options: ['Sprache', 'Sprache', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Sprache - Form der Kommunikation von Menschen mittels Sprache.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Funktionen erfüllt Kommunikation?',
              options: [
                'Austausch von Informationen',
                'Weitergabe von Erfahrung',
                'Ausdruck von Emotionen',
                'Organisation gemeinsamer Tätigkeit',
                'Alle Genannten',
                'Nur Informationsübermittlung'
              ],
              correctIndex: 4,
              explanation: 'Kommunikation erfüllt informative, emotionale, regulative und andere wichtige Funktionen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Einhaltung von Regeln bei der Interaktion mit Menschen - das ist Kultur der ______.',
              options: ['Kommunikation', 'Kommunikation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Kommunikationskultur - Einhaltung von Regeln und Normen bei der Interaktion mit Menschen.',
              answerType: 'text',
            ),
            Question(
              text: 'Was sind zwischenmenschliche Beziehungen?',
              options: [
                'Verbindungen zwischen Menschen',
                'Beziehungen zwischen Staaten',
                'Wirtschaftliche Verbindungen',
                'Politische Beziehungen',
                'Geschäftskontakte',
                'Nur freundschaftliche Beziehungen'
              ],
              correctIndex: 0,
              explanation: 'Zwischenmenschliche Beziehungen - das sind Wechselbeziehungen zwischen Menschen im Prozess gemeinsamer Tätigkeit und Kommunikation.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Wie sollte ein guter Gesprächspartner sein?',
              options: [
                'Zuhören können',
                'Aufmerksamkeit zeigen',
                'Meinung anderer respektieren',
                'Alle Genannten',
                'Nur viel reden',
                'Nur kritisieren'
              ],
              correctIndex: 3,
              explanation: 'Ein guter Gesprächspartner kann zuhören, zeigt Aufmerksamkeit und Respekt gegenüber anderen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Gesichtsausdruck des Menschen - das ist ______.',
              options: ['Mimik', 'Mimik', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Mimik - Bewegungen der Gesichtsmuskeln, die den inneren Zustand des Menschen ausdrücken.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum ist Kommunikation für den Menschen wichtig?',
              options: [
                'Zum Informationsaustausch',
                'Zur emotionalen Unterstützung',
                'Zur gemeinsamen Tätigkeit',
                'Alle Genannten',
                'Nur zur Unterhaltung',
                'Nur für die Arbeit'
              ],
              correctIndex: 3,
              explanation: 'Kommunikation ist notwendig zum Informationsaustausch, zur emotionalen Unterstützung und Organisation gemeinsamer Tätigkeit.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Bewegungen der Hände bei der Kommunikation - das ist ______.',
              options: ['Gesten', 'Gesten', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Gesten - Bewegungen der Hände und anderer Körperteile, die bei der Kommunikation verwendet werden.',
              answerType: 'text',
            ),
          ],
        ),
        Topic(
          id: "social_studies_class6_topic9",
          name: 'Konflikte und ihre Lösung',
          imageAsset: '⚡',
          description: 'Ursachen von Konflikten und Wege zu ihrer Lösung',
          explanation: '''Schlüsselbegriffe des Themas:
• Konflikt - Aufeinandertreffen von Interessen, Meinungen
• Ursachen: Unterschiede in Zielen, Missverständnisse, Ressourcenknappheit
• Konstruktiver Konflikt - führt zur Problemlösung
• Verhaltensstrategien: Zusammenarbeit, Kompromiss, Vermeidung
• Vermittlung - Hilfe einer dritten Partei bei der Konfliktlösung
• Integration - Vereinigung der Positionen nach dem Konflikt
Die Fähigkeit, Konflikte zu lösen - eine wichtige soziale Kompetenz.''',
          questions: [
            Question(
              text: 'Aufeinandertreffen entgegengesetzter Interessen - das ist ______.',
              options: ['Konflikt', 'Konflikt', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Konflikt - Aufeinandertreffen entgegengesetzter Interessen, Ansichten, Positionen.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Ursachen können Konflikte haben?',
              options: [
                'Unterschiede in Interessen',
                'Missverständnis',
                'Ressourcenknappheit',
                'Gegensätzliche Ziele',
                'Alle Genannten',
                'Nur persönliche Abneigung'
              ],
              correctIndex: 4,
              explanation: 'Ursachen von Konflikten schließen alle genannten Faktoren ein.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Vorfall oder Geschehnis, das zu einem Konflikt führen kann - das ist ______.',
              options: ['Vorfall', 'Vorfall', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Vorfall - ein Geschehnis, Missverständnis, das zu einem Konflikt führen kann.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Wege der Konfliktlösung sind konstruktiv?',
              options: [
                'Kompromiss',
                'Zusammenarbeit',
                'Verhandlungen',
                'Aggression',
                'Vermeidung',
                'Zwang'
              ],
              correctIndex: [0, 1, 2],
              explanation: 'Konstruktive Wege: Kompromiss, Zusammenarbeit, Verhandlungen.',
              answerType: 'multiple_choice',
            ),
            Question(
              text: 'Herausbildung einer einheitlichen Meinung im Konflikt - das ist ______.',
              options: ['Integration', 'Integration', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Integration im Konfliktprozess bedeutet Herausbildung einer einheitlichen Meinung als Ergebnis der Veränderung der Positionen der Seiten.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist ein Kompromiss?',
              options: [
                'Gegenseitige Zugeständnisse zur Erreichung einer Einigung',
                'Vollständiger Sieg einer Seite',
                'Vermeidung der Problemlösung',
                'Zwang zur Einigung',
                'Ignorieren des Konflikts',
                'Abbruch der Beziehungen'
              ],
              correctIndex: 0,
              explanation: 'Kompromiss - gegenseitige Zugeständnisse der Seiten zur Erreichung einer Einigung im Konflikt.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Hilfe einer dritten Partei bei der Lösung eines Konflikts - das ist ______.',
              options: ['Vermittlung', 'Vermittlung', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Vermittlung - Beteiligung einer neutralen Person an der Lösung eines Konflikts zwischen den Seiten.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Verhaltensstrategien im Konflikt gibt es?',
              options: [
                'Konkurrenz',
                'Zusammenarbeit',
                'Kompromiss',
                'Vermeidung',
                'Anpassung',
                'Alle Genannten'
              ],
              correctIndex: 5,
              explanation: 'Man unterscheidet fünf grundlegende Verhaltensstrategien im Konflikt.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Was ist ein konstruktiver Konflikt?',
              options: [
                'Konflikt, der zur Problemlösung führt',
                'Konflikt mit Anwendung von Gewalt',
                'Konflikt ohne Lösung',
                'Versteckter Konflikt',
                'Langanhaltender Konflikt',
                'Zwischenmenschlicher Konflikt'
              ],
              correctIndex: 0,
              explanation: 'Konstruktiver Konflikt hilft, das Problem aufzudecken und zu lösen, die Beziehungen zu verbessern.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Weg der Konfliktlösung durch gegenseitige Zugeständnisse - das ist ______.',
              options: ['Kompromiss', 'Kompromiss', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Kompromiss - Weg der Konfliktlösung durch gegenseitige Zugeständnisse der Seiten.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Kommunikationsbarrieren können zu Konflikten führen?',
              options: [
                'Bedeutungsbarriere',
                'Emotionaler Barriere',
                'Moralischer Barriere',
                'Alle Genannten',
                'Nur Sprachbarriere',
                'Nur Altersbarriere'
              ],
              correctIndex: 3,
              explanation: 'Alle genannten Barrieren können Ursache von Missverständnissen und Konflikten werden.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Verweigerung der Fortsetzung des Konflikts - das ist ______.',
              options: ['Vermeidung', 'Vermeidung', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Vermeidung - Verhaltensstrategie im Konflikt, bei der eine Person der Konfrontation ausweicht.',
              answerType: 'text',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic10",
          name: 'Der Mensch in der Kleingruppe',
          imageAsset: '👥',
          description: 'Position des Menschen in der Gruppe und Gruppenbeziehungen',
          explanation: '''Schlüsselbegriffe des Themas:
• Kleingruppe - kleine Vereinigung von Menschen (Familie, Klasse, Freunde)
• Leiter - Person, die Einfluss auf die Gruppe ausübt
• Gruppenormen - Verhaltensregeln in der Gruppe
• Rolle - Position des Menschen in der Gruppe
• Kollektiv - Gruppe, die durch gemeinsame Ziele vereint ist
• Freiwilligenarbeit - freiwillige Tätigkeit zum Wohl anderer
Die Gruppe beeinflusst die Persönlichkeitsentwicklung und die Wertebildung.''',
          questions: [
            Question(
              text: 'Kleine Vereinigung von Menschen - das ist ______ Gruppe.',
              options: ['kleine', 'Kleine', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Kleingruppe - kleine, nach Zusammensetzung Vereinigung von Menschen, die durch gemeinsame Tätigkeit verbunden sind.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Beispiele für Kleingruppen kennen Sie?',
              options: [
                'Familie',
                'Schulklasse',
                'Freundeskreis',
                'Sportmannschaft',
                'Alle Genannten',
                'Nur große Organisationen'
              ],
              correctIndex: 4,
              explanation: 'Alle Genannten sind Beispiele für Kleingruppen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Person, die Einfluss auf die Gruppe ausübt - das ist ______.',
              options: ['Leiter', 'Leiter', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Leiter - Mitglied der Gruppe, das Einfluss auf andere ausübt und ihre Tätigkeit organisiert.',
              answerType: 'text',
            ),
            Question(
              text: 'Was sind Gruppenormen?',
              options: [
                'Verhaltensregeln in der Gruppe',
                'Staatsgesetze',
                'Moralische Prinzipien',
                'Persönliche Überzeugungen',
                'Zufällige Handlungen',
                'Individuelle Gewohnheiten'
              ],
              correctIndex: 0,
              explanation: 'Gruppennormen - Regeln und Verhaltensstandards, die in einer konkreten Gruppe angenommen sind.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Position des Menschen in der Gruppe - das ist seine ______.',
              options: ['Rolle', 'Rolle', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Rolle - Position des Menschen in der Gruppe, die seine Rechte und Pflichten bestimmt.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist ein Kollektiv?',
              options: [
                'Gruppe mit gemeinsamen Zielen',
                'Zufällige Vereinigung',
                'Menschenmenge',
                'Schlange im Geschäft',
                'Busfahrgäste',
                'Leute auf einem Konzert'
              ],
              correctIndex: 0,
              explanation: 'Kollektiv - Gruppe von Menschen, die durch gemeinsame Ziele und gemeinsame Tätigkeit vereint sind.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Welche Eigenschaften sind für einen Leiter wichtig?',
              options: [
                'Verantwortung',
                'Organisatorische Fähigkeiten',
                'Kommunikationsfähigkeit',
                'Alle Genannten',
                'Nur körperliche Stärke',
                'Nur Reichtum'
              ],
              correctIndex: 3,
              explanation: 'Einem Leiter sind Verantwortung, organisatorische Fähigkeiten und Kommunikationsfähigkeit mit Menschen wichtig.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Gruppe, die durch gemeinsame Ziele vereint ist - das ist ______.',
              options: ['Kollektiv', 'Kollektiv', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Kollektiv - Gruppe, die durch gemeinsame Ziele und gemeinsame Tätigkeit vereint ist.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum schließen sich Menschen in Gruppen zusammen?',
              options: [
                'Zur Erreichung gemeinsamer Ziele',
                'Zur Kommunikation und Unterstützung',
                'Zum Schutz von Interessen',
                'Alle Genannten',
                'Nur unter Zwang',
                'Nur wegen Einsamkeit'
              ],
              correctIndex: 3,
              explanation: 'Menschen schließen sich in Gruppen zur Erreichung von Zielen, Kommunikation, Unterstützung und Schutz von Interessen zusammen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Verhaltensregeln in der Gruppe - das sind gruppen ______.',
              options: ['Normen', 'Normen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Gruppennormen - Verhaltensregeln, die in einer konkreten Gruppe angenommen sind.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist die Timur-Bewegung?',
              options: [
                'Hilfe für Bedürftige',
                'Politische Organisation',
                'Sportbewegung',
                'Kommerzielle Struktur',
                'Religiöse Gemeinschaft',
                'Wissenschaftliche Gesellschaft'
              ],
              correctIndex: 0,
              explanation: 'Timur-Bewegung - Kinderbewegung zur Hilfe für Bedürftige, entstanden nach dem Erscheinen des Buches "Timur und sein Trupp".',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Freiwillige Hilfe für andere - das ist ______.',
              options: ['Freiwilligenarbeit', 'Freiwilligenarbeit', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Freiwilligenarbeit - freiwillige, unentgeltliche Tätigkeit zum Wohl anderer Menschen.',
              answerType: 'text',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic11",
          name: 'Familie und Familienbeziehungen',
          imageAsset: '🏠',
          description: 'Familie als Kleingruppe und Familienwerte',
          explanation: '''Schlüsselbegriffe des Themas:
• Familie - Kleingruppe, gegründet auf Ehe oder Verwandtschaft
• Funktionen der Familie: Erziehung, Haushalt, Emotionen
• Familientraditionen - Bräuche, die von Generation zu Generation weitergegeben werden
• Generation - Menschen gleichen Alters in der Familie
• Familienwerte - für die Familie wichtige Prinzipien und Überzeugungen
• Verständnis - Grundlage harmonischer Familienbeziehungen
Die Familie spielt eine Schlüsselrolle bei der Persönlichkeitsbildung des Menschen.''',
          questions: [
            Question(
              text: 'Kleingruppe, gegründet auf Ehe oder Verwandtschaft - das ist ______.',
              options: ['Familie', 'Familie', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Familie - Kleingruppe, gegründet auf Ehe, Blutsverwandtschaft oder Adoption.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Funktionen erfüllt die Familie?',
              options: [
                'Erziehungsfunktion',
                'Haushaltsfunktion',
                'Emotionale Funktion',
                'Reproduktionsfunktion',
                'Alle Genannten',
                'Nur wirtschaftliche Funktion'
              ],
              correctIndex: 4,
              explanation: 'Die Familie erfüllt viele Funktionen: Erziehungs-, Haushalts-, emotionale, Reproduktionsfunktion und andere.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Bräuche, die in der Familie von Generation zu Generation weitergegeben werden - das sind familiäre ______.',
              options: ['Traditionen', 'Traditionen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Familientraditionen - Bräuche, Rituale, Verhaltensregeln, die in der Familie von Generation zu Generation weitergegeben werden.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Arten von Familien gibt es nach der Zusammensetzung?',
              options: [
                'Vollständige',
                'Unvollständige',
                'Kinderreiche',
                'Kinderarme',
                'Alle Genannten',
                'Nur traditionelle'
              ],
              correctIndex: 4,
              explanation: 'Familien unterscheiden sich nach Zusammensetzung: vollständige, unvollständige, kinderreiche, kinderarme und andere.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Menschen gleichen Alters in der Familie - das ist ______.',
              options: ['Generation', 'Generation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Generation - Gruppe von Menschen gleichen Alters in der Familie oder Gesellschaft.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist eine dreigenerationenfamilie?',
              options: [
                'Familie, in der Kinder, Eltern und Großeltern leben',
                'Familie mit drei Kindern',
                'Familie, die drei Generationen existiert',
                'Junge Familie',
                'Familie ohne Kinder',
                'Familie mit Pflegekindern'
              ],
              correctIndex: 0,
              explanation: 'Dreigenerationenfamilie - Familie, in der drei Generationen von Verwandten gemeinsam wohnen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Für die Familie wichtige Prinzipien und Überzeugungen - das sind familiäre ______.',
              options: ['Werte', 'Werte', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Familienwerte - für die Familie wichtige Prinzipien, Überzeugungen und Traditionen.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Arten von Familienbeziehungen gibt es?',
              options: [
                'Zusammenarbeit',
                'Bevormundung',
                'Nichteinmischung',
                'Diktat',
                'Alle Genannten',
                'Nur demokratische'
              ],
              correctIndex: 4,
              explanation: 'In Familien können sich verschiedene Beziehungstypen entwickeln: Zusammenarbeit, Bevormundung, Nichteinmischung, Diktat.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Grundlage harmonischer Familienbeziehungen - das ist ______.',
              options: ['Verständnis', 'Verständnis', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Verständnis - Fähigkeit, einander zu verstehen, Grundlage harmonischer Familienbeziehungen.',
              answerType: 'text',
            ),
            Question(
              text: 'Was sind Familienpflichten?',
              options: [
                'Pflichten der Familienmitglieder zur Haushaltsführung',
                'Staatliche Pflichten',
                'Berufliche Pflichten',
                'Lernpflichten',
                'Gesellschaftliche Pflichten',
                'Persönliche Angelegenheiten'
              ],
              correctIndex: 0,
              explanation: 'Familienpflichten - Verteilung von Aufgaben und Verantwortung zwischen den Familienmitgliedern.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Gemeinsames Abendessen oder Lesen von Büchern in der Familie - das ist ein Beispiel für familiäre ______.',
              options: ['Traditionen', 'Traditionen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Gemeinsame Mahlzeiten, Lesen, Erholung - Beispiele für Familientraditionen, die die Beziehungen stärken.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum ist es wichtig, die Älteren in der Familie zu respektieren?',
              options: [
                'Sie haben Lebenserfahrung',
                'Sie kümmern sich um die Jüngeren',
                'Sie geben Traditionen weiter',
                'Alle Genannten',
                'Nur aus Höflichkeit',
                'Nur aus Pflicht'
              ],
              correctIndex: 3,
              explanation: 'Ältere Familienmitglieder besitzen Erfahrung, kümmern sich um die Jüngeren und geben Familientraditionen weiter.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic12",
          name: 'Schulbildung',
          imageAsset: '🎓',
          description: 'Recht auf Bildung und Schulleben',
          explanation: '''Schlüsselbegriffe des Themas:
• Bildung - Prozess des Lernens und der Erziehung
• Recht auf Bildung - eines der grundlegenden Menschenrechte
• Allgemeinzugänglichkeit - Möglichkeit, Bildung für alle zu erhalten
• Schulpflicht - Anforderung des Bildungsabschlusses
• Schülerpflichten - Verhaltensregeln in der Schule
• Lernfähigkeit - wichtige Fertigkeit für erfolgreiches Lernen
Bildung spielt eine Schlüsselrolle in der Entwicklung der Persönlichkeit und der Gesellschaft.''',
          questions: [
            Question(
              text: 'Prozess des Lernens und der Erziehung - das ist ______.',
              options: ['Bildung', 'Bildung', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Bildung - zielgerichteter Prozess des Lernens und der Erziehung im Interesse des Menschen und der Gesellschaft.',
              answerType: 'text',
            ),
            Question(
              text: 'Was garantiert das Recht auf Bildung in Russland?',
              options: [
                'Allgemeinzugänglichkeit',
                'Kostenfreiheit',
                'Schulpflicht',
                'Alle Genannten',
                'Nur kostenpflichtige Bildung',
                'Nur für einige'
              ],
              correctIndex: 3,
              explanation: 'Die Verfassung garantiert Allgemeinzugänglichkeit, Kostenfreiheit und Schulpflicht der Bildung.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Möglichkeit, Bildung für alle zu erhalten - das ist ______.',
              options: ['Allgemeinzugänglichkeit', 'Allgemeinzugänglichkeit', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Allgemeinzugänglichkeit der Bildung bedeutet, dass jeder unabhängig von verschiedenen Umständen das Recht auf Bildung hat.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Stufen der allgemeinen Bildung gibt es in Russland?',
              options: [
                'Primarstufe',
                'Sekundarstufe I',
                'Sekundarstufe II',
                'Alle Genannten',
                'Nur Primarstufe',
                'Nur Hochschulbildung'
              ],
              correctIndex: 3,
              explanation: 'Das System der allgemeinen Bildung umfasst primare, grundlegende und sekundare allgemeine Bildung.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Anforderung des Bildungsabschlusses - das ist seine ______.',
              options: ['Schulpflicht', 'Schulpflicht', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Schulpflicht bedeutet, dass alle Kinder Bildung im festgelegten Umfang erhalten müssen.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist die Schulordnung?',
              options: [
                'Hauptdokument der Schule',
                'Liste der Lehrer',
                'Stundenplan',
                'Schulzeitung',
                'Fotos der Absolventen',
                'Schulbibliothek'
              ],
              correctIndex: 0,
              explanation: 'Schulordnung - Hauptdokument, das die Rechte und Pflichten der Teilnehmer des Bildungsprozesses bestimmt.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Verhaltensregeln in der Schule - das sind schüler ______.',
              options: ['Pflichten', 'Pflichten', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Schülerpflichten schließen Verhaltensregeln ein, die die Schüler befolgen müssen.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Rechte haben Schüler?',
              options: [
                'Recht auf Bildung',
                'Recht auf Achtung ihrer Würde',
                'Recht auf Teilnahme an der Schulverwaltung',
                'Alle Genannten',
                'Nur Recht auf Erholung',
                'Nur Recht auf Verpflegung'
              ],
              correctIndex: 3,
              explanation: 'Schüler haben einen Komplex von Rechten, einschließlich des Rechts auf Bildung, Achtung der Würde, Teilnahme an der Schulverwaltung.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Wichtige Fertigkeit für erfolgreiches Lernen - die Fähigkeit ______.',
              options: ['zu lernen', 'Zu lernen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Lernfähigkeit - Fähigkeit, selbständig Kenntnisse zu erwerben, wichtig für erfolgreiches Lernen.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist Selbstbildung?',
              options: [
                'Selbständiger Erwerb von Kenntnissen',
                'Lernen in der Schule',
                'Unterricht mit Nachhilfelehrer',
                'Hausaufgaben erledigen',
                'Teilnahme an Olympiaden',
                'Besuch von Arbeitsgemeinschaften'
              ],
              correctIndex: 0,
              explanation: 'Selbstbildung - selbständiges Studium des Materials, Erwerb von Kenntnissen ohne Hilfe eines Lehrers.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Hauptart der Tätigkeit eines Schülers - das ist ______.',
              options: ['Lernen', 'Lernen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Für einen Schüler ist die Hauptart der Tätigkeit - Lernen, da gerade durch es die Entwicklung erfolgt.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum ist es wichtig, gewissenhaft zu lernen?',
              options: [
                'Zum Erwerb von Kenntnissen',
                'Zur Entwicklung von Fähigkeiten',
                'Zur Vorbereitung auf das zukünftige Leben',
                'Alle Genannten',
                'Nur für gute Noten',
                'Nur damit Eltern nicht schimpfen'
              ],
              correctIndex: 3,
              explanation: 'Gewissenhaftes Lernen ist wichtig zum Erwerb von Kenntnissen, Entwicklung von Fähigkeiten und Vorbereitung auf das Erwachsenenleben.',
              answerType: 'single_choice',
            ),
          ],
        ),

        // Fortsetzung für die verbleibenden 7 Themen...
        Topic(
          id: "social_studies_class6_topic13",
          name: 'Wie die Gesellschaft aufgebaut ist',
          imageAsset: '🏛️',
          description: 'Struktur der Gesellschaft und gesellschaftliche Beziehungen',
          explanation: '''Schlüsselbegriffe des Themas:
• Gesellschaft - Vereinigung von Menschen, die gemeinsame Interessen haben
• Gesellschaftliche Beziehungen - Verbindungen zwischen Menschen in der Gesellschaft
• Lebensbereiche der Gesellschaft: wirtschaftlich, politisch, sozial, geistig
• Soziale Gruppen - stabile Vereinigungen von Menschen
• Soziale Normen - Verhaltensregeln in der Gesellschaft
• Soziale Kontrolle - Mechanismus zur Aufrechterhaltung der Ordnung
Die Gesellschaft - ein komplexes System, in dem alle Elemente miteinander verbunden sind.''',
          questions: [
            Question(
              text: 'Vereinigung von Menschen, die gemeinsame Interessen haben - das ist ______.',
              options: ['Gesellschaft', 'Gesellschaft', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Gesellschaft - Vereinigung von Menschen, verbunden durch gemeinsame Interessen, Ziele und Tätigkeit.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Lebensbereiche der Gesellschaft werden unterschieden?',
              options: [
                'Wirtschaftlicher',
                'Politischer',
                'Sozialer',
                'Geistiger',
                'Alle Genannten',
                'Nur wirtschaftlicher und politischer'
              ],
              correctIndex: 4,
              explanation: 'Man unterscheidet vier grundlegende Lebensbereiche der Gesellschaft: wirtschaftlichen, politischen, sozialen und geistigen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Verbindungen zwischen Menschen in der Gesellschaft - das sind gesellschaftliche ______.',
              options: ['Beziehungen', 'Beziehungen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Gesellschaftliche Beziehungen - stabile Verbindungen zwischen Menschen, die im Prozess gemeinsamer Tätigkeit entstehen.',
              answerType: 'text',
            ),
            Question(
              text: 'Was sind soziale Gruppen?',
              options: [
                'Stabile Vereinigungen von Menschen',
                'Zufällige Ansammlungen von Menschen',
                'Menge auf einem Konzert',
                'Schlange im Geschäft',
                'Busfahrgäste',
                'Leute auf der Straße'
              ],
              correctIndex: 0,
              explanation: 'Soziale Gruppen - stabile Vereinigungen von Menschen, verbunden durch gemeinsame Interessen und Tätigkeit.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Verhaltensregeln in der Gesellschaft - das sind soziale ______.',
              options: ['Normen', 'Normen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Soziale Normen - Verhaltensregeln, die in der Gesellschaft angenommen sind und die Beziehungen zwischen Menschen regeln.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Arten von gesellschaftlichen Beziehungen gibt es?',
              options: [
                'Zusammenarbeit',
                'Konkurrenz',
                'Beides',
                'Nur Zusammenarbeit',
                'Nur Konkurrenz',
                'Weder das eine noch das andere'
              ],
              correctIndex: 2,
              explanation: 'In der Gesellschaft existieren sowohl Beziehungen der Zusammenarbeit als auch Beziehungen der Konkurrenz.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Mechanismus zur Aufrechterhaltung der Ordnung in der Gesellschaft - das ist soziale ______.',
              options: ['Kontrolle', 'Kontrolle', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Soziale Kontrolle - Mechanismus zur Aufrechterhaltung der gesellschaftlichen Ordnung durch soziale Normen und Sanktionen.',
              answerType: 'text',
            ),
            Question(
              text: 'Wie sind Gesellschaft und Natur verbunden?',
              options: [
                'Die Gesellschaft hängt von der Natur ab',
                'Die Gesellschaft verändert die Natur',
                'Die Natur beeinflusst die Entwicklung der Gesellschaft',
                'Alle Genannten',
                'Nur die Gesellschaft beeinflusst die Natur',
                'Nur die Natur beeinflusst die Gesellschaft'
              ],
              correctIndex: 3,
              explanation: 'Gesellschaft und Natur sind miteinander verbunden: Die Gesellschaft hängt von der Natur ab und verändert sie gleichzeitig.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Stabile Vereinigungen von Menschen - das sind soziale ______.',
              options: ['Gruppen', 'Gruppen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Soziale Gruppen - stabile Vereinigungen von Menschen, verbunden durch gemeinsame Interessen und Tätigkeit.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist eine soziale Institution?',
              options: [
                'Stabile Form der Organisation des gesellschaftlichen Lebens',
                'Zeitweilige Vereinigung',
                'Zufällige Gruppe',
                'Informelle Gemeinschaft',
                'Menschenmenge',
                'Schlange'
              ],
              correctIndex: 0,
              explanation: 'Soziale Institution - stabile Form der Organisation des gesellschaftlichen Lebens, die einen bestimmten Bereich der Beziehungen regelt.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Bereich der Produktion und Verteilung von Gütern - das ist ______ Bereich.',
              options: ['wirtschaftlicher', 'Wirtschaftlicher', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Wirtschaftlicher Bereich - Bereich des gesellschaftlichen Lebens, verbunden mit Produktion, Verteilung und Konsum von Gütern.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum gilt die Gesellschaft als komplexes System?',
              options: [
                'Besteht aus miteinander verbundenen Elementen',
                'Alle Elemente beeinflussen sich gegenseitig',
                'Veränderungen in einem Teil beeinflussen andere',
                'Alle Genannten',
                'Nur weil es viele Menschen gibt',
                'Nur wegen komplizierter Gesetze'
              ],
              correctIndex: 3,
              explanation: 'Die Gesellschaft - komplexes System, weil sie aus miteinander verbundenen Elementen besteht, Veränderungen in denen das ganze System beeinflussen.',
              answerType: 'single_choice',
            ),
          ],
        ),
        Topic(
          id: "social_studies_class6_topic14",
          name: 'Unser Land im 21. Jahrhundert',
          imageAsset: '🇷🇺',
          description: 'Russland als moderner Staat',
          explanation: '''Schlüsselbegriffe des Themas:
• Russische Föderation - souveräner Staat
• Verfassung - Grundgesetz des Landes
• Staatssymbole: Flagge, Wappen, Hymne
• Multinationalität - Vielfalt der Völker Russlands
• Patriotismus - Liebe zum Vaterland
• Internationale Beziehungen - Verbindungen mit anderen Ländern
Russland - größter Staat der Welt mit reicher Geschichte und Kultur.''',
          questions: [
            Question(
              text: 'Grundgesetz unseres Landes - das ist ______.',
              options: ['Verfassung', 'verfassung', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Verfassung der Russischen Föderation - Grundgesetz, das höchste juristische Kraft hat.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Staatssymbole Russlands kennen Sie?',
              options: [
                'Flagge',
                'Wappen',
                'Hymne',
                'Alle Genannten',
                'Nur Flagge',
                'Nur Wappen'
              ],
              correctIndex: 3,
              explanation: 'Staatssymbole Russlands: Flagge, Wappen und Hymne.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Liebe zum Vaterland - das ist ______.',
              options: ['Patriotismus', 'Patriotismus', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Patriotismus - Liebe zu seinem Vaterland, Treue zu seinem Volk.',
              answerType: 'text',
            ),
            Question(
              text: 'Wie viele Völker leben in Russland?',
              options: [
                'Mehr als 100',
                'Etwa 50',
                'Nur Russen',
                '10-15 Völker',
                'Nur slawische Völker',
                '5-6 Völker'
              ],
              correctIndex: 0,
              explanation: 'In Russland leben Vertreter von mehr als 100 Völkern und Nationalitäten.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Oberhaupt des Russischen Staates - das ist ______.',
              options: ['Präsident', 'präsident', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Präsident der Russischen Föderation - Oberhaupt des Staates, Garant der Verfassung.',
              answerType: 'text',
            ),
            Question(
              text: 'Was bedeutet die weiße Farbe auf der Flagge Russlands?',
              options: [
                'Frieden und Reinheit',
                'Blut der Verteidiger',
                'Reichtum',
                'Fruchtbarkeit der Erde',
                'Himmel',
                'Treue'
              ],
              correctIndex: 0,
              explanation: 'Weiße Farbe auf der Flagge symbolisiert Frieden, Reinheit, Unschuld.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Organ, das Gesetze in Russland verabschiedet - das ist ______ Versammlung.',
              options: ['Föderale', 'föderale', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Föderale Versammlung - Parlament Russlands, bestehend aus zwei Kammern.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Werte sind in der Verfassung Russlands verankert?',
              options: [
                'Familie und Ehe',
                'Multinationale Kultur',
                'Schutz der Kinder',
                'Alle Genannten',
                'Nur politische Rechte',
                'Nur wirtschaftliche Freiheiten'
              ],
              correctIndex: 3,
              explanation: 'In der Verfassung sind traditionelle Werte verankert: Familie, Kultur, Schutz der Kinder.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Der Doppeladler auf dem Wappen Russlands symbolisiert ______.',
              options: ['Einheit der Völker', 'Einheit der Völker', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Der Doppeladler symbolisiert die Einheit der Völker Russlands, die im europäischen und asiatischen Teil des Landes leben.',
              answerType: 'text',
            ),
            Question(
              text: 'Was sind internationale Beziehungen?',
              options: [
                'Verbindungen zwischen Staaten',
                'Beziehungen innerhalb des Landes',
                'Lokale Selbstverwaltung',
                'Kommunikation zwischen Menschen',
                'Geschäftskontakte',
                'Familienbeziehungen'
              ],
              correctIndex: 0,
              explanation: 'Internationale Beziehungen - das sind Verbindungen und Interaktionen zwischen verschiedenen Staaten.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Russland ist ein ______ Staat.',
              options: ['föderaler', 'Föderaler', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Russische Föderation - föderaler Staat, bestehend aus Föderationssubjekten.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum wird Russland multinationales Land genannt?',
              options: [
                'Hier leben verschiedene Völker',
                'Verschiedene Kulturen und Traditionen',
                'Viele Sprachen und Religionen',
                'Alle Genannten',
                'Nur wegen großer Bevölkerung',
                'Nur wegen Größe des Territoriums'
              ],
              correctIndex: 3,
              explanation: 'Russland ist multinational, weil hier verschiedene Völker mit einzigartigen Kulturen, Sprachen und Traditionen leben.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic15",
          name: 'Wirtschaft - Grundlage des Gesellschaftslebens',
          imageAsset: '💰',
          description: 'Wirtschaftliche Tätigkeit und ihre Rolle',
          explanation: '''Schlüsselbegriffe des Themas:
• Wirtschaft - wirtschaftliche Tätigkeit der Gesellschaft
• Produktion - Schaffung von Waren und Dienstleistungen
• Konsum - Nutzung von Waren und Dienstleistungen
• Ressourcen - Mittel für die Produktion
• Warenwirtschaft - Produktion für den Austausch
• Naturalwirtschaft - Produktion für sich selbst
Die Wirtschaft befriedigt die Bedürfnisse der Menschen durch Produktion und Verteilung von Gütern.''',
          questions: [
            Question(
              text: 'Wirtschaftliche Tätigkeit der Gesellschaft - das ist ______.',
              options: ['Wirtschaft', 'Wirtschaft', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Wirtschaft - Wirtschaftssystem, das die Befriedigung der Bedürfnisse der Menschen sicherstellt.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Hauptstadien der wirtschaftlichen Tätigkeit gibt es?',
              options: [
                'Produktion',
                'Verteilung',
                'Austausch',
                'Konsum',
                'Alle Genannten',
                'Nur Produktion'
              ],
              correctIndex: 4,
              explanation: 'Der Wirtschaftskreislauf umfasst Produktion, Verteilung, Austausch und Konsum.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Schaffung von Waren und Dienstleistungen - das ist ______.',
              options: ['Produktion', 'Produktion', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Produktion - Prozess der Schaffung wirtschaftlicher Güter (Waren und Dienstleistungen).',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist Naturalwirtschaft?',
              options: [
                'Produktion für den Eigenbedarf',
                'Produktion für den Verkauf',
                'Handel mit Waren',
                'Erbringung von Dienstleistungen',
                'Industrielle Produktion',
                'Landwirtschaft'
              ],
              correctIndex: 0,
              explanation: 'Naturalwirtschaft - Produktion von Produkten für den Eigenbedarf, nicht für den Verkauf.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Nutzung von Waren und Dienstleistungen - das ist ______.',
              options: ['Konsum', 'Konsum', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Konsum - Nutzung von Waren und Dienstleistungen zur Befriedigung von Bedürfnissen.',
              answerType: 'text',
            ),
            Question(
              text: 'Wer sind Produzenten?',
              options: [
                'Diejenigen, die Waren und Dienstleistungen schaffen',
                'Diejenigen, die Waren kaufen',
                'Diejenigen, die Reichtümer verteilen',
                'Diejenigen, die Produkte konsumieren',
                'Diejenigen, die Geld sparen',
                'Diejenigen, die Handel betreiben'
              ],
              correctIndex: 0,
              explanation: 'Produzenten - Teilnehmer der Wirtschaft, die Waren schaffen und Dienstleistungen erbringen.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Mittel für die Produktion - das sind wirtschaftliche ______.',
              options: ['Ressourcen', 'Ressourcen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Wirtschaftliche Ressourcen - alle Arten von Mitteln, die im Produktionsprozess verwendet werden.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist Warenwirtschaft?',
              options: [
                'Produktion für Austausch und Verkauf',
                'Produktion für sich selbst',
                'Kostenlose Verteilung',
                'Naturalproduktion',
                'Handarbeit',
                'Hauswirtschaft'
              ],
              correctIndex: 0,
              explanation: 'Warenwirtschaft - Produktion von Produkten für den Austausch durch Kauf und Verkauf.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Teilnehmer der Wirtschaft, die Waren nutzen - das sind ______.',
              options: ['Konsumenten', 'Konsumenten', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Konsumenten - Teilnehmer der Wirtschaft, die Waren und Dienstleistungen zur Befriedigung von Bedürfnissen nutzen.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Ressourcen hat Russland?',
              options: [
                'Natürliche Reichtümer',
                'Qualifizierte Arbeitskräfte',
                'Entwickelte Industrie',
                'Alle Genannten',
                'Nur Bodenschätze',
                'Nur Landwirtschaft'
              ],
              correctIndex: 3,
              explanation: 'Russland besitzt vielfältige Ressourcen: natürliche, menschliche, industrielle.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Prozess des Erhalts eines gewünschten Produkts im Austausch gegen ein anderes - das ist ______.',
              options: ['Austausch', 'Austausch', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Austausch - wirtschaftliche Operation, bei der ein Produkt im Austausch gegen ein anderes erhalten wird.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum ist die Wirtschaft für die Gesellschaft wichtig?',
              options: [
                'Befriedigt Bedürfnisse',
                'Sichert Beschäftigung',
                'Schafft Reichtum',
                'Alle Genannten',
                'Nur produziert Waren',
                'Nur schafft Arbeitsplätze'
              ],
              correctIndex: 3,
              explanation: 'Die Wirtschaft ist wichtig, weil sie Bedürfnisse befriedigt, Beschäftigung sichert und Reichtum schafft.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic16",
          name: 'Sozialer Bereich des Gesellschaftslebens',
          imageAsset: '👨‍👩‍👧‍👦',
          description: 'Soziale Gruppen und Beziehungen',
          explanation: '''Schlüsselbegriffe des Themas:
• Soziale Struktur - Aufbau der Gesellschaft
• Soziale Gruppen - Vereinigungen von Menschen
• Soziale Position - Platz in der Gesellschaft
• Soziale Mobilität - Veränderung der Position
• Berufliche Qualifikation - Niveau der Meisterschaft
• Materielle Lage - Einkommensniveau
Der soziale Bereich regelt die Beziehungen zwischen verschiedenen Gruppen in der Gesellschaft.''',
          questions: [
            Question(
              text: 'Aufbau der Gesellschaft - das ist soziale ______.',
              options: ['Struktur', 'Struktur', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Soziale Struktur - Aufbau der Gesellschaft, System miteinander verbundener sozialer Gruppen.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche sozialen Gruppen kennen Sie?',
              options: [
                'Nach Alter',
                'Nach Beruf',
                'Nach Wohnort',
                'Nach Bildungsniveau',
                'Alle Genannten',
                'Nur nach Einkommen'
              ],
              correctIndex: 4,
              explanation: 'Soziale Gruppen können nach verschiedenen Merkmalen unterschieden werden: Alter, Beruf, Wohnort, Bildung.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Platz des Menschen in der Gesellschaft - das ist seine soziale ______.',
              options: ['Position', 'Position', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Soziale Position - Platz, den der Mensch in der sozialen Struktur der Gesellschaft einnimmt.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist soziale Mobilität?',
              options: [
                'Veränderung der sozialen Position',
                'Stabilität in der Gesellschaft',
                'Soziale Ungleichheit',
                'Gruppensolidarität',
                'Berufliches Wachstum',
                'Materieller Wohlstand'
              ],
              correctIndex: 0,
              explanation: 'Soziale Mobilität - Veränderung des Platzes, den ein Mensch oder eine Gruppe in der sozialen Struktur einnimmt.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Niveau der beruflichen Meisterschaft - das ist ______.',
              options: ['Qualifikation', 'Qualifikation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Qualifikation - Niveau der Vorbereitung auf eine Art von Arbeit, Grad der beruflichen Meisterschaft.',
              answerType: 'text',
            ),
            Question(
              text: 'Was beeinflusst die materielle Lage eines Menschen?',
              options: [
                'Beruf und Qualifikation',
                'Arbeitsbedingungen',
                'Verantwortung',
                'Alle Genannten',
                'Nur Bildung',
                'Nur Berufserfahrung'
              ],
              correctIndex: 3,
              explanation: 'Die materielle Lage wird beeinflusst durch Beruf, Qualifikation, Arbeitsbedingungen und Verantwortungsniveau.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Bewegung auf der sozialen Leiter - das ist soziale ______.',
              options: ['Mobilität', 'Mobilität', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Soziale Mobilität - Bewegung des Menschen oder der Gruppe im sozialen Raum.',
              answerType: 'text',
            ),
            Question(
              text: 'Wer ist Sergej Koroljow?',
              options: [
                'Hervorragender Konstrukteur',
                'Bekannter Arzt',
                'Berühmter Schriftsteller',
                'Großer Künstler',
                'Bekannter Politiker',
                'Berühmter Sportler'
              ],
              correctIndex: 0,
              explanation: 'Sergej Koroljow - herausragender sowjetischer Konstrukteur der Raketen- und Raumfahrttechnik.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Vereinigungen von Menschen in der Gesellschaft - das sind soziale ______.',
              options: ['Gruppen', 'Gruppen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Soziale Gruppen - stabile Vereinigungen von Menschen, die gemeinsame Interessen und Werte haben.',
              answerType: 'text',
            ),
            Question(
              text: 'Was hilft, die soziale Position zu verbessern?',
              options: [
                'Bildung',
                'Berufliches Wachstum',
                'Entwicklung von Fähigkeiten',
                'Alle Genannten',
                'Nur Reichtum',
                'Nur Beziehungen'
              ],
              correctIndex: 3,
              explanation: 'Die soziale Position verbessert sich durch Bildung, berufliches Wachstum und Entwicklung von Fähigkeiten.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Einkommensniveau eines Menschen - das ist seine materielle ______.',
              options: ['Lage', 'Lage', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Materielle Lage - wirtschaftlicher Zustand des Menschen, bestimmt durch das Einkommensniveau.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum gibt es in der Gesellschaft soziale Unterschiede?',
              options: [
                'Verschiedene Fähigkeiten und Anstrengungen',
                'Verschiedene Bildung',
                'Verschiedene Berufe',
                'Alle Genannten',
                'Nur wegen Ungerechtigkeit',
                'Nur wegen Erbschaft'
              ],
              correctIndex: 3,
              explanation: 'Soziale Unterschiede entstehen aufgrund verschiedener Fähigkeiten, Bildung, Berufe und Anstrengungen.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic17",
          name: 'Welt der Politik',
          imageAsset: '⚖️',
          description: 'Politisches System und Macht',
          explanation: '''Schlüsselbegriffe des Themas:
• Politik - Bereich der Gesellschaftssteuerung
• Macht - Fähigkeit, das Verhalten anderer zu beeinflussen
• Staat - politische Organisation der Gesellschaft
• Demokratie - Volksherrschaft
• Föderation - Bundesstaat
• Rechtsstaat - Herrschaft des Gesetzes
Der politische Bereich regelt die Beziehungen der Macht und Steuerung in der Gesellschaft.''',
          questions: [
            Question(
              text: 'Bereich der Gesellschaftssteuerung - das ist ______.',
              options: ['Politik', 'Politik', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Politik - Bereich der Tätigkeit, verbunden mit Beziehungen zwischen sozialen Gruppen, deren Kern die Eroberung und Nutzung der Macht ist.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Merkmale des Staates kennen Sie?',
              options: [
                'Territorium',
                'Bevölkerung',
                'Macht',
                'Gesetze',
                'Alle Genannten',
                'Nur Armee und Polizei'
              ],
              correctIndex: 4,
              explanation: 'Der Staat charakterisiert sich durch Vorhandensein von Territorium, Bevölkerung, Macht, Gesetzen und Souveränität.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Fähigkeit, das Verhalten anderer zu beeinflussen - das ist ______.',
              options: ['Macht', 'Macht', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Macht - Fähigkeit und Möglichkeit, bestimmenden Einfluss auf die Tätigkeit und das Verhalten von Menschen auszuüben.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist Demokratie?',
              options: [
                'Volksherrschaft',
                'Herrschaft eines Menschen',
                'Herrschaft der Reichen',
                'Militärdiktatur',
                'Aristokratie',
                'Monarchie'
              ],
              correctIndex: 0,
              explanation: 'Demokratie - politisches Regime, bei dem das Volk die Quelle der Macht ist.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Bundesstaat - das ist ______.',
              options: ['Föderation', 'Föderation', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Föderation - Form der Staatsordnung, bei der Teile des Staates staatliche Gebilde sind.',
              answerType: 'text',
            ),
            Question(
              text: 'Wer ist Oberhaupt des Staates in Russland?',
              options: [
                'Präsident',
                'Ministerpräsident',
                'Vorsitzender des Parlaments',
                'Bürgermeister von Moskau',
                'Patriarch',
                'Generalstaatsanwalt'
              ],
              correctIndex: 0,
              explanation: 'Präsident der Russischen Föderation - Oberhaupt des Staates.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Staat, wo das Gesetz über der Macht steht - das ist ______ Staat.',
              options: ['Rechtsstaat', 'Rechtsstaat', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Rechtsstaat - Staat, in dem die Herrschaft des Gesetzes gewährleistet ist.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist die Föderale Versammlung?',
              options: [
                'Parlament Russlands',
                'Regierung',
                'Gerichte',
                'Lokale Machtorgane',
                'Präsidialverwaltung',
                'Zentralbank'
              ],
              correctIndex: 0,
              explanation: 'Föderale Versammlung - Parlament der Russischen Föderation, repräsentatives und gesetzgebendes Organ.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Politische Organisation der Gesellschaft - das ist ______.',
              options: ['Staat', 'Staat', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Staat - grundlegende politische Organisation der Gesellschaft, die die Steuerung und den Schutz der öffentlichen Ordnung ausübt.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Gewalten gibt es im Rechtsstaat?',
              options: [
                'Gesetzgebende',
                'Vollziehende',
                'Rechtsprechende',
                'Alle Genannten',
                'Nur gesetzgebende',
                'Nur vollziehende'
              ],
              correctIndex: 3,
              explanation: 'Im Rechtsstaat existiert Gewaltenteilung in gesetzgebende, vollziehende und rechtsprechende Gewalt.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Grundgesetz Russlands - das ist ______.',
              options: ['Verfassung', 'verfassung', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Verfassung der Russischen Föderation - Grundgesetz, das höchste juristische Kraft hat.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum ist Politik für die Gesellschaft wichtig?',
              options: [
                'Regelt gesellschaftliche Beziehungen',
                'Sichert Ordnung',
                'Schützt Rechte der Bürger',
                'Alle Genannten',
                'Nur verteilt Macht',
                'Nur organisiert Wahlen'
              ],
              correctIndex: 3,
              explanation: 'Politik ist wichtig, weil sie gesellschaftliche Beziehungen regelt, Ordnung sichert und Rechte schützt.',
              answerType: 'single_choice',
            ),
          ],
        ),

        Topic(
          id: "social_studies_class6_topic18",
          name: 'Kultur und ihre Errungenschaften',
          imageAsset: '🎨',
          description: 'Materielle und geistige Kultur',
          explanation: '''Schlüsselbegriffe des Themas:
• Kultur - alles vom Menschen Geschaffene
• Materielle Kultur - Gegenstände und Dinge
• Geistige Kultur - Kenntnisse, Kunst, Moral
• Kultivierter Mensch - gebildeter und erzogener Mensch
• Traditionen - kulturelles Erbe
• Religion - Einfluss auf die Kultur
Die Kultur spiegelt die Errungenschaften der Menschheit wider und wird von Generation zu Generation weitergegeben.''',
          questions: [
            Question(
              text: 'Alles vom Menschen Geschaffene - das ist ______.',
              options: ['Kultur', 'Kultur', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Kultur - Gesamtheit der Errungenschaften der Menschheit in produktiver, gesellschaftlicher und geistiger Hinsicht.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Arten von Kultur werden unterschieden?',
              options: [
                'Materielle',
                'Geistige',
                'Beide',
                'Nur materielle',
                'Nur geistige',
                'Weder die eine noch die andere'
              ],
              correctIndex: 2,
              explanation: 'Kultur umfasst sowohl materielle als auch geistige Errungenschaften der Menschheit.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Gegenstände und Dinge, die vom Menschen geschaffen sind - das ist ______ Kultur.',
              options: ['materielle', 'Materielle', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Materielle Kultur - alle Gegenstände, die vom Menschen geschaffen sind: Gebäude, Maschinen, Kleidung usw.',
              answerType: 'text',
            ),
            Question(
              text: 'Was gehört zur geistigen Kultur?',
              options: [
                'Kenntnisse und Wissenschaft',
                'Kunst und Literatur',
                'Moral und Religion',
                'Alle Genannten',
                'Nur Technologien',
                'Nur Wirtschaft'
              ],
              correctIndex: 3,
              explanation: 'Geistige Kultur umfasst Kenntnisse, Kunst, Moral, Religion und andere immaterielle Errungenschaften.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Gebildeter und erzogener Mensch - das ist ______ Mensch.',
              options: ['kultivierter', 'Kultivierter', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Kultivierter Mensch - Mensch, der Bildung, Erziehung und Kenntnis kultureller Werte besitzt.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist kulturelles Erbe?',
              options: [
                'Werte, die von Generation zu Generation weitergegeben werden',
                'Moderne Technologien',
                'Modetrends',
                'Wirtschaftliche Errungenschaften',
                'Politische Ideen',
                'Wissenschaftliche Entdeckungen'
              ],
              correctIndex: 0,
              explanation: 'Kulturelles Erbe - Werte, Traditionen, Bräuche, die von Generation zu Generation weitergegeben werden.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Der Einfluss der Religion auf die Kultur zeigt sich in ______.',
              options: ['Architektur der Tempel', 'Architektur der Tempel', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Religion hatte enormen Einfluss auf die Kultur, besonders in der Architektur der Tempel, Ikonenmalerei, Musik.',
              answerType: 'text',
            ),
            Question(
              text: 'Was sind Traditionen?',
              options: [
                'Bräuche und Rituale, die von Generation zu Generation weitergegeben werden',
                'Neue Strömungen',
                'Moderne Technologien',
                'Wirtschaftliche Reformen',
                'Politische Programme',
                'Wissenschaftliche Theorien'
              ],
              correctIndex: 0,
              explanation: 'Traditionen - Elemente des sozialen und kulturellen Erbes, die von Generation zu Generation weitergegeben werden.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Mensch mit tiefen Kenntnissen - das ist ______ Mensch.',
              options: ['gebildeter', 'Gebildeter', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Gebildeter Mensch - mit tiefen Kenntnissen in verschiedenen Bereichen.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche Kultureinrichtungen kennen Sie?',
              options: [
                'Museen',
                'Theater',
                'Bibliotheken',
                'Alle Genannten',
                'Nur Kinos',
                'Nur Konzertsäle'
              ],
              correctIndex: 3,
              explanation: 'Zu den Kultureinrichtungen gehören Museen, Theater, Bibliotheken, Konzertsäle und andere.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Der Prozess der Einführung in die Kultur erfordert ______.',
              options: ['Anstrengungen', 'Anstrengungen', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Die Einführung in die Kultur erfordert Anstrengungen, Arbeit und ständige Selbstbildung.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum ist es wichtig, das kulturelle Erbe zu bewahren?',
              options: [
                'Für die Verbindung der Generationen',
                'Für das Verständnis der Geschichte',
                'Für die Entwicklung der Kultur',
                'Alle Genannten',
                'Nur für Tourismus',
                'Nur für Bildung'
              ],
              correctIndex: 3,
              explanation: 'Die Bewahrung des kulturellen Erbes ist wichtig für die Verbindung der Generationen, das Verständnis der Geschichte und die Entwicklung der Kultur.',
              answerType: 'single_choice',
            ),
          ],
        ),
        Topic(
          id: "social_studies_class6_topic19",
          name: 'Entwicklung der Gesellschaft',
          imageAsset: '📈',
          description: 'Fortschritt und globale Probleme',
          explanation: '''Schlüsselbegriffe des Themas:
• Fortschritt - Bewegung vorwärts, Verbesserung
• Globale Probleme - die ganze Menschheit betreffend
• Ökologische Krise - Verschlechterung des Zustands der Natur
• Internationale Organisationen - UNO, Rotes Kreuz
• Nachhaltige Entwicklung - Gleichgewicht zwischen Bedürfnissen und Möglichkeiten
• Preis des Fortschritts - negative Folgen der Entwicklung
Die Gesellschaft entwickelt sich ständig und sieht sich neuen Herausforderungen und Problemen gegenüber.''',
          questions: [
            Question(
              text: 'Bewegung der Gesellschaft vorwärts, zum Besseren - das ist ______.',
              options: ['Fortschritt', 'Fortschritt', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Fortschritt - Entwicklungsrichtung vom Niederen zum Höheren, vom weniger Vollkommenen zum vollkommeneren.',
              answerType: 'text',
            ),
            Question(
              text: 'Welche globalen Probleme kennen Sie?',
              options: [
                'Ökologische',
                'Kriegsgefahr',
                'Wirtschaftliche Ungleichheit',
                'Terrorismus',
                'Alle Genannten',
                'Nur ökologische'
              ],
              correctIndex: 4,
              explanation: 'Globale Probleme schließen ökologische, politische, wirtschaftliche und soziale Herausforderungen ein.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Verschlechterung des Zustands der natürlichen Umwelt - das ist ökologische ______.',
              options: ['Krise', 'Krise', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Ökologische Krise - Störung des Gleichgewichts in der Natur als Ergebnis der wirtschaftlichen Tätigkeit des Menschen.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist die UNO?',
              options: [
                'Organisation der Vereinten Nationen',
                'Vereinigung europäischer Länder',
                'Militärbündnis',
                'Wirtschaftliche Organisation',
                'Kulturelle Vereinigung',
                'Wissenschaftliche Gesellschaft'
              ],
              correctIndex: 0,
              explanation: 'UNO - internationale Organisation, geschaffen zur Wahrung des Friedens und der Sicherheit.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Entwicklung, die zukünftigen Generationen nicht bedroht - das ist ______ Entwicklung.',
              options: ['nachhaltige', 'Nachhaltige', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Nachhaltige Entwicklung - Entwicklung, die die Bedürfnisse der Gegenwart befriedigt, ohne die Möglichkeiten zukünftiger Generationen zu bedrohen.',
              answerType: 'text',
            ),
            Question(
              text: 'Was ist "Preis des Fortschritts"?',
              options: [
                'Negative Folgen der Entwicklung',
                'Kosten neuer Technologien',
                'Aufwendungen für Forschungen',
                'Preis der Ausrüstung',
                'Kosten der Bildung',
                'Ausgaben für Kultur'
              ],
              correctIndex: 0,
              explanation: '"Preis des Fortschritts" - negative Folgen der technischen und sozialen Entwicklung.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Internationale Hilfsorganisation - das ist Rotes ______.',
              options: ['Kreuz', 'Kreuz', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Rotes Kreuz - internationale Bewegung der Hilfe für Verwundete, Kranke und Betroffene.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum heißen Probleme global?',
              options: [
                'Betreffen die ganze Menschheit',
                'Erfordern gemeinsame Anstrengungen',
                'Haben planetaren Maßstab',
                'Alle Genannten',
                'Nur weil sie ernst sind',
                'Nur weil sie kompliziert sind'
              ],
              correctIndex: 3,
              explanation: 'Probleme heißen global, weil sie die ganze Menschheit betreffen und gemeinsame Anstrengungen zu ihrer Lösung erfordern.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Negative Folgen der Entwicklung - das ist Preis des ______.',
              options: ['Fortschritts', 'Fortschritts', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Preis des Fortschritts - negative Folgen der technischen und sozialen Entwicklung der Gesellschaft.',
              answerType: 'text',
            ),
            Question(
              text: 'Was sind Freiwillige?',
              options: [
                'Freiwillige Helfer',
                'Berufliche Retter',
                'Staatsbedienstete',
                'Militärangehörige',
                'Politiker',
                'Geschäftsleute'
              ],
              correctIndex: 0,
              explanation: 'Freiwillige - Menschen, die freiwillig und unentgeltlich gesellschaftlich nützliche Tätigkeit ausüben.',
              answerType: 'single_choice',
            ),
            Question(
              text: 'Gleichgewicht zwischen Bedürfnissen und Möglichkeiten der Natur - das ist ______ Entwicklung.',
              options: ['nachhaltige', 'Nachhaltige', '', '', '', ''],
              correctIndex: [0, 1],
              explanation: 'Nachhaltige Entwicklung setzt Gleichgewicht zwischen den Bedürfnissen der Menschheit und den Möglichkeiten der Natur voraus.',
              answerType: 'text',
            ),
            Question(
              text: 'Warum ist es wichtig, globale Probleme zu lösen?',
              options: [
                'Für das Überleben der Menschheit',
                'Für die Verbesserung des Lebens',
                'Für zukünftige Generationen',
                'Alle Genannten',
                'Nur für Wirtschaft',
                'Nur für Politik'
              ],
              correctIndex: 3,
              explanation: 'Die Lösung globaler Probleme ist wichtig für das Überleben der Menschheit, die Verbesserung des Lebens und die Zukunft der Generationen.',
              answerType: 'single_choice',
            ),
          ],
        ),
      ],
    },
  ),
];