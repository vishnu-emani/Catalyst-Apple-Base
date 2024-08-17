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

private class FeedItemMapper {
    
    private struct Root: Codable {
        let items: [Item]
    }

    private struct Item: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static var OK_200: Int { return 200 }
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        
// we can move Root and item to inside map func,as we can hide more as shown in commented code below
        
//        struct Root: Codable {
//            let items: [Item]
//        }
//
//        struct Item: Codable {
//            public let id: UUID
//            public let description: String?
//            public let location: String?
//            public let image: URL
//            
//            var item: FeedItem {
//                return FeedItem(id: id, description: description, location: location, imageURL: image)
//            }
//        }
        
        guard response.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map{ $0.item }
    }
}


