//
//  Created by CN23 on 24/04/26.
//

import Foundation
import XCTest
import SocialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_validateCache_deletesCacheOnRetrivalError() {
    let (sut, store) = makeSUT()
    sut.validateCache()
    store.completeRetrival(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_validateCache_doesNotdeletesCacheOnEmptyCache() {
    let (sut, store) = makeSUT()
    sut.validateCache()
    store.completeRetrivalWithEmptyCache()
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_doesNotdeletesCacOnLessThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.validateCache()
    store.completeRetrival(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
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



