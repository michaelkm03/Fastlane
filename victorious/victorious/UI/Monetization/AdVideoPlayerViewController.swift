//
//  AdVideoPlayerViewController.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class AdVideoPlayerViewController: UIViewController, AdLifecycleDelegate {
    weak var delegate: AdLifecycleDelegate?
    var adViewController: VAdViewControllerType

    // MARK: - Initializers

    init(adViewController: VAdViewControllerType) {
        self.adViewController = adViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
    }

    // MARK: - AdVideoPlayerViewController entry point

    func start() {
        adViewController.delegate = self
        view.addSubview(adViewController.adView)
        view.v_addFitToParentConstraintsToSubview(adViewController.adView, leading: 0.0, trailing: 0.0, top: 40.0, bottom: 0.0)
        adViewController.startAdManager()
    }

    // MARK: - AdLifecycleDelegate

    func adDidLoad() {
        delegate?.adDidLoad()
    }

    func adDidFinish() {
        adViewController.adView.removeFromSuperview()
        delegate?.adDidFinish()
    }

    func adHadError(error: NSError!) {
        adViewController.adView.removeFromSuperview()
        delegate?.adHadError(error)
    }

    func adDidStart() {
        delegate?.adDidStart()
    }
}
