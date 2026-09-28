//
//  Created by CN23 on 10/09/26.
//

import Foundation
import SocialFeed
import SocialFeedIOS
import Combine

public final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
  private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
  private var cancellable: Cancellable?
  var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
  
  public init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
    self.feedLoader = feedLoader
  }
  public func didRequestFeedRefresh() {
    presenter?.didStartLoading()
    
    cancellable = feedLoader()
      .dispatchOnMainQueue()
      .sink(
        receiveCompletion: { [weak self] completion in
          switch completion {
          case .finished: break
            
          case let .failure(error):
            self?.presenter?.didFinishLoading(with: error)
          }
        }, receiveValue: { [weak self] feed in
          self?.presenter?.didFinishLoading(with: feed)
        })
  }
}
