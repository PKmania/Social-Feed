//
//  Created by CN23 on 11/07/26.
//

import UIKit
import SocialFeed

final public class ListViewController: UITableViewController  {
  
  private var viewAppeared = false
  
  private(set) public var errorView = ErrorView()
  public var onRefresh: (() -> Void)?
  
  private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
    .init(tableView: tableView) { (tableView, index, controller) in
      controller.dataSource.tableView(tableView, cellForRowAt: index)
    }
  }()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureTableView()
    configureTraitCollectionObservers()
    refresh()
  }
  
  private func configureTableView() {
    dataSource.defaultRowAnimation = .fade
    tableView.dataSource = dataSource
    tableView.tableHeaderView = errorView.makeContainer()
    
    errorView.onHide = { [weak self] in
      self?.tableView.beginUpdates()
      self?.tableView.sizeTableHeaderToFit()
      self?.tableView.endUpdates()
    }
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
  
  private func configureTraitCollectionObservers() {
      registerForTraitChanges(
        [UITraitPreferredContentSizeCategory.self]
      ) { (self: Self, previous: UITraitCollection) in
        self.tableView.reloadData()
      }
    }
  
  @IBAction private func refresh() {
    onRefresh?()
  }
  public func display(_ cellController: [CellController]) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
    snapshot.appendSections([0])
    snapshot.appendItems(cellController, toSection: 0)
    dataSource.apply(snapshot)
  }
}

extension ListViewController: ResourceLoadingView {
  public func display(_ viewModel: ResourceLoadingViewModel) {
    refreshControl?.update(isRefreshing: viewModel.isLoading)
  }
}

extension ListViewController: ResourceErrorView {
  public func display(_ viewModel: ResourceErrorViewModel) {
    errorView.message = viewModel.message
  }
}

extension ListViewController {
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let dl = cellController(at: indexPath)?.delegate
    dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
  }
}

extension ListViewController: UITableViewDataSourcePrefetching {
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      
      dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
  }
  public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    indexPaths.forEach { indexPath in
      let dsp = cellController(at: indexPath)?.dataSourcePrefetching
      dsp?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
  }
}
//MARK: - Private Methods
extension ListViewController {
  private func cellController(at indexPath: IndexPath) -> CellController? {
    dataSource.itemIdentifier(for: indexPath)
  }
}
