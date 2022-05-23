//
//  NetworkEndPoint.swift
//  SimpleNetworkStack
//
//  Created by Franklyn Weber on 23/05/2022.
//

import Foundation


public protocol NetworkEndPoint {
    var url: URL { get }
    var defaultHeaders: [String: String] { get }
}

public extension NetworkEndPoint {
    
    var defaultHeaders: [String: String] {
        return [:]
    }
}
