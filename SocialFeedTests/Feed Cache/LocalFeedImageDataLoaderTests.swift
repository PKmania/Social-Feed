//
//  Created by CN23 on 14/09/26.
//

import Foundation
import SocialFeed
import XCTest

final class LocalFeedImageDataLoader {
  init(store: Any) {
    
  }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertTrue(store.receivedMessages.isEmpty)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedImageDataLoader(store: store)
    trackMemoryLeaks(store, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
  
  private class FeedStoreSpy {
    let receivedMessages = [Any]()
  }
  
}
