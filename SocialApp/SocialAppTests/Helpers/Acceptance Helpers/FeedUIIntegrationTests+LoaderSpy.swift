//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  SocialAppTests
//
//  Created by CN23 on 21/09/26.
//

import Foundation
import SocialFeed
import SocialFeedIOS
extension FeedUIIntegrationTests {
  class LoaderSpy: FeedLoader, FeedImageDataLoader {
    
    //MARK: - FeedLoader
    private var feedRequest = [(FeedLoader.Result) -> Void]()
    var loadFeedCallCount: Int {
      feedRequest.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      feedRequest.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
      feedRequest[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
      let error = NSError(domain: "a error", code: 0)
      feedRequest[index](.failure(error))
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
