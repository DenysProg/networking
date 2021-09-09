//
//  UsersTableViewCell.swift
//  networking
//
//  Created by Denys Nikolaichuk on 17.08.2021.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    func configure (_ user: User ) {
        self.userView.layer.cornerRadius = 8
        self.nameLabel.text = user.name
        self.usernameLabel.text = user.username
        self.emailLabel.text = user.email
        self.phoneLabel.text = user.phone
        self.websiteLabel.text = user.website
    }
}
