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
  
  func test_validateCache_deleteCacheOnRetrivalError() {
    let (sut, store) = makeSUT()
    sut.validateCache()
    store.completeRetrival(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
    let (sut, store) = makeSUT()
    sut.validateCache()
    store.completeRetrivalWithEmptyCache()
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_doesNotDeleteNonExpiredCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.validateCache()
    store.completeRetrival(with: feed.local, timestamp: nonExpiredTimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_deleteCacheOnExpiration() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.validateCache()
    store.completeRetrival(with: feed.local, timestamp: expirationTimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_validateCache_deleteExpiredCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(days: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.validateCache()
    store.completeRetrival(with: feed.local, timestamp: expiredTimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_validateCache_doesNotDeleteInvalidCacheAfterSUThasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    sut?.validateCache()
    sut = nil
    store.completeRetrival(with: anyNSError())
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



