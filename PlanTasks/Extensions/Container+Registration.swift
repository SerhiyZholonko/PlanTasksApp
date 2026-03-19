import Factory

extension Container {
    var dataStore: Factory<any DataStoreProtocol> {
        self { MainActor.assumeIsolated { FirebaseDataStore() } }.singleton
    }

    var authStore: Factory<any AuthStoreProtocol> {
        self { MainActor.assumeIsolated { FirebaseAuthStore() } }.singleton
    }
}
