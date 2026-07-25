//
//  Created by CN23 on 25/07/26.
//

import Foundation
import SocialFeed

protocol FeedLoadingView: AnyObject {
  func display(isLoading: Bool)
}

protocol FeedView {
  func display(feed: [FeedImage])
}

final class FeedPresenter {
  
  private let feedLoader: FeedLoader
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  var feedView: FeedView?
  weak var feedLoadingView: FeedLoadingView?

   func loadFeed() {
     feedLoadingView?.display(isLoading: true)
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.feedView?.display(feed: feed)
      }
      self?.feedLoadingView?.display(isLoading: false)
    }
  }
}
