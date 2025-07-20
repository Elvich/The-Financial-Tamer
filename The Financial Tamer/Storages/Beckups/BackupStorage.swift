import Foundation

protocol BackupStorage {
    func addAction(_ action: BackupTransactionAction)
    func getAllActions() async -> [BackupTransactionAction]
    func removeAction(for transactionId: Int)
    func clearAll()
} 
