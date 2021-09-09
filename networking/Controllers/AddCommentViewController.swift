//
//  AddCommentViewController.swift
//  networking
//
//  Created by Denys Nikolaichuk on 19.08.2021.
//

import UIKit

protocol AddCommentsViewControllerDelegate: AnyObject {
    func didFinishUpdateCreate(_ comment: Comment)
}

class AddCommentViewController: UIViewController, Storyboarded {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextField!
    @IBOutlet weak var navigator: UINavigationItem!
    
    weak var delegate: AddCommentsViewControllerDelegate?
    private var networking = NetworkManager()
    weak var coordinator: MainCoordinator?
    private var comment: Comment?
    private var comments = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        saveOrUpdateButton()
    }
    
    private func configureTextFields() {
        emailTextField.layer.borderColor = UIColor.red.cgColor
        self.saveButton.isEnabled = false
        [nameTextField, emailTextField, bodyTextField].forEach({ $0?.addTarget(self, action: #selector(editingChanged), for: .editingChanged) })
        emailTextField.addTarget(self, action: #selector(checkValidation), for: .editingChanged)
    }
    
    private func saveOrUpdateButton() {
        if comment != nil {
            self.saveButton.title = "Update"
            self.navigator.title = "Update Comment"
            
            if let currentComment = comment {
                self.nameTextField.text = currentComment.name
                self.emailTextField.text = currentComment.email
                self.bodyTextField.text = currentComment.body
            } else {
                DispatchQueue.main.async {
                    self.saveButton.title = "Save"
                    self.navigator.title = "Save Comment"
                }
            }
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " "  {
                textField.text = ""
                return
            }
        }
        
        guard let name = nameTextField.text, !name.isEmpty,
              let body = bodyTextField.text, !body.isEmpty,
              let email = emailTextField.text, !email.isEmpty, email.isValidEmail
        else {
                self.saveButton.isEnabled = false
                return
        }
        
        saveButton.isEnabled = true
    }
    
    @objc func didEndEditingField(){
        self.view.endEditing(true)
    }
    
    @objc func checkValidation(_ textField: UITextField) {
        if textField.text!.isValidEmail {
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
        }
    }
    
    func configureComments(_ comment: Comment) {
        self.comment = comment
    }
    
    private func saveComment() {
        let alert = UIAlertController(title: "Comment creation", message: "Your comment is creating...", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        if let name = nameTextField.text,
           let email = emailTextField.text,
           let body = bodyTextField.text {
            let newComment = Comment(id: comments.count + 1, name: name, email: email, body: body)
            
            networking.create(chooseApi: .comments, model: newComment, decodingType: Comment.self) { serverComment, serverError in
                DispatchQueue.main.async {
                    alert.dismiss(animated: true) {
                        if serverError != nil {
                            let alert = UIAlertController(title: "Server error", message: "Please try again later", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        }
                        newComment.id = serverComment.id
                        self.delegate?.didFinishUpdateCreate(newComment)
                        self.coordinator?.returnBack()
                    }
                }
            }
        }
    }
    
    private func updateComment() {
        didEndEditingField()
        let alert = UIAlertController(title: "Comment updating", message: "Your comment is updating...", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        if let name = nameTextField.text,
           let email = emailTextField.text,
           let body = bodyTextField.text {
            if let commentId = comment?.id {
                let updateComment = Comment(id: commentId, name: name, email: email, body: body)
                
                networking.edit(chooseApi: .comments, currentId: updateComment.id, model: updateComment, decodingType: Comment.self) { serverComment, serverError in
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true) {
                            if serverError != nil {
                                let alert = UIAlertController(title: "Server error", message: "Please try again later", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            updateComment.id = serverComment.id
                            self.delegate?.didFinishUpdateCreate(updateComment)
                            self.coordinator?.returnBack()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        if comment == nil {
            saveComment()
        } else {
            updateComment()
        }
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        coordinator?.returnBack()
    }
}
