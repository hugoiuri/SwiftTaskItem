import Foundation

enum Result<Type> {
    case success(Type)
    case error(NetworkError)
}

struct Resource {
    let path: String
    let method: HTTPMethod
    let body: [String: String]?
    let queryItems: [String: String]?
    let headers: [String: String]?
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

enum NetworkError: Error {
    case invalidUrl
    case noHttpResponse
    case noData
    case httpError(code: Int)
    case underlying(Error)
}

enum APIResult {
    case success(Data)
    case failure(NetworkError)
}

typealias JSON = [String: Any]
typealias NetworkServiceResponse = ((APIResult) -> Void)

struct NetworkService {
    private let baseUrl: String
    private let session: URLSession

    init(baseUrl: String, session: URLSession = URLSession.shared) {
        self.baseUrl = baseUrl
        self.session = session
    }

    func callApi(resource: Resource, callback: @escaping NetworkServiceResponse) throws {
        let request = try buildRequest(for: resource)

        let task = session.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse else {
                callback(.failure(NetworkError.noHttpResponse))
                return
            }

            guard error == nil else {
                callback(.failure(NetworkError.underlying(error!)))
                return
            }

            if 200...299 ~= httpResponse.statusCode {
                guard let data = data else {
                    callback(.failure(NetworkError.noData))
                    return
                }

                DispatchQueue.main.async {
                    callback(.success(data))
                }
                return
            } else {
                callback(.failure(NetworkError.httpError(code: httpResponse.statusCode)))
                return
            }
        }

        task.resume()
    }

    private func buildRequest(for resource: Resource) throws -> URLRequest {
        guard var components = URLComponents(string: baseUrl) else { throw NetworkError.invalidUrl }

        components.queryItems = resource.queryItems?.map { ($0.key, $0.value) }.map(URLQueryItem.init)
        guard let url = components.url?.appendingPathComponent(resource.path) else { throw NetworkError.invalidUrl }

        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 120)
        urlRequest.httpMethod = resource.method.rawValue

        resource.headers?.forEach {
            urlRequest.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        if let body: [String: String] = resource.body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }
}
