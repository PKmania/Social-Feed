//
//  Created by CN23 on 11/07/26.
//

import UIKit
import SocialFeed

protocol FeedViewControllerDelegate {
  func didRequestFeedRefresh()
}


final public class FeedViewController: UITableViewController  {
  
  private var viewAppeared = false
  
  @IBOutlet private(set) public var errorView: ErrorView?
  
  var delegate: FeedViewControllerDelegate?
  
  var tableModel = [FeedImageCellController]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    refresh()
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    if !viewAppeared {
      refreshControl?.beginRefreshing()
      viewAppeared = true
    }
  }
  
  
  @IBAction private func refresh() {
    delegate?.didRequestFeedRefresh()
  }
}

extension FeedViewController: FeedLoadingView {
  public func display(_ viewModel: FeedLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }
}

extension FeedViewController: FeedErrorView {
  public func display(_ viewModel: FeedErrorViewModel) {
    if let errorMessage = viewModel.message {
      errorView?.show(message: errorMessage)
    } else {
      errorView?.hideMessage()
    }
  }
}

extension FeedViewController {
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view(in: tableView)
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cancelCellControllerLoad(forRowAt: indexPath)
  }
}

extension FeedViewController: UITableViewDataSourcePrefetching {
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      cellController(forRowAt: indexPath).preload()
    }
  }
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach(cancelCellControllerLoad)
  }
  
  
  
}
//MARK: - Private Methods
extension FeedViewController {
  
  private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
    return tableModel[indexPath.row]
  }
  
  private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
    cellController(forRowAt: indexPath).cancel()
  }
}
