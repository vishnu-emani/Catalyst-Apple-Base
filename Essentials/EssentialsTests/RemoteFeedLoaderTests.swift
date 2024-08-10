//
//  RemoteFeedLoaderTests.swift
//  EssentialsTests
//
//  Created by Vishnu on 10/08/24.
//

import Foundation

import XCTest

class RemoteFeedLoader {
    
}
class HttpClient {
    
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client =  HttpClient()
        let sut = RemoteFeedLoader()
    
        XCTAssertNil(client.requestedURL)
        
    }
}
