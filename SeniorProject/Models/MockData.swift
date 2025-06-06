import Foundation

struct MockData {
    static let clubs: [Club] = [
        Club(
            name: "Chess Club",
            description: "Join us for strategic gameplay and friendly competition. All skill levels welcome!",
            category: .academic,
            tags: ["strategy", "games", "competition"],
            schoolID: UUID(),
            meetingSchedule: "Every Tuesday 11:45-12:15 PM",
            meetingLocation: "Room 204",
            logo: "chess-club",
            memberIDs: [UUID(), UUID(), UUID(), UUID(), UUID()],
            leadershipRoles: [
                ClubLeadershipRole(
                    userID: UUID(),
                    role: "President",
                    permissions: LeadershipPermissions(permissions: [.manageClub, .manageMembership, .postAnnouncements, .editClubInfo])
                )
            ],
            isApproved: true,
            requiresApplicationToJoin: false
        ),
        Club(
            name: "Boys Mental Health Club",
            description: "A safe space for boys to discuss mental health, share experiences, and support each other. We focus on emotional well-being, stress management, and building healthy relationships.",
            category: .affinity,
            tags: ["mental health", "support", "wellness"],
            schoolID: UUID(),
            meetingSchedule: "Every Friday 11:45-12:15 PM",
            meetingLocation: "Room 302",
            logo: "bmh-club",
            memberIDs: [UUID(), UUID(), UUID(), UUID()],
            leadershipRoles: [
                ClubLeadershipRole(
                    userID: UUID(),
                    role: "Founder",
                    permissions: LeadershipPermissions(permissions: [.manageClub, .manageMembership, .postAnnouncements, .editClubInfo])
                )
            ],
            isApproved: true,
            requiresApplicationToJoin: false
        ),
        Club(
            name: "Computer Science Club",
            description: "Learn programming, algorithms, and software development. Work on projects, participate in hackathons, and prepare for coding competitions. All skill levels welcome!",
            category: .stem,
            tags: ["programming", "technology", "coding"],
            schoolID: UUID(),
            meetingSchedule: "Every Monday and Wednesday 12:10-12:40 PM",
            meetingLocation: "CS Lab",
            logo: "cs-club",
            memberIDs: [UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID()],
            leadershipRoles: [
                ClubLeadershipRole(
                    userID: UUID(),
                    role: "President",
                    permissions: LeadershipPermissions(permissions: [.manageClub, .manageMembership, .postAnnouncements, .editClubInfo])
                ),
                ClubLeadershipRole(
                    userID: UUID(),
                    role: "Vice President",
                    permissions: LeadershipPermissions(permissions: [.manageMembership, .postAnnouncements])
                )
            ],
            isApproved: true,
            requiresApplicationToJoin: true
        ),
        Club(
            name: "Law Club",
            description: "Explore legal concepts, debate current legal issues, and prepare for mock trials. Perfect for students interested in law, politics, or public speaking.",
            category: .academic,
            tags: ["law", "debate", "politics"],
            schoolID: UUID(),
            meetingSchedule: "Every Friday 12:10-12:40 PM",
            meetingLocation: "Room 105",
            logo: "law-club",
            memberIDs: [UUID(), UUID(), UUID(), UUID(), UUID()],
            leadershipRoles: [
                ClubLeadershipRole(
                    userID: UUID(),
                    role: "President",
                    permissions: LeadershipPermissions(permissions: [.manageClub, .manageMembership, .postAnnouncements, .editClubInfo])
                )
            ],
            isApproved: true,
            requiresApplicationToJoin: false
        ),
        Club(
            name: "Debate Team",
            description: "Develop critical thinking and public speaking skills through competitive debate.",
            category: .academic,
            tags: ["debate", "public speaking", "critical thinking"],
            schoolID: UUID(),
            meetingSchedule: "Every Tuesday and Thursday 11:45-12:15 PM",
            meetingLocation: "Cafeteria",
            logo: "debate-team",
            memberIDs: [UUID(), UUID(), UUID(), UUID(), UUID(), UUID()],
            leadershipRoles: [
                ClubLeadershipRole(
                    userID: UUID(),
                    role: "Captain",
                    permissions: LeadershipPermissions(permissions: [.manageClub, .manageMembership, .postAnnouncements, .editClubInfo])
                )
            ],
            isApproved: true,
            requiresApplicationToJoin: true
        ),
        Club(
            name: "Art Club",
            description: "Express your creativity through various art forms including painting, drawing, and digital art.",
            category: .arts,
            tags: ["art", "creativity", "expression"],
            schoolID: UUID(),
            meetingSchedule: "Every Wednesday 12:10-12:40 PM",
            meetingLocation: "Art Studio",
            logo: "art-club",
            memberIDs: [UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID(), UUID()],
            leadershipRoles: [
                ClubLeadershipRole(
                    userID: UUID(),
                    role: "President",
                    permissions: LeadershipPermissions(permissions: [.manageClub, .manageMembership, .postAnnouncements, .editClubInfo])
                )
            ],
            isApproved: true,
            requiresApplicationToJoin: false
        ),
        Club(
            name: "Robotics Team",
            description: "Design, build, and program robots for competitions. Learn engineering and programming skills.",
            category: .stem,
            tags: ["robotics", "engineering", "programming"],
            schoolID: UUID(),
            meetingSchedule: "Every Monday and Thursday 12:10-12:40 PM",
            meetingLocation: "Engineering Lab",
            logo: "robotics-team",
            memberIDs: [UUID(), UUID(), UUID(), UUID(), UUID(), UUID()],
            leadershipRoles: [
                ClubLeadershipRole(
                    userID: UUID(),
                    role: "Team Captain",
                    permissions: LeadershipPermissions(permissions: [.manageClub, .manageMembership, .postAnnouncements, .editClubInfo])
                )
            ],
            isApproved: true,
            requiresApplicationToJoin: true
        )
    ]
    
    static let announcements: [Announcement] = [
        Announcement(
            clubID: UUID(),
            authorID: UUID(),
            title: "Chess Tournament This Weekend",
            content: "Join us for our annual chess tournament! Prizes will be awarded to the top three players. All skill levels are welcome to participate. Registration closes on Friday at 3 PM.",
            creationDate: Date(),
            isPinned: true,
            reactions: [UUID(): .like, UUID(): .like, UUID(): .love]
        ),
        Announcement(
            clubID: UUID(),
            authorID: UUID(),
            title: "Art Exhibition Opening",
            content: "Our spring art exhibition opens this Friday at 4 PM in the school gallery. Come support our talented artists and enjoy refreshments! The exhibition will feature works from all our members.",
            creationDate: Date().addingTimeInterval(-86400),
            isPinned: false,
            reactions: [UUID(): .love, UUID(): .wow]
        ),
        Announcement(
            clubID: UUID(),
            authorID: UUID(),
            title: "Robotics Competition Results",
            content: "Congratulations to our team for winning first place in the regional competition! Special thanks to all team members for their hard work and dedication. We'll be moving on to the state finals next month!",
            creationDate: Date().addingTimeInterval(-172800),
            isPinned: true,
            reactions: [UUID(): .like, UUID(): .love, UUID(): .wow]
        ),
        Announcement(
            clubID: UUID(),
            authorID: UUID(),
            title: "Debate Team Practice Schedule",
            content: "Important: Debate team practice will be held in the library this week due to cafeteria renovations. Please bring your research materials and be prepared for mock debates.",
            creationDate: Date().addingTimeInterval(-259200),
            isPinned: true,
            reactions: [UUID(): .like]
        ),
        Announcement(
            clubID: UUID(),
            authorID: UUID(),
            title: "Computer Science Club Workshop",
            content: "This Saturday, we'll be hosting a special workshop on mobile app development. Bring your laptops and get ready to learn about Swift programming! Snacks will be provided.",
            creationDate: Date().addingTimeInterval(-345600),
            isPinned: false,
            reactions: [UUID(): .like, UUID(): .wow]
        )
    ]
    
    static let events: [Event] = [
        Event(
            clubID: UUID(),
            name: "Chess Tournament",
            description: "Annual chess tournament with prizes for top players. All skill levels welcome!",
            startTime: Date().addingTimeInterval(86400),
            endTime: Date().addingTimeInterval(93600),
            location: "Room 204",
            isRequired: false,
            creatorID: UUID(),
            attendeeIDs: [UUID(), UUID(), UUID(), UUID()]
        ),
        Event(
            clubID: UUID(),
            name: "Art Exhibition",
            description: "Spring art exhibition featuring student works. Refreshments will be served.",
            startTime: Date().addingTimeInterval(172800),
            endTime: Date().addingTimeInterval(259200),
            location: "School Gallery",
            isRequired: false,
            creatorID: UUID(),
            attendeeIDs: [UUID(), UUID(), UUID(), UUID(), UUID()]
        ),
        Event(
            clubID: UUID(),
            name: "Robotics Workshop",
            description: "Learn basic robotics programming and build your first robot!",
            startTime: Date().addingTimeInterval(259200),
            endTime: Date().addingTimeInterval(266400),
            location: "Science Lab 3",
            isRequired: true,
            creatorID: UUID(),
            attendeeIDs: [UUID(), UUID(), UUID()]
        ),
        Event(
            clubID: UUID(),
            name: "Debate Team Practice",
            description: "Regular practice session with focus on argumentation and public speaking.",
            startTime: Date().addingTimeInterval(43200),
            endTime: Date().addingTimeInterval(50400),
            location: "Library",
            isRequired: true,
            creatorID: UUID(),
            attendeeIDs: [UUID(), UUID(), UUID(), UUID(), UUID()]
        ),
        Event(
            clubID: UUID(),
            name: "CS Club Hackathon",
            description: "24-hour coding competition with prizes for best projects.",
            startTime: Date().addingTimeInterval(345600),
            endTime: Date().addingTimeInterval(432000),
            location: "CS Lab",
            isRequired: false,
            creatorID: UUID(),
            attendeeIDs: [UUID(), UUID(), UUID(), UUID(), UUID(), UUID()]
        )
    ]
} 
