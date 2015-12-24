import UIKit

class LandingViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationBar = navigationBar {

            navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

            let navigationBarBottomLineView = UIView()
            navigationBarBottomLineView.backgroundColor = UIColor.lightGrayColor()
            navigationBarBottomLineView.translatesAutoresizingMaskIntoConstraints = false
            navigationBar.addSubview(navigationBarBottomLineView)

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
                toItem: navigationBar,
                attribute: .Leading,
                multiplier: 1,
                constant: 0).active = true

            NSLayoutConstraint(
                item: navigationBarBottomLineView,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: navigationBar,
                attribute: .Trailing,
                multiplier: 1,
                constant: 0).active = true

            NSLayoutConstraint(
                item: navigationBarBottomLineView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: navigationBar,
                attribute: .Bottom,
                multiplier: 1,
                constant: 0).active = true

            let effect = UIBlurEffect(style: .Light)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.translatesAutoresizingMaskIntoConstraints = false
            navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            navigationBar.shadowImage = UIImage()
            navigationBar.insertSubview(effectView, atIndex: 0)

            NSLayoutConstraint(
                item: effectView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: navigationBar,
                attribute: .Top,
                multiplier: 1,
                constant: -20).active = true

            NSLayoutConstraint(
                item: effectView,
                attribute: .Leading,
                relatedBy: .Equal,
                toItem: navigationBar,
                attribute: .Leading,
                multiplier: 1,
                constant: 0).active = true

            NSLayoutConstraint(
                item: effectView,
                attribute: .Trailing,
                relatedBy: .Equal,
                toItem: navigationBar,
                attribute: .Trailing,
                multiplier: 1,
                constant: 0).active = true

            NSLayoutConstraint(
                item: effectView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: navigationBar,
                attribute: .Bottom,
                multiplier: 1,
                constant: 0).active = true
        }
    }

}
