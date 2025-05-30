//
//  AppDelegate.swift
//  Tracker
//
//  Created by Galina evdokimova on 22.03.2025.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        DaysValueTransformer.register()
        let configuration = AppMetricaConfiguration(apiKey: "API key")
            AppMetrica.activate(with: configuration!)
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // TODO: Заменить на реализацию кодом обработку ошибки:
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback() // откат изменений
                let nserror = error as NSError
                // TODO: Заменить на реализацию кодом обработку ошибки:
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
