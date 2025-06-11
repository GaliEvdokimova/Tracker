//
//  TabBarController.swift
//  Tracker
//
//  Created by Galina evdokimova on 24.03.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = UINavigationController(rootViewController: TrackersViewController())
        trackersViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("app.title", comment: ""),
            image: UIImage(named: "Trackers"),
            selectedImage: nil
        )
        
        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistic.title", comment: ""),
            image: UIImage(named: "Rabbit"),
            selectedImage: nil
        )
        self.viewControllers = [trackersViewController, statisticsViewController]
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor.ypCustomWhite
            UITabBar.appearance().standardAppearance = tabBarAppearance
            
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
}
