//
//  Created by CN23 on 17/04/26.
//

import Foundation
import XCTest
import SocialFeed
//xcodebuild test -project SocialFeed.xcodeproj -scheme "CI_macos"


class LoadFeedFromRemoteUseCaseTests: XCTestCase {
  
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
    let (sut, client) = makeSUT()
    expect(sut, toCompleteWith: failure(.connectivity)) {
      let error = NSError(domain: "any", code: 0)
      client.complete(with: error)
    }
  }
  
  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    let samples = [199, 201, 300, 400, 500]
    samples.enumerated().forEach { (index, code) in
      expect(sut, toCompleteWith: failure(.invalidData)) {
        let json = makeItemsJSON([])
        client.complete(with: code, data: json , at: index)
      }
    }
  }
  
  func test_load_deliversErrorOnNon200HTTPResponseWithInvalidJSONData() {
    let (sut, client) = makeSUT()
    expect(sut, toCompleteWith: failure(.invalidData)) {
      let invalidJSON = Data()
      client.complete(with: 200, data: invalidJSON)
    }
  }
  
  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONArray() {
    let (sut, client) = makeSUT()
    expect(sut, toCompleteWith: .success([])) {
      let emptyJSON = makeItemsJSON([])
      client.complete(with: 200, data: emptyJSON)
    }
  }
  
  func test_load_deliversItemsOn200HTTPResponseWithValidJSONArray() {
    let (sut, client) = makeSUT()
    let item1 = makeItem(id: UUID(),
                         description: nil,
                         location: nil,
                         imageURL: URL(string: "https://any-url.com/posts")!)
    let item2 = makeItem(id: UUID(),
                         description: "a description",
                         location: "a location",
                         imageURL: URL(string: "https://any-url.com/posts")!)
        
    let json = makeItemsJSON([item1.json, item2.json])
    
    expect(sut, toCompleteWith: .success([item1.model, item2.model])) {
      client.complete(with: 200, data: json)
    }
  }
  
  func test_load_doesNotDeliversResultAfterSUTHasBeenDeallocated() {
    let client = HTTPCLientSpy()
    var sut: RemoteFeedLoader? = RemoteFeedLoader(url: URL(string: "https://any-url.com/posts")!, client: client)
    var capturedResults =  [RemoteFeedLoader.Result]()
    sut?.load { capturedResults.append($0) }
    sut = nil
    client.complete(with: 200, data: makeItemsJSON([]))
    XCTAssertTrue(capturedResults.isEmpty)
  }
  
  //MARK: Helpers
  private func makeSUT(url: URL = URL(string: "https://any-url.com/posts")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPCLientSpy) {
    let client = HTTPCLientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    trackMemoryLeaks(sut, file: file, line: line)
    trackMemoryLeaks(client, file: file, line: line)
    return (sut, client)
  }
  
  private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
    .failure(error)
  }
  
  private func makeItem(id: UUID, description: String?, location: String?, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
    let feedItem = FeedImage(id: id, description: description, location: location, url: imageURL)
    let json = [
      "id": id.uuidString,
      "image": imageURL.absoluteString,
      "description": description,
      "location": location
    ].reduce(into: [String: Any]()) { (acc, e) in
      if let value = e.value {
        acc[e.key] = value
      }
    }
    return (feedItem, json)
  }
  
  private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
  }
  
  private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    let exp = expectation(description: "wait for load implementation")
    
    sut.load { (receivedResult) in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedItems), .success(expectedItems)):
        XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
      case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        
      default:
        XCTFail("Unexpected result: \(receivedResult), expected: \(expectedResult)", file: file, line: line)
      }
      exp.fulfill()
    }
    
    action()
    
    wait(for: [exp], timeout: 1.0)
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
    func complete(with statusCode: Int, data: Data, at index: Int = 0) {
      let reponse = HTTPURLResponse(url: requestedURLs[index], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
      messages[index].completion(.success((data, reponse)))
    }
  }
}
