import SwiftUI
import TMACore

@MainActor
public struct BlogView: View {
    @State private var viewModel = BlogViewModel()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    TMASectionTitle("Publicaciones · \(viewModel.publishedCount) en vivo")
                    ForEach(viewModel.posts) { post in
                        TMACard {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(post.title).font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(viewModel.statusLabel(for: post.status))
                                        .font(.caption2.weight(.semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(statusColor(post.status).opacity(0.15), in: Capsule())
                                        .foregroundStyle(statusColor(post.status))
                                }
                                Text(post.excerpt).font(.footnote).foregroundStyle(.secondary)
                                Text("\(post.tags.map { "#\($0)" }.joined(separator: " ")) · \(TMATheme.shortDate(post.updatedAt))")
                                    .font(.caption2).foregroundStyle(.tertiary)
                            }
                        }
                    }

                    TMASectionTitle("Multimedia (R2 / S3)")
                    ForEach(viewModel.media) { asset in
                        TMACard {
                            HStack(spacing: 12) {
                                Image(systemName: asset.contentType.hasPrefix("image") ? "photo" : "doc")
                                    .foregroundStyle(TMATheme.accent)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(asset.filename).font(.subheadline.weight(.medium))
                                    Text("\(asset.key) · \(viewModel.fileSize(for: asset))")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }

                    TMANotice(title: "Etapa 2 · backend",
                              message: "Subida con URL prefirmada: la app pide la firma al backend, hace PUT directo al bucket y nunca carga credenciales. R2 de Cloudflare es compatible con S3 y encaja con Cloudflare Pages.")
                }
                .padding(16)
            }
            .navigationTitle("Blog")
            .refreshable { await viewModel.load() }
            .overlay {
                if viewModel.isLoading && viewModel.posts.isEmpty { ProgressView() }
            }
            .task { await viewModel.load() }
        }
    }

    private func statusColor(_ status: BlogPost.Status) -> Color {
        switch status {
        case .draft: .orange
        case .scheduled: .blue
        case .published: TMATheme.positive
        }
    }
}
