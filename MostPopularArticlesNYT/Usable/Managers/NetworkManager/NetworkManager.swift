//
//  NetworkManager.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import Foundation
import OSLog

actor NetworkManager {
    //GENERAL CONFIGURATION
    //    static nonisolated let IS_PRODUCTION: Bool = false
    static nonisolated let BASE_URL: String = "https://api.nytimes.com/svc/mostpopular"
    static nonisolated let printLogs: Bool = false
    private init() { }
    /// Main function to perform the request
    public static func request(request req: NetworkRequest) async throws -> NetworkResponse {
        //URL
        let url: URL = try {
            var components = req.url.getComponents()
            guard components?.path.first == "/" else { throw NetworkError.URLPathHasNoSlash  }
            let queryItems = req.params
                .filter{ $0.on == .query }
                .map{
                    URLQueryItem(name: $0.name, value: $0.value)
                }
            //            let authQueryItems =
            components?.queryItems = queryItems
            guard let finalUrl: URL = components?.url else { throw NetworkError.invalidURL }
            return finalUrl
        }()
        //
        var request = URLRequest(url: url)
        //Add Method
        request.httpMethod = req.method.rawValue
        //Add Body
        request.httpBody = try req.body.encodedAsData()
        //Add headers
        req.headers.forEach {
            request.addValue($0.getValue(), forHTTPHeaderField: $0.getKey())
        }
        // Configuration
        let configuration = URLSessionConfiguration.default
        configuration.isDiscretionary = true
        configuration.waitsForConnectivity = true
//        configuration.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession(configuration: configuration)
        // MAKING THE RESQUEST
        let (data, rawResponse) = try await session.data(for: request)
        guard let response = rawResponse as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        //Printing Values
        if Self.printLogs {
            os_log("🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️[NEW SERVICE CALL]🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️")
            let responseDescription = """
                ⚔️[Method]: \(request.httpMethod ?? "UNKNOWN")
                ⚔️[Status]: \(response.statusCode)
                📡[URL]: \(request.url?.absoluteString ?? "INVALID URL")
                🛸[Request Headers]: \(String(describing: request.allHTTPHeaderFields))
                🛩️[RESPONSE]: \(getPrettyJSONString(data))
            """
            os_log("\(responseDescription)")
        }
        //
        return NetworkResponse(
            status: response.statusCode,
            time: 1,
            size: rawResponse.expectedContentLength,
            data: data
        )
    }
    /// Make a request using a NetwortRequest and returning a Codable Model and the Network Response within a tuple
    /// - Parameter req: NetworkRequest
    /// - Returns: Tuple of (Codable Model, NetworkRequest)
    public static func request<T: Codable>(request req: NetworkRequest) async throws -> (T,status: Int) {
        let response = try await NetworkManager.request(request: req)
        //Decoding
        let dataDecoded: T = try await Self.decode(data: response.data)
        return (dataDecoded, status: response.status)
    }
    /// Make a request using a NetwortRequest and returning only the Codable Model
    /// - Parameter req: NetworkRequest
    /// - Returns: Codable Model
    public static func request<T: Codable>(request req: NetworkRequest) async throws -> T {
        let response = try await NetworkManager.request(request: req)
        //Decoding
        let dataDecoded: T = try await Self.decode(data: response.data)
        return (dataDecoded)
    }
    /// Upload a multipartRequest using form data in order to send files,
    /// the header for multipart/formadata is already setted, no need to added
    /// - Parameters:
    ///   - url: NetworkRequest.NetworkURL
    ///   - params: Array of NetworkRequest.NetworkParameter
    ///   - receivedHeaders: NetworkRequest.NetworkHeader]
    ///   - formData: Array of NetworkRequest.NetworkBody.FormData
    ///   - autorization: NetworkRequest.NetworkAutorization
    /// - Returns: Codable model
    public static func multipartRequest<T: Codable>(url: NetworkRequest.NetworkURL, params: [NetworkRequest.NetworkParameter] = [], headers receivedHeaders: [NetworkRequest.NetworkHeader] = [], formData: [NetworkRequest.NetworkHTTPBody.FormData]) async throws -> T {
        let boundary = UUID().uuidString
        var headers = receivedHeaders
        headers.append(.contentType(value: "multipart/form-data; boundary=\(boundary)"))
        return try await self.request(
            request: .init(
                url: url,
                method: .post,
                params: params,
                headers: headers,
                body: .formData(
                    boundary: boundary,
                    params: formData
                )
            )
        )
    }
    public static func fetchData(url: String) async throws -> Data? {
        try await Self.request(request: .init(
            url: NetworkRequest.NetworkURL(baseURL: url, version: .none, path: nil),
            method: .get
        )).data
    }
    public static func decode<T: Codable>(data: Data) async throws -> T {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let dataDecoded = try? jsonDecoder.decode(T.self, from: data) else { throw NetworkError.decodingError }
        return dataDecoded
    }
}

struct CustomCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { return nil }
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        return nil
    }
}
