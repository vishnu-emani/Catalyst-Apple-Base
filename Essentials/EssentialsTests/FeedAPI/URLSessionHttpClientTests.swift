//
//  URLSessionHttpCLientTests.swift
//  EssentialsTests
//
//  Created by Vishnu on 26/08/24.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHttpClientTests: XCTestCase {
    
    func test_getFromURL_createDataTaskWithURL() {
    
        let url = URL(string: "http://any-url.com")!
        let session  = URLSessionSpy()
        
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    //MARK: Helpers
    private class URLSessionSpy: URLSession {
        var receivedURLs = [URL]()
        
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            var receivedURLS = [URL]()
            
            receivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}
}





/// Note we should not subclass of any object if you don't own it. for example URLSession, URLSessionDataTask
