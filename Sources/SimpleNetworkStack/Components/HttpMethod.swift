//
//  HttpMethod.swift
//  SimpleNetworkStack
//
//  Created by Franklyn Weber on 23/05/2022.
//

import Foundation


public enum HttpMethod<QueryType: NetworkQuery, BodyType: Encodable> {
    case get(query: QueryType? = nil)
    case post(query: QueryType? = nil, body: BodyType?)
    
    var name: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .get(let query), .post(let query, _):
            return query?.parameters
        }
    }
    
    var body: Data? {
        switch self {
        case .get:
            return nil
        case .post(_, let body):
            
            do {
                return try JSONEncoder().encode(body)
            } catch {
                print("Failed to encode body: \(error.localizedDescription)")
            }
            
            return nil
        }
    }
}
