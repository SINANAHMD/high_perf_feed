Overview

This project implements a high-performance, infinite-scrolling social feed using Flutter, backed by Supabase. The focus of the implementation is on UI performance, memory optimization, and responsive user experience using optimistic updates.

The application demonstrates efficient rendering, smooth scrolling, and scalable data handling techniques suitable for production-grade mobile applications.

Tech Stack
Flutter
Riverpod (state management setup)
Supabase (Database, RPC, Storage)
REST APIs (for feed fetching)
Features
Infinite Scrolling Feed
Posts are fetched in paginated form (10 items per request)
Smooth infinite scrolling using ListView.builder
Scroll listener triggers additional data loading
Pull-to-Refresh
Implemented using RefreshIndicator
Clears existing data and reloads the latest posts
GPU Optimization
Each feed item is wrapped inside RepaintBoundary
Prevents unnecessary repainting during fast scrolling
Improves rendering performance and reduces frame drops
Memory Optimization
Feed uses media_thumb_url for lightweight images
cacheWidth ensures images are decoded at required size only
Prevents excessive memory usage and avoids OOM issues
Hero Animation & Detail Screen
Smooth Hero transition from feed to detail screen
Detail screen loads higher-resolution image (media_mobile_url)
Provides seamless visual experience
Optimistic UI (Like System)
Like action updates UI instantly without waiting for network response
Backend sync is handled asynchronously via Supabase RPC (toggle_like)
UI automatically reverts in case of failure
Spam Click Handling
Multiple rapid taps are prevented using local state control
Ensures consistent UI and avoids excessive backend calls
Double Tap to Like
Users can like a post by double tapping the image
Mimics modern social media interaction patterns
Backend Design (Supabase)
Database Tables

posts

id (UUID)
created_at (timestamp)
media_thumb_url (text)
media_mobile_url (text)
media_raw_url (text)
like_count (integer)

user_likes

user_id (text)
post_id (UUID)
composite primary key (user_id, post_id)
RPC Function

A concurrency-safe toggle_like function is used to:

Add or remove likes
Prevent race conditions
Maintain accurate like counts
Image Strategy (3-Tier Pipeline Concept)

The system is designed to support a three-tier image architecture:

Thumbnail (300px) → Used in feed for performance
Mobile (1080px) → Used in detail screen
Raw (original) → Used for download

For simplicity, this implementation uses placeholder image URLs, but follows the same architectural principle.

Performance Considerations
Efficient pagination prevents large data loads
RepaintBoundary reduces GPU workload
Controlled image decoding minimizes RAM usage
Network calls are optimized and minimized
UI remains responsive under rapid scrolling conditions
Edge Case Handling
Rapid Scrolling
No frame drops due to optimized rendering
Spam Clicking
Multiple like actions are throttled locally
Offline Scenario
UI updates optimistically
Automatically reverts on failure
Displays error feedback using SnackBar
Limitations
User-specific like state is managed locally and not persisted per user session
Real-time synchronization is not implemented (REST-based fetching is used)
Image processing pipeline is simulated using external image URLs instead of actual storage uploads
How to Run
Clone the repository

Run:

flutter pub get
Update Supabase credentials in main.dart

Run the app:

flutter run
Deliverables
Flutter application with optimized feed implementation
Demonstration of infinite scrolling, Hero animations, and optimistic UI
Structured and scalable architecture
Conclusion

This project demonstrates how to build a performant and scalable feed system in Flutter by combining efficient rendering techniques, proper memory management, and responsive UI patterns. It reflects real-world mobile application design principles focused on performance and user experience
