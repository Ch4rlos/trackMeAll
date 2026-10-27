import SwiftUI
import Foundation
import TMACore
import TMASalud
import TMAFinanzas
import TMAActividades
import TMABlog
import TMASecurity

struct RootTabView: View {
    enum Tab: String, Hashable {
        case salud, finanzas, actividades, blog, ajustes
    }

    let lock: AppLockModel
    @State private var selection: Tab

    /// Permite abrir la app en una pestaña concreta: `-tab finanzas`.
    /// Lo usa `scripts/capturas.sh` para automatizar las capturas del README.
    init(lock: AppLockModel) {
        self.lock = lock
        let arguments = ProcessInfo.processInfo.arguments
        var initial: Tab = .salud
        if let index = arguments.firstIndex(of: "-tab"),
           index + 1 < arguments.count,
           let tab = Tab(rawValue: arguments[index + 1]) {
            initial = tab
        }
        _selection = State(initialValue: initial)
    }

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
