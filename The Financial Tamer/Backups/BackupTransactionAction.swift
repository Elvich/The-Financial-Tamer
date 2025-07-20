import Foundation

enum BackupActionType: String, Codable {
    case create
    case update
    case delete
}

struct BackupTransactionAction: Codable, Identifiable {
    let id: Int // id транзакции
    let actionType: BackupActionType
    let transaction: TransactionDTO? // nil для delete
    let timestamp: Date
} 
