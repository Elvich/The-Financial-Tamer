import Foundation
import SwiftData

@Model
final class BackupBankAccountActionEntity {
    @Attribute(.unique) var id: Int
    var actionType: String
    var accountData: Data?
    var timestamp: Date

    init(id: Int, actionType: String, accountData: Data?, timestamp: Date) {
        self.id = id
        self.actionType = actionType
        self.accountData = accountData
        self.timestamp = timestamp
    }
} 