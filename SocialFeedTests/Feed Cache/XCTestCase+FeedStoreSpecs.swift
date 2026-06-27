//
//  XCTestCase+FeedStoreSpecs.swift
//  SocialFeedTests
//
//  Created by CN23 on 27/06/26.
//

import XCTest
import SocialFeed

extension FeedStoreSpecs where Self: XCTestCase {
  
  @discardableResult
   func deleteCache(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
    let exp = expectation(description: "wait for deletion completion")
    var receivedError: Error?
    sut.deleteCachedFeed { deletionError in
      receivedError = deletionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return receivedError
  }
  
  @discardableResult
   func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
    let exp = expectation(description: "wait for insertion completion")
    var receivedError: Error?
    sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
      receivedError = insertionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return receivedError
  }
  
   func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
   func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "wait for completion")
    
    sut.retrieve { receivedResult in
      switch (expectedResult, receivedResult) {
      case (.empty, .empty),
        (.failure, .failure):
        break
      case let (.found(expectedFeed, expectedTimestamp),
                .found(receivedFeed, receivedTimestamp)):
        XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
        XCTAssertEqual(expectedTimestamp, receivedTimestamp, file: file, line: line)
      default:
        XCTFail("Expected to retrieve \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
}
