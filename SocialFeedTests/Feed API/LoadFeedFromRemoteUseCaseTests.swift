//
//  Created by CN23 on 17/04/26.
//

import Foundation
import XCTest
import SocialFeed
//xcodebuild test -project SocialFeed.xcodeproj -scheme "CI_macos"


class LoadFeedFromRemoteUseCaseTests: XCTestCase {
  
  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    let samples = [199, 201, 300, 400, 500]
    samples.enumerated().forEach { (index, code) in
      expect(sut, toCompleteWith: failure(.invalidData)) {
        let json = makeItemsJSON([])
        client.complete(withStatusCode: code, data: json, at: index)
      }
    }
  }
  
  func test_load_deliversErrorOnNon200HTTPResponseWithInvalidJSONData() {
    let (sut, client) = makeSUT()
    expect(sut, toCompleteWith: failure(.invalidData)) {
      let invalidJSON = Data("InvalidJson".utf8)
      client.complete(withStatusCode: 200, data: invalidJSON)
    }
  }
  
  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONArray() {
    let (sut, client) = makeSUT()
    expect(sut, toCompleteWith: .success([])) {
      let emptyJSON = makeItemsJSON([])
      client.complete(withStatusCode: 200, data: emptyJSON)
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
      client.complete(withStatusCode: 200, data: json)
    }
  }
  
  //MARK: Helpers
  private func makeSUT(url: URL = URL(string: "https://any-url.com/posts")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
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
    ].compactMapValues { $0 }
    
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
}
