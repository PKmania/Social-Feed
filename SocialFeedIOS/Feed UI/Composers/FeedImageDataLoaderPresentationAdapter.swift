//
//  Created by CN23 on 10/09/26.
//

import Foundation
import SocialFeed

final class FeedImageDataLoaderPresentationAdaptor<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
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
