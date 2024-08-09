//
//  FeedLoader.swift
//  Essentials
//
//  Created by Vishnu on 09/08/24.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}
protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
