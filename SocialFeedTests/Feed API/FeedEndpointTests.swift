//
//  Created by CN23 on 30/09/26.
//

import Foundation
import XCTest
import SocialFeed

class FeedEndpointTests: XCTestCase {
  
  func test_feed_endpointURL() {
    let baseURL = URL(string: "http://base-url.com")!
    
    let received = FeedEndpoint.get.url(baseURL: baseURL)
    let expected = URL(string: "http://base-url.com/v1/feed")!
    
    XCTAssertEqual(received, expected)
  }
  
}
