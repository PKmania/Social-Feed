//
//  Created by CN23 on 23/07/26.
//

import Foundation
import SocialFeed
import UIKit

public final class FeedUIComposer {
  private init() {}
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let presenter = FeedPresenter(feedLoader: feedLoader)
    let refreshController = FeedRefreshViewController(presnter: presenter)
    let feedController = FeedViewController(refreshController: refreshController)
    presenter.feedLoadingView = WeakRefVirtualProxy(refreshController)
    presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
    return feedController
  }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
  private weak var object: T?
  init(_ object: T) {
    self.object = object
  }
}
extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
  func display(isLoading: Bool) {
    object?.display(isLoading: isLoading)
  }
}
private final class FeedViewAdapter: FeedView {
  private weak var controller: FeedViewController?
  private var imageLoader: FeedImageDataLoader
  
  init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }
  
  func display(feed: [FeedImage]) {
    controller?.tableModel = feed.map({ model in
      FeedImageCellController(viewModel:
                                FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))

    })
  }
}
