import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  String _token = 'BEARER_VIP_AUTH_2026';
  String _baseUrl = 'https://api.controlvip.pe';

  ApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 4);
    _dio.options.receiveTimeout = const Duration(seconds: 4);
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Authorization'] = 'Bearer $_token';
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
      ),
    );
  }

  void updateConfig({String? baseUrl, String? token}) {
    if (baseUrl != null) {
      _baseUrl = baseUrl;
      _dio.options.baseUrl = baseUrl;
    }
    if (token != null) _token = token;
  }

  Future<Response> pushDespachos(List<Map<String, dynamic>> despachos) async {
    return await _dio.post('/sync/despachos', data: {'despachos': despachos});
  }

  Future<Response> pushCheckpoints(List<Map<String, dynamic>> reportes) async {
    return await _dio.post('/sync/checkpoints', data: {'reportes': reportes});
  }

  Future<Response> pushFlota(List<Map<String, dynamic>> items) async {
    return await _dio.post('/sync/flota', data: {'flota': items});
  }

  Future<Response> getCatalogo() async {
    return await _dio.get('/sync/catalogo');
  }

  Future<Response> getEstado() async {
    return await _dio.get('/sync/estado');
  }
}
