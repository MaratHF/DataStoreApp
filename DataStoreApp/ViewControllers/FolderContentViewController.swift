//
//  FolderContentViewController.swift
//  DataStore
//
//  Created by MAC  on 26.08.2022.
//

import UIKit
import RealmSwift

class FolderContentViewController: MainViewController {
    
    var name = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        files = convertFolderInFile(filesInFolder: list)
        title = name
        tableView.reloadData()
    }
    
    private func convertFileInFolder(files: List<File>) -> List<FileInFolder> {
        let filesInFolder = List<FileInFolder>()
        for item in files {
            let fileInFolder = FileInFolder(value: [item.name, item.urlOrID])
            filesInFolder.append(fileInFolder)
        }
        return filesInFolder
    }
}
