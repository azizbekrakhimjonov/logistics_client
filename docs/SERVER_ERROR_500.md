# «Внутренняя ошибка сервера» / «Serverdagi ichki xatolik» — nima va qanday bartaraf etish

## Bu qanday muammo?

Bu xabar **backend (server)** tomondagi xato. Ilova API ga so‘rov yuboradi, server **HTTP 500 Internal Server Error** qaytaradi, ilova esa buni joriy tilga tarjima qilib ko‘rsatadi:
- **Rus:** Внутренняя ошибка сервера  
- **O‘zb:** Serverdagi ichki xatolik  

Ya’ni muammo **klient (Flutter) ilovasida emas**, balki **server dasturida** yoki uning atrofidagi tizimda (DB, tashqi API va hokazo).

---

## Rasmdagi aniq xato: `yuktashish.contrib.exceptions` topilmayapti

Agar Django debug sahifasida shunday yozuv chiqsa:

```text
ImportError at /api/orders/user/check/
Could not import 'yuktashish.contrib.exceptions.custom_exception_handler' for API setting 'EXCEPTION_HANDLER'.
ModuleNotFoundError: No module named 'yuktashish.contrib.exceptions'
```

demak, DRF sozlamasida `EXCEPTION_HANDLER` mavjud bo‘lmagan modulga yo‘naltirilgan.

### Avvalgi (ishlaydigan) holatiga qaytarish — ikkita yo‘l

**1-variant (tez):** DRF da standart exception handler ishlatish.

Backend loyihasida (yuktashish) `settings.py` yoki REST_FRAMEWORK sozlamasida:

```python
REST_FRAMEWORK = {
    ...
    'EXCEPTION_HANDLER': 'rest_framework.views.exception_handler',  # standart
    ...
}
```

Agar `EXCEPTION_HANDLER` `yuktashish.contrib.exceptions.custom_exception_handler` qilib qo‘yilgan bo‘lsa, uni yuqoridagi satrga almashtiring. Sahifa avvalgi holatiga (500-siz) qaytadi.

**2-variant:** Modulni yaratish.

`yuktashish` loyihasida:

1. `yuktashish/contrib/` papkasini yarating (agar yo‘q bo‘lsa).
2. `yuktashish/contrib/__init__.py` — bo‘sh yoki `# empty` qoldiring.
3. `yuktashish/contrib/exceptions.py` yarating va ichiga:

```python
from rest_framework.views import exception_handler

def custom_exception_handler(exc, context):
    return exception_handler(exc, context)
```

qo‘ying. So‘ngra qayerdadir kerak bo‘lsa, shu funksiyani kengaytirib, o‘z formatlaringizni qo‘shasiz.

Til o‘zgarganda ilovadagi matnlar `.tr()` orqali almashadi — bu client (Flutter) tomonda allaqachon ishlaydi; backendni shu ImportError dan xolis qilgach, 500 va katta qizil sahifa yo‘qoladi.

## Nima o‘zgartirildi (client tomonda)

1. **`lib/utils/exceptions.dart`**
   - 500 (va boshqa kodlar) uchun server javobidan `detail` / `message` / `error` xavfsiz o‘qiladi. Agar server JSON ichida batafsil xabar yuborsa, u foydalanuvchiga ko‘rsatiladi.
   - 500 kelganda `print("[500] Server response: ...")` qo‘shildi — debug vaqtida konsolda server javobini ko‘rish uchun.
   - 422 va boshqa holatlar uchun xavfsiz o‘qish (null/crashdan himoya) qilindi.

2. **`lib/utils/services.dart`**
   - `showSnackBar` da `message` bo‘sh yoki `null` bo‘lsa, «Something went wrong» ko‘rsatiladi (crash bo‘lmaydi).

## Bartaraf etish (asl yechim — server tomonda)

1. **Backend loglarini tekshiring**  
   So‘rov vaqtida server logida qanday exception/error chiqayotganini ko‘ring (Django, Node, FastAPI va hokazo).

2. **Ilova konsolida 500 javobini ko‘ring**  
   Flutter ilovasini debug rejimida ishga tushiring. 500 kelganda konsolda shunga o‘xshash satr chiqadi:
   ```text
   [500] Server response: {...}
   ```
   Bu yerda `{...}` — serverdan kelgan JSON/javob. Shu orqali qaysi so‘rov 500 qaytarayotgani va nima yozilgani aniqroq bo‘ladi.

3. **Tipik sabablar**
   - Ma’lumotlar bazasiga ulanish xatosi
   - Noto‘g‘ri yoki yetishmas environment (API kalit, URL, DB parol)
   - Backend kodidagi bug (null, index xatosi, type xatosi)
   - Kerakli fayl/yoki tashqi servis ishlamayapti

4. **API/base URL ni tekshiring**  
   `lib/constants/endpoints.dart` (yoki boshqa config) dagi base URL haqiqiy backend manziliga mos kelayotganini tekshiring.

---

**Xulosa:**  
«Внутренняя ошибка сервера» / «Serverdagi ichki xatolik» — backend 500 xabari. To‘liq bartaraf etish uchun server logi va [500] da chiqayotgan `Server response` ni tekshirib, xatoni backend kodida tuzatish kerak.
