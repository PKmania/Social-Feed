//
//  Created by CN23 on 25/07/26.
//

import Foundation
import SocialFeed

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

protocol FeedErrorView {
  func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
  var feedView: FeedView
  var feedLoadingView: FeedLoadingView
  var errorView: FeedErrorView
  
  init(feedView: FeedView, feedLoadingView: FeedLoadingView, errorView: FeedErrorView) {
    self.feedView = feedView
    self.feedLoadingView = feedLoadingView
    self.errorView = errorView
  }
  
  static var title: String {
    return NSLocalizedString(
      "FEED_VIEW_TITLE",
      tableName: "Feed",
      bundle: Bundle(for: FeedPresenter.self),
      comment: "Title for the feed view")
  }
  
  private var feedLoadError: String {
      return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
         tableName: "Feed",
         bundle: Bundle(for: FeedPresenter.self),
         comment: "Error message displayed when we can't load the image feed from the server")
    }
  
  func didStartFeedLoading() {
    errorView.display(.noError)
    feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    self.feedView.display(FeedViewModel(feed: feed))
    self.feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoadingFeed(with error: Error) {
    errorView.display(.error(message: feedLoadError))
    self.feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}

