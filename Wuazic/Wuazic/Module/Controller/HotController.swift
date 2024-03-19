//
//  HotController.swift
//  SwiftyAds
//
//  Created by MinhNH on 13/04/2023.
//

import UIKit

class HotController: BaseController {
    
    var data: [TrackObject] = []
    
    // MARK: - property
    fileprivate let bgImageView: UIImageView = {
        let view = UIImageView(image: UIImage(imgName: "bg-feature"))
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    fileprivate let backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(imgName: "ic-back"), for: .normal)
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        view.textColor = .white
        view.text = "Hot Tracks"
        view.font = UIFont.gilroyBold(of: 18)
        return view
    }()
    
    fileprivate let listCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerItem(cell: FeatHotItemCell.self)
        view.registerItem(cell: AdmobNativeAdCell.self)
        view.registerItem(cell: AppLovinNativeAdCell.self)
        return view
    }()
    
    // MARK: - outlet
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUIs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !super.loadedNative {
            super.loadNativeAd { [weak self] in
                self?.listCollectionView.reloadData()
            }
        }
    }
    
    // MARK: - private
    private func setupUIs() {
        backButton.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        
        view.addSubview(bgImageView)
        view.addSubview(headerView)
        view.addSubview(listCollectionView)
        
        bgImageView.layoutEdges()
        
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        backButton.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: headerView.leftAnchor).isActive = true
        backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: backButton.rightAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -50).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        listCollectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        listCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        listCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    // MARK: - public
    // MARK: - event
    @objc func backClick() {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension HotController: UICollectionViewDelegate, UICollectionViewDataSource {
    func presentTrackOption(_ track: TrackObject) {
        AdsInterstitialHandle.shared.tryToPresent { [unowned self] in
            self.openTrackOption(track)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return super.numberOfNatives()
        }
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if super.admobAd != nil {
                let cell: AdmobNativeAdCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.nativeAd = super.admobAd
                return cell
            }
            else if super.applovinAdView != nil {
                let cell: AppLovinNativeAdCell = collectionView.dequeueReusableCell(indexPath: indexPath)
                cell.nativeAd = super.applovinAdView
                return cell
            }
            else {
                return UICollectionViewCell()
            }
        }
        else {
            let cell: FeatHotItemCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.track = data[indexPath.row]
            cell.onDaolod = { [weak self] track in
                self?.waitcome(track)
            }
            cell.onOption = { [weak self] track in
                self?.presentTrackOption(track)
            }
            return cell
        }
    }
}

extension HotController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return .init(top: 0, left: 0, bottom: 10, right: 0)
        }
        return .init(top: 5, left: kPadding, bottom: UIWindow.keyWindow?.mainTabbar?.paddingBottom ?? 0, right: kPadding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            if super.admobAd != nil {
                return AdmobNativeAdCell.size(collectionView.frame.size.width)
            }
            else if super.applovinAdView != nil {
                return AppLovinNativeAdCell.size(collectionView.frame.size.width)
            }
            return .zero
        }
        return FeatHotItemCell.size(width: collectionView.size.width - 2 * kPadding)
    }
}
