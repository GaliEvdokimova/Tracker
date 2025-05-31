//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Galina evdokimova on 25.05.2025.
//

import Combine

final class CategoryViewModel {
    private var trackerCategoryStore = TrackerCategoryStore()
    private(set) var categories: [TrackerCategory] = []
    
    @Observable
    private(set) var selectedCategory: TrackerCategory?
    
    init() {
        trackerCategoryStore.delegate = self
        self.categories = trackerCategoryStore.trackerCategories
    }
    
    func addCategory(_ name: String) {
        do {
            try self.trackerCategoryStore.addCategory(TrackerCategory(title: name, trackers: []))
        } catch {
            // TODO: "Обработать ошибку"
            print("Error add category: \(error.localizedDescription)")
        }
    }
    
    func addTrackerToCategory(to category: TrackerCategory, tracker: Tracker) {
        do {
            try self.trackerCategoryStore.addTrackerToCategory(to: category, tracker: tracker)
        } catch {
            // TODO: "Обработать ошибку"
            print("Error add new tracker to category: \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        do {
            try self.trackerCategoryStore.deleteCategory(category)
        } catch {
            // TODO: "Обработать ошибку"
            print("Error delete category: \(error.localizedDescription)")
        }
    }
    
    func editCategory(category: TrackerCategory?, title: String) {
        do {
            try self.trackerCategoryStore.editCaregory(category: category, title: title)
        } catch {
            // TODO: "Обработать ошибку"
            print("Error edit category: \(error.localizedDescription)")
        }
    }
    
    func selectCategory(_ index: Int) {
        self.selectedCategory = self.categories[index]
    }
    
    func checkingSavedCategory(_ title: String) -> Bool {
        return categories.contains(where: { $0.title == title })
    }
}
// MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func categoryStore() {
        self.categories = trackerCategoryStore.trackerCategories
    }
}
