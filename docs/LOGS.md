# Ilova loglari — API va jarayonlar

Debug rejimida ishlaganda barcha API so'rovlari va muhim jarayonlar konsolga yoziladi. Muammo qayerda ekanini aniqlash uchun loglarni filtrlashingiz mumkin.

## Log format

Har bir qator taxminan shunday:
```
[2025-02-21T12:00:00.000] [TAG] xabar | detail=...
```

- **Vaqt** — ISO format
- **TAG** — jarayon turi (pastda)
- **xabar** — qisqa tavsif
- **detail** — qo'shimcha ma'lumot (request body, response, id va h.k.)

## Tag'lar va qaysi API/jarayon

| Tag        | Qaysi jarayon / API |
|-----------|----------------------|
| **API_REQ** | Har qanday API so'rov boshlandi (method, path, body) |
| **API_OK**  | So'rov muvaffaqiyatli (path, status, javob) |
| **API_FAIL**| So'rov xato (path, error, response) |
| **AUTH**    | Login, OTP (codeEntry), getUser |
| **USER**    | checkUser (api/orders/user/check/) |
| **CATEGORIES** | getCategories (hom ashyolar ro'yxati) |
| **PREORDER**  | preOrder (api/orders/preorder-create/) — xom ashyo miqdori + Tayyor |
| **ORDER**   | getOrderList, getOrderDetail, createOrder va boshqa order API lar |

## Qanday tekshirish

1. **Ilovani debug rejimida ishga tushiring** (VS Code / Android Studio Run).
2. Konsol (Debug Console) ni oching.
3. Muammoli harakatni bajaring (masalan: Tayyor bosing).
4. Konsolda qidiring:
   - `[API_REQ]` — qaysi so'rov ketdi
   - `[API_OK]` — qaysi so'rov 200/201 oldi
   - `[API_FAIL]` yoki `[PREORDER] … FAILED` — qaysi so'rov xato, status va response nima

## Misol: Tayyor bosganda 500

Konsolda ko'rinishi kerak:
```
[....] [PREORDER] preOrder START | category_unit=5
[....] [API_REQ] POST api/orders/preorder-create/ | body={"address":...
  → URL: https://yuktashish.coded.uz/api/orders/preorder-create/
[....] [API_FAIL] api/orders/preorder-create/ | error=... response=status=500 data=...
  ← ERROR: 500 | {...}
[....] [PREORDER] preOrder FAILED | path=... body=... response=500 ...
```

Shu orqali aniq ko'rasiz: so'rov ketdi, server 500 qaytardi, body va javob nima.

## Barcha API lar avtomatik loglanadi

`ApiLogInterceptor` har bir so'rov va javobni yozadi (HeaderOptions.dio va AuthService.dio orqali barcha chaqiruqlar). Qo'shimcha ravishda repository larda [AUTH], [USER], [PREORDER], [ORDER], [CATEGORIES] tag lari bilan jarayon boshida va oxirida log chiqadi.
