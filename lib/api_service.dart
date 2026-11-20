import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AcademicApi {
  static const _mainHost =
      'https://6adab9277512f497b30020ef.mockapi.io';
  static const _studentHost =
      'https://6aed363dfc3b911e6fd60ab2.mockapi.io';
  static const _timeout = Duration(seconds: 15);
  static String get _currentAcademicYear {
    final now = DateTime.now();
    return now.month >= 8
        ? '${now.year}/${now.year + 1}'
        : '${now.year - 1}/${now.year}';
  }

  static String get _currentSemester =>
      DateTime.now().month >= 8 ? 'Ganjil' : 'Genap';

  final http.Client _client;

  AcademicApi({http.Client? client}) : _client = client ?? http.Client();

  void close() => _client.close();

  Future<Map<String, dynamic>?> login({
    required String npm,
    required String password,
  }) async {
    final passwordHash = sha1.convert(utf8.encode(password)).toString();
    late final List<Map<String, dynamic>> users;
    try {
      users = await _getList(
        '$_mainHost/user',
        query: {'userid': npm, 'pass_sha1': passwordHash},
      );
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
    for (final user in users) {
      final role = '${user['roleid'] ?? ''}';
      final status = '${user['status'] ?? '1'}';
      final active = '${user['aktif'] ?? '1'}';
      if (role == '14' && status != '0' && active != '0') return user;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> mahasiswa(String npm) =>
      _byNpm(_studentHost, 'mahasiswa', npm);

  Future<List<Map<String, dynamic>>> nilai(String npm) =>
      _byNpm(_mainHost, 'nilai', npm);

  Future<List<Map<String, dynamic>>> krs(String npm) =>
      _byNpm(_studentHost, 'krs', npm);

  Future<List<Map<String, dynamic>>> kehadiran(String userId) =>
      _getList('$_mainHost/kehadiran', query: {'userid': userId});

  Future<List<Map<String, dynamic>>> keuangan(String npm) =>
      _byNpm(_mainHost, 'fin_mhs_payment', npm);

  Future<List<Map<String, dynamic>>> bimbingan(String npm) =>
      _byNpm(_mainHost, 'bimbingan_data', npm);

  Future<List<Map<String, dynamic>>> informasi() =>
      _getList('$_mainHost/informasi');

  Future<List<Map<String, dynamic>>> berita() =>
      _getList('$_mainHost/berita');

  Future<List<Map<String, dynamic>>> sertifikat(String npm) =>
      _byNpm(_mainHost, 'sertifikat', npm);

  Future<Map<String, dynamic>> submitKrs({
    required String npm,
    required String courseCode,
    required String classCode,
    required String academicYear,
    required String semester,
  }) =>
      _post('$_studentHost/krs', {
        'npm': npm,
        'kd_matkul': courseCode,
        'kd_kelas': classCode,
        'thn_akademik': academicYear,
        'semester': semester,
        'thn_akademik_now': _currentAcademicYear,
        'semester_now': _currentSemester,
        'status': 0,
      });

  Future<Map<String, dynamic>> submitKehadiran({
    required String userId,
    required String courseCode,
    required String classCode,
    required String date,
    required String time,
  }) =>
      _post('$_mainHost/kehadiran', {
        'userid': userId,
        'kd_matkul': courseCode,
        'kd_kelas': classCode,
        'tanggal': date,
        'jam_login': time,
        'keterangan': 'Hadir',
      });

  Future<Map<String, dynamic>> createSertifikat({
    required String npm,
    required String name,
    required String type,
    required String category,
    required String organizer,
    required String level,
    required String date,
    required String number,
    required String fileUrl,
  }) =>
      _post('$_mainHost/sertifikat', {
        'npm': npm,
        'nama_sertifikat': name,
        'jenis_sertifikat': type,
        'kategori_sertifikat': category,
        'penyelenggara': organizer,
        'tingkat_kegiatan': level,
        'tanggal_sertifikat': date,
        'nomor_sertifikat': number,
        'file_sertifikat': fileUrl,
        'status_verifikasi': 'Menunggu',
      });

  Future<void> deleteKrs(String id) async {
    final uri = Uri.parse('$_studentHost/krs/${Uri.encodeComponent(id)}');
    final response = await _send(() => _client.delete(uri));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(_errorMessage(response));
    }
  }

  Future<List<Map<String, dynamic>>> _byNpm(
    String host,
    String endpoint,
    String npm,
  ) =>
      _getList('$host/$endpoint', query: {'npm': npm});

  Future<List<Map<String, dynamic>>> _getList(
    String endpoint, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse(endpoint).replace(queryParameters: query);
    final response = await _send(() => _client.get(uri));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(response),
        statusCode: response.statusCode,
      );
    }
    final decoded = _decode(response.body);
    if (decoded is! List) {
      throw const ApiException('Format data dari server tidak sesuai.');
    }
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> _post(
    String endpoint,
    Map<String, Object?> body,
  ) async {
    final uri = Uri.parse(endpoint);
    final response = await _send(
      () => _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(
        _errorMessage(response),
        statusCode: response.statusCode,
      );
    }
    final decoded = _decode(response.body);
    if (decoded is! Map) {
      throw const ApiException('Respons server tidak sesuai.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('Server terlalu lama merespons. Coba lagi.');
    } on http.ClientException {
      throw const ApiException('Tidak dapat terhubung ke server.');
    } on FormatException {
      throw const ApiException('Alamat server tidak valid.');
    }
  }

  Object? _decode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const ApiException('Respons server tidak dapat dibaca.');
    }
  }

  String _errorMessage(http.Response response) {
    if (response.statusCode == 404) {
      return 'Data tidak ditemukan di server.';
    }
    if (response.statusCode >= 500) {
      return 'Server sedang bermasalah. Coba lagi nanti.';
    }
    return 'Permintaan gagal (kode ${response.statusCode}).';
  }

  static String text(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && '$value'.trim().isNotEmpty) return '$value';
    }
    return fallback;
  }

  static int credits(List<Map<String, dynamic>> records) {
    return records.fold<int>(0, (total, record) {
      final value = text(record, const ['sks', 'jumlah_sks', 'credit']);
      return total + (int.tryParse(value) ?? 0);
    });
  }

  static double average(List<Map<String, dynamic>> records) {
    var total = 0.0;
    var count = 0;
    for (final record in records) {
      final raw = text(record,
          const ['nilai_angka', 'nilai_mutu', 'grade_point', 'nilai', 'grade']);
      final numeric = double.tryParse(raw);
      final point = numeric ?? _gradePoint(raw);
      if (point == null) continue;
      total += point;
      count++;
    }
    return count == 0 ? 0 : total / count;
  }

  static double? _gradePoint(String grade) {
    const points = {
      'A': 4.0,
      'A-': 3.7,
      'AB': 3.5,
      'B+': 3.5,
      'B': 3.0,
      'B-': 2.7,
      'BC': 2.5,
      'C+': 2.5,
      'C': 2.0,
      'D': 1.0,
      'E': 0.0,
    };
    return points[grade.trim().toUpperCase()];
  }
}
