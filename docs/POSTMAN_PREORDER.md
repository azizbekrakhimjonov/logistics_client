# Postman da preorder (Tayyor) so'rovini test qilish

Client "Tayyor" bosganda yuboriladigan so'rov — **preorder yaratish**.

---

## 1. Asosiy ma'lumotlar

| Maydon   | Qiymat |
|----------|--------|
| **Method** | `POST` |
| **URL**    | `https://yuktashish.coded.uz/api/orders/preorder-create/` |

---

## 2. Headers

| Key             | Value               |
|-----------------|---------------------|
| `Content-Type`  | `application/json`  |
| `Accept`        | `application/json`  |
| `Authorization` | `Bearer <TOKEN>`    |

**Token:** Ilovada login/OTP orqali olingan `access` token. Postman da **Authorization** tab da "Bearer Token" tanlab token ni kiriting yoki Headers da `Authorization: Bearer eyJ...` qo'shing.

---

## 3. Request body (JSON) — backend schema

**PreOrder create** da address ichida **id yuborilmaydi** — faqat `name`, `long`, `lat`.

### Majburiy maydonlar

| Maydon | Turi | Izoh |
|--------|------|------|
| address | object | name, long, lat |
| address.name | string | Manzil matni |
| address.long | number | Uzunlik (longitude) |
| address.lat | number | Kenglik (latitude) |
| comment | string | Izoh (bo'sh string bo'lishi mumkin) |
| category_unit | number \| null | Kategoriya/unit ID |
| service_type | string | `"material"` yoki `"driver"` |

### Ixtiyoriy maydonlar (faqat bo'sh emas bo'lsa yuboriladi)

| Maydon | Izoh |
|--------|------|
| entity_type | `"individual"` yoki `"legal"` |
| jshshir | Jismoniy shaxs JSHSHIR |
| stir | Yuridik shaxs STIR |
| mfo | MFO |

### Jismoniy shaxs misoli

```json
{
  "address": {
    "name": "Toshkent, Chilonzor 9",
    "long": 69.123456,
    "lat": 41.234567
  },
  "comment": "",
  "category_unit": 0,
  "service_type": "material",
  "entity_type": "individual",
  "jshshir": "12345678901234"
}
```

---

## 4. Postman da tayyor body (nusxalab qo‘yish uchun)

### Jismoniy shaxs (minimal)

```json
{
  "address": {
    "name": "Toshkent, Chilonzor 9",
    "long": 69.123456,
    "lat": 41.234567
  },
  "comment": "",
  "category_unit": 1,
  "service_type": "material",
  "entity_type": "individual"
}
```

### Yuridik shaxs (stir, mfo bilan)

```json
{
  "address": {
    "name": "Toshkent, Chilonzor 9",
    "long": 69.12,
    "lat": 41.23
  },
  "comment": "",
  "category_unit": 1,
  "service_type": "material",
  "entity_type": "legal",
  "stir": "123456789",
  "mfo": "12345"
}
```

---

## 5. Postman da qadamlar

1. **New Request** → Method: **POST**.
2. URL: `https://yuktashish.coded.uz/api/orders/preorder-create/`
3. **Headers** tab:
   - `Content-Type`: `application/json`
   - `Accept`: `application/json`
   - `Authorization`: `Bearer <sizning_token>`
4. **Body** tab → **raw** → **JSON** tanlang.
5. Yuqoridagi **Jismoniy shaxs** yoki **Yuridik shaxs** JSON ni yoping.
6. **category_unit** ni backend dagi haqiqiy unit ID ga o'zgartiring (agar bilsangiz).
7. **Send** bosing.

---

## 6. Muvaffaqiyatli javob (misol)

- **Status:** `200` yoki `201`
- **Body (misol):** `{"id": 123}` — yaratilgan preorder ID si.

Bu ID keyin transport tanlash (vehicle choose) va buyurtma yaratishda ishlatiladi.
