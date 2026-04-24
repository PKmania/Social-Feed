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
    let retrivalError = anyNSError()
    
    expect(sut, toCompleteWith: .failure(retrivalError)) {
      store.completeRetrival(with: retrivalError)
    }
  }
  
  func test_load_deliversNoImagesOnEmptyCache() {
    let (sut, store) = makeSUT()
    expect(sut, toCompleteWith: .success([])) {
      store.completeRetrivalWithEmptyCache()
    }

  }
  
  
  //MARK: helpers
  
  private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackMemoryLeaks(store, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }

  
  private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadFeed, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "wait for completion")

    sut.load { receivedResult in
    switch (receivedResult, expectedResult) {
    case let (.success(receivedImages), .success(expectedImages)):
      XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
    case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
      XCTAssertEqual(receivedError, expectedError, file: file, line: line)
    default:
      XCTFail("Expected result: \(expectedResult), got result instead:\(receivedResult)")
      }
      exp.fulfill()
    }
    
    action()
    
    wait(for: [exp], timeout: 1.0)
  }
  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
  
  private func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
  }
  
}


