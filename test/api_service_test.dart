import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:universitas_boash_academic/api_service.dart';

void main() {
  test('login sends the SHA-1 password filter and accepts active students',
      () async {
    final api = AcademicApi(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/user');
        expect(request.url.queryParameters, {
          'userid': '2026001',
          'pass_sha1': '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8',
        });
        return http.Response(
          jsonEncode([
            {'roleid': 12, 'status': 1},
            {'roleid': 14, 'status': 0},
            {'roleid': 14, 'status': 1, 'userid': '2026001'},
          ]),
          200,
        );
      }),
    );
    addTearDown(api.close);

    final result =
        await api.login(npm: '2026001', password: 'password');

    expect(result?['userid'], '2026001');
  });

  test('login treats a missing filtered user as invalid credentials', () async {
    final api = AcademicApi(
      client: MockClient((request) async => http.Response('', 404)),
    );
    addTearDown(api.close);

    final result =
        await api.login(npm: '2026001', password: 'password');

    expect(result, isNull);
  });

  test('KRS submission sends the API payload', () async {
    final api = AcademicApi(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/krs');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['npm'], '2026001');
        expect(body['kd_matkul'], 'IF101');
        expect(body['kd_kelas'], 'A');
        expect(body['thn_akademik'], '2026/2027');
        expect(body['semester'], 'Ganjil');
        expect(body['status'], 0);
        return http.Response(jsonEncode({'id': '1'}), 201);
      }),
    );
    addTearDown(api.close);

    await api.submitKrs(
      npm: '2026001',
      courseCode: 'IF101',
      classCode: 'A',
      academicYear: '2026/2027',
      semester: 'Ganjil',
    );
  });

  test('attendance and certificate submissions use their API fields',
      () async {
    var requestCount = 0;
    final api = AcademicApi(
      client: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (request.url.path == '/kehadiran') {
          expect(body['userid'], '2026001');
          expect(body['kd_matkul'], 'IF101');
          expect(body['tanggal'], '2026-11-20');
        } else {
          expect(request.url.path, '/sertifikat');
          expect(body['npm'], '2026001');
          expect(body['nama_sertifikat'], 'Seminar Akademik');
          expect(body.containsKey('id_sertifikat'), isFalse);
        }
        requestCount++;
        return http.Response(jsonEncode({'id': '$requestCount'}), 201);
      }),
    );
    addTearDown(api.close);

    await api.submitKehadiran(
      userId: '2026001',
      courseCode: 'IF101',
      classCode: 'A',
      date: '2026-11-20',
      time: '10:00:00',
    );
    await api.createSertifikat(
      npm: '2026001',
      name: 'Seminar Akademik',
      type: 'Seminar',
      category: 'Akademik',
      organizer: 'Universitas',
      level: 'Kampus',
      date: '2026-11-20',
      number: '',
      fileUrl: '',
    );
    expect(requestCount, 2);
  });
}
