//
//  Created by CN23 on 10/09/26.
//

import Foundation
import UIKit
import SocialFeed
import SocialFeedIOS

public final class FeedViewAdapter: ResourceView {
  
  private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
  
  private weak var controller: ListViewController?
  private var imageLoader: (URL) -> FeedImageDataLoader.Publisher
  private let selection: (FeedImage) -> Void
      
  
  public init(
    controller: ListViewController,
    imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
    selection: @escaping (FeedImage) -> Void
  ) {
    self.controller = controller
    self.imageLoader = imageLoader
    self.selection = selection
  }
  
  public func display(_ viewModel: FeedViewModel) {
    controller?.display(viewModel.feed.map({ model in
      let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
        imageLoader(model.url)
      })
      
      let view = FeedImageCellController(
        viewModel: FeedImagePresenter.map(model),
        delegate: adapter,
        selection: { [selection] in
          selection(model)
        }
      )
      
      adapter.presenter = LoadResourcePresenter(
        resourceView: WeakRefVirtualProxy(view),
        loadingView: WeakRefVirtualProxy(view),
        errorView: WeakRefVirtualProxy(view),
        mapper: UIImage.tryMake)
      return CellController(id:model, view)
    }))
  }
}

extension UIImage {
    struct InvalidImageData: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
