import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    private var originalNavBarTitle: String = "Content View"

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

        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if let navigationBar = navigationController?.navigationBar {
            currentNavbarOriginY = navigationBar.frame.origin.y
        }

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "applicationDidBecomeActive:",
            name: UIApplicationDidBecomeActiveNotification,
            object: nil
        )
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        if let navigationBar = navigationController?.navigationBar where navigationBar.frame.origin.y < statusBarHeight {
            let navigationFrameSize = navigationBar.frame.size
            let navigationBarOrigin = CGPoint(x: 0, y: -navigationFrameSize.height)
            navigationBar.frame = CGRect(origin: navigationBarOrigin, size: navigationFrameSize)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Notification Observer

    func applicationDidBecomeActive(notification: NSNotification) {
        updateNavigationBarItemsVisiblity()
    }

    // MARK: - Layouting views

    private func updateNavigationBarItemsVisiblity() {
        let barCollapsed = currentNavbarOriginY < statusBarHeight

        navigationItem.title = barCollapsed ? "" : originalNavBarTitle
        navigationItem.backBarButtonItem?.tintColor = UIColor.clearColor()
        navigationItem.hidesBackButton = barCollapsed
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

        if deltaY > 0 && deltaY < 5 {
            resistanceConsumed = 0
        }

        if !contracting && scrollView.contentOffset.y > 0 {
            let availableResistance = expansionResistance - resistanceConsumed
            resistanceConsumed = min(expansionResistance, resistanceConsumed + deltaY)
            deltaY = max(0, deltaY - availableResistance)
        }

        var newOriginY = currentNavbarOriginY + deltaY
        let maxTopOriginY: CGFloat = -navigationBar.frame.size.height
        newOriginY = max(min(newOriginY, statusBarHeight), maxTopOriginY)

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
