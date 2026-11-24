import Foundation
import SwiftUI

struct CatalogEnvelope: Decodable {
    let status: String
    let data: [ShopProduct]
}

struct ProductVariant: Codable {
    let label: String
    let values: [String]
}

struct ShopProduct: Codable, Identifiable {
    let id: String
    let name: String
    let tagline: String
    let price: Double
    let mrp: Double?
    let image: String
    let inclusions: [String]?
    let variants: [String: ProductVariant]?
    let isAvailable: Bool?
    let stockQuantity: Int?
    let targetGender: String?
    var imageURL: URL? { URL(string: "https://n2shoppe.in" + image) }
    var availabilityConfirmed: Bool { isAvailable == true }
}

@MainActor
final class CatalogStore: ObservableObject {
    @Published private(set) var products: [ShopProduct] = []
    @Published private(set) var loadedFromLiveAPI = false
    @Published private(set) var errorText: String?
    @Published var search = ""

    init() { loadBundledPreview() }

    func loadBundledPreview() {
        guard let url = Bundle.main.url(forResource: "catalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([ShopProduct].self, from: data) else { return }
        products = decoded
    }

    func refresh() async {
        guard let url = URL(string: "https://n2shoppe.in/backend/api/products.php") else { return }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 20
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
            let result = try JSONDecoder().decode(CatalogEnvelope.self, from: data)
            guard result.status == "success" else { throw URLError(.cannotParseResponse) }
            products = result.data
            loadedFromLiveAPI = true
            errorText = nil
        } catch {
            loadedFromLiveAPI = false
            errorText = "Live catalog unavailable. Showing saved product preview; check stock on website."
        }
    }

    var filteredProducts: [ShopProduct] {
        products.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) || $0.tagline.localizedCaseInsensitiveContains(search) }
    }
}
