import '../../../models/topic.dart';
import '../../../models/question.dart';
import '../../../models/subject.dart';

final List<Subject> historySubjects1 = [];
final List<Subject> historySubjects2 = [];
final List<Subject> historySubjects3 = [];
final List<Subject> historySubjects4 = [];

final List<Subject> historySubjects5 = [
  Subject(
    name: 'History',
    topicsByGrade: {
      5: [
        // INTRODUCTION
        Topic(
          id: "introduction_history",
          name: 'Introduction. What History Studies',
          imageAsset: '📜',
          description: 'Science of history, historical sources, counting years in history',
          explanation: 'History studies the past of humanity using various sources',
          questions: [
            Question(
              text: 'What does the science of history study?',
              options: [
                'Nature and phenomena',
                'Past events and their causes',
                'Mathematical laws',
                'Chemical elements',
                'Future events'
              ],
              correctIndex: 1,
              explanation: 'History studies past events, their causes and consequences',
            ),
            Question(
              text: 'What groups of historical sources exist?',
              options: [
                'Only written ones',
                'Material, written and oral',
                'Only archaeological',
                'Only museum',
                'Only archival'
              ],
              correctIndex: 1,
              explanation: 'Historical sources are divided into material, written and oral',
            ),
            Question(
              text: 'In what year was Rome founded?',
              options: [
                '1147 BC',
                '753 BC',
                '1961 AD',
                '1492 AD',
                '476 AD'
              ],
              correctIndex: 1,
              explanation: 'Rome was founded in 753 BC',
            ),
            Question(
              text: 'What is archaeology?',
              options: [
                'Science of stars',
                'Science of antiquity studying material sources',
                'Science of language',
                'Science of plants',
                'Science of animals'
              ],
              correctIndex: 1,
              explanation: 'Archaeology is the "science of the spade", studying history through material sources',
            ),
            Question(
              text: 'How is the century determined from the year?',
              options: [
                'Subtract one from the last two digits',
                'Add one to the first two digits',
                'Divide the year by 100',
                'Multiply the year by 100',
                'Look at the calendar'
              ],
              correctIndex: 1,
              explanation: 'To determine the century, add one to the first two digits of the year',
            ),
            Question(
              text: 'What does the abbreviation "BC" mean?',
              options: [
                'Before the beginning of the era',
                'Before Christ',
                'Before the new epoch',
                'Before the beginning of the century',
                'Before the present time'
              ],
              correctIndex: 1,
              explanation: '"BC" means "Before Christ" - events before the birth of Christ',
            ),
            Question(
              text: 'Where are ancient manuscripts and documents stored?',
              options: [
                'In museums',
                'In archives',
                'In libraries',
                'In temples',
                'In schools'
              ],
              correctIndex: 1,
              explanation: 'Ancient manuscripts and documents are stored in archives',
            ),
            Question(
              text: 'Who was Herodotus?',
              options: [
                'Ancient Roman emperor',
                'Ancient Greek historian',
                'Egyptian pharaoh',
                'Babylonian king',
                'Greek philosopher'
              ],
              correctIndex: 1,
              explanation: 'Herodotus was an ancient Greek historian, called the "father of history"',
            ),
            Question(
              text: 'What was a museum in ancient understanding?',
              options: [
                'Temple of the Muses',
                'Ruler\'s palace',
                'Library',
                'School',
                'Theater'
              ],
              correctIndex: 0,
              explanation: 'The word "museum" translates from Greek as "temple of the Muses"',
            ),
            Question(
              text: 'What method of timekeeping was simplest for ancient people?',
              options: [
                'Change of day and night',
                'Movement of planets',
                'River floods',
                'Change of seasons',
                'Lunar cycles'
              ],
              correctIndex: 0,
              explanation: 'The simplest method of timekeeping was the change of day and night',
            ),
          ],
        ),

        // CHAPTER I: PRIMITIVE SOCIETY
        Topic(
          id: "primitive_society_early_humans",
          name: 'Primitive Society. Earliest Humans',
          imageAsset: '🦍',
          description: 'Human origins, stages of development, tools',
          explanation: 'Humans went through a long evolutionary path from Australopithecus to Homo sapiens',
          questions: [
            Question(
              text: 'Who discovered the remains of Pithecanthropus on Java island?',
              options: [
                'Charles Darwin',
                'Louis Leakey',
                'Eugène Dubois',
                'Heinrich Schliemann',
                'Jean-François Champollion'
              ],
              correctIndex: 2,
              explanation: 'Eugène Dubois discovered the remains of Pithecanthropus on Java island in 1891',
            ),
            Question(
              text: 'Which period of human history is called primitive society?',
              options: [
                'The period of writing',
                'The period of states',
                'The earliest period without writing and state',
                'The Middle Ages',
                'Modern times'
              ],
              correctIndex: 2,
              explanation: 'Primitive society is the earliest period without writing, state and social inequality',
            ),
            Question(
              text: 'What Stone Ages are distinguished in primitive history?',
              options: [
                'Bronze and Iron',
                'Paleolithic, Mesolithic, Neolithic',
                'Ancient and new',
                'Early and late',
                'Stone and metal'
              ],
              correctIndex: 1,
              explanation: 'The Stone Age is divided into Paleolithic (ancient), Mesolithic (middle) and Neolithic (new)',
            ),
            Question(
              text: 'Where were the most ancient remains of human-like creatures discovered?',
              options: [
                'In East Africa',
                'In South Africa',
                'In Southeast Asia',
                'In Europe',
                'In China'
              ],
              correctIndex: 1,
              explanation: 'The most ancient remains of Australopithecus were discovered in South Africa in 1924',
            ),
            Question(
              text: 'Who was "Homo habilis"?',
              options: [
                'The first to use fire',
                'The first to make tools',
                'The first to practice agriculture',
                'The first to build dwellings',
                'The first to bury the dead'
              ],
              correctIndex: 1,
              explanation: '"Homo habilis" knew how to use stones and sticks as simple tools',
            ),
            Question(
              text: 'When did "Homo sapiens" appear?',
              options: [
                '2.5 million years ago',
                '1 million years ago',
                '300-200 thousand years ago',
                '40 thousand years ago',
                '10 thousand years ago'
              ],
              correctIndex: 3,
              explanation: 'Homo sapiens (Cro-Magnon) appeared about 40 thousand years ago',
            ),
            Question(
              text: 'What is evolution?',
              options: [
                'Sudden change',
                'Gradual development',
                'Religious teaching',
                'Scientific experiment',
                'Mythical representation'
              ],
              correctIndex: 1,
              explanation: 'Evolution is the theory of gradual development of living beings, formulated by Darwin',
            ),
            Question(
              text: 'Who formulated the theory of evolution?',
              options: [
                'Eugène Dubois',
                'Charles Darwin',
                'Louis Leakey',
                'Herodotus',
                'Aristotle'
              ],
              correctIndex: 1,
              explanation: 'Charles Darwin first formulated the theory of evolution through natural selection',
            ),
            Question(
              text: 'What tools did "Homo habilis" use?',
              options: [
                'Sharpened pebbles',
                'Hand axes',
                'Complex composite tools',
                'Metal instruments',
                'Bow and arrows'
              ],
              correctIndex: 0,
              explanation: '"Homo habilis" used sharpened pebbles and chipped stones',
            ),
            Question(
              text: 'What does the word "Pithecanthropus" mean?',
              options: [
                'Ancient human',
                'Ape-human',
                'Skillful human',
                'Upright human',
                'Wise human'
              ],
              correctIndex: 1,
              explanation: 'Pithecanthropus translates as "ape-human"',
            ),
          ],
        ),

        Topic(
          id: "primitive_hunters_gatherers",
          name: 'Primitive Hunters and Gatherers',
          imageAsset: '🏹',
          description: 'Occupations of primitive humans, use of fire, tools',
          explanation: 'Ancient people engaged in hunting and gathering, learned to use fire',
          questions: [
            Question(
              text: 'What significance did fire have in the life of ancient humans?',
              options: [
                'Only for lighting',
                'Only for cooking',
                'For heating, cooking, scaring away animals',
                'Only for hunting',
                'Only for rituals'
              ],
              correctIndex: 2,
              explanation: 'Fire was used for heating, cooking, lighting and scaring away wild animals',
            ),
            Question(
              text: 'What is a clan community?',
              options: [
                'A group of friends',
                'A collective of blood relatives',
                'A neighborhood association',
                'A tribal organization',
                'A state formation'
              ],
              correctIndex: 1,
              explanation: 'A clan community is a collective of blood relatives managing a common household',
            ),
            Question(
              text: 'What main races formed in Homo sapiens?',
              options: [
                'African and Asian',
                'Northern and southern',
                'Caucasoid, Mongoloid, Negroid',
                'Eastern and western',
                'Mountain and plain'
              ],
              correctIndex: 2,
              explanation: 'Three main races formed: Caucasoid, Mongoloid and Negroid',
            ),
            Question(
              text: 'Why was hunting a collective activity?',
              options: [
                'To be more fun',
                'To defend against predators',
                'Hunting large animals required joint efforts',
                'For religious reasons',
                'Due to lack of tools'
              ],
              correctIndex: 2,
              explanation: 'Hunting large animals was only possible collectively, by setting traps and corrals',
            ),
            Question(
              text: 'How did ancient people obtain fire?',
              options: [
                'Only from lightning',
                'By friction or striking sparks',
                'From the sun',
                'From volcanoes',
                'Bought from neighbors'
              ],
              correctIndex: 1,
              explanation: 'Later humans learned to make fire by friction or striking sparks from stone',
            ),
            Question(
              text: 'What animals appeared during the Ice Age?',
              options: [
                'Dinosaurs',
                'Mammoths and woolly rhinoceroses',
                'Elephants and giraffes',
                'Monkeys',
                'Crocodiles'
              ],
              correctIndex: 1,
              explanation: 'During the Ice Age, mammoths, woolly rhinoceroses, bison, and deer appeared',
            ),
            Question(
              text: 'Who led the tribe?',
              options: [
                'The strongest warrior',
                'Council of elders',
                'Priest',
                'Chief',
                'All adult men'
              ],
              correctIndex: 1,
              explanation: 'The tribe was led by a council including elders of the clans',
            ),
            Question(
              text: 'What is gathering?',
              options: [
                'Growing plants',
                'Collecting ready gifts of nature',
                'Hunting small animals',
                'Fishing',
                'Domesticating animals'
              ],
              correctIndex: 1,
              explanation: 'Gathering is the collection of berries, fruits, mushrooms, nuts, roots',
            ),
            Question(
              text: 'What weapons did ancient people use for hunting?',
              options: [
                'Bow and arrows',
                'Clubs, spears, javelins',
                'Metal swords',
                'Firearms',
                'War animals'
              ],
              correctIndex: 1,
              explanation: 'Ancient people used clubs, spears, javelins made of stone and wood',
            ),
            Question(
              text: 'How did primitive people make clothing?',
              options: [
                'Wove fabric',
                'Sewed from animal skins',
                'Wove from grass',
                'Cut from bark',
                'Fired clay'
              ],
              correctIndex: 1,
              explanation: 'They wore clothing made from animal skins, processed with bone needles',
            ),
          ],
        ),

        Topic(
          id: "primitive_beliefs_art",
          name: 'Beliefs and Art of Primitive People',
          imageAsset: '🎨',
          description: 'Knowledge, beliefs, magic, primitive art',
          explanation: 'Primitive people had knowledge of nature, believed in spirits and created works of art',
          questions: [
            Question(
              text: 'What was magic in primitive society?',
              options: [
                'Scientific knowledge',
                'Belief in the ability to communicate with spirits',
                'Artistic creativity',
                'Agricultural skills',
                'Construction technologies'
              ],
              correctIndex: 1,
              explanation: 'Magic is the belief in a person\'s ability to communicate with spirits through spells and rituals',
            ),
            Question(
              text: 'Where were the first drawings of primitive humans discovered?',
              options: [
                'In Egypt',
                'In the Altamira cave in Spain',
                'In Mesopotamia',
                'In China',
                'In India'
              ],
              correctIndex: 1,
              explanation: 'The first drawings were discovered by Sautuola in the Altamira cave in Spain',
            ),
            Question(
              text: 'What subjects are represented in cave paintings?',
              options: [
                'Human portraits',
                'Abstract patterns',
                'Animals and hunting scenes',
                'Mountain landscapes',
                'Celestial bodies'
              ],
              correctIndex: 2,
              explanation: 'Cave paintings depict animals (deer, bulls, bears) and hunting scenes',
            ),
            Question(
              text: 'What did primitive people believe happened after death?',
              options: [
                'The person disappears forever',
                'The soul moves to the afterlife',
                'The person turns into an animal',
                'The soul is reincarnated in a new body',
                'They believed nothing'
              ],
              correctIndex: 1,
              explanation: 'Primitive people believed that after death the soul moves to the afterlife',
            ),
            Question(
              text: 'What is Stonehenge?',
              options: [
                'Primitive dwelling',
                'Place for hunting rituals',
                'Ancient stone structure',
                'Cave with drawings',
                'Ancient human settlement'
              ],
              correctIndex: 2,
              explanation: 'Stonehenge is a structure of huge stones, possibly an ancient observatory',
            ),
            Question(
              text: 'What knowledge did primitive humans possess?',
              options: [
                'Only how to obtain food',
                'Could distinguish animal tracks, knew properties of plants',
                'Could write and count',
                'Familiar with astronomy',
                'Medical knowledge'
              ],
              correctIndex: 1,
              explanation: 'Primitive people could distinguish animal tracks, knew plant properties, could treat wounds',
            ),
            Question(
              text: 'Who is a shaman?',
              options: [
                'Tribal chief',
                'Best hunter',
                'Person capable of communicating with spirits',
                'Clan elder',
                'Keeper of fire'
              ],
              correctIndex: 2,
              explanation: 'A shaman is a person endowed with special abilities to communicate with spirits',
            ),
            Question(
              text: 'What was placed in the burial along with the deceased?',
              options: [
                'Only flowers',
                'Tools, weapons, food',
                'Jewelry',
                'Maps of the area',
                'Nothing was placed'
              ],
              correctIndex: 1,
              explanation: 'Tools, weapons, and food for the afterlife were placed next to the deceased',
            ),
            Question(
              text: 'What paints did ancient artists use?',
              options: [
                'Oil paints',
                'Watercolor',
                'Charcoal, chalk, animal blood',
                'Plant juices',
                'Mineral powders'
              ],
              correctIndex: 2,
              explanation: 'Ancient artists used charcoal, chalk, fat, eggs and animal blood',
            ),
            Question(
              text: 'For what purpose were magical rituals performed?',
              options: [
                'For entertainment',
                'To ensure successful hunting',
                'To educate youth',
                'For trade',
                'For construction'
              ],
              correctIndex: 1,
              explanation: 'Magical rituals were performed to ensure successful hunting and other important matters',
            ),
          ],
        ),

        Topic(
          id: "agriculture_cattle_breeding_craft",
          name: 'Emergence of Agriculture, Cattle Breeding and Craft',
          imageAsset: '🌾',
          description: 'Transition to producing economy, Neolithic, Metal Age',
          explanation: 'In the Neolithic, humans transitioned from hunting and gathering to agriculture and cattle breeding',
          questions: [
            Question(
              text: 'When did the Neolithic period begin?',
              options: [
                '2.5 million years ago',
                '100 thousand years ago',
                '10 thousand years ago',
                '5 thousand years ago',
                '1 thousand years ago'
              ],
              correctIndex: 2,
              explanation: 'The Neolithic (New Stone Age) began about 10 thousand years ago',
            ),
            Question(
              text: 'What is a neighborhood community?',
              options: [
                'A collective of relatives',
                'An association of neighbor families with separate households',
                'A tribal organization',
                'An urban settlement',
                'A military alliance'
              ],
              correctIndex: 1,
              explanation: 'A neighborhood community is a collective of neighbor families managing separate households on their own plots',
            ),
            Question(
              text: 'What metals did humans first start using?',
              options: [
                'Iron',
                'Bronze',
                'Copper',
                'Gold',
                'Silver'
              ],
              correctIndex: 2,
              explanation: 'The first metal humans started using was copper',
            ),
            Question(
              text: 'How did agriculture differ from gathering?',
              options: [
                'It did not differ',
                'Agriculture is production of products, gathering is appropriation',
                'Gathering is more efficient',
                'Agriculture is simpler',
                'Gathering required more knowledge'
              ],
              correctIndex: 1,
              explanation: 'Agriculture is production of products, while gathering is appropriation of ready gifts of nature',
            ),
            Question(
              text: 'What invention improved land cultivation?',
              options: [
                'Sickle',
                'Hoe',
                'Plow',
                'Axe',
                'Knife'
              ],
              correctIndex: 2,
              explanation: 'The wooden plow allowed cultivation of hard soil and began deep agriculture',
            ),
            Question(
              text: 'What is ceramics?',
              options: [
                'Stone products',
                'Clay products',
                'Wood products',
                'Bone products',
                'Metal products'
              ],
              correctIndex: 1,
              explanation: 'Ceramics are products made from fired clay, primarily vessels',
            ),
            Question(
              text: 'What new crafts appeared in the Neolithic?',
              options: [
                'Only pottery',
                'Pottery, weaving, spinning',
                'Only weaving',
                'Only metalworking',
                'Construction'
              ],
              correctIndex: 1,
              explanation: 'In the Neolithic, pottery, spinning and weaving appeared',
            ),
            Question(
              text: 'What is "inequality" in primitive society?',
              options: [
                'Equality of all people',
                'Emergence of rich and poor families',
                'Different duties of men and women',
                'Age differences',
                'Different abilities of people'
              ],
              correctIndex: 1,
              explanation: 'Inequality is the emergence of property stratification into rich and poor',
            ),
            Question(
              text: 'Which animal became the first human helper in hunting?',
              options: [
                'Cat',
                'Horse',
                'Dog',
                'Cow',
                'Sheep'
              ],
              correctIndex: 2,
              explanation: 'The dog became the first helper in hunting and a loyal human friend',
            ),
            Question(
              text: 'What was the "nobility" in primitive society?',
              options: [
                'All educated people',
                'Elders, chiefs, sorcerers who concentrated wealth',
                'Best hunters',
                'Craftsmen',
                'Priests'
              ],
              correctIndex: 1,
              explanation: 'The nobility were elders, chiefs, sorcerers who owned the best lands and herds',
            ),
          ],
        ),

        // CHAPTER II: ANCIENT EAST
        Topic(
          id: "ancient_egypt_formation",
          name: 'Ancient Egypt. Formation of the State',
          imageAsset: '🏺',
          description: 'Natural conditions of Egypt, unification of Upper and Lower Egypt',
          explanation: 'Ancient Egypt arose in the Nile Valley, unified under Pharaoh Menes',
          questions: [
            Question(
              text: 'What significance did Nile floods have for Egypt?',
              options: [
                'Brought destruction',
                'Fertilized the land with fertile silt',
                'Interfered with agriculture',
                'Created swamps',
                'Washed away soil'
              ],
              correctIndex: 1,
              explanation: 'Nile floods brought fertile silt that fertilized the fields',
            ),
            Question(
              text: 'Who unified Upper and Lower Egypt?',
              options: [
                'Ramses II',
                'Thutmose III',
                'Akhenaten',
                'Menes',
                'Khufu'
              ],
              correctIndex: 3,
              explanation: 'Pharaoh Menes unified Upper and Lower Egypt around 3000 BC',
            ),
            Question(
              text: 'What were nomes in Ancient Egypt?',
              options: [
                'Temples',
                'Community associations-regions',
                'Pyramids',
                'Hieroglyphs',
                'Canals'
              ],
              correctIndex: 1,
              explanation: 'Nomes were the first community associations in the Nile Valley',
            ),
            Question(
              text: 'What is a shadoof?',
              options: [
                'Boat',
                'Device for lifting water',
                'Fishing net',
                'Agricultural tool',
                'Type of clothing'
              ],
              correctIndex: 1,
              explanation: 'A shadoof is a device for lifting water to upper fields',
            ),
            Question(
              text: 'What did Egyptians make writing material from?',
              options: [
                'Wood',
                'Papyrus',
                'Clay',
                'Silk',
                'Leather'
              ],
              correctIndex: 1,
              explanation: 'Egyptians made papyrus from reed stems',
            ),
            Question(
              text: 'What headdress symbolized power over all Egypt?',
              options: [
                'Only the white crown',
                'Only the red crown',
                'Double white-red crown',
                'Golden helmet',
                'Headband with uraeus'
              ],
              correctIndex: 2,
              explanation: 'The double white-red crown symbolized power over Upper and Lower Egypt',
            ),
            Question(
              text: 'Where was Lower Egypt located?',
              options: [
                'In the upper Nile',
                'In the Nile Delta',
                'In the Nile Valley',
                'In the oases',
                'In the mountains'
              ],
              correctIndex: 1,
              explanation: 'Lower Egypt was located in the Nile Delta, while Upper Egypt was in the valley',
            ),
            Question(
              text: 'What is an oasis?',
              options: [
                'Desert',
                'Place in the desert with a water source',
                'Mountain area',
                'River valley',
                'Sea bay'
              ],
              correctIndex: 1,
              explanation: 'An oasis is a place in the desert where there are water sources and vegetation',
            ),
            Question(
              text: 'Who was Herodotus and what is his relation to Egypt?',
              options: [
                'Egyptian pharaoh',
                'Greek historian who described Egypt',
                'Roman commander',
                'Egyptian priest',
                'Babylonian king'
              ],
              correctIndex: 1,
              explanation: 'Herodotus was an ancient Greek historian who visited Egypt and described its customs',
            ),
            Question(
              text: 'What is the Nile Delta?',
              options: [
                'Mountain area',
                'Place where the river flows into the sea with a branched channel',
                'Desert area',
                'Capital of Egypt',
                'Temple complex'
              ],
              correctIndex: 1,
              explanation: 'The delta is the place where the Nile flows into the Mediterranean Sea, where the channel branches into distributaries',
            ),
          ],
        ),

        Topic(
          id: "ancient_egypt_society",
          name: 'Society of Ancient Egypt',
          imageAsset: '👑',
          description: 'Pharaoh, officials, priests, farmers, craftsmen, slaves',
          explanation: 'Egyptian society had a pyramidal structure headed by the pharaoh',
          questions: [
            Question(
              text: 'What power did the pharaoh have in Ancient Egypt?',
              options: [
                'Limited by council',
                'Elected',
                'Unlimited (despotism)',
                'Symbolic',
                'Religious'
              ],
              correctIndex: 2,
              explanation: 'The pharaoh possessed unlimited power - despotism',
            ),
            Question(
              text: 'Who were scribes in Ancient Egypt?',
              options: [
                'Military commanders',
                'Priests',
                'Officials keeping records',
                'Farmers',
                'Craftsmen'
              ],
              correctIndex: 2,
              explanation: 'Scribes were officials who kept records of everything produced and expended in the country',
            ),
            Question(
              text: 'What duties did Egyptians perform?',
              options: [
                'Only military service',
                'Only pyramid building',
                'Digging canals, road construction, tax payment',
                'Only religious rituals',
                'Only agricultural work'
              ],
              correctIndex: 2,
              explanation: 'Egyptians performed various duties: dug canals, built roads, paid taxes',
            ),
            Question(
              text: 'Who were nomarchs?',
              options: [
                'High priests',
                'Rulers of nomes',
                'Chief scribes',
                'Military commanders',
                'Pyramid builders'
              ],
              correctIndex: 1,
              explanation: 'Nomarchs were rulers of nomes (regions) in Ancient Egypt',
            ),
            Question(
              text: 'What was the treasury in Ancient Egypt?',
              options: [
                'Temple treasure',
                'State storage of valuables',
                'Pharaoh\'s personal property',
                'Priestly library',
                'Military arsenal'
              ],
              correctIndex: 1,
              explanation: 'The treasury was the state storage where taxes were received',
            ),
            Question(
              text: 'Who were called "living killed"?',
              options: [
                'Sentenced to death',
                'Prisoners turned into slavery',
                'Sick people',
                'Priests in service',
                'Prisoners of war'
              ],
              correctIndex: 1,
              explanation: '"Living killed" were prisoners who were previously killed but later enslaved',
            ),
            Question(
              text: 'What foods were basic in the diet of ordinary Egyptians?',
              options: [
                'Meat and fish',
                'Barley and wheat cakes',
                'Fruits and vegetables',
                'Dairy products',
                'Sweets'
              ],
              correctIndex: 1,
              explanation: 'The main food was barley and wheat cakes eaten with vegetables',
            ),
            Question(
              text: 'What were ekzenes?',
              options: [
                'Temple servants',
                'Scribes',
                'Pharaoh\'s servants',
                'Prisoner-of-war slaves',
                'Farmers'
              ],
              correctIndex: 3,
              explanation: 'Ekzenes were prisoner-of-war slaves captured during military campaigns',
            ),
            Question(
              text: 'Who occupied the highest level in Egyptian society?',
              options: [
                'Priests',
                'Pharaoh',
                'Nomarchs',
                'Scribes',
                'Military commanders'
              ],
              correctIndex: 1,
              explanation: 'The highest level was occupied by the pharaoh, considered a god on earth',
            ),
            Question(
              text: 'What duties did priests perform?',
              options: [
                'Only religious rituals',
                'Serving gods, managing temple economy, teaching',
                'Only teaching scribes',
                'Only predictions',
                'Only treating the sick'
              ],
              correctIndex: 1,
              explanation: 'Priests served gods, managed temple economy, taught scribes, engaged in science',
            ),
          ],
        ),

        Topic(
          id: "ancient_egypt_religion",
          name: 'Religion of Ancient Egypt',
          imageAsset: '🔮',
          description: 'Gods, myths, temples, afterlife',
          explanation: 'Egyptians believed in many gods, the afterlife and mummified the dead',
          questions: [
            Question(
              text: 'What was the name of the sun god in Ancient Egypt?',
              options: [
                'Osiris',
                'Amun-Ra',
                'Thoth',
                'Anubis',
                'Horus'
              ],
              correctIndex: 1,
              explanation: 'Amun-Ra was the sun god, the supreme deity of the Egyptian pantheon',
            ),
            Question(
              text: 'Who was Osiris?',
              options: [
                'Sun god',
                'God of wisdom',
                'God of the afterlife',
                'God of war',
                'God of earth'
              ],
              correctIndex: 2,
              explanation: 'Osiris was the god of the afterlife, judge of the dead',
            ),
            Question(
              text: 'What is a mummy?',
              options: [
                'Statue of a god',
                'Body of the deceased treated in a special way',
                'Sacred animal',
                'Temple servant',
                'Ritual object'
              ],
              correctIndex: 1,
              explanation: 'A mummy is the body of the deceased treated with soda and balms for preservation',
            ),
            Question(
              text: 'Which god was depicted with a jackal head?',
              options: [
                'Thoth',
                'Anubis',
                'Horus',
                'Set',
                'Ptah'
              ],
              correctIndex: 1,
              explanation: 'Anubis - god of embalming, was depicted with a jackal head',
            ),
            Question(
              text: 'What is a sarcophagus?',
              options: [
                'Pharaoh\'s tomb',
                'Coffin for a mummy',
                'Temple room',
                'Sacred book',
                'Sacrificial altar'
              ],
              correctIndex: 1,
              explanation: 'A sarcophagus is a coffin for a mummy, often richly decorated',
            ),
            Question(
              text: 'Who was Thoth?',
              options: [
                'Sun god',
                'God of wisdom and writing',
                'God of war',
                'God of earth',
                'God of water'
              ],
              correctIndex: 1,
              explanation: 'Thoth was the god of wisdom, counting and writing, inventor of hieroglyphs',
            ),
            Question(
              text: 'What is the "Book of the Dead"?',
              options: [
                'Historical chronicle',
                'Collection of spells for the afterlife',
                'Poetic work',
                'Scientific treatise',
                'Law collection'
              ],
              correctIndex: 1,
              explanation: '"Book of the Dead" is a collection of spells helping the soul in the afterlife',
            ),
            Question(
              text: 'Which god was the patron of pharaohs?',
              options: [
                'Osiris',
                'Horus',
                'Anubis',
                'Set',
                'Ptah'
              ],
              correctIndex: 1,
              explanation: 'Horus - sky god, patron of pharaohs, depicted with a falcon head',
            ),
            Question(
              text: 'What was the scarab in Egyptian religion?',
              options: [
                'Harmful insect',
                'Sacred beetle, symbol of rebirth',
                'Type of lizard',
                'Sacred bird',
                'Ritual knife'
              ],
              correctIndex: 1,
              explanation: 'The scarab was a beetle considered a sacred symbol of rebirth and the sun',
            ),
            Question(
              text: 'What were crocodiles in Egyptian religion?',
              options: [
                'Harmful animals',
                'Sacred animals of god Sobek',
                'Symbol of evil',
                'Hunting prey',
                'Trade item'
              ],
              correctIndex: 1,
              explanation: 'Crocodiles were considered sacred animals of the water god Sobek',
            ),
          ],
        ),

        Topic(
          id: "ancient_egypt_culture",
          name: 'Culture of Ancient Egypt',
          imageAsset: '📚',
          description: 'Writing, science, art, architecture',
          explanation: 'Ancient Egypt left a rich cultural heritage: pyramids, hieroglyphs, papyri',
          questions: [
            Question(
              text: 'What are hieroglyphs?',
              options: [
                'Alphabet letters',
                'Egyptian writing signs',
                'Mathematical symbols',
                'Temple decorations',
                'Pictures for children'
              ],
              correctIndex: 1,
              explanation: 'Hieroglyphs are Egyptian writing signs combining images and sound symbols',
            ),
            Question(
              text: 'Who deciphered Egyptian hieroglyphs?',
              options: [
                'Heinrich Schliemann',
                'Jean-François Champollion',
                'Howard Carter',
                'Arthur Evans',
                'Leonardo da Vinci'
              ],
              correctIndex: 1,
              explanation: 'French scholar Champollion deciphered hieroglyphs using the Rosetta Stone',
            ),
            Question(
              text: 'What scientific knowledge was developed in Ancient Egypt?',
              options: [
                'Only mathematics',
                'Mathematics, medicine, astronomy',
                'Only medicine',
                'Only astronomy',
                'Only chemistry'
              ],
              correctIndex: 1,
              explanation: 'Egypt developed mathematics (for construction), medicine (embalming), astronomy (calendar)',
            ),
            Question(
              text: 'What is an obelisk?',
              options: [
                'Pyramid',
                'Tall stone pillar',
                'Temple building',
                'Pharaoh statue',
                'Tomb'
              ],
              correctIndex: 1,
              explanation: 'An obelisk is a tall stone pillar with a pointed top, a monument in honor of gods and pharaohs',
            ),
            Question(
              text: 'What structures were built for nobles?',
              options: [
                'Pyramids',
                'Mastabas',
                'Temples',
                'Palaces',
                'Obelisks'
              ],
              correctIndex: 1,
              explanation: 'Mastabas were built for nobles - tombs in the form of a truncated pyramid',
            ),
            Question(
              text: 'What is a sphinx?',
              options: [
                'Mythical creature with lion body and human head',
                'God of wisdom',
                'Type of writing',
                'Musical instrument',
                'Sacred book'
              ],
              correctIndex: 0,
              explanation: 'A sphinx is a mythical creature with a lion body and human head, often of a pharaoh',
            ),
            Question(
              text: 'What musical instruments existed in Ancient Egypt?',
              options: [
                'Only drums',
                'Only flutes',
                'Harps, flutes, drums',
                'Only harps',
                'Only trumpets'
              ],
              correctIndex: 2,
              explanation: 'Egyptians played harps, flutes, drums, sistrums',
            ),
            Question(
              text: 'What is papyrus?',
              options: [
                'Tree',
                'Reed for making writing material',
                'Clay',
                'Stone',
                'Metal'
              ],
              correctIndex: 1,
              explanation: 'Papyrus is a reed from which writing material was made',
            ),
            Question(
              text: 'What colors predominated in Egyptian painting?',
              options: [
                'Only black and white',
                'Yellow, red, blue, green',
                'Only brown',
                'Only gold',
                'All rainbow colors'
              ],
              correctIndex: 1,
              explanation: 'Egyptian painting was dominated by bright colors: yellow, red, blue, green',
            ),
            Question(
              text: 'What was the main purpose of Egyptian art?',
              options: [
                'Beautify life',
                'Serve religious and funeral cults',
                'Entertain people',
                'Educate youth',
                'Glorify nature'
              ],
              correctIndex: 1,
              explanation: 'Egyptian art served religious and funeral cults, ensuring eternal life',
            ),
          ],
        ),

        Topic(
          id: "ancient_egypt_pharaohs",
          name: 'Great Pharaohs of Ancient Egypt',
          imageAsset: '👑',
          description: 'Pharaohs of the Old, Middle, New Kingdoms',
          explanation: 'Egyptian history includes periods of prosperity under great pharaohs',
          questions: [
            Question(
              text: 'Who built the largest pyramid at Giza?',
              options: [
                'Khafre',
                'Khufu',
                'Menkaure',
                'Djoser',
                'Sneferu'
              ],
              correctIndex: 1,
              explanation: 'Pharaoh Khufu built the largest pyramid at Giza',
            ),
            Question(
              text: 'What was the name of the female pharaoh?',
              options: [
                'Nefertiti',
                'Hatshepsut',
                'Cleopatra',
                'Nefertari',
                'Tiy'
              ],
              correctIndex: 1,
              explanation: 'Hatshepsut was a female pharaoh who ruled Egypt',
            ),
            Question(
              text: 'Who was Akhenaten?',
              options: [
                'Builder of the pyramids',
                'Pharaoh-reformer who introduced monotheism',
                'Conqueror of new lands',
                'Scribe',
                'Priest'
              ],
              correctIndex: 1,
              explanation: 'Akhenaten was a pharaoh-reformer who introduced worship of the single god Aten',
            ),
            Question(
              text: 'Who discovered Tutankhamun\'s tomb?',
              options: [
                'Champollion',
                'Howard Carter',
                'Schliemann',
                'Evans',
                'Petrie'
              ],
              correctIndex: 1,
              explanation: 'Howard Carter discovered Tutankhamun\'s tomb in 1922',
            ),
            Question(
              text: 'What was Ramses II famous for?',
              options: [
                'Construction of pyramids',
                'Military campaigns and construction',
                'Religious reform',
                'Discovery of new lands',
                'Writing laws'
              ],
              correctIndex: 1,
              explanation: 'Ramses II was famous for military campaigns and large-scale construction',
            ),
            Question(
              text: 'What battle did Ramses II fight against the Hittites?',
              options: [
                'At Marathon',
                'At Kadesh',
                'At Gaugamela',
                'At Thermopylae',
                'At Cannae'
              ],
              correctIndex: 1,
              explanation: 'The Battle of Kadesh between Egyptians and Hittites occurred under Ramses II',
            ),
            Question(
              text: 'Who was the last pharaoh of Ancient Egypt?',
              options: [
                'Hatshepsut',
                'Cleopatra VII',
                'Ramses II',
                'Tutankhamun',
                'Akhenaten'
              ],
              correctIndex: 1,
              explanation: 'Cleopatra VII was the last pharaoh of Ancient Egypt',
            ),
            Question(
              text: 'What was the capital of Egypt under Akhenaten?',
              options: [
                'Thebes',
                'Akhetaten',
                'Memphis',
                'Alexandria',
                'Cairo'
              ],
              correctIndex: 1,
              explanation: 'Akhenaten built a new capital - Akhetaten',
            ),
            Question(
              text: 'What was the significance of Hatshepsut\'s reign?',
              options: [
                'Military expansion',
                'Development of trade and construction',
                'Religious reforms',
                'Writing laws',
                'Development of science'
              ],
              correctIndex: 1,
              explanation: 'Under Hatshepsut, trade expeditions were organized and temples were built',
            ),
            Question(
              text: 'What was the significance of Tutankhamun\'s reign?',
              options: [
                'Great conquests',
                'Restoration of old cults after Akhenaten',
                'Construction of pyramids',
                'Religious reform',
                'Development of writing'
              ],
              correctIndex: 1,
              explanation: 'Tutankhamun restored the old cults abolished by Akhenaten',
            ),
          ],
        ),

        Topic(
          id: "ancient_mesopotamia",
          name: 'Ancient Mesopotamia',
          imageAsset: '🏛️',
          description: 'Sumer, Akkad, Babylon, Assyria',
          explanation: 'Mesopotamia was the cradle of civilization with city-states and cuneiform writing',
          questions: [
            Question(
              text: 'What is Mesopotamia?',
              options: [
                'Land between the Tigris and Euphrates',
                'Land between the Nile and Jordan',
                'Land between two seas',
                'Land between mountains',
                'Land between rivers'
              ],
              correctIndex: 0,
              explanation: 'Mesopotamia is the land between the Tigris and Euphrates rivers',
            ),
            Question(
              text: 'What writing was invented in Mesopotamia?',
              options: [
                'Hieroglyphs',
                'Cuneiform',
                'Alphabet',
                'Pictograms',
                'Runes'
              ],
              correctIndex: 1,
              explanation: 'Cuneiform was invented in Mesopotamia - writing on clay tablets',
            ),
            Question(
              text: 'What were ziggurats?',
              options: [
                'Palaces',
                'Temple towers',
                'Tombs',
                'Fortresses',
                'Libraries'
              ],
              correctIndex: 1,
              explanation: 'Ziggurats were stepped temple towers in Mesopotamia',
            ),
            Question(
              text: 'Who was Hammurabi?',
              options: [
                'Sumerian king',
                'Babylonian king who created laws',
                'Assyrian conqueror',
                'Persian king',
                'Egyptian pharaoh'
              ],
              correctIndex: 1,
              explanation: 'Hammurabi was the Babylonian king who created the first written laws',
            ),
            Question(
              text: 'What was the basis of Hammurabi\'s laws?',
              options: [
                'Principle of forgiveness',
                'Principle of "eye for an eye"',
                'Principle of mercy',
                'Principle of equality',
                'Principle of freedom'
              ],
              correctIndex: 1,
              explanation: 'Hammurabi\'s laws were based on the principle of "eye for an eye, tooth for a tooth"',
            ),
            Question(
              text: 'What was the Assyrian state famous for?',
              options: [
                'Cultural achievements',
                'Military power and cruelty',
                'Democratic governance',
                'Scientific discoveries',
                'Religious tolerance'
              ],
              correctIndex: 1,
              explanation: 'Assyria was famous for its military power and cruelty towards conquered peoples',
            ),
            Question(
              text: 'What was the name of the Babylonian god?',
              options: [
                'Ra',
                'Marduk',
                'Zeus',
                'Osiris',
                'Anu'
              ],
              correctIndex: 1,
              explanation: 'Marduk was the supreme god of Babylon',
            ),
            Question(
              text: 'What is the "Epic of Gilgamesh"?',
              options: [
                'Historical chronicle',
                'Ancient epic poem',
                'Collection of laws',
                'Religious text',
                'Scientific treatise'
              ],
              correctIndex: 1,
              explanation: '"Epic of Gilgamesh" is an ancient epic poem about the adventures of King Gilgamesh',
            ),
            Question(
              text: 'What was the name of the library in Nineveh?',
              options: [
                'Alexandrian',
                'Ashurbanipal',
                'Babylonian',
                'Assyrian',
                'Sumerian'
              ],
              correctIndex: 1,
              explanation: 'The library of Ashurbanipal was in Nineveh, the capital of Assyria',
            ),
            Question(
              text: 'What scientific knowledge was developed in Mesopotamia?',
              options: [
                'Only mathematics',
                'Mathematics, astronomy, medicine',
                'Only astronomy',
                'Only medicine',
                'Only geography'
              ],
              correctIndex: 1,
              explanation: 'In Mesopotamia, mathematics (60-based system), astronomy, and medicine developed',
            ),
          ],
        ),

        Topic(
          id: "ancient_india_china",
          name: 'Ancient India and China',
          imageAsset: '🐉',
          description: 'Civilizations of the Indus and Huang He valleys',
          explanation: 'Ancient India and China developed unique cultures, writing and philosophical teachings',
          questions: [
            Question(
              text: 'What rivers was Ancient India located between?',
              options: [
                'Tigris and Euphrates',
                'Indus and Ganges',
                'Nile and Jordan',
                'Huang He and Yangtze',
                'Danube and Rhine'
              ],
              correctIndex: 1,
              explanation: 'Ancient India was located between the Indus and Ganges rivers',
            ),
            Question(
              text: 'What is the caste system?',
              options: [
                'Military organization',
                'Division of society into closed groups',
                'Religious teaching',
                'Government system',
                'Economic system'
              ],
              correctIndex: 1,
              explanation: 'The caste system is the division of society into closed groups (castes) by birth',
            ),
            Question(
              text: 'What religions originated in India?',
              options: [
                'Only Buddhism',
                'Buddhism and Hinduism',
                'Only Hinduism',
                'Only Jainism',
                'Confucianism'
              ],
              correctIndex: 1,
              explanation: 'Buddhism and Hinduism originated in India',
            ),
            Question(
              text: 'Who was Buddha?',
              options: [
                'Indian god',
                'Founder of Buddhism',
                'Chinese philosopher',
                'Indian emperor',
                'Prophet'
              ],
              correctIndex: 1,
              explanation: 'Buddha (Siddhartha Gautama) was the founder of Buddhism',
            ),
            Question(
              text: 'What river was Ancient China located along?',
              options: [
                'Indus',
                'Ganges',
                'Huang He',
                'Yangtze',
                'Mekong'
              ],
              correctIndex: 2,
              explanation: 'Ancient China originated in the Huang He (Yellow River) valley',
            ),
            Question(
              text: 'What is the Great Wall of China?',
              options: [
                'Temple complex',
                'Defensive structure against nomads',
                'Irrigation system',
                'Palace',
                'Tomb'
              ],
              correctIndex: 1,
              explanation: 'The Great Wall of China was built to protect against nomads',
            ),
            Question(
              text: 'What philosophical teachings originated in China?',
              options: [
                'Only Confucianism',
                'Confucianism and Taoism',
                'Only Taoism',
                'Buddhism',
                'Hinduism'
              ],
              correctIndex: 1,
              explanation: 'Confucianism and Taoism originated in China',
            ),
            Question(
              text: 'Who was Confucius?',
              options: [
                'Chinese emperor',
                'Ancient Chinese philosopher',
                'Military leader',
                'Priest',
                'Scientist'
              ],
              correctIndex: 1,
              explanation: 'Confucius was an ancient Chinese philosopher whose teachings became the basis of Chinese culture',
            ),
            Question(
              text: 'What is silk?',
              options: [
                'Cotton fabric',
                'Fabric from silkworm cocoons',
                'Wool fabric',
                'Linen fabric',
                'Synthetic fabric'
              ],
              correctIndex: 1,
              explanation: 'Silk is a fabric made from threads extracted from silkworm cocoons',
            ),
            Question(
              text: 'What is the significance of the Shang Dynasty?',
              options: [
                'Unification of China',
                'Emergence of Chinese writing',
                'Construction of the Great Wall',
                'Creation of the empire',
                'Spread of Buddhism'
              ],
              correctIndex: 1,
              explanation: 'During the Shang Dynasty, Chinese hieroglyphic writing emerged',
            ),
          ],
        ),

        // CHAPTER III: ANCIENT GREECE
        Topic(
          id: "ancient_greece_nature_population",
          name: 'Ancient Greece: Nature and Population',
          imageAsset: '🏺',
          description: 'Geographical location, Mycenaean civilization',
          explanation: 'Ancient Greece was located on the Balkan Peninsula and islands, inhabited by Greek tribes',
          questions: [
            Question(
              text: 'What seas wash Greece?',
              options: [
                'Only the Mediterranean',
                'Aegean, Ionian, Mediterranean',
                'Only the Aegean',
                'Only the Ionian',
                'Black and Mediterranean'
              ],
              correctIndex: 1,
              explanation: 'Greece is washed by the Aegean, Ionian and Mediterranean seas',
            ),
            Question(
              text: 'What were the main occupations of the Greeks?',
              options: [
                'Only agriculture',
                'Agriculture, cattle breeding, crafts, trade',
                'Only cattle breeding',
                'Only crafts',
                'Only trade'
              ],
              correctIndex: 1,
              explanation: 'Greeks engaged in agriculture, cattle breeding, crafts and trade',
            ),
            Question(
              text: 'Who were the Achaeans?',
              options: [
                'Egyptian tribe',
                'Ancient Greek tribes',
                'Persian people',
                'Phoenicians',
                'Romans'
              ],
              correctIndex: 1,
              explanation: 'Achaeans were ancient Greek tribes who created the Mycenaean civilization',
            ),
            Question(
              text: 'What is the Mycenaean civilization?',
              options: [
                'Civilization on Crete',
                'Civilization in mainland Greece',
                'Egyptian civilization',
                'Mesopotamian civilization',
                'Indian civilization'
              ],
              correctIndex: 1,
              explanation: 'The Mycenaean civilization existed in mainland Greece in the 2nd millennium BC',
            ),
            Question(
              text: 'Who discovered Mycenae?',
              options: [
                'Champollion',
                'Heinrich Schliemann',
                'Evans',
                'Carter',
                'Petrie'
              ],
              correctIndex: 1,
              explanation: 'Heinrich Schliemann discovered Mycenae and conducted excavations there',
            ),
            Question(
              text: 'What is the Iliad?',
              options: [
                'Historical chronicle',
                'Ancient Greek epic poem about the Trojan War',
                'Collection of laws',
                'Philosophical treatise',
                'Religious text'
              ],
              correctIndex: 1,
              explanation: 'The Iliad is an ancient Greek epic poem about the Trojan War attributed to Homer',
            ),
            Question(
              text: 'What is the Odyssey?',
              options: [
                'Poem about the Trojan War',
                'Poem about Odysseus\'s wanderings',
                'Historical chronicle',
                'Collection of myths',
                'Philosophical work'
              ],
              correctIndex: 1,
              explanation: 'The Odyssey is a poem about the wanderings of Odysseus after the Trojan War',
            ),
            Question(
              text: 'What was the name of the king who started the Trojan War?',
              options: [
                'Odysseus',
                'Agamemnon',
                'Achilles',
                'Menelaus',
                'Paris'
              ],
              correctIndex: 1,
              explanation: 'Agamemnon was the Mycenaean king who led the Greek campaign against Troy',
            ),
            Question(
              text: 'What is a polis?',
              options: [
                'City',
                'City-state',
                'Village',
                'Temple',
                'Fortress'
              ],
              correctIndex: 1,
              explanation: 'Polis is a city-state, the main form of political organization in Ancient Greece',
            ),
            Question(
              text: 'What was the significance of Greek colonization?',
              options: [
                'Military expansion',
                'Spread of Greek culture',
                'Religious missions',
                'Scientific expeditions',
                'Trade only'
              ],
              correctIndex: 1,
              explanation: 'Colonization contributed to the spread of Greek culture in the Mediterranean',
            ),
          ],
        ),

        Topic(
          id: "ancient_greece_religion",
          name: 'Religion of Ancient Greece',
          imageAsset: '⚡',
          description: 'Gods, myths, temples, oracles',
          explanation: 'Ancient Greeks believed in many gods living on Mount Olympus',
          questions: [
            Question(
              text: 'Where did the Greek gods live according to myths?',
              options: [
                'In the sky',
                'On Mount Olympus',
                'In the underworld',
                'In the sea',
                'On earth'
              ],
              correctIndex: 1,
              explanation: 'According to myths, the gods lived on Mount Olympus',
            ),
            Question(
              text: 'Who was the supreme god?',
              options: [
                'Poseidon',
                'Zeus',
                'Hades',
                'Apollo',
                'Ares'
              ],
              correctIndex: 1,
              explanation: 'Zeus was the supreme god, ruler of gods and humans',
            ),
            Question(
              text: 'Who was the god of the sea?',
              options: [
                'Zeus',
                'Poseidon',
                'Hades',
                'Apollo',
                'Hermes'
              ],
              correctIndex: 1,
              explanation: 'Poseidon was the god of the sea and earthquakes',
            ),
            Question(
              text: 'What was the name of the god of the underworld?',
              options: [
                'Zeus',
                'Hades',
                'Poseidon',
                'Ares',
                'Hephaestus'
              ],
              correctIndex: 1,
              explanation: 'Hades was the god of the underworld of the dead',
            ),
            Question(
              text: 'Who was the goddess of love and beauty?',
              options: [
                'Hera',
                'Aphrodite',
                'Athena',
                'Artemis',
                'Demeter'
              ],
              correctIndex: 1,
              explanation: 'Aphrodite was the goddess of love and beauty',
            ),
            Question(
              text: 'What is an oracle?',
              options: [
                'Priest',
                'Place for divination and predictions',
                'Temple',
                'Sacrifice',
                'Religious ceremony'
              ],
              correctIndex: 1,
              explanation: 'An oracle is a place where predictions were given on behalf of the gods',
            ),
            Question(
              text: 'Where was the most famous oracle?',
              options: [
                'In Athens',
                'In Delphi',
                'In Olympia',
                'In Sparta',
                'In Thebes'
              ],
              correctIndex: 1,
              explanation: 'The most famous oracle was in Delphi, dedicated to Apollo',
            ),
            Question(
              text: 'What were the Olympic Games?',
              options: [
                'Military competitions',
                'Sports competitions in honor of Zeus',
                'Theatrical performances',
                'Religious ceremonies',
                'Political assemblies'
              ],
              correctIndex: 1,
              explanation: 'The Olympic Games were sports competitions held in honor of Zeus',
            ),
            Question(
              text: 'How often were the Olympic Games held?',
              options: [
                'Every year',
                'Every 4 years',
                'Every 10 years',
                'Once',
                'Every month'
              ],
              correctIndex: 1,
              explanation: 'The Olympic Games were held every 4 years',
            ),
            Question(
              text: 'What was the name of the goddess of wisdom?',
              options: [
                'Hera',
                'Athena',
                'Aphrodite',
                'Artemis',
                'Demeter'
              ],
              correctIndex: 1,
              explanation: 'Athena was the goddess of wisdom, just war and crafts',
            ),
          ],
        ),

        Topic(
          id: "athens_sparta",
          name: 'Athens and Sparta',
          imageAsset: '🛡️',
          description: 'Two main policies of Ancient Greece',
          explanation: 'Athens and Sparta represented two different models of Greek society',
          questions: [
            Question(
              text: 'What was the government system in Athens?',
              options: [
                'Monarchy',
                'Democracy',
                'Oligarchy',
                'Tyranny',
                'Aristocracy'
              ],
              correctIndex: 1,
              explanation: 'Athens had a democratic system where citizens participated in governance',
            ),
            Question(
              text: 'What was the government system in Sparta?',
              options: [
                'Democracy',
                'Oligarchy',
                'Monarchy',
                'Tyranny',
                'Republic'
              ],
              correctIndex: 1,
              explanation: 'Sparta had an oligarchic system where power belonged to a few',
            ),
            Question(
              text: 'Who were the helots in Sparta?',
              options: [
                'Citizens',
                'Conquered population turned into slaves',
                'Warriors',
                'Merchants',
                'Artisans'
              ],
              correctIndex: 1,
              explanation: 'Helots were the conquered population of Messenia turned into state slaves',
            ),
            Question(
              text: 'What was the main occupation of Spartiates?',
              options: [
                'Agriculture',
                'Military service',
                'Crafts',
                'Trade',
                'Science'
              ],
              correctIndex: 1,
              explanation: 'Spartiates were primarily engaged in military service',
            ),
            Question(
              text: 'What was the name of the Athenian reformer who laid the foundations of democracy?',
              options: [
                'Solon',
                'Pericles',
                'Themistocles',
                'Cleisthenes',
                'Draco'
              ],
              correctIndex: 0,
              explanation: 'Solon carried out reforms that laid the foundations of Athenian democracy',
            ),
            Question(
              text: 'What is the Areopagus?',
              options: [
                'People\'s Assembly',
                'Council of Elders',
                'Market Square',
                'Temple',
                'Theater'
              ],
              correctIndex: 1,
              explanation: 'The Areopagus was the council of elders, the highest judicial body in Athens',
            ),
            Question(
              text: 'At what age did Spartan boys begin military training?',
              options: [
                'From 7 years old',
                'From 10 years old',
                'From 12 years old',
                'From 15 years old',
                'From 18 years old'
              ],
              correctIndex: 0,
              explanation: 'Spartan boys began military training at age 7',
            ),
            Question(
              text: 'What was the name of the Spartan slave?',
              options: [
                'Metic',
                'Helot',
                'Periek',
                'Citizen',
                'Warrior'
              ],
              correctIndex: 1,
              explanation: 'Helots were slaves in Sparta',
            ),
            Question(
              text: 'Who could be a citizen in Athens?',
              options: [
                'All residents',
                'Only men whose parents were Athenians',
                'Only rich people',
                'Only warriors',
                'Only officials'
              ],
              correctIndex: 1,
              explanation: 'Citizens in Athens were only men whose both parents were Athenians',
            ),
            Question(
              text: 'What was the main goal of Spartan education?',
              options: [
                'Comprehensive development',
                'Preparing a disciplined warrior',
                'Teaching sciences',
                'Teaching arts',
                'Teaching trade'
              ],
              correctIndex: 1,
              explanation: 'The goal of Spartan education was to prepare a disciplined and hardy warrior',
            ),
          ],
        ),

        Topic(
          id: "greco_persian_wars",
          name: 'Greco-Persian Wars',
          imageAsset: '⚔️',
          description: 'Wars between Greek city-states and the Persian Empire',
          explanation: 'In the 5th century BC, the Greeks repelled the Persian invasion',
          questions: [
            Question(
              text: 'When did the Greco-Persian Wars begin?',
              options: [
                'In the 6th century BC',
                'In 500 BC',
                'In 490 BC',
                'In 480 BC',
                'In 450 BC'
              ],
              correctIndex: 1,
              explanation: 'The Greco-Persian Wars began in 500 BC with the Ionian Revolt',
            ),
            Question(
              text: 'What was the first major battle of the Greco-Persian Wars?',
              options: [
                'Battle of Thermopylae',
                'Battle of Marathon',
                'Battle of Salamis',
                'Battle of Plataea',
                'Battle of Mycale'
              ],
              correctIndex: 1,
              explanation: 'The first major battle was the Battle of Marathon in 490 BC',
            ),
            Question(
              text: 'Who won the Battle of Marathon?',
              options: [
                'Persians',
                'Greeks',
                'Draw',
                'Spartans',
                'Athenians'
              ],
              correctIndex: 1,
              explanation: 'The Greeks, led by Miltiades, won the Battle of Marathon',
            ),
            Question(
              text: 'Who was the Persian king during the second invasion of Greece?',
              options: [
                'Cyrus',
                'Darius I',
                'Xerxes I',
                'Cambyses',
                'Artaxerxes'
              ],
              correctIndex: 2,
              explanation: 'Xerxes I led the second Persian invasion of Greece',
            ),
            Question(
              text: 'Where did the famous Battle of Thermopylae take place?',
              options: [
                'On the plain',
                'In the mountain pass',
                'At sea',
                'Near the city',
                'In the valley'
              ],
              correctIndex: 1,
              explanation: 'The Battle of Thermopylae took place in a narrow mountain pass',
            ),
            Question(
              text: 'Who led the Spartans at Thermopylae?',
              options: [
                'Leonidas',
                'Themistocles',
                'Miltiades',
                'Pericles',
                'Lycurgus'
              ],
              correctIndex: 0,
              explanation: 'King Leonidas led the Spartans at Thermopylae',
            ),
            Question(
              text: 'What was the decisive naval battle?',
              options: [
                'Battle of Marathon',
                'Battle of Thermopylae',
                'Battle of Salamis',
                'Battle of Plataea',
                'Battle of Mycale'
              ],
              correctIndex: 2,
              explanation: 'The Battle of Salamis in 480 BC was the decisive naval battle',
            ),
            Question(
              text: 'Who commanded the Athenian fleet at Salamis?',
              options: [
                'Leonidas',
                'Themistocles',
                'Miltiades',
                'Pericles',
                'Aristides'
              ],
              correctIndex: 1,
              explanation: 'Themistocles commanded the Athenian fleet at Salamis',
            ),
            Question(
              text: 'What was the significance of the Greco-Persian Wars?',
              options: [
                'Persian conquest of Greece',
                'Preservation of Greek independence',
                'Unification of Greece',
                'Spread of Persian culture',
                'End of Greek civilization'
              ],
              correctIndex: 1,
              explanation: 'The Greeks preserved their independence and culture',
            ),
            Question(
              text: 'When did the Greco-Persian Wars end?',
              options: [
                'In 490 BC',
                'In 480 BC',
                'In 449 BC',
                'In 431 BC',
                'In 404 BC'
              ],
              correctIndex: 2,
              explanation: 'The Greco-Persian Wars ended with the Peace of Callias in 449 BC',
            ),
          ],
        ),

        Topic(
          id: "athens_democracy_culture",
          name: 'Athenian Democracy and Culture',
          imageAsset: '🎭',
          description: 'Flourishing of democracy, architecture, theater',
          explanation: 'In the 5th century BC, Athens experienced a cultural flourishing under Pericles',
          questions: [
            Question(
              text: 'Who was the leader of Athens during its heyday?',
              options: [
                'Solon',
                'Pericles',
                'Themistocles',
                'Cleisthenes',
                'Draco'
              ],
              correctIndex: 1,
              explanation: 'Pericles led Athens during its heyday in the 5th century BC',
            ),
            Question(
              text: 'What building was built on the Acropolis?',
              options: [
                'Parthenon',
                'Colosseum',
                'Pyramid',
                'Ziggurat',
                'Lighthouse'
              ],
              correctIndex: 0,
              explanation: 'The Parthenon, temple of Athena, was built on the Acropolis',
            ),
            Question(
              text: 'Who were the architects of the Parthenon?',
              options: [
                'Phidias',
                'Ictinus and Callicrates',
                'Praxiteles',
                'Scopas',
                'Lysippus'
              ],
              correctIndex: 1,
              explanation: 'Ictinus and Callicrates were the architects of the Parthenon',
            ),
            Question(
              text: 'Who created the statue of Athena in the Parthenon?',
              options: [
                'Ictinus',
                'Phidias',
                'Praxiteles',
                'Scopas',
                'Lysippus'
              ],
              correctIndex: 1,
              explanation: 'Phidias created the famous statue of Athena in the Parthenon',
            ),
            Question(
              text: 'What is ostracism?',
              options: [
                'Election to office',
                'Exile of dangerous citizens',
                'Tax collection',
                'Military service',
                'Religious ceremony'
              ],
              correctIndex: 1,
              explanation: 'Ostracism was the expulsion of dangerous citizens from Athens for 10 years',
            ),
            Question(
              text: 'What theatrical genres existed in Ancient Greece?',
              options: [
                'Only tragedy',
                'Tragedy and comedy',
                'Only comedy',
                'Only drama',
                'Only satire'
              ],
              correctIndex: 1,
              explanation: 'In Ancient Greece, tragedy and comedy existed',
            ),
            Question(
              text: 'Who were the famous tragedians?',
              options: [
                'Only Aeschylus',
                'Aeschylus, Sophocles, Euripides',
                'Only Sophocles',
                'Only Euripides',
                'Only Aristophanes'
              ],
              correctIndex: 1,
              explanation: 'Famous tragedians were Aeschylus, Sophocles and Euripides',
            ),
            Question(
              text: 'Who was the famous comedian?',
              options: [
                'Aeschylus',
                'Aristophanes',
                'Sophocles',
                'Euripides',
                'Menander'
              ],
              correctIndex: 1,
              explanation: 'Aristophanes was the most famous comedian',
            ),
            Question(
              text: 'What is philosophy?',
              options: [
                'Religious teaching',
                'Love of wisdom',
                'Scientific knowledge',
                'Artistic creativity',
                'Political activity'
              ],
              correctIndex: 1,
              explanation: 'Philosophy translates as "love of wisdom"',
            ),
            Question(
              text: 'Who were the famous Greek philosophers?',
              options: [
                'Only Socrates',
                'Socrates, Plato, Aristotle',
                'Only Plato',
                'Only Aristotle',
                'Only Pythagoras'
              ],
              correctIndex: 1,
              explanation: 'Famous philosophers were Socrates, Plato and Aristotle',
            ),
          ],
        ),

        Topic(
          id: "macedonian_conquest",
          name: 'Macedonian Conquest',
          imageAsset: '👑',
          description: 'Rise of Macedonia, Alexander the Great',
          explanation: 'In the 4th century BC, Macedonia subjugated Greece and created a huge empire',
          questions: [
            Question(
              text: 'Who was the king of Macedonia who conquered Greece?',
              options: [
                'Alexander the Great',
                'Philip II',
                'Darius III',
                'Xerxes',
                'Pericles'
              ],
              correctIndex: 1,
              explanation: 'Philip II, Alexander\'s father, conquered Greece',
            ),
            Question(
              text: 'When did the Battle of Chaeronea take place?',
              options: [
                'In 490 BC',
                'In 480 BC',
                'In 431 BC',
                'In 338 BC',
                'In 323 BC'
              ],
              correctIndex: 3,
              explanation: 'The Battle of Chaeronea, where Philip defeated the Greeks, took place in 338 BC',
            ),
            Question(
              text: 'Who was Alexander the Great?',
              options: [
                'Greek philosopher',
                'Macedonian king and conqueror',
                'Persian king',
                'Athenian commander',
                'Spartan king'
              ],
              correctIndex: 1,
              explanation: 'Alexander the Great was the Macedonian king who created a huge empire',
            ),
            Question(
              text: 'When did Alexander begin his campaign to the East?',
              options: [
                'In 490 BC',
                'In 480 BC',
                'In 431 BC',
                'In 338 BC',
                'In 334 BC'
              ],
              correctIndex: 4,
              explanation: 'Alexander began his campaign to the East in 334 BC',
            ),
            Question(
              text: 'What was the first major battle against the Persians?',
              options: [
                'Battle of Chaeronea',
                'Battle of Granicus',
                'Battle of Issus',
                'Battle of Gaugamela',
                'Battle of Hydaspes'
              ],
              correctIndex: 1,
              explanation: 'The first major battle was the Battle of Granicus in 334 BC',
            ),
            Question(
              text: 'Who was the Persian king during Alexander\'s campaign?',
              options: [
                'Xerxes',
                'Darius III',
                'Cyrus',
                'Cambyses',
                'Artaxerxes'
              ],
              correctIndex: 1,
              explanation: 'Darius III was the Persian king during Alexander\'s campaign',
            ),
            Question(
              text: 'What was the decisive battle with Persia?',
              options: [
                'Battle of Granicus',
                'Battle of Issus',
                'Battle of Gaugamela',
                'Battle of Hydaspes',
                'Battle of Chaeronea'
              ],
              correctIndex: 2,
              explanation: 'The Battle of Gaugamela in 331 BC was the decisive battle',
            ),
            Question(
              text: 'How far east did Alexander\'s empire extend?',
              options: [
                'To Egypt',
                'To India',
                'To China',
                'To Arabia',
                'To Scythia'
              ],
              correctIndex: 1,
              explanation: 'Alexander\'s empire extended to India',
            ),
            Question(
              text: 'What was the name of the city Alexander founded in Egypt?',
              options: [
                'Rome',
                'Alexandria',
                'Babylon',
                'Persepolis',
                'Athens'
              ],
              correctIndex: 1,
              explanation: 'Alexandria in Egypt became one of the most important cities of the ancient world',
            ),
            Question(
              text: 'When did Alexander the Great die?',
              options: [
                'In 490 BC',
                'In 480 BC',
                'In 431 BC',
                'In 338 BC',
                'In 323 BC'
              ],
              correctIndex: 4,
              explanation: 'Alexander the Great died in 323 BC in Babylon',
            ),
          ],
        ),

        // CHAPTER IV: ANCIENT ROME
        Topic(
          id: "early_rome",
          name: 'Early Rome',
          imageAsset: '🏛️',
          description: 'Foundation of Rome, royal period',
          explanation: 'According to legend, Rome was founded in 753 BC by Romulus',
          questions: [
            Question(
              text: 'According to legend, when was Rome founded?',
              options: [
                'In 1000 BC',
                'In 753 BC',
                'In 500 BC',
                'In 300 BC',
                'In 100 BC'
              ],
              correctIndex: 1,
              explanation: 'According to legend, Rome was founded in 753 BC',
            ),
            Question(
              text: 'Who were the legendary founders of Rome?',
              options: [
                'Romulus and Remus',
                'Caesar and Pompey',
                'Scipio and Hannibal',
                'Augustus and Antony',
                'Cicero and Cato'
              ],
              correctIndex: 0,
              explanation: 'According to legend, Rome was founded by Romulus and Remus',
            ),
            Question(
              text: 'Who raised Romulus and Remus?',
              options: [
                'Shepherd',
                'She-wolf',
                'Goddess',
                'Priest',
                'Queen'
              ],
              correctIndex: 1,
              explanation: 'According to legend, the brothers were nursed by a she-wolf',
            ),
            Question(
              text: 'What river was Rome located on?',
              options: [
                'Nile',
                'Tiber',
                'Euphrates',
                'Danube',
                'Rhine'
              ],
              correctIndex: 1,
              explanation: 'Rome was located on the Tiber River',
            ),
            Question(
              text: 'What peoples inhabited Ancient Italy?',
              options: [
                'Only Greeks',
                'Latins, Etruscans, Samnites',
                'Only Etruscans',
                'Only Latins',
                'Only Gauls'
              ],
              correctIndex: 1,
              explanation: 'Ancient Italy was inhabited by Latins, Etruscans, Samnites and other peoples',
            ),
            Question(
              text: 'Who were the Etruscans?',
              options: [
                'Greek tribe',
                'Ancient people of Italy',
                'Germanic tribe',
                'Celtic tribe',
                'Phoenicians'
              ],
              correctIndex: 1,
              explanation: 'The Etruscans were an ancient people who inhabited northern Italy',
            ),
            Question(
              text: 'How many kings ruled in Rome according to tradition?',
              options: [
                '5',
                '7',
                '10',
                '12',
                '15'
              ],
              correctIndex: 1,
              explanation: 'According to tradition, 7 kings ruled in Rome',
            ),
            Question(
              text: 'Who was the last Roman king?',
              options: [
                'Romulus',
                'Numa Pompilius',
                'Tarquin the Proud',
                'Servius Tullius',
                'Ancus Marcius'
              ],
              correctIndex: 2,
              explanation: 'Tarquin the Proud was the last Roman king',
            ),
            Question(
              text: 'When was the royal period in Rome?',
              options: [
                '1000-500 BC',
                '753-509 BC',
                '500-300 BC',
                '300-100 BC',
                '100 BC-100 AD'
              ],
              correctIndex: 1,
              explanation: 'The royal period in Rome lasted from 753 to 509 BC',
            ),
            Question(
              text: 'What is the Capitoline Wolf?',
              options: [
                'Legendary animal',
                'Sculpture symbolizing Rome',
                'Temple',
                'Fortress',
                'Hill'
              ],
              correctIndex: 1,
              explanation: 'The Capitoline Wolf is a bronze sculpture symbolizing the legend of Rome\'s foundation',
            ),
          ],
        ),

        Topic(
          id: "roman_republic",
          name: 'Roman Republic',
          imageAsset: '⚖️',
          description: 'Government system, social struggle',
          explanation: 'After the expulsion of the kings, a republican system was established in Rome',
          questions: [
            Question(
              text: 'When was the republic established in Rome?',
              options: [
                'In 753 BC',
                'In 509 BC',
                'In 390 BC',
                'In 265 BC',
                'In 146 BC'
              ],
              correctIndex: 1,
              explanation: 'The republic was established in Rome in 509 BC after the expulsion of the kings',
            ),
            Question(
              text: 'What were the main government bodies in the Roman Republic?',
              options: [
                'Only Senate',
                'Senate, popular assemblies, magistrates',
                'Only popular assemblies',
                'Only magistrates',
                'Only consuls'
              ],
              correctIndex: 1,
              explanation: 'The main government bodies were the Senate, popular assemblies and magistrates',
            ),
            Question(
              text: 'Who were consuls?',
              options: [
                'Priests',
                'Highest magistrates',
                'Military commanders',
                'Judges',
                'Treasurers'
              ],
              correctIndex: 1,
              explanation: 'Consuls were the highest magistrates who headed the Roman Republic',
            ),
            Question(
              text: 'What was the term of consuls?',
              options: [
                '1 year',
                '2 years',
                '4 years',
                '5 years',
                'For life'
              ],
              correctIndex: 0,
              explanation: 'Consuls were elected for 1 year',
            ),
            Question(
              text: 'What rights did Roman citizens have?',
              options: [
                'Only to vote',
                'To vote, to be elected, to appeal sentences',
                'Only to be elected',
                'Only to own land',
                'Only to trade'
              ],
              correctIndex: 1,
              explanation: 'Roman citizens had the right to vote, to be elected, and to appeal court sentences',
            ),
            Question(
              text: 'Who were patricians?',
              options: [
                'All residents of Rome',
                'Descendants of ancient families',
                'Conquered peoples',
                'Slaves',
                'Foreigners'
              ],
              correctIndex: 1,
              explanation: 'Patricians were descendants of the ancient families of Rome',
            ),
            Question(
              text: 'Who were plebeians?',
              options: [
                'Descendants of ancient families',
                'Common people',
                'Slaves',
                'Foreigners',
                'Priests'
              ],
              correctIndex: 1,
              explanation: 'Plebeians were the common people of Rome',
            ),
            Question(
              text: 'What was the struggle between patricians and plebeians?',
              options: [
                'For power',
                'For political and economic rights',
                'For land',
                'For slaves',
                'For trade'
              ],
              correctIndex: 1,
              explanation: 'Plebeians fought for political rights and economic equality with patricians',
            ),
            Question(
              text: 'What position could only plebeians hold?',
              options: [
                'Consul',
                'Tribune of the plebs',
                'Praetor',
                'Censor',
                'Dictator'
              ],
              correctIndex: 1,
              explanation: 'The tribune of the plebs could only be a plebeian and had the right to veto',
            ),
            Question(
              text: 'What laws were written on the Twelve Tables?',
              options: [
                'Religious',
                'Basic laws of the republic',
                'Military',
                'Trade',
                'Agricultural'
              ],
              correctIndex: 1,
              explanation: 'The Twelve Tables contained the basic laws of the Roman Republic',
            ),
          ],
        ),

        Topic(
          id: "roman_conquests",
          name: 'Roman Conquests',
          imageAsset: '🛡️',
          description: 'Wars with Carthage, conquest of the Mediterranean',
          explanation: 'Rome gradually conquered Italy and then the entire Mediterranean',
          questions: [
            Question(
              text: 'What wars did Rome fight with Carthage?',
              options: [
                'Peloponnesian',
                'Punic',
                'Macedonian',
                'Gallic',
                'Samnite'
              ],
              correctIndex: 1,
              explanation: 'The wars between Rome and Carthage were called the Punic Wars',
            ),
            Question(
              text: 'How many Punic Wars were there?',
              options: [
                '1',
                '2',
                '3',
                '4',
                '5'
              ],
              correctIndex: 2,
              explanation: 'There were three Punic Wars',
            ),
            Question(
              text: 'Who was the Carthaginian commander during the Second Punic War?',
              options: [
                'Hannibal',
                'Hasdrubal',
                'Hamilcar',
                'Scipio',
                'Fabius'
              ],
              correctIndex: 0,
              explanation: 'Hannibal was the Carthaginian commander during the Second Punic War',
            ),
            Question(
              text: 'How did Hannibal get to Italy?',
              options: [
                'By sea',
                'Through the Alps',
                'Through the Pyrenees',
                'Through the Balkans',
                'Through Africa'
              ],
              correctIndex: 1,
              explanation: 'Hannibal crossed the Alps with his army and elephants',
            ),
            Question(
              text: 'What was the decisive battle of the Second Punic War?',
              options: [
                'Battle of Cannae',
                'Battle of Zama',
                'Battle of Lake Trasimene',
                'Battle of Ticinus',
                'Battle of Trebia'
              ],
              correctIndex: 1,
              explanation: 'The Battle of Zama in 202 BC ended the Second Punic War',
            ),
            Question(
              text: 'Who commanded the Roman army at Zama?',
              options: [
                'Fabius',
                'Scipio Africanus',
                'Hannibal',
                'Hasdrubal',
                'Cato'
              ],
              correctIndex: 1,
              explanation: 'Scipio Africanus commanded the Roman army at Zama',
            ),
            Question(
              text: 'When was Carthage destroyed?',
              options: [
                'In 509 BC',
                'In 390 BC',
                'In 146 BC',
                'In 44 BC',
                'In 31 BC'
              ],
              correctIndex: 2,
              explanation: 'Carthage was destroyed in 146 BC after the Third Punic War',
            ),
            Question(
              text: 'What famous phrase did Cato end his speeches with?',
              options: [
                '"Veni, vidi, vici"',
                '"Carthage must be destroyed"',
                '"Alea iacta est"',
                '"Et tu, Brute?"',
                '"Divide and conquer"'
              ],
              correctIndex: 1,
              explanation: 'Cato ended his speeches with the phrase "Carthage must be destroyed"',
            ),
            Question(
              text: 'What territories did Rome conquer by the 2nd century BC?',
              options: [
                'Only Italy',
                'The entire Mediterranean',
                'Only Greece',
                'Only Africa',
                'Only Spain'
              ],
              correctIndex: 1,
              explanation: 'By the 2nd century BC, Rome conquered the entire Mediterranean',
            ),
            Question(
              text: 'What was the name of the Roman province in North Africa?',
              options: [
                'Asia',
                'Africa',
                'Macedonia',
                'Gaul',
                'Spain'
              ],
              correctIndex: 1,
              explanation: 'The Roman province in North Africa was called Africa',
            ),
          ],
        ),

        Topic(
          id: "roman_empire",
          name: 'Roman Empire',
          imageAsset: '👑',
          description: 'Fall of the republic, first emperors',
          explanation: 'In the 1st century BC, the republic fell and the empire was established',
          questions: [
            Question(
              text: 'Who was the first Roman emperor?',
              options: [
                'Julius Caesar',
                'Augustus',
                'Tiberius',
                'Caligula',
                'Nero'
              ],
              correctIndex: 1,
              explanation: 'Augustus (Octavian) was the first Roman emperor',
            ),
            Question(
              text: 'When did Augustus become emperor?',
              options: [
                'In 509 BC',
                'In 44 BC',
                'In 31 BC',
                'In 27 BC',
                'In 14 AD'
              ],
              correctIndex: 3,
              explanation: 'Augustus became emperor in 27 BC',
            ),
            Question(
              text: 'What was the period of Augustus\'s reign called?',
              options: [
                'Golden Age',
                'Silver Age',
                'Iron Age',
                'Bronze Age',
                'Copper Age'
              ],
              correctIndex: 0,
              explanation: 'Augustus\'s reign was called the Golden Age of Roman literature',
            ),
            Question(
              text: 'Who was Julius Caesar?',
              options: [
                'First emperor',
                'Dictator who paved the way for empire',
                'Consul',
                'Tribune',
                'Senator'
              ],
              correctIndex: 1,
              explanation: 'Julius Caesar was a dictator whose activities paved the way for the empire',
            ),
            Question(
              text: 'When was Julius Caesar assassinated?',
              options: [
                'In 509 BC',
                'In 44 BC',
                'In 31 BC',
                'In 27 BC',
                'In 14 AD'
              ],
              correctIndex: 1,
              explanation: 'Julius Caesar was assassinated in 44 BC',
            ),
            Question(
              text: 'What famous phrase did Caesar say when crossing the Rubicon?',
              options: [
                '"Veni, vidi, vici"',
                '"Alea iacta est"',
                '"Et tu, Brute?"',
                '"Carthage must be destroyed"',
                '"Divide and conquer"'
              ],
              correctIndex: 1,
              explanation: 'When crossing the Rubicon, Caesar said "Alea iacta est" - "The die is cast"',
            ),
            Question(
              text: 'Who was in the first triumvirate?',
              options: [
                'Augustus, Antony, Lepidus',
                'Caesar, Pompey, Crassus',
                'Nero, Caligula, Claudius',
                'Trajan, Hadrian, Marcus Aurelius',
                'Constantine, Diocletian, Maximian'
              ],
              correctIndex: 1,
              explanation: 'The first triumvirate included Caesar, Pompey and Crassus',
            ),
            Question(
              text: 'Who was in the second triumvirate?',
              options: [
                'Augustus, Antony, Lepidus',
                'Caesar, Pompey, Crassus',
                'Nero, Caligula, Claudius',
                'Trajan, Hadrian, Marcus Aurelius',
                'Constantine, Diocletian, Maximian'
              ],
              correctIndex: 0,
              explanation: 'The second triumvirate included Octavian (Augustus), Antony and Lepidus',
            ),
            Question(
              text: 'What was the decisive battle between Octavian and Antony?',
              options: [
                'Battle of Philippi',
                'Battle of Actium',
                'Battle of Cannae',
                'Battle of Zama',
                'Battle of Pharsalus'
              ],
              correctIndex: 1,
              explanation: 'The Battle of Actium in 31 BC ended with Octavian\'s victory over Antony',
            ),
            Question(
              text: 'What was the name of the first Roman emperor?',
              options: [
                'Julius Caesar',
                'Augustus',
                'Tiberius',
                'Caligula',
                'Nero'
              ],
              correctIndex: 1,
              explanation: 'Augustus was the first Roman emperor',
            ),
          ],
        ),

        Topic(
          id: "roman_culture",
          name: 'Culture of Ancient Rome',
          imageAsset: '📚',
          description: 'Architecture, literature, science',
          explanation: 'Roman culture absorbed Greek achievements and created its own unique works',
          questions: [
            Question(
              text: 'What architectural structure could accommodate up to 50,000 spectators?',
              options: [
                'Pantheon',
                'Colosseum',
                'Circus Maximus',
                'Forum',
                'Thermae'
              ],
              correctIndex: 1,
              explanation: 'The Colosseum could accommodate up to 50,000 spectators',
            ),
            Question(
              text: 'What was the Colosseum used for?',
              options: [
                'For theatrical performances',
                'For gladiator fights and spectacles',
                'For chariot races',
                'For religious ceremonies',
                'For political assemblies'
              ],
              correctIndex: 1,
              explanation: 'The Colosseum was used for gladiator fights and other spectacles',
            ),
            Question(
              text: 'What is the Pantheon?',
              options: [
                'Temple of all gods',
                'Amphitheater',
                'Stadium',
                'Palace',
                'Fortress'
              ],
              correctIndex: 0,
              explanation: 'The Pantheon is the "temple of all gods" in Rome',
            ),
            Question(
              text: 'What were Roman roads?',
              options: [
                'Dirt roads',
                'Paved stone roads',
                'Wooden roads',
                'Brick roads',
                'Gravel roads'
              ],
              correctIndex: 1,
              explanation: 'Roman roads were paved with stone and served for centuries',
            ),
            Question(
              text: 'What were aqueducts?',
              options: [
                'Bridges',
                'Structures for water supply',
                'Temples',
                'Palaces',
                'Fortresses'
              ],
              correctIndex: 1,
              explanation: 'Aqueducts were structures for supplying water to cities',
            ),
            Question(
              text: 'Who was Virgil?',
              options: [
                'Historian',
                'Poet, author of the Aeneid',
                'Philosopher',
                'Orator',
                'Scientist'
              ],
              correctIndex: 1,
              explanation: 'Virgil was a poet, author of the Aeneid about the founding of Rome',
            ),
            Question(
              text: 'Who was Cicero?',
              options: [
                'Poet',
                'Orator and politician',
                'Emperor',
                'Commander',
                'Scientist'
              ],
              correctIndex: 1,
              explanation: 'Cicero was a famous orator and politician',
            ),
            Question(
              text: 'What language was spoken in Ancient Rome?',
              options: [
                'Greek',
                'Latin',
                'Etruscan',
                'Celtic',
                'Phoenician'
              ],
              correctIndex: 1,
              explanation: 'Latin was the language of Ancient Rome',
            ),
            Question(
              text: 'What is Roman law?',
              options: [
                'Religious rules',
                'System of legal norms',
                'Moral principles',
                'Political doctrines',
                'Philosophical teachings'
              ],
              correctIndex: 1,
              explanation: 'Roman law is a system of legal norms that became the basis of European jurisprudence',
            ),
            Question(
              text: 'What was the name of the Roman public square?',
              options: [
                'Acropolis',
                'Forum',
                'Agora',
                'Circus',
                'Stadium'
              ],
              correctIndex: 1,
              explanation: 'The Forum was the main public square in Rome',
            ),
          ],
        ),

        Topic(
          id: "rise_of_christianity",
          name: 'Rise of Christianity',
          imageAsset: '✝️',
          description: 'Origins of Christianity, spread in the Roman Empire',
          explanation: 'Christianity arose in the 1st century AD in Judea and gradually spread throughout the empire',
          questions: [
            Question(
              text: 'Where did Christianity originate?',
              options: [
                'In Greece',
                'In Judea',
                'In Egypt',
                'In Rome',
                'In Persia'
              ],
              correctIndex: 1,
              explanation: 'Christianity originated in Judea in the 1st century AD',
            ),
            Question(
              text: 'Who is considered the founder of Christianity?',
              options: [
                'Apostle Peter',
                'Jesus Christ',
                'Apostle Paul',
                'Emperor Constantine',
                'Pontius Pilate'
              ],
              correctIndex: 1,
              explanation: 'Jesus Christ is considered the founder of Christianity',
            ),
            Question(
              text: 'What is the Bible?',
              options: [
                'Historical chronicle',
                'Sacred book of Christians',
                'Collection of laws',
                'Philosophical treatise',
                'Poetic work'
              ],
              correctIndex: 1,
              explanation: 'The Bible is the sacred book of Christians consisting of the Old and New Testaments',
            ),
            Question(
              text: 'Who were the first persecutors of Christians?',
              options: [
                'Greek authorities',
                'Roman authorities',
                'Jewish authorities',
                'Egyptian authorities',
                'Persian authorities'
              ],
              correctIndex: 1,
              explanation: 'The first persecutors of Christians were the Roman authorities',
            ),
            Question(
              text: 'Which emperor legalized Christianity?',
              options: [
                'Nero',
                'Diocletian',
                'Constantine',
                'Theodosius',
                'Augustus'
              ],
              correctIndex: 2,
              explanation: 'Emperor Constantine legalized Christianity with the Edict of Milan in 313',
            ),
            Question(
              text: 'Which emperor made Christianity the state religion?',
              options: [
                'Constantine',
                'Theodosius',
                'Nero',
                'Diocletian',
                'Augustus'
              ],
              correctIndex: 1,
              explanation: 'Emperor Theodosius made Christianity the state religion in 380',
            ),
            Question(
              text: 'What were the catacombs used for?',
              options: [
                'For water supply',
                'For secret Christian meetings',
                'For burials',
                'For storage',
                'For defense'
              ],
              correctIndex: 1,
              explanation: 'Catacombs were used for secret Christian meetings and burials',
            ),
            Question(
              text: 'Who were the apostles?',
              options: [
                'Roman officials',
                'Disciples of Jesus',
                'Jewish priests',
                'Greek philosophers',
                'Roman emperors'
              ],
              correctIndex: 1,
              explanation: 'The apostles were the disciples of Jesus who spread Christianity',
            ),
            Question(
              text: 'What is the New Testament?',
              options: [
                'Jewish sacred texts',
                'Part of the Bible about Jesus and his teachings',
                'Roman laws',
                'Greek myths',
                'Egyptian religious texts'
              ],
              correctIndex: 1,
              explanation: 'The New Testament is the part of the Bible telling about Jesus and his teachings',
            ),
            Question(
              text: 'Why did Christianity attract many followers?',
              options: [
                'Wealth of the church',
                'Ideas of equality and salvation',
                'Political power',
                'Military strength',
                'Economic benefits'
              ],
              correctIndex: 1,
              explanation: 'Christianity attracted with ideas of spiritual equality, justice and salvation',
            ),
          ],
        ),

        Topic(
          id: "fall_western_roman_empire",
          name: 'Fall of the Western Roman Empire',
          imageAsset: '🏺',
          description: 'Crisis of the empire, great migration, fall of Rome',
          explanation: 'In the 5th century AD, the Western Roman Empire fell under the onslaught of barbarians',
          questions: [
            Question(
              text: 'When did the Western Roman Empire fall?',
              options: [
                'In 313 AD',
                'In 395 AD',
                'In 410 AD',
                'In 476 AD',
                'In 500 AD'
              ],
              correctIndex: 3,
              explanation: 'The Western Roman Empire fell in 476 AD',
            ),
            Question(
              text: 'Who was the last Roman emperor?',
              options: [
                'Augustus',
                'Constantine',
                'Romulus Augustulus',
                'Theodosius',
                'Nero'
              ],
              correctIndex: 2,
              explanation: 'Romulus Augustulus was the last Roman emperor',
            ),
            Question(
              text: 'Who overthrew the last Roman emperor?',
              options: [
                'Goths',
                'Vandals',
                'Huns',
                'Franks',
                'Odoacer'
              ],
              correctIndex: 4,
              explanation: 'Odoacer, leader of the barbarians, overthrew the last Roman emperor',
            ),
            Question(
              text: 'What was the Great Migration?',
              options: [
                'Movement of Romans to the provinces',
                'Mass movement of barbarian tribes',
                'Resettlement of Greeks',
                'Jewish diaspora',
                'Christian missions'
              ],
              correctIndex: 1,
              explanation: 'The Great Migration was the mass movement of barbarian tribes in the 4th-7th centuries',
            ),
            Question(
              text: 'Who were the Huns?',
              options: [
                'Germanic tribe',
                'Nomadic people from Asia',
                'Celtic tribe',
                'Slavic tribe',
                'Roman citizens'
              ],
              correctIndex: 1,
              explanation: 'The Huns were a nomadic people from Asia led by Attila',
            ),
            Question(
              text: 'When was Rome sacked by the Visigoths?',
              options: [
                'In 376 AD',
                'In 410 AD',
                'In 451 AD',
                'In 455 AD',
                'In 476 AD'
              ],
              correctIndex: 1,
              explanation: 'Rome was sacked by the Visigoths led by Alaric in 410 AD',
            ),
            Question(
              text: 'When was Rome sacked by the Vandals?',
              options: [
                'In 376 AD',
                'In 410 AD',
                'In 451 AD',
                'In 455 AD',
                'In 476 AD'
              ],
              correctIndex: 3,
              explanation: 'Rome was sacked by the Vandals in 455 AD',
            ),
            Question(
              text: 'What battle stopped Attila\'s advance?',
              options: [
                'Battle of Adrianople',
                'Battle of the Catalaunian Fields',
                'Battle of Actium',
                'Battle of Cannae',
                'Battle of Zama'
              ],
              correctIndex: 1,
              explanation: 'The Battle of the Catalaunian Fields in 451 stopped Attila\'s advance',
            ),
            Question(
              text: 'What were the causes of the fall of the Western Roman Empire?',
              options: [
                'Only barbarian invasions',
                'Economic crisis, barbarian invasions, political instability',
                'Only economic crisis',
                'Only political instability',
                'Only religious conflicts'
              ],
              correctIndex: 1,
              explanation: 'The causes were economic crisis, barbarian invasions, political instability and other factors',
            ),
            Question(
              text: 'What part of the Roman Empire survived?',
              options: [
                'Western',
                'Eastern (Byzantine)',
                'Northern',
                'Southern',
                'All parts fell'
              ],
              correctIndex: 1,
              explanation: 'The Eastern Roman Empire (Byzantine) survived and existed until 1453',
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

final List<List<Subject>> allHistorySubjects = [
  historySubjects1,
  historySubjects2,
  historySubjects3,
  historySubjects4,
  historySubjects5,
  historySubjects6,
  historySubjects7,
  historySubjects8,
  historySubjects9,
  historySubjects10,
  historySubjects11,
];