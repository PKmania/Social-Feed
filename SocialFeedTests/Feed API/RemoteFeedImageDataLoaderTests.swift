//
//  Created by CN23 on 11/09/26.
//

import XCTest
import Foundation
import SocialFeed

class RemoteFeedImageDataLoader {
  init(client: Any) {
    
  }
}

class RemoteFeedImageDataLoaderTests: XCTestCase {

  func test_init_doesNotPerformAnyURLRequest() {
    let (_, client) = makeSUT()
    
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedImageDataLoader(client: client)
    trackMemoryLeaks(sut, file: file, line: line)
    trackMemoryLeaks(client, file: file, line: line)
    return (sut, client)
  }

  private class HTTPClientSpy {
    var requestedURLs = [URL]()
  }
}
