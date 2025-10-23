//
//  TodayReminder.swift
//  Plants
//
//  Created by Raghad Aljuid on 29/04/1447 AH.
//
import SwiftUI

struct MyPlantsView: View {
    @Binding var plants: [Plant]
    @State private var showSetReminder = false

    // بدل showEditSheet + editIndex نستخدم عنصر اختياري
    @State private var editingPlant: Plant? = nil

    // Colors
    private let bg = Color.black
    private let chipBG = Color(hex: "#18181D")
    private let chipSunText = Color(hex: "#E2DDA3")
    private let chipWaterText = Color(hex: "#CFE8F6")
    private let progressIdle = Color.white.opacity(0.15)
    private let progressActive = Color(hex: "#28E0A8")
    private let checkActive = Color(hex: "#28E0A8")

    var body: some View {
        ZStack { bg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Title
                HStack {
                    Text("My Plants 🌱")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Divider()
                    .overlay(Color.white.opacity(0.08))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 14)

                // Status + progress
                VStack(alignment: .leading, spacing: 12) {
                    Text(statusText)
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(progressIdle).frame(height: 10)
                            Capsule()
                                .fill(progressActive)
                                .frame(width: max(0, geo.size.width * progressValue), height: 10)
                                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: progressValue)
                        }
                    }
                    .frame(height: 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                // List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(sortedPlants) { plant in
                            PlantRow(
                                plant: plant,
                                chipBG: chipBG,
                                chipSunText: chipSunText,
                                chipWaterText: chipWaterText,
                                checkActive: checkActive
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    toggleWater(for: plant)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // افتح شاشة التعديل لهذا العنصر
                                editingPlant = plant
                            }
                            Divider()
                                .overlay(Color.white.opacity(0.12))
                                .padding(.leading, 16)
                        }
                        Spacer(minLength: 40)
                    }
                }

                // Floating add button
                HStack {
                    Spacer()
                    Button { showSetReminder = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle().fill(
                                    LinearGradient(colors: [checkActive, Color(hex: "#1EBE8E")],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                            )
                            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
                            .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 8)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 22)
                }
                .ignoresSafeArea()
            }
        }
        // إضافة جديدة
        .sheet(isPresented: $showSetReminder) {
            SetReminderView { newPlant in
                plants.append(newPlant)
            }
            .presentationDetents([.large])
            .presentationCornerRadius(28)
        }
        // تعديل/حذف باستخدام item آمن
        .sheet(item: $editingPlant) { plant in
            // احصل على index الحالي (قد يتغير بسبب حذف/فرز)
            let currentIndex = plants.firstIndex(of: plant)
            SetReminderView(
                existing: plant,
                onSave: { updated in
                    if let idx = currentIndex ?? plants.firstIndex(of: plant) {
                        plants[idx] = updated
                    }
                },
                onDelete: {
                    if let idx = currentIndex ?? plants.firstIndex(of: plant) {
                        plants.remove(at: idx)
                    }
                }
            )
            .presentationDetents([.large])
            .presentationCornerRadius(28)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Helpers
    private var wateredCount: Int { plants.filter { $0.isWateredToday }.count }
    private var progressValue: CGFloat {
        guard !plants.isEmpty else { return 0 }
        return CGFloat(wateredCount) / CGFloat(plants.count)
    }

    private var statusText: String {
        if wateredCount == 0 { return "Your plants are waiting for a sip 💦" }
        else if wateredCount >= 3 { return "3 of your plants feel loved today ✨" }
        else { return "\(wateredCount) of your plants feel loved today ✨" }
    }

    // Spider دائمًا في النهاية
    private var sortedPlants: [Plant] {
        let nonSpider = plants.filter { $0.name.caseInsensitiveCompare("Spider") != .orderedSame }
        let spider    = plants.filter { $0.name.caseInsensitiveCompare("Spider") == .orderedSame }
        return nonSpider + spider
    }

    private func toggleWater(for plant: Plant) {
        if let idx = plants.firstIndex(of: plant) {
            plants[idx].isWateredToday.toggle()
        }
    }
}
