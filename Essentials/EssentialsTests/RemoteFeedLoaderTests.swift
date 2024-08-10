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



class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
    
        XCTAssertNil(client.requestedURL)
        
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT( url: URL(string: "https://a-given-url")!)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // Mark: -Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client =  HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HttpClientSpy: HttpClient {
        var requestedURL: URL?
        
        func get(requestedURL: URL) {
            self.requestedURL = requestedURL
        }
    }
}
