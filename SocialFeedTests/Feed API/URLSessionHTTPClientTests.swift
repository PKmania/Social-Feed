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
  func get(from url: URL) {
    session.dataTask(with: url) { _, _, _ in }.resume()
  }
}
class URLURLSessionHTTPClientTests: XCTestCase {
  
  func test_getFromURL_resumeDataTaskWithURL() {
    let url = URL(string: "https://any-url.com/posts")!
    let session = URLSessionSpy()
    let sut = URLURLSessionHTTPClient(session: session)
    let task = URLSessionDataTaskSpy()
    session.stub(url, with: task)
    sut.get(from: url)
    
    XCTAssertEqual(task.resumeCallCount, 1)
    }
  
  private class URLSessionSpy: URLSession {
    var stubs: [URL: URLSessionDataTask] = [:]
    
    func stub(_ url: URL, with task: URLSessionDataTask) {
      stubs[url] = task
    }
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
      return stubs[url] ?? FakeURLSessionDataTask()
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


