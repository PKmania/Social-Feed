//
//  Created by CN23 on 29/09/26.
//

import Foundation
import UIKit
import SocialFeed

public class ImageCommentCellController: NSObject {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
}

extension ImageCommentCellController: CellController {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: ImageCommentCell = tableView.dequeueReusableCell()
            cell.messageLabel.text = model.message
            cell.usernameLabel.text = model.username
            cell.dateLabel.text = model.date
            return cell
  }
  
  public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
  }
  
  
}
