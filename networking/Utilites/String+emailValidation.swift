//
//  String+emailValidation.swift
//  networking
//
//  Created by Denys Nikolaichuk on 17.08.2021.
//

import UIKit

extension String {
    var isValidEmail: Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}
