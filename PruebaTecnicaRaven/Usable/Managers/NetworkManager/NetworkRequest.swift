//
//  NetworkRequest.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import Foundation

struct NetworkRequest {
    let url: NetworkURL
    let method: Self.NetworkMethod
    var params: [Self.NetworkParameter] = []
    var headers: [NetworkHeader] = []
    var body: Self.NetworkHTTPBody = .none
    //MARK: - URL
    struct NetworkURL {
        // FORMAT: baseURL/version/path
        // EXAMPLE: https://myapi.com/api + /v2 + /getUsers
        enum Version: String {
            case none
            case v1 = "v1"
            case v2 = "v2"
        }
        let baseURL: String
        let version: Self.Version
        let path: String
        
        func getComponents() -> URLComponents? {
            var components = URLComponents(string: baseURL)
            let previousPath = components?.path ?? ""
            let path = switch version {
            case .none:
                previousPath + "/\(path)"
            default:
                previousPath + "/\(version.rawValue)/\(path)"
            }
            components?.path = path
            return components
        }
    }
    //MARK: - Method
    enum NetworkMethod: String, Hashable, CaseIterable {
        case get
        case post
        case put
        case patch
        case delete
        case head
        case options
        
        var stringValue: String {
            switch self {
            case .get: "GET"
            case .post: "POST"
            case .put: "PUT"
            case .patch: "PATCH"
            case .delete: "DELETE"
            case .head: "HEAD"
            case .options: "OPTIONS"
            }
        }
        func getTitle() -> String {
            self.stringValue
        }
    }
    //MARK: - Parameters
    struct NetworkParameter {
        let name: String
        let value: String
        var on: Self.parameterType = .query
        enum parameterType {
            case query
            case requestBody
        }
    }
    //MARK: - Body
    enum NetworkHTTPBody {
        case none
        case raw(params: Parameters)
        case formData(boundary: String, params: [Self.FormData])
        case x_www_form_urlencoded(params: [String: Any])
        case binary(data: Data)
        case graphQL(query: String, variables: String)
        
        func encodedAsData() throws -> Data? {
            switch self {
            case .none:
                return nil
            case .raw(let params):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: params)
                    return jsonData
                } catch {
                    throw NetworkError.encodingBodyError
                }
            case .formData(let boundary, let params):
                var body = Data()
                //
                for param in params {
                    switch param.value {
                    case .string(let value):
                        if
                            let boundaryData = "--\(boundary)\r\n".data(using: .utf8),
                            let dispositionData = "Content-Disposition: form-data; name=\"\(param.key)\"\r\n\r\n".data(using: .utf8),
                            let valueData = "\(value)\r\n".data(using: .utf8)
                        {
                            body.append(boundaryData)
                            body.append(dispositionData)
                            body.append(valueData)
                        }
                    case .data(let fileData, let mimeType):
                        let filename = switch mimeType {
                        case .imageJpeg: "image.jpg"
                        default: "file"
                        }
                        if
                            let boundaryData = "--\(boundary)\r\n".data(using: .utf8),
                            let dispositionData = "Content-Disposition: form-data; name=\"\(param.key)\"; filename=\"\(filename)\"\r\n".data(using: .utf8),
                            let typeData = "Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8),
                            let rnData = "\r\n".data(using: .utf8)
                        {
                            //
                            body.append(boundaryData)
                            body.append(dispositionData)
                            body.append(typeData)
                            body.append(fileData)
                            body.append(rnData)
                        }
                    }
                }
                if let closingBoundaryData = "--\(boundary)--\r\n".data(using: .utf8) {
                    body.append(closingBoundaryData)
                }
                return body
            case .x_www_form_urlencoded:
                return Data()
            case .binary:
                return Data()
            case .graphQL:
                return Data()
            }
        }
        
        struct FormData {
            let key: String
            let value: Self.FormDataType
            enum FormDataType {
                case string(value: String)
                case data(fileData: Data, mimeType: MimeType)
            }
            enum MimeType: String {
                case textplain = "text/plain"
                case textHtml = "text/html"
                case imageJpeg = "image/jpeg"
                case applicationJson = "application/json"
                case applicationPdf = "application/pdf"
            }
        }
    }
    //MARK: - Header
    enum NetworkHeader {
        case authorization(value: String)
        case accept(value: String)
        case userAgent(value: String)
        case contentType(value: String)
        case contentLength(value: String)
        case custom(key: String,value: String)
        
        func getKey() -> String {
            switch self {
            case .authorization: "Authorization"
            case .accept: "Accept"
            case .userAgent: "User-Agent"
            case .contentType: "Content-Type"
            case .contentLength: "Content-Length"
            case .custom(let key, _): key
            }
        }
        func getValue() -> String {
            switch self {
            case .authorization(let value): value
            case .accept(let value): value
            case .userAgent(let value): value
            case .contentType(let value): value
            case .contentLength(let value): value
            case .custom(_,let value): value
            }
        }
    }
}
