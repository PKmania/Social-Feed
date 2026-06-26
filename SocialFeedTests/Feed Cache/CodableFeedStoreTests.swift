//
//  Created by CN23 on 26/06/26.
//

import XCTest
import SocialFeed
class CodableFeedStore {
  
  private struct Cache: Codable {
    let feed: [LocalFeedImage]
    let timestamp: Date
  }
  private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
  
  func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      return completion(.empty)
    }
    
    let decoder = JSONDecoder()
    let cache = try! decoder.decode(Cache.self, from: data)
    completion(.found(feed: cache.feed, timestamp: cache.timestamp))
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let encoded = try! encoder.encode(Cache(feed: feed, timestamp: timestamp))
    try! encoded.write(to: storeURL)
    completion(nil)
  }

}

class CodableFeedStoreTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    removeArtifactsFromDirectory()
  }
  override func tearDown() {
    super.tearDown()
    removeArtifactsFromDirectory()
  }
  func removeArtifactsFromDirectory() {
     let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    try? FileManager.default.removeItem(at: storeURL)
  }
  
  func test_retrieve_deliverEmptyOnEmptyCache() {
    let sut = CodableFeedStore()
    let exp = expectation(description: "wait for completion")
    sut.retrieve { result in
      switch result {
      case .empty:
        break
      default:
        XCTFail("Expected empty result, got \(result) instead")
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    let sut = CodableFeedStore()
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
    let sut = CodableFeedStore()
    let feed = uniqueImageFeed().local
    let timestamp = Date()
    
    let exp = expectation(description: "wait for completion")
    sut.insert(feed, timestamp: timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected to inserted feed successully.")
      sut.retrieve { receivedResult in
        switch (receivedResult) {
        case let .found(receivedFeed, receivedTimestamp):
          XCTAssertEqual(feed, receivedFeed)
          XCTAssertEqual(timestamp, receivedTimestamp)
        default:
          XCTFail("Expected found result with \(feed) and timestamp \(timestamp), got \(receivedResult) instead.")
        }
        exp.fulfill()
      }
    }
    wait(for: [exp], timeout: 1.0)
  }
}
