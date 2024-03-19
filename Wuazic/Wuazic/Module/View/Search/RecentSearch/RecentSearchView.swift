//
//  RecentSearchView.swift
//  SwiftyAds
//
//  Created by MinhNH on 11/04/2023.
//

import UIKit
import GoogleMobileAds
import AppLovinSDK

enum RecentSearchType {
    case history
    case suggest
}

class RecentSearchView: BaseView {
    
    fileprivate let _column: CGFloat = UIDevice.current.isiPhone ? 3 : 6
    fileprivate var _type: RecentSearchType = .history
    fileprivate var _terms: [String] = []
    fileprivate var _textHeader: String = ""
    fileprivate var _heightPlayerMini: CGFloat = 0
    var heightPlayerMini: CGFloat {
        set {
            if _heightPlayerMini != newValue {
                listCollectionView.reloadData()
            }
            _heightPlayerMini = newValue
        }
        get {
            return _heightPlayerMini
        }
    }
    
    var genres: [GenreObject] = [] { didSet { listCollectionView.reloadData() } }
    var onSearch: ((String) -> Void)?
    var onOpenGenre: ((GenreObject) -> Void)?
    
    var admobAd: GADNativeAd?
    var applovinAdView: MANativeAdView?
    
    // MARK: - properties
    fileprivate let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerItem(cell: AdmobNativeAdCell.self)
        view.registerItem(cell: AppLovinNativeAdCell.self)
        view.registerItem(cell: SearchTermHistoryCell.self)
        view.registerItem(cell: SearchSuggestCell.self)
        view.registerItem(cell: GenreItemCell.self)
        view.registerItem(header: RecentSearchHeaderView.self)
        view.registerItem(header: GenreHeaderView.self)
        return view
    }()
    
    // MARK: - initial
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.drawUIs()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.drawUIs()
    }
    
    // MARK: - private
    private func drawUIs() {
        backgroundColor = .clear
        
        addSubview(listCollectionView)
        
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        listCollectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        listCollectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        listCollectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
    }
    
    func setAdView(admobAd: GADNativeAd?, applovinAdView: MANativeAdView?) {
        self.admobAd = admobAd
        self.applovinAdView = applovinAdView
        self.listCollectionView.reloadData()
    }
    
    // MARK: - public
    func setType(_ type: RecentSearchType, _ terms: [String] = []) {
        self._type = type
        
        if self._type == .history {
            self._textHeader = "Recent search"
            self._terms = RecentSearchService.shared.data
            self.listCollectionView.reloadData()
        }
        else {
            self._textHeader = "Suggest for your"
            self._terms = terms
            self.listCollectionView.reloadData()
        }
    }
    
    fileprivate func clearAllHistory() {
        if self._type == .history {
            RecentSearchService.shared.truncate()
            self._terms = RecentSearchService.shared.data
            self.listCollectionView.reloadData()
        }
    }
    
    // MARK: - event
    
}

extension RecentSearchView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self._type == .history {
            return 3
        }
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return admobAd != nil || applovinAdView != nil ? 1 : 0
        }
        
        if self._type == .history {
            if section == 1 {
                return _terms.count
            }
            else {
                return genres.count
            }
        }
        return _terms.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            if admobAd != nil {
                let cell: AdmobNativeAdCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.nativeAd = admobAd
                return cell
            }
            else if applovinAdView != nil {
                let cell: AppLovinNativeAdCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.nativeAd = applovinAdView
                return cell
            }
            else {
                return UICollectionViewCell()
            }
        } else {
            if self._type == .history {
                if indexPath.section == 1 {
                    let cell: SearchTermHistoryCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                    cell.term = _terms[indexPath.row]
                    return cell
                }
                else {
                    let cell: GenreItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                    cell.genre = genres[indexPath.row]
                    return cell
                }
            }
            else {
                let cell: SearchSuggestCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.term = _terms[indexPath.row]
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if indexPath.section == 1 {
                let headerView: RecentSearchHeaderView = collectionView.dequeueHeader(indexPath: indexPath)
                headerView.titleHeader.text = self._textHeader
                headerView.clearAllButton.isHidden = self._type != .history
                headerView.onClearAll = { [weak self] in
                    self?.clearAllHistory()
                }
                return headerView
            }
            else {
                let headerView: GenreHeaderView = collectionView.dequeueHeader(indexPath: indexPath)
                return headerView
            }
            
        default:
            return UICollectionReusableView(frame: .zero)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self._type == .history {
            if indexPath.section == 1 {
                let term = _terms[indexPath.row]
                onSearch?(term)
            }
            else {
                onOpenGenre?(genres[indexPath.row])
            }
        }
        else {
            let term = _terms[indexPath.row]
            onSearch?(term)
        }
    }
}

extension RecentSearchView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .init(top: 0, left: 0, bottom: 10, right: 0)
        }
        if section == collectionView.numberOfSections - 1 {
            return .init(top: 0, left: kPadding, bottom: self.heightPlayerMini, right: kPadding)
        }
        return .init(top: 0, left: kPadding, bottom: 0, right: kPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if self._type == .history {
            if section == 0 {
                // don't nothing
            }
            else {
                return kPadding
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if self._type == .history {
            if section == 0 {
                // don't nothing
            }
            else {
                return kPadding
            }
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            if admobAd != nil {
                return AdmobNativeAdCell.size(collectionView.frame.size.width)
            }
            else if applovinAdView != nil {
                return AppLovinNativeAdCell.size(collectionView.frame.size.width)
            }
            return .zero
        }
        
        if self._type == .history {
            if indexPath.section == 1 {
                return SearchTermHistoryCell.size(width: collectionView.size.width - 2 * kPadding)
            }
            else {
                let width: CGFloat = CGFloat((collectionView.size.width - (_column + 1) * kPadding) / _column).rounded(.down)
                return GenreItemCell.size(width: width)
            }
        }
        else {
            return SearchSuggestCell.size(width: collectionView.size.width - 2 * kPadding)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return .init(width: collectionView.size.width, height: 0)
        }
        let width: CGFloat = collectionView.size.width
        let height: CGFloat = 40
        return .init(width: width, height: height)
    }
}





