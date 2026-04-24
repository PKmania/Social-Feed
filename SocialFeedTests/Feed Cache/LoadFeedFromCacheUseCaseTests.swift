//
//  Created by CN23 on 24/04/26.
//

import Foundation
import XCTest
import SocialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_load_requestCacheRetrival() {
    let (sut, store) = makeSUT()
    
    sut.load {_ in }
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  func test_load_failsOnRetivalError() {
    let (sut, store) = makeSUT()
    let exp = expectation(description: "wait for completion")
    let retrivalError = anyNSError()
    var receivedError: Error?
    sut.load { result in
      switch result {
      case let .failure(error):
        receivedError = error
      default:
        XCTFail("Expected failure, got success instead:\(result)")
      }
      exp.fulfill()
    }
    
    store.completeRetrival(with: retrivalError)
    
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertEqual(receivedError as? NSError, retrivalError)
  }
  
  func test_load_deliversNoImagesOnEmptyCache() {
    let (sut, store) = makeSUT()
    let exp = expectation(description: "wait for completion")
    var receivedImages: [FeedImage]?
    sut.load { result in
    switch result {
    case let .success(images):
      receivedImages = images
    default:
      XCTFail("Expected success, got failure instead:\(result)")
      }
      exp.fulfill()
    }
    store.completeRetrivalWithEmptyCache()
    
    wait(for: [exp], timeout: 1.0)
    
    XCTAssertEqual(receivedImages, [])
  }
  
  
  //MARK: helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackMemoryLeaks(store, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }

  
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
}


