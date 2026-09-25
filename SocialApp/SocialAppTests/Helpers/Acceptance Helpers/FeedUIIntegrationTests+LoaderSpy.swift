//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  SocialAppTests
//
//  Created by CN23 on 21/09/26.
//

import Foundation
import SocialFeed
import SocialFeedIOS
import Combine

extension FeedUIIntegrationTests {
  class LoaderSpy: FeedImageDataLoader {
    
    //MARK: - FeedLoader
    private var feedRequests = [PassthroughSubject<[FeedImage], Error>]()
    var loadFeedCallCount: Int {
      feedRequests.count
    }
    
    func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
               let publisher = PassthroughSubject<[FeedImage], Error>()
               feedRequests.append(publisher)
               return publisher.eraseToAnyPublisher()
           }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
      feedRequests[index].send(feed)
    }
    
    func completeFeedLoadingWithError(at index: Int) {
      let error = NSError(domain: "a error", code: 0)
      feedRequests[index].send(completion: .failure(error))
    }
    
    //MARK: - FeedImageDataLoader
    var loadedImageURLs:  [URL] {
      imageRequest.map {$0.url}
    }
    private var imageRequest = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    private(set) var cancelledImageURLs = [URL]()
    
    private struct TaskSpy: FeedImageDataLoaderTask {
      let cancelCallback: () -> Void
      func cancel() {
        cancelCallback()
      }
    }
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
      imageRequest.append((url, completion))
      return TaskSpy { [weak self] in  self?.cancelledImageURLs.append(url)}
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
      imageRequest[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int) {
      let error = NSError(domain: "a error", code: 0)
      imageRequest[index].completion(.failure(error))
    }
  }
}
