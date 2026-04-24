//
//  Created by CN23 on 24/04/26.
//

import Foundation
import XCTest
import SocialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_load_requestCacheRetrival() {
    let (sut, store) = makeSUT()
    
    sut.load()
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  //MARK: helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackMemoryLeaks(store, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }

}


