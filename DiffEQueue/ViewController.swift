import UIKit

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var dataSource: UITableViewDiffableDataSource<Int, UUID>!
    var data = [UUID: String]()

    var lastUUID = UUID()

    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
          UUID(): "hello",
          UUID(): "there",
          UUID(): "snarnge"
        ]

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Bork")

        dataSource = UITableViewDiffableDataSource(tableView: tableView) {
            (tableView, indexPath, identifier) in

            let cell = tableView.dequeueReusableCell(withIdentifier: "Bork", for: indexPath)
            cell.textLabel!.text = self.data[identifier]
            return cell
        }

        var snapshot = dataSource.snapshot()

        var keys = [UUID]()

        data.keys.forEach {
            keys.append($0)
            lastUUID = $0
        }
        snapshot.appendSections([0])
        snapshot.appendItems(keys, toSection: 0)

        dataSource.apply(snapshot, animatingDifferences: true) {
            print("completion")
        }
    }

    @IBAction func splunge() {
        var snapshot = dataSource.snapshot()

        let uuid = UUID()

        data[uuid] = "\(Date())"
        snapshot.insertItems([uuid], beforeItem: lastUUID)

        dataSource.apply(snapshot, animatingDifferences: true) {
            print("completion")
        }
    }

}

