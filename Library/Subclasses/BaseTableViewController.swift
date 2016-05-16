import UIKit
import DATAStack

public class BaseTableViewController: UITableViewController {
    internal var dataStack: DATAStack

    public init(dataStack: DATAStack) {
        self.dataStack = dataStack

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
