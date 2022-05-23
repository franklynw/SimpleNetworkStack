//
//  Encodable+Extensions.swift
//  SimpleNetworkStack
//
//  Created by Franklyn Weber on 22/02/2021.
//

import Foundation


extension Encodable {
    
    func parametersDictionary() throws -> [String: String] {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        
        guard let dictionary = jsonObject as? [String: Any] else {
            throw EncodingError.invalidValue(self, EncodingError.Context(codingPath: [], debugDescription: "Failed to make dictionary"))
        }
        
        return dictionary.reduce(into: [String: String]()) {
            $0[$1.key] = String(describing: $1.value)
        }
    }
}
