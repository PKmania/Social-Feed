//
//  Created by CN23 on 26/06/26.
//

import XCTest
import SocialFeed
class CodableFeedStore {
  
  private struct Cache: Codable {
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var localFeed: [LocalFeedImage] {
      return feed.map { $0.local }
    }
  }
  
  private struct CodableFeedImage: Codable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL
    
    init(_ image: LocalFeedImage) {
      id = image.id
      description = image.description
      location = image.location
      url = image.url
    }
    
    var local: LocalFeedImage {
      return LocalFeedImage(id: id, description: description, location: location, url: url)
    }
  }
  private let storeURL: URL
  init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }
    
    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let encoded = try! encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
    try! encoded.write(to: storeURL)
    completion(nil)
  }

}

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
    let exp = expectation(description: "wait for completion")
    sut.retrieve { firstResult in
      sut.retrieve { secondResult in
        switch (firstResult, secondResult) {
        case (.empty, .empty):
          break
        default:
          XCTFail("Expected retreiving twice from empty cache to deliver same empty cache result, got \(firstResult) and \(secondResult) instead")
        }
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    let exp = expectation(description: "wait for completion")
    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected to inserted feed successully.")
        exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    let exp = expectation(description: "wait for completion")
    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected to inserted feed successully.")
      sut.retrieve { firstResult in
        sut.retrieve { secondResult in
          switch (firstResult, secondResult) {
          case let (.found(feed: firstFeed, timestamp: firstTimestamp),
                    .found(feed: secondFeed, timestamp: secondTimestamp)):
            XCTAssertEqual(feed, firstFeed)
            XCTAssertEqual(timestamp, firstTimestamp)
            
            XCTAssertEqual(feed, secondFeed)
            XCTAssertEqual(timestamp, secondTimestamp)
          default:
            XCTFail("Expected retrieving twice from non empty cache to deliver same found result with \(feed) and timestamp \(timestamp), got \(firstResult) and \(secondResult) instead.")
          }
          exp.fulfill()
        }
      }
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  // MARK: Helpers
  
  private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
    let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
    trackMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "wait for completion")

    sut.retrieve { receivedResult in
      switch (expectedResult, receivedResult) {
      case (.empty, .empty):
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
    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
  }
}
