import Foundation

protocol BackupBankAccountStorage {
    func addAction(_ action: BackupBankAccountAction)
    func getAllActions() async -> [BackupBankAccountAction]
    func removeAction(for accountId: Int)
    func clearAll()
} 