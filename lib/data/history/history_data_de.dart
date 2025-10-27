import '../../../models/topic.dart';
import '../../../models/question.dart';
import '../../../models/subject.dart';

final List<Subject> historySubjects1 = [];
final List<Subject> historySubjects2 = [];
final List<Subject> historySubjects3 = [];
final List<Subject> historySubjects4 = [];

final List<Subject> historySubjects5 = [
  Subject(
    name: 'Geschichte',
    topicsByGrade: {
      5: [
        // EINFÜHRUNG
        Topic(
          id: "introduction_history",
          name: 'Einführung. Was Geschichte studiert',
          imageAsset: '📜',
          description: 'Wissenschaft Geschichte, historische Quellen, Zeitrechnung in der Geschichte',
          explanation: 'Geschichte studiert die Vergangenheit der Menschheit anhand verschiedener Quellen',
          questions: [
            Question(
              text: 'Was studiert die Wissenschaft Geschichte?',
              options: [
                'Natur und Phänomene',
                'Vergangene Ereignisse und ihre Ursachen',
                'Mathematische Gesetze',
                'Chemische Elemente',
                'Zukünftige Ereignisse'
              ],
              correctIndex: 1,
              explanation: 'Geschichte studiert vergangene Ereignisse, ihre Ursachen und Folgen',
            ),
            Question(
              text: 'Welche Gruppen historischer Quellen gibt es?',
              options: [
                'Nur schriftliche',
                'Materielle, schriftliche und mündliche',
                'Nur archäologische',
                'Nur museale',
                'Nur archivische'
              ],
              correctIndex: 1,
              explanation: 'Historische Quellen werden in materielle, schriftliche und mündliche unterteilt',
            ),
            Question(
              text: 'In welchem Jahr wurde Rom gegründet?',
              options: [
                '1147 v. Chr.',
                '753 v. Chr.',
                '1961 n. Chr.',
                '1492 n. Chr.',
                '476 n. Chr.'
              ],
              correctIndex: 1,
              explanation: 'Rom wurde 753 v. Chr. gegründet',
            ),
            Question(
              text: 'Was ist Archäologie?',
              options: [
                'Wissenschaft von den Sternen',
                'Wissenschaft des Altertums, die materielle Quellen studiert',
                'Wissenschaft von der Sprache',
                'Wissenschaft von den Pflanzen',
                'Wissenschaft von den Tieren'
              ],
              correctIndex: 1,
              explanation: 'Archäologie ist die "Wissenschaft der Schaufel", die Geschichte anhand materieller Quellen studiert',
            ),
            Question(
              text: 'Wie bestimmt man das Jahrhundert nach dem Jahr?',
              options: [
                'Subtrahiere eins von den letzten beiden Ziffern',
                'Addiere eins zu den ersten beiden Ziffern',
                'Teile das Jahr durch 100',
                'Multipliziere das Jahr mit 100',
                'Schau auf den Kalender'
              ],
              correctIndex: 1,
              explanation: 'Um das Jahrhundert zu bestimmen, addiert man eins zu den ersten beiden Ziffern des Jahres',
            ),
            Question(
              text: 'Was bedeutet die Abkürzung "v. Chr."?',
              options: [
                'Vor Beginn der Ära',
                'Vor unserer Zeitrechnung',
                'Vor der neuen Epoche',
                'Vor Beginn des Jahrhunderts',
                'Vor der gegenwärtigen Zeit'
              ],
              correctIndex: 1,
              explanation: '"v. Chr." bedeutet "vor unserer Zeitrechnung" - Ereignisse vor der Geburt Christi',
            ),
            Question(
              text: 'Wo werden alte Handschriften und Dokumente aufbewahrt?',
              options: [
                'In Museen',
                'In Archiven',
                'In Bibliotheken',
                'In Tempeln',
                'In Schulen'
              ],
              correctIndex: 1,
              explanation: 'Alte Handschriften und Dokumente werden in Archiven aufbewahrt',
            ),
            Question(
              text: 'Wer war Herodot?',
              options: [
                'Ein altrömischer Kaiser',
                'Ein altgriechischer Historiker',
                'Ein ägyptischer Pharao',
                'Ein babylonischer König',
                'Ein griechischer Philosoph'
              ],
              correctIndex: 1,
              explanation: 'Herodot war ein altgriechischer Historiker, der "Vater der Geschichte" genannt wurde',
            ),
            Question(
              text: 'Was war ein Museum im antiken Verständnis?',
              options: [
                'Tempel der Musen',
                'Palast des Herrschers',
                'Bibliothek',
                'Schule',
                'Theater'
              ],
              correctIndex: 0,
              explanation: 'Das Wort "Museum" übersetzt sich aus dem Griechischen als "Tempel der Musen"',
            ),
            Question(
              text: 'Welche Zeitzählmethode war für die alten Menschen die einfachste?',
              options: [
                'Wechsel von Tag und Nacht',
                'Bewegung der Planeten',
                'Flussüberflutungen',
                'Wechsel der Jahreszeiten',
                'Mondzyklen'
              ],
              correctIndex: 0,
              explanation: 'Die einfachste Zeitzählmethode war der Wechsel von Tag und Nacht',
            ),
          ],
        ),

        // KAPITEL I: URGESELLSCHAFT
        Topic(
          id: "primitive_society_early_humans",
          name: 'Urgesellschaft. Früheste Menschen',
          imageAsset: '🦍',
          description: 'Ursprung des Menschen, Entwicklungsstadien, Werkzeuge',
          explanation: 'Der Mensch durchlief einen langen Evolutionsweg vom Australopithecus zum Homo sapiens',
          questions: [
            Question(
              text: 'Wer entdeckte die Überreste des Pithecanthropus auf der Insel Java?',
              options: [
                'Charles Darwin',
                'Louis Leakey',
                'Eugène Dubois',
                'Heinrich Schliemann',
                'Jean-François Champollion'
              ],
              correctIndex: 2,
              explanation: 'Eugène Dubois entdeckte 1891 die Überreste des Pithecanthropus auf der Insel Java',
            ),
            Question(
              text: 'Welcher Zeitraum der menschlichen Geschichte wird als Urgesellschaft bezeichnet?',
              options: [
                'Die Zeit der Schriftlichkeit',
                'Die Zeit der Staaten',
                'Die früheste Zeit ohne Schriftlichkeit und Staat',
                'Das Mittelalter',
                'Die Neuzeit'
              ],
              correctIndex: 2,
              explanation: 'Die Urgesellschaft ist die früheste Zeit ohne Schriftlichkeit, Staat und soziale Ungleichheit',
            ),
            Question(
              text: 'Welche Steinzeiten werden in der Urgeschichte unterschieden?',
              options: [
                'Bronze- und Eisenzeit',
                'Altsteinzeit, Mittelsteinzeit, Jungsteinzeit',
                'Alte und neue',
                'Frühe und späte',
                'Stein- und Metallzeit'
              ],
              correctIndex: 1,
              explanation: 'Die Steinzeit wird in Altsteinzeit (Paläolithikum), Mittelsteinzeit (Mesolithikum) und Jungsteinzeit (Neolithikum) unterteilt',
            ),
            Question(
              text: 'Wo wurden die ältesten Überreste eines menschenähnlichen Wesens entdeckt?',
              options: [
                'In Ostafrika',
                'In Südafrika',
                'In Südostasien',
                'In Europa',
                'In China'
              ],
              correctIndex: 1,
              explanation: 'Die ältesten Überreste des Australopithecus wurden 1924 in Südafrika entdeckt',
            ),
            Question(
              text: 'Wer war der "Homo habilis"?',
              options: [
                'Der erste, der Feuer verwendete',
                'Der erste, der Werkzeuge herstellte',
                'Der erste, der Landwirtschaft betrieb',
                'Der erste, der Behausungen baute',
                'Der erste, der Tote bestattete'
              ],
              correctIndex: 1,
              explanation: '"Homo habilis" konnte Steine und Stöcke als einfache Werkzeuge verwenden',
            ),
            Question(
              text: 'Wann erschien der "Homo sapiens"?',
              options: [
                'Vor 2,5 Millionen Jahren',
                'Vor 1 Million Jahren',
                'Vor 300-200 Tausend Jahren',
                'Vor 40 Tausend Jahren',
                'Vor 10 Tausend Jahren'
              ],
              correctIndex: 3,
              explanation: 'Der Homo sapiens (Cro-Magnon-Mensch) erschien vor etwa 40 Tausend Jahren',
            ),
            Question(
              text: 'Was ist Evolution?',
              options: [
                'Plötzliche Veränderung',
                'Allmähliche Entwicklung',
                'Religiöse Lehre',
                'Wissenschaftliches Experiment',
                'Mythische Vorstellung'
              ],
              correctIndex: 1,
              explanation: 'Evolution ist die Theorie der allmählichen Entwicklung lebender Wesen, formuliert von Darwin',
            ),
            Question(
              text: 'Wer formulierte die Evolutionstheorie?',
              options: [
                'Eugène Dubois',
                'Charles Darwin',
                'Louis Leakey',
                'Herodot',
                'Aristoteles'
              ],
              correctIndex: 1,
              explanation: 'Charles Darwin formulierte erstmals die Evolutionstheorie durch natürliche Selektion',
            ),
            Question(
              text: 'Welche Werkzeuge verwendete der "Homo habilis"?',
              options: [
                'Zugespitzte Kieselsteine',
                'Faustkeile',
                'Komplexe zusammengesetzte Werkzeuge',
                'Metallische Werkzeuge',
                'Bogen und Pfeile'
              ],
              correctIndex: 0,
              explanation: '"Homo habilis" verwendete zugespitzte Kieselsteine und behauene Steine',
            ),
            Question(
              text: 'Was bedeutet das Wort "Pithecanthropus"?',
              options: [
                'Alter Mensch',
                'Affenmensch',
                'Geschickter Mensch',
                'Aufrecht gehender Mensch',
                'Vernünftiger Mensch'
              ],
              correctIndex: 1,
              explanation: 'Pithecanthropus bedeutet übersetzt "Affenmensch"',
            ),
          ],
        ),

        Topic(
          id: "primitive_hunters_gatherers",
          name: 'Urzeitliche Jäger und Sammler',
          imageAsset: '🏹',
          description: 'Tätigkeiten des Urmenschen, Feuernutzung, Werkzeuge',
          explanation: 'Urmenschen betrieben Jagd und Sammeltätigkeit, lernten Feuer zu nutzen',
          questions: [
            Question(
              text: 'Welche Bedeutung hatte das Feuer im Leben des Urmenschen?',
              options: [
                'Nur zur Beleuchtung',
                'Nur zur Zubereitung von Speisen',
                'Zum Heizen, Zubereiten von Speisen, Vertreiben von Tieren',
                'Nur zur Jagd',
                'Nur für Rituale'
              ],
              correctIndex: 2,
              explanation: 'Feuer wurde zum Heizen, Zubereiten von Speisen, Beleuchten und Vertreiben wilder Tiere verwendet',
            ),
            Question(
              text: 'Was ist eine Gemeinschaftsgruppe?',
              options: [
                'Eine Gruppe von Freunden',
                'Kollektiv blutsverwandter Verwandter',
                'Nachbarschaftsvereinigung',
                'Stammesorganisation',
                'Staatliches Gebilde'
              ],
              correctIndex: 1,
              explanation: 'Gemeinschaftsgruppe - Kollektiv blutsverwandter Verwandter, die gemeinsame Wirtschaft führen',
            ),
            Question(
              text: 'Welche Hauptrasse bildeten sich beim Homo sapiens?',
              options: [
                'Afrikanische und asiatische',
                'Nördliche und südliche',
                'Europide, mongolide, negride',
                'Östliche und westliche',
                'Berg- und Flachland'
              ],
              correctIndex: 2,
              explanation: 'Es bildeten sich drei Hauptrasse: Europide, Mongolide und Negride',
            ),
            Question(
              text: 'Warum war die Jagd eine kollektive Tätigkeit?',
              options: [
                'Damit es lustiger war',
                'Um sich vor Raubtieren zu schützen',
                'Für die Jagd auf große Tiere waren gemeinsame Anstrengungen nötig',
                'Aus religiösen Gründen',
                'Wegen Mangels an Werkzeugen'
              ],
              correctIndex: 2,
              explanation: 'Auf große Tiere konnte nur kollektiv gejagt werden, indem Fallen und Treibjagden eingerichtet wurden',
            ),
            Question(
              text: 'Wie entzündeten Urmenschen Feuer?',
              options: [
                'Nur durch Blitze',
                'Durch Reibung oder Funken schlagen',
                'Von der Sonne',
                'Aus Vulkanen',
                'Kauften bei Nachbarn'
              ],
              correctIndex: 1,
              explanation: 'Später lernte der Mensch Feuer durch Reibung oder Funken schlagen aus Stein zu entzünden',
            ),
            Question(
              text: 'Welche Tiere erschienen in der Eiszeit?',
              options: [
                'Dinosaurier',
                'Mammuts und Wollnashörner',
                'Elefanten und Giraffen',
                'Affen',
                'Krokodile'
              ],
              correctIndex: 1,
              explanation: 'In der Eiszeit erschienen Mammuts, Wollnashörner, Bisons, Hirsche',
            ),
            Question(
              text: 'Wer führte den Stamm an?',
              options: [
                'Der stärkste Krieger',
                'Rat der Ältesten',
                'Priester',
                'Häuptling',
                'Alle erwachsenen Männer'
              ],
              correctIndex: 1,
              explanation: 'Der Stamm wurde von einem Rat angeführt, dem die Ältesten der Gemeinschaftsgruppen angehörten',
            ),
            Question(
              text: 'Was ist Sammeltätigkeit?',
              options: [
                'Anbau von Pflanzen',
                'Sammeln fertiger Gaben der Natur',
                'Jagd auf kleine Tiere',
                'Fischerei',
                'Zähmung von Tieren'
              ],
              correctIndex: 1,
              explanation: 'Sammeltätigkeit - Sammeln von Beeren, Früchten, Pilzen, Nüssen, Wurzeln',
            ),
            Question(
              text: 'Welche Waffen verwendeten Urmenschen zur Jagd?',
              options: [
                'Bogen und Pfeile',
                'Keulen, Speere, Lanzen',
                'Metallische Schwerter',
                'Feuerwaffen',
                'Kampftiere'
              ],
              correctIndex: 1,
              explanation: 'Urmenschen verwendeten Keulen, Speere, Lanzen aus Stein und Holz',
            ),
            Question(
              text: 'Wie stellten Urmenschen Kleidung her?',
              options: [
                'Webten Stoff',
                'Nähten aus Tierhäuten',
                'Flochten aus Gras',
                'Schnitzten aus Rinde',
                'Brannten Ton'
              ],
              correctIndex: 1,
              explanation: 'Kleidung wurde aus Tierhäuten getragen, die mit Knochennadeln bearbeitet wurden',
            ),
          ],
        ),

        Topic(
          id: "primitive_beliefs_art",
          name: 'Glauben und Kunst der Urmenschen',
          imageAsset: '🎨',
          description: 'Wissen, Glauben, Magie, urzeitliche Kunst',
          explanation: 'Urmenschen besaßen Wissen über die Natur, glaubten an Geister und schufen Kunstwerke',
          questions: [
            Question(
              text: 'Was ist Magie in der Urgesellschaft?',
              options: [
                'Wissenschaftliches Wissen',
                'Glaube an die Fähigkeit, mit Geistern zu kommunizieren',
                'Künstlerisches Schaffen',
                'Landwirtschaftliche Fähigkeiten',
                'Bautechnologien'
              ],
              correctIndex: 1,
              explanation: 'Magie - Glaube an die Fähigkeit des Menschen, durch Zaubersprüche und Rituale mit Geistern zu kommunizieren',
            ),
            Question(
              text: 'Wo wurden die ersten Zeichnungen des Urmenschen entdeckt?',
              options: [
                'In Ägypten',
                'In der Höhle von Altamira in Spanien',
                'In Mesopotamien',
                'In China',
                'In Indien'
              ],
              correctIndex: 1,
              explanation: 'Die ersten Zeichnungen entdeckte Sautuola in der Höhle von Altamira in Spanien',
            ),
            Question(
              text: 'Welche Motive sind in der Höhlenmalerei dargestellt?',
              options: [
                'Porträts von Menschen',
                'Abstrakte Muster',
                'Tiere und Jagdszenen',
                'Gebirgslandschaften',
                'Himmelskörper'
              ],
              correctIndex: 2,
              explanation: 'In der Höhlenmalerei sind Tiere (Hirsche, Stiere, Bären) und Jagdszenen dargestellt',
            ),
            Question(
              text: 'Woran glaubten Urmenschen nach dem Tod eines Menschen?',
              options: [
                'Der Mensch verschwindet für immer',
                'Die Seele wandert in die jenseitige Welt',
                'Der Mensch verwandelt sich in ein Tier',
                'Die Seele wird in einem neuen Körper wiedergeboren',
                'An nichts glaubten sie'
              ],
              correctIndex: 1,
              explanation: 'Urmenschen glaubten, dass nach dem Tod die Seele in die jenseitige Welt wandert',
            ),
            Question(
              text: 'Was ist Stonehenge?',
              options: [
                'Urzeitliche Behausung',
                'Ort für Jagdrituale',
                'Alte Steinkonstruktion',
                'Höhle mit Zeichnungen',
                'Siedlung des Urmenschen'
              ],
              correctIndex: 2,
              explanation: 'Stonehenge - Konstruktion aus riesigen Steinen, möglicherweise ein altes Observatorium',
            ),
            Question(
              text: 'Über welches Wissen verfügte der Urmensch?',
              options: [
                'Nur wie man Nahrung beschafft',
                'Er unterschied Tierspuren, kannte Eigenschaften von Pflanzen',
                'Konnte schreiben und rechnen',
                'War mit Astronomie vertraut',
                'Kenntnisse über Medizin'
              ],
              correctIndex: 1,
              explanation: 'Urmenschen unterschieden Tierspuren, kannten Eigenschaften von Pflanzen, konnten Wunden behandeln',
            ),
            Question(
              text: 'Wer ist ein Schamane?',
              options: [
                'Stammeshäuptling',
                'Bester Jäger',
                'Mensch mit besonderen Fähigkeiten zur Kommunikation mit Geistern',
                'Ältester der Gemeinschaftsgruppe',
                'Hüter des Feuers'
              ],
              correctIndex: 2,
              explanation: 'Schamane - Mensch, der mit besonderen Fähigkeiten zur Kommunikation mit Geistern ausgestattet ist',
            ),
            Question(
              text: 'Was legte man ins Grab neben den Verstorbenen?',
              options: [
                'Nur Blumen',
                'Werkzeuge, Waffen, Nahrungsmittel',
                'Schmuck',
                'Landkarten',
                'Nichts wurde gelegt'
              ],
              correctIndex: 1,
              explanation: 'Neben den Verstorbenen legte man Werkzeuge, Waffen, Nahrungsmittel für das jenseitige Leben',
            ),
            Question(
              text: 'Welche Farben verwendeten alte Künstler?',
              options: [
                'Ölfarben',
                'Aquarell',
                'Holzkohle, Kreide, Tierblut',
                'Pflanzensäfte',
                'Mineralpulver'
              ],
              correctIndex: 2,
              explanation: 'Alte Künstler verwendeten Holzkohle, Kreide, Fett, Eier und Tierblut',
            ),
            Question(
              text: 'Zu welchem Zweck führte man magische Rituale durch?',
              options: [
                'Zur Unterhaltung',
                'Erfolgreiche Jagd zu gewährleisten',
                'Zur Ausbildung der Jugend',
                'Für Handel',
                'Für Bauarbeiten'
              ],
              correctIndex: 1,
              explanation: 'Magische Rituale wurden durchgeführt, um erfolgreiche Jagd und andere wichtige Angelegenheiten zu gewährleisten',
            ),
          ],
        ),

        Topic(
          id: "agriculture_cattle_breeding_craft",
          name: 'Entstehung von Ackerbau, Viehzucht und Handwerk',
          imageAsset: '🌾',
          description: 'Übergang zur produzierenden Wirtschaft, Jungsteinzeit, Metallzeitalter',
          explanation: 'Im Neolithikum ging der Mensch von Jagd und Sammeltätigkeit zu Ackerbau und Viehzucht über',
          questions: [
            Question(
              text: 'Wann begann die Jungsteinzeit?',
              options: [
                'Vor 2,5 Millionen Jahren',
                'Vor 100 Tausend Jahren',
                'Vor 10 Tausend Jahren',
                'Vor 5 Tausend Jahren',
                'Vor 1 Tausend Jahren'
              ],
              correctIndex: 2,
              explanation: 'Die Jungsteinzeit (Neolithikum) begann vor etwa 10 Tausend Jahren',
            ),
            Question(
              text: 'Was ist eine Nachbarschaftsgemeinschaft?',
              options: [
                'Kollektiv von Verwandten',
                'Vereinigung von Nachbarsfamilien mit separaten Haushalten',
                'Stammesorganisation',
                'Städtische Siedlung',
                'Militärbündnis'
              ],
              correctIndex: 1,
              explanation: 'Nachbarschaftsgemeinschaft - Kollektiv von Nachbarsfamilien, die separate Haushalte auf ihren Grundstücken führen',
            ),
            Question(
              text: 'Welche Metalle begann der Mensch als erste zu verwenden?',
              options: [
                'Eisen',
                'Bronze',
                'Kupfer',
                'Gold',
                'Silber'
              ],
              correctIndex: 2,
              explanation: 'Das erste Metall, das der Mensch zu verwenden begann, war Kupfer',
            ),
            Question(
              text: 'Wie unterschied sich Ackerbau von Sammeltätigkeit?',
              options: [
                'Gar nicht unterschied',
                'Ackerbau ist Produktion von Produkten, Sammeltätigkeit ist Aneignung',
                'Sammeltätigkeit ist effektiver',
                'Ackerbau ist einfacher',
                'Sammeltätigkeit erforderte mehr Wissen'
              ],
              correctIndex: 1,
              explanation: 'Ackerbau - Produktion von Produkten, Sammeltätigkeit - Aneignung fertiger Gaben der Natur',
            ),
            Question(
              text: 'Welche Erfindung verbesserte die Bodenbearbeitung?',
              options: [
                'Sichel',
                'Hacke',
                'Pflug',
                'Axt',
                'Messer'
              ],
              correctIndex: 2,
              explanation: 'Der hölzerne Pflug ermöglichte die Bearbeitung harten Bodens und begann mit dem Tiefenackerbau',
            ),
            Question(
              text: 'Was ist Keramik?',
              options: [
                'Produkte aus Stein',
                'Produkte aus Ton',
                'Produkte aus Holz',
                'Produkte aus Knochen',
                'Produkte aus Metall'
              ],
              correctIndex: 1,
              explanation: 'Keramik - Produkte aus gebranntem Ton, vor allem Gefäße',
            ),
            Question(
              text: 'Welche neuen Handwerke entstanden im Neolithikum?',
              options: [
                'Nur Töpferei',
                'Töpferei, Weberei, Spinnen',
                'Nur Weberei',
                'Nur Metallverarbeitung',
                'Bauwesen'
              ],
              correctIndex: 1,
              explanation: 'Im Neolithikum entstanden Töpferei, Spinnen und Weberei',
            ),
            Question(
              text: 'Was ist "Ungleichheit" in der Urgesellschaft?',
              options: [
                'Gleichheit aller Menschen',
                'Auftreten von reichen und armen Familien',
                'Verschiedene Pflichten von Männern und Frauen',
                'Altersunterschiede',
                'Verschiedene Fähigkeiten der Menschen'
              ],
              correctIndex: 1,
              explanation: 'Ungleichheit - Auftreten von Vermögensschichtung in Reiche und Arme',
            ),
            Question(
              text: 'Welches Tier wurde der erste Helfer des Menschen bei der Jagd?',
              options: [
                'Katze',
                'Pferd',
                'Hund',
                'Kuh',
                'Schaf'
              ],
              correctIndex: 2,
              explanation: 'Der Hund wurde der erste Helfer bei der Jagd und treuer Freund des Menschen',
            ),
            Question(
              text: 'Was ist "Adel" in der Urgesellschaft?',
              options: [
                'Alle gebildeten Menschen',
                'Älteste, Häuptlinge, Zauberer, die Reichtum konzentrierten',
                'Beste Jäger',
                'Handwerker',
                'Priester'
              ],
              correctIndex: 1,
              explanation: 'Adel - Älteste, Häuptlinge, Zauberer, die die besten Ländereien und Herden besaßen',
            ),
          ],
        ),

        // KAPITEL II: ALTES ORIENT
        Topic(
          id: "ancient_egypt_formation",
          name: 'Altes Ägypten. Entstehung des Staates',
          imageAsset: '🏺',
          description: 'Naturbedingungen Ägyptens, Vereinigung von Ober- und Unterägypten',
          explanation: 'Das alte Ägypten entstand im Niltal, vereinigte sich unter Pharao Menes',
          questions: [
            Question(
              text: 'Welche Bedeutung hatten die Nilüberschwemmungen für Ägypten?',
              options: [
                'Brachten Zerstörung',
                'Düngten das Land mit fruchtbarem Schlamm',
                'Behinderten den Ackerbau',
                'Schufen Sümpfe',
                'Schwemmten den Boden aus'
              ],
              correctIndex: 1,
              explanation: 'Nilüberschwemmungen brachten fruchtbaren Schlamm, der die Felder düngte',
            ),
            Question(
              text: 'Wer vereinigte Ober- und Unterägypten?',
              options: [
                'Ramses II.',
                'Thutmosis III.',
                'Echnaton',
                'Menes',
                'Cheops'
              ],
              correctIndex: 3,
              explanation: 'Pharao Menes vereinigte Ober- und Unterägypten um 3000 v. Chr.',
            ),
            Question(
              text: 'Was sind Gaue im alten Ägypten?',
              options: [
                'Tempel',
                'Gemeinschaftliche Vereinigungen-Gebiete',
                'Pyramiden',
                'Hieroglyphen',
                'Kanäle'
              ],
              correctIndex: 1,
              explanation: 'Gaue - erste gemeinschaftliche Vereinigungen im Niltal',
            ),
            Question(
              text: 'Was ist ein Schaduf?',
              options: [
                'Boot',
                'Vorrichtung zum Heben von Wasser',
                'Fischernetz',
                'Landwirtschaftliches Gerät',
                'Kleidungsstück'
              ],
              correctIndex: 1,
              explanation: 'Schaduf - Vorrichtung zum Heben von Wasser auf obere Felder',
            ),
            Question(
              text: 'Woraus stellten Ägypter Material zum Schreiben her?',
              options: [
                'Aus Holz',
                'Aus Papyrus',
                'Aus Lehm',
                'Aus Seide',
                'Aus Leder'
              ],
              correctIndex: 1,
              explanation: 'Ägypter stellten Papyrus aus Schilfstängeln her',
            ),
            Question(
              text: 'Welche Kopfbedeckung symbolisierte die Herrschaft über ganz Ägypten?',
              options: [
                'Nur die weiße Krone',
                'Nur die rote Krone',
                'Doppelte weiß-rote Krone',
                'Goldener Helm',
                'Binde mit Uräus'
              ],
              correctIndex: 2,
              explanation: 'Die doppelte weiß-rote Krone symbolisierte die Herrschaft über Ober- und Unterägypten',
            ),
            Question(
              text: 'Wo lag Unterägypten?',
              options: [
                'Im Oberlauf des Nils',
                'Im Nildelta',
                'Im Niltal',
                'In Oasen',
                'In den Bergen'
              ],
              correctIndex: 1,
              explanation: 'Unterägypten lag im Nildelta, Oberägypten im Tal',
            ),
            Question(
              text: 'Was ist eine Oase?',
              options: [
                'Wüste',
                'Ort in der Wüste mit Wasserquelle',
                'Bergregion',
                'Flusstal',
                'Meeresbucht'
              ],
              correctIndex: 1,
              explanation: 'Oase - Ort in der Wüste, wo es Wasserquellen und Vegetation gibt',
            ),
            Question(
              text: 'Wer war Herodot und welche Beziehung hat er zu Ägypten?',
              options: [
                'Ägyptischer Pharao',
                'Griechischer Historiker, der Ägypten beschrieb',
                'Römischer Feldherr',
                'Ägyptischer Priester',
                'Babylonischer König'
              ],
              correctIndex: 1,
              explanation: 'Herodot - altgriechischer Historiker, besuchte Ägypten und beschrieb dessen Bräuche',
            ),
            Question(
              text: 'Was ist das Nildelta?',
              options: [
                'Bergregion',
                'Mündungsgebiet des Flusses ins Meer mit verzweigtem Flussbett',
                'Wüstengebiet',
                'Hauptstadt Ägyptens',
                'Tempelkomplex'
              ],
              correctIndex: 1,
              explanation: 'Delta - Mündungsgebiet des Nils ins Mittelmeer, wo sich das Flussbett in Arme verzweigt',
            ),
          ],
        ),


      ],
    },
  ),
];

final List<Subject> historySubjects6 = [];
final List<Subject> historySubjects7 = [];
final List<Subject> historySubjects8 = [];
final List<Subject> historySubjects9 = [];
final List<Subject> historySubjects10 = [];
final List<Subject> historySubjects11 = [];