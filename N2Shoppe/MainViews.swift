import SwiftUI
import SafariServices

struct InAppBrowser: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct MainTabs: View {
    var body: some View {
        TabView {
            NavigationStack { StorefrontView() }
                .tabItem { Label("Shop", systemImage: "bag") }
            NavigationStack { OnlinePage(title: "My Orders", path: "/?page=my-orders") }
                .tabItem { Label("Orders", systemImage: "shippingbox") }
            NavigationStack { OnlinePage(title: "My Account", path: "/?page=account") }
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
    }
}

struct StorefrontView: View {
    @EnvironmentObject private var store: CatalogStore
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    @State private var showCart = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 9) {
                    Text("SHOP SMART • WEAR BETTER").font(.caption.weight(.bold)).tracking(1.5)
                    Text("Exclusive Combo Packs").font(.largeTitle.bold())
                    Text("Explore curated fashion combos from N2 Shoppe.").font(.subheadline)
                    Button { showCart = true } label: {
                        Label("Shop on official website", systemImage: "arrow.up.right")
                            .font(.subheadline.bold()).padding(.vertical, 9).padding(.horizontal, 14)
                            .background(.white, in: Capsule()).foregroundStyle(Color.n2Red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(21)
                .foregroundStyle(.white)
                .background(LinearGradient(colors: [.n2Red, Color(red: 0.29, green: 0.02, blue: 0.06)], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 22))

                if let error = store.errorText {
                    Label(error, systemImage: "wifi.exclamationmark")
                        .font(.caption).foregroundStyle(.orange)
                }
                TextField("Search combo packs", text: $store.search)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Text("Featured Products").font(.title2.bold())
                    Spacer()
                    Text("\(store.filteredProducts.count) products").font(.caption).foregroundStyle(.secondary)
                }
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(store.filteredProducts) { product in
                        NavigationLink(value: product.id) { ProductTile(product: product) }
                            .buttonStyle(.plain)
                    }
                }
            }.padding(16)
        }
        .background(Color.n2Bg)
        .navigationTitle("N2 Shoppe")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { showCart = true } label: { Image(systemName: "cart") } } }
        .navigationDestination(for: String.self) { id in
            if let product = store.products.first(where: { $0.id == id }) { ProductDetail(product: product) }
        }
        .sheet(isPresented: $showCart) { InAppBrowser(url: URL(string: "https://n2shoppe.in/")!) }
        .refreshable { await store.refresh() }
    }
}

struct ProductTile: View {
    let product: ShopProduct
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(product.id).resizable().scaledToFit().frame(maxWidth: .infinity).frame(height: 165).background(.white)
            Text(product.name).font(.subheadline.bold()).lineLimit(2).foregroundStyle(.primary)
            Text(product.tagline).font(.caption2).lineLimit(2).foregroundStyle(.secondary)
            Text(product.price, format: .currency(code: "INR")).font(.headline).foregroundStyle(Color.n2Red)
            if let mrp = product.mrp {
                Text(mrp, format: .currency(code: "INR")).font(.caption).strikethrough().foregroundStyle(.secondary)
            }
            Text(product.availabilityConfirmed ? "Available on site" : "Check availability")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 15))
    }
}

struct ProductDetail: View {
    let product: ShopProduct
    @State private var selected: [String: String] = [:]
    @State private var openShop = false
    private var keys: [String] { (product.variants ?? [:]).keys.sorted() }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Image(product.id).resizable().scaledToFit().frame(maxWidth: .infinity).background(.white, in: RoundedRectangle(cornerRadius: 16))
                Text(product.name).font(.title.bold())
                Text(product.tagline).foregroundStyle(.secondary)
                Text(product.price, format: .currency(code: "INR")).font(.title2.bold()).foregroundStyle(Color.n2Red)
                if let inclusions = product.inclusions {
                    Text("What's included").font(.headline)
                    ForEach(inclusions, id: \.self) { item in Label(item, systemImage: "checkmark.circle.fill").font(.subheadline) }
                }
                ForEach(keys, id: \.self) { key in
                    if let variant = product.variants?[key], !variant.values.isEmpty {
                        Picker(variant.label, selection: Binding(
                            get: { selected[key] ?? variant.values[0] },
                            set: { selected[key] = $0 }
                        )) {
                            ForEach(variant.values, id: \.self) { value in Text(value).tag(value) }
                        }.pickerStyle(.menu)
                    }
                }
                Text("Final stock, selected variants, delivery and total will be confirmed on the official website.")
                    .font(.caption).foregroundStyle(.secondary)
                Button { openShop = true } label: {
                    Text("Continue shopping securely").font(.headline).frame(maxWidth: .infinity).padding()
                }.buttonStyle(.borderedProminent).tint(.n2Red)
            }.padding(16)
        }
        .background(Color.n2Bg)
        .navigationTitle("Product Details").navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $openShop) { InAppBrowser(url: URL(string: "https://n2shoppe.in/")!) }
    }
}

struct OnlinePage: View {
    let title: String
    let path: String
    @State private var showingPage = false
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "person.crop.rectangle.stack").font(.system(size: 55)).foregroundStyle(Color.n2Red)
            Text("Your N2 Shoppe account").font(.title2.bold())
            Text("Secure login and customer orders are available through the existing website. This starter does not store account credentials on the device.")
                .multilineTextAlignment(.center).foregroundStyle(.secondary)
            Button("Open \(title)") { showingPage = true }
                .buttonStyle(.borderedProminent).tint(.n2Red)
        }
        .padding(25)
        .navigationTitle(title)
        .sheet(isPresented: $showingPage) { InAppBrowser(url: URL(string: "https://n2shoppe.in" + path)!) }
    }
}
