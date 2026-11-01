import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    home: const WelcomeGate());
}

class WelcomeGate extends StatelessWidget {
  const WelcomeGate({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 112, height: 112, decoration: BoxDecoration(shape: BoxShape.circle, color: paleGold, border: Border.all(color: champagne, width: 2)),
          child: const Icon(Icons.temple_hindu_rounded, color: maroon, size: 66)),
        const SizedBox(height: 26),
        const Text('जय गुरुदेव 🙏', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: maroon)),
        const SizedBox(height: 10),
        const Text('Yog Yogeshwar Mahaprabhu', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: brown)),
        const Text('Shree Ramlal Ji Maharaj', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: brown)),
        const SizedBox(height: 12),
        const Text('ॐ गुरवे नमः', style: TextStyle(fontSize: 22, color: champagne, fontWeight: FontWeight.w600)),
        const SizedBox(height: 34),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevoteeAuthPage())),
          icon: const Icon(Icons.login), label: const Text('Login / Create Account'),
          style: FilledButton.styleFrom(backgroundColor: maroon, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginPage())),
          style: OutlinedButton.styleFrom(foregroundColor: maroon, side: const BorderSide(color: champagne), padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text('Administrator Login'))),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 66,
          child: FilledButton.icon(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen())),
            icon: const Icon(Icons.arrow_forward_rounded, size: 26),
            label: const Text('SKIP FOR NOW  •  CONTINUE AS GUEST',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: .3)),
            style: FilledButton.styleFrom(
              backgroundColor: champagne,
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('You can use the app without an account. Sign in is optional.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: brown)),
      ]),
    ))),
  );
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
  Set<String> favouriteIds = {};
  @override
  void initState() { super.initState(); _loadFavouriteIds(); }
  Future<void> _loadFavouriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => favouriteIds = (prefs.getStringList('favourite_content_ids') ?? []).toSet());
  }
  Future<void> _toggleFavourite(Map<String, dynamic> item) async {
    final id = (item['id'] ?? '').toString();
    if (id.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favourite_content') ?? [];
    final entries = saved.map((v) {
      try { return Map<String, dynamic>.from(jsonDecode(v)); } catch (_) { return <String, dynamic>{}; }
    }).where((e) => e['id'] != null).toList();
    if (entries.any((e) => e['id'].toString() == id)) {
      entries.removeWhere((e) => e['id'].toString() == id);
    } else { entries.add(Map<String, dynamic>.from(item)); }
    await prefs.setStringList('favourite_content', entries.map((e) => jsonEncode(e)).toList());
    final ids = entries.map((e) => e['id'].toString()).toSet();
    await prefs.setStringList('favourite_content_ids', ids.toList());
    if (mounted) setState(() => favouriteIds = ids);
  }
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
                  : Icon(
                      (item['file_url'] ?? '').toString().toLowerCase().split('?').first.endsWith('.pdf')
                          ? Icons.picture_as_pdf_outlined
                          : Icons.play_circle_outline,
                      color: maroon,
                    ),
                title: isGallery ? const SizedBox.shrink() : Text((item['title'] ?? 'Devotional content').toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: brown)),
                subtitle: Text((item['description'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: isGallery ? const Icon(Icons.zoom_in, color: champagne) : Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    tooltip: favouriteIds.contains((item['id'] ?? '').toString()) ? 'Remove from favourites' : 'Add to favourites',
                    onPressed: () => _toggleFavourite(item),
                    icon: Icon(favouriteIds.contains((item['id'] ?? '').toString()) ? Icons.favorite : Icons.favorite_border, color: maroon),
                  ),
                  const Icon(Icons.open_in_new, color: champagne),
                ]),
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
    title: '',
  )));
}

class GalleryImagePage extends StatelessWidget {
  final String imageUrl, title;
  const GalleryImagePage({super.key, required this.imageUrl, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF211A18),
    appBar: AppBar(backgroundColor: const Color(0xFF211A18), foregroundColor: Colors.white, title: title.isEmpty ? null : Text(title)),
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
  // Detect the actual file format before the devotional category. An Aarti
  // entry may be a PDF booklet, not an audio track.
  if (lower.endsWith('.pdf') || category == 'books' || category == 'book') {
    Navigator.push(context, MaterialPageRoute(builder: (_) => PdfReaderPage(url: link, title: title)));
    return;
  }
  if (category == 'bhajan' || category == 'aarti' || category == 'audio' ||
      lower.endsWith('.mp3') || lower.endsWith('.m4a') || lower.endsWith('.aac') || lower.endsWith('.wav')) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerPage(url: link, title: title)));
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
    ]))));
}

class PdfReaderPage extends StatelessWidget {
  final String url, title;
  const PdfReaderPage({super.key, required this.url, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)),
    body: PdfViewer.uri(Uri.parse(url)));
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
  final categories = const ['Bhajan','Aarti','Books','Guru Vani','Pravachan','Satsang','Gallery','Sadhana Music','Notifications'];

  Future<void> upload() async {
    final client = Supabase.instance.client;
    final role = client.auth.currentUser?.appMetadata['role']?.toString();
    if (role != 'admin' && role != 'super_admin') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Administrator permission required.')));
      return;
    }
    if (category != 'Gallery' && title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a content title.')));
      return;
    }
    final picked = await FilePicker.platform.pickFiles(withData: true, type: FileType.any);
    if (picked == null || picked.files.single.bytes == null || !mounted) return;
    setState(() => busy = true);
    try {
      final file = picked.files.single;
      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final storagePath = 'uploads/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      await client.storage.from('prabhu').uploadBinary(storagePath, file.bytes!, fileOptions: FileOptions(upsert: false));
      final url = client.storage.from('prabhu').getPublicUrl(storagePath);
      await client.from('devotional_content').insert({
        'title': category == 'Gallery' ? '' : (title.text.trim().isEmpty ? file.name : title.text.trim()),
        'category': category, 'description': description.text.trim(), 'file_url': url,
        'thumbnail_url': category == 'Gallery' ? url : null, 'published': true,
      });
      title.clear(); description.clear();
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content uploaded and published.'))); setState(() {}); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally { if (mounted) setState(() => busy = false); }
  }

  Future<List<Map<String, dynamic>>> loadManagedContent() async {
    final rows = await Supabase.instance.client.from('devotional_content').select('id,title,category,file_url,created_at,published').order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }


  Future<void> previewContent(Map<String, dynamic> item) async {
    final category = (item['category'] ?? '').toString().toLowerCase();
    final url = (item['file_url'] ?? '').toString();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preview is not available for this item.')));
      return;
    }
    if (category == 'gallery' || _isImageUrl(url)) {
      openGalleryImage(context, item);
      return;
    }
    if (category == 'books' || url.toLowerCase().split('?').first.endsWith('.pdf')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PdfReaderPage(url: url, title: (item['title'] ?? 'PDF Preview').toString())));
      return;
    }
    if (category == 'bhajan' || category == 'aarti' || category == 'audio' || category == 'sadhana music' ||
        RegExp(r'\.(mp3|m4a|aac|wav|ogg)(\?|$)', caseSensitive: false).hasMatch(url)) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerPage(url: url, title: (item['title'] ?? 'Audio Preview').toString())));
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    if (mounted) {
      showDialog<void>(context: context, builder: (_) => AlertDialog(
        title: const Text('File details'),
        content: Text('Category: ${item['category'] ?? 'Other'}\\nFile URL: $url'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ));
    }
  }

  bool _isImageUrl(String url) => RegExp(r'\.(png|jpe?g|webp|gif)(\?|$)', caseSensitive: false).hasMatch(url);

  Future<void> removeContent(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id == null) return;
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Remove media?'), content: const Text('This item will be removed from the app.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Remove')),
      ],
    ));
    if (confirmed != true || !mounted) return;
    setState(() => busy = true);
    try {
      final client = Supabase.instance.client;
      final fileUrl = (item['file_url'] ?? '').toString();
      const marker = '/storage/v1/object/public/prabhu/';
      final markerIndex = fileUrl.indexOf(marker);
      if (markerIndex >= 0) {
        final storagePath = Uri.decodeComponent(fileUrl.substring(markerIndex + marker.length));
        await client.storage.from('prabhu').remove([storagePath]);
      }
      await client.from('devotional_content').delete().eq('id', id);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Media removed.'))); setState(() {}); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not remove media: $e')));
    } finally { if (mounted) setState(() => busy = false); }
  }

  @override
  void dispose() { title.dispose(); description.dispose(); super.dispose(); }

  Widget uploadTab() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Upload devotional content', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: maroon)),
    const SizedBox(height: 8), const Text('Upload photos, bhajans, aarti, books and other devotional media.', style: TextStyle(color: brown)),
    const SizedBox(height: 20),
    DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Content category'),
      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: busy ? null : (v) { if (v != null) setState(() => category = v); }),
    const SizedBox(height: 12),
    if (category == 'Gallery') const Text('Photos are uploaded without displaying their file names.', style: TextStyle(color: brown))
    else TextField(controller: title, decoration: const InputDecoration(labelText: 'Content title')),
    const SizedBox(height: 12),
    TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description (optional)')),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: busy ? null : upload, icon: const Icon(Icons.cloud_upload), label: Text(busy ? 'Uploading...' : 'Choose file & publish'), style: FilledButton.styleFrom(backgroundColor: maroon)),  ]);

  Widget manageTab() => FutureBuilder<List<Map<String, dynamic>>>(future: loadManagedContent(), builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: champagne));
    if (snapshot.hasError) return Center(child: Text('Unable to load media: ${snapshot.error}'));
    final rows = snapshot.data ?? [];
    if (rows.isEmpty) return const Center(child: Text('No uploaded media yet.'));
    return RefreshIndicator(onRefresh: () async { setState(() {}); }, child: ListView.separated(
      padding: const EdgeInsets.all(16), itemCount: rows.length, separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = rows[index]; final photo = item['category'] == 'Gallery';
        final created = (item['created_at'] ?? '').toString();
        return Card(color: cardWhite, child: ListTile(
          leading: Icon(photo ? Icons.image : Icons.perm_media, color: champagne),
          title: Text(photo ? 'Photo' : (item['title'] ?? 'Untitled').toString()),
          subtitle: Text((item['category'] ?? 'Media').toString() + (created.isEmpty ? '' : ' • ' + created.split('T').first)),
          trailing: Wrap( spacing: 0, children: [
            IconButton(tooltip: 'Preview', icon: const Icon(Icons.visibility_outlined, color: maroon), onPressed: () => previewContent(item)),
            IconButton(tooltip: 'Remove media', icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: busy ? null : () => removeContent(item)),
          ]),
        ));
      },
    ));
  });

  @override
  Widget build(BuildContext context) => DefaultTabController(length: 3, child: Scaffold(
    appBar: AppBar(title: const Text('Admin Portal'), actions: [
      IconButton(tooltip: 'Sign out', onPressed: () async { await Supabase.instance.client.auth.signOut(); if (context.mounted) Navigator.pop(context); }, icon: const Icon(Icons.logout)),
    ], bottom: const TabBar(tabs: [
      Tab(icon: Icon(Icons.cloud_upload_outlined), text: 'Upload'),
      Tab(icon: Icon(Icons.library_music_outlined), text: 'Manage Media'),
      Tab(icon: Icon(Icons.event_outlined), text: 'Events'),
    ])),
    body: TabBarView(children: [uploadTab(), manageTab(), const EventsAdminPage()]),
  ));
}

class EventsAdminPage extends StatefulWidget {
  const EventsAdminPage({super.key});
  @override
  State<EventsAdminPage> createState() => _EventsAdminPageState();
}
class _EventsAdminPageState extends State<EventsAdminPage> {
  Future<List<Map<String, dynamic>>> load() async {
    final rows = await Supabase.instance.client.from('devotional_events').select().order('event_date');
    return List<Map<String, dynamic>>.from(rows);
  }
  Future<void> editEvent([Map<String, dynamic>? event]) async {
    final title = TextEditingController(text: (event?['title'] ?? '').toString());
    final description = TextEditingController(text: (event?['description'] ?? '').toString());
    final location = TextEditingController(text: (event?['location'] ?? '').toString());
    DateTime selectedDate = DateTime.tryParse((event?['event_date'] ?? '').toString()) ?? DateTime.now();
    bool published = event?['published'] == true;
    final result = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(event == null ? 'Add event' : 'Edit event'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Event title')),
          TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: location, decoration: const InputDecoration(labelText: 'Location')),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(context: dialogContext, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (picked != null) setDialogState(() => selectedDate = picked);
            },
            icon: const Icon(Icons.calendar_month),
            label: Text('${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'),
          ),
          SwitchListTile(title: const Text('Published'), value: published, onChanged: (v) => setDialogState(() => published = v)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () {
            if (title.text.trim().isEmpty) {
              ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Enter an event title.')));
              return;
            }
            Navigator.pop(dialogContext, true);
          }, child: const Text('Save')),
        ],
      ),
    ));
    if (result == true && mounted) {
      try {
        final data = {
          'title': title.text.trim(), 'description': description.text.trim(), 'location': location.text.trim(),
          'event_date': '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
          'published': published,
        };
        if (event == null) {
          await Supabase.instance.client.from('devotional_events').insert(data);
        } else {
          await Supabase.instance.client.from('devotional_events').update(data).eq('id', event['id']);
        }
        if (mounted) { setState(() {}); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event saved.'))); }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save event: $e')));
      }
    }
    title.dispose(); description.dispose(); location.dispose();
  }
  Future<void> deleteEvent(Map<String, dynamic> event) async {
    final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete event?'),
      content: Text('Remove "${event['title'] ?? 'this event'}" from the events list?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
      ],
    ));
    if (yes != true) return;
    try {
      await Supabase.instance.client.from('devotional_events').delete().eq('id', event['id']);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not delete event: $e')));
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(backgroundColor: maroon, foregroundColor: Colors.white,
      onPressed: () => editEvent(), icon: const Icon(Icons.add), label: const Text('Add event')),
    body: FutureBuilder<List<Map<String, dynamic>>>(future: load(), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: champagne));
      if (snapshot.hasError) return Center(child: Text('Unable to load events: ${snapshot.error}'));
      final rows = snapshot.data ?? [];
      if (rows.isEmpty) return const EmptyState(message: 'No events have been added yet. Tap Add event to create one.');
      return RefreshIndicator(onRefresh: () async { setState(() {}); }, child: ListView.builder(
        padding: const EdgeInsets.all(12), itemCount: rows.length, itemBuilder: (context, i) {
          final e = rows[i];
          return Card(color: cardWhite, child: ListTile(
            leading: const Icon(Icons.event, color: champagne),
            title: Text((e['title'] ?? '').toString(), style: const TextStyle(color: brown)),
            subtitle: Text('${e['event_date'] ?? ''} • ${e['published'] == true ? 'Published' : 'Draft'}'),
            trailing: Wrap( children: [
              IconButton(tooltip: 'Edit event', icon: const Icon(Icons.edit_outlined, color: maroon), onPressed: () => editEvent(e)),
              IconButton(tooltip: 'Delete event', icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => deleteEvent(e)),
            ]),
          ));
        },
      ));
    }),
  );
}

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});
  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}
class _FavouritesPageState extends State<FavouritesPage> {
  Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('favourite_content') ?? [];
    return saved.map((v) {
      try { return Map<String, dynamic>.from(jsonDecode(v)); } catch (_) { return <String, dynamic>{}; }
    }).where((e) => e.isNotEmpty).toList().reversed.toList();
  }
  Future<void> remove(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final id = (item['id'] ?? '').toString();
    final saved = prefs.getStringList('favourite_content') ?? [];
    final entries = saved.map((v) {
      try { return Map<String, dynamic>.from(jsonDecode(v)); } catch (_) { return <String, dynamic>{}; }
    }).where((e) => e.isNotEmpty && (e['id'] ?? '').toString() != id).toList();
    await prefs.setStringList('favourite_content', entries.map((e) => jsonEncode(e)).toList());
    await prefs.setStringList('favourite_content_ids', entries.map((e) => e['id'].toString()).toList());
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Favourites')),
    body: FutureBuilder<List<Map<String, dynamic>>>(future: load(), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: champagne));
      final rows = snapshot.data ?? [];
      if (rows.isEmpty) return const EmptyState(message: 'Your saved devotional items will appear here.');
      return ListView.separated(padding: const EdgeInsets.all(16), itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8), itemBuilder: (context, i) {
          final item = rows[i]; final category = (item['category'] ?? 'Media').toString();
          final gallery = category.toLowerCase() == 'gallery';
          return Card(color: cardWhite, child: ListTile(
            leading: Icon(gallery ? Icons.image_outlined : Icons.play_circle_outline, color: champagne),
            title: Text(gallery ? 'Photo' : (item['title'] ?? 'Devotional content').toString(), style: const TextStyle(color: brown)),
            subtitle: Text(category),
            onTap: () => gallery ? openGalleryImage(context, item) : openItem(context, item),
            trailing: IconButton(tooltip: 'Remove from favourites', icon: const Icon(Icons.favorite, color: maroon), onPressed: () => remove(item)),
          ));
        });
    }),
  );
}

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});
  Future<List<Map<String, dynamic>>> load() async {
    if (!Supabase.instance.isInitialized) return [];    final data = await Supabase.instance.client.from('devotional_events').select().eq('published', true).order('event_date');
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
  AudioPlayer? completionPlayer;
  int minutes = 15, remaining = 900;
  bool running = false, musicPlaying = false;
  String? completionMusicUrl;
  final completed = <String>[];

  Future<void> _loadCompletedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('sadhana_completed_sessions') ?? [];
    if (mounted) setState(() { completed..clear()..addAll(saved); });
  }

  Future<void> _saveCompletedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('sadhana_completed_sessions', completed);
  }

  @override
  void initState() {
    super.initState();
    _loadCompletedSessions();
    loadCompletionMusic();
  }

  Future<void> loadCompletionMusic() async {
    if (!Supabase.instance.isInitialized) return;
    try {
      final rows = await Supabase.instance.client.from('devotional_content')
        .select('file_url').eq('published', true).eq('category', 'Sadhana Music')
        .order('created_at', ascending: false).limit(1);
      if (rows.isNotEmpty && mounted) setState(() => completionMusicUrl = rows.first['file_url']?.toString());
    } catch (_) {}
  }

  Future<void> playCompletionMusic() async {
    final url = completionMusicUrl;
    if (url == null || url.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ask an admin to upload the Sadhana completion music.')));
      return;
    }
    try {
      await completionPlayer?.stop();
      completionPlayer ??= AudioPlayer();
      await completionPlayer!.setLoopMode(LoopMode.off);
      await completionPlayer!.setUrl(url);
      await completionPlayer!.play();
      if (mounted) setState(() => musicPlaying = true);
      completionPlayer!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed && mounted) setState(() => musicPlaying = false);
      });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to play the Sadhana completion music.')));
    }
  }

  Future<void> stopCompletionMusic() async {
    await completionPlayer?.stop();
    if (mounted) setState(() => musicPlaying = false);
  }

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
        HapticFeedback.vibrate();
        _saveCompletedSessions();
        playCompletionMusic();
      } else {
        setState(() => remaining--);
      }
    });
  }

  void reset() {
    timer?.cancel();
    stopCompletionMusic();
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
  void dispose() { timer?.cancel(); completionPlayer?.dispose(); super.dispose(); }

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
          if (musicPlaying) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: stopCompletionMusic,
              icon: const Icon(Icons.music_off),
              label: const Text('Stop Music'),
            )),
          ],
          Row(children: [
            Expanded(child: FilledButton.icon(
              onPressed: startOrPause,
              icon: Icon(running ? Icons.pause : Icons.play_arrow),
              label: Text(running ? 'Pause' : remaining == minutes * 60 ? 'Start' : 'Resume'),
              style: FilledButton.styleFrom(backgroundColor: maroon),
            )),
            const SizedBox(width: 10),
            OutlinedButton.icon(onPressed: reset, icon: const Icon(Icons.stop),
              label: Text(musicPlaying ? 'Stop Timer & Music' : 'Stop Timer')),
          ]),
        ]),
      ),
      const SizedBox(height: 22),
      const Text('Completed sessions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brown)),
      if (completed.isEmpty)
        const Padding(padding: EdgeInsets.only(top: 8), child: Text('Your completed sessions are saved on this device.', style: TextStyle(color: brown)))
      else
        ...completed.map((s) => ListTile(leading: const Icon(Icons.check_circle_outline, color: champagne), title: Text(s))),
    ]),
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.isInitialized ? Supabase.instance.client : null;
    final user = client?.auth.currentUser;
    final role = user?.appMetadata['role']?.toString();
    final isAdmin = role == 'admin' || role == 'super_admin';
    return Scaffold(appBar: AppBar(title: const Text('Profile')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: cardWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: paleGold)),
          child: Column(children: [
            const CircleAvatar(radius: 38, backgroundColor: ivory, child: Icon(Icons.person, size: 42, color: maroon)),
            const SizedBox(height: 12),
            Text(user?.email ?? 'Welcome, Devotee', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: maroon)),
            const SizedBox(height: 5),
            Text(user == null ? 'Guest access' : (isAdmin ? (role == 'super_admin' ? 'Super Administrator' : 'Administrator') : 'Devotee account'), style: const TextStyle(color: brown)),
            const SizedBox(height: 5), const Text('ॐ गुरवे नमः', style: TextStyle(color: brown)),
          ])),
        const SizedBox(height: 18),
        if (user == null)
          ProfileTile(icon: Icons.login, title: 'Devotee Login / Sign Up', subtitle: 'Sign in or create a free account', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevoteeAuthPage()))),
        if (user != null)
          ProfileTile(icon: Icons.logout, title: 'Sign Out', subtitle: 'Sign out of this account', onTap: () async {
            await client!.auth.signOut();
            if (mounted) setState(() {});
          }),
        ProfileTile(icon: Icons.favorite_outline, title: 'Favourites', subtitle: 'Your saved devotional items', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavouritesPage()))),
        const ProfileTile(icon: Icons.info_outline, title: 'About the App', subtitle: 'Yog Yogeshwar Mahaprabhu Shree Ramlal Ji Maharaj'),
        const ProfileTile(icon: Icons.privacy_tip_outlined, title: 'Privacy', subtitle: 'Your practice is personal and private'),
        if (isAdmin)
          ProfileTile(icon: Icons.admin_panel_settings_outlined, title: 'Open Admin Portal', subtitle: 'Manage devotional content and events', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()))),
        if (user == null)
          ProfileTile(icon: Icons.admin_panel_settings_outlined, title: 'Admin Login', subtitle: 'For authorised content administrators', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminLoginPage()))),
      ]));
  }
}

class DevoteeAuthPage extends StatefulWidget {
  const DevoteeAuthPage({super.key});
  @override
  State<DevoteeAuthPage> createState() => _DevoteeAuthPageState();
}
class _DevoteeAuthPageState extends State<DevoteeAuthPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool creating = false, busy = false, obscure = true;
  String? message, error;

  Future<void> signInWithGoogle() async {
    if (!Supabase.instance.isInitialized) {
      setState(() => error = 'Account service is not configured yet.');
      return;
    }
    setState(() { busy = true; error = null; message = null; });
    try {
      final google = GoogleSignIn.instance;
      await google.initialize(
        serverClientId: '735985536071-n2bvs0k7g3pvv2skln78r6spmpf9nb6k.apps.googleusercontent.com',
      );
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Google did not return an ID token. Check Google sign-in configuration.');
      }
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (e) {
      // Surface the actual platform/Supabase error so configuration failures can be diagnosed.
      if (mounted) setState(() => error = 'Google sign-in failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submit() async {
    if (!Supabase.instance.isInitialized) {
      setState(() => error = 'Account service is not configured yet.');
      return;
    }
    if (email.text.trim().isEmpty || password.text.length < 6) {
      setState(() => error = 'Enter a valid email and a password with at least 6 characters.');
      return;
    }
    setState(() { busy = true; error = null; message = null; });
    try {
      final auth = Supabase.instance.client.auth;
      if (creating) {
        final result = await auth.signUp(email: email.text.trim(), password: password.text);
        if (result.session == null) {
          setState(() => message = 'Account created. Please verify your email, then sign in.');
        } else if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
        }
      } else {
        await auth.signInWithPassword(email: email.text.trim(), password: password.text);
        if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'Unable to complete sign-in. Please try again.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resetPassword() async {
    if (!Supabase.instance.isInitialized || email.text.trim().isEmpty) {
      setState(() => error = 'Enter your email address first.');
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email.text.trim());
      if (mounted) setState(() => message = 'Password reset email requested. Check your inbox.');
    } on AuthException catch (e) {
      if (mounted) setState(() => error = e.message);
    }
  }

  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(creating ? 'Create Devotee Account' : 'Devotee Login')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      const Icon(Icons.self_improvement, color: maroon, size: 64),
      const SizedBox(height: 12),
      const Text('Your devotional journey', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: maroon)),
      const SizedBox(height: 22),
      SizedBox(width: double.infinity, height: 54, child: OutlinedButton.icon(
        onPressed: busy ? null : signInWithGoogle,
        icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
        label: const Text('Continue with Google', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(foregroundColor: brown, side: const BorderSide(color: paleGold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
      const SizedBox(height: 18),
      const Row(children: [
        Expanded(child: Divider(color: paleGold)),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(color: brown))),
        Expanded(child: Divider(color: paleGold)),
      ]),
      const SizedBox(height: 12),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.email_outlined))),
      const SizedBox(height: 12),
      TextField(controller: password, obscureText: obscure, decoration: InputDecoration(labelText: 'Password (minimum 6 characters)', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)))),
      if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
      if (message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(message!, style: const TextStyle(color: brown))),
      const SizedBox(height: 18),
      FilledButton(onPressed: busy ? null : submit, style: FilledButton.styleFrom(backgroundColor: maroon), child: Text(busy ? 'Please wait...' : (creating ? 'Create Free Account' : 'Sign In'))),
      if (!creating) TextButton(onPressed: busy ? null : resetPassword, child: const Text('Forgot password?')),
      TextButton(onPressed: busy ? null : () => setState(() { creating = !creating; error = null; message = null; }), child: Text(creating ? 'Already have an account? Sign in' : 'New here? Create a free account')),
      const SizedBox(height: 8),
      const Text('You can continue using the app as a guest without creating an account. Phone/SMS OTP sign-in is not used.', textAlign: TextAlign.center, style: TextStyle(color: brown, fontSize: 12)),
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