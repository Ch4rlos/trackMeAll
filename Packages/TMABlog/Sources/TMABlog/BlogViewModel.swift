import Foundation
import Observation
import TMACore

@MainActor
@Observable
public final class BlogViewModel {
    public private(set) var posts: [BlogPost] = []
    public private(set) var media: [MediaAsset] = []
    public private(set) var isLoading = false
    public private(set) var errorMessage: String?

    private let repository: any BlogRepository

    public init(repository: any BlogRepository = MockBlogRepository()) {
        self.repository = repository
    }

    public var publishedCount: Int { posts.filter { $0.status == .published }.count }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            async let posts = repository.posts()
            async let media = repository.media()
            self.posts = try await posts
            self.media = try await media
        } catch {
            errorMessage = "No se pudo leer el blog: \(error)"
        }
        isLoading = false
    }

    public func statusLabel(for status: BlogPost.Status) -> String {
        switch status {
        case .draft: "Borrador"
        case .scheduled: "Programado"
        case .published: "Publicado"
        }
    }

    public func fileSize(for asset: MediaAsset) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(asset.byteSize), countStyle: .file)
    }
}
