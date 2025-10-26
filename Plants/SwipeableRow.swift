//
//  SwipeableRow.swift
//  Planto
//
//  Created by Raghad Aljuid on 04/05/1447 AH.
//
import SwiftUI

struct SwipeableRow<Content: View>: View {
    let id: UUID
    let actionWidth: CGFloat
    let onDelete: () -> Void
    @Binding var openRow: UUID?
    @ViewBuilder var content: () -> Content

    @State private var offsetX: CGFloat = 0
    @State private var isDragging = false

    init(id: UUID,
         actionWidth: CGFloat = 88,
         openRow: Binding<UUID?>,
         onDelete: @escaping () -> Void,
         @ViewBuilder content: @escaping () -> Content) {
        self.id = id
        self.actionWidth = actionWidth
        self._openRow = openRow
        self.onDelete = onDelete
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            // مساحة الأكشن (شفافة) مع زر دائري
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                deleteButton
                    .frame(width: actionWidth) // يضمن وجود مساحة للسحب
                    .frame(maxHeight: .infinity, alignment: .center)
            }

            // المحتوى الأمامي
            content()
                .background(Color.black) // نفس خلفيتك
                .offset(x: offsetX)
                .gesture(drag)
                .onChange(of: openRow) { _, new in
                    if new != id && offsetX != 0 {
                        withAnimation(.spring()) { offsetX = 0 }
                    }
                }
                .onTapGesture {
                    if openRow != nil {
                        withAnimation(.spring()) {
                            openRow = nil
                            offsetX = 0
                        }
                    }
                }
        }
        .clipped()
    }

    // زر دائري مطابق للسكيتش
    private var deleteButton: some View {
        Button(role: .destructive, action: {
            withAnimation(.spring()) {
                onDelete()
                openRow = nil
                offsetX = 0
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.red)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 8)

                Image(systemName: "trash")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 16) // يبعد الزر عن الحافة
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                isDragging = true
                let t = min(0, value.translation.width) // لليسار فقط
                offsetX = max(t, -actionWidth)          // لا تتجاوز المساحة
                if offsetX == -actionWidth { openRow = id }
            }
            .onEnded { value in
                isDragging = false
                let shouldOpen = (value.translation.width < -actionWidth * 0.4)
                withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                    offsetX = shouldOpen ? -actionWidth : 0
                    openRow = shouldOpen ? id : nil
                }
            }
    }
}

