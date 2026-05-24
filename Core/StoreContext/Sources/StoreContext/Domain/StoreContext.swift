public struct StoreContext: Equatable, Sendable {
    public let store: Store
    public let employee: Employee
    public let salesChannel: SalesChannel

    public init(store: Store, employee: Employee, salesChannel: SalesChannel) {
        self.store = store
        self.employee = employee
        self.salesChannel = salesChannel
    }
}

public struct Store: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let countryCode: String
    public let currencyCode: String

    public init(id: String, name: String, countryCode: String, currencyCode: String) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.currencyCode = currencyCode
    }
}

public struct Employee: Identifiable, Equatable, Sendable {
    public let id: String
    public let displayName: String
    public let role: EmployeeRole

    public init(id: String, displayName: String, role: EmployeeRole) {
        self.id = id
        self.displayName = displayName
        self.role = role
    }
}

public enum EmployeeRole: String, Equatable, Sendable {
    case seller = "Seller"
    case manager = "Manager"
    case storeAdmin = "Store admin"
}

public enum SalesChannel: String, Equatable, Sendable {
    case store = "Store"
    case popUp = "Pop-up"
    case clienteling = "Clienteling"
}
