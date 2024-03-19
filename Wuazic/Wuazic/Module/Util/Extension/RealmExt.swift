//
//  RealmExt.swift
//  SwiftyAds
//
//  Created by MinhNH on 11/04/2023.
//

import RealmSwift

extension Results {
    func toArray() -> [Element] {
        var array = [Element]()
        for item in self {
            array.append(item)
        }
        return array
    }
}
