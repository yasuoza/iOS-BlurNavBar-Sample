import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var navigationBar: UINavigationBar?

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private var originalNavBarTitle: String?

    private let navigationBarBottomLineView = UIView()

    private var statusBarHeight: CGFloat {
        get {
            let application = UIApplication.sharedApplication()
            return min(application.statusBarFrame.size.height, application.statusBarFrame.size.width)
        }
    }

    private var currentNavbarOriginY = CGFloat.NaN
    private var previousYOffset = CGFloat.NaN

    let expansionResistance: CGFloat = 200
    private var resistanceConsumed: CGFloat = 0.0
    private var contracting = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationBar = navigationBar {
            navigationController?.interactivePopGestureRecognizer?.delegate = self

            let topInset = navigationBar.frame.size.height - statusBarHeight
            tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)

            currentNavbarOriginY = navigationBar.frame.origin.y
            originalNavBarTitle = navigationBar.topItem?.title
            navigationBar.tintColor = view.window?.tintColor

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

            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: "applicationDidBecomeActive:",
                name: UIApplicationDidBecomeActiveNotification,
                object: nil
            )
        }
    }

    // MARK: - Notification Observer

    func applicationDidBecomeActive(notification: NSNotification) {
        updateNavigationBarItemsVisiblity()
    }

    // MARK: - Layouting views

    private func updateNavigationBarItemsVisiblity() {
        let barCollapsed = currentNavbarOriginY < 0

        navigationBar?.topItem?.title = barCollapsed ? "" : originalNavBarTitle
        navigationBar?.tintColor = barCollapsed ? UIColor.clearColor() : view.window?.tintColor
        navigationBarBottomLineView.hidden = currentNavbarOriginY != 0
        navigationBar?.hidden = barCollapsed
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 60
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = "Content Content Content Content"

        return cell
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard isViewLoaded() && view.window != nil else { return }
        guard let navigationBar = navigationBar else { return }

        if previousYOffset.isNaN {
            previousYOffset = scrollView.contentOffset.y
            return
        }

        var deltaY = previousYOffset - scrollView.contentOffset.y

        let start = -scrollView.contentInset.top;
        if previousYOffset < start {
            deltaY = min(0, deltaY - (previousYOffset - start));
        }

        let end = floor(scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds) + scrollView.contentInset.bottom - 0.5)
        if previousYOffset > end && deltaY > 0 {
            deltaY = max(0, deltaY - (previousYOffset - end))
        }

        let previousContractingState = contracting
        contracting = deltaY < 0
        if contracting != previousContractingState {
            resistanceConsumed = 0
        }

         if !contracting && scrollView.contentOffset.y > 0 {
            let availableResistance = expansionResistance - resistanceConsumed
            resistanceConsumed = min(expansionResistance, resistanceConsumed + deltaY)
            deltaY = max(0, deltaY - availableResistance)
        }

        var newOriginY = currentNavbarOriginY + deltaY
        let maxTopOriginY = -navigationBar.frame.height
        newOriginY = max(min(newOriginY, 0), maxTopOriginY)

        let newOrigin = CGPoint(x: 0, y: newOriginY)
        currentNavbarOriginY = newOriginY
        navigationBar.frame = CGRect(origin: newOrigin, size: navigationBar.frame.size)

        updateNavigationBarItemsVisiblity()

        previousYOffset = scrollView.contentOffset.y
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count > 1
    }

}
