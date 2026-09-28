//
//  Created by CN23 on 10/09/26.
//

import Foundation

public final class FeedImagePresenter {
  
  public static func map(_ image: FeedImage) -> FeedImageViewModel {
    FeedImageViewModel(
      description: image.description,
      location: image.location,
    )
  }
}
