import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

const ivory = Color(0xFFF8F3E8);
const champagne = Color(0xFFC6A15B);
const maroon = Color(0xFF6B2638);
const brown = Color(0xFF704B2B);
const cardWhite = Color(0xFFFFFEFA);
const paleGold = Color(0xFFE9D9B8);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); } catch (_) {}
  const url = String.fromEnvironment('SUPABASE_URL');
  const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  if (url.isNotEmpty && key.isNotEmpty) {
    try { await Supabase.initialize(url: url, anonKey: key); } catch (_) {}
  }
  runApp(const RamlalMaharajApp());
}

class RamlalMaharajApp extends StatelessWidget {
  const RamlalMaharajApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Yog Yogeshwar Mahaprabhu',
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: ivory,
      colorScheme: ColorScheme.fromSeed(seedColor: champagne, primary: maroon, surface: ivory),
      appBarTheme: const AppBarTheme(backgroundColor: ivory, foregroundColor: brown, elevation: 0)),
    home: const MainScreen());
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int index = 0;
  final pages = const [HomePage(), DarshanPage(), MediaPage(), SadhanaPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: index, children: pages)),
    bottomNavigationBar: NavigationBar(height: 68, selectedIndex: index, backgroundColor: cardWhite,
      indicatorColor: paleGold, onDestinationSelected: (v) => setState(() => index = v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.self_improvement_outlined), selectedIcon: Icon(Icons.self_improvement), label: 'Darshan'),
        NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Media'),
        NavigationDestination(icon: Icon(Icons.spa_outlined), selectedIcon: Icon(Icons.spa), label: 'Sadhana'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ]));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const features = [
    ('Bhajan', Icons.music_note_rounded), ('Aarti', Icons.local_fire_department_rounded),
    ('Books', Icons.menu_book_rounded), ('Guru Vani', Icons.auto_stories_rounded),
    ('Pravachan', Icons.mic_rounded), ('Satsang', Icons.groups_rounded),
    ('Gallery', Icons.photo_library_rounded), ('Events', Icons.event_rounded),
  ];
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: paleGold, border: Border.all(color: champagne)),
          child: const Icon(Icons.temple_hindu_rounded, color: maroon, size: 28)),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Yog Yogeshwar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: maroon)),
          Text('Mahaprabhu Shree Ramlal Ji Maharaj', style: TextStyle(fontSize: 11, color: brown)),
        ])),
        IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentPage(category: 'Notifications', title: 'Announcements'))),
          icon: const Icon(Icons.notifications_none_rounded, color: brown)),
      ]))),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Container(height: 205, width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: champagne),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFFFF9ED), Color(0xFFEAD8B4), Color(0xFFFFFDF7)]),
          boxShadow: [BoxShadow(color: champagne.withValues(alpha: .16), blurRadius: 16, offset: const Offset(0, 5))]),
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.temple_hindu_rounded, size: 55, color: maroon), SizedBox(height: 12),
          Text('श्री महाप्रभु जी महाराज', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: maroon)),
          SizedBox(height: 8), Text('ॐ गुरवे नमः', style: TextStyle(fontSize: 20, color: brown, fontWeight: FontWeight.w600)),
          SizedBox(height: 7), Text('गुरु कृपा • भक्ति • साधना', style: TextStyle(color: brown, fontSize: 12)),
        ])))),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 15, 20, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('जय गुरुदेव 🙏', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: maroon)),
        SizedBox(height: 4), Text('A place for devotion, wisdom and inner peace', style: TextStyle(color: brown, fontSize: 13)),
        SizedBox(height: 20), Text('Explore', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: brown)),
      ]))),
    SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverGrid(
      delegate: SliverChildBuilderDelegate((context, i) {
        final item = features[i];
        return InkWell(borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            item.$1 == 'Events' ? const EventsPage() : ContentPage(category: item.$1, title: item.$1))),
          child: Container(decoration: BoxDecoration(color: cardWhite, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: paleGold), boxShadow: [BoxShadow(color: brown.withValues(alpha: .05), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 52, height: 52, decoration: const BoxDecoration(color: ivory, shape: BoxShape.circle),
                child: Icon(item.$2, color: champagne, size: 28)),
              const SizedBox(height: 10), Text(item.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: brown)),
            ])));
      }, childCount: features.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 13, crossAxisSpacing: 13, childAspectRatio: 1.25))),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFFFFF9ED), borderRadius: BorderRadius.circular(18), border: Border.all(color: paleGold)),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('आज की गुरु वाणी', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: maroon)),
        SizedBox(height: 10), Text('गुरु कृपा ही जीवन का सबसे बड़ा आधार है।', style: TextStyle(fontSize: 16, color: brown)),
        SizedBox(height: 6), Text('ॐ गुरवे नमः', style: TextStyle(fontSize: 12, color: champagne)),
      ])))),
    const SliverToBoxAdapter(child: SizedBox(height: 18)),
  ]);
}

class DarshanPage extends StatelessWidget {
  const DarshanPage({super.key});
  @override
  Widget build(BuildContext context) => const ContentPage(category: 'Gallery', title: 'Darshan & Gallery', embedded: true);
}
class MediaPage extends StatelessWidget {
  const MediaPage({super.key});
  @override
  Widget build(BuildContext context) => const ContentPage(category: 'Bhajan', title: 'Devotional Media', embedded: true);
}

class ContentPage extends StatefulWidget {
  final String category, title;
  final bool embedded;
  const ContentPage({super.key, required this.category, required this.title, this.embedded = false});
  @override
  State<ContentPage> createState() => _ContentPageState();
}
class _ContentPageState extends State<ContentPage> {
  String search = '';
  Future<List<Map<String, dynamic>>> load() async {
    if (!Supabase.instance.isInitialized) return [];
    final rows = await Supabase.instance.client.from('devotional_content').select()
      .eq('published', true).eq('category', widget.category).order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }
  @override
  Widget build(BuildContext context) {
    final content = Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: TextField(
        decoration: InputDecoration(hintText: 'Search ' + widget.title.toLowerCase() + '...', prefixIcon: const Icon(Icons.search),
          filled: true, fillColor: cardWhite, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
        onChanged: (v) => setState(() => search = v.toLowerCase()))),
      Expanded(child: FutureBuilder<List<Map<String, dynamic>>>(future: load(), builder: (context, snapshot) {
        if (!Supabase.instance.isInitialized) return const EmptyState(message: 'Content service is not connected yet.');
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: champagne));
        if (snapshot.hasError) return const EmptyState(message: 'Unable to load content. Please try again later.');
        final rows = (snapshot.data ?? []).where((e) => (e['title'] ?? '').toString().toLowerCase().contains(search)).toList();
        if (rows.isEmpty) return const EmptyState(message: 'New devotional content will appear here soon.');
        return ListView.separated(padding: const EdgeInsets.all(16), itemCount: rows.length, separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final item = rows[i];
            final imageUrl = (item['thumbnail_url'] ?? item['file_url'] ?? '').toString();
            final isGallery = widget.category.toLowerCase() == 'gallery';
            return Card(color: cardWhite, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: paleGold)),
              child: ListTile(
                leading: isGallery && imageUrl.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.circular(9), child: Image.network(imageUrl, width: 58, height: 58, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox(width: 58, height: 58, child: Icon(Icons.image_not_supported, color: champagne))))
                  : const Icon(Icons.play_circle_outline, color: maroon),
                title: Text((item['title'] ?? 'Devotional content').toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: brown)),
                subtitle: Text((item['description'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Icon(isGallery ? Icons.zoom_in : Icons.open_in_new, color: champagne),
                onTap: () => isGallery ? openGalleryImage(context, item) : openItem(context, item)));
          });
      })),
    ]);
    if (widget.embedded) return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 24, 20, 12), child: Align(alignment: Alignment.centerLeft,
        child: Text(widget.title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: maroon)))),
      Expanded(child: content)]);
    return Scaffold(appBar: AppBar(title: Text(widget.title)), body: content);
  }
}
void openGalleryImage(BuildContext context, Map<String, dynamic> item) {
  final link = (item['file_url'] ?? item['thumbnail_url'] ?? '').toString();
  if (link.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image is not available yet.')));
    return;
  }
  Navigator.push(context, MaterialPageRoute(builder: (_) => GalleryImagePage(
    imageUrl: link,
    title: (item['title'] ?? 'Guru Darshan').toString(),
  )));
}

class GalleryImagePage extends StatelessWidget {
  final String imageUrl, title;
  const GalleryImagePage({super.key, required this.imageUrl, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF211A18),
    appBar: AppBar(backgroundColor: const Color(0xFF211A18), foregroundColor: Colors.white, title: Text(title)),
    body: Center(child: InteractiveViewer(
      minScale: 0.7, maxScale: 4,
      child: Image.network(imageUrl, fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) => progress == null ? child :
          const Center(child: CircularProgressIndicator(color: champagne)),
        errorBuilder: (_, __, ___) => const Padding(padding: EdgeInsets.all(24),
          child: Text('Unable to load this image. Please check its image URL.', textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white))),
      ),
    )),
  );
}

Future<void> openItem(BuildContext context, Map<String, dynamic> item) async {
  final link = (item['file_url'] ?? '').toString();
  final uri = Uri.tryParse(link);
  if (uri == null || link.isEmpty || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content link is not available.')));
  }
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});
  Future<List<Map<String, dynamic>>> load() async {
    if (!Supabase.instance.isInitialized) return [];
    final data = await Supabase.instance.client.from('devotional_events').select().eq('published', true).order('event_date');
    return List<Map<String, dynamic>>.from(data);
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Events & Festivals')),
    body: FutureBuilder<List<Map<String, dynamic>>>(future: load(), builder: (context, snap) {
      if (!Supabase.instance.isInitialized) return const EmptyState(message: 'Events service is not connected yet.');
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: champagne));
      if (snap.hasError) return const EmptyState(message: 'Unable to load events right now.');
      final rows = snap.data ?? [];
      if (rows.isEmpty) return const EmptyState(message: 'Upcoming events will be announced here.');
      return ListView.builder(padding: const EdgeInsets.all(16), itemCount: rows.length, itemBuilder: (_, i) {
        final e = rows[i];
        return Card(color: cardWhite, child: ListTile(leading: const Icon(Icons.event, color: maroon),
          title: Text((e['title'] ?? '').toString()), subtitle: Text((e['event_date'] ?? '').toString() + ' • ' + (e['location'] ?? '').toString() + '\n' + (e['description'] ?? '').toString())));
      });
    }));
}

class SadhanaPage extends StatefulWidget {
  const SadhanaPage({super.key});
  @override
  State<SadhanaPage> createState() => _SadhanaPageState();
}
class _SadhanaPageState extends State<SadhanaPage> {
  Timer? timer;
  int minutes = 15, remaining = 900;
  bool running = false;
  final completed = <String>[];
  void choose(int m) { timer?.cancel(); setState(() { minutes = m; remaining = m * 60; running = false; }); }
  void start() {
    if (remaining == 0) choose(minutes);
    setState(() => running = true);
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (remaining <= 1) {
        t.cancel();
        setState(() { remaining = 0; running = false; completed.insert(0, DateTime.now().toString().substring(0, 16) + ' • ' + minutes.toString() + ' min'); });
      } else { setState(() => remaining--); }
    });
  }
  void reset() { timer?.cancel(); setState(() { running = false; remaining = minutes * 60; }); }
  String clock(int s) => (s ~/ 60).toString().padLeft(2, '0') + ':' + (s % 60).toString().padLeft(2, '0');
  @override
  void dispose() { timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Sadhana Timer')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: cardWhite, borderRadius: BorderRadius.circular(24), border: Border.all(color: paleGold)),
        child: Column(children: [
          const Text('ॐ गुरवे नमः', style: TextStyle(color: maroon, fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 22),
          SizedBox(width: 210, height: 210, child: Stack(fit: StackFit.expand, children: [
            CircularProgressIndicator(value: minutes == 0 ? 0 : remaining / (minutes * 60), strokeWidth: 9, backgroundColor: ivory, color: champagne),
            Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(clock(remaining), style: const TextStyle(fontSize: 43, fontWeight: FontWeight.bold, color: maroon)),
              const Text('TIME REMAINING', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: brown)),
            ]))])),
          const SizedBox(height: 22),
          Wrap(spacing: 8, children: [15, 30, 60, 120].map((m) => ChoiceChip(label: Text(m < 60 ? m.toString() + ' min' : (m ~/ 60).toString() + ' hr'),
            selected: minutes == m, onSelected: running ? null : (_) => choose(m), selectedColor: paleGold)).toList()),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FilledButton.icon(onPressed: running ? null : start, icon: const Icon(Icons.play_arrow), label: Text(running ? 'Running' : 'Start'), style: FilledButton.styleFrom(backgroundColor: maroon))),
            const SizedBox(width: 10), OutlinedButton.icon(onPressed: reset, icon: const Icon(Icons.stop), label: const Text('Reset')),
          ]),
        ])),
      const SizedBox(height: 22), const Text('Completed sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brown)),
      if (completed.isEmpty) const Padding(padding: EdgeInsets.only(top: 8), child: Text('Completed sessions will appear here during this app session.', style: TextStyle(color: brown)))
      else ...completed.map((s) => ListTile(leading: const Icon(Icons.check_circle_outline, color: champagne), title: Text(s))),
    ]));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Profile')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: cardWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: paleGold)),
        child: const Column(children: [
          CircleAvatar(radius: 38, backgroundColor: ivory, child: Icon(Icons.person, size: 42, color: maroon)),
          SizedBox(height: 12), Text('Welcome, Devotee', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: maroon)),
          SizedBox(height: 5), Text('ॐ गुरवे नमः', style: TextStyle(color: brown)),
        ])),
      const SizedBox(height: 18),
      ProfileTile(icon: Icons.favorite_outline, title: 'Favourites', subtitle: 'Your saved devotional items', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentPage(category: 'Favourites', title: 'Favourites')))),
      const ProfileTile(icon: Icons.info_outline, title: 'About the App', subtitle: 'Yog Yogeshwar Mahaprabhu Shree Ramlal Ji Maharaj'),
      const ProfileTile(icon: Icons.privacy_tip_outlined, title: 'Privacy', subtitle: 'Your practice is personal and private'),
      ProfileTile(icon: Icons.admin_panel_settings_outlined, title: 'Admin Login', subtitle: 'For authorised content administrators',
        onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Admin access'),
          content: const Text('Secure administrator sign-in will be enabled after server-side admin roles are connected.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]))),
    ]));
}
class ProfileTile extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback? onTap;
  const ProfileTile({super.key, required this.icon, required this.title, required this.subtitle, this.onTap});
  @override
  Widget build(BuildContext context) => Card(color: cardWhite, elevation: 0, child: ListTile(leading: Icon(icon, color: champagne),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: brown)), subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.menu_book_outlined, color: champagne, size: 48), const SizedBox(height: 14),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: brown, fontSize: 15)),
    ])));
}
