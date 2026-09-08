//
//  Created by CN23 on 22/07/26.
//

import Foundation
import UIKit
protocol FeedRefreshViewControllerDelegate {
  func didRequestFeedRefresh()
}

final public class FeedRefreshViewController: NSObject, FeedLoadingView {
  @IBOutlet public var view: UIRefreshControl?

  var delegate: FeedRefreshViewControllerDelegate?

  @IBAction func refresh() {
    delegate?.didRequestFeedRefresh()
  }
  
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view?.beginRefreshing()
    }else {
      view?.endRefreshing()
    }
  }
}

