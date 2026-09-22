//
//  Created by CN23 on 10/09/26.
//

import Foundation
import SocialFeed
import SocialFeedIOS

public final class FeedLoaderPresentationAdaptor: FeedViewControllerDelegate {
  private let feedLoader: FeedLoader
  var presenter: FeedPresenter?
  public init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  public func didRequestFeedRefresh() {
    presenter?.didStartLoadingFeed()
    feedLoader.load { [weak self] (result) in
      switch result {
      case let .success(feed):
        self?.presenter?.didFinishLoadingFeed(with: feed)
      case let .failure(error):
        self?.presenter?.didFinishLoadingFeed(with: error)
      }
    }
  }
}
