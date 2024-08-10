//
//  RemoteFeedLoaderTests.swift
//  EssentialsTests
//
//  Created by Vishnu on 10/08/24.
//

import Foundation

import XCTest

class RemoteFeedLoader {
  
    func load() {
        
        HttpClient.sharedInstance.get(requestedURL: URL(string: "https://a-url")!)
    }
}

class HttpClient {
    static var sharedInstance = HttpClient()
    
    func get(requestedURL: URL) {}
}

class HttpClientSpy: HttpClient {
    var requestedURL: URL?
    
    override func get(requestedURL: URL) {
        self.requestedURL = requestedURL
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client =  HttpClientSpy()
        HttpClient.sharedInstance = client
        let sut = RemoteFeedLoader()
    
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let client =  HttpClientSpy()
        HttpClient.sharedInstance = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}
