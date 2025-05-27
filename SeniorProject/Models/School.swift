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
    
    
    mutating func addAdministrator(adminID: UUID) {
        if !administratorIDs.contains(adminID) {
            administratorIDs.append(adminID)
        }
    }
    
   
    mutating func removeAdministrator(adminID: UUID) {
        administratorIDs.removeAll { $0 == adminID }
    }
    
   
    func isAdministrator(userID: UUID) -> Bool {
        return administratorIDs.contains(userID)
    }
    
  
    func getAdministratorCount() -> Int {
        return administratorIDs.count
    }
    
   
    mutating func addClub(clubID: UUID) {
        if !clubIDs.contains(clubID) {
            clubIDs.append(clubID)
        }
    }
    
   
    mutating func removeClub(clubID: UUID) {
        clubIDs.removeAll { $0 == clubID }
    }
    
    
    func hasClub(clubID: UUID) -> Bool {
        return clubIDs.contains(clubID)
    }
    
   
    func getClubCount() -> Int {
        return clubIDs.count
    }
    
   
    mutating func updateName(_ newName: String) {
        self.name = newName
    }
    
  
    func isValidEmailDomain(_ email: String) -> Bool {
        return email.hasSuffix(domain)
    }
    
    
    func getSchoolInfo() -> [String: Any] {
        return [
            "name": name,
            "domain": domain,
            "administratorCount": administratorIDs.count,
            "clubCount": clubIDs.count
        ]
    }
}
