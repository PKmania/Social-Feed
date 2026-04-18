//
//  Created by CN23 on 17/04/26.
//

import Foundation
import XCTest
import SocialFeed
//xcodebuild test -project SocialFeed.xcodeproj -scheme "CI_macos"


class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    let url = URL(string: "https://any-url.com/posts")!
    let (_, client) = makeSUT(url: url)

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_load_requestDataFromURL() {
    let url = URL(string: "https://any-url.com/posts")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load {_ in }
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadTwice_requestDataFromURLTwice() {
    let url = URL(string: "https://any-url.com/posts")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load {_ in }
    sut.load {_ in }
    
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_load_deliversErrorOnClientError() {
    let url = URL(string: "https://any-url.com/posts")!
    let (sut, client) = makeSUT(url: url)
    
    var capturedErrors =  [RemoteFeedLoader.Error]()
    sut.load { capturedErrors.append($0) }
    
    let error = NSError(domain: "any", code: 0)
    client.complete(with: error)

    XCTAssertEqual(capturedErrors, [.connectivity])
  }
  
  //MARK: Helpers
  private func makeSUT(url: URL = URL(string: "https://any-url.com/posts")!) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy) {
    let client = HTTPCLientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut, client)
  }
  
  private class HTTPCLientSpy: HTTPClient {
    var requestedURLs: [URL] {
      return messages.map { $0.url }
    }
    var messages: [(url: URL, completion: (Error) -> Void)] = []
    
    func get(from url: URL, completion: @escaping (Error) -> Void) {
      messages.append((url: url, completion: completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(error)
    }
  }
}
