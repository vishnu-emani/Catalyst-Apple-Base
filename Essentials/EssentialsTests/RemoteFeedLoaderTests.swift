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
    let url: URL
    init(url: URL, client: HttpClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        
        self.client.get(requestedURL: url)
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
        let url = URL(string: "https://a-url")!
        let client =  HttpClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
    
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        
        let url = URL(string: "https://a-given-url")!
        let client =  HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
}
