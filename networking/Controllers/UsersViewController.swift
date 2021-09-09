//
//  UsersViewController.swift
//  networking
//
//  Created by Denys Nikolaichuk on 02.08.2021.
//

import UIKit

class UsersViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            let nib = UINib(nibName: "UsersTableViewCell", bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: "UserCellId")
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var networking = NetworkManager()
    private let dataManager = DataManager()
    var coordinator: MainCoordinator?
    
    private var plusBarButton: UIBarButtonItem?
    private var refreshControl = UIRefreshControl()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonConfig()
        getUserInfo()
    }
    
    private func getUserInfo() {
        activityIndicator.startAnimating()
        dataManager.getAllUsers { users in
            self.users = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
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
        getUserInfo()
        self.refreshControl.endRefreshing()
    }
    
    @objc func addButtonTapped() {
        coordinator?.addUser(with: self)
    }
    
    private func removeUser(_ indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.users.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func updateUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            self.users[index] = user
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    private func saveUser(_ user: User) {
        self.users.append(user)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - Table view data source
extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count == 0 {
            tableView.setEmptyView(title: "You don't have any user.", message: "Your users will be in here.")
            self.activityIndicator.stopAnimating()
        } else {
            tableView.restore()
        }
        
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCellId", for: indexPath) as? UsersTableViewCell {
            
            let usersInfo = users[indexPath.row]
            cell.configure(usersInfo)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.showPost(indexPath, users: users)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _, _, complitionHandler in
            let currentUser = self.users[indexPath.row]
            
            self.networking.delete(currentId: currentUser.id, currentUser) { _ in
                self.removeUser(indexPath)
            }
            complitionHandler(true)
        }
        
        let edit = UIContextualAction(style: .destructive, title: "Edit") { _, _, complitionHandler in
            self.coordinator?.editUser(self.users[indexPath.row], with: self)
            complitionHandler(true)
        }
        
        edit.backgroundColor = .black
        delete.backgroundColor = .red
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}

extension UsersViewController: AddUserViewControllerDelegate {
    func didFinishUpdateCreate(_ user: User) {
        if users.contains(where: { $0.id == user.id }) {
            updateUser(user)
        } else {
            saveUser(user)
        }
    }
}
