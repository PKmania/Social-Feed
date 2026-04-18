//
//  Created by CN23 on 17/04/26.
//

import Foundation
import XCTest
//xcodebuild test -project SocialFeed.xcodeproj -scheme "CI_macos"

class RemoteFeedLoader {
  let client: HTTPClient
  let url: URL
  
  init(url: URL, client: HTTPClient) {
    self.url =  url
    self.client = client
  }
  func load() {
    client.get(from: url)
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
    let url = URL(string: "https://any-url.com/posts")!
    let client = HTTPCLientSpy()
    _ = RemoteFeedLoader(url: url, client: client)

    XCTAssertNil(client.requestedURL)
  }
  
  func test_load_requestDataFromURL() {
    let url = URL(string: "https://any-url.com/posts")!
    let client = HTTPCLientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    
    sut.load()
    
    XCTAssertEqual(client.requestedURL, url)
  }
}
