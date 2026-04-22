//
//  Created by CN23 on 22/04/26.
//

import Foundation
import XCTest
import SocialFeed

class FeedStore {
  var deleteCachedFeedCallCount = 0
  func deleteCachedFeed() {
    deleteCachedFeedCallCount += 1
  }
}

class LocalFeedLoader {
  let store: FeedStore
  init(store: FeedStore) {
    self.store = store
  }
  
  func save(_ items: [FeedItem]) {
    store.deleteCachedFeed()
  }
}

class CacheFeedUseCaseTests: XCTestCase {
  
  func test_init_doesNotDeleteCacheUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
  }
  
  func test_save_requestsCacheDeletion() {
    let (sut, store) = makeSUT()
    let items = [uniqueItems(), uniqueItems()]
    
    sut.save(items)
    XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
  }
  
  //MARK: helpers
  
  private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    return (sut, store)
  }
  
  private func uniqueItems() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
}
