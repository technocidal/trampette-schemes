import Foundation
import OSLog

public struct Scheme: Codable {
    public let label: String
    public let `protocol`: String

    enum CodingKeys: String, CodingKey {
        case label = "Label"
        case `protocol` = "Scheme"
    }
}

public enum Category: String, CaseIterable {
    case apple
    case thirdParty
}

public struct AppScheme {
    public let scheme: Scheme
    public let category: Category
}

@globalActor
public actor AppSchemes {
    public static let shared = AppSchemes()
    
    
    public var all: [AppScheme] {
        schemes.sorted { $0.scheme.label < $1.scheme.label }
    }
    
    public var apple: [AppScheme] {
        schemes.filter { $0.category == .apple }
    }
    
    public var thirdParty: [AppScheme] {
        schemes.filter { $0.category == .thirdParty }
    }
    
    private var schemes = [AppScheme]()
    
    init() {
        if let url = Bundle.module.url(forResource: "Apple", withExtension: "plist") {
            let decoder = PropertyListDecoder()
            do {
                guard let data = FileManager.default.contents(atPath: url.path()) else {
                    return
                }
                let decoded = try decoder.decode([Scheme].self, from: data)
                schemes.append(contentsOf: decoded.map { AppScheme(scheme: $0, category: .apple)})
            } catch {
                os_log(.error, "Error decoding schemes: %@", error.localizedDescription)
            }
        }

        if let url = Bundle.module.url(forResource: "ThirdParty", withExtension: "plist") {
            let decoder = PropertyListDecoder()
            do {
                guard let data = FileManager.default.contents(atPath: url.path()) else {
                    return
                }
                let decoded = try decoder.decode([Scheme].self, from: data)
                schemes.append(contentsOf: decoded.map { AppScheme( scheme: $0, category: .thirdParty)})
            } catch {
                os_log(.error, "Error decoding schemes: %@", error.localizedDescription)
            }
        }
    }
    
    public func schemes(for category: Category) -> [AppScheme] {
        schemes.filter { $0.category == category }
    }
    
    public func search(query: String) async -> [AppScheme] {
        if query.isEmpty {
            return schemes
        }
        
        let finalElements = schemes.map({ appScheme -> (score: Double, scheme: AppScheme) in
            let normalizedQuery = query.normalizedForScoring
            let normalizedLabel = appScheme.scheme.label.normalizedForScoring
            let score = normalizedLabel.score(word: normalizedQuery, fuzziness: 0.25)
            return (score, appScheme)
        })
        .filter { $0.score > 0.1 }
        .sorted(by: { $0.score > $1.score })
        .map { $0.scheme }
        
        return finalElements
    }
}
