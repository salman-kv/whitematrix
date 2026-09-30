# ShopEase

A simple shopping app built with Flutter (Android). Browse products, search, filter, add to cart, save favourites and place orders.

## Login

Use the email **or** the phone number.

| Name | Email | Phone | Password |
|---|---|---|---|
| Salman Khan | `salman@gmail.com` | `9876543210` | `Shop@123` |
| Aisha Rahman | `aisha@shopease.com` | `9123456780` | `Aisha@456` |
| Rahul Nair | `rahul@shopease.com` | `9000011111` | `Rahul@789` |

Tip: on the login screen tap **Use** to fill the form, or the group icon to see all accounts.
Each account keeps its **own** cart, wishlist and orders.

## Run the app

You need Flutter 3.41+ and an Android emulator or phone (with internet).

```bash
flutter pub get
flutter run
```

Build the APK: `flutter build apk --release`
(result: `build/app/outputs/flutter-apk/app-release.apk`)

## What you can do

- Log in with validation and error messages
- Browse products with **infinite scrolling**
- Search, sort and filter by price and category
- View product details and image gallery
- Add to cart, change quantity, check out
- Save products to the wishlist
- See your orders in Profile
- Switch **Light / Dark / System** theme in Profile → Settings

## Where the data comes from

- **Products, images and prices:** the free [DummyJSON](https://dummyjson.com) API (no key needed). If there is no internet, sample products are shown instead.
- **Cart, wishlist, orders, recent searches:** created by you and saved on the phone, separately for each account.
- **Logins:** fixed in `lib/core/demo_accounts.dart` (there is no backend).
- **Review counts and the "original" price:** worked out by the app, because the API does not provide them. The API has no colour or size data, so every product shows one default choice: Color "Default" and Size "One size".

## Built with

Flutter, MVC structure, `provider` for state, `http`, `cached_network_image`, `shimmer`, `shared_preferences`, `google_fonts` (Poppins).

## Project structure

```
lib/
├── core/         theme, colours, routes, demo accounts
├── models/       Product, Category, CartItem, Order, User
├── services/     API, local storage, search/filter rules
├── controllers/  app logic and state (Provider)
├── views/        screens
└── widgets/      reusable UI parts
```

Screenshots are in the `screenshots/` folder.
