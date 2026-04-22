//
//  Created by CN23 on 22/04/26.
//

import Foundation
import XCTest
import SocialFeed

class FeedStore {
  var deleteCachedFeedCallCount = 0
}

class LocalFeedLoader {
  init(store: FeedStore) {
    
  }
}

class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCacheUponCreation() {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    
    XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
  }
}
