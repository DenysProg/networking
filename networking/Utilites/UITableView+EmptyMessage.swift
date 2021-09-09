//
//  UITableView+EmptyMessage.swift
//  networking
//
//  Created by Denys Nikolaichuk on 18.08.2021.
//

import UIKit

extension UITableView {
    func setEmptyView(title: String, message: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let emptyIcon = UIImage(named: "ic_empty")
        let imageView = UIImageView(image: emptyIcon!)
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        let stackView   = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        messageLabel.textColor = UIColor.lightGray
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(imageView)
            
        
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.equalSpacing
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 16.0
            
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
            
        emptyView.addSubview(stackView)
            
        stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true

        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
        }
    }
    
    func restore() {
        self.backgroundView = nil
    }
}
