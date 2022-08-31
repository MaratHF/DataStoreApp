//
//  MianViewController.swift
//  DataStore
//
//  Created by MAC  on 25.08.2022.
//

import UIKit
import UniformTypeIdentifiers
import QuickLook
import RealmSwift

protocol FolderViewControllerProtocol {
    func selectFolder(folder: File, index: Int)
}

class MainViewController: UITableViewController {
    
    var userName: String
    var files = List<File>()
    var user = User()
    var folderID = ""
    var list = List<FileInFolder>()
    var folders = List<File>()
    private let cellID = "cell"
    private var userData: Results<User>!
    private let defaultUrl = Bundle.main.url(forResource: "error", withExtension: ".jpeg")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userData = StorageManager.shared.realm.objects(User.self).where({ $0.name == userName })
        print()
        if userData.isEmpty {
            user.name = userName
            StorageManager.shared.addNewUser(user: user)
            files = user.files
        } else {
            user = userData.first!
            files = userData.first!.files
        }
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func setEditing (_ editing: Bool, animated: Bool)
    {
       super.setEditing(editing, animated: animated)
       self.editButtonItem.title = editing ? "Готово" : "Править"
     }
    
    init(name: String) {
        self.userName = name
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        files.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let file = files[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        if file.isItFolder {
            content.image = UIImage(systemName: "folder")
        } else {
            content.image = UIImage(systemName: "doc")
        }
        content.text = file.name
        cell.contentConfiguration = content

        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let folderContentVC = FolderContentViewController(name: userName)
        let file = files[indexPath.row]
        
        if file.isItFolder {
            let folders = files.where({ $0.isItFolder == true })
            folderContentVC.name = file.name
            folderContentVC.folderID = file.urlOrID
            folderContentVC.list = file.folderFiles
            folderContentVC.folders = convertResultsToList(results: folders)
           
            navigationController?.pushViewController(folderContentVC, animated: true)
        } else {
            let quickLookVC = QLPreviewController()
            quickLookVC.dataSource = self
            let fileUrl = getFileUrl()
            
            if QLPreviewController.canPreview(fileUrl as QLPreviewItem) {
                quickLookVC.currentPreviewItemIndex = indexPath.row
                navigationController?.pushViewController(quickLookVC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            if self.folderID == "" {
                StorageManager.shared.deleteFile(user: self.user, index: indexPath.row)
            } else {
                StorageManager.shared.deleteFileFromFolder(user: self.user, index: indexPath.row, ID: self.folderID)
                self.files = self.convertFolderInFile(filesInFolder: self.list)
            }
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let moveAction = UIContextualAction(style: .normal, title: "Переместить") { _, _, isDone in
            self.moveFile(index: indexPath.row)
            isDone(true)
        }
        
        let changeNameAction = UIContextualAction(style: .normal, title: "Переименовать") { _, _, isDone in
            if self.folderID == "" {
                self.showAlert(file: self.files[indexPath.row], folderFile: nil, indexPath: indexPath)
            } else {
                self.showAlert(file: nil, folderFile: self.list[indexPath.row], indexPath: indexPath)
            }
            isDone(true)
        }
        
        moveAction.backgroundColor = .blue
        changeNameAction.backgroundColor = .purple
        
        if files[indexPath.row].isItFolder {
            return UISwipeActionsConfiguration(actions: [deleteAction, changeNameAction])
        } else {
            return UISwipeActionsConfiguration(actions: [deleteAction, changeNameAction, moveAction])
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    // MARK: - Public methods
    
    func convertFolderInFile(filesInFolder: List<FileInFolder>) -> List<File> {
        let files = List<File>()
        for item in filesInFolder {
            let file = File(value: [item.name, item.url])
            files.append(file)
        }
        return files
    }
    
    func setupNavigationBar() {
        title = "ФАЙЛЫ"
        
        // Разобраться как написать [weak self]
        let importFromGallery = UIAction(title: "Загрузить из галереи", identifier: UIAction.Identifier(rawValue: "ImportFromGallery"),
                     handler: { _ in
                self.importFromGallery()
            })
        let importFromICloud = UIAction(title: "Загрузить из iCloud", identifier: UIAction.Identifier(rawValue: "ImportFromICloud"), handler: { _ in
                self.importFromICloud()
            })
        let newFolder = UIAction(title: "Новая папка", identifier: UIAction.Identifier("newFolder"), handler: { _ in
                self.newFolder()
            })
        
        let editButton = editButtonItem
        editButton.title = "Править"
        var menu = UIMenu(children: [])
        if folderID == "" {
            menu = UIMenu(children: [importFromGallery, importFromICloud, newFolder])
        } else {
            menu = UIMenu(children: [importFromGallery, importFromICloud])
        }
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle.fill") , menu: menu), editButtonItem]
    }
    
    func importFromGallery() {
        let vc = UIImagePickerController()
        vc.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = false
        
        present(vc, animated: true)
    }
    
    func importFromICloud() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }

    // MARK: - Private methods
    
    private func setupView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
    }
    
    private func newFolder() {
        let folderKey = UUID().uuidString
        var name = "Новая папка"
        
        let folders = files.where({ $0.isItFolder == true })
        if !folders.where({ $0.name == name }).isEmpty {
            var count = 1
            for item in folders {
                let num = item.name.last?.wholeNumberValue ?? 0
                if num >= count {
                    count = num + 1
                }
            }
            name += " \(count)"
        }
        
        let newFolder = File(value: [name, folderKey, true])
        StorageManager.shared.addNewFile(user: user, file: newFolder)
        tableView.reloadData()
    }
    
    private func moveFile(index: Int) {
        let foldersVC = FoldersViewController()
        if folderID == "" {
            let list = files.where({ $0.isItFolder == true })
            foldersVC.folders = convertResultsToList(results: list)
        } else {
            foldersVC.folders = folders
        }
        foldersVC.delegate = self
        foldersVC.index = index
        let navVC = UINavigationController(rootViewController: foldersVC)
        navVC.modalPresentationStyle = .fullScreen
        present(navVC, animated: true)
    }
    
    private func convertResultsToList(results: Results<File>) -> List<File> {
        results.reduce(List<File>()) { (list, element) -> List<File> in
            list.append(element)
            return list
        }
    }
    
    private func getFileName(fileUrl: URL) -> (fileName: String, fileExtension: String) {
        let fileURLParts = fileUrl.absoluteString.components(separatedBy: "/")
        let fileName = fileURLParts.last
        let fileExtension = fileName?.components(separatedBy: ".").last
        return (fileName ?? "Неизвествный файл", fileExtension ?? "")
    }
    
    private func getFileUrl() -> URL {
        guard let indexPath = tableView.indexPathForSelectedRow else { return defaultUrl }
        let url = files[indexPath.row].urlOrID
        let fileUrl = URL(string: url) ?? defaultUrl
        return fileUrl
    }
    
    private func sizePerMB(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    
    private func presentAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Ошибка загрузки",
                message: "Ваш файл имеет формат .txt, либо его размер превышает 20 мб.",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}
// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var fileUrl = defaultUrl
        
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            fileUrl = url
        } else if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            fileUrl = url
        }
        
        let fileExtension = getFileName(fileUrl: fileUrl).fileExtension
        
        if sizePerMB(url: fileUrl) < 20.0 || fileExtension == ".txt" {
            let name = getFileName(fileUrl: fileUrl)
            
            if folderID == "" {
                let file = File(value: [name.fileName, fileUrl.absoluteString])
                StorageManager.shared.addNewFile(user: user, file: file)
            } else {
                let file = FileInFolder(value: [name.fileName, fileUrl.absoluteString])
                StorageManager.shared.addNewFileInFolder(user: user, file: file, ID: folderID)
                
                files = convertFolderInFile(filesInFolder: list)
            }
            
            picker.dismiss(animated: true)
            tableView.reloadData()
        } else {
            picker.dismiss(animated: true)
            presentAlert()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


// MARK: - FolderViewControllerProtocol
extension MainViewController: FolderViewControllerProtocol {
    func selectFolder(folder: File, index: Int) {
        let file = files[index]
        
        var folderForSave = File()
        
        if folder.urlOrID == "0" {
            StorageManager.shared.addNewFile(user: user, file: file)
        } else {
            if folderID == "" {
                folderForSave = files.where({ $0.urlOrID == folder.urlOrID }).first!
            } else {
                folderForSave = folders.filter({ $0.urlOrID == folder.urlOrID }).first!
            }
            
            StorageManager.shared.addNewFileInFolder(
                user: user,
                file: FileInFolder(value: [file.name, file.urlOrID]),
                ID: folderForSave.urlOrID
            )
        }
        
        
        if folderID == "" {
            StorageManager.shared.deleteFile(user: user, index: index)
        } else {
            StorageManager.shared.deleteFileFromFolder(user: user, index: index, ID: folderID)
            files = convertFolderInFile(filesInFolder: list)
        }
        
        tableView.reloadData()
    }
}
// MARK: - FolderViewControllerProtocol
extension MainViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileUrl = urls.first else { return }
        let fileExtension = getFileName(fileUrl: fileUrl).fileExtension
        
        if sizePerMB(url: fileUrl) < 20.0 || fileExtension == ".txt" {
            let name = getFileName(fileUrl: fileUrl)
            
            if fileUrl.startAccessingSecurityScopedResource() {
                if folderID == "" {
                    let file = File(value: [name.fileName, fileUrl.absoluteString])
                    StorageManager.shared.addNewFile(user: user, file: file)
                } else {
                    let file = FileInFolder(value: [name.fileName, fileUrl.absoluteString])
                    StorageManager.shared.addNewFileInFolder(user: user, file: file, ID: folderID)
                    
                    files = convertFolderInFile(filesInFolder: list)
                }
            }
            fileUrl.stopAccessingSecurityScopedResource()
            tableView.reloadData()
        } else {
            presentAlert()
        }
    }
}
// MARK: - FolderViewControllerProtocol
extension MainViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        files.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = URL(string: files[index].urlOrID) ?? defaultUrl
        return url as QLPreviewItem
    }
}
// MARK: - Alert Controller
extension MainViewController {
    private func showAlert(file: File?, folderFile: FileInFolder?, indexPath: IndexPath) {
       
        let alert = UIAlertController.createAlertController()
        
        alert.action(file: file, folderFile: folderFile) { fileName in
            if file != nil {
                StorageManager.shared.changeFileName(
                    user: self.user,
                    index: indexPath.row,
                    name: fileName
                )
            } else {
                StorageManager.shared.changeFolderFileName(
                    user: self.user,
                    index: indexPath.row,
                    name: fileName,
                    ID: self.folderID
                )
                self.files = self.convertFolderInFile(filesInFolder: self.list)
            }
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        present(alert, animated: true)
    }
}






















