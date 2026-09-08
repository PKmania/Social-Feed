//
//  Created by CN23 on 22/07/26.
//

import Foundation
import UIKit
protocol FeedRefreshViewControllerDelegate {
  func didRequestFeedRefresh()
}

final public class FeedRefreshViewController: NSObject, FeedLoadingView {

  public var view: UIRefreshControl  = UIRefreshControl(){
    didSet {
      setupView()
    }
  }
  private let delegate: FeedRefreshViewControllerDelegate
  
  init(delegate: FeedRefreshViewControllerDelegate) {
    self.delegate = delegate
    super.init()
    setupView()
  }
  
  private func setupView() {
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
  }
  
  @objc func refresh() {
    delegate.didRequestFeedRefresh()
  }
  
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    }else {
      view.endRefreshing()
    }
  }
}

