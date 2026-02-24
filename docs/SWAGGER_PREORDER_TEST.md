# Preorder API — Swagger da test qilish

## Nima o‘zgardi va nima uchun 500 bo‘lishi mumkin

- **Avval** klient faqat `address`, `comment`, `category_unit` yuborardi — API 500 bermagan.
- **Keyin** Swagger schema da `service_type`, `entity_type`, `jshshir`, `stir`, `mfo` ko‘rsatilgandi va ular klientga qo‘shildi.
- Agar backend bu maydonlarni **majburiy** qilib validatsiya qilsa yoki **format**ni qattiq tekshirsa (masalan, bo‘sh string qabul qilmasa), 500 yoki 400 chiqishi mumkin.
- **Hozir** klient yana **faqat eski format**ni yuboradi: `address`, `comment`, `category_unit`. Shunda API yana ishlashi kerak (agar backend o‘zgartirilmagan bo‘lsa).

Swagger da quyidagi ikkala variantni sinab ko‘ring: avval **minimal**, keyin **to‘liq** body.

---

## 1. Endpoint va method

- **Method:** `POST`
- **Path:** `/api/orders/preorder-create/`
- **Base URL:** loyihangizdagi backend manzili (masalan `https://api.example.com` yoki `http://localhost:8000`).
- **To‘liq URL:** `{Base URL}/api/orders/preorder-create/`

---

## 2. Headers

| Key            | Value             |
|----------------|-------------------|
| `Content-Type` | `application/json` |
| `Accept`       | `application/json` |
| `Authorization`| `Bearer <TOKEN>`   |

**Token olish:** Avval login/register API orqali token oling yoki Postman/ilovadan mavjud tokenni nusxalang.

---

## 3. Request body — minimal (klient hozir shuni yuboradi)

Bu **avval ishlagan** format. Swagger da **Request body** maydoniga quyidagini kiriting:

```json
{
  "address": {
    "name": "1600 Amphitheatre Pkwy, California",
    "long": -122.0842,
    "lat": 37.4220
  },
  "comment": "",
  "category_unit": 1
}
```

- **Saqlangan manzil** bo‘lsa, `address` ichiga `"id": 5` (o‘zingizning manzil id) qo‘shing.
- **category_unit** — tanlangan hajm (unit) ID si. Swagger/categories API dan bitta haqiqiy ID oling (masalan `1`, `2`, `5`).

---

## 4. Request body — to‘liq (Swagger schema dagi barcha maydonlar)

Agar backend **barcha** maydonlarni talab qilsa, quyidagidan foydalaning:

```json
{
  "address": {
    "id": 0,
    "name": "1600 Amphitheatre Pkwy, California",
    "long": -122.0842,
    "lat": 37.4220
  },
  "comment": "",
  "service_type": "material",
  "entity_type": "individual",
  "jshshir": "",
  "stir": "",
  "mfo": "",
  "category_unit": 1
}
```

- `address.id`: yangi manzil uchun `0`, saqlangan manzil uchun haqiqiy ID.
- `category_unit`: haqiqiy unit ID (masalan `1`).

---

## 5. Swagger da qadamlar

1. Swagger UI ni oching (backend manzili + `/swagger/` yoki `/docs/`).
2. `POST /api/orders/preorder-create/` ni oching.
3. **Try it out** bosing.
4. **Request body** maydoniga yuqoridagi **minimal** JSON ni yoping.
5. **Authorization** kerak bo‘lsa: sahifaning yuqorisida **Authorize** orqali token kiriting yoki Headers da `Authorization: Bearer <token>` qo‘shing.
6. **Execute** bosing.
7. **Response** da status `200`/`201` bo‘lsa — minimal format qabul qilinadi.
8. Agar **400** yoki **500** chiqsa — javob body sini ko‘ring (qaysi maydon xato).
9. Keyin **to‘liq** body ni sinab ko‘ring — 500 to‘xtasa, backend yangi maydonlarni talab qilayotgani aniq.

---

## 6. Xulosa

- **Minimal body** ishlasa — muammo klientda qo‘shilgan maydonlar edi; hozir klient faqat minimal yuboradi.
- **Minimal** ham 500 bersa — backend (serializer, view, DB) ni tekshiring; logda stack trace chiqadi.
- **To‘liq body** ishlasa, **minimal** 500 bersa — backend yangi maydonlarni majburiy qilgan; ularni klientga qayta qo‘shish kerak yoki backend da ixtiyoriy qilish kerak.
