# LMG TODO App

A modern, feature-rich TODO application built with Flutter, featuring SQLite storage, real-time timers, calendar integration, and beautiful animations.

## Features

### Core Features
- ✅ **Task Management**: Create, edit, delete, and organize tasks
- ⏱️ **Timer System**: Real-time countdown timers with start, pause, and stop controls
- 📅 **Calendar Integration**: View tasks by date with interactive calendar
- 🔍 **Search & Filter**: Search tasks by title/description and filter by status
- 📊 **Progress Tracking**: Visual progress indicators and statistics
- 🎨 **Modern UI**: Beautiful, responsive design with smooth animations

### Task Features
- **Status Management**: TODO, In Progress, Done
- **Priority Levels**: Low, Medium, High
- **Due Dates**: Optional due dates with overdue indicators
- **Duration Control**: Set task duration (max 5 minutes)
- **Real-time Updates**: Live timer updates and status changes

### UI/UX Features
- **Smooth Animations**: Staggered list animations and micro-interactions
- **Dark/Light Theme Support**: Modern color scheme with proper contrast
- **Responsive Design**: Works on all screen sizes
- **Gesture Support**: Swipe to delete tasks
- **Loading States**: Proper loading indicators and empty states

## Screenshots

### Main Todo List
- Modern card-based design
- Status indicators with color coding
- Real-time timer display
- Search and filter functionality

### Task Details
- Comprehensive task information
- Timer controls (Start/Pause/Stop)
- Progress visualization
- Edit functionality

### Add/Edit Task
- Form validation
- Time picker (minutes/seconds)
- Priority selection
- Due date picker

## Technical Stack

- **Framework**: Flutter 3.5+
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Animations**: flutter_animate, flutter_staggered_animations
- **Calendar**: table_calendar
- **UI Components**: flutter_slidable, google_fonts
- **Notifications**: flutter_local_notifications

## Project Structure

```
lib/
├── constants/
│   ├── app_colors.dart      # Color scheme and theme colors
│   └── app_styles.dart      # Typography, spacing, and common styles
├── data/
│   └── database_helper.dart # SQLite database operations
├── models/
│   └── todo_model.dart      # Todo data model
├── pages/
│   ├── todo_list_page.dart  # Main todo list page
│   └── todo_details_page.dart # Task details page
├── providers/
│   └── todo_provider.dart   # State management
├── widgets/
│   ├── add_todo_bottom_sheet.dart # Add/edit task form
│   ├── search_bar.dart      # Search functionality
│   ├── status_filter.dart   # Status filter chips
│   └── todo_card.dart       # Individual task card
└── main.dart                # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.5.3 or higher
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd lmg_todo_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Dependencies

The app uses the following key dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.2          # SQLite database
  provider: ^6.1.2         # State management
  table_calendar: ^3.0.9   # Calendar widget
  flutter_animate: ^4.5.0  # Animations
  flutter_staggered_animations: ^1.1.1  # List animations
  google_fonts: ^6.2.1     # Custom fonts
  flutter_slidable: ^3.1.1 # Swipe actions
  intl: ^0.19.0            # Date formatting
```

## Usage

### Creating Tasks
1. Tap the floating action button (+)
2. Fill in the task title (required)
3. Add optional description
4. Set duration (max 5 minutes)
5. Choose priority level
6. Set optional due date
7. Tap "Save"

### Managing Tasks
- **View Details**: Tap on any task card
- **Start Timer**: Use the play button in details
- **Pause/Resume**: Use pause button during active timers
- **Complete**: Use stop button to mark as done
- **Edit**: Tap edit icon in details page
- **Delete**: Swipe left on task card

### Filtering & Search
- **Search**: Use the search bar to find tasks by title/description
- **Filter by Status**: Use the filter chips (All, To Do, In Progress, Done)
- **Calendar View**: Toggle calendar to view tasks by date

## Database Schema

The app uses SQLite with the following table structure:

```sql
CREATE TABLE todos(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL,
  duration INTEGER NOT NULL,
  elapsedTime INTEGER DEFAULT 0,
  startTime TEXT,
  endTime TEXT,
  createdDate TEXT NOT NULL,
  dueDate TEXT,
  priority INTEGER DEFAULT 0,
  isCompleted INTEGER DEFAULT 0
)
```

## Features in Detail

### Timer System
- Real-time countdown with 1-second precision
- Automatic completion when timer reaches zero
- Pause/resume functionality
- Visual indicators for running timers

### Status Management
- **TODO**: Newly created tasks
- **IN_PROGRESS**: Tasks with active or paused timers
- **DONE**: Completed tasks

### Priority System
- **Low**: Default priority (gray)
- **Medium**: Medium priority (orange)
- **High**: High priority (red)

### Calendar Integration
- Monthly/weekly view options
- Task markers on dates with tasks
- Date selection to filter tasks
- Today highlighting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support or questions, please open an issue in the repository.

---

**Built with ❤️ using Flutter**
