import SwiftUI
import TMACore
import TMASalud
import TMAFinanzas
import TMAActividades
import TMABlog
import TMASecurity

struct RootTabView: View {
    enum Tab: Hashable {
        case salud, finanzas, actividades, blog, ajustes
    }

    let lock: AppLockModel
    @State private var selection: Tab = .salud

    var body: some View {
        TabView(selection: $selection) {
            SaludView()
                .tabItem { Label("Salud", systemImage: "heart.text.square") }
                .tag(Tab.salud)

            FinanzasView()
                .tabItem { Label("Finanzas", systemImage: "creditcard") }
                .tag(Tab.finanzas)

            ActividadesView()
                .tabItem { Label("Actividades", systemImage: "figure.walk.motion") }
                .tag(Tab.actividades)

            BlogView()
                .tabItem { Label("Blog", systemImage: "square.and.pencil") }
                .tag(Tab.blog)

            SettingsView(lock: lock)
                .tabItem { Label("Ajustes", systemImage: "gearshape") }
                .tag(Tab.ajustes)
        }
        .tint(TMATheme.accent)
    }
}

#Preview {
    RootTabView(lock: AppLockModel())
}
