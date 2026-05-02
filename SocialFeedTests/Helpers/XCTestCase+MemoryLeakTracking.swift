//
//  Created by CN23 on 20/04/26.
//

import XCTest

extension XCTestCase {
  func trackMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
    addTeardownBlock { [weak instance] in
      XCTAssertNil(instance, "instance should have been deallocted. Potential memory leaks.", file: file, line: line)
    }
  }
}
