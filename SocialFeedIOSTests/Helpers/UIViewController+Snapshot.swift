import Foundation
import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection
    
    static func iPhone17(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        let traits = UITraitCollection { mutableTraits in
            mutableTraits.forceTouchCapability = .unavailable
            mutableTraits.layoutDirection = .leftToRight
            mutableTraits.preferredContentSizeCategory = contentSize
            mutableTraits.userInterfaceIdiom = .phone
            mutableTraits.horizontalSizeClass = .compact
            mutableTraits.verticalSizeClass = .regular
            mutableTraits.displayScale = 3
            mutableTraits.accessibilityContrast = .normal
            mutableTraits.displayGamut = .P3
            mutableTraits.userInterfaceStyle = style
        }
        return SnapshotConfiguration(
            size: CGSize(width: 402, height: 874),
            safeAreaInsets: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 59, left: 16, bottom: 34, right: 16),
            traitCollection: traits
        )
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone17(style: .light)
  
  convenience init(configuration: SnapshotConfiguration, root: UIViewController) {

      self.init(frame: CGRect(origin: .zero, size: configuration.size))

      self.configuration = configuration

      self.layoutMargins = configuration.layoutMargins

      self.rootViewController = root

      self.isHidden = false

      root.view.layoutMargins = configuration.layoutMargins

  }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
      configuration.traitCollection
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}
