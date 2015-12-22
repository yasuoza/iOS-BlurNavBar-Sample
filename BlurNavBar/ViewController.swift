import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private var originalTitleItemTitle: String?
    private var originalTitleItemTintColor: UIColor?

    @IBOutlet weak var titleItem: UINavigationItem! {
        didSet {
            originalTitleItemTitle = titleItem.title
            originalTitleItemTintColor = titleItem.leftBarButtonItems?.first?.tintColor
        }
    }

    private let navigationBarBottomLineView = UIView()
    private var navigationBlurViewHeightConstraint: NSLayoutConstraint!

    private var statusBarHeight: CGFloat {
        get {
            let application = UIApplication.sharedApplication()
            return min(application.statusBarFrame.size.height, application.statusBarFrame.size.width)
        }
    }

    private var previousYOffset = CGFloat.NaN

    let expansionResistance: CGFloat = 200
    private var resistanceConsumed: CGFloat = 0.0
    private var contracting = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationBar = navigationController?.navigationBar {

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
            navigationBar.insertSubview(effectView, atIndex: 1)

            navigationBlurViewHeightConstraint = NSLayoutConstraint(
                item: effectView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: navigationBar,
                attribute: .Top,
                multiplier: 1,
                constant: -statusBarHeight)
            navigationBlurViewHeightConstraint.active = true

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        navigationBlurViewHeightConstraint.constant = -statusBarHeight
    }

    // MARK: - Layouting views

    private func updateNavigationBarItemsVisiblity() {
        guard let barOriginY = navigationController?.navigationBar.frame.origin.y else {
            return
        }

        titleItem.title = barOriginY < 0 ? "" : originalTitleItemTitle
        titleItem.leftBarButtonItems?.forEach { item in
            item.tintColor = barOriginY < 0 ? UIColor.clearColor() : originalTitleItemTintColor
        }
        titleItem.rightBarButtonItems?.forEach { item in
            item.tintColor = barOriginY < 0 ? UIColor.clearColor() : originalTitleItemTintColor
        }

        navigationBarBottomLineView.hidden = barOriginY != statusBarHeight
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
        guard let navigationBar = navigationController?.navigationBar else { return }

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

        var newOriginY = navigationBar.frame.origin.y + deltaY
        let maxOriginY = statusBarHeight == 0 ? -navigationBar.frame.height : -statusBarHeight
        newOriginY = max(min(newOriginY, statusBarHeight), maxOriginY)

        let newOrigin = CGPoint(x: 0, y: newOriginY)
        navigationBar.frame = CGRect(origin: newOrigin, size: navigationBar.frame.size)

        updateNavigationBarItemsVisiblity()

        previousYOffset = scrollView.contentOffset.y
    }

}
