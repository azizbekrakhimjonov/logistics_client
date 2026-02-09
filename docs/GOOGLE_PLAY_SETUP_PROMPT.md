# Google Play Console uchun sozlamalar — Yuktashish Client (prompt)

Bu hujjat **Yuktashish Client** ilovasi uchun qilingan barcha sozlamalarni to‘liq tavsiflaydi. **Yuktashish Driver** uchun ham xuddi shu qadamlar bo‘yicha sozlash mumkin — faqat ilova nomi, package name va (ixtiyoriy) keystore/parollar almashtiriladi.

---

## 1. Android package name (applicationId va namespace)

Google Play da **com.example** ruxsat etilmaydi. Yuktashish Client uchun ishlatilgan package name:

- **applicationId:** `com.yuktashish.client`
- **namespace:** `com.yuktashish.client`

**Yuktashish Driver uchun:** `com.yuktashish.driver` (yoki `com.yuktashish.driver_app`).

**Qayerda o‘zgartiriladi:**
- `android/app/build.gradle` — `namespace` va `defaultConfig.applicationId`
- `android/app/src/main/java/` — Java package papkalari va `MainActivity.java` ichidagi `package` qatori

**Papka tuzilishi (Client):**
- `android/app/src/main/java/com/yuktashish/client/MainActivity.java`
- `MainActivity.java` ichida: `package com.yuktashish.client;`

**Driver uchun:** `com/example/logistics_client` o‘rniga `com/yuktashish/driver` (yoki tanlangan package), `MainActivity.java` da `package com.yuktashish.driver;`

---

## 2. Release imzolash (signing) — AAB ni debug emas, release bilan imzolash

Google Play faqat **release** imzosi bilan yuklangan AAB ni qabul qiladi.

### 2.1. android/app/build.gradle (Groovy)

Fayl **Groovy** (`build.gradle`), Kotlin emas (`build.gradle.kts`). Ichida quyidagilar bo‘ladi:

**Plugins:**
```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}
```

**Keystore properties (build.gradle boshida):**
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

**android { } ichida:**

- `namespace "com.yuktashish.client"` (Driver: `"com.yuktashish.driver"`)
- `defaultConfig { applicationId "com.yuktashish.client" ... }` (Driver: `"com.yuktashish.driver"`)
- **signingConfigs:**
```groovy
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```
- **buildTypes:**
```groovy
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

### 2.2. android/key.properties (Git ga commit qilinmaydi)

**Joyi:** loyiha ichida `android/key.properties` (android papkasida).

**Mazmuni (misol):**
```properties
storePassword=myapp2026
keyPassword=myapp2026
keyAlias=upload
storeFile=../upload-keystore.jks
```

- **storeFile:** Keystore `android` papkasida bo‘lsa: `../upload-keystore.jks`. Boshqa joyda bo‘lsa to‘liq yo‘l (Windows: `C:\\path\\upload-keystore.jks`, `\\` bilan).
- **keyAlias** — keystore yaratilganda berilgan alias (odatda `upload`).
- **Driver uchun:** Alohida keystore yaratish mumkin (masalan `upload-driver.jks`) yoki boshqa parol/alias; key.properties da shu qiymatlar bo‘ladi.

### 2.3. android/key.properties.example (namuna, Git ga commit qilish mumkin)

```properties
# Release imzolash uchun. Nusxalang: key.properties, qiymatlarni to'ldiring.
# key.properties va *.jks ni Git ga commit qilmang.

storePassword=parolingiz
keyPassword=parolingiz
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 2.4. Keystore yaratish (bir marta, keyin saqlab qolinadi)

**Joyi:** `android` papkasi (masalan `c:\yuk\driver_project\android`).

**Buyruq (PowerShell/CMD):**
```bash
cd <loyiha>\android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- Savollarga (F.I.O., tashkilot, shahar va h.k.) javob bering.
- Parol — key.properties dagi `storePassword` / `keyPassword` bilan bir xil qilib olish qulay.
- **Driver uchun:** Alohida loyiha bo‘lsa, o‘sha loyihaning `android` papkasida yangi keystore (masalan `upload-keystore.jks`) yaratiladi; key.properties ham o‘sha loyihada.

### 2.5. .gitignore (android papkasi)

`android/.gitignore` da quyidagilar bo‘lishi kerak (keystore va parollar ochiq chiqmasin):

```
key.properties
**/*.keystore
**/*.jks
```

---

## 3. Login sahifasida ilova nomi (Client va Driver farqlashi uchun)

Login ekranida qaysi ilova ekani ko‘rinsin: **Yuktashish Client** yoki **Yuktashish Driver**.

**Qilingan ish (Client):**
- Tarjima kaliti: `app_name_client`, qiymati: **"Yuktashish Client"** (uz/ru).
- Login sahifasida yuqori bannerda: `"app_name_client".tr()` — oq matn, 22px, bold.

**Driver uchun:**
- Yangi kalit: `app_name_driver`, qiymati: **"Yuktashish Driver"** (uz/ru).
- Login sahifasida xuddi shu o‘rinda: `"app_name_driver".tr()`.

**Qayerda:**
- Tarjima: `assets/translations/uz.json`, `ru.json` va (codegen ishlatilsa) `lib/generated/codegen_loader.g.dart`.
- UI: login screen — yuqori qismdagi matn (masalan `SafeArea` + `Align` + `Text(..., style: white, 22, bold)`).

---

## 4. Debug rejimini release da o‘chirish (kodda)

Release buildda debug chiqishlari va BlocObserver ishlamasin.

**main.dart da:**
- `import 'package:flutter/foundation.dart';` — `kDebugMode` uchun.
- Token va boshqa debug: `if (kDebugMode) print(...);`
- BlocObserver: `blocObserver: kDebugMode ? MyBlocObserver() : null`
- `MaterialApp`: `debugShowCheckedModeBanner: false`

(Bu faqat kod va konsol chiqishiga taalluqli; AAB ni release bilan imzolash 2‑bandda.)

---

## 5. Build va AAB joyi

**Buyruqlar:**
```bash
cd <loyiha>
flutter clean
flutter build appbundle
```

**AAB fayl:** `build/app/outputs/bundle/release/app-release.aab`  
Shu faylni Google Play Console → Ilova → Release → App bundles ga yuklanadi.

---

## 6. Qisqacha tekshiruv ro‘yxati (Client / Driver uchun ham)

- [ ] Package name **com.example** emas (masalan `com.yuktashish.client` yoki `com.yuktashish.driver`).
- [ ] `android/app/build.gradle` — Groovy, `signingConfigs.release` va `buildTypes.release.signingConfig signingConfigs.release` mavjud.
- [ ] `android/key.properties` mavjud, `storeFile` to‘g‘ri (masalan `../upload-keystore.jks`).
- [ ] `android/` da `upload-keystore.jks` (yoki key.properties dagi boshqa nom) mavjud.
- [ ] Login sahifasida ilova nomi ko‘rinadi (Yuktashish Client / Yuktashish Driver).
- [ ] `flutter build appbundle` xatosiz tugaydi, AAB release imzosi bilan yig‘ilgan.
- [ ] Google Play Console da yangi ilova yoki mavjud ilova uchun to‘g‘ri package name bilan AAB yuklanadi.

---

## 7. Yuktashish Driver uchun prompt (AI ga berish uchun qisqa matn)

Quyidagi matnni **Yuktashish Driver** loyihasi uchun AI ga berishingiz mumkin:

---

**Prompt: Google Play uchun Android sozlamalari — Yuktashish Driver**

Yuktashish Driver Flutter ilovasi uchun Google Play Console ga yuklashga tayyor qilish kerak. Quyidagilarni qil:

1. **Package name:** `com.example` ishlatilmasin. ApplicationId va namespace ni `com.yuktashish.driver` qil. `android/app/build.gradle` da namespace va applicationId ni o‘zgartir. Java package papkalarini `com/yuktashish/driver` qil va `MainActivity.java` da `package com.yuktashish.driver;` deb yoz.

2. **Release imzolash:** `android/app/build.gradle` Groovy bo‘lsin. Build fayli boshida `key.properties` dan o‘qiladigan `keystoreProperties` qo‘sh. android {} ichida `signingConfigs { release { keyAlias, keyPassword, storeFile, storePassword } }` va `buildTypes { release { signingConfig signingConfigs.release } }` bo‘lsin. `android/key.properties` da storePassword, keyPassword, keyAlias, storeFile (masalan `../upload-keystore.jks`) bo‘lsin. `android/.gitignore` da key.properties va **/*.keystore, **/*.jks qo‘yilgan bo‘lsin. Keystore yaratish: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload` — android papkasida.

3. **Login sahifasida ilova nomi:** Ekranda "Yuktashish Driver" ko‘rinsin. Tarjima kaliti `app_name_driver`, qiymati "Yuktashish Driver". Login ekranining yuqori qismida shu matn oq, 22px, bold.

4. **Debug:** Release buildda debug print va BlocObserver ishlamasin (kDebugMode tekshiruvi va debugShowCheckedModeBanner: false).

5. **AAB:** `flutter clean` va `flutter build appbundle` dan keyin `build/app/outputs/bundle/release/app-release.aab` Google Play ga yuklanadigan fayl.

Barcha o‘zgarishlar Yuktashish Client da qilingan uslubda bo‘lsin, faqat ilova nomi "Yuktashish Driver" va package `com.yuktashish.driver`.

---

Ushbu hujjat va promptdan foydalanib, Yuktashish Driver uchun ham xuddi shu sozlamalarni qo‘llashingiz mumkin.
