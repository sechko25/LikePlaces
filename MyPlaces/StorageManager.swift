//
//  StorageManager.swift
//  MyPlaces
//
//  Created by secha on 24.02.22.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }
    }
}
