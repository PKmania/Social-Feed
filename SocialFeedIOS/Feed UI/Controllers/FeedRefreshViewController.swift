//
//  Created by CN23 on 22/07/26.
//

import Foundation
import UIKit


final public class FeedRefreshViewController: NSObject {

  public var view: UIRefreshControl  = UIRefreshControl(){
    didSet {
      setupView()
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
    bind()
    viewModel.loadFeed()
  }
  
  private func bind() {
    viewModel.onChange = { [weak self] viewModel in
      if viewModel.isLoading {
        self?.view.beginRefreshing()
      }else {
        self?.view.endRefreshing()
      }
    }
  }
}

