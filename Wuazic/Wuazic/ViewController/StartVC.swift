import UIKit
import Lottie
import GoogleMobileAds
import AppLovinSDK
import UserMessagingPlatform

class StartVC: UIViewController {
    
    @IBOutlet weak var viewLoading: UIView!
    
    private let animationLoading = LottieAnimationView(name: "splash_anim")
    
    private var timer: Timer?
    private var timeLoading: Int = 3
    
    private var admobSplashLoaded: Bool = false
    private var admobSplash: GADInterstitialAd?
    private var isMobileAdsStartCalled = false
    
    private var applovinSplashLoaded: Bool = false
    private var applovinSplash: MAInterstitialAd?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(1, forKey: "splashing")
        UserDefaults.standard.synchronize()
        
        addNotification()
        requestConsent()
        let event = ["time_start" : "\(Date().timeIntervalSince1970)",
                     "action" : "start_session"]
        NetworksService.shared.postEvent(event: event)
    }
    
    private func requestConsent(){
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false
        
#if DEBUG
        let debugSettings = UMPDebugSettings()
        debugSettings.testDeviceIdentifiers = ["5FB0A2DA-8823-4CBE-B52C-49707E8CCA8E"]
        debugSettings.geography = .EEA
        
        parameters.debugSettings = debugSettings
#endif
        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { [weak self] requestConsentError in
            guard let self else { return }
            
            if let consentError = requestConsentError {
                self.timerStartErrorConsent()
                return print("Error: \(consentError.localizedDescription)")
            }
            
            UMPConsentForm.loadAndPresentIfRequired(from: self) { [weak self] loadAndPresentError in
                guard let self else {
                    self?.timerStartErrorConsent()
                    return
                }
                
                if let consentError = loadAndPresentError {
                    self.timerStartErrorConsent()
                    return print("Error: \(consentError.localizedDescription)")
                }
                if UMPConsentInformation.sharedInstance.canRequestAds {
                    self.startGoogleMobileAdsSDK()
                }
            }
        }
        if UMPConsentInformation.sharedInstance.canRequestAds {
            startGoogleMobileAdsSDK()
        }
    }
    
    private func startGoogleMobileAdsSDK() {
        DispatchQueue.main.async {
            guard !self.isMobileAdsStartCalled else { return }
            
            self.isMobileAdsStartCalled = true
#if DEBUG
            AdmobHandle.shared.idsTest = ["3dfb4f2b13e1aa1188bebcbddb678902"]
#endif
            AdmobHandle.shared.awake { [weak self] in
                guard let self else { return }
                
                self.processLogicSplashAd()
            }
        }
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(forName: .admob_ready, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            
            if self.admobSplashLoaded {
                self.loadSplashAdmob()
                self.timerStart()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .applovin_ready, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            
            if self.applovinSplashLoaded {
                self.loadSplashApplovin()
                self.timerStart()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ct"), object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            self.navigationController?.pushViewController(AudioHomeVC(), animated: true)
        }
    }
    
    private func processLogicSplashAd() {
        let splTimeOut = UserDefaults.standard.integer(forKey: "splash-timeout")
        let splash = UserDefaults.standard.string(forKey: "splash_mode") ?? ""
        
        if splash == "admob" {
            self.timeLoading = splTimeOut > 0 ? splTimeOut : 10
            
            if AdmobHandle.shared.isReady {
                self.loadSplashAdmob()
                self.timerStart()
            }
            else {
                self.admobSplashLoaded = true
            }
        }
        else if splash == AdsName.applovin.rawValue {
            self.timeLoading = splTimeOut > 0 ? splTimeOut : 10
            
            if ApplovinHandle.shared.isReady {
                self.loadSplashApplovin()
                self.timerStart()
            }
            else {
                self.applovinSplashLoaded = true
            }
        }
        else {
            self.timerStart()
        }
    }
    
    private func timerStartErrorConsent() {
        #if DEBUG
            AdmobHandle.shared.idsTest = []
        #endif
            AdmobHandle.shared.awake { [weak self] in
                guard let self else { return }
                self.processLogicSplashAd()
        }
    }
    
    private func timerStart() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.countLoading)), userInfo: nil, repeats: true)
    }
    
    private func loadSplashAdmob() {
        let id = DataCommonModel.shared.admob_inter_splash
        
        if id.isEmpty {
            return
        }
        
        GADInterstitialAd.load(withAdUnitID: id, request: GADRequest()) { [weak self] ad, error in
            guard let self else { return }
            
            self.timer?.invalidate()
            self.timer = nil
            
            if ad != nil {
                self.admobSplash = ad
                self.admobSplash?.fullScreenContentDelegate = self
                self.admobSplash?.present(fromRootViewController: self)
            }
            else {
                self.admobSplash = nil
                self.openTabView()
            }
        }
    }
    
    private func loadSplashApplovin() {
        applovinSplash = MAInterstitialAd(adUnitIdentifier: DataCommonModel.shared.applovin_inter_splash)
        applovinSplash?.delegate = self
        applovinSplash?.revenueDelegate = self
        applovinSplash?.load()
    }
    
    @objc func countLoading() {
        if timeLoading == 0 {
            timer?.invalidate()
            timer = nil
            self.openTabView()
        } else {
            timeLoading = timeLoading - 1
        }
    }
    
    private func openTabView() {
        UserDefaults.standard.set(0, forKey: "splashing")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name("pollza"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationLoading.contentMode = .scaleAspectFit
        viewLoading.addSubview(animationLoading)
        animationLoading.frame = CGRect(x: 0, y: 0, width: viewLoading.frame.width, height: viewLoading.frame.height)
        DispatchQueue.main.async {
            self.animationLoading.play(fromProgress: 0,
                                       toProgress: 1,
                                       loopMode: LottieLoopMode.loop,
                                       completion: { (finished) in})
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension StartVC: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        openTabView()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        openTabView()
    }
}

extension StartVC: MAAdRevenueDelegate, MAAdViewAdDelegate {
    func didPayRevenue(for ad: MAAd) { }
    
    func didLoad(_ ad: MAAd) {
        self.timer?.invalidate()
        self.timer = nil
        
        if applovinSplash?.isReady ?? false {
            applovinSplash?.show()
        }
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        self.timer?.invalidate()
        self.timer = nil
        
        self.openTabView()
    }
    
    func didExpand(_ ad: MAAd) { }
    
    func didCollapse(_ ad: MAAd) { }
    
    func didDisplay(_ ad: MAAd) { }
    
    func didHide(_ ad: MAAd) {
        self.openTabView()
    }
    
    func didClick(_ ad: MAAd) { }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        self.openTabView()
    }
}
