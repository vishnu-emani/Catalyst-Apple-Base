//
//  URLSessionHttpCLientTests.swift
//  EssentialsTests
//
//  Created by Vishnu on 26/08/24.
//

import XCTest
import Essentials

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping(HttpClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error =  error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHttpClientTests: XCTestCase {
    
    func test_getFromURL_resumeDataTaskWithURL() {
    
        let url = URL(string: "http://any-url.com")!
        let session  = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url) { _ in  }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        
        let url = URL(string: "http://any-url.com")!
        let session  = URLSessionSpy()
        let error = NSError(domain: "any erroe", code: 1)
        
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        
        let expectations = expectation(description: "wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("expected failure with \(error) got \(result) failure instead")
            }
            
            expectations.fulfill()
        }
        
        wait(for: [expectations], timeout: 1.0)
    }
    
    //MARK: Helpers
    private class URLSessionSpy: URLSession {
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for given \(url)")
            }
            
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}





/// Note we should not subclass of any object if you don't own it. for example URLSession, URLSessionDataTask
