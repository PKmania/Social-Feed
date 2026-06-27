//
//  Created by CN23 on 26/06/26.
//

import XCTest
import SocialFeed


class CodableFeedStoreTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    setupEmptyStoreState()
  }
  
  override func tearDown() {
    super.tearDown()
    undoStoreSideEffets()
  }
  
  
  func test_retrieve_deliverEmptyOnEmptyCache() {
    let sut = makeSUT()
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    expect(sut, toRetrieveTwice: .empty)
  }
  
  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_deliversFailureOnRetrievalError() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "Invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
    expect(sut, toRetrieve: .failure(anyNSError()))
  }
  
  func test_retrieve_hasNoSideEffectsOnFailure() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "Invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
    
    expect(sut, toRetrieveTwice: .failure(anyNSError()))
  }
  
  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()
    let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
    XCTAssertNil(firstInsertionError, "Expected to inserted cache successfully.")
    
    let latestFeed = uniqueImageFeed().local
    let latestTimeStamp = Date()
    
    let LatestInsertionError = insert((latestFeed, latestTimeStamp), to: sut)
    XCTAssertNil(LatestInsertionError, "Expected to override cache successfully.")
    
    expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimeStamp))
  }
  
  func test_insert_deliversErrorOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")
    let sut = makeSUT(storeURL: invalidStoreURL)
    let feed = uniqueImageFeed().local
    let timeStamp = Date()
    
    let insertionError = insert((feed, timeStamp), to: sut)
    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error.")
    
  }
  // MARK: Delete Cache
  
  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    let deletionError = deleteCache(from: sut)
    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_emptiesPreviouslyInsertedCache() {
    let sut = makeSUT()
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_deliversErrorOnDeletionError() {
    let noDeletePersmissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePersmissionURL)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNotNil(deletionError, "Expected cache delete to fail")

  }
  // MARK: Helpers
  
  private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  @discardableResult
  private func deleteCache(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
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
  private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
    let exp = expectation(description: "wait for insertion completion")
    var receivedError: Error?
    sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
      receivedError = insertionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return receivedError
  }
  
  private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
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
  
  private func setupEmptyStoreState() {
    deleteStoreArtifacts()
  }
  
  private func undoStoreSideEffets() {
    deleteStoreArtifacts()
  }
  
  private func deleteStoreArtifacts() {
    try? FileManager.default.removeItem(at: testSpecificStoreURL())
  }
  
  private func testSpecificStoreURL() -> URL {
    cachesDirectory().appendingPathComponent("\(type(of: self)).store")
  }
  
  private func cachesDirectory() -> URL {
      return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
