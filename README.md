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
│   ├── UniMateApp.swift
│   ├── AppDelegate.swift
│   └── AppCoordinator.swift
│
├── Core/
│   ├── Services/
│   │   ├── Network/
│   │   │   ├── NetworkService.swift
│   │   │   ├── Endpoint.swift
│   │   │   └── HTTPMethod.swift
│   │   ├── Authentication/
│   │   │   ├── AuthenticationService.swift
│   │   │   └── KeychainService.swift
│   │   ├── Chat/
│   │   │   ├── ChatService.swift
│   │   │   └── WebSocketService.swift
│   │   └── Storage/
│   │       └── StorageManager.swift
│   │
│   ├── Utils/
│   │   ├── Extensions/
│   │   │   ├── Color+Extension.swift
│   │   │   ├── Date+Extension.swift
│   │   │   ├── String+Extension.swift
│   │   │   ├── View+Extension.swift
│   │   │   ├── UIImage+Extension.swift
│   │   │   └── Bundle+Extension.swift
│   │   ├── Helpers/
│   │   │   ├── Validators.swift
│   │   │   ├── DateFormatter.swift
│   │   │   ├── ImageLoader.swift
│   │   │   ├── Logger.swift
│   │   │   └── Analytics.swift
│   │   └── Constants.swift
│   │
│   └── Models/
│       ├── User.swift
│       ├── Message.swift
│       ├── Chat.swift
│       ├── Post.swift
│       └── Match.swift
│
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   │   ├── AuthenticationFlow.swift
│   │   │   ├── SignInView.swift
│   │   │   ├── SignUpView.swift
│   │   │   ├── ForgotPasswordView.swift
│   │   │   └── VerificationView.swift
│   │   └── ViewModels/
│   │       └── AuthenticationViewModel.swift
│   │
│   ├── Chat/
│   │   ├── Views/
│   │   │   ├── ChatListView.swift
│   │   │   ├── ChatView.swift
│   │   │   └── ChatBubbleView.swift
│   │   └── ViewModels/
│   │       ├── ChatListViewModel.swift
│   │       └── ChatViewModel.swift
│   │
│   ├── Match/
│   │   ├── Views/
│   │   │   ├── MatchView.swift
│   │   │   ├── MatchCardView.swift
│   │   │   └── MatchDetailView.swift
│   │   └── ViewModels/
│   │       └── MatchViewModel.swift
│   │
│   ├── Forum/
│   │   ├── Views/
│   │   │   ├── ForumView.swift
│   │   │   ├── PostListView.swift
│   │   │   ├── PostDetailView.swift
│   │   │   └── CreatePostView.swift
│   │   └── ViewModels/
│   │       ├── ForumViewModel.swift
│   │       └── PostViewModel.swift
│   │
│   └── Profile/
│       ├── Views/
│       │   ├── ProfileView.swift
│       │   ├── EditProfileView.swift
│       │   └── SettingsView.swift
│       └── ViewModels/
│           └── ProfileViewModel.swift
│
├── UI/
│   ├── Components/
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   ├── SecondaryButton.swift
│   │   │   ├── IconButton.swift
│   │   │   ├── SocialButton.swift
│   │   │   └── LoadingButton.swift
│   │   ├── TextFields/
│   │   │   ├── CustomTextField.swift
│   │   │   ├── SearchTextField.swift
│   │   │   ├── EmailTextField.swift
│   │   │   ├── PasswordTextField.swift
│   │   │   └── ChatTextField.swift
│   │   ├── LoadingView.swift
│   │   └── ErrorView.swift
│   │
│   ├── Styles/
│   │   ├── Colors.swift
│   │   ├── Typography.swift
│   │   └── ViewModifiers.swift
│   │
│   └── Resources/
│       ├── Assets.xcassets/
│       │   ├── AppIcon.appiconset/
│       │   ├── Colors.xcassets/
│       │   └── Images.xcassets/
│       └── Localizable.strings
│
└── Configuration/
    ├── Info.plist
    ├── AppConfiguration.swift
    └── Debug.xcconfig
```
