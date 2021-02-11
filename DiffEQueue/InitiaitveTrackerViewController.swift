import UIKit

// goal - use this stuff after seeing the WWDC sessions, along
// with using a swift type as the key

enum Section {
    case blah
}

enum ParticipantType {
    case player
    case monster
    case npc
}

struct Participant: Hashable {
    let id = UUID()
    var name: String
    var initiative: Int?
    var hp: Int = 32
    var ac: Int = -2 // plate mail
    var type: ParticipantType

    init(name: String, hp: Int, ac: Int, type: ParticipantType,
         initiative: Int? = nil) {
        self.name = name
        self.hp = hp
        self.ac = ac
        self.initiative = initiative
        self.type = type
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

class InitiativeTrackerViewController: UIViewController {
    @IBOutlet var tableView: UITableView!

    var participants = [Participant]()
    var topIndex = 0

    func makeParticipants() {
        let pcCount = 4
        let monsterCount = 3
        participants = []

        let pcs = (0..<pcCount).map {
            Participant(name: "Player \($0)", hp: 2 * $0, ac: $0, 
                        type: .player, initiative: d20())
        }
        participants += pcs

        let monsters = (0..<monsterCount).map {
            return Participant(name: "Monster \($0)", hp: 2 * $0, ac: $0,
                               type: .monster, initiative: d20())
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

    var dataSource: DeletableTableViewDiffableDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Bork")

        makeParticipants()

        let currentOrder = turnOrder()

        dataSource = DeletableTableViewDiffableDataSource(tableView: tableView) {
            (tableView, indexPath, participant) in

            let cell = tableView.dequeueReusableCell(withIdentifier: "Bork", for: indexPath)
            cell.textLabel!.text = "\(participant.initiative!) : \(participant.name)"
            return cell
        }
        dataSource.itvc = self

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
                              type: .npc, initiative: d20())
        npcNumber += 1

        participants.append(npc)
        updateSnapshot()
    }

    func removedParticipant(_ goAway: Participant) {
        // assuming coming from the data source, so the UI is already
        // up to date
        participants.removeAll { value in
            value == goAway
        }
    }
}


class DeletableTableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Participant> {
    weak var itvc: InitiativeTrackerViewController!

    override func tableView(_ tableView: UITableView,
                            canEditRowAt indexPath: IndexPath) -> Bool {
        let participant = itemIdentifier(for: indexPath)
        return participant?.type != .player
    }
    
    override func tableView(_ tableView: UITableView, 
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let identifierToDelete = itemIdentifier(for: indexPath) {
                var snapshot = self.snapshot()
                snapshot.deleteItems([identifierToDelete])
                apply(snapshot)

                // Is there a better way?
                itvc.removedParticipant(identifierToDelete)
            }
        }
    }
}
