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
    
    sut.save(uniqueImageFeed().model) {_ in }
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_doesNotRequestCacheInsertionOnDeletionError() {
    let (sut, store) = makeSUT()
    let error = anyNSError()
    
    sut.save(uniqueImageFeed().model) {_ in }
    store.completeDeletion(with: error)
    
    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }
  
  func test_save_requestNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
    let timestamp = Date()
    let (sut, store) = makeSUT(currentDate: { timestamp })
    let (model, localItem) = uniqueImageFeed()
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
    sut?.save(uniqueImageFeed().model) { error in
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
    sut?.save(uniqueImageFeed().model) { error in
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
  
  private func expect(_ sut: LocalFeedLoader, toCompleteWirhError error: NSError?, when action: () -> Void) {
    let exp = expectation(description: "eait for completeion")
    
    var receivedError: Error?
    sut.save(uniqueImageFeed().model) { error in
      receivedError = error
      exp.fulfill()
    }
    
    action()
    
    wait(for: [exp], timeout:  1.0)
    XCTAssertEqual(receivedError as? NSError, error)
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
