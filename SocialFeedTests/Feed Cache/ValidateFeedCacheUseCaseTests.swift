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
    sut.validateCache { _ in }
    store.completeRetrival(with: anyNSError())
    
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
    let (sut, store) = makeSUT()
    sut.validateCache { _ in }
    store.completeRetrivalWithEmptyCache()
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_doesNotDeleteNonExpiredCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.validateCache { _ in }
    store.completeRetrival(with: feed.local, timestamp: nonExpiredTimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_deleteCacheOnExpiration() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.validateCache { _ in }
    store.completeRetrival(with: feed.local, timestamp: expirationTimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_validateCache_deleteExpiredCache() {
    let feed = uniqueImageFeed()
    let fixedCurrentDate = Date()
    let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
    let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
    sut.validateCache { _ in }
    store.completeRetrival(with: feed.local, timestamp: expiredTimestamp)
    XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
  }
  
  func test_validateCache_succeedsOnEmptyCache() {
      let (sut, store) = makeSUT()
      
      expect(sut, toCompleteWith: .success(()), when: {
        store.completeRetrivalWithEmptyCache()
      })
    }
  
  func test_validateCache_succeedsOnNonExpiredCache() {
      let feed = uniqueImageFeed()
      let fixedCurrentDate = Date()
      let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
      let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

      expect(sut, toCompleteWith: .success(()), when: {
        store.completeRetrival(with: feed.local, timestamp: nonExpiredTimestamp)
      })
    }
  
  func test_validateCache_doesNotDeleteInvalidCacheAfterSUThasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    sut?.validateCache { _ in }
    sut = nil
    store.completeRetrival(with: anyNSError())
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
      let (sut, store) = makeSUT()
      let deletionError = anyNSError()
      
      expect(sut, toCompleteWith: .failure(deletionError), when: {
        store.completeRetrival(with: anyNSError())
        store.completeDeletion(with: deletionError)
      })
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
      let (sut, store) = makeSUT()
      
      expect(sut, toCompleteWith: .success(()), when: {
        store.completeRetrival(with: anyNSError())
        store.completeDeletionSuccessfully()
      })
    }
  
  //MARK: helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackMemoryLeaks(store, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
  
  private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    
    sut.validateCache { receivedResult in
      switch (receivedResult, expectedResult) {
      case (.success, .success):
        break
        
      case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        
      default:
        XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
      }
      
      exp.fulfill()
    }
    
    action()
    wait(for: [exp], timeout: 1.0)
  }
  
}



