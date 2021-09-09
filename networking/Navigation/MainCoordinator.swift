//
//  MainCoordinator.swift
//  networking
//
//  Created by Denys Nikolaichuk on 17.08.2021.
//

import UIKit

protocol CoordinatorProtocol {
    var children: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    func start()
}

class MainCoordinator: CoordinatorProtocol {
    var children = [CoordinatorProtocol]()
    
    var navigationController: UINavigationController
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = UsersViewController.instantiate()
        viewController.coordinator = self
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func returnBack() {
        navigationController.popViewController(animated: true)
    }
    
    func addUser(with delegate: AddUserViewControllerDelegate) {
        let viewController = AddUserViewController.instantiate()
        viewController.coordinator = self
        viewController.delegate = delegate
        
        navigationController.show(viewController, sender: self)
    }
    
    func editUser(_ user: User, with delegate: AddUserViewControllerDelegate) {
        let viewController = AddUserViewController.instantiate()
        viewController.configureUser(user)
        viewController.delegate = delegate
        viewController.coordinator = self
        
        navigationController.show(viewController, sender: self)
    }
    
    func showPost(_ indexPath: IndexPath, users: [User]) {
        let viewController = PostsViewController.instantiate()
        viewController.coordinator = self
        viewController.configure(users[indexPath.row])
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func addPost(with delegate: AddPostViewControllerDelegate) {
        let viewController = AddPostsViewController.instantiate()
        viewController.coordinator = self
        viewController.delegate = delegate
        
        navigationController.show(viewController, sender: self)
    }
    
    func editPost(_ post: Post, with delegate: AddPostViewControllerDelegate) {
        let viewController = AddPostsViewController.instantiate()
        viewController.configurePost(post)
        viewController.delegate = delegate
        viewController.coordinator = self
        
        navigationController.show(viewController, sender: self)
    }
    
    func showComment(_ indexPath: IndexPath, posts: [Post]) {
        let viewController = CommentViewController.instantiate()
        viewController.coordinator = self
        viewController.configure(posts[indexPath.row])
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func addComment(with delegate: AddCommentsViewControllerDelegate) {
        let viewController = AddCommentViewController.instantiate()
        viewController.coordinator = self
        viewController.delegate = delegate
        
        navigationController.show(viewController, sender: self)
    }
    
    func editComments(_ comments: Comment, with delegate: AddCommentsViewControllerDelegate) {
        let viewController = AddCommentViewController.instantiate()
        viewController.configureComments(comments)
        viewController.delegate = delegate
        viewController.coordinator = self
        
        navigationController.show(viewController, sender: self)
    }
}
