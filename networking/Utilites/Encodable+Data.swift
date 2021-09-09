//
//  Encodable+Data.swift
//  networking
//
//  Created by Denys Nikolaichuk on 18.08.2021.
//

import Foundation

extension Encodable {
    func toJSONData() -> Data? { try? JSONEncoder().encode(self) }
}
