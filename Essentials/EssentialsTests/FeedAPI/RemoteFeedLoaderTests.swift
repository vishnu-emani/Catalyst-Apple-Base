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
        
        sut.load { _ in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url")!
        let (sut, client) = makeSUT( url: URL(string: "https://a-given-url")!)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let(sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPREsponse() {
        let(sut, client) = makeSUT()
        
        let samples = [199, 300, 400, 403, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                
                let json = makeItemsJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPREsponseWithInvalidJSon() {
        let(sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let invalidJSon = Data(bytes: "invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSon)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPREsponseWithEmptyJSONList() {
        let(sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJson = makeItemsJson([])
            client.complete(withStatusCode: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJSonItems() {
        let(sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(),
                             imageURL: URL(string: "https://a-url.com")!)
        
        let item2 = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://another-url.com")!)
        
        let items = [item1.model, item2.model]
        expect(sut, toCompleteWithResult: .success(items)) {
            let json = makeItemsJson([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        }
    }
    
    func test_load_doesNotDeliverResultsAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://a-url")!
        let client =  HttpClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load{capturedResults.append($0)}
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // Mark: -Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url")!) -> (sut: RemoteFeedLoader, client: HttpClientSpy) {
        let client =  HttpClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackMemeoryLeaks(sut)
        trackMemeoryLeaks(client)
        return (sut, client)
    }
    
    private func trackMemeoryLeaks(_ instance: AnyObject, file: StaticString = #filePath,
                                   line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should be deallocated. Potential memory leak", file: file, line: line)
        }
    }
    
    private func makeItem(id: UUID,
                          description: String? = nil,
                          location: String? = nil,
                          imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(id: id,
                            description: description,
                            location: location,
                            imageURL: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return(item, json)
    }
    
    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let itemsJSon = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSon)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult
                        expectedResults: RemoteFeedLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.load{ receivedResults in
            switch(receivedResults, expectedResults) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedItems), .failure(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResults) got \(receivedResults) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private class HttpClientSpy: HttpClient {
        
        private var messages = [(url: URL, completion: (HttpClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            messages.map{ $0.url }
        }
        
        func get(requestedURL: URL, completion: @escaping (HttpClientResult) -> Void) {
            messages.append((requestedURL,completion))
        }
        
        func complete(with error:  Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode: Int, data: Data, at index: Int = 0) {
            
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: withStatusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success(data, response))
            
        }
    }
}
