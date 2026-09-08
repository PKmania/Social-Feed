//
//  Created by CN23 on 23/07/26.
//

import Foundation
import SocialFeed
import UIKit

public final class FeedUIComposer {
  private init() {}
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let presenterAdapter = FeedLoaderPresentationAdaptor(feedLoader: feedLoader)
    let refreshController = FeedRefreshViewController(delegate: presenterAdapter)
    let feedController = FeedViewController(refreshController: refreshController)
    let presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, imageLoader: imageLoader),
                                  feedLoadingView: WeakRefVirtualProxy(refreshController))
    presenterAdapter.presenter = presenter
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
  func display(_ viewModel: FeedLoadingViewModel) {
    object?.display(viewModel)
  }
}


extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView , T.Image == UIImage {
  func display(_ model: FeedImageViewModel<UIImage>) {
    object?.display(model)
  }
}

private final class FeedViewAdapter: FeedView {
  private weak var controller: FeedViewController?
  private var imageLoader: FeedImageDataLoader
  
  init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }
  func display(_ viewModel: FeedViewModel) {
    controller?.tableModel = viewModel.feed.map({ model in
      let adapter = FeedImageDataLoaderPresentationAdaptor<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
      let view = FeedImageCellController(delegate: adapter)
      
      adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
      return view
    })

  }
}


private final class FeedLoaderPresentationAdaptor: FeedRefreshViewControllerDelegate {
  private let feedLoader: FeedLoader
  var presenter: FeedPresenter?
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  func didRequestFeedRefresh() {
    presenter?.didStartFeedLoading()
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

private final class FeedImageDataLoaderPresentationAdaptor<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
  private var task: FeedImageDataLoaderTask?
   private let model: FeedImage
   private let imageLoader: FeedImageDataLoader
  
  init(model: FeedImage, imageLoader: FeedImageDataLoader) {
    self.model = model
    self.imageLoader = imageLoader
  }
  
  var presenter: FeedImagePresenter<View, Image>?
  func didRequestImage() {
    let model = self.model
    presenter?.didStartLoadingImageData(for: model)
    
    task = imageLoader.loadImageData(from: model.url, completion: { [weak self] (result) in
      switch result {
      case let .success(data):
        self?.presenter?.didFinishLoadingImageData(with: data, for: model)
      case let .failure(error):
        self?.presenter?.didFinishLoadingImageData(with: error, for: model)
      }
    })
  }
  
  func didCancelImageRequest() {
    task?.cancel()
  }
  
}
