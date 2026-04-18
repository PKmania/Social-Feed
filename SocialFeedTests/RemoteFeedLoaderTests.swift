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
  
  func test_load_deliversErrorOnNon200HTTPResponse() {
    let url = URL(string: "https://any-url.com/posts")!
    let (sut, client) = makeSUT(url: url)
    let samples = [199, 201, 300, 400, 500]
    samples.enumerated().forEach { (index, code) in
      var capturedErrors =  [RemoteFeedLoader.Error]()
      sut.load { capturedErrors.append($0) }
      
      client.complete(with: code, at: index)

      XCTAssertEqual(capturedErrors, [.invalidData])
    }
  }
  
  func test_load_deliversErrorOnNon200HTTPResponseWithInvalidJSONData() {
    let (sut, client) = makeSUT()
    var capturedErrors =  [RemoteFeedLoader.Error]()
    sut.load { capturedErrors.append($0) }
    
    let invalidJSON = Data()
    client.complete(with: 200, data: invalidJSON)

    XCTAssertEqual(capturedErrors, [.invalidData])
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
    var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }
    func complete(with statusCode: Int, data: Data = Data(), at index: Int = 0) {
      let reponse = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
      messages[index].completion(.success((data, reponse)))
    }
  }
}
