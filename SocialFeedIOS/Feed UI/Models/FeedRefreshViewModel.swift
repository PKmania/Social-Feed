//
//  Created by CN23 on 23/07/26.
//

import Foundation
import SocialFeed

final class FeedRefreshViewModel {
  
  private let feedLoader: FeedLoader
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
//    setupView()
  }

  private(set) var isLoading: Bool = false {
    didSet {
      onChange?(self)
    }
  }
  
  var onChange: ((FeedRefreshViewModel) -> Void)?
  var onFeedLoad: (([FeedImage]) -> Void)?

   func loadFeed() {
     isLoading = true
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onFeedLoad?(feed)
      }
      self?.isLoading = false
    }
  }
}
