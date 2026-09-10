//
//  Created by CN23 on 10/09/26.
//

import Foundation
import XCTest

final class FeedPresenter {
  init(view: Any) {
    
  }
}

class FeedPresenterTests: XCTestCase {
  
  func test_init_doesNotSendMessagesToView() {
    let view = ViewSpy()
    
    _ = FeedPresenter(view: view)
    
    XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = FeedPresenter(view: view)
    trackMemoryLeaks(view, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }
  
  private class ViewSpy {
    let messages = [Any]()
  }
  
}
