# SHOPIK Flutter ↔ Django API contract matrix

Backend source: `zydan25/marketplace/backend`.
Base URL: `https://shopik.alattab.site/api`.

| Domain | Contract | Flutter client | UI |
|---|---|---:|---|
| Accounts | POST `/auth/login/` `{identifier,password}` | ✅ | Login |
| Accounts | GET `/auth/me/` | ✅ | Account/bootstrap |
| Finance | GET `/wallets/` | ✅ | Wallet/dashboard |
| Services | GET `/v2/services/catalog/` | ✅ | Dynamic services/games |
| Services | GET `/v2/services/services/{id}/` | ✅ | Telecom package catalog |
| Services | POST `/v2/services/requests/` + `Idempotency-Key` | ✅ | Recharge/inquiry |
| Services | GET `/v2/services/requests/{uuid}/` | ✅ | Transaction polling |
| Services | GET `/v2/services/requests/{uuid}/provider-check/` | ✅ | API layer available |
| Services | GET `/v2/services/reports/` | ✅ | Operations/reports |
| WiFi | GET `/v2/services/wifi/networks/` | ✅ | WiFi |
| WiFi | POST `/v2/services/wifi/purchase/` with `amount` | ✅ | WiFi purchase |
| WiFi | GET `/v2/services/wifi/my-cards/` | ✅ | Purchased cards |
| Catalog | GET `/home/` | ✅ | API layer available |
| Catalog | GET `/cities/` | ✅ | Address/model |
| Catalog | GET `/categories/` | ✅ | API layer available |
| Catalog | GET `/catalog/tree/` | ✅ | API layer available |
| Catalog | GET `/products/` | ✅ | Store |
| Catalog | GET `/products/{id}/` | ✅ | Product detail |
| Vendors | GET `/vendors/` | ✅ | Store/vendor chips |
| Vendors | GET `/vendors/{id}/` | ✅ | API layer available |
| Cart | POST `/cart/calculate/` | ✅ | API layer available |
| Addresses | GET `/addresses/` | ✅ | Account |
| Addresses | POST `/addresses/` | ✅ | Account |
| Addresses | PATCH `/addresses/{id}/` | ✅ | API layer available |
| Addresses | DELETE `/addresses/{id}/` | ✅ | API layer available |
| Orders | GET `/orders/` | ✅ | Orders |
| Orders | POST `/orders/` | ✅ | Store checkout |
| Orders | GET `/orders/{id}/order_view/` | ✅ | API layer available |
| Orders | POST `/orders/{id}/confirm_received/` | ✅ | Orders |
| Notifications | GET `/notifications/` | ✅ | Notification center |
| Notifications | POST `/notifications/{id}/mark_read/` | ✅ | API layer |
| Conversations | GET/POST `/conversations/` | ✅ | API layer/support-ready |
| Conversations | GET `/conversations/{id}/` | ✅ | API layer |
| Conversations | POST `/conversations/{id}/send_message/` | ✅ | API layer |
| Messages | GET/POST `/messages/` | ✅ | API layer |
| Support | GET `/support/` | ✅ | Customer support |
| Support | POST `/support/messages/` | ✅ | Customer support |
| Preferences | GET/PATCH `/preferences/` | ✅ | API layer |
| Order chats | GET `/order-chats/` | ✅ | API layer |
| Order chats | POST `/order-chats/ensure_for_order/` | ✅ | API layer |
| Order chats | POST `/order-chats/{id}/send_message/` | ✅ | API layer |
| Gifts | GET `/gifts/` | ✅ | Transfer layer |
| Gifts | POST `/gifts/lookup/` `{receiver_phone}` | ✅ | Transfer |
| Gifts | POST `/gifts/` `{receiver_phone,amount,message}` | ✅ | Transfer |
| Gifts | POST `/gifts/{id}/confirm/` | ✅ | Transfer |
| Gifts | POST `/gifts/{id}/cancel/` | ✅ | API layer |

## Security/behavior changes from the old React app

- No fixed authentication token is stored in source code.
- Authentication token is stored in `flutter_secure_storage`.
- Paid service requests receive an `Idempotency-Key`.
- HTTP calls have a 15-second client timeout.
- Failed optional domains do not log the user out after successful authentication.
- WiFi purchase no longer fabricates a PIN/serial number when the server rejects the purchase.
- API responses remain the source of truth; the Flutter app does not silently invent wallet balances or transaction records.

## Live API verification

The Django source contracts were checked against `zydan25/marketplace/backend`. A live credentialed POST test against `shopik.alattab.site` was **not executed from this environment**, because outbound application-network access is unavailable here. The GitHub Actions build is used for Dart/Flutter compilation validation.
