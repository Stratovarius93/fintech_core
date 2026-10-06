# Fintech Core 🏦

Plataforma móvil financiera de alto rendimiento construida con Flutter, diseñada bajo principios rigurosos de *Pragmatic Clean Architecture*, resiliencia *Offline-First* y flexibilidad *Server Driven UI*.

## 📚 Documentación Principal (ADRs y Operaciones)
Para entender a profundidad el "por qué" detrás del código y las estrategias de escalabilidad de este proyecto, por favor revisa los siguientes documentos oficiales:

- 🏗️ [**Decisiones de Arquitectura (ADRs)**](ARCHITECTURE.md)
- 🚀 [**Estrategia de Despliegue y Operación**](DEPLOYMENT_AND_OPERATIONS.md)
- 🤖 [**Reporte de Uso e Impacto de IA**](AI_USAGE_REPORT.md)

---

## ⚙️ 1. Configurar (Setup)

### Prerrequisitos
- Flutter SDK `>= 3.38.5` (o superior)
- Dart SDK `>= 3.10.4`
- Entorno de desarrollo para iOS (Xcode) y/o Android (Android Studio).

### Variables de Entorno (`.env`)
El proyecto utiliza `flutter_dotenv` para proteger secretos y URLs (siguiendo directrices de AppSec).
1. En la raíz del proyecto, clona el archivo de entorno de ejemplo:
   ```bash
   cp .env.example .env
   ```
2. Asegúrate de que el archivo `.env` contenga las siguientes rutas para que la simulación funcione:
   ```env
   API_BASE_URL=https://api.test.bank/v1
   SDUI_URL=https://script.google.com/macros/s/AKfycbwhfMUOzYzMA9-KWt56ujx2W2O8JYySeO6aSCIWO7GeYLCZ5KLyJrlzw3ZpIVsVWIV3/exec
   ```
   *(Nota: SDUI_URL apunta al backend Serverless usado para servir los Banners dinámicos en el Dashboard).*

### Estructura del Server Driven UI (SDUI)
Para contexto de evaluación, el servicio de Google Sheets (`SDUI_URL`) retorna el siguiente formato JSON, el cual es parseado por nuestro `SduiRegistry` y pintado dinámicamente como Widgets nativos:

```json
{
  "type": "promo",
  "properties": {
    "title": "Promoción de Bienvenida",
    "subtitle": "Obtén beneficios exclusivos hoy"
  }
}
```

### Dependencias
Instala los paquetes necesarios:
```bash
flutter pub get
```

---

## ▶️ 2. Ejecutar (Run)
Para correr la aplicación en el emulador o dispositivo físico, simplemente ejecuta:

```bash
flutter run
```

**Credenciales Mockeadas:**
El `NetworkSimulatorInterceptor` validará las siguientes credenciales para simular un inicio de sesión exitoso hacia el Dashboard:
- **Email:** `user@bank.com`
- **Password:** `123456`

*(La aplicación incluye un simulador de fallos de red aleatorios para probar la resiliencia offline).*

---

## 🧪 3. Probar (Testing)
Nuestra arquitectura genérica asíncrona (`BaseDataBloc`) permite aislar pruebas complejas sin repetir código.

Para correr toda la suite de pruebas unitarias y de widgets (repositorios, BLoCs, Mappers):
```bash
flutter test
```

Para correr la prueba **E2E automatizada** (Integration Test) del flujo crítico de resiliencia offline. Es muy útil para **grabar la evidencia** de cómo la app recupera los datos desde la caché:
```bash
flutter test integration_test/critical_flow_offline_recovery_test.dart
```

Para validar la sintaxis y reglas estrictas del linter:
```bash
flutter analyze
```

---

## 🤝 4. Colaborar (Contributing)

Si te unes al equipo, por favor respeta las siguientes reglas de gobierno de código:

1. **Trunk Based Development (TBD):** Integramos directo al tronco (`main`). Realiza *commits* pequeños y frecuentes. Si construyes algo a medias, apágalo tras un *Feature Flag*.
2. **Sigue a la IA Arquitecta:** Revisa nuestro archivo base `.agents/agents/architect/agent.md`. Es el manual rector que asegura que todo desarrollador (y otras IAs) mantengan la estructura `Feature-First` intacta.
3. **No reinventes la rueda:** Todos los BLoCs nuevos deben heredar del núcleo `BaseDataBloc`.
4. **Cero Crash por nulos:** Todo JSON entrante debe parsearse utilizando el wrapper de seguridad `JsonMap`.
