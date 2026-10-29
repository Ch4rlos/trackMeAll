import Foundation

/// Datos falsos pero con forma real, para construir toda la UI sin permisos
/// ni backend. Cada `Mock*Repository` los devuelve con un pequeño retardo
/// para que los estados de carga se vean de verdad.
public enum MockData {

    // MARK: Salud

    public static func healthMetrics(now: Date = .now, calendar: Calendar = .current) -> [HealthMetric] {
        let today = calendar.startOfDay(for: now)
        return [
            HealthMetric(kind: .steps, title: "Pasos", value: "8,432",
                         detail: "Meta 10,000 · 84%", date: now),
            HealthMetric(kind: .heartRate, title: "Frecuencia cardiaca", value: "62 lpm",
                         detail: "Reposo · rango 54-71", date: now),
            HealthMetric(kind: .hrv, title: "HRV", value: "48 ms",
                         detail: "Promedio 7 días: 44 ms", date: now),
            HealthMetric(kind: .sleep, title: "Sueño", value: "6 h 52 min",
                         detail: "Profundo 1 h 18 · REM 1 h 05", date: today),
            HealthMetric(kind: .workout, title: "Ejercicio", value: "42 min",
                         detail: "Fuerza · 318 kcal activas", date: now),
            HealthMetric(kind: .vo2Max, title: "VO₂ máx", value: "43.2",
                         detail: "Estimado por Watch · tendencia estable", date: today),
            HealthMetric(kind: .mindfulness, title: "Mindfulness", value: "10 min",
                         detail: "Sesión guiada · respiración", date: now),
            HealthMetric(kind: .nutrition, title: "Alimentación", value: "1,840 kcal",
                         detail: "P 128 g · C 190 g · G 58 g", date: now)
        ]
    }

    public static func stepsLastWeek(now: Date = .now, calendar: Calendar = .current) -> [DailyMetric] {
        let values: [Double] = [6210, 9340, 7815, 11020, 8720, 4390, 8432]
        let names = ["lun", "mar", "mié", "jue", "vie", "sáb", "dom"]
        let today = calendar.startOfDay(for: now)
        return values.enumerated().map { index, value in
            let date = calendar.date(byAdding: .day, value: index - 6, to: today) ?? today
            return DailyMetric(date: date, label: names[index], value: value)
        }
    }

    public static func moods(now: Date = .now) -> [MoodEntry] {
        [
            MoodEntry(date: now.addingTimeInterval(-3_600), valence: 0.6,
                      labels: ["tranquilo", "concentrado"], note: "Sesión de Jiujitsu."),
            MoodEntry(date: now.addingTimeInterval(-86_400), valence: -0.2,
                      labels: ["cansado"], note: "Poca energía después de comida."),
            MoodEntry(date: now.addingTimeInterval(-172_800), valence: 0.8,
                      labels: ["agradecido", "animado"], note: nil)
        ]
    }

    public static func nutrition(now: Date = .now, calendar: Calendar = .current) -> [NutritionDay] {
        let today = calendar.startOfDay(for: now)
        return [
            NutritionDay(date: today, calories: 1840, proteinGrams: 128,
                         carbsGrams: 190, fatGrams: 58, waterLiters: 2.4),
            NutritionDay(date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                         calories: 2110, proteinGrams: 142,
                         carbsGrams: 205, fatGrams: 66, waterLiters: 2.9)
        ]
    }

    // MARK: Finanzas

    public static func accounts(now: Date = .now) -> [AccountSummary] {
        [
            AccountSummary(name: "Débito principal", institution: "BBVA",
                           balance: 18_420.55, lastSyncedAt: now.addingTimeInterval(-1_800)),
            AccountSummary(name: "Crédito", institution: "American Express",
                           balance: -6_240.10, lastSyncedAt: now.addingTimeInterval(-1_800)),
            AccountSummary(name: "Ahorro", institution: "Nu",
                           balance: 52_000, lastSyncedAt: now.addingTimeInterval(-172_800))
        ]
    }

    public static func transactions(now: Date = .now) -> [Transaction] {
        [
            Transaction(merchant: "Totalplay", amount: -899, date: now.addingTimeInterval(-7_200),
                        category: "Servicios", source: .gmail),
            Transaction(merchant: "Home Depot", amount: -1_284.90, date: now.addingTimeInterval(-86_400),
                        category: "Hogar", source: .ocr),
            Transaction(merchant: "Odin's Grip", amount: 4_500, date: now.addingTimeInterval(-172_800),
                        category: "Ingreso", source: .manual),
            Transaction(merchant: "Starbucks", amount: -78.50, date: now.addingTimeInterval(-190_000),
                        category: "Comida", source: .ocr)
        ]
    }

    // MARK: Actividades

    public static func appUsage() -> [AppUsage] {
        [
            AppUsage(appName: "Xcode", category: "Desarrollo", minutes: 142),
            AppUsage(appName: "Safari", category: "Productividad", minutes: 63),
            AppUsage(appName: "WhatsApp", category: "Social", minutes: 38),
            AppUsage(appName: "Instagram", category: "Social", minutes: 21)
        ]
    }

    public static func visits(now: Date = .now) -> [PlaceVisit] {
        [
            PlaceVisit(name: "Odin's Grip", arrivedAt: now.addingTimeInterval(-14_400),
                       durationMinutes: 95, latitude: 25.67, longitude: -100.31),
            PlaceVisit(name: "Casa", arrivedAt: now.addingTimeInterval(-28_800),
                       durationMinutes: 540, latitude: 25.65, longitude: -100.35),
            PlaceVisit(name: "CEDIM", arrivedAt: now.addingTimeInterval(-90_000),
                       durationMinutes: 60, latitude: 25.65, longitude: -100.29)
        ]
    }

    public static func agenda(now: Date = .now, calendar: Calendar = .current) -> [AgendaEvent] {
        [
            AgendaEvent(title: "Llamada de trabajo",
                        start: now.addingTimeInterval(3_600),
                        end: now.addingTimeInterval(5_400), calendar: "Trabajo"),
            AgendaEvent(title: "Revisión de proyecto",
                        start: now.addingTimeInterval(86_400),
                        end: now.addingTimeInterval(90_000), calendar: "Obra norte")
        ]
    }

    // MARK: Blog

    public static func posts(now: Date = .now) -> [BlogPost] {
        [
            BlogPost(title: "Cómo estructuré el sistema de un arquitecto que programa",
                     slug: "arquitecto-que-programa", status: .published,
                     updatedAt: now.addingTimeInterval(-259_200),
                     excerpt: "Del plano al repo: qué automatizo y qué sigo dibujando a mano.",
                     tags: ["sistemas", "arquitectura"], coverKey: "posts/arquitecto.jpg"),
            BlogPost(title: "Jiujitsu y ansiedad: lo que el Watch sí puede medir",
                     slug: "jiujitsu-ansiedad", status: .draft,
                     updatedAt: now.addingTimeInterval(-7_200),
                     excerpt: "HRV, sueño y valencia emocional: tres señales, cero milagros.",
                     tags: ["jiujitsu", "salud"]),
            BlogPost(title: "Odin's Grip: primer año",
                     slug: "odins-grip-primer-ano", status: .scheduled,
                     updatedAt: now.addingTimeInterval(-86_400),
                     excerpt: "Lo que funcionó y lo que costó aprender en la academia.",
                     tags: ["odinsgrip"], coverKey: "posts/odins.jpg")
        ]
    }

    public static func media() -> [MediaAsset] {
        [
            MediaAsset(key: "posts/arquitecto.jpg", filename: "arquitecto.jpg",
                       contentType: "image/jpeg", byteSize: 412_880),
            MediaAsset(key: "posts/odins.jpg", filename: "odins.jpg",
                       contentType: "image/jpeg", byteSize: 388_140)
        ]
    }
}
