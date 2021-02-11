import UIKit

// goal - use this stuff just reading the headers and docs

class SplungeViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var dataSource: UITableViewDiffableDataSource<Int, UUID>!
    var data = [UUID: String]()

    var lastUUID = UUID()

    func thingies() -> [Int: [UUID: String]] {
        [0: [
           UUID(): "hello there",
           UUID(): "Greeble bork"
         ],
         1: [
           UUID(): "Smells like",
           UUID(): "Pez"
         ],
         2: [
           UUID(): "giant Broccoli",
           UUID(): "mushroom forest",
           UUID(): "ekky fnordbork"
         ],
         3: [
           UUID(): "giant Broccoli",
           UUID(): "mushroom forest",
           UUID(): "ekky fnordbork"
         ],
         4: [
           UUID(): "Blah",
           UUID(): "gronk"
         ],
         5: [:
         ]
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Bork")
        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Snurgle")

        let thangies = thingies()
        var dataMap = [UUID: String]()
        
        thangies.forEach { key, value in
            dataMap.merge(value, uniquingKeysWith: { a, _ in a } )
        }


        dataSource = UITableViewDiffableDataSource(tableView: tableView) {
            (tableView, indexPath, identifier) in

            let cell = tableView.dequeueReusableCell(withIdentifier: "Bork", for: indexPath)
            cell.textLabel!.text = dataMap[identifier]
            return cell
        }

        var snapshot = dataSource.snapshot()

        for (sectionNumber, values) in thangies {
            snapshot.appendSections([sectionNumber])
            snapshot.appendItems(Array(values.keys), toSection: sectionNumber)
        }

        dataSource.apply(snapshot, animatingDifferences: false) {
            print("completion")
        }
    }

    @IBAction func splunge() {
        var snapshot = dataSource.snapshot()
        
        var sections = [0, 1, 2, 3, 4, 5]
        
        let oop = sections.randomElement()!
        sections.remove(at: oop)
        let ack = sections.randomElement()!
        
        print("\(oop) -> \(ack)")
        
        snapshot.moveSection(oop, afterSection: ack)

        dataSource.apply(snapshot, animatingDifferences: true) {
            print("completion")
        }
        
    }
}



extension SplungeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFooterView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Snurgle")!

        headerFooterView.contentView.subviews.forEach {
            $0.removeFromSuperview()
        }

        let label = UILabel()
        label.text = "Snornge \(section)"
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        headerFooterView.contentView.addSubview(label)

        return headerFooterView
    }
}
