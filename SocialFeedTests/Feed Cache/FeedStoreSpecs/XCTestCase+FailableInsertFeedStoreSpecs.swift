//
//  Created by CN23 on 27/06/26.
//

import XCTest
import SocialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
  func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)

    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
  }

  func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
    insert((uniqueImageFeed().local, Date()), to: sut)

    expect(sut, toRetrieve: .empty, file: file, line: line)
  }
}
