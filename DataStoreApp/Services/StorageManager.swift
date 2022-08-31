//
//  File.swift
//  DataStore
//
//  Created by MAC  on 29.08.2022.
//

import Foundation
import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    let realm = try! Realm()
    
    private init() {}
    
    func addNewUser(user: User) {
        try! realm.write {
            realm.add(user)
        }
    }
    
    func addNewFile(user: User, file: File) {
        try! realm.write {
            user.files.append(file)
        }
    }
    
    func addNewFileInFolder(user: User, file: FileInFolder, ID: String) {
        try! realm.write {
            let folder = user.files.where({ $0.urlOrID == ID }).first
            folder?.folderFiles.append(file)
        }
    }
    
    func saveFilesInFolder(user: User, files: List<FileInFolder>, ID: String) {
        try! realm.write {
            let file = user.files.where({ $0.urlOrID == ID }).first!
            file.folderFiles = files
        }
    }
    
    func deleteFile(user: User, index: Int) {
        try! realm.write {
            user.files.remove(at: index)
        }
    }
    
    func deleteFileFromFolder(user: User, index: Int, ID: String) {
        try! realm.write {
            let folder = user.files.where({ $0.urlOrID == ID }).first!
            folder.folderFiles.remove(at: index)
        }
    }
    
    func changeFileName(user: User, index: Int, name: String) {
        try! realm.write {
            user.files[index].name = name
        }
    }
    
    func changeFolderFileName(user: User, index: Int, name: String, ID: String) {
        try! realm.write {
            let folder = user.files.where({ $0.urlOrID == ID }).first!
            folder.folderFiles[index].name = name
        }
    }
}
