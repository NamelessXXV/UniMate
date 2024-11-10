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
│   ├── UniMateApp.swift              // Main app entry point, sets up environment and root view
│   ├── AppDelegate.swift             // Handles app lifecycle and Firebase setup
│   ├── AppCoordinator.swift          // Manages app navigation and authentication state
│   └── Persistence.swift             // CoreData stack setup and management
│
├── Core/
│   ├── Services/
│   │   ├── Network/
│   │   │   ├── NetworkService.swift  // Generic network request handling
│   │   │   ├── Endpoint.swift        // API endpoint configuration
│   │   │   └── HTTPMethod.swift      // HTTP method definitions (GET, POST, etc.)
│   │   ├── Authentication/
│   │   │   ├── AuthenticationService.swift  // Firebase auth operations
│   │   │   └── KeychainService.swift        // Secure credential storage
│   │   ├── Chat/
│   │   │   ├── ChatService.swift            // Firebase real-time chat operations
│   │   │   ├── WebSocketService.swift       // Real-time connection management
│   │   │   └── LocalChatService.swift       // CoreData chat history operations
│   │   ├── Storage/
│   │   │   ├── StorageManager.swift         // Firebase Storage (images, files)
│   │   │   └── LocalStorageManager.swift    // CoreData CRUD operations
│   │   └── Database/
│   │       ├── FirebaseManager.swift        // Firebase Firestore operations
│   │       └── CoreDataManager.swift        // CoreData context and operations
│   │
│   ├── Utils/
│   │   ├── Extensions/
│   │   │   ├── Color+Extension.swift        // Custom color helpers
│   │   │   ├── Date+Extension.swift         // Date formatting and calculations
│   │   │   ├── String+Extension.swift       // String validation and formatting
│   │   │   ├── View+Extension.swift         // SwiftUI view modifiers
│   │   │   ├── UIImage+Extension.swift      // Image processing helpers
│   │   │   ├── Bundle+Extension.swift       // Resource loading helpers
│   │   │   └── NSManagedObject+Extension.swift  // CoreData convenience methods
│   │   ├── Helpers/
│   │   │   ├── Validators.swift             // Input validation (email, password)
│   │   │   ├── DateFormatter.swift          // Date formatting utilities
│   │   │   ├── ImageLoader.swift            // Async image loading and caching
│   │   │   ├── Logger.swift                 // Custom logging system
│   │   │   └── Analytics.swift              // Firebase Analytics tracking
│   │   └── Constants.swift                  // App-wide constants and configurations
│   │
│   ├── Models/
│   │   ├── Remote/                          // Firebase data models
│   │   │   ├── User.swift                   // User profile data
│   │   │   ├── Message.swift                // Chat message structure
│   │   │   ├── Chat.swift                   // Chat thread structure
│   │   │   ├── Post.swift                   // Forum post structure
│   │   │   └── Match.swift                  // User matching data
│   │   └── Local/                           // CoreData models
│   │       ├── ChatMessage.swift            // Local chat message entity
│   │       ├── ChatThread.swift             // Local chat thread entity
│   │       ├── LocalUserPreferences.swift   // User settings entity
│   │       └── CachedUserProfile.swift      // Cached user data entity
│   │
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   │   ├── AuthenticationFlow.swift     // Auth navigation container
│   │   │   ├── SignInView.swift            // Login screen
│   │   │   ├── SignUpView.swift            // Registration screen
│   │   │   ├── ForgotPasswordView.swift    // Password reset screen
│   │   │   └── VerificationView.swift      // Email verification screen
│   │   └── ViewModels/
│   │       └── AuthenticationViewModel.swift // Auth business logic
│   │
│   ├── Chat/
│   │   ├── Views/
│   │   │   ├── ChatListView.swift          // List of chat threads
│   │   │   ├── ChatView.swift              // Individual chat conversation
│   │   │   └── ChatBubbleView.swift        // Message bubble UI
│   │   └── ViewModels/
│   │       ├── ChatListViewModel.swift      // Chat list business logic
│   │       └── ChatViewModel.swift          // Chat conversation logic
│   │
│   ├── Match/
│   │   ├── Views/
│   │   │   ├── MatchView.swift             // Main matching screen
│   │   │   ├── MatchCardView.swift         // Swipeable match card
│   │   │   └── MatchDetailView.swift       // User detail screen
│   │   └── ViewModels/
│   │       └── MatchViewModel.swift         // Matching logic
│   │
│   ├── Forum/
│   │   ├── Views/
│   │   │   ├── ForumView.swift             // Main forum screen
│   │   │   ├── PostListView.swift          // List of forum posts
│   │   │   ├── PostDetailView.swift        // Individual post view
│   │   │   └── CreatePostView.swift        // New post creation
│   │   └── ViewModels/
│   │       ├── ForumViewModel.swift         // Forum list logic
│   │       └── PostViewModel.swift          // Post management logic
│   │
│   └── Profile/
│       ├── Views/
│       │   ├── ProfileView.swift           // User profile display
│       │   ├── EditProfileView.swift       // Profile editing
│       │   └── SettingsView.swift          // App settings
│       └── ViewModels/
│           └── ProfileViewModel.swift       // Profile management logic
│
├── UI/
│   ├── Components/
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift         // Main action button
│   │   │   ├── SecondaryButton.swift       // Alternative action button
│   │   │   ├── IconButton.swift            // Icon-based button
│   │   │   ├── SocialButton.swift          // Social login button
│   │   │   └── LoadingButton.swift         // Button with loading state
│   │   ├── TextFields/
│   │   │   ├── CustomTextField.swift       // Base text field
│   │   │   ├── SearchTextField.swift       // Search input field
│   │   │   ├── EmailTextField.swift        // Email input field
│   │   │   ├── PasswordTextField.swift     // Secure password field
│   │   │   └── ChatTextField.swift         // Message input field
│   │   ├── LoadingView.swift               // Loading indicator
│   │   └── ErrorView.swift                 // Error display
│   │
│   └── Styles/
│       ├── Colors.swift                    // Color definitions
│       └── Typography.swift                // Text styles
│
├── Resources/
│   ├── Assets.xcassets/                    // Image and color assets
│   │   ├── AppIcon.appiconset/            // App icons
│   │   ├── Colors.xcassets/               // Color sets
│   │   └── Images.xcassets/               // Image assets
│   ├── UniMate.xcdatamodeld/              // CoreData schema
│   └── Localizable.strings                // Localized strings
│
└── Configuration/
    ├── Info.plist                         // App configuration
    ├── AppConfiguration.swift             // Environment configuration
    └── GoogleService-Info.plist           // Firebase configuration
```
