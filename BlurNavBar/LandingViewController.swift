import UIKit

class LandingViewController: UIViewController {

    @IBOutlet weak var fakeNavigationBar: UINavigationBar?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        decorateNavigationBar(navigationController?.navigationBar)
        decorateNavigationBar(fakeNavigationBar)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if navigationController?.navigationBar.frame.origin.y <= 20 {
            fakeNavigationBar?.hidden = false
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let navgationBar = navigationController?.navigationBar where navgationBar.frame.origin.y <= 20 {
            fakeNavigationBar?.hidden = true
            navgationBar.frame = CGRect(origin: CGPoint(x: 0, y: 20), size: navgationBar.frame.size)
        }
    }

    // MARK: - UINavigationBar common decoration stack

    private func decorateNavigationBar(uinavigationBar: UINavigationBar?) {
        let navigationBarBottomLineView = UIView()
        navigationBarBottomLineView.backgroundColor = UIColor.lightGrayColor()
        navigationBarBottomLineView.translatesAutoresizingMaskIntoConstraints = false
        uinavigationBar?.addSubview(navigationBarBottomLineView)

        NSLayoutConstraint(
            item: navigationBarBottomLineView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .Height,
            multiplier: 1,
            constant: 0.4).active = true

        NSLayoutConstraint(
            item: navigationBarBottomLineView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: uinavigationBar,
            attribute: .Leading,
            multiplier: 1,
            constant: 0).active = true

        NSLayoutConstraint(
            item: navigationBarBottomLineView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: uinavigationBar,
            attribute: .Trailing,
            multiplier: 1,
            constant: 0).active = true

        NSLayoutConstraint(
            item: navigationBarBottomLineView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: uinavigationBar,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0).active = true


        let effect = UIBlurEffect(style: .Light)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        effectView.userInteractionEnabled = false
        uinavigationBar?.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        uinavigationBar?.shadowImage = UIImage()
        uinavigationBar?.insertSubview(effectView, atIndex: 0)

        NSLayoutConstraint(
            item: effectView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: uinavigationBar,
            attribute: .Top,
            multiplier: 1,
            constant: -20).active = true

        NSLayoutConstraint(
            item: effectView,
            attribute: .Leading,
            relatedBy: .Equal,
            toItem: uinavigationBar,
            attribute: .Leading,
            multiplier: 1,
            constant: 0).active = true

        NSLayoutConstraint(
            item: effectView,
            attribute: .Trailing,
            relatedBy: .Equal,
            toItem: uinavigationBar,
            attribute: .Trailing,
            multiplier: 1,
            constant: 0).active = true

        NSLayoutConstraint(
            item: effectView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: uinavigationBar,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0).active = true
    }

}
