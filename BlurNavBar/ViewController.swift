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

    private let statusBarHeight: CGFloat = 20.0

    private var previousYOffset = CGFloat.NaN

    override func viewDidLoad() {
        super.viewDidLoad()

        if let navigationBar = navigationController?.navigationBar {
            let bottomLineOrigin = CGPoint(x: 0, y: navigationBar.frame.height)
            navigationBarBottomLineView.frame = CGRect(
                origin: bottomLineOrigin, size: CGSize(width: navigationBar.frame.width, height: 0.4)
            )
            navigationBarBottomLineView.backgroundColor = UIColor.lightGrayColor()

            let effect = UIBlurEffect(style: .Light)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.frame = CGRect(
                x: 0, y: -statusBarHeight,
                width: navigationBar.frame.width, height: statusBarHeight + navigationBar.frame.height
            )
            navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
            navigationBar.shadowImage = UIImage()
            navigationBar.insertSubview(effectView, atIndex: 1)

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
        guard let barOriginY = navigationController?.navigationBar.frame.origin.y,
            navigationBar = navigationController?.navigationBar else {
                return
        }

        titleItem.title = barOriginY < 0 ? "" : originalTitleItemTitle
        titleItem.leftBarButtonItems?.forEach { item in
            item.tintColor = barOriginY < 0 ? UIColor.clearColor() : originalTitleItemTintColor
        }
        titleItem.rightBarButtonItems?.forEach { item in
            item.tintColor = barOriginY < 0 ? UIColor.clearColor() : originalTitleItemTintColor
        }

        if barOriginY == statusBarHeight {
            navigationBar.addSubview(navigationBarBottomLineView)
        } else {
            navigationBarBottomLineView.removeFromSuperview()
        }
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
            deltaY = max(0, deltaY - self.previousYOffset + end);
        }

        if deltaY < 0 {
            deltaY = min(0, deltaY);
        } else if scrollView.contentOffset.y > 0 {
            deltaY = max(0, deltaY)
        }

        var newOriginY = navigationBar.frame.origin.y + deltaY
        newOriginY = max(min(newOriginY, statusBarHeight), -statusBarHeight)

        let newOrigin = CGPoint(x: 0, y: newOriginY)
        navigationBar.frame = CGRect(origin: newOrigin, size: navigationBar.frame.size)

        updateNavigationBarItemsVisiblity()

        previousYOffset = scrollView.contentOffset.y
    }

}
