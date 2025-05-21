//
//  School.swift
//  SeniorProject
//
//  Created by Joseph Amprey on 5/20/25.
//
import Foundation
struct School:  Identifiable {
    let id: UUID
    var name: String
    let domain: String
    //var logoURL: URL?
    var administratorIDs: [UUID]
    var clubIDs: [UUID]
    init(id: UUID = UUID(),
         name: String,
         domain: String,
         administratorIDs: [UUID] = [],
         clubIDs: [UUID] = []) {
        self.id = id
            self.name = name
            self.domain = domain
            self.administratorIDs = administratorIDs
            self.clubIDs = clubIDs
        }
    
    
    
    
    
    
}
