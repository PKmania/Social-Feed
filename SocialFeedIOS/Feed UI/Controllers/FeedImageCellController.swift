//
//  Created by CN23 on 23/07/26.
//

import Foundation
import UIKit
import SocialFeed

public protocol FeedImageCellControllerDelegate {
  func didRequestImage()
  func didCancelImageRequest()
}

public final class FeedImageCellController: CellController, ResourceView, ResourceLoadingView, ResourceErrorView {
  
  public typealias ResourceViewModel = UIImage
  
  private let viewModel: FeedImageViewModel
  private var delegate: FeedImageCellControllerDelegate
  private var cell: FeedImageCell?
  
  public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate) {
    self.viewModel = viewModel
    self.delegate = delegate
  }
  
  public func view(in tableView: UITableView) -> UITableViewCell {
    cell = tableView.dequeueReusableCell()
    
    cell?.locationContainer.isHidden = !viewModel.hasLocation
    cell?.locationLabel.text = viewModel.location
    cell?.descriptionLabel.text = viewModel.description
    cell?.feedImageView.image = nil
    cell?.onRetry = delegate.didRequestImage
    delegate.didRequestImage()
    return cell!
  }
  
  public func display(_ viewModel: UIImage) {
    cell?.feedImageView.setImageAnimated(viewModel)
  }
  
  public func display(_ viewModel: ResourceLoadingViewModel) {
    cell?.feedImageContainer.isShimmering = viewModel.isLoading
  }
  
  public func display(_ viewModel: ResourceErrorViewModel) {
    cell?.feedImageRetryButton.isHidden = viewModel.message == nil
  }
  
  public func preload() {
    delegate.didRequestImage()
  }
  
  public func cancelLoad() {
    releaseCellForReuse()
    delegate.didCancelImageRequest()
  }
  
  private func releaseCellForReuse() {
    cell?.onReuse = nil
    cell = nil
  }
}
