//
//  NetworkResponse.swift
//  SimpleNetworkStack
//
//  Created by Franklyn Weber on 23/05/2022.
//

import Foundation


public protocol NetworkResponse: Decodable {
    
}


public extension Array: NetworkResponse where Element: Decodable {}
