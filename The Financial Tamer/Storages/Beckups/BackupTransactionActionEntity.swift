import Foundation
import SwiftData

@Model
final class BackupTransactionActionEntity {
    @Attribute(.unique) var id: Int
    var actionType: String
    var transactionData: Data?
    var timestamp: Date

    init(id: Int, actionType: String, transactionData: Data?, timestamp: Date) {
        self.id = id
        self.actionType = actionType
        self.transactionData = transactionData
        self.timestamp = timestamp
    }
} 
