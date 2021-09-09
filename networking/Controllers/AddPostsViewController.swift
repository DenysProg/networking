//
//  AddPostsViewController.swift
//  networking
//
//  Created by Denys Nikolaichuk on 18.08.2021.
//

import UIKit

protocol AddPostViewControllerDelegate: AnyObject {
    func didFinishUpdateCreate(_ post: Post)
}

class AddPostsViewController: UIViewController, Storyboarded {
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextField!
    @IBOutlet weak var navigation: UINavigationItem!
    
    weak var delegate: AddPostViewControllerDelegate?
    private var networking = NetworkManager()
    weak var coordinator: MainCoordinator?
    private var post: Post?
    private var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        saveOrUpdateButton()
    }
    
    private func configureTextFields() {
        self.saveButton.isEnabled = false
        [titleTextField, bodyTextField].forEach({ $0?.addTarget(self, action: #selector(editingChanged), for: .editingChanged)})
    }
    
    private func saveOrUpdateButton() {
        if post != nil {
            saveButton.title = "Update"
            navigation.title = "Update Post"
            
            if let currentPost = post {
                titleTextField.text = currentPost.title
                bodyTextField.text = currentPost.body
            }
        } else {
                self.saveButton.title = "Save"
                self.navigation.title = "Add Post"
        }
    }
    
    @objc func didEndEditingField(){
        self.view.endEditing(true)
    }
    
    func configurePost(_ post: Post) {
        self.post = post
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        
        guard let name = titleTextField.text, !name.isEmpty,
              let userName = bodyTextField.text, !userName.isEmpty
        else {
            self.saveButton.isEnabled = false
            return
        }
        saveButton.isEnabled = true
    }
    
    private func savePost() {
        if let title = titleTextField.text,
           let body = bodyTextField.text {
            let newPost = Post(userId: posts.count + 1, title: title, body: body)
            
            let alert = UIAlertController(title: "Post creation", message: "Your post is creating...", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            
            networking.create(chooseApi: .posts, model: newPost, decodingType: Post.self) { serverPost, serverError in
                DispatchQueue.main.async {
                    alert.dismiss(animated: true) {
                        if serverError != nil {
                            let alert = UIAlertController(title: "Server error", message: "Please try again later", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        newPost.id = serverPost.id
                        self.delegate?.didFinishUpdateCreate(newPost)
                        self.coordinator?.returnBack()
                    }
                }
            }
        }
    }
    
    private func updatePost() {
        didEndEditingField()
        let alert = UIAlertController(title: "User updating", message: "Your user is updating...", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        if let title = titleTextField.text,
           let body = bodyTextField.text {
            if let postId = post?.id {
                let updatedPost = Post(userId: postId, title: title, body: body)
                
                networking.edit(chooseApi: .posts, currentId: updatedPost.userId, model: updatedPost, decodingType: Post.self) { serverPost, serverError in
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true) {
                            if serverError != nil {
                                let alert = UIAlertController(title: "Server error", message: "Please try again later", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            updatedPost.id = serverPost.id
                            self.delegate?.didFinishUpdateCreate(updatedPost)
                            self.coordinator?.returnBack()
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        coordinator?.returnBack()
    }
    
    @IBAction func saveOrUpdatePost(_ sender: UIBarButtonItem) {
        if post == nil {
            savePost()
        } else {
            updatePost()
        }
    }
}
