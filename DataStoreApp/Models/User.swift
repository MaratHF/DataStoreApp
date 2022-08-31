//
//  User.swift
//  DataStore
//
//  Created by MAC  on 29.08.2022.
//

import Foundation
import RealmSwift

class User: Object {
    @Persisted var name = ""
    @Persisted var files = List<File>()
}

class File: Object {
    @Persisted var name = ""
    @Persisted var urlOrID = ""
    @Persisted var isItFolder = false
    @Persisted var folderFiles = List<FileInFolder>()
}

class FileInFolder: Object {
    @Persisted var name = ""
    @Persisted var url = ""
}
