//
//  UITableView+HeaderSizing.swift
//  SocialFeedIOS
//
//  Created by CN23 on 21/09/26.
//

import Foundation
import UIKit

extension UITableView {
  func sizeTableHeaderToFit() {
    guard let header = tableHeaderView else { return }
    
    let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    
    let needsFrameUpdate = header.frame.height != size.height
    if needsFrameUpdate {
      header.frame.size.height = size.height
      tableHeaderView = header
    }
  }
}
