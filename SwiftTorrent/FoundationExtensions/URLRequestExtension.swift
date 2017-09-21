//
//  RequestComposer.swift
//  SwiftTorrent
//
//  Created by Daniel Tombor on 2017. 09. 16..
//  Copyright © 2017. danieltmbr. All rights reserved.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

protocol QueryParam {
    var urlEncoded: String? { get }
}

extension URLRequest {
    
    init?(method: HttpMethod = .get,
          path: String,
          parameters: [String: QueryParam]? = nil,
          headers: [String: String]? = nil) {
        
        guard var components = URLComponents(string: path)
            else { return nil }
        
        components.percentEncodedQuery = parameters?
            .flatMap { (key: String, value: QueryParam) -> String? in
                guard !key.isEmpty,
                    let key = key.urlEncoded,
                    let value = value.urlEncoded
                    else { return nil }
                return "\(key)=\(value)"
            }
            .joined(separator: "&")
                
        guard let url = components.url
            else { return nil }
        
        var request = URLRequest(url: url)
        
        headers?.forEach {
            guard !$0.key.isEmpty && !$0.value.isEmpty
                else { return }
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        self = request
    }
    
}
