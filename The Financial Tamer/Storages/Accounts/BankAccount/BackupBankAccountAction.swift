import Foundation

enum BackupBankAccountActionType: String, Codable {
    case create
    case update
    case delete
}

struct BackupBankAccountAction: Codable, Identifiable {
    let id: Int // id счета
    let actionType: BackupBankAccountActionType
    let account: BankAccountDTO? // nil для delete
    let timestamp: Date
}

struct BankAccountDTO: Codable {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}

extension BankAccount {
    func toDTO() -> BankAccountDTO {
        return BankAccountDTO(
            id: self.id,
            userId: self.userId,
            name: self.name,
            balance: self.balance,
            currency: self.currency,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
}

extension BankAccountDTO {
    func toModel() -> BankAccount {
        return BankAccount(
            id: self.id,
            userId: self.userId,
            name: self.name,
            balance: self.balance,
            currency: self.currency,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
} 