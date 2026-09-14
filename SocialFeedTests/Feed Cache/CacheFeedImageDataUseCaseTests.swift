//
//  Created by CN23 on 14/09/26.
//

import Foundation
import SocialFeed
import XCTest

class CacheFeedImageDataUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertTrue(store.receivedMessages.isEmpty)
  }
  
  func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
    let (sut, store) = makeSUT()
    let url = anyURL()
    let data = anyData()
    
    sut.save(data, for: url) { _ in }
    
    XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
    let store = FeedImageDataStoreSpy()
    let sut = LocalFeedImageDataLoader(store: store)
    trackMemoryLeaks(store, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
  
}
