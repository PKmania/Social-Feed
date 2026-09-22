//
//  Created by CN23 on 10/09/26.
//

import Foundation
import UIKit
import SocialFeed
import SocialFeedIOS

public final class FeedViewAdapter: FeedView {
  private weak var controller: FeedViewController?
  private var imageLoader: (URL) -> FeedImageDataLoader.Publisher
  
  public init(controller: FeedViewController, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
    self.controller = controller
    self.imageLoader = imageLoader
  }
  public func display(_ viewModel: FeedViewModel) {
    controller?.display(viewModel.feed.map({ model in
      let adapter = FeedImageDataLoaderPresentationAdaptor<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
      let view = FeedImageCellController(delegate: adapter)
      
      adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
      return view
    }))
  }
}
