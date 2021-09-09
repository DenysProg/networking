//
//  PostsViewController.swift
//  networking
//
//  Created by Denys Nikolaichuk on 18.08.2021.
//

import UIKit

class PostsViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
            let nib = UINib(nibName: "PostsTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "PostCellID")
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var networking = NetworkManager()
    private var posts = [Post]()
    private var user: User?
    weak var coordinator: MainCoordinator?
    private var plusBarButton: UIBarButtonItem?
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPostInfo()
        addButtonConfig()
    }
    
    private func addButtonConfig() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(named: "ic_plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            addButton.shake(values: [-12.0, 12.0, -12.0, 12.0, -6.0, 6.0, -3.0, 3.0, 0.0])
        }
        self.plusBarButton = UIBarButtonItem(customView: addButton)
        self.navigationItem.setRightBarButton(plusBarButton, animated: false)
        
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        getPostInfo()
        self.refreshControl.endRefreshing()
    }
    
    @objc func addButtonTapped() {
        coordinator?.addPost(with: self)
    }
    
    private func getPostInfo() {
        activityIndicator.startAnimating()
        if let id = user?.id {
            networking.getAllById(chooseApi: .posts, nameId: "userId", currentId: id, decodingType: [Post].self) { posts, error in
                DispatchQueue.main.async {
                    self.posts = posts ?? []
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
            }
            }
        }
    }
    
    func configure(_ user: User) {
        self.user = user
    }
    
    private func removePost(_ indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.posts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func savePost(_ post: Post) {
        self.posts.append(post)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func updatePost(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            self.posts[index] = post
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
}

extension PostsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.count == 0 {
            tableView.setEmptyView(title: "You don't have any post.", message: "Your posts will be in here.")
        }
        else {
            tableView.restore()
        }
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellID", for: indexPath) as? PostsTableViewCell {
            let post = posts[indexPath.row]
            cell.configure(post)
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showComment(indexPath, posts: posts)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, complitionHandler in
            let currentPost = self.posts[indexPath.row]
            
            self.networking.delete(currentId: currentPost.id, currentPost) { _ in
                self.removePost(indexPath)
            }
            
            complitionHandler(true)
        }
        
        let edit = UIContextualAction(style: .destructive, title: "Edit") { _, _, complitionHandler in
            self.coordinator?.editPost(self.posts[indexPath.row], with: self)
            complitionHandler(true)
        }
        
        edit.backgroundColor = .black
        delete.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}

extension PostsViewController: AddPostViewControllerDelegate {
    func didFinishUpdateCreate(_ post: Post) {
        if posts.contains(where: {$0.id == post.id})  {
            updatePost(post)
        } else  {
            savePost(post)
        }
    }
}
