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
    internal static func map(_ data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        
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
