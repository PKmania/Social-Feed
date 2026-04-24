//
//  Created by CN23 on 22/04/26.
//

import Foundation
import XCTest
import SocialFeed


class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()
    
    sut.save(uniqueItems().model) {_ in }
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let error = anyNSError()
    
    sut.save(uniqueItems().model) {_ in }
    store.completeDeletion(with: error)
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let (model, localItem) = uniqueItems()
    sut.save(model) {_ in }
    store.completeDeletionSuccessfully()
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(localItem, timestamp)])

  }
  
  func test_save_failsOnDeletionError() {
    let (sut, store) = makeSUT()
    let error = anyNSError()
    
    expect(sut, toCompleteWirhError: error) {
      store.completeDeletion(with: error)
    }
  }

  func test_save_failsOnInsertionError() {
    let (sut, store) = makeSUT()
    let error = anyNSError()
    
    expect(sut, toCompleteWirhError: error) {
      store.completeDeletionSuccessfully()
      store.completeInsertion(with: error)
    }
  }
  
  func test_save_sucessOnSuccessfulInsertion() {
    let (sut, store) = makeSUT()
    
    expect(sut, toCompleteWirhError: nil) {
      store.completeDeletionSuccessfully()
      store.completeInsertionSuccessfully()
    }

  }
  func test_save_doesNotDeliverDeletionErrorAfterSUTHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    
    var receivedResult = [LocalFeedLoader.SaveResult]()
    sut?.save(uniqueItems().model) { error in
      receivedResult.append(error)
    }
    sut = nil
    store.completeDeletion(with: anyNSError())
    XCTAssertTrue(receivedResult.isEmpty)
  }
  
  func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
    let store = FeedStoreSpy()
    var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
    
    var receivedResult = [LocalFeedLoader.SaveResult]()
    sut?.save(uniqueItems().model) { error in
      receivedResult.append(error)
    }
    store.completeDeletionSuccessfully()
    sut = nil
    store.completeInsertion(with: anyNSError())
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
  
  private class FeedStoreSpy: FeedStore {
    
    enum ReceivedMessage : Equatable {
      case  deleteCachedFeed
      case insert([LocalFeedItem], Date)
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
    
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
      insertionCompletions.append(completion)
      receivedMessages.append(.insert(items, timestamp))
    }
  }
  
  private func expect(_ sut: LocalFeedLoader, toCompleteWirhError error: NSError?, when action: () -> Void) {
    let exp = expectation(description: "eait for completeion")
    
    var receivedError: Error?
    sut.save(uniqueItems().model) { error in
      receivedError = error
      exp.fulfill()
    }
    
    action()
    
    wait(for: [exp], timeout:  1.0)
    XCTAssertEqual(receivedError as? NSError, error)
  }
  
  private func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func uniqueItems() -> (model: [FeedItem], local: [LocalFeedItem]) {
    let items = [uniqueItem(), uniqueItem()]
    let localItems = items.map { LocalFeedItem(id: $0.id,
                                               description: $0.description,
                                               location: $0.location,
                                               imageURL: $0.imageURL)}
    return (items, localItems)
  }
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
}
