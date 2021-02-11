import UIKit

// goal - use this stuff after seeing the WWDC sessions, along
// with using a swift type as the key

enum Section {
    case blah
}

struct Participant: Hashable {
    let id = UUID()
    var name: String
    var initiative: Int?
    var hp: Int = 32
    var ac: Int = -2 // plate mail

    init(name: String, hp: Int, ac: Int, initiative: Int? = nil) {
        self.name = name
        self.hp = hp
        self.ac = ac
        self.initiative = initiative
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (thing1: Participant, thing2: Participant) -> Bool {
        return thing1.id == thing2.id
    }
}


func d20(_ modifier: Int = 0) -> Int {
    Int.random(in: (1...20)) + modifier 
}

class InitiaitveTrackerViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var participants = [Participant]()
    var topIndex = 0

    func makeParticipants() {
        let pcCount = 4
        let monsterCount = 3
        participants = []

        let pcs = (0..<pcCount).map {
            Participant(name: "Player \($0)", hp: 2 * $0, ac: $0, 
                               initiative: d20())
        }
        participants += pcs

        let monsters = (0..<monsterCount).map {
            return Participant(name: "Monster \($0)", hp: 2 * $0, ac: $0, 
                               initiative: d20())
        }
        participants += monsters
        print(participants)
    }

    // participants ordered by current initiative
    func turnOrder() -> [Participant] {
        let ordered = participants.sorted { $0.initiative! < $1.initiative! }

        // rotate array
        let slice1 = ordered[..<topIndex]
        let slice2 = ordered[topIndex...]
        let rotated = Array(slice2) + Array(slice1)
        return rotated
    }

    var dataSource: UITableViewDiffableDataSource<Section, Participant>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Bork")

        makeParticipants()

        let currentOrder = turnOrder()

        dataSource = UITableViewDiffableDataSource<Section, Participant>(tableView: tableView) {
            (tableView, indexPath, participant) in

            let cell = tableView.dequeueReusableCell(withIdentifier: "Bork", for: indexPath)
            cell.textLabel!.text = "\(participant.initiative!) : \(participant.name)"
            return cell
        }            

        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.blah])

        snapshot.appendItems(currentOrder, toSection: .blah)
        dataSource.apply(snapshot)
    }

    func updateSnapshot() {
        let currentOrder = turnOrder()

        var snapshot = dataSource.snapshot()
        
        // Need to clear it all out first, otherwise animation gets messed up
        snapshot.deleteAllItems()
        snapshot.appendSections([.blah])        
        snapshot.appendItems(currentOrder, toSection: .blah)

        dataSource.apply(snapshot)
    }

    @IBAction func nextParticipant() {
        topIndex = ((topIndex + 1) % (participants.count))
        updateSnapshot()
    }

    var npcNumber = 0
    @IBAction func newParticipant() {
        let npc = Participant(name: "NPC \(npcNumber)", hp: 20, ac: 4,
                              initiative: d20())
        npcNumber += 1

        participants.append(npc)
        updateSnapshot()
    }
}
