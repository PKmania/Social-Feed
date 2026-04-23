//
//  Created by CN23 on 22/04/26.
//

import Foundation
import XCTest
import SocialFeed

class FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void

  enum ReceivedMessage : Equatable {
    case  deleteCachedFeed
    case insert([FeedItem], Date)
  }
  var receivedMessages : [ReceivedMessage] = []
  private var deletionCompletions = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()

  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedFeed)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }
  
  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }
  
  func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(items, timestamp))
  }
  
  
}

class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
  init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void ) {
    store.deleteCachedFeed { [ unowned self] (error) in
      
      if error == nil {
        store.insert(items, timestamp: self.currentDate(), completion: completion)
      }else {
        completion(error)
      }
    }
  }
}

class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItems(), uniqueItems()]
    
    sut.save(items) {_ in }
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItems(), uniqueItems()]
    let error = anyNSError()
    
    sut.save(items) {_ in }
    store.completeDeletion(with: error)
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let items = [uniqueItems(), uniqueItems()]
    
    sut.save(items) {_ in }
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])

  }
  
  func test_save_failsOnDeletionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItems(), uniqueItems()]
    let error = anyNSError()
    
    let exp = expectation(description: "eait for completeion")
    
    var receivedError: Error?
    sut.save(items) { error in
      receivedError = error
      exp.fulfill()
    }
    store.completeDeletion(with: error)
    
    wait(for: [exp], timeout:  1.0)
    XCTAssertEqual(receivedError as? NSError, error)
  }

  func test_save_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    let items = [uniqueItems(), uniqueItems()]
    let error = anyNSError()
    
    let exp = expectation(description: "eait for completeion")
    
    var receivedError: Error?
    sut.save(items) { error in
      receivedError = error
      exp.fulfill()
    }
    store.completeDeletionSuccessfully()
    store.completeInsertion(with: error)
    
    wait(for: [exp], timeout:  1.0)
    XCTAssertEqual(receivedError as? NSError, error)
  }
  
  func test_save_sucessOnSuccessfulInsertion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItems(), uniqueItems()]
    
    let exp = expectation(description: "eait for completeion")
    
    var receivedError: Error?
    sut.save(items) { error in
      receivedError = error
      exp.fulfill()
    }
    store.completeDeletionSuccessfully()
    store.completeInsertionSuccessfully()
    
    wait(for: [exp], timeout:  1.0)
    XCTAssertNil(receivedError)
  }
  
  //MARK: helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackMemoryLeaks(store, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
  
  private func uniqueItems() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
}
