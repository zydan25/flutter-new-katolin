# SHOPIK — Native Flutter Rebuild

هذا مجلد تطبيق Flutter مستقل وجديد، منفصل عن React/Vite والـFlutter Module القديم. الهدف هو أن يكون Flutter هو التطبيق نفسه، بواجهة Full Screen responsive وليس إطار هاتف بعرض 430px.

## المصدر
واجهة التطبيق مبنية بصريًا على `src/` الحالية: اتجاه RTL، ألوان الشركات، البطاقات، التبويبات، شبكة السداد، المتجر، العمليات، الحساب والوايفاي، مع إزالة إطار `max-w-[430px]` الموجود في React.

## Backend
العنوان الأساسي:
`https://shopik.alattab.site/api`

العقود المستخدمة في هذه النسخة:

- `POST /auth/login/` مع `{identifier,password}`
- `GET /auth/me/`
- `GET /wallets/`
- `GET /v2/services/catalog/`
- `GET /v2/services/services/{id}/`
- `POST /v2/services/requests/`
- `GET /v2/services/requests/{uuid}/`
- `GET /v2/services/requests/{uuid}/provider-check/`
- `GET /v2/services/reports/`
- `GET /v2/services/wifi/networks/`
- `POST /v2/services/wifi/purchase/` مع `amount`
- `GET /v2/services/wifi/my-cards/`
- `GET /home/`
- `GET /cities/`, `/categories/`, `/products/`, `/vendors/`
- `GET/POST/PATCH/DELETE /addresses/`
- `GET /orders/`
- `POST /orders/`
- `GET /orders/{id}/order_view/`
- `POST /orders/{id}/confirm_received/`
- `GET /notifications/`
- `POST /gifts/lookup/`
- `GET /gifts/`
- `POST /gifts/`
- `POST /gifts/{id}/confirm/`
- `POST /gifts/{id}/cancel/`

العمليات المدفوعة ترسل `Idempotency-Key`، ولا يوجد Token ثابت داخل التطبيق. يتم حفظ token الحقيقي في `flutter_secure_storage`.

## التشغيل محليًا
```bash
cd shopik_flutter
flutter pub get
flutter create --platforms=android .
flutter run
```

للبناء:
```bash
flutter build apk --release
flutter build appbundle --release
```

يوجد Workflow في `.github/workflows/build-flutter-native.yml` ينشئ Android host تلقائيًا، يشغل `flutter analyze`، ثم يبني APK وAAB ويضعهما في Artifacts.
