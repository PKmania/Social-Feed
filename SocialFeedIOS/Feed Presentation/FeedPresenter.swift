//
//  Created by CN23 on 25/07/26.
//

import Foundation
import SocialFeed

struct FeedLoadingViewModel {
  let isLoading: Bool
}
protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}
struct FeedViewModel {
  let feed: [FeedImage]
}
protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
  
  private let feedLoader: FeedLoader
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  var feedView: FeedView?
  var feedLoadingView: FeedLoadingView?

   func loadFeed() {
     feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.feedView?.display(FeedViewModel(feed: feed))
      }
      self?.feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
    }
  }
}
