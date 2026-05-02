//
//  Created by CN23 on 24/04/26.
//

import Foundation

internal struct RemoteFeedItem : Decodable{
  internal let id: UUID
  internal let description: String?
  internal let location: String?
  internal let image: URL
}
