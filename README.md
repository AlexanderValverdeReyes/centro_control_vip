# centro_control_vip
# Sistema de Gestión de Despacho y Monitoreo de Flota Interprovincial

Sistema de escritorio integral para el control operativo de terminales terrestres, despacho de unidades vehiculares, seguimiento por puntos de control e indicadores de rendimiento (KPIs). Desarrollado en Flutter para Windows bajo arquitectura *Offline-First* con persistencia transaccional local.

---

## 1. Stack Tecnológico

* **Framework:** Flutter (Desktop)
* **Lenguaje:** Dart
* **Base de datos local:** SQLite
* **Patrón de persistencia:** Offline-First con sincronización diferida
* **Plataforma objetivo:** Windows (x64)

---

## 2. Módulos del Sistema

### 2.1. Centro de Control Operativo y KPIs
* **Filtro y rastreo de unidades:** Búsqueda y discriminación inmediata por estado (en andén, en tránsito, inactivo, mantenimiento).
* **Gestión de andenes:** Control de disponibilidad según modalidad de ruta (servicio directo o regular con escalas).
* **Gestión de incidencias:** Notificaciones operativas de demoras y contingencias en ruta.
* **Métricas clave (KPIs):**
  * Conteo de flota activa y en circulación.
  * Tasa de cumplimiento de itinerario (umbral de 2.5 horas por trayecto).
  * Control de disponibilidad de conductores según descansos reglamentarios.

### 2.2. Módulo de Despacho
* Selección de corredor operativo (Mala – Lima / Lima – Mala).
* Asignación validada de unidad vehicular, conductor habilitado y andén de embarque.
* Registro y confirmación del despacho con marca temporal inmutable.

### 2.3. Monitoreo Cartográfico 2D y Telemetría por Hitos
* Seguimiento visual del progreso mediante hitos secuenciales de control (checkpoints).
* Estimación de telemetría: cálculo de porcentaje de trayecto recorrido y velocidad relativa entre intervalos de control.

### 2.4. Gestión de Flota y Personal
* **Conductores:** Registro de código interno, DNI, nombres, número/categoría de licencia de conducir y horas acumuladas de descanso semanal.
* **Unidades vehiculares:** Registro de código interno, placa, marca, modelo, año, capacidad nominal de pasajeros, presión de neumáticos (PSI) y lectura de odómetro (km).

### 2.5. Registro Histórico y Auditoría
* Tabla histórica de despachos registrados de forma local.
* Persistencia en SQLite sin dependencia de conectividad externa.
* Esquema preparado para sincronización con bases de datos remotas.

---

## 3. Características de Interfaz (UI/UX)

* Soporte nativo para modo oscuro (Dark Mode) y modo claro (Light Mode).
* Paleta cromática corporativa: Azul real institucional, acentos dorados/amarillos para estados operativos y tipografía blanca de alto contraste.

---

## 4. Instalación y Ejecución

### Prerrequisitos
* Sistema operativo Windows 10 o Windows 11 (64 bits).
* Flutter SDK (versión estable con soporte de escritorio habilitado).
* Visual Studio (Community o superior) con la carga de trabajo **"Desarrollo para el escritorio con C++"** instalada.

### Pasos de ejecución
1. Clonar el repositorio:
   ```bash
   git clone https://github.com/AlexanderValverdeReyes/centro_control_vip.git
2. Obtener las dependencias del proyecto:
   ```bash
   flutter pub get
   ```
3. Ejecutar la aplicación en el emulador o dispositivo físico:
   ```bash
   flutter run
   ```
