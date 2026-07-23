//
//  Created by CN23 on 22/07/26.
//

import Foundation
import UIKit


final public class FeedRefreshViewController: NSObject {

  public var view: UIRefreshControl  = UIRefreshControl(){
    didSet {
      setupView()
      bind()
    }
  }
  private let viewModel: FeedRefreshViewModel
  
  init(viewModel: FeedRefreshViewModel) {
    self.viewModel = viewModel
    super.init()
    setupView()
    
  }
  private func setupView() {
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)

  }
  
  @objc func refresh() {
    
    viewModel.loadFeed()
  }
  
  private func bind() {
    viewModel.onLoadingStateChange = { [weak view] isLoading in
      if isLoading {
        view?.beginRefreshing()
      }else {
        view?.endRefreshing()
      }
    }
  }
}

