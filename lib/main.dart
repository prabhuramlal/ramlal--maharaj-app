import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'firebase_options.dart';

const ivory = Color(0xFFF8F3E8);
const champagne = Color(0xFFC6A15B);
const maroon = Color(0xFF6B2638);
const brown = Color(0xFF704B2B);
const cardWhite = Color(0xFFFFFEFA);
const paleGold = Color(0xFFE9D9B8);

final FlutterLocalNotificationsPlugin sadhanaNotifications = FlutterLocalNotificationsPlugin();
const int sadhanaAlarmNotificationId = 707;
final ValueNotifier<bool> appHindi = ValueNotifier<bool>(false);
String get currentDisplayName { final u = Supabase.instance.isInitialized ? Supabase.instance.client.auth.currentUser : null; final n = u?.userMetadata?['full_name']?.toString().trim(); return (n == null || n.isEmpty) ? 'Devotee' : n; }
final GlobalKey<ScaffoldMessengerState> appMessengerKey = GlobalKey<ScaffoldMessengerState>();
String appText(String english, String hindi) => appHindi.value ? hindi : english;

Future<void> initializeSadhanaNotifications() async {
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  const settings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));
  await sadhanaNotifications.initialize(settings);
  const channel = AndroidNotificationChannel('sadhana_completion_bell', 'Sadhana completion bell', description: 'Temple bell when Sadhana finishes', importance: Importance.max, sound: RawResourceAndroidNotificationSound('temple_bell'), playSound: true);
  await sadhanaNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
}

Future<void> scheduleSadhanaBell(DateTime endAt) async {
  final android = sadhanaNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await android?.requestNotificationsPermission();
  await android?.requestExactAlarmsPermission();
  const details = NotificationDetails(android: AndroidNotificationDetails('sadhana_completion_bell', 'Sadhana completion bell', channelDescription: 'Temple bell when Sadhana finishes', importance: Importance.max, priority: Priority.max, playSound: true, sound: RawResourceAndroidNotificationSound('temple_bell')));
  await sadhanaNotifications.zonedSchedule(sadhanaAlarmNotificationId, 'Sadhana completed', 'Your meditation session is complete. जय गुरुदेव 🙏', tz.TZDateTime.from(endAt, tz.local), details, androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await initializeSadhanaNotifications(); } catch (_) {}
  try { final prefs = await SharedPreferences.getInstance(); appHindi.value = prefs.getBool('app_language_hindi') ?? false; } catch (_) {}
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
    scaffoldMessengerKey: appMessengerKey,
    debugShowCheckedModeBanner: false,
    title: 'Yog Yogeshwar Mahaprabhu',
    theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: ivory,
      textTheme: GoogleFonts.notoSansDevanagariTextTheme(),
      primaryTextTheme: GoogleFonts.notoSansDevanagariTextTheme(),
      colorScheme: ColorScheme.fromSeed(seedColor: champagne, primary: maroon, surface: ivory),
      appBarTheme: const AppBarTheme(backgroundColor: ivory, foregroundColor: brown, elevation: 0)),
    home: (Supabase.instance.isInitialized && Supabase.instance.client.auth.currentSession != null) ? const MainScreen() : const WelcomeGate());
}

class WelcomeGate extends StatelessWidget {
  const WelcomeGate({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 112, height: 112, decoration: BoxDecoration(shape: BoxShape.circle, color: paleGold, border: Border.all(color: champagne, width: 2)),
          child: ClipOval(child: Image.asset('assets/images/gurudev_logo_png.jpeg', fit: BoxFit.cover))),
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
  List<Widget> get pages => [const HomePage(), const DarshanPage(), const MediaPage(), const SadhanaPage(), const ProfilePage()];
  @override
  void initState() { super.initState(); appHindi.addListener(_languageChanged); }
  void _languageChanged() { if (mounted) setState(() {}); }
  @override
  void dispose() { appHindi.removeListener(_languageChanged); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: index, children: pages)),
    bottomNavigationBar: NavigationBar(height: 68, selectedIndex: index, backgroundColor: cardWhite,
      indicatorColor: paleGold, onDestinationSelected: (v) => setState(() => index = v),
      destinations: [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: appText('Home', 'होम')), 
        NavigationDestination(icon: Icon(Icons.self_improvement_outlined), selectedIcon: Icon(Icons.self_improvement), label: appText('Darshan', 'दर्शन')), 
        NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: appText('Media', 'मीडिया')), 
        NavigationDestination(icon: Icon(Icons.spa_outlined), selectedIcon: Icon(Icons.spa), label: appText('Sadhana', 'साधना')), 
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: appText('Profile', 'प्रोफ़ाइल')), 
      ]));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const features = [
    ('Bhajan', Icons.music_note_rounded), ('Aarti', Icons.local_fire_department_rounded),
    ('Books', Icons.menu_book_rounded), ('Guru Vani', Icons.auto_stories_rounded),
    ('Pravachan', Icons.mic_rounded), ('Satsang', Icons.groups_rounded),
    ('Gallery', Icons.photo_library_rounded), ('Events', Icons.event_rounded), ('Live', Icons.live_tv_rounded),
  ];
  static const hindiFeatures = ['भजन', 'आरती', 'पुस्तकें', 'गुरु वाणी', 'प्रवचन', 'सत्संग', 'गैलरी', 'कार्यक्रम', 'लाइव'];
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(shape: BoxShape.circle, color: paleGold, border: Border.all(color: champagne)),
          child: ClipOval(child: Image.asset('assets/images/gurudev_logo_png.jpeg', fit: BoxFit.cover))),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('योग योगेश्वर महाप्रभु', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: maroon)),
          Text('श्री रामलाल जी महाराज', style: TextStyle(fontSize: 13, color: brown, fontWeight: FontWeight.w600)),
        ])),
        IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentPage(category: 'Notifications', title: 'Announcements'))),
          icon: const Icon(Icons.notifications_none_rounded, color: brown)),
      ]))),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Container(height: 285, width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: champagne),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFFFF9ED), Color(0xFFEAD8B4), Color(0xFFFFFDF7)]),
          boxShadow: [BoxShadow(color: champagne.withValues(alpha: .16), blurRadius: 16, offset: const Offset(0, 5))]),
        child: ClipRRect(borderRadius: BorderRadius.circular(23), child: Stack(fit: StackFit.expand, children: [
          Container(color: const Color(0xFFFFF9ED), alignment: Alignment.center, child: Image.asset('assets/images/gurudev_logo_png.jpeg', fit: BoxFit.cover, alignment: const Alignment(0, -0.28), width: double.infinity, height: double.infinity)),
          DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: .58)]))),
          const Align(alignment: Alignment.bottomCenter, child: Padding(padding: EdgeInsets.only(bottom: 14), child: Text('जय गुरुदेव 🙏', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black54, blurRadius: 8)])))),
        ]))))),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 15, 20, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome, ${currentDisplayName}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: maroon)),
        const SizedBox(height: 4), const Text('गुरुदेव की कृपा आप पर बनी रहे 🙏', style: TextStyle(color: brown, fontSize: 14)),
        const SizedBox(height: 20), Text(appText('Explore devotion', 'दर्शन एवं भक्ति'), style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: brown)),
      ]))),
    SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverGrid(
      delegate: SliverChildBuilderDelegate((context, i) {
        final item = features[i];
        return InkWell(borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            (item.$1 == 'Events' || item.$1 == 'Live') ? const EventsPage() : ContentPage(category: item.$1, title: item.$1))),
          child: Container(decoration: BoxDecoration(color: cardWhite, borderRadius: BorderRadius.circular(18),
            border: Border.all(color: paleGold), boxShadow: [BoxShadow(color: brown.withValues(alpha: .05), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 52, height: 52, decoration: const BoxDecoration(color: ivory, shape: BoxShape.circle),
                child: Icon(item.$2, color: champagne, size: 28)),
              const SizedBox(height: 10), Text(appHindi.value ? hindiFeatures[i] : item.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: brown)),
            ])));
      }, childCount: features.length),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 13, crossAxisSpacing: 13, childAspectRatio: 1.25))),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Container(padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFFFFF9ED), borderRadius: BorderRadius.circular(18), border: Border.all(color: paleGold)),
      child: const LatestGuruVaniCard()))),
    SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 22), child: Card(color: cardWhite, elevation: 0, child: ListTile(leading: const Icon(Icons.video_library_outlined, color: maroon), title: const Text('Prabhu’s YouTube Channel', style: TextStyle(fontWeight: FontWeight.w600, color: maroon)), subtitle: const Text('Watch more devotional videos and programmes'), trailing: const Icon(Icons.open_in_new, color: champagne), onTap: () => launchUrl(Uri.parse('https://youtube.com/@dramitkumar2201'), mode: LaunchMode.externalApplication))))),
    const SliverToBoxAdapter(child: SizedBox(height: 18)),
  ]);
}

class LatestGuruVaniCard extends StatelessWidget {
  const LatestGuruVaniCard({super.key});
  Future<Map<String, dynamic>?> latest() async {
    if (!Supabase.instance.isInitialized) return null;
    final rows = await Supabase.instance.client.from('devotional_content').select().eq('published', true).eq('category', 'Guru Vani').order('created_at', ascending: false).limit(1);
    return rows.isEmpty ? null : Map<String, dynamic>.from(rows.first);
  }
  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>?>(future: latest(), builder: (context, snap) {
    final item = snap.data;
    final title = (item?['title'] ?? '').toString();
    final description = (item?['description'] ?? '').toString();
    return InkWell(onTap: item == null ? null : () => openItem(context, item), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('आज की गुरु वाणी', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: maroon)),
      const SizedBox(height: 10),
      Text(description.isNotEmpty ? description : (title.isNotEmpty ? title : 'गुरु कृपा ही जीवन का सबसे बड़ा आधार है।'), style: const TextStyle(fontSize: 16, color: brown)),
      const SizedBox(height: 6),
      Text(title.isEmpty ? 'ॐ गुरवे नमः' : title, style: const TextStyle(fontSize: 12, color: champagne)),
    ]));
  });
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
        final rows = (snapshot.data ?? []).where((e) => ('${e['title'] ?? ''} ${e['description'] ?? ''}').toLowerCase().contains(search)).toList();
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
                title: isGallery || (item['title'] ?? '').toString().trim().isEmpty ? const SizedBox.shrink() : Text(item['title'].toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: brown)),
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
  if (link.contains('youtube.com') || link.contains('youtu.be') || link.contains('music.youtube.com')) {
    final uri = Uri.tryParse(link);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
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
  final isVideo = category == 'video' || RegExp(r'\\.(mp4|m4v|mov|webm)(\\?|$)', caseSensitive: false).hasMatch(link);
  if (isVideo) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => InAppVideoPage(url: link, title: title)));
    return;
  }
  final uri = Uri.tryParse(link);
  if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This content link could not be opened.')));
  }
}

class InAppVideoPage extends StatefulWidget {
  final String url, title;
  const InAppVideoPage({super.key, required this.url, required this.title});
  @override
  State<InAppVideoPage> createState() => _InAppVideoPageState();
}

class _InAppVideoPageState extends State<InAppVideoPage> {
  late final VideoPlayerController _controller;
  String? _error;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      }).catchError((Object error) {
        if (mounted) setState(() => _error = 'Unable to load this video. Check the link or internet connection.');
      });
  }

  String _time(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Center(child: _error != null
      ? Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: maroon)))
      : !_ready
        ? const CircularProgressIndicator(color: champagne)
        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
            VideoProgressIndicator(_controller, allowScrubbing: true, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16), colors: const VideoProgressColors(playedColor: champagne, bufferedColor: paleGold, backgroundColor: ivory)),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(onPressed: () => _controller.seekTo(_controller.value.position - const Duration(seconds: 10)), icon: const Icon(Icons.replay_10, color: brown), iconSize: 36),
              IconButton(onPressed: () => setState(() { _controller.value.isPlaying ? _controller.pause() : _controller.play(); }), icon: Icon(_controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle, color: maroon), iconSize: 58),
              IconButton(onPressed: () => _controller.seekTo(_controller.value.position + const Duration(seconds: 10)), icon: const Icon(Icons.forward_10, color: brown), iconSize: 36),
            ]),
            Text('${_time(_controller.value.position)} / ${_time(_controller.value.duration)}', style: const TextStyle(color: brown)),
          ])),
  );
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
    if (!Supabase.instance.isInitialized) { setState(() => error = 'Administrator sign-in is not configured in this build.'); return; }
    setState(() { busy = true; error = null; });
    try {
      if (email.text.trim().contains('@')) {
        await Supabase.instance.client.auth.signInWithPassword(email: email.text.trim(), password: password.text);
      } else {
        final response = await Supabase.instance.client.functions.invoke('phone-login', body: {'phone': email.text.trim(), 'password': password.text});
        if (response.status < 200 || response.status >= 300) throw Exception('Phone login failed. Check your number and password.');
        final data = Map<String, dynamic>.from(response.data);
        await Supabase.instance.client.auth.setSession(data['refresh_token'].toString());
      }
      final role = Supabase.instance.client.auth.currentUser?.appMetadata['role']?.toString();
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
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address or phone number', prefixIcon: Icon(Icons.email_outlined))),
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
  final title = TextEditingController(), description = TextEditingController(), externalUrl = TextEditingController();
  String category = 'Bhajan';
  final categories = const ['Bhajan','Aarti','Books','Guru Vani','Pravachan','Satsang','Gallery','Sadhana Music','Notifications','Live'];

  Future<void> upload() async {
    final client = Supabase.instance.client;
    final role = client.auth.currentUser?.appMetadata['role']?.toString();
    if (role != 'admin' && role != 'super_admin') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Administrator permission required.')));
      return;
    }
    final external = externalUrl.text.trim();
    final isExternal = external.isNotEmpty;
    final picked = isExternal ? null : await FilePicker.platform.pickFiles(withData: true, type: FileType.any);
    final textOnly = category == 'Notifications' && description.text.trim().isNotEmpty;
    if (!isExternal && !textOnly && (picked == null || picked.files.single.bytes == null)) return;
    if (!mounted) return;
    setState(() => busy = true);
    try {
      final file = picked?.files.single;
      String url = external;
      if (!isExternal && !textOnly && file != null) {
        final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
        final storagePath = 'uploads/${DateTime.now().millisecondsSinceEpoch}_$safeName';
        await client.storage.from('prabhu').uploadBinary(storagePath, file.bytes!, fileOptions: FileOptions(upsert: false));
        url = client.storage.from('prabhu').getPublicUrl(storagePath);
      }
      if (url.isEmpty && !textOnly) throw Exception('Choose a file or enter an external link.');
      await client.from('devotional_content').insert({
        'title': title.text.trim(),
        'category': category, 'description': description.text.trim(), 'file_url': url,
        'thumbnail_url': category == 'Gallery' ? url : null, 'published': true,
      });
      title.clear(); description.clear(); externalUrl.clear();
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
    if (RegExp(r'\\.(mp4|m4v|mov|webm)(\\?|$)', caseSensitive: false).hasMatch(url) || category == 'video') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => InAppVideoPage(url: url, title: (item['title'] ?? 'Video Preview').toString())));
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
  void dispose() { title.dispose(); description.dispose(); externalUrl.dispose(); super.dispose(); }

  Widget uploadTab() => ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Upload devotional content', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: maroon)),
    const SizedBox(height: 8), const Text('Upload photos, bhajans, aarti, books and other devotional media.', style: TextStyle(color: brown)),
    const SizedBox(height: 20),
    DropdownButtonFormField<String>(value: category, decoration: const InputDecoration(labelText: 'Content category'),
      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: busy ? null : (v) { if (v != null) setState(() => category = v); }),
    const SizedBox(height: 12),
    TextField(controller: title, decoration: const InputDecoration(labelText: 'Title (optional)')),
    const SizedBox(height: 12),
    TextField(controller: externalUrl, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'External link (optional)', hintText: 'YouTube video or playlist URL', prefixIcon: Icon(Icons.link))),
    const SizedBox(height: 12),
    TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description (optional)')),
    const SizedBox(height: 18),
    FilledButton.icon(onPressed: busy ? null : upload, icon: const Icon(Icons.cloud_upload), label: Text(busy ? 'Publishing...' : 'Choose file or publish link'), style: FilledButton.styleFrom(backgroundColor: maroon)),  ]);

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
  Widget build(BuildContext context) {
    final isSuperAdmin = Supabase.instance.client.auth.currentUser?.appMetadata['role']?.toString() == 'super_admin';
    final tabs = <Widget>[
      const Tab(icon: Icon(Icons.cloud_upload_outlined), text: 'Upload'),
      const Tab(icon: Icon(Icons.library_music_outlined), text: 'Manage Media'),
      const Tab(icon: Icon(Icons.event_outlined), text: 'Events'),
      if (isSuperAdmin) const Tab(icon: Icon(Icons.manage_accounts_outlined), text: 'Users'),
    ];
    final pages = <Widget>[uploadTab(), manageTab(), const EventsAdminPage(), if (isSuperAdmin) const SuperAdminUsersPage()];
    return DefaultTabController(length: tabs.length, child: Scaffold(
    appBar: AppBar(title: const Text('Admin Portal'), actions: [

      IconButton(tooltip: 'My profile', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())), icon: const Icon(Icons.person_outline)),
      IconButton(tooltip: 'Sign out', onPressed: () async { await Supabase.instance.client.auth.signOut(); if (context.mounted) Navigator.pop(context); }, icon: const Icon(Icons.logout)),
    ], bottom: TabBar(isScrollable: true, tabs: tabs)),
    body: TabBarView(children: pages),
  ));
  }
}

class SuperAdminUsersPage extends StatefulWidget {
  const SuperAdminUsersPage({super.key});
  @override
  State<SuperAdminUsersPage> createState() => _SuperAdminUsersPageState();
}
class _SuperAdminUsersPageState extends State<SuperAdminUsersPage> {
  bool loading = true, working = false;
  String? error;
  String searchQuery = '';
  List<Map<String, dynamic>> users = [];
  @override
  void initState() { super.initState(); loadUsers(); }

  Future<void> loadUsers() async {
    setState(() { loading = true; error = null; });
    try {
      final r = await Supabase.instance.client.functions.invoke('manage-users', body: {'action': 'list'});
      if (r.status < 200 || r.status >= 300) throw Exception('Request failed: ' + r.status.toString());
      users = List<Map<String, dynamic>>.from((r.data as Map)['users'] ?? []);
    } catch (e) { error = e.toString(); }
    if (mounted) setState(() => loading = false);
  }

  Future<void> updateUser(Map<String, dynamic> user, Map<String, dynamic> body, String prompt) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirm account change'),
      content: Text(prompt + ' ' + (user['email'] ?? 'this account').toString()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
      ],
    ));
    if (ok != true || !mounted) return;
    setState(() => working = true);
    try {
      final r = await Supabase.instance.client.functions.invoke('manage-users', body: body);
      if (r.status < 200 || r.status >= 300) throw Exception(r.data.toString());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account updated.')));
      await loadUsers();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: ' + e.toString())));
    } finally { if (mounted) setState(() => working = false); }
  }

  @override
  Widget build(BuildContext context) {
    final self = Supabase.instance.client.auth.currentUser?.id;
    if (loading) return const Center(child: CircularProgressIndicator(color: champagne));
    if (error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(error!, textAlign: TextAlign.center), const SizedBox(height: 12),
      FilledButton(onPressed: loadUsers, child: const Text('Retry')),
    ]));
    final query = searchQuery.trim().toLowerCase();
    final filteredUsers = users.where((u) {
      final email = (u['email'] ?? '').toString().toLowerCase();
      final userMeta = u['user_metadata'] is Map ? Map<String, dynamic>.from(u['user_metadata']) : <String, dynamic>{};
      final phone = (userMeta['phone'] ?? '').toString().toLowerCase();
      final name = (userMeta['full_name'] ?? '').toString().toLowerCase();
      final id = (u['id'] ?? '').toString().toLowerCase();
      final metadata = u['app_metadata'] is Map ? Map<String, dynamic>.from(u['app_metadata']) : <String, dynamic>{};
      final role = (metadata['role'] ?? 'devotee').toString().toLowerCase();
      return query.isEmpty || email.contains(query) || phone.contains(query) || name.contains(query) || id.contains(query) || role.contains(query);
    }).toList();
    return RefreshIndicator(onRefresh: loadUsers, child: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Super Admin • User Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: maroon)),
      const SizedBox(height: 6),
      const Text('Promote or revoke administrators and suspend or restore accounts. Server-side role checks protect every action.', style: TextStyle(color: brown)),
      const SizedBox(height: 14),
      TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by email, user ID or role',
          prefixIcon: const Icon(Icons.search, color: champagne),
          suffixIcon: searchQuery.isEmpty ? null : IconButton(
            tooltip: 'Clear search', icon: const Icon(Icons.clear),
            onPressed: () => setState(() => searchQuery = ''),
          ),
          filled: true, fillColor: cardWhite,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      const SizedBox(height: 12),
      Text('${filteredUsers.length} of ${users.length} registered accounts'),
      if (filteredUsers.isEmpty)
        const Padding(padding: EdgeInsets.symmetric(vertical: 32), child: Center(child: Text('No matching users found.'))),
      ...filteredUsers.map((u) {
        final id = (u['id'] ?? '').toString();
        final email = (u['email'] ?? 'No email').toString();
        final metadata = u['app_metadata'] is Map ? Map<String, dynamic>.from(u['app_metadata']) : <String, dynamic>{};
        final role = (metadata['role'] ?? 'devotee').toString();
        final userMeta = u['user_metadata'] is Map ? Map<String, dynamic>.from(u['user_metadata']) : <String, dynamic>{};
        final phone = (userMeta['phone'] ?? 'Not provided').toString();
        final fullName = (userMeta['full_name'] ?? '').toString();
        final banned = (u['banned_until'] ?? '').toString().isNotEmpty;
        final protected = id == self || role == 'super_admin';
        return Card(color: cardWhite, child: ListTile(
          leading: const Icon(Icons.account_circle_outlined, color: champagne, size: 30),
          title: Text(fullName.isEmpty ? email : fullName),
          subtitle: Text('$email • $phone\n' + role.toUpperCase() + (banned ? ' • SUSPENDED' : ' • ACTIVE')),
          isThreeLine: false,
          trailing: protected ? const Icon(Icons.verified_user_outlined, color: brown) : PopupMenuButton<String>(
            enabled: !working,
            onSelected: (v) {
              if (v == 'admin' || v == 'devotee') {
                updateUser(u, {'action': 'set_role', 'user_id': id, 'role': v}, v == 'admin' ? 'Grant admin access to' : 'Revoke admin access from');
              } else {
                updateUser(u, {'action': banned ? 'unban' : 'ban', 'user_id': id}, banned ? 'Restore access for' : 'Suspend');
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: role == 'admin' ? 'devotee' : 'admin', child: Text(role == 'admin' ? 'Revoke admin' : 'Make admin')),
              PopupMenuItem(value: banned ? 'unban' : 'ban', child: Text(banned ? 'Restore account' : 'Suspend account')),
            ],
          ),
        ));
      }),
    ]));
  }
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
    final eventTime = TextEditingController();
    DateTime selectedDate = DateTime.tryParse((event?['event_date'] ?? '').toString()) ?? DateTime.now();
    bool published = event?['published'] == true;
    final result = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: Text(event == null ? 'Add event' : 'Edit event'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Event title (optional)')),
          TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description / live programme details')),
          TextField(controller: location, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Location or YouTube Live link')),
          TextField(controller: eventTime, decoration: const InputDecoration(labelText: 'Scheduled time (optional)', hintText: 'e.g. 7:00 PM')),
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
            Navigator.pop(dialogContext, true);
          }, child: const Text('Save')),
        ],
      ),
    ));
    if (result == true && mounted) {
      try {
        final data = {
          'title': title.text.trim(), 'description': description.text.trim() + (eventTime.text.trim().isEmpty ? '' : '\\nScheduled time: ' + eventTime.text.trim()), 'location': location.text.trim(),
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
    title.dispose(); description.dispose(); location.dispose(); eventTime.dispose();
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
          title: Text((e['title'] ?? '').toString().trim().isEmpty ? 'Devotional Programme' : (e['title'] ?? '').toString()), subtitle: Text((e['event_date'] ?? '').toString() + ' • ' + (e['location'] ?? '').toString() + '\n' + (e['description'] ?? '').toString()), onTap: () { final loc = (e['location'] ?? '').toString(); final uri = Uri.tryParse(loc); if (uri != null && (loc.startsWith('https://') || loc.startsWith('http://'))) launchUrl(uri, mode: LaunchMode.externalApplication); }));
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
  DateTime? _endsAt;
  static const _deadlineKey = 'sadhana_timer_deadline';

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
    _restoreTimer();
  }

  Future<void> _restoreTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDeadline = prefs.getInt(_deadlineKey);
    if (savedDeadline == null) return;
    final deadline = DateTime.fromMillisecondsSinceEpoch(savedDeadline);
    final seconds = deadline.difference(DateTime.now()).inSeconds;
    if (seconds <= 0) {
      await prefs.remove(_deadlineKey);
      await sadhanaNotifications.cancel(sadhanaAlarmNotificationId);
      if (!mounted) return;
      setState(() {
        remaining = 0; running = false; _endsAt = null;
        completed.insert(0, DateTime.now().toString().substring(0, 16) + ' • ' + minutes.toString() + ' min');
      });
      await _saveCompletedSessions();
      HapticFeedback.vibrate();
      await playCompletionMusic();
      return;
    }
    if (!mounted) return;
    setState(() { _endsAt = deadline; remaining = seconds; running = true; });
    _tickFromDeadline();
  }

  void _tickFromDeadline() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted || _endsAt == null) return;
      final seconds = _endsAt!.difference(DateTime.now()).inSeconds;
      if (seconds <= 0) {
        t.cancel();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_deadlineKey);
        await sadhanaNotifications.cancel(sadhanaAlarmNotificationId);
        if (!mounted) return;
        setState(() {
          remaining = 0; running = false; _endsAt = null;
          completed.insert(0, DateTime.now().toString().substring(0, 16) + ' • ' + minutes.toString() + ' min');
        });
        HapticFeedback.vibrate();
        await _saveCompletedSessions();
        playCompletionMusic();
      } else {
        setState(() => remaining = seconds);
      }
    });
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
    try {
      await completionPlayer?.stop();
      completionPlayer ??= AudioPlayer();
      await completionPlayer!.setAsset('assets/sounds/temple_bell.wav');
      await completionPlayer!.setVolume(1.0);
      await completionPlayer!.setLoopMode(LoopMode.one);
      if (mounted) setState(() => musicPlaying = true);
      unawaited(completionPlayer!.play());
      await Future<void>.delayed(const Duration(seconds: 15));
      await completionPlayer!.stop();
      await completionPlayer!.setLoopMode(LoopMode.off);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to play the temple bell.')),
        );
      }
    } finally {
      if (mounted) setState(() => musicPlaying = false);
    }
  }

  Future<void> stopCompletionMusic() async {
    await completionPlayer?.stop();
    if (mounted) setState(() => musicPlaying = false);
  }

  void choose(int m) {
    timer?.cancel();
    _endsAt = null;
    SharedPreferences.getInstance().then((p) => p.remove(_deadlineKey));
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
      _endsAt = null;
      SharedPreferences.getInstance().then((p) => p.remove(_deadlineKey));
      sadhanaNotifications.cancel(sadhanaAlarmNotificationId);
      setState(() => running = false);
      return;
    }
    if (remaining <= 0) remaining = minutes * 60;
    _endsAt = DateTime.now().add(Duration(seconds: remaining));
    final endAt = _endsAt!;
    SharedPreferences.getInstance().then((p) => p.setInt(_deadlineKey, endAt.millisecondsSinceEpoch));
    scheduleSadhanaBell(endAt).catchError((_) {});
    setState(() => running = true);
    _tickFromDeadline();
  }

  void reset() {
    timer?.cancel();
    _endsAt = null;
    SharedPreferences.getInstance().then((p) => p.remove(_deadlineKey));
    sadhanaNotifications.cancel(sadhanaAlarmNotificationId);
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
          ] else if (remaining == 0) ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(
              onPressed: playCompletionMusic,
              icon: const Icon(Icons.replay),
              label: const Text('Play Completion Music Again'),
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

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}
class _EditProfilePageState extends State<EditProfilePage> {
  final name = TextEditingController(), phone = TextEditingController(), email = TextEditingController(), photo = TextEditingController(), password = TextEditingController();
  bool busy = false;
  @override
  void initState() {
    super.initState();
    final u = Supabase.instance.client.auth.currentUser!;
    name.text = (u.userMetadata?['full_name'] ?? '').toString();
    phone.text = (u.userMetadata?['phone'] ?? '').toString();
    photo.text = (u.userMetadata?['avatar_url'] ?? '').toString();
    email.text = u.email ?? '';
  }
  Future<void> choosePhoto() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (picked == null || picked.files.single.bytes == null) return;
    setState(() => busy = true);
    try {
      final file = picked.files.single;
      final safe = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = 'avatars/${Supabase.instance.client.auth.currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}_$safe';
      await Supabase.instance.client.storage.from('prabhu').uploadBinary(path, file.bytes!, fileOptions: const FileOptions(upsert: true));
      photo.text = Supabase.instance.client.storage.from('prabhu').getPublicUrl(path);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo selected. Save changes to apply it.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not upload photo: $e')));
    } finally { if (mounted) setState(() => busy = false); }
  }

  Future<void> save() async {
    setState(() => busy = true);
    try {
      final attrs = UserAttributes(data: {'full_name': name.text.trim(), 'phone': phone.text.trim(), 'avatar_url': photo.text.trim()}.cast<String, dynamic>(), email: email.text.trim().isEmpty ? null : email.text.trim(), password: password.text.isEmpty ? null : password.text);
      await Supabase.instance.client.auth.updateUser(attrs);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personal details updated.'))); Navigator.pop(context); }
    } on AuthException catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message))); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update profile: $e'))); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  void dispose() { name.dispose(); phone.dispose(); email.dispose(); photo.dispose(); password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('My Personal Details')), body: ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Profile photo is optional. Leave it blank to use the default icon.', style: TextStyle(color: brown)),
    const SizedBox(height: 12),
    TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
    const SizedBox(height: 12), TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address')),
    const SizedBox(height: 12), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Registered phone number')),
    const SizedBox(height: 12), OutlinedButton.icon(onPressed: busy ? null : choosePhoto, icon: const Icon(Icons.photo_camera_outlined), label: const Text('Choose profile photo (optional)')),
    TextField(controller: photo, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'Or enter photo URL (optional)')),
    const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'New password (leave blank to keep current)')),
    const SizedBox(height: 20), FilledButton(onPressed: busy ? null : save, child: Text(busy ? 'Saving...' : 'Save Changes')),
  ]));
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});
  static const policy = '''PRIVACY POLICY\nYog Yogeshwar Mahaprabhu Shree Ramlal Ji Maharaj\n\n1. INTRODUCTION\nWe respect your privacy and are committed to protecting personal information. This policy explains information handled when you use this devotional application.\n\n2. INFORMATION WE HANDLE\nDepending on use, the App may process your name, email address, registered phone number, optional profile photo URL, authentication identifiers, account preferences and limited technical logs. Guest users can access available guest features without creating an account.\n\n3. HOW INFORMATION IS USED\nInformation is used to create and manage accounts, maintain login sessions, provide devotional features, manage administrator permissions, deliver announcements, protect the service and respond to support requests.\n\n4. STORAGE AND SERVICE PROVIDERS\nThe App uses Supabase for configured authentication, database and media-storage services. Google services may process information when YouTube or YouTube Music links are opened. Those services operate under their own privacy policies.\n\n5. DEVOTIONAL MEDIA AND EXTERNAL LINKS\nThe App may display images, Daily Darshan, Guru Vani, Bhajans, Pravachan, PDFs, playlists and live programme links. Media may be uploaded to the App's configured storage or opened from external services.\n\n6. ADMINISTRATOR ACCESS\nAuthorised administrators may manage devotional content and account administration according to assigned permissions. Registered name, email and phone details may be visible to authorised administrators. Passwords are never displayed to administrators.\n\n7. NOTIFICATIONS\nThe App may display announcements about devotional programmes and new content. Notifications may contain text, images, documents or links.\n\n8. DATA SHARING\nWe do not sell or rent personal information. Data may be processed by service providers as needed to operate the App, maintain security or comply with law.\n\n9. SECURITY AND RETENTION\nReasonable safeguards are used to protect information. No online service can guarantee absolute security. Information is retained only as reasonably necessary for service operation, security and legal obligations.\n\n10. ACCOUNT DELETION\nUsers may request account deletion through the in-app deletion feature where available. Data will be deleted or deactivated as applicable, subject to legal retention requirements, technical limitations and backup cycles.\n\n11. CHILDREN'S PRIVACY\nThe App is intended for general devotional use. Parents or guardians may contact us if they believe a child has provided personal information requiring review.\n\n12. EXTERNAL SERVICES\nYouTube, YouTube Music and other external websites are governed by their own terms and privacy policies.\n\n13. YOUR CHOICES\nSubject to applicable law, you may request access to, correction of or deletion of your personal information and may stop using account-based features.\n\n14. CONTACT\nFor privacy questions or requests, contact the App administrator through the official contact channel provided by the App.''';
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Privacy Policy')), body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: SelectableText(policy, style: const TextStyle(height: 1.55, color: brown, fontSize: 14))));
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  bool deleting = false;

  Future<void> deleteAccount() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null || user.email == null) return;
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('खाता स्थायी रूप से हटाएँ?'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('यह कार्रवाई वापस नहीं की जा सकती। पुष्टि के लिए अपना वर्तमान पासवर्ड दर्ज करें.\n\nThis permanently deletes your sign-in account.'),
          const SizedBox(height: 14),
          TextField(controller: passwordController, obscureText: true, autofocus: true,
            decoration: const InputDecoration(labelText: 'Current password / वर्तमान पासवर्ड', prefixIcon: Icon(Icons.lock_outline))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel / रद्द करें')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, passwordController.text.isNotEmpty),
            child: const Text('Delete account / हटाएँ'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) { passwordController.dispose(); return; }
    setState(() => deleting = true);
    try {
      final check = await client.auth.signInWithPassword(email: user.email!, password: passwordController.text);
      if (check.user?.id != user.id) throw Exception('Account confirmation failed. Please sign in again.');
      final response = await client.functions.invoke('delete-account');
      if (response.status < 200 || response.status >= 300) {
        throw Exception((response.data is Map ? response.data['error'] : null)?.toString() ?? 'Account deletion service is unavailable.');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('favourite_content');
      await prefs.remove('favourite_content_ids');
      await prefs.remove('sadhana_completed_sessions');
      await client.auth.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const WelcomeGate()), (route) => false);
      WidgetsBinding.instance.addPostFrameCallback((_) => appMessengerKey.currentState?.showSnackBar(SnackBar(backgroundColor: Colors.green.shade700, content: Text(appText('Your account has been permanently deleted successfully.', 'आपका खाता सफलतापूर्वक स्थायी रूप से हटा दिया गया है।')))));
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password verification failed: ${e.message}')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account deletion failed: ${e.toString().replaceFirst('Exception: ', '')}')));
    } finally {
      passwordController.dispose();
      if (mounted) setState(() => deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.isInitialized ? Supabase.instance.client : null;
    final user = client?.auth.currentUser;
    final role = user?.appMetadata['role']?.toString();
    final isAdmin = role == 'admin' || role == 'super_admin';
    return Scaffold(appBar: AppBar(title: Text(appText('Profile', 'प्रोफ़ाइल'))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: cardWhite, borderRadius: BorderRadius.circular(20), border: Border.all(color: paleGold)),
          child: Column(children: [
            CircleAvatar(radius: 38, backgroundColor: ivory, backgroundImage: (user?.userMetadata?['avatar_url'] ?? '').toString().startsWith('http') ? NetworkImage(user!.userMetadata!['avatar_url'].toString()) : null, child: (user?.userMetadata?['avatar_url'] ?? '').toString().startsWith('http') ? null : const Icon(Icons.person, size: 42, color: maroon)),
            const SizedBox(height: 12),
            Text((user?.userMetadata?['full_name'] ?? user?.email ?? 'Welcome, Devotee • भक्त का स्वागत है').toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: maroon)),
            const SizedBox(height: 5),
            Text(user == null ? 'अतिथि प्रवेश • Guest access' : (isAdmin ? (role == 'super_admin' ? 'सुपर एडमिन • Super Administrator' : 'एडमिन • Administrator') : 'भक्त खाता • Devotee account'), style: const TextStyle(color: brown)),
            const SizedBox(height: 5),
            if (user != null) Text('Email: ${user.email ?? 'Not provided'}', style: const TextStyle(color: brown, fontSize: 12)),
            if (user != null) Text('Phone: ${(user.userMetadata?['phone'] ?? 'Not provided')}', style: const TextStyle(color: brown, fontSize: 12)),
            if (user != null) Text('Joined: ${user.createdAt.split('T').first}', style: const TextStyle(color: brown, fontSize: 12)),
            const SizedBox(height: 5), const Text('ॐ गुरवे नमः', style: TextStyle(color: brown)),
          ])),
        const SizedBox(height: 18),
        ProfileTile(
          icon: Icons.language,
          title: appText('App language • हिन्दी / English', 'ऐप की भाषा • हिन्दी / English'),
          subtitle: appText('Choose Hindi or English', 'हिन्दी या English चुनें'),
          onTap: () => showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(appText('App language', 'ऐप की भाषा')),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                  title: const Text('हिन्दी'),
                  trailing: appHindi.value ? const Icon(Icons.check, color: maroon) : null,
                  onTap: () async {
                    appHindi.value = true;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('app_language_hindi', true);
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    if (mounted) setState(() {});
                  },
                ),
                ListTile(
                  title: const Text('English'),
                  trailing: !appHindi.value ? const Icon(Icons.check, color: maroon) : null,
                  onTap: () async {
                    appHindi.value = false;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('app_language_hindi', false);
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    if (mounted) setState(() {});
                  },
                ),
              ]),
            ),
          ),
        ),
        if (user == null)
          ProfileTile(icon: Icons.login, title: 'भक्त लॉगिन / Devotee Login', subtitle: 'Sign in or create a free account', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevoteeAuthPage()))),
        if (user != null)
          ProfileTile(icon: Icons.person_outline, title: 'My Personal Details', subtitle: 'View and update your profile', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()))),
        if (user != null)
          ProfileTile(icon: Icons.logout, title: 'साइन आउट • Sign Out', subtitle: 'Sign out of this account', onTap: () async {
            await client!.auth.signOut();
            if (mounted) setState(() {});
          }),
        if (user != null)
          ProfileTile(icon: Icons.delete_forever_outlined, title: 'खाता हटाएँ • Delete Account', subtitle: deleting ? 'Please wait…' : 'Permanently delete your account', onTap: deleting ? null : deleteAccount),
        ProfileTile(icon: Icons.favorite_outline, title: 'पसंदीदा • Favourites', subtitle: 'Your saved devotional items', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavouritesPage()))),
        const ProfileTile(icon: Icons.info_outline, title: 'ऐप के बारे में • About the App', subtitle: 'Yog Yogeshwar Mahaprabhu Shree Ramlal Ji Maharaj'),
        ProfileTile(icon: Icons.privacy_tip_outlined, title: 'गोपनीयता • Privacy', subtitle: 'Privacy Policy', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()))),
        if (isAdmin)
          ProfileTile(icon: Icons.admin_panel_settings_outlined, title: 'एडमिन पोर्टल • Admin Portal', subtitle: 'Manage devotional content and events', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardPage()))),
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
  final email = TextEditingController(), phone = TextEditingController(), fullName = TextEditingController();
  final password = TextEditingController(), confirmPassword = TextEditingController();
  bool creating = false, busy = false, obscure = true;
  String? message, error;

  Future<void> submit() async {
    if (!Supabase.instance.isInitialized) {
      setState(() => error = 'Account service is not configured yet.');
      return;
    }
    if ((creating && (email.text.trim().isEmpty || phone.text.trim().isEmpty || fullName.text.trim().isEmpty)) || (!creating && email.text.trim().isEmpty) || password.text.length < 6 || (creating && password.text != confirmPassword.text)) {
      setState(() => error = creating ? 'Enter your name, email, phone number, and matching passwords (minimum 6 characters).' : 'Enter your email or phone number and password (minimum 6 characters).');
      return;
    }
    setState(() { busy = true; error = null; message = null; });
    try {
      final auth = Supabase.instance.client.auth;
      if (creating) {
        final result = await auth.signUp(email: email.text.trim(), password: password.text, data: {'full_name': fullName.text.trim(), 'phone': phone.text.trim()});
        if (result.session == null) {
          setState(() => message = 'Account created. Please verify your email, then sign in.');
        } else if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen()), (route) => false);
        }
      } else {
        if (email.text.trim().contains('@')) {
          await auth.signInWithPassword(email: email.text.trim(), password: password.text);
        } else {
          final response = await Supabase.instance.client.functions.invoke('phone-login', body: {'phone': email.text.trim(), 'password': password.text});
          if (response.status < 200 || response.status >= 300) throw Exception('Phone login failed. Check your number and password.');
          final data = Map<String, dynamic>.from(response.data);
          await auth.setSession(data['refresh_token'].toString());
        }
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
  void dispose() { email.dispose(); phone.dispose(); fullName.dispose(); password.dispose(); confirmPassword.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(creating ? 'Create Devotee Account' : 'Devotee Login')),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      const Icon(Icons.self_improvement, color: maroon, size: 64),
      const SizedBox(height: 12),
      const Text('Your devotional journey', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: maroon)),
      const SizedBox(height: 22),
      const SizedBox(height: 18),
      const Row(children: [
        Expanded(child: Divider(color: paleGold)),
        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('OR', style: TextStyle(color: brown))),
        Expanded(child: Divider(color: paleGold)),
      ]),
      const SizedBox(height: 12),
      if (creating) ...[
        TextField(controller: fullName, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline))),
        const SizedBox(height: 12),
        TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number', prefixIcon: Icon(Icons.phone_outlined))),
        const SizedBox(height: 12),
      ],
      TextField(controller: email, keyboardType: TextInputType.emailAddress, autocorrect: false, decoration: InputDecoration(labelText: creating ? 'Email address' : 'Email address or phone number', prefixIcon: const Icon(Icons.email_outlined))),
      const SizedBox(height: 12),
      TextField(controller: password, obscureText: obscure, decoration: InputDecoration(labelText: creating ? 'Create Password (minimum 6 characters)' : 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => obscure = !obscure), icon: Icon(obscure ? Icons.visibility : Icons.visibility_off)))),
      if (creating) ...[
        const SizedBox(height: 12),
        TextField(controller: confirmPassword, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_reset_outlined))),
      ],
      if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
      if (message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(message!, style: const TextStyle(color: brown))),
      const SizedBox(height: 18),
      FilledButton(onPressed: busy ? null : submit, style: FilledButton.styleFrom(backgroundColor: maroon), child: Text(busy ? 'Please wait...' : (creating ? 'Create Free Account' : 'Sign In'))),
      if (!creating) TextButton(onPressed: busy ? null : resetPassword, child: const Text('Forgot password?')),
      TextButton(onPressed: busy ? null : () => setState(() { creating = !creating; error = null; message = null; }), child: Text(creating ? 'Already have an account? Sign in' : 'New here? Create a free account')),
      const SizedBox(height: 8),
      const Text('Email or phone number + password. No OTP and no Google Sign-In. Guest access is also available.', textAlign: TextAlign.center, style: TextStyle(color: brown, fontSize: 12)),
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