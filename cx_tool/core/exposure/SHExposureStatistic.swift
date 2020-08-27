//
//  SHExposureStatistic.swift
//  cx_tool
//
//  Created by Demon on 2020/8/23.
//  Copyright © 2020 Demon. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    //方法替换
    fileprivate static func swizzleMethod(target: NSObject.Type, _ left: Selector, _ right: Selector) {
        guard let originalMethod = class_getInstanceMethod(target, left), let swizzledMethod = class_getInstanceMethod(target, right) else { return }
        let didAddMethod = class_addMethod(target, left, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            class_replaceMethod(target, right, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

private var SH_VIEWVISIBLE = 0
private var SH_TRACKHASPERFORM = 0
private var SH_TRACKMODEL = 0
private var SH_EXPORSURE_PROTOCOL = 0
private var SH_EXPOSE_KEY = 0
private var SH_EXPORSURE_AREA = 0

private var kExposureAreaThreshold: CGFloat = 0.5

class SHExposureStatistic: NSObject {

    @objc static dynamic func registerExporsure() {
        NSObject.swizzleMethod(target: UIScrollView.self, NSSelectorFromString("_scrollViewDidEndDeceleratingForDelegate"), #selector(UIScrollView.sh_scrollViewDidEndDeceleratingForDelegate))
        NSObject.swizzleMethod(target: UIScrollView.self, NSSelectorFromString("_scrollViewDidEndDraggingForDelegateWithDeceleration:"), #selector(UIScrollView.sh_scrollViewDidEndDraggingForDelegateWithDeceleration(_:)))
        NSObject.swizzleMethod(target: UIScrollView.self, NSSelectorFromString("_delegateScrollViewAnimationEnded"), #selector(UIScrollView.sh_delegateScrollViewAnimationEnded))
        NSObject.swizzleMethod(target: UIView.self, #selector(setter: UIView.isHidden), #selector(UIView.sh_isHidden(_:)))
        NSObject.swizzleMethod(target: UIView.self, #selector(setter: UIView.frame), #selector(UIView.sh_frame(_:)))
        NSObject.swizzleMethod(target: UIView.self, #selector(UIView.addSubview(_:)), #selector(UIView.sh_addSubView(_:)))
//        NSObject.swizzleMethod(target: UIViewController.self, #selector(UIViewController.viewDidLoad), #selector(UIViewController.sh_viewDidLoad))
    }
}

extension UIView {

    /// 绑定曝光值
    @objc var sh_expose_key: String? {
        get {
            return objc_getAssociatedObject(self, &SH_EXPOSE_KEY) as? String
        }
        set {
            if let new_value = newValue, !new_value.isEmpty, new_value != self.sh_expose_key {
                objc_setAssociatedObject(self, &SH_EXPOSE_KEY, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
                self.sh_viewVisible = false
                self.sh_updateViewVisible()
            }
        }
    }

    fileprivate var sh_viewVisible: Bool {
        get {
            guard let result = objc_getAssociatedObject(self, &SH_VIEWVISIBLE) as? Bool else { return false }
            return result
        }
        set {
            if !self.sh_viewVisible && newValue, let expose_key = self.sh_expose_key, !expose_key.isEmpty {
                // TODO: 数据上报
            }
            objc_setAssociatedObject(self, &SH_VIEWVISIBLE, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    /// 已经执行过
    fileprivate var sh_track_has_perform: Bool {
        get {
            guard let result = objc_getAssociatedObject(self, &SH_TRACKHASPERFORM) as? Bool else { return false }
            return result
        }
        set {
            objc_setAssociatedObject(self, &SH_TRACKHASPERFORM, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }

    @objc fileprivate func sh_didMoveToWindow() {
        self.sh_didMoveToWindow()
        self.sh_updateViewVisible()
    }

    @objc fileprivate func sh_addSubView(_ subView: UIView) {
        if subView != self {
            self.sh_addSubView(subView)
            self.sh_updateViewVisible()
        }
    }

    @objc fileprivate func sh_frame(_ frame: CGRect) {
        self.sh_frame(frame)
        self.sh_updateViewVisible()
    }

    @objc fileprivate func sh_isHidden(_ hidden: Bool) {
        self.sh_isHidden(hidden)
        self.sh_updateViewVisible()
    }

    fileprivate func sh_updateViewVisible() {
//        guard let currentVC = self.locatedVC() as? UIViewController, let topVC = self.topVC() else { return }
//        if currentVC != topVC { return } // 上个控制器还有banner在滑动 所有判断view所在的控制器是否在最上层, 当有控制器嵌套时就不能这么用
        guard let currentVC = self.locatedVC() as? UIViewController else { return }
        if currentVC.sh_viewVisibleAuth() {
            self.sh_checkoutAuth()
        }
    }

    private func sh_checkoutAuth() {
        if self.sh_track_has_perform { return }
        self.sh_track_has_perform = true
        self.perform(#selector(sh_calculateViewVisible), with: nil, afterDelay: 0, inModes: [RunLoop.Mode.default])
        for subView in self.subviews {
            subView.sh_checkoutAuth()
        }
    }

    @objc private func sh_calculateViewVisible() {
        self.sh_track_has_perform = false
        guard let exposekey = self.sh_expose_key, !exposekey.isEmpty else { return }
        self.sh_viewVisible = self.sh_isDisplayInScreen()
    }

    @discardableResult
    func sh_isDisplayInScreen() -> Bool {
        if self.isHidden || self.alpha < 0.01 || self.window == nil {
            return false
        }

        //iOS11 以下 特殊处理 UITableViewWrapperView 需要使用的supview
        //UITableviewWrapperview 的大小为tableView 在屏幕中出现第一个完整的屏幕大小的视图
        //并且会因为contentOffset的改变而改变，所以UITableviewWrapperview会滑出屏幕，这样因为self.superview.hlj_viewVisible 这个条件导致 他下面的子试图都被判定为不可见，因此将cell的父试图为UITableViewWrapperView的时候，使用tableView 计算
        var view = self
        if String(describing: type(of: view)) == "UITableViewWrapperView" {
            if let sView = self.superview {
                view = sView
            }
        }

        guard let delegate = UIApplication.shared.delegate else { return false }
        guard let wd = delegate.window else { return false }
        let selfRect = view.convert(view.bounds, to: wd)
        
        var screenRect = CGRect.zero
        if let currentVC = self.locatedVC() as? UIViewController, currentVC.sh_exposure_area != UIEdgeInsets.zero {
            screenRect = UIScreen.main.bounds.inset(by: currentVC.sh_exposure_area)
        } else {
            screenRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }

        let intersectionRect = screenRect.intersection(selfRect)
        let intersectionSquare = intersectionRect.size.width * intersectionRect.size.height
        let selfSquare = selfRect.size.width * selfRect.size.height
        let result = intersectionSquare >= selfSquare * kExposureAreaThreshold
        return result
    }

    private func locatedVC() -> SHExporsureStatisticProtocol? {
        var nxt = self.next
        while nxt != nil {
            if nxt is UIViewController {
                return nxt as? UIViewController
            }
            nxt = nxt?.next
        }
        return nil
    }

    private func topVC() -> UIViewController? {
        guard let keywindow = UIApplication.shared.keyWindow else { return nil }
        var rootvc = keywindow.rootViewController

        if rootvc?.isKind(of: UINavigationController.self) ?? false {
            let nav = rootvc as? UINavigationController
            rootvc = nav?.topViewController
        } else if rootvc?.isKind(of: UITabBarController.self) ?? false {
            let tabbar = rootvc as? UITabBarController

            let selectedVC = tabbar?.selectedViewController
            rootvc = selectedVC
            if selectedVC?.isKind(of: UINavigationController.self) ?? false {
                let nav = selectedVC as? UINavigationController
                rootvc = nav?.topViewController
            }
        }

        while rootvc?.presentedViewController != nil {
            rootvc = rootvc?.presentedViewController
            if rootvc?.isKind(of: UINavigationController.self) ?? false {
                let nav = rootvc as? UINavigationController
                rootvc = nav?.visibleViewController
            } else if rootvc?.isKind(of: UITabBarController.self) ?? false {
                let tabbar = rootvc as? UITabBarController
                let selectedVC = tabbar?.selectedViewController
                rootvc = selectedVC
                if selectedVC?.isKind(of: UINavigationController.self) ?? false {
                    let nav = selectedVC as? UINavigationController
                    rootvc = nav?.topViewController
                }
            }
        }
        return rootvc
    }
}

extension UIScrollView {

    @objc fileprivate func sh_scrollViewDidEndDeceleratingForDelegate() {
        self.sh_scrollViewDidEndDeceleratingForDelegate()
        self.sh_updateViewVisible()
    }

    @objc fileprivate func sh_scrollViewDidEndDraggingForDelegateWithDeceleration(_ object: Bool) {
        self.sh_scrollViewDidEndDraggingForDelegateWithDeceleration(object)
        if !object {
            self.sh_updateViewVisible()
        }
    }

    @objc fileprivate func sh_delegateScrollViewAnimationEnded() {
        self.sh_delegateScrollViewAnimationEnded()
        if !sh_isDisplayInScreen() { return }
        self.sh_updateViewVisible()
    }
}

@objc protocol SHExporsureStatisticProtocol: NSObjectProtocol {
    func sh_viewVisibleAuth() -> Bool
    func sh_VCUniqueId() -> String
}

private var SH_VIEWDIDLOAD_TIMESTAMP = 0

extension UIViewController {
    /// 设置曝光有效区域
    var sh_exposure_area: UIEdgeInsets {
        get {
            guard let result = objc_getAssociatedObject(self, &SH_EXPORSURE_AREA) as? UIEdgeInsets else { return UIEdgeInsets.zero }
            return result
        }
        set {
            objc_setAssociatedObject(self, &SH_EXPORSURE_AREA, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

extension UIViewController: SHExporsureStatisticProtocol {

    /// 开启曝光埋点的开关
    ///
    /// - Returns: bool
    func sh_viewVisibleAuth() -> Bool {
        return false
    }

    func sh_VCUniqueId() -> String {
        return ""
    }
}

extension UIView: SHExporsureStatisticProtocol {

    func sh_VCUniqueId() -> String {
        return ""
    }

    func sh_viewVisibleAuth() -> Bool {
        return true
    }
    
}

func printLog<T>(_ items: T..., fileName: String = #file, methodName: String = #function, lineNumber: Int = #line) {
    #if DEBUG
    var msg = ""
    for item in items {
        msg += "\(item)\n"
    }
    let date = Date()
    let fName = (fileName as NSString).pathComponents.last!
    let result = "\(date)  " +  "\(fName)  " + "methodName:\(methodName)  " + "line:\(lineNumber)  " + "\(msg)"
    print(result)
    #endif
}
