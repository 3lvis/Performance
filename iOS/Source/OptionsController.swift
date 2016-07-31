import UIKit
import DATAStack

class OptionsController: UITableViewController {
    unowned var dataStack: DATAStack

    init(dataStack: DATAStack) {
        self.dataStack = dataStack

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Select an option"
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Table"
        } else {
            cell.textLabel?.text = "Collection"
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            let controller = TableController(dataStack: self.dataStack)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = CollectionController(dataStack: self.dataStack)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}