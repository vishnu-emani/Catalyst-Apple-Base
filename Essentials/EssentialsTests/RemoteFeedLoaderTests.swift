//
//  RemoteFeedLoaderTests.swift
//  EssentialsTests
//
//  Created by Vishnu on 10/08/24.
//

import Foundation

import XCTest
import Essentials

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let (_, client) = makeSUT()
    
        XCTAssertTrue(client.requestedURLs.isEmpty)
        
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT( url: URL(string: "https://a-given-url")!)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT( url: URL(string: "https://a-given-url")!)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let(sut, client) = makeSUT()
        client.error = NSError(domain: "Test", code: 0)
        
        var capturedError: RemoteFeedLoader.Error?
        sut.load{ error in capturedError = error}
        
        XCTAssertEqual(capturedError, .connectivity)
    }
    
    // Mark: -Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client =  HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HttpClientSpy: HttpClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(requestedURL: URL, completion: @escaping(Error) -> Void) {
            
            if let error = error {
                completion(error)
            } else {
                self.requestedURLs.append(requestedURL)
            }
        }
    }
}
