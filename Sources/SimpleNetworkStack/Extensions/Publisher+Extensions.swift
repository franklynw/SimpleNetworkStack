//
//  Publisher+Extensions.swift
//  
//
//  Created by Franklyn Weber on 23/05/2022.
//

import Foundation
import Combine


@available(iOS 13, *)
public extension Publisher {
    
    func decodeIfPresent<T: Decodable, Coder: TopLevelDecoder>(type: T.Type, decoder: Coder) -> AnyPublisher<T?, Error> where Coder.Input == Output {
        
        mapError { $0 as Error }
            .flatMap { d -> AnyPublisher<T?, Error> in
                
                do {
                    let decoded: T? = try decoder.decode(type, from: d)
                    return Future<T?, Error> { promise in
                        promise(.success(decoded))
                    }
                    .eraseToAnyPublisher()
                    
                } catch {
                    return Just<T?>(nil)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}
