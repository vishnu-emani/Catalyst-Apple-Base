//
//  FeedItemMapper.swift
//  Essentials
//
//  Created by Vishnu on 18/08/24.
//

import Foundation


internal final class FeedItemMapper {
    
    private struct Root: Codable {
        let items: [Item]
        
        var feed: [FeedItem] {
           return items.map{ $0.item }
        }
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
    
    private static var OK_200: Int { return 200 }
    
    internal static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }
        
        return .success(root.feed)
    }
}
