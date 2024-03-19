//
//  ReuseableViewExt.swift
//  SwiftyAds
//
//  Created by MinhNH on 03/04/2023.
//

import UIKit

// MARK: - UICollectionView
extension UICollectionView {
    func registerItem<T: UICollectionViewCell>(cell: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.identifier)
    }
    
    func registerItemNib<T: UICollectionViewCell>(cell: T.Type) {
        let nib = UINib(nibName: T.identifier, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.identifier)
    }
    
    func registerItem<T: UICollectionReusableView>(header: T.Type) {
        register(T.self,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: T.identifier)
    }
    
    func registerItemNib<T: UICollectionReusableView>(header: T.Type) {
        let nib = UINib(nibName: T.identifier, bundle: nil)
        register(nib,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                 withReuseIdentifier: T.identifier)
    }
    
    func registerItemNib<T: UICollectionReusableView>(footer: T.Type) {
        let nib = UINib(nibName: T.identifier, bundle: nil)
        register(nib,
                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                 withReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
        return cell
    }
    
    func dequeueHeader<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        let header = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                      withReuseIdentifier: T.identifier,
                                                      for: indexPath) as! T
        return header
    }
}

extension UICollectionViewCell { }

extension UICollectionReusableView {
    static var identifier: String {
        return String(describing: self)
    }
}

// MARK: - UITableView
extension UITableView {
    func registerItem<T: UITableViewCell>(cell: T.Type) {
        register(T.self, forCellReuseIdentifier: T.identifier)
    }
    
    func registerItemNib<T: UITableViewCell>(cell: T.Type) {
        let nib = UINib(nibName: T.identifier, bundle: nil)
        register(nib, forCellReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let cell = dequeueReusableCell(withIdentifier: T.identifier) as! T
        return cell
    }
}

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
