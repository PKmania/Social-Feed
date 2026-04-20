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
    session.dataTask(with: url) { _, _, _ in }
  }
}
class URLURLSessionHTTPClientTests: XCTestCase {
  
  func test_getFromURL_createsDataTaskWithURL() {
    let url = URL(string: "https://any-url.com/posts")!
    let session = URLSessionSpy()
    let sut = URLURLSessionHTTPClient(session: session)
    
    sut.get(from: url)
    
    XCTAssertEqual(session.receivedURLs, [url])
    }
  
  private class URLSessionSpy: URLSession {
    var receivedURLs = [URL]()
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
      receivedURLs.append(url)
      return FakeURLSessionDataTask()
    }
    
  }
  
  private class FakeURLSessionDataTask: URLSessionDataTask {}
}


