//
//  Created by CN23 on 22/07/26.
//

import Foundation
import UIKit


final public class FeedRefreshViewController: NSObject, FeedLoadingView {

  public var view: UIRefreshControl  = UIRefreshControl(){
    didSet {
      setupView()
    }
  }
  private let loadFeed: (() -> Void)
  
  init(loadFeed: @escaping (() -> Void)) {
    self.loadFeed = loadFeed
    super.init()
    setupView()
  }
  
  private func setupView() {
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
  }
  
  @objc func refresh() {
    loadFeed()
  }
  
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    }else {
      view.endRefreshing()
    }
  }
}

