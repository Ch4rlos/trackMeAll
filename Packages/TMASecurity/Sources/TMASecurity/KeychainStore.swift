import Foundation
import Security
import LocalAuthentication

/// Llaves y secretos en el Keychain, con protección opcional por biometría
/// (`biometryCurrentSet`: si se agrega o borra un rostro/huella, el item se invalida).
public struct KeychainStore: Sendable {

    public enum Accessibility: Sendable {
        /// Solo en este dispositivo, requiere desbloqueo.
        case whenUnlockedThisDeviceOnly
        /// Protegido por biometría del juego actual de rostros/huellas.
        case biometryCurrentSet
    }

    private let service: String

    public init(service: String = "com.carlosquiroga.trackmeall") {
        self.service = service
    }

    public func save(_ data: Data, account: String, accessibility: Accessibility) throws {
        // Se borra primero para poder actualizar la política de acceso.
        try? delete(account: account)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        if accessibility == .biometryCurrentSet {
            var accessError: Unmanaged<CFError>?
            guard let access = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                .biometryCurrentSet,
                &accessError
            ) else {
                throw KeychainError.accessControlUnavailable
            }
            query[kSecAttrAccessControl as String] = access
            query.removeValue(forKey: kSecAttrAccessible as String)
        }

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.write(status) }
    }

    public func read(account: String) throws -> Data {
        let context = LAContext()
        context.localizedReason = "Acceso a datos de trackMeAll"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            // Si el item pide biometría, el sistema muestra el diálogo con este motivo.
            kSecUseAuthenticationContext as String: context
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            throw KeychainError.read(status)
        }
        return data
    }

    public func delete(account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.delete(status)
        }
    }

    public func exists(account: String) -> Bool {
        (try? read(account: account)) != nil
    }
}

public enum KeychainError: Error, Sendable {
    case accessControlUnavailable
    case write(OSStatus)
    case read(OSStatus)
    case delete(OSStatus)

    public var message: String {
        switch self {
        case .accessControlUnavailable: "No se pudo crear la política de acceso biométrico."
        case .write(let status): "Keychain al guardar (OSStatus \(status))."
        case .read(let status): "Keychain al leer (OSStatus \(status))."
        case .delete(let status): "Keychain al borrar (OSStatus \(status))."
        }
    }
}
