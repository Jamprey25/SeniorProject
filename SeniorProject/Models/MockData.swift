import Foundation

struct MockData {
    static let clubs: [club] = [
        club(
            name: "Chess Club",
            description: "Join us for strategic gameplay and friendly competition. All skill levels welcome!",
            category: .academic,
            tags: ["strategy", "games", "competition"],
            schoolID: UUID(),
            meetingSchedule: "Every Tuesday 3:30-5:00 PM",
            meetingLocation: "Room 204",
            memberIDs: [],
            leadershipRoles: [],
            isApproved: true,
            requiresApplicationToJoin: false
        ),
        club(
            name: "Boys Mental Health Club",
            description: "A safe space for boys to discuss mental health, share experiences, and support each other. We focus on emotional well-being, stress management, and building healthy relationships.",
            category: .affinity,
            tags: ["mental health", "support", "wellness"],
            schoolID: UUID(),
            meetingSchedule: "Every Thursday 3:30-5:00 PM",
            meetingLocation: "Room 302",
            memberIDs: [],
            leadershipRoles: [],
            isApproved: true,
            requiresApplicationToJoin: false
        ),
        club(
            name: "Computer Science Club",
            description: "Learn programming, algorithms, and software development. Work on projects, participate in hackathons, and prepare for coding competitions. All skill levels welcome!",
            category: .stem,
            tags: ["programming", "technology", "coding"],
            schoolID: UUID(),
            meetingSchedule: "Every Monday and Wednesday 3:30-5:30 PM",
            meetingLocation: "Computer Lab",
            memberIDs: [],
            leadershipRoles: [],
            isApproved: true,
            requiresApplicationToJoin: true
        ),
        club(
            name: "Law Club",
            description: "Explore legal concepts, debate current legal issues, and prepare for mock trials. Perfect for students interested in law, politics, or public speaking.",
            category: .academic,
            tags: ["law", "debate", "politics"],
            schoolID: UUID(),
            meetingSchedule: "Every Friday 3:30-4:30 PM",
            meetingLocation: "Room 105",
            memberIDs: [],
            leadershipRoles: [],
            isApproved: true,
            requiresApplicationToJoin: false
        ),
        club(
            name: "Debate Team",
            description: "Develop critical thinking and public speaking skills through competitive debate.",
            category: .academic,
            tags: ["debate", "public speaking", "critical thinking"],
            schoolID: UUID(),
            meetingSchedule: "Every Tuesday and Thursday 6:30-8:00PM",
            meetingLocation: "Cafateria ",
            memberIDs: [],
            leadershipRoles: [],
            isApproved: true,
            requiresApplicationToJoin: true
        )
    ]
    
    static let announcements: [Announcement] = [
        Announcement(
            clubID: UUID(),
            authorID: UUID(),
            title: "Chess Tournament This Weekend",
            content: "Join us for our annual chess tournament! Prizes will be awarded to the top three players.",
            creationDate: Date(),
            isPinned: true,
            reactions: [:]
        ),
        Announcement(
            clubID: UUID(),
            authorID: UUID(),
            title: "Art Exhibition Opening",
            content: "Our spring art exhibition opens this Friday. Come support our talented artists!",
            creationDate: Date().addingTimeInterval(-86400),
            isPinned: false,
            reactions: [:]
        ),
        Announcement(
            clubID: UUID(),
            authorID: UUID(),
            title: "Robotics Competition Results",
            content: "Congratulations to our team for winning first place in the regional competition!",
            creationDate: Date().addingTimeInterval(-172800),
            isPinned: true,
            reactions: [:]
        )
    ]
    
    static let events: [Event] = [
        Event(
            clubID: UUID(),
            name: "Chess Tournament",
            description: "Annual chess tournament with prizes for top players",
            startTime: Date().addingTimeInterval(86400),
            endTime: Date().addingTimeInterval(93600),
            location: "Room 204",
            isRequired: false,
            creatorID: UUID(),
            attendeeIDs: []
        ),
        Event(
            clubID: UUID(),
            name: "Art Exhibition",
            description: "Spring art exhibition featuring student works",
            startTime: Date().addingTimeInterval(172800),
            endTime: Date().addingTimeInterval(259200),
            location: "School Gallery",
            isRequired: false,
            creatorID: UUID(),
            attendeeIDs: []
        ),
        Event(
            clubID: UUID(),
            name: "Robotics Workshop",
            description: "Learn basic robotics programming",
            startTime: Date().addingTimeInterval(259200),
            endTime: Date().addingTimeInterval(266400),
            location: "Science Lab 3",
            isRequired: true,
            creatorID: UUID(),
            attendeeIDs: []
        )
    ]
} 