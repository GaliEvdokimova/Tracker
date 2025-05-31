//
//  MetricaService.swift
//  Tracker
//
//  Created by Galina evdokimova on 31.05.2025.
//

import Foundation
import YandexMobileMetrica

enum Event: String {
    case open = "open"
    case close = "close"
    case click = "click"
}

enum Screen: String {
    case main = "Main"
}

enum Item: String {
    case add_track = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

struct AnalyticsService {
    private enum ParamKeys {
        static let screen = "screen"
        static let item = "item"
    }
    
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "8e8b1b2e-cff3-4400-9ae9-1b1b376fafaf") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }

    func report(event: Event, screen: Screen, item: Item? = nil) {
        var params: [String : String] = [ParamKeys.screen : screen.rawValue]
        if let item = item {
            params[ParamKeys.item] = item.rawValue
        }
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
