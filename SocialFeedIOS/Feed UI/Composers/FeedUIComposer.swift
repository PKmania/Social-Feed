//
//  Created by CN23 on 23/07/26.
//

import Foundation
import SocialFeed

public final class FeedUIComposer {
  private init() {}
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let viewModel = FeedRefreshViewModel(feedLoader: feedLoader)
    let refreshController = FeedRefreshViewController(viewModel: viewModel)
    let feedController = FeedViewController(refreshController: refreshController)
    viewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
    return feedController
  }
  
  
  private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    return { [weak controller] feed in
      controller?.tableModel = feed.map { model in
        FeedImageCellController(model: model, imageLoader: loader)
      }
    }
  }
}
