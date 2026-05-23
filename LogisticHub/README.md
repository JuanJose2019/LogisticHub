# LogisticHubs — iOS App
**App de Gestión de Sedes Logísticas**  
Universidad Católica de El Salvador | Facultad de Ingeniería y Arquitectura

---

## 📁 Estructura del Proyecto

```
LogisticHubs/
├── App/
│   └── LogisticHubsApp.swift          # Entry point (@main)
│
├── Models/
│   ├── Hub.swift                       # Modelo de dominio (puro, sin dependencias)
│   └── HubDTO.swift                    # DTO de red + mapeo a dominio
│
├── CoreData/
│   ├── LogisticHubs.xcdatamodeld      # Esquema Core Data (crear en Xcode)
│   ├── PersistenceController.swift    # Stack Core Data + operaciones CRUD
│   └── HubEntity+CoreDataClass.swift  # Entidad NSManagedObject + extensiones
│
├── Services/
│   ├── NetworkService.swift            # URLSession async + síncrono
│   ├── HubRepository.swift             # Patrón Repositorio (red + persistencia)
│   ├── MockNetworkService.swift        # Servicio simulado + JSON de prueba
│   └── LocationService.swift          # Core Location wrapper
│
├── ViewModels/
│   ├── HubListViewModel.swift          # Estado de la lista (MVVM)
│   └── HubDetailViewModel.swift       # Estado del detalle + mapa
│
├── Views/
│   ├── List/
│   │   ├── HubListView.swift           # Pantalla principal
│   │   └── HubRowView.swift            # Celda de lista
│   ├── Detail/
│   │   └── HubDetailView.swift         # Pantalla de detalle + mapa
│   └── Components.swift               # Componentes reutilizables
│
├── Utilities/
│   ├── AppError.swift                  # Errores centralizados
│   ├── AppConfiguration.swift         # Constantes de configuración
│   └── L10n.swift                     # Namespace de localización
│
└── Resources/
    ├── Info.plist                     # Permisos y configuración
    └── Localization/
        ├── es.lproj/Localizable.strings   # Español
        └── en.lproj/Localizable.strings   # Inglés
```

---

## 🏛️ Arquitectura: MVVM

```
View ──(observes)──▶ ViewModel ──(calls)──▶ Repository
                                                ├──▶ NetworkService  (URLSession)
                                                └──▶ PersistenceController (Core Data)
```

- **View**: SwiftUI — solo presenta estado, sin lógica de negocio.
- **ViewModel**: `@MainActor ObservableObject` — transforma datos del repo en estado de UI.
- **Repository**: Coordina red y persistencia; abstrae el origen de datos.
- **Service**: Responsabilidad única (red O persistencia O localización).

---

## ✅ Principios SOLID Aplicados

| Principio | Aplicación |
|-----------|-----------|
| **S** — Single Responsibility | `NetworkService`, `HubRepository`, `LocationService` cada uno con una sola responsabilidad |
| **O** — Open/Closed | `NetworkServiceProtocol` permite agregar implementaciones sin modificar código existente |
| **L** — Liskov Substitution | `MockNetworkService` es sustituible por `NetworkService` sin romper nada |
| **I** — Interface Segregation | `HubRepositoryProtocol` expone solo los métodos necesarios |
| **D** — Dependency Inversion | Los ViewModels dependen de protocolos, no de implementaciones concretas |

---

## 🔧 Requerimientos Técnicos Cumplidos

### 1. Networking — URLSession
- **Asíncrono**: `async/await` en `NetworkService.fetch(_:from:)`
- **Síncrono**: `DispatchSemaphore` en `NetworkService.fetchSync(_:from:)`
- Manejo de errores tipados via `AppError`

### 2. Persistencia — Core Data
- Entidad `HubEntity` con todos los atributos del modelo
- `PersistenceController` con upsert, fetch con predicados y soporte in-memory (preview)
- Sincronización automática: fetch remoto → persistir local

### 3. Localización — MapKit + Core Location
- `Map` de SwiftUI con `MapAnnotation` personalizado
- `LocationService` con `CLLocationManager` y manejo de permisos
- `MKMapItem.openInMaps()` para navegación nativa

### 4. Calidad — SOLID + MVVM
- Inyección de dependencias en todos los servicios
- Protocolo por cada capa de servicio (testabilidad)
- `@MainActor` en ViewModels para thread safety

### 5. Internacionalización
- `Localizable.strings` en Español e Inglés
- Namespace `L10n` para evitar strings hardcodeados
- `CFBundleLocalizations` en Info.plist

---

## 🚀 Configuración del Proyecto en Xcode

### Paso 1: Crear el proyecto
```
File > New > Project > App
Product Name: LogisticHubs
Interface: SwiftUI
Language: Swift
Use Core Data: ✅
Include Tests: ✅
```

### Paso 2: Configurar Core Data (.xcdatamodeld)
Crear entidad `HubEntity` con los atributos:

| Atributo     | Tipo         | Optional |
|-------------|--------------|----------|
| id           | UUID         | NO       |
| name         | String       | NO       |
| address      | String       | NO       |
| city         | String       | NO       |
| country      | String       | NO       |
| latitude     | Double       | NO       |
| longitude    | Double       | NO       |
| capacity     | Integer 32   | NO       |
| type         | String       | YES      |
| status       | String       | YES      |
| contactEmail | String       | YES      |
| phoneNumber  | String       | YES      |
| createdAt    | Date         | YES      |

**Codegen**: Manual/None (usamos `HubEntity+CoreDataClass.swift`)

### Paso 3: Agregar frameworks
En Target > General > Frameworks:
- MapKit ✅ (automático en iOS 13+)
- CoreLocation ✅ (automático en iOS 13+)
- CoreData ✅ (automático)

### Paso 4: Agregar localización
Project > Info > Localizations > (+) > Spanish

### Paso 5: Copiar archivos del proyecto
Agregar todos los archivos `.swift` a los grupos correspondientes.

---

## 🧪 Datos de Prueba

El `MockNetworkService` simula una respuesta con **6 sedes reales** de El Salvador, Guatemala y Honduras. Se activa automáticamente — para producción, cambiar en `HubListViewModel`:

```swift
// Desarrollo (mock):
networkService: MockNetworkService()

// Producción:
networkService: NetworkService()
```

---

## 📋 Equipo

- Luis Mario Benítez Domínguez  
- Kevin Misael González Rosales  
- Jonathan Vásquez  
- Lumardo

**Entrega**: 23 de mayo de 2025  
**Materia**: Ingeniería de Software / Desarrollo Móvil  
**Universidad**: UNICAES — Facultad de Ingeniería y Arquitectura
