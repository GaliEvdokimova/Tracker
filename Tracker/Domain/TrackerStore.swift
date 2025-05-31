//
//  TrackerStore.swift
//  Tracker
//
//  Created by Galina evdokimova on 18.05.2025.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidTitle
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedule
    case decodingErrorInvalid
    case decodingErrorInvalidFetchTracker
}

protocol TrackerStoreDelegate: AnyObject {
    func store()
}

final class TrackerStore: NSObject {
    // MARK: - Public Properties
    weak var delegate: TrackerStoreDelegate?
    var trackers: [Tracker] {
        guard
            let objects = self.fetchedResultsController.fetchedObjects,
            let trackers = try? objects.map({ try self.tracker(from: $0) })
        else { return [] }
        return trackers
    }
    // MARK: - Private Properties
    private let colorMarshalling = UIColorMarshalling()
    private let daysValueTransformer = DaysValueTransformer()
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        try? controller.performFetch()
        return controller
    }()
    // MARK: - Initializers
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.init()
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        fetchedResultsController.delegate = self
    }
    // MARK: - Public Methods
    func createTracker(_ tracker: Tracker) throws -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker)
        try context.save()
        return trackerCoreData
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData,
                               with tracker: Tracker
    ) {
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule as NSObject
    }
    
    func pinTracker(_ tracker: Tracker, value: Bool) throws {
        let pinTracker = try fetchTracker(with: tracker)
        guard let pinTracker = pinTracker else { return }
        pinTracker.pinned = value
        try context.save()
    }
    
    func deleteTracker(_ tracker: Tracker?) throws {
        let deleteTracker = try fetchTracker(with: tracker)
        guard let deleteTracker = deleteTracker else { return }
        context.delete(deleteTracker)
        try context.save()
    }
    
    func editTracker(_ tracker: Tracker, editingTracker: Tracker?) throws {
        let editTracker = try fetchTracker(with: editingTracker)
        guard let editTracker = editTracker else { return }
        editTracker.id = tracker.id
        editTracker.title = tracker.title
        editTracker.schedule = tracker.schedule as NSObject
        editTracker.emoji = tracker.emoji
        editTracker.pinned = tracker.pinned
        editTracker.color = colorMarshalling.hexString(from: tracker.color)
        try context.save()
    }
    
    func fetchTracker(with tracker: Tracker?) throws -> TrackerCoreData? {
        guard let tracker = tracker else {
            throw TrackerStoreError.decodingErrorInvalidFetchTracker
        }
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "id == %@",
            tracker.id as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
    }
    // MARK: - Private Methods
    private func tracker(from trackersCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackersCoreData.id else {
            throw TrackerStoreError.decodingErrorInvalidId
        }
        
        guard let title = trackersCoreData.title else {
            throw TrackerStoreError.decodingErrorInvalidTitle
        }
        
        guard let color = trackersCoreData.color else {
            throw TrackerStoreError.decodingErrorInvalidColor
        }
        
        guard let emoji = trackersCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidEmoji
        }
        
        guard let schedule = trackersCoreData.schedule else {
            throw TrackerStoreError.decodingErrorInvalidSchedule
        }
        let pinned = trackersCoreData.pinned
        
        return Tracker(
            id: id,
            title: title,
            color: colorMarshalling.color(from: color),
            emoji: emoji,
            schedule: schedule as! [WeekDay],
            pinned: pinned)
    }
}
// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        delegate?.store()
    }
}
