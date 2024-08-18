//
//  RemoteFeedLoader.swift
//  Essentials
//
//  Created by Vishnu on 10/08/24.
//

import Foundation

public final class RemoteFeedLoader {
     private let url: URL
     private let client: HttpClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping(Result) -> Void) {
        client.get(requestedURL: url) { result in
            switch result {
            case let .success(data, response):
                do {
                let items = try FeedItemMapper.map(data, response: response)
                    completion(.success(items))
                } catch {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}


