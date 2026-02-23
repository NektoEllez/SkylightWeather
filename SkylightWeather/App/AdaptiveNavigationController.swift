//
//  AdaptiveNavigationController.swift
//  SkylightWeather
//

import UIKit

/// Navigation controller that reapplies bar appearance when trait collection changes,
/// ensuring title and tint colors stay visible in both light and dark modes.
final class AdaptiveNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        applyBarAppearance()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
            self.applyBarAppearance()
        }
    }

    private func applyBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.compactScrollEdgeAppearance = appearance
        navigationBar.tintColor = .label
    }
}
