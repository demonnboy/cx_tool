//
//  SHBasePageViewController.swift
//  Demon
//
//  Created by Demon on 2019/12/23.
//  Copyright © 2019 Demon. All rights reserved.
//

import UIKit

class SHBasePageViewController: UIViewController {

    private var viewControllers: [UIViewController] = []
    private var currenIndex: Int = 0

    public override func viewDidLoad() {
        super.viewDidLoad()
        reloadViewControllers()
        setPageViewController()
    }

    public func initialIndex() -> Int {
        return 0
    }

    public func collectionController() -> [UIViewController] {
        return []
    }

    private func reloadViewControllers() {
        currenIndex = initialIndex()
        viewControllers = collectionController()
        if viewControllers.isEmpty {
            fatalError("需要添加控制器")
        }
        if currenIndex < 0 || currenIndex >= viewControllers.count {
            currenIndex = 0
        }

        let initVC = [viewControllers[currenIndex]]
        pageViewController.setViewControllers(initVC, direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
    }

    private func setPageViewController() {
        pageViewController.view.frame = self.view.bounds
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }

    fileprivate lazy var pageViewController: UIPageViewController = {
        let page = UIPageViewController(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: nil)
        page.dataSource = self
        page.delegate = self
        return page
    }()
}

extension SHBasePageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.indexOfViewController(viewController)
        if let i = index, i != 0 {
            currenIndex = i - 1
            let previousVC = viewControllers[currenIndex]
            return previousVC
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.indexOfViewController(viewController)
        if let i = index, (i + 1) != self.viewControllers.count {
            currenIndex = i + 1
            let previousVC = viewControllers[currenIndex]
            return previousVC
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    }

    fileprivate func indexOfViewController(_ vc: UIViewController) -> Int? {
        return self.viewControllers.firstIndex(of: vc)
    }
}
