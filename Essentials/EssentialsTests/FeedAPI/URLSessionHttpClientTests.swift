//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import Essentials

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(requestedURL: anyURL()) {_ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        let receivedError = receivedErrorFor(data: nil, response: nil, error: requestError) as NSError?
    
        
        XCTAssertEqual(receivedError?.domain , requestError.domain)
        XCTAssertEqual(receivedError?.code , requestError.code)
    }
    
    func test_getFromURL_failsOnNilValues() {
    
        XCTAssertNotNil(receivedErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(receivedErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(receivedErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(receivedErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(receivedErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(receivedErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(receivedErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(receivedErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(receivedErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_SuceedsOnURLHTTPResponseWithData()  {
        let data = anyData()
        let response = anyHTTPURLResponse()
        let receivedValues = receivedValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        XCTAssertEqual(receivedValues?.response.url, response.url)
    }
    
    
    func test_getFromURL_SuceedsWithEmptyDataONHTTPURLResponseWithNilData()  {
        let response = anyHTTPURLResponse()
        let receivedValues = receivedValuesFor(data: nil, response: response, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        XCTAssertEqual(receivedValues?.response.url, response.url)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath,
                         line: UInt = #line) -> HttpClient {
       let sut = URLSessionHTTPClient()
        trackMemeoryLeaks(sut, file: file, line: line)
         return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("Any Data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func receivedValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath,
                                   line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = receivedResult(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .success(data, response):
            return  (data, response)
        default:
            XCTFail("Expected success got \(result) instead", file: file, line: line)
            return nil
        }
        
    }
    
    private func receivedErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath,
                                  line: UInt = #line) -> Error? {
        
        let result = receivedResult(data: data, response: response, error: error, file: file, line: line)
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func receivedResult(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath,
                                line: UInt = #line) -> HttpClientResult {
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HttpClientResult!
        sut.get(requestedURL: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObservers: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping(URLRequest) -> Void) {
            requestObservers = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObservers = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
           return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObservers?(request)
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stub else { return }
            
            if let requestObsever = URLProtocolStub.requestObservers {
                client?.urlProtocolDidFinishLoading(self)
                return requestObsever(request)
            }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
}
