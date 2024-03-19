import UIKit

public protocol CRRefreshProtocol {
    /// 自定义的view
    var view: UIView {get}
    
    /// view的insets
    var insets: UIEdgeInsets {set get}
    
    /// 触发刷新的高度
    var trigger: CGFloat {set get}
    
    /// 动画执行时的高度
    var execute: CGFloat {set get}
    
    /// 动画结束时延迟的时间，单位秒
    var endDelay: CGFloat {set get}
    
    /// 延迟时悬停的高度
    var hold: CGFloat {set get}
    
    /// 开始刷新
    mutating func refreshBegin(view: CRRefreshComponent)
    
    /// 将要开始刷新
    mutating func refreshWillEnd(view: CRRefreshComponent)
    
    /// 结束刷新
    mutating func refreshEnd(view: CRRefreshComponent, finish: Bool)
    
    /// 刷新进度的变化
    mutating func refresh(view: CRRefreshComponent, progressDidChange progress: CGFloat)
    
    /// 刷新状态的变化
    mutating func refresh(view: CRRefreshComponent, stateDidChange state: CRRefreshState)
}
