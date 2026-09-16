import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import 'routes/corredor_mala_lima.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _initialized = false;

  DatabaseHelper._internal();

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  static void initFfi() {
    ensureInitialized();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    await ensureInitialized();
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'centro_control_vip.db');

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Unidades
    await db.execute('''
      CREATE TABLE unidades (
        id TEXT PRIMARY KEY,
        codigo TEXT UNIQUE NOT NULL,
        placa TEXT,
        marca TEXT,
        modelo TEXT,
        anio INTEGER,
        chasis TEXT,
        motor TEXT,
        odometro_km INTEGER,
        capacidad_pasajeros INTEGER,
        tanque_litros INTEGER,
        presion_nominal_psi INTEGER,
        tipo_servicio TEXT,
        estado TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        sha256 TEXT,
        sync_status TEXT
      );
    ''');

    // 2. Conductores
    await db.execute('''
      CREATE TABLE conductores (
        id TEXT PRIMARY KEY,
        codigo TEXT UNIQUE NOT NULL,
        nombres TEXT,
        apellidos TEXT,
        dni TEXT UNIQUE,
        licencia_numero TEXT,
        licencia_categoria TEXT,
        licencia_vencimiento TEXT,
        telefono TEXT,
        estado TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        sha256 TEXT,
        sync_status TEXT
      );
    ''');

    // 3. Rutas
    await db.execute('''
      CREATE TABLE rutas (
        id TEXT PRIMARY KEY,
        codigo TEXT UNIQUE,
        nombre TEXT,
        corredor TEXT,
        origen TEXT,
        destino TEXT,
        distancia_km REAL,
        duracion_min INTEGER,
        polyline TEXT,
        activa INTEGER,
        sync_status TEXT
      );
    ''');

    // 4. Despachos
    await db.execute('''
      CREATE TABLE despachos (
        id TEXT PRIMARY KEY,
        codigo TEXT UNIQUE NOT NULL,
        unidad_id TEXT,
        conductor_id TEXT,
        ruta_id TEXT,
        anden_id TEXT,
        salida_prog TEXT,
        salida_real TEXT,
        desviacion_min INTEGER,
        tipo_servicio TEXT,
        sync TEXT,
        uuid TEXT,
        ultimo_checkpoint_id TEXT,
        progreso_ruta REAL,
        created_at TEXT,
        sha256 TEXT
      );
    ''');

    // 5. Andenes
    await db.execute('''
      CREATE TABLE andenes (
        id TEXT PRIMARY KEY,
        numero TEXT UNIQUE,
        estado TEXT,
        despacho_actual_id TEXT,
        sync_status TEXT
      );
    ''');

    // 6. Checkpoints
    await db.execute('''
      CREATE TABLE checkpoints (
        id TEXT PRIMARY KEY,
        codigo TEXT,
        nombre TEXT,
        lat REAL,
        lng REAL,
        km REAL,
        orden INTEGER,
        ruta_id TEXT,
        sync_status TEXT
      );
    ''');

    // 7. Reportes Checkpoint
    await db.execute('''
      CREATE TABLE reportes_checkpoint (
        id TEXT PRIMARY KEY,
        despacho_id TEXT,
        checkpoint_id TEXT,
        timestamp_local TEXT,
        lat_reportada REAL,
        lng_reportada REAL,
        origen TEXT,
        sync_status TEXT,
        sha256 TEXT
      );
    ''');

    // 8. Restricciones
    await db.execute('''
      CREATE TABLE restricciones (
        id TEXT PRIMARY KEY,
        codigo TEXT,
        motivo TEXT,
        km REAL,
        severidad TEXT,
        activa INTEGER,
        created_at TEXT,
        sync_status TEXT
      );
    ''');

    // 9. Cola Sync
    await db.execute('''
      CREATE TABLE cola_sync (
        id TEXT PRIMARY KEY,
        entidad TEXT,
        entidad_id TEXT,
        accion TEXT,
        payload_json TEXT,
        intentos INTEGER,
        proximo_intento TEXT,
        ultimo_error TEXT,
        created_at TEXT
      );
    ''');

    // 10. Bitácora de Transacciones
    await db.execute('''
      CREATE TABLE bitacora_transacciones (
        id TEXT PRIMARY KEY,
        entidad TEXT,
        entidad_id TEXT,
        accion TEXT,
        payload TEXT,
        sha256 TEXT,
        created_at TEXT
      );
    ''');

    // 11. Preferencias
    await db.execute('''
      CREATE TABLE preferencias (
        clave TEXT PRIMARY KEY,
        valor TEXT
      );
    ''');

    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    const uuid = Uuid();
    final now = DateTime.now().toIso8601String();

    // Preferencias iniciales (Tema Claro por defecto)
    await db.insert('preferencias', {'clave': 'theme_mode', 'valor': 'light'});
    await db.insert('preferencias', {'clave': 'auth_token', 'valor': 'BEARER_VIP_AUTH_2026'});
    await db.insert('preferencias', {'clave': 'sync_url', 'valor': 'https://api.controlvip.pe/sync'});

    // 14 Waypoints obligatorios del Corredor Mala — Lima
    for (final wp in CorredorMalaLima.waypoints) {
      await db.insert('checkpoints', {
        'id': 'CHK-${wp.codigo}',
        'codigo': wp.codigo,
        'nombre': wp.nombre,
        'lat': wp.lat,
        'lng': wp.lng,
        'km': wp.km,
        'orden': wp.orden,
        'ruta_id': CorredorMalaLima.rutaId,
        'sync_status': 'OK',
      });
    }

    // Ruta Mala — Lima
    await db.insert('rutas', {
      'id': CorredorMalaLima.rutaId,
      'codigo': 'R-01',
      'nombre': CorredorMalaLima.rutaNombre,
      'corredor': CorredorMalaLima.corredorNombre,
      'origen': 'Terminal Terrestre de Mala',
      'destino': 'Terminal Grau (La Victoria, Lima)',
      'distancia_km': 90.0,
      'duracion_min': 95,
      'polyline': jsonEncode(CorredorMalaLima.waypoints.map((w) => {'lat': w.lat, 'lng': w.lng}).toList()),
      'activa': 1,
      'sync_status': 'OK',
    });

    // Andenes 01 a 12
    for (int i = 1; i <= 12; i++) {
      final numStr = i.toString().padLeft(2, '0');
      await db.insert('andenes', {
        'id': 'ANDEN-$numStr',
        'numero': numStr,
        'estado': (i == 1 || i == 2) ? 'DISPONIBLE' : (i == 5 ? 'MANTENIMIENTO' : 'DISPONIBLE'),
        'despacho_actual_id': null,
        'sync_status': 'OK',
      });
    }

    // Unidades de flota inicial
    final unidadesIniciales = [
      {
        'codigo': 'BUS-VIP-101',
        'placa': 'B9X-721',
        'marca': 'Scania',
        'modelo': 'Touring HD 6x2',
        'anio': 2024,
        'chasis': '9BSK4X200PB129410',
        'motor': 'DC13 141 450HP Euro VI',
        'odometro_km': 48500,
        'capacidad_pasajeros': 42,
        'tanque_litros': 400,
        'presion_nominal_psi': 118,
        'tipo_servicio': 'VIP EXPRESS',
        'estado': 'enAnden',
      },
      {
        'codigo': 'BUS-VIP-102',
        'placa': 'C4K-819',
        'marca': 'Volvo',
        'modelo': 'B430R I-Shift Suite',
        'anio': 2024,
        'chasis': 'YV3R86200PA884102',
        'motor': 'D11C 430HP Euro VI',
        'odometro_km': 92300,
        'capacidad_pasajeros': 44,
        'tanque_litros': 420,
        'presion_nominal_psi': 120,
        'tipo_servicio': 'VIP PREMIUM',
        'estado': 'enRuta',
      },
      {
        'codigo': 'BUS-VIP-103',
        'placa': 'A1M-902',
        'marca': 'Mercedes-Benz',
        'modelo': 'O500 RSD 2442',
        'anio': 2023,
        'chasis': '9BM384074KB910231',
        'motor': 'OM 457 LA 420HP',
        'odometro_km': 145000,
        'capacidad_pasajeros': 46,
        'tanque_litros': 400,
        'presion_nominal_psi': 98, // Disparará advertencia PSI
        'tipo_servicio': 'VIP EXPRESS',
        'estado': 'novedad',
      },
      {
        'codigo': 'BUS-VIP-104',
        'placa': 'D7Z-314',
        'marca': 'Volvo',
        'modelo': 'B430R Suite',
        'anio': 2025,
        'chasis': 'YV3R86200RA199201',
        'motor': 'D11C 430HP Euro VI',
        'odometro_km': 28900,
        'capacidad_pasajeros': 40,
        'tanque_litros': 450,
        'presion_nominal_psi': 116,
        'tipo_servicio': 'VIP EXPRESS',
        'estado': 'enRuta',
      },
      {
        'codigo': 'BUS-VIP-105',
        'placa': 'F3W-405',
        'marca': 'Scania',
        'modelo': 'K410 IB 4x2',
        'anio': 2024,
        'chasis': '9BSK4X200PB331902',
        'motor': 'DC13 410HP',
        'odometro_km': 64100,
        'capacidad_pasajeros': 44,
        'tanque_litros': 380,
        'presion_nominal_psi': 115,
        'tipo_servicio': 'VIP CARGO',
        'estado': 'enAnden',
      },
    ];

    for (final u in unidadesIniciales) {
      final id = uuid.v4();
      final hash = sha256.convert(utf8.encode('${u['codigo']}_$now')).toString();
      await db.insert('unidades', {
        'id': id,
        'codigo': u['codigo'],
        'placa': u['placa'],
        'marca': u['marca'],
        'modelo': u['modelo'],
        'anio': u['anio'],
        'chasis': u['chasis'],
        'motor': u['motor'],
        'odometro_km': u['odometro_km'],
        'capacidad_pasajeros': u['capacidad_pasajeros'],
        'tanque_litros': u['tanque_litros'],
        'presion_nominal_psi': u['presion_nominal_psi'],
        'tipo_servicio': u['tipo_servicio'],
        'estado': u['estado'],
        'created_at': now,
        'updated_at': now,
        'deleted_at': null,
        'sha256': hash,
        'sync_status': 'OK',
      });
    }

    // Conductores iniciales
    final conductoresIniciales = [
      {
        'codigo': 'OP-629',
        'nombres': 'Carlos Eduardo',
        'apellidos': 'Mendoza Valdivia',
        'dni': '42819032',
        'licencia_numero': 'Q42819032',
        'licencia_categoria': 'A-IIIC',
        'licencia_vencimiento': '2028-11-15',
        'telefono': '984120932',
        'estado': 'DESCANSADO',
      },
      {
        'codigo': 'OP-112',
        'nombres': 'Renzo Fabricio',
        'apellidos': 'Quispe Farfán',
        'dni': '45109281',
        'licencia_numero': 'Q45109281',
        'licencia_categoria': 'A-IIIC',
        'licencia_vencimiento': '2027-08-20',
        'telefono': '991823019',
        'estado': 'ACTIVO',
      },
      {
        'codigo': 'OP-992',
        'nombres': 'Marco Aurelio',
        'apellidos': 'Tapia Salazar',
        'dni': '40912837',
        'licencia_numero': 'Q40912837',
        'licencia_categoria': 'A-IIIC',
        'licencia_vencimiento': '2026-09-25', // Alerta por vencer (< 30 días)
        'telefono': '972301928',
        'estado': 'DESCANSADO',
      },
      {
        'codigo': 'OP-331',
        'nombres': 'Víctor Manuel',
        'apellidos': 'Benavides Luna',
        'dni': '43920194',
        'licencia_numero': 'Q43920194',
        'licencia_categoria': 'A-IIIB',
        'licencia_vencimiento': '2029-01-10',
        'telefono': '962019482',
        'estado': 'ACTIVO',
      },
      {
        'codigo': 'OP-440',
        'nombres': 'David Fernando',
        'apellidos': 'Thorne Morales',
        'dni': '41092847',
        'licencia_numero': 'Q41092847',
        'licencia_categoria': 'A-IIIC',
        'licencia_vencimiento': '2026-01-01', // Vencida
        'telefono': '951092837',
        'estado': 'LICENCIA',
      },
    ];

    for (final c in conductoresIniciales) {
      final id = uuid.v4();
      final hash = sha256.convert(utf8.encode('${c['codigo']}_$now')).toString();
      await db.insert('conductores', {
        'id': id,
        'codigo': c['codigo'],
        'nombres': c['nombres'],
        'apellidos': c['apellidos'],
        'dni': c['dni'],
        'licencia_numero': c['licencia_numero'],
        'licencia_categoria': c['licencia_categoria'],
        'licencia_vencimiento': c['licencia_vencimiento'],
        'telefono': c['telefono'],
        'estado': c['estado'],
        'created_at': now,
        'updated_at': now,
        'deleted_at': null,
        'sha256': hash,
        'sync_status': 'OK',
      });
    }

    // Restricción vial inicial
    await db.insert('restricciones', {
      'id': 'REST-01',
      'codigo': 'CHK-SUR-110',
      'motivo': 'Mantenimiento Preventivo de Calzada km 46 (San Bartolo). Reducción de carril.',
      'km': 46.0,
      'severidad': 'MODERADA',
      'activa': 1,
      'created_at': now,
      'sync_status': 'OK',
    });

    // Despacho inicial activo en ruta sobre el corredor Mala — Lima
    final unidadList = await db.query('unidades', where: 'codigo = ?', whereArgs: ['BUS-VIP-102']);
    final conductorList = await db.query('conductores', where: 'codigo = ?', whereArgs: ['OP-112']);
    if (unidadList.isNotEmpty && conductorList.isNotEmpty) {
      final dspId = uuid.v4();
      final dspHash = sha256.convert(utf8.encode('DSP-202609-0941_$now')).toString();
      await db.insert('despachos', {
        'id': dspId,
        'codigo': 'DSP-202609-0941',
        'unidad_id': unidadList.first['id'] as String,
        'conductor_id': conductorList.first['id'] as String,
        'ruta_id': CorredorMalaLima.rutaId,
        'anden_id': 'ANDEN-02',
        'salida_prog': '22:30:00',
        'salida_real': '22:31:14',
        'desviacion_min': 1,
        'tipo_servicio': 'VIP EXPRESS',
        'sync': 'OK',
        'uuid': uuid.v4(),
        'ultimo_checkpoint_id': 'CHK-CHILCA',
        'progreso_ruta': 0.42, // Entre Chilca y Pucusana
        'created_at': now,
        'sha256': dspHash,
      });

      await db.update(
        'andenes',
        {'estado': 'OCUPADO', 'despacho_actual_id': dspId},
        where: 'id = ?',
        whereArgs: ['ANDEN-02'],
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
