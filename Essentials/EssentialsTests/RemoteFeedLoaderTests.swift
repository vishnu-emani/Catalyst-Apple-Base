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
        
        HttpClient.sharedInstance.requestedURL = URL(string: "https://a-url")
    }
}

class HttpClient {
    static let sharedInstance = HttpClient()
    
    private init() {}
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client =  HttpClient.sharedInstance
        let sut = RemoteFeedLoader()
    
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let client =  HttpClient.sharedInstance
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}
