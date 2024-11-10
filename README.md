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
│   ├── UniMateApp.swift          // App entry point
│   └── AppDelegate.swift         // App lifecycle management
│
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   │   ├── LoginView.swift         // Login with Face ID/Password
│   │   │   ├── ResetPasswordView.swift  // Password reset via email
│   │   │   └── EmailVerificationView.swift // HKU email verification
│   │   ├── ViewModels/
│   │   │   └── AuthViewModel.swift      // Auth logic for HKU domain
│   │   └── Models/
│   │       └── User.swift               // User with HKU specific fields
│   │
│   ├── Profile/
│   │   ├── Views/
│   │   │   ├── ProfileView.swift        // Shows username, picture, academic status
│   │   │   └── EditProfileView.swift    // Edit profile and tags (max 6)
│   │   ├── ViewModels/
│   │   │   └── ProfileViewModel.swift    // Profile and tags management
│   │   └── Models/
│   │       └── Profile.swift             // Profile with tags structure
│   │
│   ├── Match/
│   │   ├── Views/
│   │   │   ├── NearbyUsersView.swift    // 400m radius user display
│   │   │   └── UserDetailView.swift     // Show user tags and connection option
│   │   ├── ViewModels/
│   │   │   └── MatchViewModel.swift      // Nearby users and connection logic
│   │   └── Models/
│   │       └── Connection.swift          // Connection request structure
│   │
│   ├── Chat/
│   │   ├── Views/
│   │   │   ├── ChatListView.swift       // Individual and group chats (max 15)
│   │   │   ├── ChatDetailView.swift     // Chat with media support
│   │   │   └── StorageView.swift        // Shows chat storage usage
│   │   ├── ViewModels/
│   │   │   └── ChatViewModel.swift       // Local chat management
│   │   └── Models/
│   │       ├── Message.swift             // Message with edit/delete
│   │       └── ChatRoom.swift            // Chat room with storage info
│   │
│   └── Forum/
│       ├── Views/
│       │   ├── ForumListView.swift      // Latest and trending posts
│       │   ├── CategoryView.swift       // 5 main categories view
│       │   └── PostDetailView.swift     // Post with media, likes, comments
│       ├── ViewModels/
│       │   └── ForumViewModel.swift      // Posts and engagement management
│       └── Models/
│           ├── Post.swift                // Post with multi-category support
│           └── Comment.swift             // Comment structure
│
├── Core/
│   ├── Location/
│   │   ├── LocationManager.swift        // 400m radius tracking
│   │   └── LocationPermission.swift     // Location authorization
│   │
│   ├── Extensions/
│   │   └── String+TagValidation.swift   // Tag formatting rules
│   │
│   └── Utilities/
│       ├── StorageCalculator.swift      // Chat storage size calculation
│       └── NotificationManager.swift     // Local notifications handling
│
├── UI/
│   ├── Theme/
│   │   └── AppTheme.swift              // Global app styling
│   │
│   └── Components/
│       ├── CommonButton.swift           // Reusable button styles
│       ├── CommonTextField.swift        // Reusable text field
│       ├── ImagePicker.swift            // Profile picture & media attachment selector
│       ├── TagInput.swift              // Tag creation and management
│       ├── LoadingView.swift           // Loading indicator
│       └── EmptyStateView.swift        // Empty state handling
│
└── Resources/
    ├── Persistence.swift                // Auto-generated Core Data file
    ├── UniMate.xcdatamodeld/           // Auto-generated Core Data model
    │   └── UniMate.xcdatamodel         // Data model definition
    ├── Info.plist                      // App configuration
    └── Assets.xcassets                 // App assets
```
