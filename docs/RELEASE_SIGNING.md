# Release AAB imzolash (Google Play uchun)

Google Play Console AAB ni **release imzosi** bilan talab qiladi. Debug imzosi bilan yuklangan AAB rad etiladi.

## 1. Release kalit (keystore) yaratish

Terminalda (yoki CMD/PowerShell) quyidagi buyruqni ishlating. Barcha savollarga javob bering; parol va alias ni eslab qoling.

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- **upload-keystore.jks** — `android` papkasiga saqlang (masalan: `c:\yuk\logistics_client\android\upload-keystore.jks`).
- **upload** — alias (keyAlias). Boshqa nom bersangiz, key.properties da ham shu nomni yozing.
- Parollarni xavfsiz joyda saqlang; keystore yo‘qolsa, yangi ilova chiqarish mumkin emas.

## 2. key.properties yaratish

1. `android` papkasida `key.properties.example` dan nusxa oling va nomini **key.properties** qiling.
2. Ichini to‘ldiring:

```properties
storePassword=keystore_parolingiz
keyPassword=kalit_parolingiz
keyAlias=upload
storeFile=upload-keystore.jks
```

- **storeFile** — keystore yo‘li. Agar `android` papkasida bo‘lsa: `../upload-keystore.jks`. To‘liq yo‘l: `C:\\keys\\upload-keystore.jks` (Windows da `\\` ishlating).

## 3. AAB yig‘ish

```bash
flutter clean
flutter build appbundle
```

Tayyor AAB: `build/app/outputs/bundle/release/app-release.aab`. Uni Google Play Console ga yuklang.

## Muhim

- **key.properties** va **upload-keystore.jks** ni Git ga commit qilmang (`.gitignore` da qo‘yilgan).
- Keystore va parollarni zaxiraga oling; ularni yo‘qotmasangiz, ilovani yangilab chiqish qiyin bo‘ladi.
