//
//  Created by CN23 on 10/09/26.
//

import Foundation
import SocialFeed
import SocialFeedIOS
import Combine

public final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
  private let loader: () -> AnyPublisher<Resource, Error>
  private var cancellable: Cancellable?
  var presenter: LoadResourcePresenter<Resource, View>?
  
  public init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
    self.loader = loader
  }
  public func loadResource() {
    presenter?.didStartLoading()
    
    cancellable = loader()
      .dispatchOnMainQueue()
      .sink(
        receiveCompletion: { [weak self] completion in
          switch completion {
          case .finished: break
            
          case let .failure(error):
            self?.presenter?.didFinishLoading(with: error)
          }
        }, receiveValue: { [weak self] resource in
          self?.presenter?.didFinishLoading(with: resource)
        })
  }
}

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
  public func didRequestFeedRefresh() {
    loadResource()
  }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
  public func didRequestImage() {
    loadResource()
  }
  
  public func didCancelImageRequest() {
    cancellable?.cancel()
    cancellable = nil
  }
}
