//
//  NetworkQuery.swift
//  SimpleNetworkStack
//
//  Created by Franklyn Weber on 23/05/2022.
//

import Foundation


public protocol NetworkQuery: Encodable {
    var parameters: [String: String] { get }
}


public extension NetworkQuery {
    
    var parameters: [String: String] {
        return (try? parametersDictionary()) ?? [:]
    }
}
