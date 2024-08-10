//
//  RemoteFeedLoader.swift
//  Essentials
//
//  Created by Vishnu on 10/08/24.
//

import Foundation

public protocol HttpClient {
    func get(requestedURL: URL)
}

public final class RemoteFeedLoader {
     private let url: URL
     private let client: HttpClient
    
    public init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        self.client.get(requestedURL: url)
    }
}
