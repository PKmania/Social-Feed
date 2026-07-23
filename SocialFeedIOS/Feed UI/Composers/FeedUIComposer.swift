//
//  Created by CN23 on 23/07/26.
//

import Foundation
import SocialFeed
public final class FeedUIComposer {
  private init() {}
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
    let feedController = FeedViewController(refreshController: refreshController)
    refreshController.onRefresh = { [weak feedController] feed in
      feedController?.tableModel = feed.map({ model in
        FeedImageCellController(model: model, imageLoader: imageLoader)
      })
    }
    return feedController
  }
}
