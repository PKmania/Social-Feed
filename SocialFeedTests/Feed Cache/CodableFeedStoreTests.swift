//
//  Created by CN23 on 26/06/26.
//

import XCTest
import SocialFeed


class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
  
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
  
  func test_insert_deliverNoErrorOnEmptyCache() {
    let sut = makeSUT()
    let firstInsertionError = insert((uniqueImageFeed().local, Date()), to: sut)
    
    XCTAssertNil(firstInsertionError, "Expected to inserted cache successfully.")
  }
  
  func test_insert_deliverNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

    XCTAssertNil(insertionError, "Expected to override cache successfully.")
  }
  
  func test_insert_overridesPreviouslyInsertedCacheValues() {
    let sut = makeSUT()
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let latestFeed = uniqueImageFeed().local
    let latestTimeStamp = Date()
    
    insert((latestFeed, latestTimeStamp), to: sut)
    
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
  
  func test_insert_hasNoSideEffectsOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")
    let sut = makeSUT(storeURL: invalidStoreURL)
    let feed = uniqueImageFeed().local
    let timeStamp = Date()
    
    insert((feed, timeStamp), to: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  // MARK: Delete Cache
  
  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
   deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_emptiesPreviouslyInsertedCache() {
    let sut = makeSUT()
    insert((uniqueImageFeed().local, Date()), to: sut)
    
   deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_deliversErrorOnDeletionError() {
    let noDeletePersmissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePersmissionURL)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNotNil(deletionError, "Expected cache delete to fail")
  }
  
  func test_delete_hasNoSideEffectsOnDeletionError() {
    let noDeletePersmissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePersmissionURL)
    
    deleteCache(from: sut)
    
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_deliverNoErrorOnEmptyCache() {
    let sut = makeSUT()
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
  }
  
  func test_delete_deliverNoErrorOnNonEmptyCache() {
    let sut = makeSUT()
    insert((uniqueImageFeed().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
  }
  

  func test_storeSideEffects_runSerially() {
    let sut = makeSUT()
    var completedOperationInOrder = [XCTestExpectation]()
    let op1 = expectation(description: "Operation 1")
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      completedOperationInOrder.append(op1)
      op1.fulfill()
    }
    let op2 = expectation(description: "Operation 2")

    sut.deleteCachedFeed { _ in
      completedOperationInOrder.append(op2)
      op2.fulfill()
    }
    
    let op3 = expectation(description: "Operation 3")
    
    sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
      completedOperationInOrder.append(op3)
      op3.fulfill()
    }
    
    waitForExpectations(timeout: 5.0)
    
    XCTAssertEqual(completedOperationInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order.")
  }
  
  // MARK: Helpers
  
  private func makeSUT(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackMemoryLeaks(sut, file: file, line: line)
    return sut
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
