import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case httpError(Int, Data?)
    case decodingError(Error)
    case encodingError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Некорректный ответ от сервера."
        case .httpError(let code, _):
            return "Ошибка сервера: код \(code)"
        case .decodingError(let error):
            return "Ошибка декодирования: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Ошибка кодирования: \(error.localizedDescription)"
        case .unknown(let error):
            return "Неизвестная ошибка: \(error.localizedDescription)"
        }
    }
}

protocol NetworkClient {
    func request<Request: Encodable, Response: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Request?,
        headers: [String: String]?
    ) async throws -> Response

    func request(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        body: ([String: Any])?,
        headers: [String: String]?
    ) async throws -> Any
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

final class DefaultNetworkClient: NetworkClient {
    private let baseURL = URL(string: "https://shmr-finance.ru/api/v1")!
    private let token: String = Utility.token
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func request<Request: Encodable, Response: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Request?,
        headers: [String: String]? = nil
    ) async throws -> Response {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        if let body = body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }

        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode, data)
            }
            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }

    func request(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        body: ([String: Any])? = nil,
        headers: [String: String]? = nil
    ) async throws -> Any {
        let url: URL
        if let queryItems = queryItems, !queryItems.isEmpty {
            var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
            components.queryItems = queryItems
            guard let composedURL = components.url else {
                throw NetworkError.invalidResponse
            }
            url = composedURL
        } else {
            url = baseURL.appendingPathComponent(endpoint)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        if let body = body {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                throw NetworkError.encodingError(error)
            }
        }

        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode, data)
            }
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
} 
