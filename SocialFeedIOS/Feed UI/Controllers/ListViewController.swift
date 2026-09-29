//
//  Created by CN23 on 11/07/26.
//

import UIKit
import SocialFeed

public protocol CellController {
    func view(in tableView: UITableView) -> UITableViewCell
    func preload()
    func cancelLoad()
}

final public class ListViewController: UITableViewController  {
  
  private var viewAppeared = false
  
  @IBOutlet private(set) public var errorView: ErrorView?
  
  public var onRefresh: (() -> Void)?
  
  private var loadingControllers = [IndexPath: CellController]()
  
  private var tableModel = [CellController]() {
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
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.sizeTableHeaderToFit()
  }
  
  @IBAction private func refresh() {
    onRefresh!()
  }
  public func display(_ cellController: [CellController]) {
    loadingControllers = [:]
    tableModel = cellController
  }
}

extension ListViewController: ResourceLoadingView {
  public func display(_ viewModel: ResourceLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }
}

extension ListViewController: ResourceErrorView {
  public func display(_ viewModel: ResourceErrorViewModel) {
    if let errorMessage = viewModel.message {
      errorView?.show(message: errorMessage)
    } else {
      errorView?.hideMessageAnimated()
    }
  }
}

extension ListViewController {
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

extension ListViewController: UITableViewDataSourcePrefetching {
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
extension ListViewController {
  private func cellController(forRowAt indexPath: IndexPath) -> CellController {
    let controller = tableModel[indexPath.row]
          loadingControllers[indexPath] = controller
          return controller
  }
  
  private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
    loadingControllers[indexPath]?.cancelLoad()
            loadingControllers[indexPath] = nil
  }
}
