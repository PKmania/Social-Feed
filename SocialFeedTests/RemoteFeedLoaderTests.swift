//
//  Created by CN23 on 17/04/26.
//

import Foundation
import XCTest
//xcodebuild test -project SocialFeed.xcodeproj -scheme "CI_macos"

class RemoteFeedLoader {
  
}

class HTTPClient {
  var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    let client = HTTPClient()
    _ = RemoteFeedLoader()

    XCTAssertNil(client.requestedURL)
  }
}
