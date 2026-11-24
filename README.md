# N2 Shoppe — SwiftUI iOS starter (source project)

This is a **native SwiftUI starter**, built from the uploaded N2 Shoppe PHP/MySQL ZIP. It is **not an IPA** and is **not yet App Store-ready**. No website credentials or database dumps are included.

## Implemented
- Native iPhone catalog home, search, product list and detail screens.
- All six official combo product images and product specifications extracted from `backend/config/public-catalog.json`.
- Live public catalog request to `https://n2shoppe.in/backend/api/products.php` with bundled offline preview if unavailable. Availability must be confirmed against live server.
- Product variants display as pickers (NOT transmitted to checkout yet).
- Official website opened in a Safari view for shopping, login and orders.
- Brand icon based on the uploaded website icon.

## Not implemented / still required
- Native signed-in sessions, OTP, cart persistence, wishlist, wallet, checkout, secure payment SDK, order placement, order tracking API and push notifications.
- Native checkout cannot safely use current website session/CSRF API as-is: the uploaded `auth-otp.php` explicitly requires a CSRF token and browser session; `cart-sync.php` bridges the existing PHP cart.
- `orders.php` exposes order lookup via `awb` or `order_number` without visible customer authentication; review/secure this server endpoint before creating a native order screen.
- Verify official website page paths for account/orders, shipping and legal pages. Test on actual iPhones.
- Privacy policy, account deletion flow, screenshots and Apple App Review compliance. A native app offering only website links may be rejected under minimum-functionality rules; further native features should be added.

## Mac build instructions
1. Install Xcode and XcodeGen (`brew install xcodegen`).
2. In Terminal, enter the `N2Shoppe-iOS` folder and run `xcodegen generate`.
3. Open `N2Shoppe.xcodeproj` in Xcode, choose your Apple Development Team and set a unique Bundle Identifier.
4. Select an iPhone simulator and Run; check the live API response in the Xcode console.
5. To distribute: create an Apple Developer organization account, enable signing, test, and archive/upload via Xcode to App Store Connect.

## Source audit
Uploaded site is PHP/MySQL with public catalog endpoint, OTP API, cart bridge, order lookup, and an Android `.apk` (not original Android source). No data is changed on the live server by this starter.
