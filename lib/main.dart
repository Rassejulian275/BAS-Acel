import 'package:material_ui/material_ui.dart';

import 'api_service.dart';

const ink = Color(0xFF10213D);
const gold = Color(0xFFF2C230);
const canvas = Color(0xFFF6F7FA);
const muted = Color(0xFF7C8798);

void main() {
  runApp(const BoashApp());
}

class BoashApp extends StatelessWidget {
  const BoashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BOASH Academic',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ink,
          primary: ink,
          secondary: gold,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: canvas,
          foregroundColor: ink,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF6F7FA),
          hintStyle: const TextStyle(color: muted),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE9ECF1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ink, width: 1.4),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _npm = TextEditingController();
  final _password = TextEditingController();
  final _api = AcademicApi();
  bool _busy = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _npm.dispose();
    _password.dispose();
    _api.close();
    super.dispose();
  }

  Future<void> _login() async {
    if (_npm.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Masukkan NPM dan password terlebih dahulu.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await _api.login(
        npm: _npm.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _error =
              'NPM/password tidak cocok atau akun belum terdaftar. Cek userid, '
              'pass_sha1 (SHA-1 password), roleid 14, dan status aktif di /user.';
        });
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AcademicHome(npm: _npm.text.trim(), user: user),
        ),
      );
    } on ApiException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 34, 26, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 116,
                      height: 116,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: ink.withValues(alpha: .08),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/boash-logo.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'UNIVERSITAS BOASH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.7,
                    ),
                  ),
                  const SizedBox(height: 38),
                  const Text(
                    'Selamat datang',
                    style: TextStyle(
                      color: ink,
                      fontSize: 31,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk ke portal akademik untuk melanjutkan.',
                    style: TextStyle(color: muted, fontSize: 15),
                  ),
                  const SizedBox(height: 26),
                  const _FieldLabel('NPM'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _npm,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan nomor mahasiswa',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('Password'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _password,
                    obscureText: _obscure,
                    onSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      hintText: 'Masukkan password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        final npm = _npm.text.trim();
                        if (npm.isEmpty) {
                          setState(() {
                            _error = 'Masukkan NPM terlebih dahulu.';
                          });
                          return;
                        }
                        setState(() {
                          _password.text = npm;
                          _error = null;
                        });
                      },
                      child: const Text('Gunakan NPM sebagai password'),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFB63D45),
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: _busy ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: ink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Portal layanan akademik mahasiswa',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: ink,
      fontWeight: FontWeight.w700,
      fontSize: 13,
    ),
  );
}

class AcademicHome extends StatefulWidget {
  const AcademicHome({super.key, required this.npm, required this.user});
  final String npm;
  final Map<String, dynamic> user;

  @override
  State<AcademicHome> createState() => _AcademicHomeState();
}

class _AcademicHomeState extends State<AcademicHome> {
  final _api = AcademicApi();
  late Future<_DashboardData> _data;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<_DashboardData> _load() async {
    final results = await Future.wait([
      _api.mahasiswa(widget.npm),
      _api.nilai(widget.npm),
      _api.berita(),
      _api.informasi(),
    ]);
    return _DashboardData(
      mahasiswa: results[0].isEmpty ? <String, dynamic>{} : results[0].first,
      nilai: results[1],
      berita: results[2],
      informasi: results[3],
    );
  }

  void _refresh() => setState(() => _data = _load());

  String get _nama {
    final profile = _dataOrEmpty;
    return AcademicApi.text(
      profile.mahasiswa,
      const ['nama', 'nama_mhs', 'nama_mahasiswa', 'name'],
      fallback: AcademicApi.text(widget.user, const [
        'nama',
        'name',
        'username',
      ], fallback: 'Mahasiswa'),
    );
  }

  _DashboardData get _dataOrEmpty => _cached ?? const _DashboardData.empty();
  _DashboardData? _cached;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<_DashboardData>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.hasData) _cached = snapshot.data;
            final data = snapshot.data ?? _dataOrEmpty;
            final pages = [
              snapshot.hasError
                  ? _ErrorState(
                      message: 'Data beranda belum bisa dimuat.',
                      onRetry: _refresh,
                    )
                  : _dashboard(data),
              _moduleOverview(),
              _newsPage(data),
              _profilePage(data),
            ];
            return IndexedStack(index: _tab, children: pages);
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: Colors.white,
        indicatorColor: gold.withValues(alpha: .24),
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            label: 'Daftar',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            label: 'Informasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _dashboard(_DashboardData data) {
    final nama = AcademicApi.text(
      data.mahasiswa,
      const ['nama', 'nama_mhs', 'nama_mahasiswa', 'name'],
      fallback: AcademicApi.text(widget.user, const [
        'nama',
        'name',
        'username',
      ], fallback: 'Mahasiswa'),
    );
    final prodi = AcademicApi.text(data.mahasiswa, const [
      'prodi',
      'program_studi',
      'nama_prodi',
    ], fallback: 'Program studi');
    final npm = AcademicApi.text(data.mahasiswa, const [
      'npm',
      'nim',
    ], fallback: widget.npm);
    final ips = AcademicApi.average(data.nilai);
    final sks = AcademicApi.credits(data.nilai);
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PORTAL MAHASISWA',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Halo, ${nama.split(' ').first}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFE9ECF1)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    'assets/boash-logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _heroCard(nama, prodi, npm, ips, sks),
          const SizedBox(height: 25),
          _SectionHeading(
            title: 'Akses cepat',
            action: 'Lihat semua',
            onAction: () => setState(() => _tab = 1),
          ),
          const SizedBox(height: 13),
          _quickGrid(context),
          const SizedBox(height: 25),
          _SectionHeading(
            title: 'Kabar kampus',
            action: 'Semua',
            onAction: () => setState(() => _tab = 2),
          ),
          const SizedBox(height: 12),
          if (snapshotLoading(data))
            const _LoadingCard()
          else if (data.informasi.isEmpty && data.berita.isEmpty)
            const _EmptyCard(message: 'Belum ada informasi terbaru.')
          else
            ..._combinedNews(data)
                .take(2)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _NewsCard(item: item),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _heroCard(String nama, String prodi, String npm, double ips, int sks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF10213D), Color(0xFF1E385E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: ink.withValues(alpha: .16),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$npm  •  $prodi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFC9D2DF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.school_rounded, color: gold, size: 23),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 17),
            child: Divider(color: Color(0x33FFFFFF), height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _StatValue(
                  label: 'Rata-rata nilai',
                  value: ips == 0 ? '—' : ips.toStringAsFixed(2),
                ),
              ),
              Container(height: 35, width: 1, color: const Color(0x33FFFFFF)),
              Expanded(
                child: _StatValue(
                  label: 'Total SKS',
                  value: sks == 0 ? '—' : '$sks',
                ),
              ),
              Container(height: 35, width: 1, color: const Color(0x33FFFFFF)),
              const Expanded(
                child: _StatValue(label: 'Periode', value: '2025/2026'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickGrid(BuildContext context) {
    final items = <_Feature>[
      _Feature(
        'KHS',
        Icons.insert_chart_outlined_rounded,
        const Color(0xFF4A78C2),
        'khs',
      ),
      _Feature(
        'KRS',
        Icons.edit_calendar_outlined,
        const Color(0xFFB7832F),
        'krs',
      ),
      _Feature(
        'Presensi',
        Icons.fact_check_outlined,
        const Color(0xFF389982),
        'presensi',
      ),
      _Feature(
        'Keuangan',
        Icons.account_balance_wallet_outlined,
        const Color(0xFF5574AE),
        'keuangan',
      ),
      _Feature(
        'Bimbingan',
        Icons.forum_outlined,
        const Color(0xFF8A68A8),
        'bimbingan',
      ),
      _Feature(
        'Sertifikat',
        Icons.workspace_premium_outlined,
        const Color(0xFFC65D57),
        'sertifikat',
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.02,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () => _openModule(context, item.id),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 14, 8, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xFFEEF0F4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: .11),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _moduleOverview() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    children: [
      const Text(
        'Daftar layanan akademik',
        style: TextStyle(color: ink, fontSize: 25, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 7),
      const Text(
        'Semua kebutuhan kuliah dalam satu tempat.',
        style: TextStyle(color: muted, fontSize: 14),
      ),
      const SizedBox(height: 20),
      ...[
        _Feature(
          'Kartu Hasil Studi',
          Icons.insert_chart_outlined_rounded,
          const Color(0xFF4A78C2),
          'khs',
        ),
        _Feature(
          'Kartu Rencana Studi',
          Icons.edit_calendar_outlined,
          const Color(0xFFB7832F),
          'krs',
        ),
        _Feature(
          'Kehadiran',
          Icons.fact_check_outlined,
          const Color(0xFF389982),
          'presensi',
        ),
        _Feature(
          'Keuangan mahasiswa',
          Icons.account_balance_wallet_outlined,
          const Color(0xFF5574AE),
          'keuangan',
        ),
        _Feature(
          'Bimbingan akademik',
          Icons.forum_outlined,
          const Color(0xFF8A68A8),
          'bimbingan',
        ),
        _Feature(
          'Sertifikat',
          Icons.workspace_premium_outlined,
          const Color(0xFFC65D57),
          'sertifikat',
        ),
        _Feature(
          'Informasi kampus',
          Icons.campaign_outlined,
          const Color(0xFF389982),
          'informasi',
        ),
        _Feature(
          'Berita kampus',
          Icons.article_outlined,
          const Color(0xFF4A78C2),
          'berita',
        ),
        _Feature(
          'DHS / riwayat studi',
          Icons.history_edu_outlined,
          const Color(0xFF8A68A8),
          'dhs',
        ),
      ].map(
        (feature) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _FeatureTile(
            feature: feature,
            onTap: () => _openModule(context, feature.id),
          ),
        ),
      ),
    ],
  );

  Widget _newsPage(_DashboardData data) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    children: [
      const Text(
        'Informasi kampus',
        style: TextStyle(color: ink, fontSize: 25, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 7),
      const Text(
        'Pengumuman dan kabar terbaru dari kampus.',
        style: TextStyle(color: muted, fontSize: 14),
      ),
      const SizedBox(height: 20),
      if (data.informasi.isEmpty && data.berita.isEmpty)
        const _EmptyCard(message: 'Belum ada informasi untuk ditampilkan.')
      else
        ..._combinedNews(data).map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _NewsCard(item: item),
          ),
        ),
    ],
  );

  Widget _profilePage(_DashboardData data) {
    final fields = <String, List<String>>{
      'NPM': ['npm', 'nim'],
      'Program studi': ['prodi', 'program_studi', 'nama_prodi'],
      'Fakultas': ['fakultas', 'nama_fakultas'],
      'Email': ['email'],
      'Telepon': ['telepon', 'no_hp', 'phone'],
    };
    final profile = data.mahasiswa;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text(
          'Profil mahasiswa',
          style: TextStyle(
            color: ink,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEEF0F4)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: gold.withValues(alpha: .22),
                child: Text(
                  _nama.isEmpty ? 'M' : _nama[0].toUpperCase(),
                  style: const TextStyle(
                    color: ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _nama,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.npm,
                style: const TextStyle(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...fields.entries.map((entry) {
          final value = AcademicApi.text(profile, entry.value, fallback: '—');
          return _DetailRow(label: entry.key, value: value);
        }),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          ),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Keluar'),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _combinedNews(_DashboardData data) {
    return [
      ...data.informasi.map((item) => {...item, '_kind': 'Pengumuman'}),
      ...data.berita.map((item) => {...item, '_kind': 'Berita'}),
    ];
  }

  void _openModule(BuildContext context, String module) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ModulePage(module: module, npm: widget.npm, user: widget.user),
      ),
    );
  }

  bool snapshotLoading(_DashboardData _) => _cached == null;
}

class ModulePage extends StatefulWidget {
  const ModulePage({
    super.key,
    required this.module,
    required this.npm,
    required this.user,
  });
  final String module;
  final String npm;
  final Map<String, dynamic> user;

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
  final _api = AcademicApi();
  late Future<List<Map<String, dynamic>>> _future;
  late _Feature _feature;
  List<Map<String, dynamic>> _items = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _feature =
        _features[widget.module] ??
        _Feature('Akademik', Icons.school_outlined, ink, widget.module);
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    switch (widget.module) {
      case 'khs':
      case 'dhs':
        return _api.nilai(widget.npm);
      case 'krs':
        return _api.krs(widget.npm);
      case 'presensi':
        return _api.kehadiran(
          AcademicApi.text(widget.user, const [
            'id',
            'userid',
            'userId',
          ], fallback: widget.npm),
        );
      case 'keuangan':
        return _api.keuangan(widget.npm);
      case 'bimbingan':
        return _api.bimbingan(widget.npm);
      case 'sertifikat':
        return _api.sertifikat(widget.npm);
      case 'informasi':
        return _api.informasi();
      case 'berita':
        return _api.berita();
      default:
        return _api.mahasiswa(widget.npm);
    }
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _addKrs() async {
    final formKey = GlobalKey<FormState>();
    final code = TextEditingController();
    final classCode = TextEditingController();
    final currentYear = DateTime.now().year;
    final academicYear = DateTime.now().month >= 8
        ? '$currentYear/${currentYear + 1}'
        : '${currentYear - 1}/$currentYear';
    final year = TextEditingController(text: academicYear);
    final semester = TextEditingController(text: 'Ganjil');
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ajukan mata kuliah',
                style: TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _formField(code, 'Kode mata kuliah'),
              const SizedBox(height: 10),
              _formField(classCode, 'Kode kelas'),
              const SizedBox(height: 10),
              _formField(year, 'Tahun akademik'),
              const SizedBox(height: 10),
              _formField(semester, 'Semester'),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Kirim pengajuan'),
              ),
            ],
          ),
        ),
      ),
    );
    if (accepted != true || !mounted) {
      code.dispose();
      classCode.dispose();
      year.dispose();
      semester.dispose();
      return;
    }
    setState(() => _busy = true);
    try {
      await _api.submitKrs(
        npm: widget.npm,
        courseCode: code.text.trim(),
        classCode: classCode.text.trim(),
        academicYear: year.text.trim(),
        semester: semester.text.trim(),
      );
      await _refresh();
      if (mounted) _message('Pengajuan KRS berhasil dikirim.');
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
      code.dispose();
      classCode.dispose();
      year.dispose();
      semester.dispose();
    }
  }

  Widget _formField(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Wajib diisi' : null,
      );

  Future<void> _addAttendance() async {
    final formKey = GlobalKey<FormState>();
    final courseCode = TextEditingController();
    final classCode = TextEditingController();
    final now = DateTime.now();
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Catat kehadiran',
                style: TextStyle(
                  color: ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Presensi dicatat untuk waktu saat ini.',
                style: TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _formField(courseCode, 'Kode mata kuliah'),
              const SizedBox(height: 10),
              _formField(classCode, 'Kode kelas'),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Kirim presensi'),
              ),
            ],
          ),
        ),
      ),
    );
    if (accepted != true || !mounted) {
      courseCode.dispose();
      classCode.dispose();
      return;
    }
    setState(() => _busy = true);
    try {
      await _api.submitKehadiran(
        userId: AcademicApi.text(widget.user, const [
          'id',
          'userid',
          'userId',
        ], fallback: widget.npm),
        courseCode: courseCode.text.trim(),
        classCode: classCode.text.trim(),
        date:
            '${now.year.toString().padLeft(4, '0')}-'
            '${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}',
        time:
            '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}:'
            '${now.second.toString().padLeft(2, '0')}',
      );
      await _refresh();
      if (mounted) _message('Presensi berhasil dicatat.');
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
      courseCode.dispose();
      classCode.dispose();
    }
  }

  Future<void> _addCertificate() async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final type = TextEditingController();
    final category = TextEditingController();
    final organizer = TextEditingController();
    final level = TextEditingController();
    final date = TextEditingController();
    final number = TextEditingController();
    final fileUrl = TextEditingController();
    final controllers = [
      name,
      type,
      category,
      organizer,
      level,
      date,
      number,
      fileUrl,
    ];
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tambah sertifikat',
                  style: TextStyle(
                    color: ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                _formField(name, 'Nama sertifikat'),
                const SizedBox(height: 10),
                _formField(type, 'Jenis sertifikat'),
                const SizedBox(height: 10),
                _formField(category, 'Kategori'),
                const SizedBox(height: 10),
                _formField(organizer, 'Penyelenggara'),
                const SizedBox(height: 10),
                _formField(level, 'Tingkat kegiatan'),
                const SizedBox(height: 10),
                _formField(date, 'Tanggal sertifikat'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: number,
                  decoration: const InputDecoration(
                    labelText: 'Nomor sertifikat',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: fileUrl,
                  decoration: const InputDecoration(
                    labelText: 'Tautan file (opsional)',
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Kirim sertifikat'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (accepted != true || !mounted) {
      for (final controller in controllers) {
        controller.dispose();
      }
      return;
    }
    setState(() => _busy = true);
    try {
      await _api.createSertifikat(
        npm: widget.npm,
        name: name.text.trim(),
        type: type.text.trim(),
        category: category.text.trim(),
        organizer: organizer.text.trim(),
        level: level.text.trim(),
        date: date.text.trim(),
        number: number.text.trim(),
        fileUrl: fileUrl.text.trim(),
      );
      await _refresh();
      if (mounted) _message('Sertifikat berhasil dikirim.');
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
      for (final controller in controllers) {
        controller.dispose();
      }
    }
  }

  Future<void> _deleteKrs(Map<String, dynamic> item) async {
    final id = AcademicApi.text(item, const ['id']);
    if (id.isEmpty) {
      _message('Data KRS tidak memiliki ID yang bisa dihapus.');
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus mata kuliah?'),
        content: const Text('Pengajuan KRS ini akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      await _api.deleteKrs(id);
      await _refresh();
      if (mounted) _message('Mata kuliah berhasil dihapus.');
    } on ApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_feature.label)),
      floatingActionButton:
          const ['krs', 'presensi', 'sertifikat'].contains(widget.module)
          ? FloatingActionButton.extended(
              onPressed: _busy
                  ? null
                  : switch (widget.module) {
                      'krs' => _addKrs,
                      'presensi' => _addAttendance,
                      _ => _addCertificate,
                    },
              backgroundColor: ink,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(switch (widget.module) {
                'krs' => 'Ajukan KRS',
                'presensi' => 'Catat presensi',
                _ => 'Tambah sertifikat',
              }),
            )
          : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final error = snapshot.error;
            return _ErrorState(
              message: error is ApiException
                  ? error.message
                  : 'Data belum bisa dimuat.',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: ink));
          }
          _items = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _items.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 70),
                      _EmptyCard(message: _emptyMessage(widget.module)),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
                    children: [
                      if (widget.module == 'khs' || widget.module == 'dhs')
                        _resultSummary(_items),
                      ..._items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DataCard(
                            item: item,
                            module: widget.module,
                            onDelete: widget.module == 'krs'
                                ? () => _deleteKrs(item)
                                : null,
                          ),
                        ),
                      ),
                      if (_busy)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: CircularProgressIndicator(color: ink),
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _resultSummary(List<Map<String, dynamic>> items) => Container(
    padding: const EdgeInsets.all(17),
    margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(
      color: ink,
      borderRadius: BorderRadius.circular(19),
    ),
    child: Row(
      children: [
        Expanded(
          child: _StatValue(
            label: 'Rata-rata nilai',
            value: AcademicApi.average(items) == 0
                ? '—'
                : AcademicApi.average(items).toStringAsFixed(2),
          ),
        ),
        Container(height: 35, width: 1, color: const Color(0x33FFFFFF)),
        Expanded(
          child: _StatValue(
            label: 'Total SKS',
            value: '${AcademicApi.credits(items)}',
          ),
        ),
        Container(height: 35, width: 1, color: const Color(0x33FFFFFF)),
        Expanded(
          child: _StatValue(label: 'Mata kuliah', value: '${items.length}'),
        ),
      ],
    ),
  );
}

class _DashboardData {
  const _DashboardData({
    required this.mahasiswa,
    required this.nilai,
    required this.berita,
    required this.informasi,
  });
  const _DashboardData.empty()
    : mahasiswa = const {},
      nilai = const [],
      berita = const [],
      informasi = const [];

  final Map<String, dynamic> mahasiswa;
  final List<Map<String, dynamic>> nilai;
  final List<Map<String, dynamic>> berita;
  final List<Map<String, dynamic>> informasi;
}

class _Feature {
  const _Feature(this.label, this.icon, this.color, this.id);
  final String label;
  final IconData icon;
  final Color color;
  final String id;
}

const _features = <String, _Feature>{
  'khs': _Feature(
    'Kartu Hasil Studi',
    Icons.insert_chart_outlined_rounded,
    Color(0xFF4A78C2),
    'khs',
  ),
  'krs': _Feature(
    'Kartu Rencana Studi',
    Icons.edit_calendar_outlined,
    Color(0xFFB7832F),
    'krs',
  ),
  'presensi': _Feature(
    'Kehadiran',
    Icons.fact_check_outlined,
    Color(0xFF389982),
    'presensi',
  ),
  'keuangan': _Feature(
    'Keuangan mahasiswa',
    Icons.account_balance_wallet_outlined,
    Color(0xFF5574AE),
    'keuangan',
  ),
  'bimbingan': _Feature(
    'Bimbingan akademik',
    Icons.forum_outlined,
    Color(0xFF8A68A8),
    'bimbingan',
  ),
  'sertifikat': _Feature(
    'Sertifikat',
    Icons.workspace_premium_outlined,
    Color(0xFFC65D57),
    'sertifikat',
  ),
  'informasi': _Feature(
    'Informasi kampus',
    Icons.campaign_outlined,
    Color(0xFF389982),
    'informasi',
  ),
  'berita': _Feature(
    'Berita kampus',
    Icons.article_outlined,
    Color(0xFF4A78C2),
    'berita',
  ),
  'dhs': _Feature(
    'DHS / riwayat studi',
    Icons.history_edu_outlined,
    Color(0xFF8A68A8),
    'dhs',
  ),
};

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onAction,
  });
  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      TextButton(
        onPressed: onAction,
        style: TextButton.styleFrom(
          foregroundColor: ink,
          visualDensity: VisualDensity.compact,
        ),
        child: Text(action, style: const TextStyle(fontSize: 12)),
      ),
    ],
  );
}

class _StatValue extends StatelessWidget {
  const _StatValue({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 11),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFFC9D2DF), fontSize: 10),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature, required this.onTap});
  final _Feature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: const Color(0xFFEEF0F4)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: feature.color.withValues(alpha: .11),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(feature.icon, color: feature.color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                feature.label,
                style: const TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      ),
    ),
  );
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final title = AcademicApi.text(item, const [
      'judul',
      'title',
      'nama',
      'subject',
    ], fallback: 'Informasi kampus');
    final description = AcademicApi.text(item, const [
      'deskripsi',
      'isi',
      'konten',
      'content',
      'ringkasan',
      'body',
    ], fallback: 'Pilih untuk melihat informasi lebih lanjut.');
    final type = AcademicApi.text(item, const [
      '_kind',
      'kategori',
      'type',
    ], fallback: 'Pengumuman');
    final date = AcademicApi.text(item, const [
      'tanggal',
      'createdAt',
      'created_at',
      'date',
    ]);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF0F4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.campaign_outlined, color: ink, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF9A7621),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .7,
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          date,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: muted, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({required this.item, required this.module, this.onDelete});
  final Map<String, dynamic> item;
  final String module;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final titleKeys = switch (module) {
      'krs' => const ['nama_matkul', 'matkul', 'mata_kuliah', 'kd_matkul'],
      'presensi' => const ['nama_matkul', 'matkul', 'mata_kuliah', 'tanggal'],
      'keuangan' => const ['nama_pembayaran', 'jenis', 'nama', 'keterangan'],
      'bimbingan' => const ['dosen', 'nama_dosen', 'judul', 'perihal'],
      'sertifikat' => const ['nama_sertifikat', 'nama', 'judul', 'kegiatan'],
      'khs' ||
      'dhs' => const ['nama_matkul', 'matkul', 'mata_kuliah', 'kd_matkul'],
      _ => const ['judul', 'nama', 'title', 'name'],
    };
    final title = AcademicApi.text(item, titleKeys, fallback: 'Data akademik');
    final subtitle = item.entries
        .where(
          (entry) =>
              !const [
                'id',
                'npm',
                'userid',
              ].contains(entry.key.toLowerCase()) &&
              entry.value != null &&
              entry.value is! Map &&
              entry.value is! List,
        )
        .where((entry) => entry.key != 'nama' && entry.key != 'title')
        .take(3)
        .map((entry) => '${_humanize(entry.key)}: ${entry.value}')
        .join('  ·  ');
    final result = AcademicApi.text(item, const [
      'nilai_huruf',
      'grade',
      'nilai',
      'huruf',
    ]);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEEF0F4)),
      ),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            decoration: BoxDecoration(
              color:
                  _features[module]?.color.withValues(alpha: .11) ??
                  gold.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _features[module]?.icon ?? Icons.school_outlined,
              color: _features[module]?.color ?? ink,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (result.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                result,
                style: const TextStyle(color: ink, fontWeight: FontWeight.w800),
              ),
            ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Hapus',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Color(0xFFB63D45)),
            ),
        ],
      ),
    );
  }

  String _humanize(String key) => key
      .replaceAll('_', ' ')
      .replaceFirstMapped(
        RegExp(r'^[a-z]'),
        (match) => match[0]!.toUpperCase(),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFEEF0F4)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: muted, fontSize: 13),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(24),
    child: Center(child: CircularProgressIndicator(color: ink)),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEEF0F4)),
    ),
    child: Column(
      children: [
        const Icon(Icons.inbox_outlined, color: muted, size: 30),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 13),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, color: muted, size: 38),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba lagi'),
          ),
        ],
      ),
    ),
  );
}

String _emptyMessage(String module) => switch (module) {
  'krs' => 'Belum ada mata kuliah terdaftar.',
  'presensi' => 'Belum ada riwayat kehadiran.',
  'keuangan' => 'Belum ada data pembayaran.',
  'bimbingan' => 'Belum ada informasi bimbingan.',
  'sertifikat' => 'Belum ada sertifikat.',
  'khs' || 'dhs' => 'Data nilai belum tersedia.',
  _ => 'Belum ada data untuk ditampilkan.',
};
