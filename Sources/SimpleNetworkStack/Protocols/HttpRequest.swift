//
//  HttpRequest.swift
//  SimpleNetworkStack
//
//  Created by Franklyn Weber on 23/05/2022.
//

import Foundation
import Combine

@available(iOS 13, *)
public protocol HttpRequest: SpecializableDecoderHttpRequest where Decoder == JSONDecoder {}


@available(iOS 13, *)
public protocol SpecializableDecoderHttpRequest {
    
    associatedtype QueryType: NetworkQuery
    associatedtype BodyType: NetworkRequestBody
    associatedtype ResponseType: NetworkResponse
    associatedtype AdditionalHeadersType: NetworkHeader
    associatedtype Decoder: TopLevelDecoder where Decoder.Input == Data
    
    var endPoint: NetworkEndPoint { get }
    var method: HttpMethod<QueryType, BodyType> { get }
    var contentType: ContentType? { get }
    var timeoutInterval: TimeInterval? { get }
    var decoder: Decoder { get }
}


// MARK: - Default values
@available(iOS 13, *)
public extension SpecializableDecoderHttpRequest {
    
    var method: HttpMethod<QueryType, BodyType> {
        return .get()
    }
    
    var contentType: ContentType? {
        return .json
    }
    
    var timeoutInterval: TimeInterval? {
        return nil
    }
    
    var decoder: Decoder {
        return JSONDecoder() as! Decoder
    }
}


// MARK: - Public
@available(iOS 13, *)
public extension SpecializableDecoderHttpRequest {
    
    func start() -> AnyPublisher<ResponseType, Error> {
        
        let cancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decode(type: ResponseType.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return cancellable
    }
    
    func start() -> AnyPublisher<ResponseType?, Error> {
        
        let cancellable = URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map { $0.data }
            .decodeIfPresent(type: ResponseType.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return cancellable
    }
}


// MARK: - Private
@available(iOS 13, *)
extension SpecializableDecoderHttpRequest {
    
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


public class DummyDecoder: TopLevelDecoder {
    
    /*
     Doesn't actually decode anything, just sends the data as a string
     */
    
    public typealias Input = Data
    public typealias Output = String
    
    public init() {}
    
    public func decode<Output>(_ type: Output.Type, from: Input) throws -> Output where Output : Decodable {
        guard let output = String(decoding: from, as: UTF8.self) as? Output else {
            throw DecodingError.typeMismatch(String.self, .init(codingPath: [], debugDescription: "Could not output String", underlyingError: nil))
        }
        return output
    }
}
