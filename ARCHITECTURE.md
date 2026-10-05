# Documentación de Arquitectura y Decisiones Técnicas - Fintech Core

## 1. Patrón Arquitectónico Principal
### Decisión: Pragmatic Clean Architecture (Feature-First)
Hemos adoptado una arquitectura basada en **Clean Architecture**, pero de manera pragmática eliminando la capa de **Casos de Uso (Use Cases)**. La estructura de carpetas está orientada a **Features**, lo que significa que todo el código relacionado a una funcionalidad específica (ej. `auth`, `dashboard`) vive dentro de su propia carpeta modular.

**Alternativas descartadas:**
- *Clean Architecture Clásica (con Casos de Uso):* Descartada por recomendación de Google Developer Experts para este contexto. Introducía demasiada verbosidad y abstracciones innecesarias.
- *Estructura Layer-First (todas las vistas en una carpeta, todos los blocs en otra):* Descartada porque dificulta la escalabilidad en equipos grandes y rompe la modularidad al intentar extraer un feature como micro-aplicativo.

**Impacto a largo plazo:**
La arquitectura orientada a features permitirá que en el futuro el proyecto pueda evolucionar fácilmente hacia un modelo de **Micro Frontends** o ser administrado por equipos independientes (Squads).

## 2. Inyección de Dependencias
### Decisión: `RepositoryProvider` (flutter_bloc) nativo y escalable
La inyección de dependencias se maneja directamente en el árbol de widgets. Para asegurar la escalabilidad y limpieza a medida que el proyecto crece, cada feature expone dos constructores de listas: un inyector de repositorios (ej. `athInjector()` que devuelve `List<RepositoryProvider<dynamic>>`) y un inyector de estados (ej. `athBlocs()` que devuelve `List<SingleChildWidget>`). Estas listas se combinan en la raíz de la aplicación usando `MultiRepositoryProvider` y `MultiBlocProvider`.

**Alternativas descartadas:**
- *`get_it` / `injectable`:* Se descartó para evitar acoplamiento a Service Locators globales. Inyectar a través del context de Flutter garantiza que los repositorios sigan el mismo ciclo de vida de la UI y respeta el paradigma declarativo.

## 3. Estado de la Interfaz y Flujo de Datos
### Decisión: `BaseDataBloc` y `BaseAsyncValueState`
En lugar de escribir Eventos y Estados repetitivos para cada pantalla, se implementó un núcleo genérico (`BaseDataBloc`) que maneja nativamente las transiciones (Initial, Loading, Success, Error).

**Trade-offs:**
- *Pro:* Reducción masiva de boilerplate. La UI siempre sabe cómo reaccionar utilizando extensiones declarativas como `mapProvided` y `whenProvided`.
- *Contra:* Ligera curva de aprendizaje inicial para entender el uso de genéricos, pero altamente compensada por la velocidad de desarrollo.

## 4. Resiliencia, Red y Manejo de Errores (Offline-First / Degraded Network)
### Decisión: Interceptor de Simulación y `NetworkHandler`
Para cumplir con la necesidad de manejar **alta latencia o indisponibilidad parcial**, creamos un `NetworkSimulatorInterceptor` que inyecta latencias y errores de forma aleatoria o controlada en entorno de desarrollo.
Toda petición pasa por un mixin `NetworkHandler` que atrapa errores de Dio (`DioException`) o fallos de parseo (`ParseException`) centralizándolos. El Repositorio traduce estas excepciones a dominios seguros usando `Either<Failure, Success>` de `dartz`.

### Decisión: Offline-First con Caché Local (Hive)
Para garantizar operatividad continua frente a la volatilidad de la red, adoptamos un patrón **Offline-First**.
- Cada respuesta exitosa de red (ej. los datos del Dashboard) se almacena serializada en **Hive** (elegido por su alta velocidad y sincronía).
- Si el servicio global `NetworkInfo` detecta pérdida de conexión, o el interceptor lanza un timeout, el Repositorio recupera automáticamente la última información guardada en caché y se la presenta al usuario sin interrumpir el flujo.
- Si el dispositivo está sin red y **no hay** caché previa, el sistema despacha un `NotInternetFailure` semántico, el cual la capa de Presentación mapea a una pantalla específica de desconexión.

**Parseo Seguro:**
Se utiliza una clase propia `JsonMap` que intercepta errores de tipado o valores nulos cuando se transforman los JSONs que llegan del backend. La entidad y el modelo se independizaron para asegurar pureza mediante `Mappers` extendidos.

## 5. Riesgos Técnicos y Supuestos
- **Riesgo:** El almacenamiento caché (por ej. con `Hive`) puede corromperse en actualizaciones mayores del modelo de datos si no se planifican bien migraciones o TypeAdapters.
- **Supuesto:** Se asume que el backend respeta una estructura estándar en sus respuestas de error (con código y mensaje), los cuales son interpretados por el `ServerException`.
- **Estrategia de Escalamiento:** El uso de prefijos únicos por archivo (ej. `ath_`) evita colisiones de nombres. Al escalar, cada feature puede ser extraído a un "package" local independiente dentro de un monorepo (usando Melos).

## 6. Documentación de Código
### Decisión: Clean Code y Comentarios en Inglés
Todo el código y sus comentarios técnicos internos se escriben en inglés, garantizando alineación con los estándares globales de Clean Code.

## 7. Estrategia de Pruebas (Testing)
### Decisión: Testing Pragmático y Dirigido
Para evitar redundancia de tests y aprovechar el core genérico:
- **Core Asíncrono (`BaseDataBloc` y `State`)**: Se testa al 100% una sola vez. Garantiza que las transiciones de estado (`loading`, `success`, `error`) funcionen por defecto en todo el proyecto.
- **Features (BLoC)**: Se utiliza `blocTest` enfocado estrictamente en verificar que la lógica de negocio emita el flujo correcto (ej. `Initial state` y los estados exitosos). No se re-testean flujos de errores genéricos que ya cubre el core.
- **Inyección de Dependencias**: Se incluyen smoke tests (`testWidgets`) para validar que las listas de providers (ej. `athBlocs`, `athInjector`) inyecten y expongan correctamente las dependencias en el árbol de Flutter (`context.read`).
- **Data y Red**: Se mockean clientes HTTP (ej. Dio) usando `mocktail`. Los Repositorios se testean validando rigurosamente su capacidad para atrapar excepciones específicas y devolver clases seguras `Either<Failure, T>`.

## 8. Singletons & Dependency Injection
### Decisión: Singletons Pasados por Inyección
Los Singletons (ej. `NetworkInfo.instance`, `DsbLocalStore.instance`) se utilizan para servicios globales o acceso a bases de datos locales. Para mantener la testeabilidad y respetar los principios de arquitectura limpia, estas instancias estáticas deben ser inyectadas en los constructores de los Repositorios a través de los Inyectores de dependencia (ej. `dsbInjector()`), en lugar de consumirse directamente en los métodos internos. Esto permite usar mocks fácilmente y controlar de forma determinista la ausencia de conexión, retornando clases concretas de error como `NotInternetFailure`.

## 9. Server Driven UI (SDUI)
### Decisión: Implementación mediante Patrón Registry y JSON
Para soportar interfaces dinámicas (ej. Banners promocionales, ofertas), la arquitectura incluye un motor SDUI nativo.
- El servidor envía un árbol JSON definiendo nodos (`type`, `properties`, `children`).
- El cliente utiliza `SduiNodeEntity` y `SduiRegistry` (Singleton factory) para mapear esos tipos a Widgets reales (ej. `text` -> `Text`, `column` -> `Column`).
- Si un componente no está registrado, se renderiza un `SizedBox.shrink()` como *fallback* evitando fallos fatales en producción.
- Toda la validación de nulos al parsear el JSON depende de `JsonMap`.

## 10. Variables de Entorno (Environment Variables)
### Decisión: Separación de URLs usando `.env` y `flutter_dotenv`
Todas las rutas base de APIs, tokens o variables sensibles deben almacenarse en archivos de entorno (`.env`) en lugar de estar quemadas (hardcoded) en el código. Si no se encuentra configurada, la aplicación lanzará una excepción (Fail-Fast) para evitar falsos positivos y nunca exponer datos por defecto.
*(Nota: Para propósitos de pruebas técnicas o revisión, el archivo `.env` se incluye temporalmente en el repositorio, pero en un entorno corporativo real este archivo es ignorado por git (`.gitignore`) y los secretos se inyectan a través de CI/CD).*

## 11. Integración con Servicios Externos (Ecosistema) y Push Notifications
### Decisión: Servicios Modulares Inyectables
Para integrar servicios externos de analítica/engagement (ej. `CleverTap` o `Amplitude`) y envío de notificaciones push (ej. `Firebase Cloud Messaging`), hemos creado clases `Singleton` dentro de `lib/core/services`.
- **AnalyticsService**: Centraliza toda recolección de eventos para evitar mezclar lógica de negocio del banco con SDKs de marketing. Permite traquear fallos de UX para generar funnels en herramientas de análisis.
- **PushNotificationService**: Configura los canales en Android/iOS usando `flutter_local_notifications` permitiendo reaccionar a cargas útiles en background para notificar al usuario (ej. de transacciones sospechosas o exitosas).

## 12. Monitoreo y Observabilidad en Producción
### Decisión: Estrategia de Triangulación (Crashlytics, APM, Sentry)
Siendo una aplicación Fintech (Crítica Nivel 1), el monitoreo en producción requiere detectar problemas operativos y de UX en tiempo real. Estrategia a utilizar:
1. **Detección de Errores Fatales (Crashlytics / Sentry):** Todo fallo no atrapado y las excepciones semánticas (ej. `NotInternetFailure` o `ParseException`) deben registrarse automáticamente. El interceptor de red envía métricas sobre todos los Status Code `4xx` y `5xx`.
2. **Rendimiento APM (Firebase Performance / Datadog):** Monitorear la latencia (TTFB) de los microservicios del banco. Si la carga del Dashboard excede los X milisegundos de forma concurrente, dispara una alerta (PagerDuty).
3. **Observabilidad UX (CleverTap / Amplitude):** Utilizando el `AnalyticsService`, registramos eventos customizados como `login_failed_biometrics` o `dashboard_timeout`. Permite identificar problemas en los que la app no crashea, pero los usuarios no pueden completar sus tareas (degradación de experiencia).
