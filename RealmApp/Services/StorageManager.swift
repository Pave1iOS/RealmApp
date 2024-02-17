//
//  StorageManager.swift
//  RealmApp
//
//  Created by Alexey Efimov on 08.10.2021.
//  Copyright © 2021 Alexey Efimov. All rights reserved.
//

import Foundation
import RealmSwift

final class StorageManager {
    static let shared = StorageManager()
    
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
    }
    
    // MARK: - Task List
    func fetchData<T>(_ type: T.Type) -> Results<T> where T: RealmFetchable {
        realm.objects(T.self)
    }
    
    func save(_ taskLists: [TaskList]) {
        write {
            realm.add(taskLists)
        }
    }
    
    func save(_ taskList: String, completion: (TaskList) -> Void) {
        write {
            let taskList = TaskList(value: [taskList])
            realm.add(taskList)
            completion(taskList)
        }
    }
    
    func delete(taskList: TaskList? = nil, task: Task? = nil) {
        
        write {
            if taskList != nil {
                realm.delete(taskList?.tasks ?? List<Task>())
                realm.delete(taskList ?? TaskList())
            } else if task != nil {
                realm.delete(task ?? Task())
            }
        }
    }
    
    func edit(
        taskList: TaskList? = nil,
        task: Task? = nil,
        newTitle: String? = nil,
        newNote: String? = nil
    ) {
        write {
            if taskList != nil {
                taskList?.title = newTitle ?? ""
            } else if task != nil {
                task?.title = newTitle ?? ""
                task?.note = newNote ?? ""
            }
        }
    }

    func done(taskList: TaskList? = nil, task: Task? = nil) {
        write {
            taskList?.tasks.setValue(true, forKey: "isComplete")
        }
    }

    // MARK: - Tasks
    func save(_ task: String, withNote note: String, to taskList: TaskList, completion: (Task) -> Void) {
        write {
            let task = Task(value: [task, note])
            taskList.tasks.append(task)
            completion(task)
        }
    }
    
    // MARK: - Private methods
    private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
}
