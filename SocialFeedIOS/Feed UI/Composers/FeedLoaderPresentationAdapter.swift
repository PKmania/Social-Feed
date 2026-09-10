//
//  Created by CN23 on 10/09/26.
//

import Foundation
import SocialFeed

final class FeedLoaderPresentationAdaptor: FeedViewControllerDelegate {
  private let feedLoader: FeedLoader
  var presenter: FeedPresenter?
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  func didRequestFeedRefresh() {
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
