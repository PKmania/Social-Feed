//
//  Created by CN23 on 11/07/26.
//

import UIKit
import SocialFeed

final public class FeedViewController: UITableViewController {
  public var refreshController: FeedRefreshViewController?
  private var viewAppeared = false
  
  var tableModel = [FeedImageCellController]() {
    didSet {
      tableView.reloadData()
    }
  }
  
  public convenience init(refreshController: FeedRefreshViewController) {
    self.init()
    self.refreshController = refreshController
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    tableView.prefetchDataSource = self
    refreshControl = refreshController?.refreshControl
    refreshController?.refresh()
  
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    if !viewAppeared {
      refreshControl?.beginRefreshing()
      viewAppeared = true
    }
  }
}

extension FeedViewController {
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellController(forRowAt: indexPath).view()
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
