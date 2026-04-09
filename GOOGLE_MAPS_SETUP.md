 🗺️ Configuration Google Maps - DonM App

## 📋 Étapes pour obtenir votre clé API Google Maps

### 1. **Créer un projet Google Cloud**
1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créez un nouveau projet ou utilisez "DonM-App"

### 2. **Activer les APIs requises**
Dans votre projet Google Cloud, activez :
- ✅ **Maps SDK for Android**
- ✅ **Maps SDK for iOS** 
- ✅ **Places API**
- ✅ **Geocoding API**
- ✅ **Directions API**

### 3. **Créer une clé API**
1. Allez dans "APIs & Services" > "Identifiants"
2. Cliquez sur "Créer des identifiants" > "Clé API"
3. Copiez votre clé API

### 4. **Sécuriser votre clé API**
1. Cliquez sur votre clé API
2. Dans "Restrictions d'application", sélectionnez "Applications Android"
3. Ajoutez votre nom de package : `com.donm.app`
4. Ajoutez l'empreinte SHA-1 de votre certificat

### 5. **Obtenir l'empreinte SHA-1**
Exécutez cette commande dans votre terminal :
```bash
cd android
./gradlew signingReport
```
Copiez l'empreinte SHA-1 (SHA1) sous "debug" ou "release"

### 6. **Configurer la clé dans l'application**

#### Dans `android/app/src/main/AndroidManifest.xml` :
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="VOTRE_CLÉ_API_ICI" />
```

#### Dans `lib/core/config/firebase_config.dart` :
```dart
static const String googleMapsApiKey = 'VOTRE_CLÉ_API_ICI';
```

## 🔧 **Configuration finale**

1. **Remplacez `VOTRE_GOOGLE_MAPS_API_KEY`** dans `AndroidManifest.xml`
2. **Exécutez `flutter clean` et `flutter pub get`**
3. **Testez sur un vrai appareil** (l'émulateur peut avoir des problèmes)

## 🚨 **Important**

- **Ne partagez jamais votre clé API publiquement**
- **Restreignez toujours votre clé à votre application**
- **Surveillez l'utilisation de votre clé** dans Google Cloud Console

## 📱 **Test de Google Maps**

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Test simple
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(6.5244, -3.3762), // Abidjan
    zoom: 15.0,
  ),
)
```

Une fois configuré, Google Maps devrait fonctionner parfaitement dans votre application DonM ! 🎯
