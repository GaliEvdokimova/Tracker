//
//  TrackingTest.swift
//  TrackingTest
//
//  Created by Galina evdokimova on 31.05.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let vc = TrackersViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        
        navigationController.view.frame = UIScreen.main.bounds
        
        vc.loadViewIfNeeded()
        
        assertSnapshot(
            matching: navigationController,
            as: .image
        )
    }
}
