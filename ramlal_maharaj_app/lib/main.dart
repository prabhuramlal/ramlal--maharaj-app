import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RamlalMaharajApp());
}

const Color gold = Color(0xFFB68A35);
const Color cream = Color(0xFFFFFAF0);
const Color darkBrown = Color(0xFF49351E);

class RamlalMaharajApp extends StatelessWidget {
  const RamlalMaharajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yog Yogeshwar Mahaprabhu',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          primary: gold,
          surface: cream,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<String> titles = [
    'Home',
    'Darshan',
    'Media',
    'Sadhana',
    'Profile',
  ];

  final List<IconData> icons = [
    Icons.home_rounded,
    Icons.self_improvement_rounded,
    Icons.play_circle_fill_rounded,
    Icons.spa_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: selectedIndex == 0
            ? const HomePage()
            : FeaturePage(title: titles[selectedIndex]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFF3E5C5),
        destinations: List.generate(5, (index) {
          return NavigationDestination(
            icon: Icon(icons[index]),
            label: titles[index],
          );
        }),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, dynamic>> features = const [
    {'name': 'Bhajan', 'icon': Icons.music_note_rounded},
    {'name': 'Aarti', 'icon': Icons.local_fire_department_rounded},
    {'name': 'Books', 'icon': Icons.menu_book_rounded},
    {'name': 'Guru Vani', 'icon': Icons.auto_stories_rounded},
    {'name': 'Pravachan', 'icon': Icons.mic_rounded},
    {'name': 'Satsang', 'icon': Icons.groups_rounded},
    {'name': 'Gallery', 'icon': Icons.photo_library_rounded},
    {'name': 'Sadhana', 'icon': Icons.spa_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE9A8), gold],
                    ),
                    border: Border.all(color: gold, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.self_improvement_rounded,
                    color: darkBrown,
                    size: 31,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yog Yogeshwar',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: darkBrown,
                        ),
                      ),
                      Text(
                        'Mahaprabhu Shree Ramlal Ji Maharaj',
                        style: TextStyle(
                          fontSize: 11,
                          color: gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.notifications_none_rounded,
                    color: darkBrown, size: 28),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Container(
              height: 215,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: gold, width: 1.5),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFEFC7),
                    Color(0xFFE7C77F),
                    Color(0xFFFFF7E6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.18),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.self_improvement_rounded,
                    size: 65,
                    color: darkBrown,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'श्री महाप्रभु जी महाराज',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: darkBrown,
                    ),
                  ),
                  SizedBox(height: 9),
                  Text(
                    'ॐ गुरवे नमः',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF80551D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'जय गुरुदेव 🙏',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Experience devotion, wisdom and peace',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.brown.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = features[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FeaturePage(
                          title: item['name'] as String,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFE9D6AC),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gold.withOpacity(0.08),
                          blurRadius: 9,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 54,
                          width: 54,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF2D8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: gold,
                            size: 29,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Text(
                          item['name'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: darkBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: features.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 13,
              crossAxisSpacing: 13,
              childAspectRatio: 1.18,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFFFF0D2),
                border: Border.all(color: const Color(0xFFE9D6AC)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Guru Vani',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkBrown,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'गुरु कृपा ही जीवन का सबसे बड़ा आधार है।',
                    style: TextStyle(
                      fontSize: 16,
                      color: darkBrown,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'New messages will be added here.',
                    style: TextStyle(
                      fontSize: 12,
                      color: gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FeaturePage extends StatelessWidget {
  final String title;

  const FeaturePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        foregroundColor: darkBrown,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.self_improvement_rounded,
              size: 75,
              color: gold,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Devotional content will be added here.',
              style: TextStyle(color: Colors.brown),
            ),
            const SizedBox(height: 25),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}