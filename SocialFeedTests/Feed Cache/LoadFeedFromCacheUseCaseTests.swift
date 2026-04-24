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
    
    sut.load {_ in }
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_failsOnRetivalError() {
    let (sut, store) = makeSUT()
    let retrivalError = anyNSError()
    
    expect(sut, toCompleteWith: .failure(retrivalError)) {
      store.completeRetrival(with: retrivalError)
    }
  }
  
  func test_load_deliversNoImagesOnEmptyCache() {
    let (sut, store) = makeSUT()
    expect(sut, toCompleteWith: .success([])) {
      store.completeRetrivalWithEmptyCache()
    }

  }
  
  func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
    
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    expect(sut, toCompleteWith: .success(feed.model)) {
      store.completeRetrival(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
    }
  }
  
  func test_load_deliversNoImagesOnSevenDaysOldCache() {
    
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let exactSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    expect(sut, toCompleteWith: .success([])) {
      store.completeRetrival(with: feed.local, timestamp: exactSevenDaysOldTimestamp)
    }
  }
  
  func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
    
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    
    expect(sut, toCompleteWith: .success([])) {
      store.completeRetrival(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
    }
  }
  
  func test_load_deletesCacheOnRetrivalError() {
    let (sut, store) = makeSUT()
    sut.load {_ in }
    store.completeRetrival(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_load_doesNotdeletesCacheOnEmptyCache() {
    let (sut, store) = makeSUT()
    sut.load {_ in }
    store.completeRetrivalWithEmptyCache()
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_doesNotdeletesCacheOnLessThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.load { _ in }
    store.completeRetrival(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_doesNotdeletesCacheOnSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let exactSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.load { _ in }
    store.completeRetrival(with: feed.local, timestamp: exactSevenDaysOldTimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_load_doesNotdeletesCacheOnMoreThanSevenDaysOldCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(days: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.load { _ in }
    store.completeRetrival(with: feed.local, timestamp: moreThanSevenDaysOldTimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_load_doesNotDeliverResultAfterSUThasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    var receivedResult = [LocalFeedLoader.LoadFeed]()
    sut?.load { result in
      receivedResult.append(result)
    }
    sut = nil
    store.completeRetrivalWithEmptyCache()
    XCTAssertTrue(receivedResult.isEmpty)
  }
  
  //MARK: helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackMemoryLeaks(store, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }

  
  private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadFeed, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "wait for completion")

    sut.load { receivedResult in
    switch (receivedResult, expectedResult) {
    case let (.success(receivedImages), .success(expectedImages)):
      XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
    case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
      XCTAssertEqual(receivedError, expectedError, file: file, line: line)
    default:
      XCTFail("Expected result: \(expectedResult), got result instead:\(receivedResult)")
      }
      exp.fulfill()
    }
    
    action()
    
    wait(for: [exp], timeout: 1.0)
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
