//
//  Filters.swift
//  Tracker
//
//  Created by Galina evdokimova on 29.05.2025.
//

import Foundation

enum Filters: String, CaseIterable {
    case allTrackers = "Все трекеры"
    case trackersToday = "Трекеры на сегодня"
    case completedTrackers =  "Завершенные"
    case unCompletedTrackers =  "Не завершенные"
}
