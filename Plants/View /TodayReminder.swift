//
//  TodayReminder.swift
//  Plants
//
//  Created by Raghad Aljuid on 29/04/1447 AH.
//
import SwiftUI

struct MyPlantsView: View {
    @ObservedObject var viewModel: PlantViewModel   // ← بدلاً من @Binding [Plant]
    @State private var showSetReminder = false
    @State private var editingPlant: Plant? = nil
    @State private var openRow: UUID? = nil

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

                // إذا الكل مروّي اليوم أعرض All Done و"بدون" الشريط العلوي
                if allWatered && !viewModel.plants.isEmpty {
                    GeometryReader { geo in
                        VStack(spacing: 0) {
                            Spacer().frame(height: geo.size.height * 0.18)
                            AllDoneView()
                            Spacer().frame(height: geo.size.height * 0.18)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .transition(.opacity)
                    .frame(maxHeight: .infinity)
                } else {
                    // Status + progress (يظهر فقط إذا ما اكتملت)
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
                                SwipeableRow(
                                    id: plant.id,
                                    openRow: $openRow,
                                    onDelete: { delete(plant: plant) }   // ← عبر دالة تستخدم الـ ViewModel
                                ) {
                                    PlantRow(
                                        plant: plant,
                                        chipBG: chipBG,
                                        chipSunText: chipSunText,
                                        chipWaterText: chipWaterText,
                                        checkActive: checkActive
                                    ) {
                                        toggleWater(for: plant)          // ← عبر الـ ViewModel
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                    .onTapGesture { editingPlant = plant }
                                }

                                Divider()
                                    .overlay(Color.white.opacity(0.12))
                                    .padding(.leading, 16)
                            }
                            Spacer(minLength: 40)
                        }
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
                viewModel.addPlant(plant: newPlant)   // ← إضافة عبر الـ ViewModel
            }
            .presentationDetents([.large])
            .presentationCornerRadius(28)
        }
        // تعديل/حذف
        .sheet(item: $editingPlant) { plant in
            let currentIndex = viewModel.plants.firstIndex(of: plant)
            SetReminderView(
                existing: plant,
                onSave: { updated in
                    // تحديث العنصر في الـ ViewModel عبر معرّفه
                    let targetID = currentIndex.flatMap { _ in plant.id } ?? plant.id
                    viewModel.updatePlant(id: targetID, with: updated)
                },
                onDelete: {
                    if let idx = currentIndex ?? viewModel.plants.firstIndex(of: plant) {
                        let toDelete = viewModel.plants[idx]
                        viewModel.deletePlant(plant: toDelete)
                    }
                }
            )
            .presentationDetents([.large])
            .presentationCornerRadius(28)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Helpers
    private var plants: [Plant] { viewModel.plants }

    private var wateredCount: Int { plants.filter { $0.isWateredToday }.count }

    private var progressValue: CGFloat {
        guard !plants.isEmpty else { return 0 }
        return CGFloat(wateredCount) / CGFloat(plants.count)
    }

    private var allWatered: Bool {
        !plants.isEmpty && plants.allSatisfy { $0.isWateredToday }
    }

    private var statusText: String {
        if plants.isEmpty { return "Add your first plant 🌱" }
        if wateredCount == 0 { return "Your plants are waiting for a sip 💦" }
        else if wateredCount >= 3 { return "3 of your plants feel loved today ✨" }
        else { return "\(wateredCount) of your plants feel loved today ✨" }
    }

    // ترتيب: غير المسقي أولاً، ثم المسقي، وSpider دائماً بالنهاية
    private var sortedPlants: [Plant] {
        let notSpider = plants.filter { $0.name.caseInsensitiveCompare("Spider") != .orderedSame }
        let spider    = plants.filter { $0.name.caseInsensitiveCompare("Spider") == .orderedSame }

        let unwatered = notSpider.filter { !$0.isWateredToday }
        let watered   = notSpider.filter {  $0.isWateredToday }

        return unwatered + watered + spider
    }

    private func toggleWater(for plant: Plant) {
        viewModel.toggleWater(for: plant)   // ← عبر الـ ViewModel
    }

    // دالة الحذف (سوايب)
    private func delete(plant: Plant) {
        withAnimation(.easeInOut) {
            viewModel.deletePlant(plant: plant)   // ← عبر الـ ViewModel
        }
    }

    // شاشة “All Done!”
    private struct AllDoneView: View {
        var body: some View {
            VStack(spacing: 24) {
                Image("Alldone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .shadow(radius: 12, y: 6)

                Text("All Done! 🎉")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(.white)

                Text("All Reminders Completed")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
    }
}
