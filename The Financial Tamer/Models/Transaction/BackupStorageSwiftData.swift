import Foundation
import SwiftData
import SwiftUI

class BackupStorageSwiftData: BackupStorage {
    
    @Environment(\.modelContext) private var context: ModelContext


    func addAction(_ action: BackupTransactionAction) {
        let transactionData: Data?
        if let transaction = action.transaction {
            transactionData = try? JSONEncoder().encode(transaction)
        } else {
            transactionData = nil
        }
        let entity = BackupTransactionActionEntity(
            id: action.id,
            actionType: action.actionType.rawValue,
            transactionData: transactionData,
            timestamp: action.timestamp
        )
        context.insert(entity)
        try? context.save()
    }

    func getAllActions() async -> [BackupTransactionAction] {
        let fetchDescriptor = FetchDescriptor<BackupTransactionActionEntity>()
        let entities = (try? context.fetch(fetchDescriptor)) ?? []
        var actions: [BackupTransactionAction] = []
        for entity in entities {
            let transactionDTO: TransactionDTO? = {
                guard let data = entity.transactionData else { return nil }
                return try? JSONDecoder().decode(TransactionDTO.self, from: data)
            }()
            actions.append(BackupTransactionAction(
                id: entity.id,
                actionType: BackupActionType(rawValue: entity.actionType) ?? .create,
                transaction: transactionDTO,
                timestamp: entity.timestamp
            ))
        }
        return actions
    }

    func removeAction(for transactionId: Int) {
        let fetchDescriptor = FetchDescriptor<BackupTransactionActionEntity>(predicate: #Predicate { $0.id == transactionId })
        if let entity = try? context.fetch(fetchDescriptor).first {
            context.delete(entity)
            try? context.save()
        }
    }

    func clearAll() {
        let fetchDescriptor = FetchDescriptor<BackupTransactionActionEntity>()
        let entities = (try? context.fetch(fetchDescriptor)) ?? []
        for entity in entities {
            context.delete(entity)
        }
        try? context.save()
    }
} 
