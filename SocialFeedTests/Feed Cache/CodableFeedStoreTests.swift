//
//  Created by CN23 on 26/06/26.
//

import XCTest
import SocialFeed
class CodableFeedStore {
  func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
    completion(.empty)
  }
}

class CodableFeedStoreTests: XCTestCase {
  
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
}
