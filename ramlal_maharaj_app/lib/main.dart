import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfrx/pdfrx.dart';
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
  final category = (item['category'] ?? '').toString().toLowerCase();
  final title = (item['title'] ?? 'Devotional content').toString();
  final lower = link.toLowerCase().split('?').first;
  if (link.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content link is not available.')));
    return;
  }
  if (category == 'bhajan' || category == 'aarti' || category == 'audio' ||
      lower.endsWith('.mp3') || lower.endsWith('.m4a') || lower.endsWith('.aac') || lower.endsWith('.wav')) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerPage(url: link, title: title)));
    return;
  }
  if (category == 'books' || category == 'book' || lower.endsWith('.pdf')) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PdfReaderPage(url: link, title: title)));
    return;
  }
  final uri = Uri.tryParse(link);
  if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video link could not be opened.')));
  }
}

class AudioPlayerPage extends StatefulWidget {
  final String url, title;
  const AudioPlayerPage({super.key, required this.url, required this.title});
  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}
class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final player = AudioPlayer();
  String? error;
  @override
  void initState() {
    super.initState();
    player.setUrl(widget.url).then((_) {}, onError: (e) { if (mounted) setState(() => error = 'Unable to play this audio. Please check the media file.'); });
  }
  @override
  void dispose() { player.dispose(); super.dispose(); }
  String time(Duration? d) {
    if (d == null) return '--:--';
    final s = d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(widget.title)),
    body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.music_note_rounded, size: 100, color: champagne),
      const SizedBox(height: 20), Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: maroon)),
      const SizedBox(height: 30),
      if (error != null) Text(error!, style: const TextStyle(color: maroon))
      else StreamBuilder<Duration?>(stream: player.durationStream, builder: (context, durationSnap) =>
        StreamBuilder<Duration>(stream: player.positionStream, builder: (context, positionSnap) {
          final duration = durationSnap.data ?? Duration.zero;
          final position = positionSnap.data ?? Duration.zero;
          final max = duration.inMilliseconds.toDouble();
          return Column(children: [
            Slider(value: max <= 0 ? 0 : position.inMilliseconds.clamp(0, max).toDouble(), max: max <= 0 ? 1 : max,
              activeColor: maroon, onChanged: max <= 0 ? null : (v) => player.seek(Duration(milliseconds: v.round()))),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(time(position)), Text(time(duration))]),
          ]);
        })),
      const SizedBox(height: 22),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(iconSize: 38, onPressed: () => player.seek(Duration.zero), icon: const Icon(Icons.replay_10, color: brown)),
        StreamBuilder<PlayerState>(stream: player.playerStateStream, builder: (context, snap) {
          final playing = snap.data?.playing ?? false;
          return IconButton(iconSize: 66, color: maroon,
            onPressed: () => playing ? player.pause() : player.play(),
            icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_fill));
        }),
        IconButton(iconSize: 38, onPressed: () => player.seek(player.duration ?? Duration.zero), icon: const Icon(Icons.forward_10, color: brown)),
      ]),
    ])))));
}

class PdfReaderPage extends StatelessWidget {
  final String url, title;
  const PdfReaderPage({super.key, required this.url, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)),
    body: PdfViewer.uri(Uri.parse(url), params: const PdfViewerParams(enableTextSelection: true)));
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}
class _AdminLoginPageState extends State<AdminLoginPage> {
  final email = TextEditingController(), password = TextEditingController();
  bool busy = false, obscure = true;
  String? error;
  Future<void> signIn() async {
    if (!Supabase.instance.isInitialized) { setState(() => error = 'Secure sign-in service is not configured.'); return; }
    setState(() { busy = true; error = null; });
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(email: email.text.trim(), password: password.text);
      final role = response.user?.appMetadata['role']?.toString();
      if (role != 'admin' && role != 'super_admin') {
        await Supabase.instance.client.auth.signOut();
        throw Exception('This account is not authorised as an administrator.');
      }
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()));
    } catch (e) {
      if (mounted) setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Administrator Login')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      const Icon(Icons.admin_panel_settings, color: maroon, size: 64),
      const SizedBox(height: 16), const Text('Authorised administrators only', textAlign: TextAlign.center, style: TextStyle(color: brown)),
      const SizedBox(height: 24),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined))),
      const SizedBox(height: 12),
      TextField(controller: password, obscureText: obscure, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)))),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
      const SizedBox(height: 20),
      FilledButton(onPressed: busy ? null : signIn, style: FilledButton.styleFrom(backgroundColor: maroon),
        child: Text(busy ? 'Signing in...' : 'Secure Login')),
    ]));
}

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});
  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}
class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool busy = false;
  final title = TextEditingController(), description = TextEditingController();
  String category = 'Bhajan';
  final categories = const ['Bhajan','Aarti','Books','Guru Vani','Pravachan','Satsang','Gallery','Notifications'];
  Future<void> upload() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final role = user?.appMetadata['role']?.toString();
    if (role != 'admin' && role != 'super_admin') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Administrator permission required.')));
      return;
    }
    if (title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title.')));
      return;
    }
    final picked = await FilePicker.platform.pickFiles(withData: true, type: FileType.any);
    if (picked == null || picked.files.single.bytes == null) return;
    setState(() => busy = true);
    try {
      final file = picked.files.single;
      final path = 'uploads/${DateTime.now().millisecondsSinceEpoch}_${file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
      await client.storage.from('prabhu').uploadBinary(path, file.bytes!,
        fileOptions: FileOptions(upsert: false, contentType: file.extension == 'pdf' ? 'application/pdf' : null));
      final url = client.storage.from('prabhu').getPublicUrl(path);
      await client.from('devotional_content').insert({
        'title': title.text.trim(), 'category': category, 'description': description.text.trim(),
        'file_url': url, 'thumbnail_url': category == 'Gallery' ? url : null, 'published': true,
      });
      title.clear(); description.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content uploaded and published.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${e.toString()}')));
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override
  void dispose() { title.dispose(); description.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Admin Dashboard'), actions: [
    IconButton(tooltip: 'Sign out', onPressed: () async { await Supabase.instance.client.auth.signOut(); if (context.mounted) Navigator.pop(context); }, icon: const Icon(Icons.logout))
  ]), body: ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Manage devotional content', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: maroon)),
    const SizedBox(height: 8), const Text('Upload photos, audio, PDFs and video links. Published items appear in the app.', style: TextStyle(color: brown)),
    const SizedBox(height: 20),
    TextField(controller: title, decoration: const InputDecoration(labelText: 'Content title')),
    const SizedBox(height: 12),
    TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
    const SizedBox(height: 12),
    DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Category'),
      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: busy ? null : (v) { if (v != null) setState(() => category = v); }),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: busy ? null : upload, icon: const Icon(Icons.cloud_upload), label: Text(busy ? 'Uploading...' : 'Choose file & publish'),
      style: FilledButton.styleFrom(backgroundColor: maroon)),
    const SizedBox(height: 12),
    const Text('Security note: administrator rights are verified from the signed-in account role and enforced again by Supabase Row Level Security.', style: TextStyle(fontSize: 12, color: brown)),
  ]));
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

  void choose(int m) {
    timer?.cancel();
    setState(() { minutes = m; remaining = m * 60; running = false; });
  }

  Future<void> chooseCustomDuration() async {
    final controller = TextEditingController();
    final value = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Custom Sadhana Timer'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Duration in minutes',
            hintText: 'For example, 45',
            helperText: 'Enter 1 to 1440 minutes (up to 24 hours)',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text.trim());
              if (parsed == null || parsed < 1 || parsed > 1440) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please enter 1 to 1440 minutes.')),
                );
                return;
              }
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('Set Timer'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null && mounted) choose(value);
  }

  void startOrPause() {
    if (running) {
      timer?.cancel();
      setState(() => running = false);
      return;
    }
    if (remaining <= 0) remaining = minutes * 60;
    setState(() => running = true);
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (remaining <= 1) {
        t.cancel();
        setState(() {
          remaining = 0;
          running = false;
          completed.insert(0, DateTime.now().toString().substring(0, 16) + ' • ' + minutes.toString() + ' min');
        });
      } else {
        setState(() => remaining--);
      }
    });
  }

  void reset() {
    timer?.cancel();
    setState(() { running = false; remaining = minutes * 60; });
  }

  String clock(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) return h.toString().padLeft(2, '0') + ':' + m.toString().padLeft(2, '0') + ':' + sec.toString().padLeft(2, '0');
    return m.toString().padLeft(2, '0') + ':' + sec.toString().padLeft(2, '0');
  }

  String durationLabel(int m) => m < 60 ? '$m min' : (m % 60 == 0 ? '${m ~/ 60} hr' : '${m ~/ 60} hr ${m % 60} min');

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sadhana Timer')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: cardWhite, borderRadius: BorderRadius.circular(24), border: Border.all(color: paleGold)),
        child: Column(children: [
          const Text('ॐ गुरवे नमः', style: TextStyle(color: maroon, fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 22),
          SizedBox(width: 210, height: 210, child: Stack(fit: StackFit.expand, children: [
            CircularProgressIndicator(
              value: minutes == 0 ? 0 : remaining / (minutes * 60),
              strokeWidth: 9, backgroundColor: ivory, color: champagne,
            ),
            Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(clock(remaining), style: const TextStyle(fontSize: 39, fontWeight: FontWeight.bold, color: maroon)),
              const Text('TIME REMAINING', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: brown)),
            ])),
          ])),
          const SizedBox(height: 22),
          const Align(alignment: Alignment.centerLeft, child: Text('Choose duration', style: TextStyle(fontWeight: FontWeight.w600, color: brown))),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ...[15, 30, 60, 120].map((m) => ChoiceChip(
              label: Text(durationLabel(m)),
              selected: minutes == m,
              onSelected: running ? null : (_) => choose(m),
              selectedColor: paleGold,
            )),
            ActionChip(
              avatar: const Icon(Icons.edit, size: 17, color: maroon),
              label: Text(minutes == 15 || minutes == 30 || minutes == 60 || minutes == 120 ? 'Custom' : durationLabel(minutes)),
              backgroundColor: (minutes == 15 || minutes == 30 || minutes == 60 || minutes == 120) ? ivory : paleGold,
              onPressed: running ? null : chooseCustomDuration,
            ),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: FilledButton.icon(
              onPressed: startOrPause,
              icon: Icon(running ? Icons.pause : Icons.play_arrow),
              label: Text(running ? 'Pause' : remaining == minutes * 60 ? 'Start' : 'Resume'),
              style: FilledButton.styleFrom(backgroundColor: maroon),
            )),
            const SizedBox(width: 10),
            OutlinedButton.icon(onPressed: reset, icon: const Icon(Icons.stop), label: const Text('Reset')),
          ]),
        ]),
      ),
      const SizedBox(height: 22),
      const Text('Completed sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brown)),
      if (completed.isEmpty)
        const Padding(padding: EdgeInsets.only(top: 8), child: Text('Completed sessions will appear here during this app session.', style: TextStyle(color: brown)))
      else
        ...completed.map((s) => ListTile(leading: const Icon(Icons.check_circle_outline, color: champagne), title: Text(s))),
    ]),
  );
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
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginPage()))),
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
