//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Galina evdokimova on 25.05.2025.
//

import UIKit
import Combine

final class CategoryViewModel {
    private var trackerCategoryStore = TrackerCategoryStore()
    private(set) var categories: [TrackerCategory] = []
    
    init() {
        trackerCategoryStore.delegate = self
        self.categories = trackerCategoryStore.trackerCategories
    }
    
    @Published private(set) var selectedCategory: TrackerCategory?
        var selectedCategoryPublisher: AnyPublisher<TrackerCategory?, Never> {
            $selectedCategory.eraseToAnyPublisher()
        }
    
    func addCategory(_ name: String) {
        do {
            try self.trackerCategoryStore.addCategory(TrackerCategory(title: name, trackers: []))
        } catch {
            print("Error add category: \(error.localizedDescription)")
        }
    }
    
    func addNewTrackerToCategory(to title: String?, tracker: Tracker) {
        do {
            try self.trackerCategoryStore.addNewTrackerToCategory(to: title, tracker: tracker)
        } catch {
            print("Error add new tracker to category: \(error.localizedDescription)")
        }
    }
    
    func selectCategory(_ index: Int) {
        self.selectedCategory = self.categories[index]
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func categoryStore() {
        self.categories = trackerCategoryStore.trackerCategories
    }
}

