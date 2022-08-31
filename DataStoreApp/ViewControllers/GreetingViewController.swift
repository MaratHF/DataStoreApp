//
//  GreetingViewController.swift
//  DataStore
//
//  Created by MAC  on 29.08.2022.
//

import UIKit

class GreetingViewController: UIViewController {
    
    private var label: UILabel!
    private var textFiled: UITextField!
    private var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .gray
        setupSubviews()
        setConstraints()
    }
    
    private func setupSubviews() {
        label = UILabel()
        label.text = "Введите ваше имя"
        label.font = UIFont.systemFont(ofSize: 18)
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        
        textFiled = UITextField()
        textFiled.borderStyle = .roundedRect
        view.addSubview(textFiled)
        
        button = UIButton()
        view.addSubview(button)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Продолжить", for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
       
    }
    
    private func setConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        textFiled.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        textFiled.center = view.center
        NSLayoutConstraint.activate([
            textFiled.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textFiled.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textFiled.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            textFiled.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            label.bottomAnchor.constraint(equalTo: textFiled.topAnchor, constant: -40),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            button.topAnchor.constraint(equalTo: textFiled.bottomAnchor, constant: 40),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            
        ])
        
    }
    
    @objc private func buttonTapped() {
        if textFiled.text != nil, textFiled.text != "" {
            let navVC = UINavigationController(rootViewController: MainViewController(name: textFiled.text!))
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: true)
        }
    }
}

// MARK: - Keyboard
extension GreetingViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}
