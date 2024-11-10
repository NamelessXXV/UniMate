HKUConnect - iOS Application Project Overview
1. Core Features
- Authentication System
  - HKU Email Domain (@connect.hku.hk) verification
  - Login Methods:
    - Face ID (default if allowed)
    - Password (no specific requirements)
    - Password reset via email
  - No Touch ID support

- Chat System
  - Individual and Group Chats
    - Max 15 groups per user creation limit
    - No member limit in groups
    - All media types allowed
    - Message editing/deletion enabled
  - Local Storage Only
    - Clear chat history option per conversation
    - Display total storage size
    - No chat backup/export feature
    - No online/offline status display
    
- Match System (400m Radius)
  - User Display:
    - Shows all users within radius
    - Displays name and tags
    - No online/offline status
  - Connection System:
    - Connection requests appear as messages in chat
    - Requester can't send more messages until accepted
    - No time limit for accepting requests
    - Chat deletion serves as blocking mechanism
    
- Tags System
  - Maximum 6 tags per user
  - Tag Rules:
    - 30 character limit
    - Case insensitive
    - Spaces replaced with underscores
    - Emojis allowed (count toward character limit)
    - No tag suggestions
    - User-defined (no predefined tags)
    
- Forum
  - Categories:
    - Student life
    - Buy/Sell
    - Lost and Found
    - Course discussions
    - News about school
  - Features:
    - Multiple category posting
    - Required: title and content
    - Optional: additional media
    - Like, comment, save functions
    - Keyword search in titles
  - Sections:
    - Latest posts
    - Trending (based on comments/24h and views)
    
- Profile
  - Information:
    - Username (non-unique, changeable)
    - Profile picture
    - Academic status (undergraduate/postgraduate/PhD)
    - Tags
  - Privacy:
    - Profile visible to connected users
    - Anyone within range can send requests
    
- Notifications
  - New chat messages
  - Connection requests
  - Accepted connections
  - Group chat mentions
  
2. Technical Specifications

- Platform Requirements
  - SwiftUI interface
  - Swift programming language
  - Xcode 15 or above
  - Minimum iOS 15.0
  - Portrait orientation only
  - Dark mode support
  - No Dynamic Type support
  
- Required Technologies (From Course)
  - List and Navigation
  - JSON & iOS Networking
  - Core Data
  - Map and Location
  - Advanced Map Services
  - Camera and Photo
  - Augmented Reality
  
- Future Feature (Independent)

  - AR Campus Messages:
    - Allow users to leave virtual messages/drawings at specific locations
    - Viewable through app's camera
    - Location-based persistence
  
- Implementation Approach
  - Minimize third-party packages
  - Custom implementations for core features:
    - Networking layer
    - Image caching
    - Data persistence
  - Local data storage for chats
  - No content moderation system

```
UniMate/
├── App/
│   ├── UniMateApp.swift          // Main app entry point, setup app environment
│   └── AppDelegate.swift         // Firebase configuration and app delegate lifecycle
│
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   │   ├── LoginView.swift         // Login screen UI
│   │   │   ├── SignUpView.swift        // Registration screen UI
│   │   │   └── AuthenticationView.swift // Container view for auth flow
│   │   ├── ViewModels/
│   │   │   └── AuthViewModel.swift      // Handles auth business logic and Firebase Auth
│   │   └── Models/
│   │       └── User.swift               // User data model and Codable conformance
│   │
│   ├── Profile/
│   │   ├── Views/
│   │   │   ├── ProfileView.swift        // User profile display
│   │   │   └── EditProfileView.swift    // Profile editing screen
│   │   ├── ViewModels/
│   │   │   └── ProfileViewModel.swift    // Profile data management and updates
│   │   └── Models/
│   │       └── Profile.swift             // Profile data structure
│   │
│   ├── Match/
│   │   ├── Views/
│   │   │   ├── MatchView.swift          // Main matching interface
│   │   │   └── MatchDetailView.swift    // Detailed match profile view
│   │   ├── ViewModels/
│   │   │   └── MatchViewModel.swift      // Matching logic and algorithms
│   │   └── Models/
│   │       └── Match.swift               // Match data structure
│   │
│   ├── Chat/
│   │   ├── Views/
│   │   │   ├── ChatListView.swift       // List of chat conversations
│   │   │   └── ChatDetailView.swift     // Individual chat conversation
│   │   ├── ViewModels/
│   │   │   └── ChatViewModel.swift       // Real-time chat management
│   │   └── Models/
│   │       ├── Message.swift             // Message data structure
│   │       └── ChatRoom.swift            // Chat room data structure
│   │
│   └── Forum/
│       ├── Views/
│       │   ├── ForumListView.swift      // List of forum posts
│       │   └── PostDetailView.swift     // Individual post with comments
│       ├── ViewModels/
│       │   └── ForumViewModel.swift      // Forum data management
│       └── Models/
│           ├── Post.swift                // Post data structure
│           └── Comment.swift             // Comment data structure
│
├── Core/
│   ├── Services/
│   │   ├── FirebaseService.swift        // Firebase operations wrapper
│   │   ├── AuthService.swift            // Authentication service
│   │   ├── StorageService.swift         // Firebase Storage operations
│   │   └── ImageService.swift           // Image loading and caching
│   │
│   ├── Persistence/
│   │   ├── Persistence.swift            // Core Data stack and setup
│   │   ├── PersistenceController.swift  // Manages Core Data operations
│   │   └── UniMate.xcdatamodeld         // Core Data model file
│   │
│   ├── Extensions/
│   │   ├── Color+Extension.swift        // Custom color definitions
│   │   ├── Date+Extension.swift         // Date formatting utilities
│   │   └── String+Extension.swift       // String validation and formatting
│   │
│   └── Utilities/
│       ├── Constants.swift              // App-wide constants
│       ├── Validators.swift             // Input validation
│       └── ErrorHandling.swift          // Custom error types and handling
│
├── UI/
│   ├── Components/
│   │   ├── CustomButton.swift           // Reusable button styles
│   │   ├── CustomTextField.swift        // Custom text input fields
│   │   ├── LoadingView.swift            // Loading animation view
│   │   ├── MessageBubble.swift          // Chat message bubble
│   │   └── UserAvatar.swift             // User profile image view
│   │
│   ├── Styles/
│   │   ├── AppColors.swift              // App color scheme
│   │   └── AppFonts.swift               // Typography definitions
│   │
│   └── Modifiers/
│       └── ViewModifiers.swift          // Custom SwiftUI view modifiers
│
└── Resources/
    ├── GoogleService-Info.plist         // Firebase configuration file
    ├── Info.plist                       // App configuration
    └── Assets.xcassets                  // App images and assets
```
