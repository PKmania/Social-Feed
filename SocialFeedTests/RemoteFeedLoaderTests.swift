//
//  Created by CN23 on 17/04/26.
//

import Foundation
import XCTest
//xcodebuild test -project SocialFeed.xcodeproj -scheme "CI_macos"

class RemoteFeedLoader {
  let client: HTTPClient
  init(client: HTTPClient) {
    self.client = client
  }
  func load() {
    client.get(from: URL(string: "https://any-url.com/posts")!)
  }
}

protocol HTTPClient {
  func get(from url: URL)
}
class HTTPCLientSpy: HTTPClient {
  var requestedURL: URL?

  func get(from url: URL) {
    requestedURL = url
  }
}

class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    let client = HTTPCLientSpy()
    _ = RemoteFeedLoader(client: client)

    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    let client = HTTPCLientSpy()
    let sut = RemoteFeedLoader(client: client)
    
    sut.load()
    
    XCTAssertNotNil(client.requestedURL)
  }
}
