import Foundation
import OSLog

public struct AppScheme: Codable {
    let label: String
    let scheme: String
    
    enum CodingKeys: String, CodingKey {
        case label = "Label"
        case scheme = "Scheme"
    }
}

@globalActor
public actor AppSchemes {
    public static let shared = AppSchemes()
    
    var schemes: [AppScheme] = []
    
    init() {
        if let url = Bundle.module.url(forResource: "Apple", withExtension: "plist") {
            let decoder = PropertyListDecoder()
            do {
                guard let data = try FileManager.default.contents(atPath: url.path()) else {
                    return
                }
                schemes = try decoder.decode([AppScheme].self, from: data)
            } catch {
                os_log(.error, "Error decoding schemes: %@", error.localizedDescription)
            }
        }
        
        if let url = Bundle.module.url(forResource: "ThirdParty", withExtension: "plist") {
            let decoder = PropertyListDecoder()
            do {
                guard let data = try FileManager.default.contents(atPath: url.path()) else {
                    return
                }
                schemes = try decoder.decode([AppScheme].self, from: data)
            } catch {
                os_log(.error, "Error decoding schemes: %@", error.localizedDescription)
            }
        }
    }
}
