//
//  PostsTableViewCell.swift
//  networking
//
//  Created by Denys Nikolaichuk on 18.08.2021.
//

import UIKit

class PostsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var bodyLabe: UILabel!
    @IBOutlet weak var postsView: UIView!
    
    func configure(_ post: Post) {
        self.postsView.layer.cornerRadius = 8
        self.titleLable.text = post.title
        self.bodyLabe.text = post.body
    }
}
