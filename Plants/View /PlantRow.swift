//
//  PlantRow.swift
//  Plants
//
//  Created by You on 01/05/1447 AH.
//

import SwiftUI

struct PlantRow: View {
    let plant: Plant

    // ألوان  من MyPlantsView
    let chipBG: Color
    let chipSunText: Color
    let chipWaterText: Color
    let checkActive: Color

    var onToggleWater: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // زر التحقق (ماء اليوم)
            Button(action: onToggleWater) {
                Image(systemName: plant.isWateredToday ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(plant.isWateredToday ? checkActive : .white.opacity(0.35))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 8) {
                // الغرفة
                HStack(spacing: 6) {
                    Image(systemName: "location")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 12, weight: .semibold))
                    Text("in \(plant.room)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }

                // اسم النبتة
                Text(plant.name)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)

                // الشرائط (Light + Water)
                HStack(spacing: 10) {
                    ChipView(text: plant.light, textColor: chipSunText, bg: chipBG, icon: "sun.max")
                    ChipView(text: plant.waterAmount, textColor: chipWaterText, bg: chipBG, icon: "drop")
                }
            }

            Spacer(minLength: 0)
        }
    }
}

private struct ChipView: View {
    let text: String
    let textColor: Color
    let bg: Color
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(textColor.opacity(0.95))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(bg)
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}
