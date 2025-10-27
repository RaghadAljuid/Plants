//
//  Plant.swift
//  Plants
//
//  Created by Raghad Aljuid on 27/04/1447 AH.
//
import Foundation

struct Plant: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var room: String
    var light: String
    var waterAmount: String
    var isWateredToday: Bool = false
}
