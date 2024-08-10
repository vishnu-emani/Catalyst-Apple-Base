//
//  RemoteFeedLoaderTests.swift
//  EssentialsTests
//
//  Created by Vishnu on 10/08/24.
//

import Foundation

import XCTest

class RemoteFeedLoader {
    let client: HttpClient
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func load() {
        
        self.client.get(requestedURL: URL(string: "https://a-url")!)
    }
}

protocol HttpClient {
    func get(requestedURL: URL)
}

class HttpClientSpy: HttpClient {
    var requestedURL: URL?
    
    func get(requestedURL: URL) {
        self.requestedURL = requestedURL
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client =  HttpClientSpy()
        _ = RemoteFeedLoader(client: client)
    
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let client =  HttpClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}
