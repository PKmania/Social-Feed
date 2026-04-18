//
//  Created by CN23 on 17/04/26.
//

import Foundation
import XCTest
//xcodebuild test -project SocialFeed.xcodeproj -scheme "CI_macos"

class RemoteFeedLoader {
  func load() {
    HTTPClient.shared.get(from: URL(string: "https://any-url.com/posts")!)
  }
}

class HTTPClient {
  static var shared = HTTPClient()

  func get(from url: URL) {}
}
class HTTPCLientSpy: HTTPClient {
  var requestedURL: URL?

  override func get(from url: URL) {
    requestedURL = url
  }
}

class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    let client = HTTPCLientSpy()
    HTTPClient.shared = client
    _ = RemoteFeedLoader()

    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    let client = HTTPCLientSpy()
    HTTPClient.shared = client
    let sut = RemoteFeedLoader()
    
    sut.load()
    
    XCTAssertNotNil(client.requestedURL)
  }
}
