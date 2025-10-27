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
                    ChipView(text: plant.light, textColor: chipSunText, textIconColor: chipSunText.opacity(0.95), bg: chipBG, icon: "sun.max")
                    ChipView(text: plant.waterAmount, textColor: chipWaterText, textIconColor: chipWaterText.opacity(0.95), bg: chipBG, icon: "drop")
                }
            }

            Spacer(minLength: 0)
        }
        // تأثير بصري خفي حسب حالة السقي
        .padding(.vertical, 2)
        .background(
            // للمسقي: طبقة خفيفة جداً
            (plant.isWateredToday ? Color.white.opacity(0.02) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        )
        .overlay(
            // خط خارجي شبه معدوم للمسقي فقط
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(plant.isWateredToday ? Color.white.opacity(0.05) : Color.clear, lineWidth: 1)
        )
        // ظل خفيف جداً أخضر للمسقي، وظل شبه معدوم لغير المسقي
        .shadow(color: plant.isWateredToday ? checkActive.opacity(0.12) : .black.opacity(0.15),
                radius: plant.isWateredToday ? 6 : 4,
                x: 0, y: plant.isWateredToday ? 3 : 2)
        .opacity(plant.isWateredToday ? 0.92 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.95), value: plant.isWateredToday)
    }
}

private struct ChipView: View {
    let text: String
    let textColor: Color
    let textIconColor: Color
    let bg: Color
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(textIconColor)
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
