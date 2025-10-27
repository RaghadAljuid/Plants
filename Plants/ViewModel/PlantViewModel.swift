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
        plants.append(plant)
    }

    // حذف نبتة
    func deletePlant(plant: Plant) {
        if let index = plants.firstIndex(of: plant) {
            plants.remove(at: index)
        }
    }

    // تحديث حالة السقاية للنبتة
    func toggleWater(for plant: Plant) {
        if let index = plants.firstIndex(of: plant) {
            plants[index].isWateredToday.toggle()
        }
    }
}
