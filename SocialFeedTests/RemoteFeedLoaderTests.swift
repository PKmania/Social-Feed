//
//  Created by CN23 on 17/04/26.
//

import Foundation
import XCTest
//xcodebuild test -project SocialFeed.xcodeproj -scheme "CI_macos"

class RemoteFeedLoader {
  func load() {
    HTTPClient.shared.requestedURL = URL(string: "https://any-url.com/posts")!
  }
}

class HTTPClient {
  static let shared = HTTPClient()
  private init() {}
  var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    let client = HTTPClient.shared
    _ = RemoteFeedLoader()

    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    let client = HTTPClient.shared
    let sut = RemoteFeedLoader()
    
    sut.load()
    
    XCTAssertNotNil(client.requestedURL)
  }
}
