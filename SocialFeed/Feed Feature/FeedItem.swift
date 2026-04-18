//
//  Created by CN23 on 17/04/26.
//

import Foundation

public struct FeedItem : Equatable{
  public let id: UUID
  public let description: String?
  public let location: String?
  public let imageURL: URL
}
