//
//  AddUserViewController.swift
//  networking
//
//  Created by Denys Nikolaichuk on 17.08.2021.
//

import UIKit

protocol AddUserViewControllerDelegate: AnyObject {
    func didFinishUpdateCreate(_ user: User)
}

class AddUserViewController: UIViewController, Storyboarded {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var navigation: UINavigationItem!
    
    private var networking = NetworkManager()
    weak var coordinator: MainCoordinator?
    weak var delegate: AddUserViewControllerDelegate?
    
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        saveOrUpdateButton()
    }
    
    private func configureTextFields() {
        [nameTextField, usernameTextField, emailTextField].forEach({ $0?.addTarget(self, action: #selector(editingChanged), for: .editingChanged)})
        emailTextField.addTarget(self, action: #selector(checkValidation), for: .editingChanged)
    }
    
    private func saveOrUpdateButton() {
        if user != nil {
            saveButton.title = "Update"
            navigation.title = "Update User"
            
            if let currentUser = self.user {
                nameTextField.text = currentUser.name
                usernameTextField.text = currentUser.username
                emailTextField.text = currentUser.email
                phoneTextField.text = currentUser.phone
                websiteTextField.text = currentUser.website
            }
        } else {
            DispatchQueue.main.async {
                self.saveButton.isEnabled = false
                self.saveButton.title = "Save"
                self.navigation.title = "Save User"
            }
        }
    }
    
    @objc func didEndEditingField(){
        self.view.endEditing(true)
    }
    
    func configureUser(_ user: User) {
        self.user = user
    }
    
    @objc func checkValidation(_ textField: UITextField) {
        if  textField.text!.isValidEmail {
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 4
            let lighterGrayColor = UIColor(displayP3Red: 204, green: 204, blue: 204, alpha: 0)
            textField.layer.borderColor = lighterGrayColor.cgColor
            print("Email is valid")
        } else {
            print("Email is invalid")
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = 4
            textField.layer.borderColor = UIColor.red.cgColor
            saveButton.isEnabled = false
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        
        guard let name = nameTextField.text, !name.isEmpty,
              let userName = usernameTextField.text, !userName.isEmpty,
              let email = emailTextField.text, !email.isEmpty, email.isValidEmail
        else {
            self.saveButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
    }
    
    private func saveUser() {
        if let name = nameTextField.text,
           let usarename = usernameTextField.text,
           let email = emailTextField.text,
           let phone = phoneTextField.text,
           let website = websiteTextField.text {
            let newUser = User(id: Int.random(in: 11..<6000), name: name, username: usarename, email: email, phone: phone, website: website)
            let alert = UIAlertController(title: "User creation", message: "Your user is creating...", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            networking.create(chooseApi: .users, model: newUser, decodingType: User.self) { serverUser, serverError in
                DispatchQueue.main.async {
                    alert.dismiss(animated: true) {
                        if serverError != nil {
                            let alert = UIAlertController(title: "Server error", message: "Please try again later", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                            
                        newUser.id = serverUser.id
                        self.delegate?.didFinishUpdateCreate(newUser)
                        self.coordinator?.returnBack()
                    }
                }
            }
        }
    }
    
    private func updateUser() {
        didEndEditingField()
        if let name = nameTextField.text,
           let usarename = usernameTextField.text,
           let email = emailTextField.text,
           let phone = phoneTextField.text,
           let website = websiteTextField.text {
            if let userId = user?.id {
                let updateUser = User(id: userId, name: name, username: usarename, email: email, phone: phone, website: website)
                let alert = UIAlertController(title: "User updating", message: "Your user is updating...", preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                
                networking.edit(chooseApi: .users, currentId: updateUser.id, model: updateUser, decodingType: User.self) { serverUser, serverError in
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true) {
                            if serverError != nil {
                                let alert = UIAlertController(title: "Server error", message: "Please try again later", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            updateUser.id = serverUser.id
                            self.delegate?.didFinishUpdateCreate(updateUser)
                            self.coordinator?.returnBack()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        if user == nil {
            saveUser()
        } else {
            updateUser()
        }
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        coordinator?.returnBack()
    }
}
