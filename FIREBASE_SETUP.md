# Configuration Firebase

## 📋 Aperçu

Ce projet utilise **Firebase Authentication** pour gérer l'authentification des hôtes (animateurs). Au lieu d'un mock local, les utilisateurs se connectent via leurs identifiants Firebase.

---

## 🚀 Étapes de Setup Firebase

### 1. Créer un projet Firebase

1. Aller à [Firebase Console](https://console.firebase.google.com/)
2. Cliquer sur **"Create a new project"**
3. Entrer le nom du projet: `Mentimeter Host` (ou le nom que tu préfères)
4. Activer/accepter les options
5. Attendre la création (1-2 minutes)

### 2. Ajouter les applications (plateforme)

Dans **Project Settings**:

#### Android
1. Aller à **Project Settings > Your apps**
2. Cliquer sur **Add app > Android**
3. Entrer:
   - Package name: `com.example.quiz_host_app`
   - App nickname: `HostApp Android`
4. Télécharger `google-services.json`
5. Placer le fichier dans: `android/app/google-services.json`

#### iOS
1. Ajouter une app iOS dans **Project Settings**
2. Bundle ID: `com.example.quizHostApp`
3. Télécharger `GoogleService-Info.plist`
4. Place dans: `ios/Runner/GoogleService-Info.plist`

#### Web (optionnel)
1. Ajouter une app Web
2. App nickname: `HostApp Web`
3. Les clés seront affichées (note-les si besoin)

### 3. Activer Email/Password Authentication

1. Dans Firebase Console, aller à **Authentication**
2. Aller à l'onglet **Sign-in method**
3. Activer **Email/Password**

### 4. Ajouter un utilisateur (test)

1. Dans **Authentication > Users**
2. Cliquer sur **Create user**
3. Entrer:
   - Email: `test@test.com`
   - Password: `123456` (ou ce que tu veux, min 6 chars)
4. Valider

### 5. Dépendances Flutter

Les packages sont déjà dans `pubspec.yaml`:

```yaml
firebase_core: ^4.6.0
firebase_auth: ^6.3.0
```

Si manquant, faire:
```bash
flutter pub add firebase_core firebase_auth
```

---

## 🔧 Modifications du Code

### Avant (Mock)
Le `AuthBloc` acceptait n'importe quel email + password >= 4 caractères localement:

```dart
if (event.email.isEmpty || event.password.length < 4) {
  emit(const AuthError(message: 'Email ou mot de passe invalide'));
  return;
}
emit(AuthAuthenticated(email: event.email));
```

### Après (Firebase)
Le `AuthBloc` vérifie via **Firebase Authentication**:

```dart
final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: event.email,
  password: event.password,
);
emit(AuthAuthenticated(email: credential.user?.email ?? event.email));
```

### Fichier modifié
- [lib/features/auth/bloc/auth_bloc.dart](lib/features/auth/bloc/auth_bloc.dart)
  - Ajout import: `import 'package:firebase_auth/firebase_auth.dart';`
  - Méthode `_onLoginRequested()`: appel Firebase au lieu du mock
  - Méthode `_onLogoutRequested()`: appel `FirebaseAuth.instance.signOut()`
  - Gestion de session initiale: si utilisateur déjà connecté → `AuthAuthenticated`
  - Fonction `_mapFirebaseError()`: traduit les erreurs Firebase en messages utilisateur

---

## ⚙️ Comment ça Marche

### Flow de connexion

1. **Utilisateur rentre email + password** dans `LoginScreen`
2. **Click "Sign in"** → envoi événement `LoginRequested` au `AuthBloc`
3. **Le bloc appelle** `FirebaseAuth.instance.signInWithEmailAndPassword()`
4. **Firebase vérifie** les identifiants:
   - ✅ Si correct → Utilisateur authentifié
   - ❌ Si incorrect → Erreur retournée
5. **Le bloc émet** soit `AuthAuthenticated` soit `AuthError`
6. **LoginScreen affiche**:
   - Succès: Navigue vers `DashboardScreen`
   - Erreur: Affiche SnackBar rouge en bas

### Affichage des erreurs

Les erreurs s'affichent dans un **SnackBar rouge** en bas de l'écran:

```dart
ScaffoldMessenger.of(ctx).showSnackBar(
  SnackBar(
    content: Text(state.message),
    backgroundColor: AppColors.danger,
  ),
);
```

Erreurs possibles:
- `"Adresse email invalide."` → Format email incorrect
- `"Aucun utilisateur trouve avec cet email."` → Pas de compte Firebase
- `"Email ou mot de passe incorrect."` → Mauvais password
- `"Probleme reseau..."` → Pas d'internet / Firebase indisponible

### Persistance de session

Au redémarrage de l'app:
- Si utilisateur déjà connecté → Affiche `DashboardScreen` directement
- Si pas connecté → Affiche `LoginScreen`

```dart
static AuthState _initialState() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return AuthAuthenticated(email: user.email ?? '');
  }
  return const AuthInitial();
}
```

---

## 🧪 Test Local

```bash
# Assurez-vous d'être au bon répertoire
cd /path/to/HostApp

# Récupérer les dépendances
flutter pub get

# Lancer sur Android/iOS/Web
flutter run
```

**Testez avec:**
- Email: `test@test.com`
- Password: `123456`

### Erreurs courantes

| Erreur | Solution |
|--------|----------|
| `FirebaseCore not initialized` | Assurez-vous que `Firebase.initializeApp()` est appelé dans `main.dart` |
| `google-services.json not found` | Téléchargez depuis Firebase Console et placez dans `android/app/` |
| `Invalid JSON in google-services.json` | Vérifiez le fichier téléchargé, réessayez le téléchargement |
| `User not found` | Créez d'abord l'utilisateur dans Firebase Console > Authentication |
| `Wrong password` | Vérifiez le password au moment de la création de l'utilisateur |



