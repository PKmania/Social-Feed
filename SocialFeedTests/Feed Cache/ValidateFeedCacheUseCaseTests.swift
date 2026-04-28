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
  
  private func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
  }
  
  private func uniqueImageFeed() -> (model: [FeedImage], local: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let localItems = feed.map { LocalFeedImage(id: $0.id,
                                               description: $0.description,
                                               location: $0.location,
                                               url: $0.url)}
    return (feed, localItems)
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
}


private extension Date {
  func adding(days: Int) -> Date {
    Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}
