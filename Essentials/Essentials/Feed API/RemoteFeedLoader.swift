//
//  RemoteFeedLoader.swift
//  Essentials
//
//  Created by Vishnu on 10/08/24.
//

import Foundation

public protocol HttpClient {
    func get(requestedURL: URL, completion: @escaping(Error?, HTTPURLResponse?) -> Void)
}

public final class RemoteFeedLoader {
     private let url: URL
     private let client: HttpClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping(Error) -> Void) {
        self.client.get(requestedURL: url) { error, response  in
            
            if response != nil {
                completion(.invalidData)
            } else  {
                completion(.connectivity)
            }
        }
    }
}
