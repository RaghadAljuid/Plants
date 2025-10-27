//
//  PlantViewModel.swift
//  Planto
//
//  Created by Raghad Aljuid on 04/05/1447 AH.
//
import SwiftUI
import Combine

class PlantViewModel: ObservableObject {
    @Published var plants: [Plant] = []   // قائمة النباتات

    // إضافة نبتة جديدة
    func addPlant(plant: Plant) {
        var p = plant
        // تأكد من بدء تتبع الوقت
        if p.startTrackingDate == nil { p.startTrackingDate = Date() }
        plants.append(p)

        // جدولة تذكير إن لزم
        NotificationManager.shared.scheduleWateringReminderIfNeeded(for: p)
    }

    // حذف نبتة
    func deletePlant(plant: Plant) {
        if let index = plants.firstIndex(of: plant) {
            // ألغِ تذكيرها
            NotificationManager.shared.cancelReminder(for: plants[index])
            plants.remove(at: index)
        }
    }

    // تحديث حالة السقاية للنبتة
    func toggleWater(for plant: Plant) {
        if let index = plants.firstIndex(of: plant) {
            plants[index].isWateredToday.toggle()
            let updated = plants[index]

            if updated.isWateredToday {
                // إذا سُقيت: ألغِ التذكير
                NotificationManager.shared.cancelReminder(for: updated)
            } else {
                // إذا أزلنا علامة السقي: أعد جدولة بعد 5 دقائق
                NotificationManager.shared.scheduleWateringReminderIfNeeded(for: updated)
            }
        }
    }

    // تحديث نبتة موجودة عبر المعرّف
    func updatePlant(id: UUID, with updated: Plant) {
        if let index = plants.firstIndex(where: { $0.id == id }) {
            var newValue = updated
            // تأكد من startTrackingDate
            if newValue.startTrackingDate == nil {
                newValue.startTrackingDate = Date()
            }
            plants[index] = newValue

            // أعد ضبط التذكير حسب الحالة الجديدة
            NotificationManager.shared.cancelReminder(for: newValue)
            NotificationManager.shared.scheduleWateringReminderIfNeeded(for: newValue)
        }
    }
}
