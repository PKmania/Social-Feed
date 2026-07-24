//
//  Created by CN23 on 23/07/26.
//

import Foundation
import UIKit


final class FeedImageCellController {
  private var viewModel: FeedImageViewModel<UIImage>

  
  init(viewModel: FeedImageViewModel<UIImage>) {
    self.viewModel = viewModel
  }
  
  func view() -> UITableViewCell {
    let cell = binded(FeedImageCell())
    viewModel.loadImageData()
    return cell
  }
  
  func binded(_ cell: FeedImageCell) -> FeedImageCell {
    let cell = FeedImageCell()
    cell.locationContainer.isHidden = !viewModel.hasLocation
    cell.locationLabel.text = viewModel.location
    cell.descriptionLabel.text = viewModel.description
    cell.onRetry = viewModel.loadImageData
    
    viewModel.onImageLoad = { [weak cell] image in
      cell?.feedImageView.image = image
    }
    
    viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
      cell?.feedImageContainer.isShimmering = isLoading
    }
    viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
      cell?.feedImageRetryButton.isHidden = !shouldRetry
    }
    
    return cell
  }
  
  func preload() {
    viewModel.loadImageData()
  }
  
  func cancel() {
    viewModel.cancelImageLoad()
  }
}
