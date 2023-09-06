import Foundation

class JKServiceHandler {
    
    func fetchJokes(completionHandler: @escaping (String?, Error?) -> Void) {
        guard let url = URL(string: JKEndpoints.jokeApi.path) else {
            return
        }
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                do {
                    let joke = try JSONDecoder().decode(String.self, from: data)
                    completionHandler(joke, nil)
                } catch {
                    completionHandler(nil, error)
                }
            } else {
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
}
