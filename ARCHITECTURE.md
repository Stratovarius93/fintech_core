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
