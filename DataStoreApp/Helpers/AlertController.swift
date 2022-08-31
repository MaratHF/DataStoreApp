//
//  AlertController.swift
//  DataStore
//
//
//  Created by MAC  on 29.08.2022.
//

import UIKit

extension UIAlertController {
    
    static func createAlertController() -> UIAlertController {
        UIAlertController(title: "Изменение файла", message: "Укажите имя файла", preferredStyle: .alert)
    }
    
    func action(file: File?, folderFile: FileInFolder?, completion: @escaping (String) -> Void) {
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newValue = self.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            completion(newValue)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        addAction(saveAction)
        addAction(cancelAction)
        addTextField { textField in
            textField.text = file != nil ? file?.name : folderFile?.name
        }
    }
}
