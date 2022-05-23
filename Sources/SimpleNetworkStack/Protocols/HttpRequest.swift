//
//  HttpRequest.swift
//  SimpleNetworkStack
//
//  Created by Franklyn Weber on 23/05/2022.
//

import Foundation
import Combine


public protocol HttpRequest {
    associatedtype QueryType: NetworkQuery
    associatedtype BodyType: NetworkRequestBody
    associatedtype ResponseType: NetworkResponse
    associatedtype AdditionalHeadersType: NetworkHeader
    var endPoint: NetworkEndPoint { get }
    var method: HttpMethod<QueryType, BodyType> { get }
    var contentType: ContentType? { get }
    var timeoutInterval: TimeInterval? { get }
}


// MARK: - Default values
public extension HttpRequest {
    
    var method: HttpMethod<QueryType, BodyType> {
        return .get()
    }
    
    var contentType: ContentType? {
        return .json
    }
    
    var timeoutInterval: TimeInterval? {
        return nil
    }
}


// MARK: - Public
public extension HttpRequest {
    
    func start() -> AnyPublisher<ResponseType, Error> {
        
        let cancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: ResponseType.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return cancellable
    }
}


// MARK: - Private
extension HttpRequest {
    
    private var urlRequest: URLRequest {
        
        let url = endPoint.url
        let urlWithParameters = addQueryParameters(to: url)
        
        var request = URLRequest(url: urlWithParameters)
        
        request.httpMethod = method.name
        
        addDefaultHeaders(to: &request)
        addHeaders(to: &request)
        addBody(to: &request)
        
        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        
        return request
    }
    
    private func addQueryParameters(to url: URL) -> URL {
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = method.queryParameters?.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        return components?.url ?? url
    }
    
    private func addBody(to request: inout URLRequest) {
        request.httpBody = method.body
    }
    
    private func addHeaders(to request: inout URLRequest) {
        
        var headers = [String: String]()
        
        if let contentType = contentType?.rawValue {
            headers["Content-Type"] = contentType
        }
        
        if let additionalHeaders = try? AdditionalHeadersType().parametersDictionary() {
            additionalHeaders.forEach {
                headers[$0.key] = $0.value
            }
        }
        
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
    }
    
    private func addDefaultHeaders(to request: inout URLRequest) {
        
        let defaultHeaders = endPoint.defaultHeaders
        
        defaultHeaders.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
    }
}
