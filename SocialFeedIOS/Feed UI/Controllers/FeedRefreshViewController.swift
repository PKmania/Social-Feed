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
  private let presnter: FeedPresenter
  
  init(presnter: FeedPresenter) {
    self.presnter = presnter
    super.init()
    setupView()
  }
  
  private func setupView() {
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
  }
  
  @objc func refresh() {
    presnter.loadFeed()
  }
  
  func display(isLoading: Bool) {
    if isLoading {
      view.beginRefreshing()
    }else {
      view.endRefreshing()
    }
  }
}

