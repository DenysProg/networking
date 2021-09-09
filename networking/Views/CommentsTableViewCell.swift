//
//  CommentsTableViewCell.swift
//  networking
//
//  Created by Denys Nikolaichuk on 19.08.2021.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var commentsView: UIView!
    
    
    func configure(_ coment: Comment) {
        self.commentsView.layer.cornerRadius = 8
        self.nameLabel.text = coment.name
        self.emailLabel.text = coment.email
        self.bodyLabel.text = coment.body
    }
}
