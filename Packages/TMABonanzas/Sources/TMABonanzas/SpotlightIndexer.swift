import Foundation
import CoreSpotlight
import UniformTypeIdentifiers
import TMACore

/// Indexa las publicaciones del blog para que aparezcan en Spotlight y en la
/// búsqueda del sistema, sin backend.
public struct SpotlightIndexer: Sendable {

    public enum IndexError: Error, Sendable {
        case indexFailed(String)
    }

    public init() {}

    public func index(posts: [BlogPost]) async throws(IndexError) {
        let items = posts.map { post -> CSSearchableItem in
            let attributes = CSSearchableItemAttributeSet(contentType: UTType.text)
            attributes.title = post.title
            attributes.contentDescription = post.excerpt
            attributes.keywords = post.tags + ["trackMeAll", "blog"]
            attributes.contentCreationDate = post.updatedAt
            return CSSearchableItem(
                uniqueIdentifier: "blog.\(post.slug)",
                domainIdentifier: "com.carlosquiroga.trackmeall.blog",
                attributeSet: attributes
            )
        }

        do {
            try await CSSearchableIndex.default().indexSearchableItems(items)
        } catch {
            throw .indexFailed(error.localizedDescription)
        }
    }

    public func removeAll() async throws(IndexError) {
        do {
            try await CSSearchableIndex.default()
                .deleteSearchableItems(withDomainIdentifiers: ["com.carlosquiroga.trackmeall.blog"])
        } catch {
            throw .indexFailed(error.localizedDescription)
        }
    }
}
