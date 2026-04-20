//
//  Created by CN23 on 20/04/26.
//

import Foundation
import XCTest
import SocialFeed

class URLSessionHTTPClient {
  private let session: URLSession
  init (session: URLSession = .shared) {
    self.session = session
  }
  private struct UnexpectedError: Error {}
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { (_, _, error) in
      if let error = error {
        completion(.failure(error))
      }else {
        completion(.failure(UnexpectedError()))
      }
    }.resume()
  }
}
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
    let exp = expectation(description: "Completion handler should be called")
    
    URLProtocolStub.observeRequests { request in
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")
      exp.fulfill()
    }
    makeSUT().get(from: url) { _ in }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURL_failsOnRequestError() {
    let requestError = NSError(domain: "any error", code: 0)
    let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
    XCTAssertNotNil(receivedError)
    XCTAssertEqual(receivedError?.domain, requestError.domain)
    XCTAssertEqual(receivedError?.code, requestError.code)
  }
  
  func test_getFromURL_failsOnAllInvalidRepresentationCases() {
    let anyData = Data("any data".utf8)
    let anyError = NSError(domain: "any error", code: 0)
    let nonHTTPURLResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    let anyHTTPURLResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
    
    XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyError))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
  }
  
  
  //MARK: Helpers
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
    let sut = URLSessionHTTPClient()
    trackMemoryLeaks(sut)
    return URLSessionHTTPClient()
  }
  
  private func anyURL() -> URL {
    URL(string: "https://any-url.com")!
  }
  
  private func resultErrorFor(data: Data? , response: URLResponse? , error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
    URLProtocolStub.stub(data: data, response: response, error: error)
    let sut = makeSUT(file: file, line: line)
    let exp = expectation(description: "Completion handler should be called")
    var receivedError: Error?
    sut.get(from: anyURL()) { (result) in
      switch result {
      case let .failure(error):
        receivedError = error
      default:
        XCTFail("Expected failure, got \(result) instead")
      }
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
    return receivedError
  }
  private class URLProtocolStub: URLProtocol{
    private static var stub: Stub?
    private static var requestObserver : ((URLRequest) -> Void)?
    
    private struct Stub {
      let data: Data?
      let response: URLResponse?
      let error: Error?
    }
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
      requestObserver = nil
    }
    
    static func stub(data: Data? = nil , response: URLResponse? = nil , error: Error? = nil) {
      stub = Stub(data: data, response: response, error: error)
    }
    static func observeRequests(_ observer: @escaping (URLRequest) -> Void) {
      requestObserver = observer
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      requestObserver?(request)
      return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    
    override func startLoading() {
      if let data = URLProtocolStub.stub?.data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      if let response = URLProtocolStub.stub?.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      
      if let error = URLProtocolStub.stub?.error {
        client?.urlProtocol(self, didFailWithError: error)
      }
      
      client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
  }
}


