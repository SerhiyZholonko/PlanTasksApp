import Factory

extension Container {
    var dataStore: Factory<any DataStoreProtocol> {
        self { MainActor.assumeIsolated { MockDataStore() } }.singleton
    }
}
