//
//  TrackerTests.swift
//  Tracker
//
//  Created by Galina evdokimova on 30.05.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackersViewControllerLight() throws {
        let trackersViewController = TrackersViewController()
        // Пожалуйста, расскоментируйте строку ниже для теста
//        trackersViewController.view.backgroundColor = .black

        assertSnapshot(
            matching: trackersViewController,
            as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testTrackersViewControllerDark() throws {
        let trackersViewController = TrackersViewController()
        // Пожалуйста, расскоментируйте строку ниже для теста
//        trackersViewController.view.backgroundColor = .white

        assertSnapshot(
            matching: trackersViewController,
            as: .image(size: trackersViewController.preferredContentSize,
                       traits: .init(userInterfaceStyle: .dark)))
    }
}
