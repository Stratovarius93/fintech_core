# Estrategia de Despliegue y Operación (Deployment & Operations)

Para garantizar un ciclo de vida ágil, seguro y con cero tiempo de inactividad percibido, la estrategia de despliegue y operación de *Fintech Core* está fuertemente fundamentada en prácticas DevSecOps y monitoreo continuo.

## 1. Control de Versiones (Trunk Based Development)
Para favorecer la agilidad y evitar los famosos "merge conflicts" masivos (comunes en GitFlow), todo el desarrollo se rige bajo **Trunk Based Development (TBD)**:
- Existe una única rama de la verdad: `main` (el *trunk*).
- Los desarrolladores hacen *commits* pequeños y frecuentes (múltiples veces al día) directamente a `main` o utilizan ramas de características (*feature branches*) extremadamente cortas (vida máxima de 1 día) que se integran rápidamente.
- La estabilidad del *trunk* se garantiza mediante la ejecución automática de pruebas unitarias en el CI antes de permitir la integración, apoyado fuertemente por *Feature Flags* para código incompleto.

## 2. Integración y Entrega Continua (CI/CD)
El flujo de desarrollo está automatizado utilizando **GitHub Actions** (o GitLab CI), compuesto por tres pipelines principales:

- **PR Validation Pipeline (CI):** 
  Se dispara con cada Pull Request hacia la rama `develop` o `main`.
  1. Verifica que el código formatee con los estándares de Dart (`dart format`).
  2. Ejecuta el linter estático (`flutter analyze`).
  3. Ejecuta los Unit Tests y Widget Tests (`flutter test`). Bloquea el merge si el *Coverage* de pruebas disminuye o si alguna falla.
- **QA / Beta Deployment Pipeline (CD):** 
  Al hacer merge en `develop`, compila la aplicación para iOS y Android y la sube automáticamente a **Firebase App Distribution**, notificando por correo o Slack al equipo de QA interno para pruebas exploratorias.
- **Production Deployment Pipeline:** 
  Activado manualmente al taggear una *Release*. Usa **Fastlane** para compilar la versión final (inyectando variables de producción y ofuscando el código) y la distribuye directamente a *TestFlight* (iOS) y a la *Consola de Google Play* en pista interna/cerrada.

## 2. Estrategia de Lanzamiento (Release Strategy)
Dado el alto riesgo inherente a una aplicación financiera:
- **Phased Rollout (Lanzamiento Escalonado):** Las actualizaciones en Android (Google Play) y iOS (Phased Release) se distribuyen al 1%, luego al 10%, 50% y finalmente al 100% en un transcurso de 7 días. Si las métricas de monitoreo detectan anomalías, el despliegue se pausa inmediatamente.
- **Feature Flags (Mantenibilidad Operativa):** Nuevas funcionalidades riesgosas (ej. nuevos flujos de préstamos) nacen ocultas detrás de *Feature Flags*. El equipo de negocio puede activarlas o apagarlas remotamente sin necesidad de subir una nueva versión a las tiendas, minimizando el impacto de un fallo crítico.
- **Server Driven UI (SDUI):** Permite cambiar diseños (Banners o botones) directamente desde el backend, mitigando la dependencia de los ciclos de revisión de Apple/Google para ajustes menores.

## 3. Monitoreo y Observabilidad en Producción (Operations)
La operación diaria del sistema depende de herramientas líderes para detectar problemas proactivamente antes de que los usuarios se quejen:
- **Crashlytics:** Toda excepción fatal y no fatal (`ServerException`, `ParseException`) es atrapada por una barrera global (`FlutterError.onError`) y enviada a Firebase Crashlytics con trazas detalladas y variables de contexto (ej. el endpoint que falló).
- **APM (Firebase Performance Monitoring):** Mide el "Time to First Byte" (TTFB) y el tiempo que tardan las peticiones HTTP clave (ej. Login, Fetch Dashboard). Si el tiempo promedio excede los márgenes permitidos, se activa una alerta en *PagerDuty*.
- **Business Analytics (CleverTap / Amplitude):** Registra los "funnels" de los usuarios. Permite identificar problemas no técnicos (ej. el usuario abandonó la app porque no entendió un texto, aunque la app no crasheó).

## 4. Gestión de Secretos y Seguridad AppSec
- **Protección de Variables:** Los secretos, contraseñas y certificados no se versionan. Las URLs y llaves API se inyectan en tiempo de compilación a través de flujos CI/CD seguros (`--dart-define` o archivos `.env` ignorados por el repositorio).
- **Code Obfuscation:** En la compilación final (Production Pipeline) se incluye el flag `--obfuscate --split-debug-info`, haciendo la ingeniería inversa del binario Dart extremadamente difícil, un requisito bancario básico.

## 5. Planes de Contingencia (Disaster Recovery / Degraded State)
La estrategia operativa asume que los servicios externos van a fallar.
- **Offline-First Resilience:** Si un microservicio crítico cae (ej. servicio de saldos bancarios), la app intercepta el timeout e hidrata la vista con el último estado correcto guardado en la caché cifrada localmente (Hive).
- **Graceful Degradation:** Si no hay caché disponible, el bloque asíncrono universal renderiza de forma elegante vistas informativas invitando a reintentar (vía el patrón `NetworkHandler`), en lugar de bloquear el teléfono o mostrar trazas rojas en pantalla.
