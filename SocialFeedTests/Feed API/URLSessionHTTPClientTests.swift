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
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
    session.dataTask(with: url) { (_, _, error) in
      if let error = error {
        completion(.failure(error))
      }
      
    }.resume()
  }
}
class URLSessionHTTPClientTests: XCTestCase {
  
  func test_getFromURL_failsOnRequestError() {
    let url = URL(string: "https://any-url.com/posts")!
    URLProtocol.registerClass(URLProtocolStub.self)
    let expectedError = NSError(domain: "any error", code: 0)
    URLProtocolStub.stub(url, error: expectedError)
    let sut = URLSessionHTTPClient()
    let exp = expectation(description: "Completion handler should be called")
    sut.get(from: url) { (result) in
      switch result {
      case let .failure(receivedError as NSError):
        XCTAssertEqual(receivedError.domain, expectedError.domain)
        XCTAssertEqual(receivedError.code, expectedError.code)
      default:
        XCTFail("Expected failure with error \(expectedError), got \(result) instead")
      }
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
    URLProtocol.unregisterClass(URLProtocolStub.self)
    
  }
  
  //MARK: Helpers
  private class URLProtocolStub: URLProtocol{
    private static var stubs = [URL: Stub]()
    
    private struct Stub {
      let data: Data?
      let response: HTTPURLResponse?
      let error: Error?
    }
    
    static func stub(_ url: URL,_ data: Data? = nil , _ response: HTTPURLResponse? = nil , error: Error? = nil) {
      stubs[url] = Stub(data: data, response: response, error: error)
    }
    override class func canInit(with request: URLRequest) -> Bool {
      guard let url = request.url else { return false }
      return stubs[url] != nil
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    override func startLoading() {
      guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {  return }
      
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


