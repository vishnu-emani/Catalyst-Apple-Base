//
//  RemoteFeedLoader.swift
//  Essentials
//
//  Created by Vishnu on 10/08/24.
//

import Foundation

public enum HttpClientResponse {
  case success(Data, HTTPURLResponse)
  case failure(Error)
}

public protocol HttpClient {
    func get(requestedURL: URL, completion: @escaping(HttpClientResponse) -> Void)
}

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
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                     completion(.success(root.items))
                } else {
                    completion(.failure(.invalidData))
                }
                
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let items: [FeedItem]
}
