import UIKit

// goal - use this stuff after seeing the WWDC sessions, along
// with using a swift type as the key

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


class InitiaitveTrackerViewController: UIViewController {
    var participants = [Participant]()
    var topOfOrder: Participant?  // current player

    func makeParticipants() {
        let pcCount = 4
        let monsterCount = 3
        participants = []

        let pcs = (0..<pcCount).map {
            Participant(name: "Player \($0)", hp: 2 * $0, ac: $0, initiative: $0 * 2)
        }
        participants += pcs

        let monsters = (0..<monsterCount).map {
            Participant(name: "Monster \($0)", hp: 2 * $0, ac: $0, initiative: $0 * 2 + 1)
        }
        participants += monsters
        print(participants)
    }

    // participants ordered by current initiative
    func turnOrder() -> [Participant] {
        return participants
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        makeParticipants()

        let currentOrder = turnOrder()

        
        
    }

    func nextParticipant() {
        // move to next dealie
        // regen list with that that player first
        // apply
    }
}
