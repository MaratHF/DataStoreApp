//
//  FoldersViewController.swift
//  DataStore
//
//  Created by MAC  on 28.08.2022.
//

import UIKit
import RealmSwift

class FoldersViewController: UITableViewController {
    
    let cellID = "folderCell"
    var folders = List<File>()
    var index = 0
    var delegate: FolderViewControllerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Выберете папку для перемещения"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        folders.insert(File(value: ["Файлы", "0", true]), at: 0)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        folders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = folders[indexPath.row].name
        content.image = UIImage(systemName: "folder")
        cell.contentConfiguration = content
        
        return cell
    }
   
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let folder = folders[indexPath.row]
        delegate.selectFolder(folder: folder, index: index)
        dismiss(animated: true)
    }
}
