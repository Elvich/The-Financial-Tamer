import Foundation
import SwiftData
import SwiftUI

class BackupBankAccountStorageSwiftData: BackupBankAccountStorage {
    
    @Environment(\.modelContext) private var context: ModelContext

    func addAction(_ action: BackupBankAccountAction) {
        let accountData: Data?
        if let account = action.account {
            accountData = try? JSONEncoder().encode(account)
        } else {
            accountData = nil
        }
        let entity = BackupBankAccountActionEntity(
            id: action.id,
            actionType: action.actionType.rawValue,
            accountData: accountData,
            timestamp: action.timestamp
        )
        context.insert(entity)
        try? context.save()
    }

    func getAllActions() async -> [BackupBankAccountAction] {
        let fetchDescriptor = FetchDescriptor<BackupBankAccountActionEntity>()
        let entities = (try? context.fetch(fetchDescriptor)) ?? []
        var actions: [BackupBankAccountAction] = []
        for entity in entities {
            let accountDTO: BankAccountDTO? = {
                guard let data = entity.accountData else { return nil }
                return try? JSONDecoder().decode(BankAccountDTO.self, from: data)
            }()
            actions.append(BackupBankAccountAction(
                id: entity.id,
                actionType: BackupBankAccountActionType(rawValue: entity.actionType) ?? .create,
                account: accountDTO,
                timestamp: entity.timestamp
            ))
        }
        return actions
    }

    func removeAction(for accountId: Int) {
        let fetchDescriptor = FetchDescriptor<BackupBankAccountActionEntity>(predicate: #Predicate { $0.id == accountId })
        if let entity = try? context.fetch(fetchDescriptor).first {
            context.delete(entity)
            try? context.save()
        }
    }

    func clearAll() {
        let fetchDescriptor = FetchDescriptor<BackupBankAccountActionEntity>()
        let entities = (try? context.fetch(fetchDescriptor)) ?? []
        for entity in entities {
            context.delete(entity)
        }
        try? context.save()
    }
} 