//
//  DateHeadere.swift
//  UniMate
//
//  Created by Sheky Cheung on 26/11/2024.
//
import SwiftUI

struct DateHeader: View {
    let date: Date
    
    var body: some View {
        Text(formatDate(date))
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
    }
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}
