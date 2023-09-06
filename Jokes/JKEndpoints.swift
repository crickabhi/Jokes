import Foundation

enum JKEndpoints {
    private var basePath: String { "https://geek-jokes.sameerkumar.website" }
    
    case jokeApi
}

extension JKEndpoints {
    var path: String {
        let endpointPath: String
        switch self {
        case .jokeApi:
            endpointPath = "/api"
        }
        return basePath.appending(endpointPath)
    }
}
