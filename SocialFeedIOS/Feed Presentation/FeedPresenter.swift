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

final class FeedPresenter {
  var feedView: FeedView
  var feedLoadingView: FeedLoadingView

  init(feedView: FeedView, feedLoadingView: FeedLoadingView) {
    self.feedView = feedView
    self.feedLoadingView = feedLoadingView
  }
  
  static var title: String {
    return "My Feed"
  }
  
  func didStartFeedLoading() {
    feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    self.feedView.display(FeedViewModel(feed: feed))
    self.feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoadingFeed(with error: Error) {
    self.feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}
