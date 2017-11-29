import Foundation
import Firebase


enum NetworkAPI: String {
    case category = "getCategory"
    case cancel = "cancel"
}

let baseURL =  "us-central1-instasolve-d8c55.cloudfunctions.net"

func urlForNetworkAPI(_ api: NetworkAPI) -> URL? {
    // get the baseURLe from firebase
    return URL(string: ["http:/", baseURL, api.rawValue].joined(separator: "/"))
}

