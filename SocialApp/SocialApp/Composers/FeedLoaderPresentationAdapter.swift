//
//  Created by CN23 on 10/09/26.
//

import Foundation
import SocialFeed
import SocialFeedIOS
import Combine

public final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
  var presenter: FeedPresenter?
  private var cancellable: Cancellable?
  
  public init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
    self.feedLoader = feedLoader
  }
  public func didRequestFeedRefresh() {
    presenter?.didStartLoadingFeed()
    
    cancellable = feedLoader()
      .dispatchOnMainQueue()
      .sink(
        receiveCompletion: { [weak self] completion in
          switch completion {
          case .finished: break
            
          case let .failure(error):
            self?.presenter?.didFinishLoadingFeed(with: error)
          }
        }, receiveValue: { [weak self] feed in
          self?.presenter?.didFinishLoadingFeed(with: feed)
        })
  }
}
