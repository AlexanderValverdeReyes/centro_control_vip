# Contexto del Sistema: Centro de Control VIP — Despacho de Transporte Interprovincial

## Entorno y Stack Técnico

Entorno Flutter Desktop nativo para Windows, ejecutado con flutter run -d windows. El sistema es offline-first, pero NO es totalmente offline: mantiene una capa de sincronización diferida que se activa cuando hay conectividad disponible. Toda la interfaz se construye con Flutter puro y Material 3; queda prohibido el uso de HTML, CSS, JavaScript, React, WebView o cualquier motor híbrido. La gestión de estado se realiza con Provider (ChangeNotifier) durante el MVP, con la arquitectura preparada para migrar a Riverpod sin modificar la capa de vistas. La arquitectura sigue el patrón Clean Architecture ligera con carpetas separadas por responsabilidad: models, data, providers, widgets, views y core. No se permite lógica de negocio dentro de los widgets.

## Modelo Operativo: Offline-First con Sincronización Diferida

La aplicación funciona al 100 por ciento aunque no haya internet: todo se lee y se escribe primero en SQLite local y la UI nunca bloquea por red. En paralelo, un motor de sincronización en segundo plano intenta empujar los cambios pendientes hacia el backend cuando detecta conectividad. Si no hay red, los registros quedan marcados con sync igual a PENDING y se reintentan con backoff exponencial (por ejemplo 5s, 15s, 45s, 2min, 5min) hasta un máximo de reintentos. Si el backend rechaza el envío, el registro pasa a FAIL y se muestra en la UI con badge rojo, permitiendo reintento manual desde Registro de Salidas. La sincronización es bidireccional: el cliente empuja despachos, checkpoints reportados, cambios de flota y restricciones, y jala catálogos actualizados (rutas, checkpoints, tarifas, operadores autorizados) desde el servidor.

## Persistencia con SQLite (Real, sin datos simulados)

El sistema NO usa datos simulados. Toda la información se persiste en una base de datos SQLite local a través del paquete sqflite_common_ffi sobre Windows nativo. La base de datos se inicializa al arrancar la aplicación mediante sqfliteFfiInit() y databaseFactory igual a databaseFactoryFfi, y el archivo .db se almacena en la carpeta de documentos de la aplicación usando path_provider. Las entidades mínimas que deben existir como tablas son: unidades, conductores, rutas, despachos, andenes, checkpoints, restricciones, reportes_checkpoint, cola_sync, bitacora_transacciones y preferencias. Cada tabla incluye columnas de auditoría: id (UUID), created_at, updated_at, deleted_at (soft delete), sha256 (firma de integridad) y sync_status (OK, PENDING, FAIL). Toda operación de escritura que afecte a más de una tabla (por ejemplo, crear un despacho y marcar un andén como ocupado) se ejecuta dentro de una transacción atómica con BEGIN y COMMIT. La capa de datos se organiza en tres subniveles: DatabaseHelper (apertura, esquema, migraciones), DAOs por entidad y repositorios que exponen streams reactivos para que el Provider notifique cambios a la UI sin acoplarla a SQLite.

## Gestión de Flota (Módulo Nuevo)

El sistema debe permitir el registro, edición, listado y baja lógica (soft delete) tanto de unidades de transporte como de conductores. Unidades y conductores no son mocks precargados; el usuario los crea desde la interfaz y quedan persistidos en SQLite. Los formularios de alta y edición validan campos obligatorios y evitan duplicidad de código de unidad o de operador.

Datos mínimos de una unidad: codigo con formato BUS-VIP-NNN y restricción UNIQUE, placa, marca, modelo, anio, chasis, motor, odometro_km, capacidad_pasajeros, tanque_litros, presion_nominal_psi, tipo_servicio (VIP EXPRESS, VIP PREMIUM o VIP CARGO), estado (enAnden, enRuta, novedad, mantenimiento, baja) y columnas de auditoría.

Datos mínimos de un conductor: codigo con formato OP-NNN y restricción UNIQUE, nombres, apellidos, dni, licencia_numero, licencia_categoria (A-IIIA, A-IIIB, A-IIIC), licencia_vencimiento, telefono, estado (DESCANSADO, ACTIVO, LICENCIA, BAJA) y columnas de auditoría. El sistema rechaza la asignación de un conductor ACTIVO a un nuevo despacho y advierte cuando la licencia esté próxima a vencer (menos de 30 días) o vencida.

## Rastreo por Checkpoints (Sistema de Señales)

El objetivo operativo es saber en qué punto del corredor va cada unidad. Para lograrlo, el sistema registra señales de paso por checkpoints que se reportan desde distintas fuentes y se persisten localmente antes de intentar la sincronización remota.

Los checkpoints del corredor Mala — Lima y Lima — Mala, en orden geográfico de sur a norte, son: Terminal Terrestre de Mala (TER-MALA), Chilca (CHK-CHILCA), Pucusana (CHK-PUCUSANA), Santa María del Mar (CHK-SM-MAR), San Bartolo (CHK-SAN-BARTOLO), Punta Negra (CHK-PUNTA-NEGRA), Punta Hermosa (CHK-PUNTA-HERMOSA), Lurín (CHK-LURIN), Villa El Salvador (CHK-VES) y Terminal Lima (TER-LIMA). Cada checkpoint tiene un código, nombre, latitud, longitud, kilómetro sobre la carretera 1S y un orden numérico.

Fuentes de señales de paso: la primera es manual desde la tablet o PC del despachador, tocando un botón REPORTAR PASO cuando el bus confirma por radio que pasó por un checkpoint. La segunda es automática desde la propia app cuando el conductor pulsa un botón en una versión móvil futura (fuera del MVP). La tercera es vía GPS del dispositivo si en el futuro se integra, comparando la posición contra el radio de cada checkpoint para disparar el reporte de forma automática. En el MVP solo se implementa la fuente manual, pero la tabla y el flujo están preparados para las otras dos.

Cada reporte de checkpoint crea un registro en la tabla reportes_checkpoint con: id, despacho_id, checkpoint_id, timestamp_local, lat_reportada, lng_reportada, origen (MANUAL, GPS_AUTO, CONDUCTOR), sync_status y sha256. Inmediatamente se actualiza el campo ultimo_checkpoint_id y progreso_ruta (0.0 a 1.0) del despacho correspondiente, y se recalcula el ETA con base en la velocidad promedio del tramo restante.

## Sincronización con Backend

El módulo de rastreo NO es cerrado: está diseñado para enviar señales a un backend remoto cuando haya red. El backend puede ser REST o WebSocket; se asume una API REST mínima con endpoints POST /sync/despachos, POST /sync/checkpoints, POST /sync/flota, GET /sync/catalogo y GET /sync/estado. La autenticación usa un token Bearer guardado en la tabla preferencias, generado en el primer arranque con un dispositivo autorizado. Si el backend aún no está disponible, la app funciona igual y encola todo en la tabla cola_sync.

La tabla cola_sync actúa como outbox: cada fila contiene id, entidad, entidad_id, payload_json, intentos, proximo_intento, ultimo_error y created_at. Un worker interno (SyncEngine) corre cada 30 segundos, detecta conectividad con connectivity_plus, toma hasta 20 filas pendientes ordenadas por created_at, las envía en batch y actualiza el estado. Si falla, incrementa intentos y aplica backoff. Si tiene éxito, marca la fila como sincronizada y actualiza sync_status del registro original a OK. La UI muestra en el Top Header un indicador vivo: verde si todo está sincronizado, naranja si hay pendientes, rojo si hay fallos, y un contador de pendientes en la sidebar.

Para el rastreo específico de checkpoints, el POST /sync/checkpoints envía un array con los reportes locales y el servidor responde con el estado agregado del despacho (progreso, ETA, próximo checkpoint esperado) que la app guarda y muestra en el mapa. Adicionalmente, se puede abrir un canal WebSocket opcional a /ws/rastreo para recibir en vivo las señales de otras unidades del mismo corredor y pintarlas en el mapa sin esperar al siguiente ciclo de polling.

## Reglas de Dominio

Un despacho nunca se crea sin pasar por los cinco pasos del Stepper (Ruta, Unidad, Conductor, Andén, Hora). Cada despacho genera un código único con formato DSP-YYYYMM-NNNN, por ejemplo DSP-202609-0941, y su inserción se confirma con estado COMMIT OK antes de mostrar el modal de éxito. No se puede despachar una unidad en estado novedad o mantenimiento, ni un conductor en estado ACTIVO, LICENCIA o BAJA. Los andenes van del 01 al 12 en la sede TER-LIMA-JVICTORIA; un andén ocupado no puede reasignarse hasta cerrar el despacho anterior. El rango nominal de presión de neumáticos es de 100 a 130 PSI; fuera de ese rango la barra se muestra en naranja o rojo. El nivel de combustible menor a 20 por ciento dispara alerta visual. Toda escritura en despachos y reportes se firma con SHA-256 local antes de intentar la sincronización remota. El estado de sincronización puede ser OK (verde), PENDING (naranja) o FAIL (rojo). El índice OTP tiene meta mayor o igual al 95 por ciento.

## Mapa Estático del Corredor Mala — Lima

El único corredor que se representa en el mapa es Mala — Lima y Lima — Mala, correspondiente a la Carretera Panamericana Sur, Ruta 1S. No se usan Google Maps, Mapbox, flutter_map ni hojas de tiles remotas; queda todo prohibido. La solución es un mapa estático 2D vectorial propio, construido con CustomPainter sobre una imagen de fondo empaquetada como asset que reproduce la silueta de la costa entre Mala y Lima, con opacidad reducida para que las capas vectoriales encima tengan prioridad visual (opacidad 0.15 en modo oscuro, 0.35 en modo claro).

Sobre esa base se dibujan: la polilínea del corredor con trazo grueso azul rey y borde dorado fino; los diez checkpoints y terminales como nodos circulares con etiqueta monoespaciada; el marcador de inicio y fin con iconos de bandera; las unidades en movimiento como pines reposicionados leyendo su progreso (0.0 a 1.0) a lo largo de la polilínea mediante PathMetrics; y una estela o halo en el último checkpoint reportado para indicar por dónde pasó la unidad.

El cálculo de posición sobre la ruta se hace con path.computeMetrics().first.getTangentForOffset(offset * metric.length) para obtener posición y ángulo del pin. El corredor se define en la tabla rutas con un campo polyline que guarda un JSON con la lista de coordenadas lat/lng, y el CustomPainter transforma lat/lng a píxeles del lienzo con una proyección simple de bounding box. El mapa se muestra en la vista Monitoreo 2D en modo detallado y en Sala de Control en modo compacto, reutilizando el mismo CustomPainter con dos configuraciones visuales.

Sí se puede hacer un mapa estático de esa ruta: se recomienda empaquetar una imagen PNG o SVG simplificada de la costa Mala — Lima como asset de fondo, y encima renderizar la polilínea, los checkpoints y los pines de bus con CustomPainter y Positioned. Funciona sin conexión y no requiere APIs externas.

## Tema Claro Primero, con Toggle a Oscuro

El tema por defecto del sistema es claro. Debe existir un botón visible (icono sol o luna) en el Top Header que permita alternar entre modo claro y modo oscuro, y la preferencia se persiste en SQLite en la tabla preferencias. El ThemeMode se expone desde un ThemeProvider dedicado para que MaterialApp lo consuma con themeMode. Se definen dos ThemeData completos: buildLightTheme y buildDarkTheme, construidos ambos desde los mismos tokens semánticos.

Los tokens semánticos se exponen a través de un ThemeExtension llamado AppPalette con campos: primary, onPrimary, secondary, onSecondary, tertiary, onTertiary, neutral, background, surface, surfaceVariant, outline, textoPrincipal, textoSecundario, exito, advertencia, peligro y gold. Los widgets nunca leen colores hex directamente; siempre obtienen el AppPalette desde Theme.of(context).extension. Esto permite que la misma pantalla funcione en claro y oscuro sin condicionales.

## Paleta Corporativa

La paleta base es: Primary #0B3B6F (azul corporativo), Secondary #D4AF37 (dorado corporativo), Tertiary #F5B700 (ámbar de acento), Neutral #1A1A1B (gris muy oscuro de base). Cada color tiene su escala del 50 al 900 para construir estados hover, pressed, disabled y superficies.

Modo Claro por defecto: fondo de aplicación #F7F8FA, superficie de tarjetas #FFFFFF, superficie secundaria #F0F1F4, borde y divisor #E2E4E9, texto principal #1A1A1B, texto secundario #6B7280, texto terciario #9CA3AF. Primary y Secondary se usan tal cual sobre blanco. El dorado y el ámbar se reservan para botones de acción principal, badges de estado y encabezados de sección. El azul primario se usa en botones secundarios, tabs activos, sidebar y navegación.

Modo Oscuro: fondo de aplicación #1A1A1B, superficie de tarjetas #232326, superficie secundaria #2C2C30, borde y divisor #3A3A3E, texto principal #FFFFFF, texto secundario #B0B3B8, texto terciario #7A7D82. Primary #0B3B6F se aclara a #1E5A9E para mantener contraste sobre fondo oscuro. Secondary #D4AF37 y Tertiary #F5B700 se mantienen. El rojo de alerta crítica es #C62828 en claro y #EF5350 en oscuro. El verde de éxito es #2E7D32 en claro y #66BB6A en oscuro. El naranja de advertencia es #EF6C00 en claro y #FFA726 en oscuro.

## Tipografía

Fuente sans-serif Inter con Roboto como fallback para texto narrativo, etiquetas, títulos y cuerpo. Fuente monoespaciada JetBrains Mono para códigos de unidad (BUS-VIP-101), códigos de despacho (DSP-202609-0941), códigos de operador (OP-629), UUIDs, hashes SHA-256, horas HH:mm:ss, telemetría numérica (velocidad, ETA, PSI, odómetro) y cualquier dato técnico. Ambas fuentes se empaquetan como assets. Los estilos tipográficos se definen como TextTheme en ambos temas. La constante kMono se construye dinámicamente desde el tema para respetar el color del modo activo.

## Estructura del Proyecto

main.dart — Punto de entrada, inicialización de SQLite, MultiProvider raíz, MaterialApp con themeMode y arranque del SyncEngine.

core/theme.dart — AppPalette, buildLightTheme, buildDarkTheme y helpers de tipografía.

core/constants.dart — Formatos de código, regex de validación, rutas de assets y constantes de dominio.

core/sync_engine.dart — Worker de sincronización diferida con backoff exponencial.

data/database_helper.dart — Apertura de SQLite, creación de esquema, migraciones y transacciones.

data/dao/unidad_dao.dart — CRUD sobre tabla unidades.

data/dao/conductor_dao.dart — CRUD sobre tabla conductores.

data/dao/ruta_dao.dart — CRUD sobre tabla rutas.

data/dao/despacho_dao.dart — CRUD sobre tabla despachos.

data/dao/anden_dao.dart — CRUD sobre tabla andenes.

data/dao/checkpoint_dao.dart — CRUD sobre tabla checkpoints.

data/dao/reporte_checkpoint_dao.dart — Registro de señales de paso.

data/dao/restriccion_dao.dart — CRUD sobre tabla restricciones.

data/dao/cola_sync_dao.dart — CRUD sobre tabla cola_sync.

data/dao/bitacora_dao.dart — Registro append-only de transacciones firmadas.

data/repositories/flota_repository.dart — Fachada que combina DAOs y expone streams.

data/repositories/despacho_repository.dart — Transacciones atómicas de despacho.

data/repositories/rastreo_repository.dart — Reportes de checkpoint y cálculo de progreso.

data/remote/api_client.dart — Cliente HTTP con dio, interceptores y token.

models/unidad.dart, conductor.dart, ruta.dart, despacho.dart, anden.dart, checkpoint.dart, reporte_checkpoint.dart, restriccion.dart — Modelos con fromMap y toMap.

providers/app_provider.dart — Navegación, filtros y selección activa.

providers/theme_provider.dart — ThemeMode persistido.

providers/flota_provider.dart — Estado de unidades y conductores.

providers/despacho_provider.dart — Estado de despachos y andenes.

providers/rastreo_provider.dart — Estado de progreso por unidad y checkpoints reportados.

providers/sync_provider.dart — Estado del SyncEngine expuesto a la UI.

widgets/sidebar.dart — Menú lateral fijo de 250px con logo, navegación e indicador de sync.

widgets/top_header.dart — Header con terminal, reloj, buscador, toggle de tema y botón NUEVO DESPACHO.

widgets/metric_card.dart — Tarjeta reutilizable.

widgets/unidad_card.dart — Tarjeta Kanban de unidad.

widgets/conductor_card.dart — Tarjeta de conductor con estado de licencia.

widgets/corredor_map.dart — CustomPainter del corredor Mala — Lima.

widgets/checkpoint_button.dart — Botón REPORTAR PASO para el despachador.

widgets/despacho_modal.dart — Modal con Stepper de cinco pasos.

widgets/success_modal.dart — Modal de confirmación con COMMIT OK.

views/sala_control_view.dart — Métricas, Kanban y radar compacto.

views/monitoreo_view.dart — Mapa detallado Mala — Lima, panel de telemetría y reporte de checkpoints.

views/registro_salidas_view.dart — Métricas, filtros, tabla de despachos y expediente.

views/flota_view.dart — Gestión de unidades y conductores.

## Layout Principal Común

Sidebar izquierdo fijo de 250px con logo CONTROL VIP, menú vertical con cinco items (Sala de Control, Módulo de Despacho, Monitoreo 2D, Registro de Salidas, Gestión de Flota) e indicadores inferiores de MODO LOCAL SQLITE, estado de sync y contador de pendientes. El item seleccionado muestra borde izquierdo dorado de 4px y fondo azul rey.

Header superior de 84px con información del terminal activo TER-LIMA-JVICTORIA y andenes 01-12, reloj vivo HH:mm:ss, buscador expandido, botón de toggle de tema, indicador de conectividad y botón dorado NUEVO DESPACHO EXPRESS. La navegación se controla con AppProvider.currentIndex.

## Especificación de Pantallas

Sala de Control: fila superior con cuatro MetricCard (Total Flota, En Terminal, En Tránsito Normal, En Observación) leyendo conteos reales desde SQLite. Centro con Kanban de tres columnas: EN ANDÉN con botón DESPACHAR AHORA, EN RUTA con botón EN SEGUIMIENTO DINÁMICO, NOVEDADES con botón GESTIONAR INCIDENCIA. Parte inferior con radar compacto del corredor Mala — Lima mostrando pines de las unidades activas.

Modal Despacho: Dialog de 780x620 con Stepper vertical de cinco pasos. Paso 1 Ruta, paso 2 Unidad, paso 3 Conductor, paso 4 Andén, paso 5 Hora. Botón inferior dorado en el paso 5: CONFIRMAR DESPACHO Y REGISTRAR EN BITÁCORA.

Modal Éxito: check dorado grande, título ¡DESPACHO ASIGNADO CON ÉXITO!, panel con cinco filas de detalle, banner verde de COMMIT OK, botones SALA DE CONTROL e IMPRIMIR TICKET.

Monitoreo 2D: tabs de corredores con solo MALA — LIMA y LIMA — MALA activos. Banner rojo con restricciones activas. Cuerpo en Row con mapa detallado a la izquierda y panel derecho de 320px con detalle de la unidad. Sobre el mapa, los diez checkpoints clickeables y un botón flotante REPORTAR PASO que abre un selector del checkpoint recién cruzado y lo registra localmente. Métricas inferiores: Velocidad Promedio, Diagnóstico Mecánico y Eficiencia de Consumo, calculadas sobre registros reales.

Registro de Salidas: métricas Despachos de Turno, OTP, Sync Cloud y Custodia SHA-256. Filtros con buscador, dropdown de rutas, dropdown de turnos, filtro adicional por estado de sync y botón EXPORTAR A EXCEL. DataTable con ID Despacho, Código Unidad, Tipo, Ruta, Conductor, Andén, Salida Prog., Salida Real, Desviación y badge de Sync. Doble clic abre el expediente con UUID y SHA-256 y un botón REINTENTAR SYNC si el estado es FAIL.

Gestión de Flota: dos tabs internos UNIDADES y CONDUCTORES. Botones REGISTRAR UNIDAD y REGISTRAR CONDUCTOR que abren formularios modales con validación. Listado con edición y baja lógica. Alertas visuales para licencias vencidas o por vencer.

## Esquema SQLite Propuesto

Tabla unidades: id TEXT PRIMARY KEY, codigo TEXT UNIQUE NOT NULL, placa TEXT, marca TEXT, modelo TEXT, anio INTEGER, chasis TEXT, motor TEXT, odometro_km INTEGER, capacidad_pasajeros INTEGER, tanque_litros INTEGER, presion_nominal_psi INTEGER, tipo_servicio TEXT, estado TEXT, created_at TEXT, updated_at TEXT, deleted_at TEXT, sha256 TEXT, sync_status TEXT.

Tabla conductores: id TEXT PRIMARY KEY, codigo TEXT UNIQUE NOT NULL, nombres TEXT, apellidos TEXT, dni TEXT UNIQUE, licencia_numero TEXT, licencia_categoria TEXT, licencia_vencimiento TEXT, telefono TEXT, estado TEXT, created_at TEXT, updated_at TEXT, deleted_at TEXT, sha256 TEXT, sync_status TEXT.

Tabla rutas: id TEXT PRIMARY KEY, codigo TEXT UNIQUE, nombre TEXT, corredor TEXT, origen TEXT, destino TEXT, distancia_km REAL, duracion_min INTEGER, polyline TEXT, activa INTEGER, sync_status TEXT.

Tabla despachos: id TEXT PRIMARY KEY, codigo TEXT UNIQUE NOT NULL, unidad_id TEXT, conductor_id TEXT, ruta_id TEXT, anden_id TEXT, salida_prog TEXT, salida_real TEXT, desviacion_min INTEGER, tipo_servicio TEXT, sync TEXT, uuid TEXT, ultimo_checkpoint_id TEXT, progreso_ruta REAL, created_at TEXT, sha256 TEXT.

Tabla andenes: id TEXT PRIMARY KEY, numero TEXT UNIQUE, estado TEXT, despacho_actual_id TEXT, sync_status TEXT.

Tabla checkpoints: id TEXT PRIMARY KEY, codigo TEXT, nombre TEXT, lat REAL, lng REAL, km REAL, orden INTEGER, ruta_id TEXT, sync_status TEXT.

Tabla reportes_checkpoint: id TEXT PRIMARY KEY, despacho_id TEXT, checkpoint_id TEXT, timestamp_local TEXT, lat_reportada REAL, lng_reportada REAL, origen TEXT, sync_status TEXT, sha256 TEXT.

Tabla restricciones: id TEXT PRIMARY KEY, codigo TEXT, motivo TEXT, km REAL, severidad TEXT, activa INTEGER, created_at TEXT, sync_status TEXT.

Tabla cola_sync: id TEXT PRIMARY KEY, entidad TEXT, entidad_id TEXT, accion TEXT, payload_json TEXT, intentos INTEGER, proximo_intento TEXT, ultimo_error TEXT, created_at TEXT.

Tabla bitacora_transacciones: id TEXT PRIMARY KEY, entidad TEXT, entidad_id TEXT, accion TEXT, payload TEXT, sha256 TEXT, created_at TEXT.

Tabla preferencias: clave TEXT PRIMARY KEY, valor TEXT.

## Reglas de Código

Todo widget visual debe ser reutilizable. Los colores se leen siempre desde AppPalette del tema activo; queda prohibido escribir colores hexadecimales fuera de core/theme.dart. Todo texto técnico usa la variante monoespaciada del tema. Bordes con BorderRadius.circular de 6 u 8. Espaciado en múltiplos de 4. Sin lógica en build más allá de where o map de presentación. El mapa se construye siempre con CustomPainter y Positioned; prohibido google_maps_flutter, flutter_map y cualquier tile externo. Los diálogos críticos usan showDialog con barrierDismissible en false. Tipografía con fontWeight explícito y letterSpacing entre 1.0 y 1.5 en títulos de sección. Ninguna llamada de red se ejecuta en el hilo de UI; todo pasa por el SyncEngine. Ningún widget hace HTTP directo; siempre a través de repositorios.

## Anti-patrones Rechazados

HTML, CSS, JavaScript embebido, webview_flutter o flutter_html. Google Maps, Mapbox o tiles remotos. setState para estado compartido entre pantallas. Widgets de más de 300 líneas. Colores hexadecimales fuera de core/theme.dart. Botones sin feedback táctil. Datos hardcodeados en las vistas; toda la información viene de SQLite. Llamadas HTTP dentro de widgets o dentro de build. Bloquear la UI esperando red.

## Glosario de Códigos

TER para terminal física (TER-LIMA-JVICTORIA, TER-MALA). CHK para checkpoint en ruta (CHK-LURIN, CHK-PUNTA-NEGRA, CHK-CHILCA, CHK-PUCUSANA, CHK-SAN-BARTOLO, CHK-PUNTA-HERMOSA, CHK-SM-MAR, CHK-VES). BUS-VIP para unidad de flota. OP para conductor. DSP para despacho. R para ruta del catálogo. A para andén.

## Precedencia

Este documento es la fuente de verdad del proyecto. Todo código generado debe respetar la paleta corporativa, el esquema SQLite, el modelo offline-first con sincronización diferida, los contratos de modelos y los anti-patrones aquí definidos. Si hay ambigüedad entre un mockup visual y este documento, prevalece el mockup para layout y este documento para semántica, dominio, persistencia y sincronización.

## Nota sobre el Mapa

El mapa del corredor Mala — Lima es 100 por ciento vectorial, generado por código con CustomPainter. No usa imágenes de fondo, PNG, SVG ni tiles remotos. El catálogo de distritos y localidades del trazado cubre, como mínimo: Mala (terminal), San Antonio, San Andrés, Chilca, Pucusana, Santa María del Mar, San Bartolo, Punta Negra, Punta Hermosa, Lurín, Villa El Salvador, Villa María del Triunfo, San Juan de Miraflores y La Victoria (terminal Grau, Lima). Cada punto se persiste en la tabla checkpoints con código, nombre, latitud, longitud, kilómetro y orden, y el painter proyecta lat/lng a píxeles con un bounding box fijo. Los buses se posicionan sobre la polilínea usando el progreso_ruta del despacho y las métricas del Path. Si en el futuro se agregan más distritos al catálogo, basta con sumarlos a la lista de waypoints en lib/data/routes/corredor_mala_lima.dart y correr la migración; el painter los dibuja automáticamente sin cambios.