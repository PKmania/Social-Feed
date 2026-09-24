//
//  Created by CN23 on 10/09/26.
//

import Foundation
import SocialFeed
import SocialFeedIOS
import Combine
final class FeedImageDataLoaderPresentationAdaptor<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
  private let model: FeedImage
  private var cancellable: Cancellable?
  private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
  
  init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
    self.model = model
    self.imageLoader = imageLoader
  }
  
  var presenter: FeedImagePresenter<View, Image>?
  func didRequestImage() {
    let model = self.model
    presenter?.didStartLoadingImageData(for: model)
    
    cancellable = imageLoader(model.url)
      .dispatchOnMainQueue()
      .sink { [weak self] (completion) in
        switch completion {
        case .finished: break
        case let .failure(error):
          self?.presenter?.didFinishLoadingImageData(with: error, for: model)
        }
      } receiveValue: { [weak self] (data) in
        self?.presenter?.didFinishLoadingImageData(with: data, for: model)
        
      }
  }
  
  
  func didCancelImageRequest() {
    cancellable?.cancel()
  }
}
