//
//  Created by CN23 on 20/04/26.
//

import Foundation
import XCTest
import SocialFeed

class URLURLSessionHTTPClient {
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
class URLURLSessionHTTPClientTests: XCTestCase {
  
  func test_getFromURL_resumeDataTaskWithURL() {
    let url = URL(string: "https://any-url.com/posts")!
    let session = URLSessionSpy()
    let sut = URLURLSessionHTTPClient(session: session)
    let task = URLSessionDataTaskSpy()
    session.stub(url, with: task)
    sut.get(from: url) { _ in }
    
    XCTAssertEqual(task.resumeCallCount, 1)
    }
  
  func test_getFromURL_failsOnRequestError() {
    let url = URL(string: "https://any-url.com/posts")!
    let session = URLSessionSpy()
    let sut = URLURLSessionHTTPClient(session: session)
    let task = URLSessionDataTaskSpy()
    let expectedError = NSError(domain: "any error", code: 0)
    session.stub(url, error: expectedError)
    
    let exp = expectation(description: "Completion handler should be called")
    sut.get(from: url) { (result) in
      switch result {
      case let .failure(receivedError as NSError):
        XCTAssertEqual(receivedError, expectedError)
      default:
        XCTFail("Expected failure with error \(expectedError), got \(result) instead")
      }
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  //MARK: Helpers
  private class URLSessionSpy: URLSession {
   private var stubs = [URL: Stub]()
    
    private struct Stub {
      let task: URLSessionDataTask
      let error: Error?
    }
    func stub(_ url: URL, with task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
      stubs[url] = Stub(task: task, error: error)
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
      guard let stub = stubs[url] else {
        fatalError("No stubbing defined for \(url)")
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


