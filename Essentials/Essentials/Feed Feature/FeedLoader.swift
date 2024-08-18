//
//  FeedLoader.swift
//  Essentials
//
//  Created by Vishnu on 09/08/24.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
