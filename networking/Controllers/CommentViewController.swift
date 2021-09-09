//
//  CommentViewController.swift
//  networking
//
//  Created by Denys Nikolaichuk on 19.08.2021.
//

import UIKit

class CommentViewController: UIViewController, Storyboarded {
 
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            let nib = UINib(nibName: "CommentsTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "CommentsCellID")
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var coordinator: MainCoordinator?
    private let networking = NetworkManager()
    private var comments = [Comment]()
    private var post: Post?
    private var plusBarButton: UIBarButtonItem?
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCommentsInfo()
        addButtonConfig()
    }
    
    func getCommentsInfo() {
        activityIndicator.startAnimating()
        if let id = post?.id {
            networking.getAllById(chooseApi: .comments, nameId: "postId", currentId: id, decodingType: [Comment].self) { comment, error in
                DispatchQueue.main.async {
                    self.comments = comment ?? []
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
        
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
        getCommentsInfo()
        self.refreshControl.endRefreshing()
    }
    
    @objc func addButtonTapped() {
        coordinator?.addComment(with: self)
    }
    
    func configure(_ post: Post) {
        self.post = post
    }
    
    private func removePost(_ indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.comments.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func updateComments(_ comment: Comment) {
        if let index = comments.firstIndex(where: { $0.id == comment.id }) {
            self.comments[index] = comment
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    private func saveComments(_ comment: Comment) {
        self.comments.append(comment)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCellID", for: indexPath) as? CommentsTableViewCell {
            let commentInfo = comments[indexPath.row]
            cell.configure(commentInfo)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, complitionHandler in
            let currentComments = self.comments[indexPath.row]
            
            self.networking.delete(currentId: currentComments.id, currentComments) { _ in
                self.removePost(indexPath)
            }
            
            complitionHandler(true)
        }
        
        let edit = UIContextualAction(style: .destructive, title: "Edit") { _, _, complitionHandler in
            self.coordinator?.editComments(self.comments[indexPath.row], with: self)
            complitionHandler(true)
        }
        
        edit.backgroundColor = .black
        delete.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}

extension CommentViewController: AddCommentsViewControllerDelegate {
    func didFinishUpdateCreate(_ comment: Comment) {
        if comments.contains(where: { $0.id == comment.id }) {
            updateComments(comment)
        } else {
            saveComments(comment)
        }
    }
}
