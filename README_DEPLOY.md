# 🚀 Déploiement DonM sur Vercel

## 📋 Prérequis

- Compte Vercel (gratuit)
- Git installé sur votre machine
- Projet Flutter buildé

## 🏗️ Étape 1: Build de Production

```bash
# Aller dans le dossier du projet
cd "c:\Users\DELL\OneDrive - IPNET INSTITUTE OF TECHNOLOGY\Bureau\STAGE\gladys\donm"

# Build pour production web
flutter build web --release -t lib/main_demo.dart

# Les fichiers seront dans build/web/
```

## 📁 Étape 2: Préparation pour Vercel

Les fichiers sont déjà prêts dans `build/web/` avec :
- ✅ `index.html` optimisé
- ✅ `main.dart.js` compilé
- ✅ `assets/` (images, icônes)
- ✅ `manifest.json` PWA
- ✅ `flutter.js` bootstrap

## 🌐 Étape 3: Déploiement sur Vercel

### Option A: Via Interface Web (Recommandé)

1. **Créer un compte Vercel** : https://vercel.com
2. **Importer le projet Git** :
   - Connecter votre GitHub/GitLab
   - Importer le dossier `donm`
   - Sélectionner la branche `main`

3. **Configuration automatique** :
   - Vercel détecte automatiquement `build/web`
   - Ajoute le domaine : `donm-xxx.vercel.app`

### Option B: Via Vercel CLI

```bash
# Installer Vercel CLI
npm install -g vercel

# Se connecter
vercel login

# Déployer depuis le dossier build
cd build/web
vercel --prod

# Suivre les instructions pour le nom de domaine
```

## 🎯 Étape 4: Configuration du Projet

Dans l'interface Vercel, vérifier :

**Build Settings:**
- **Framework Preset**: Other
- **Root Directory**: `build/web`
- **Build Command**: `flutter build web --release -t lib/main_demo.dart`
- **Output Directory**: `build/web`

**Environment Variables:**
```
FLUTTER_WEB_CANVASKIT_URL=https://www.gstatic.com/flutter-canvaskit/
```

## 🔗 Étape 5: URL de Production

Après déploiement, vous obtiendrez :

**URL Principale**: `https://donm-xxxxxxxx.vercel.app`

**URL Personnalisée**: `https://donm-demo.vercel.app` (si disponible)

## 📱 Fonctionnalités Déployées

L'application inclut :

✅ **Page d'accueil professionnelle** avec logo DonM
✅ **Navigation multi-pages** (Accueil, Commandes, Profil)
✅ **Design responsive** adapté mobile/desktop
✅ **Animations fluides** et transitions modernes
✅ **Interface utilisateur** intuitive
✅ **Branding DonM** cohérent

## 🎨 Design DonM

- **Couleurs officielles** : Vert (#2E7D32) et Jaune (#FFB300)
- **Logo animé** avec effet pulse
- **Interface moderne** et professionnelle
- **Expérience utilisateur** optimisée

## 📊 Test de l'Application

1. **Ouvrir l'URL** fournie par Vercel
2. **Tester sur mobile** (responsive)
3. **Tester sur desktop** (adaptatif)
4. **Vérifier les animations** et transitions
5. **Valider le branding** DonM

## 🔄 Mises à Jour

Pour mettre à jour l'application :

```bash
# 1. Modifier le code
# 2. Rebuild
flutter build web --release -t lib/main_demo.dart

# 3. Redéployer
vercel --prod
```

## 📞 Support

- **Documentation Vercel** : https://vercel.com/docs
- **Support Flutter** : https://flutter.dev/docs
- **Projet DonM** : Déjà configuré et prêt

---

**L'application DonM est prête pour le déploiement professionnel !** 🚀
