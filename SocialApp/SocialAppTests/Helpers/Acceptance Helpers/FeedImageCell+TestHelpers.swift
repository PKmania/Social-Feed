//
//  FeedImageCell+TestHelpers.swift
//  SocialAppTests
//
//  Created by CN23 on 21/09/26.
//

import Foundation
import SocialFeedIOS
import UIKit

extension FeedImageCell {
  var isShowingLocation: Bool {
    return !locationContainer.isHidden
  }
  var locationText: String? {
    return locationLabel.text
  }
  
  var descriptionText: String? {
    return descriptionLabel.text
  }
  
  var isShowingImageLoadingIndicator: Bool {
    return feedImageContainer.isShimmering
  }
  
  var renderedImage: Data? {
    return feedImageView.image?.pngData()
  }
  
  var isShowingRetryAction: Bool {
    return !feedImageRetryButton.isHidden
  }
  
  func simulateRetryAction() {
    feedImageRetryButton.simulateTap()
  }
}
