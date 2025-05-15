#  README – Flutter CRUD Task Manager Module

---

##  Setup Instructions

1. **Install Flutter SDK:**
   Make sure Flutter is installed on your system.
   [Flutter installation guide](https://docs.flutter.dev/get-started/install)

2. **Clone this repository:**

   ```bash
   git clone <your-repo-link>
   cd crud_module
   ```

3. **Install dependencies:**

   ```bash
   flutter pub get
   ```

4. **Configure Firebase:**

   * Go to [Firebase Console](https://console.firebase.google.com)
   * Create a project (e.g., `crud-module`)
   * Add an Android app with package name: `com.example.crud_module`
   * Download `google-services.json` and place it inside `android/app/`
   * Enable **Firestore Database**
   * Set Firestore rules (for testing):

     ```js
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /{document=**} {
           allow read, write: if true;
         }
       }
     }
     ```

5. **Run the app:**

   ```bash
   flutter run
   ```

---

## API Endpoints Documentation

> This module uses Firebase Firestore as a backend service and `sqflite` for local storage.

| Functionality    | Type     | Firestore Path          | Description                      |
| ---------------- | -------- | ----------------------- | -------------------------------- |
| Fetch all tasks  | `GET`    | `/tasks/`               | Retrieves all tasks via snapshot |
| Add task         | `POST`   | `/tasks/`               | Adds a new task                  |
| Update task      | `PUT`    | `/tasks/{id}`           | Updates an existing task         |
| Delete task      | `DELETE` | `/tasks/{id}`           | Deletes a task                   |
| Sync to local DB | —        | `sqflite` local storage | Local DB used for offline access |

---

##  Usage Instructions

### Features

* Add, edit, delete tasks
* Store tasks locally and sync with Firestore
* Search with debounce
* Filter by task status and category
* Sort by priority (ascending/descending)
* Infinite scroll pagination
* Light/dark theme toggle
* Export to CSV or JSON
* Import tasks from JSON

###  Data Import (JSON)

* Use the import button on the task screen
* Select a `.json` file containing a list of tasks in this format:

```json
[
  {
    "title": "Sample Task",
    "description": "This is a task",
    "status": "Pending",
    "priority": 1,
    "category": "Work",
    "createdDate": "2024-12-01T10:00:00.000Z"
  }
]
```

###  Data Export

* Tap the **CSV** or **JSON** export icons in the app bar
* Files will be saved inside app’s external directory

---

##  Architecture Overview

###  Layers

| Layer        | Responsibility                                |
| ------------ | --------------------------------------------- |
| **UI**       | Flutter `screens/` for task listing, add/edit |
| **BLoC**     | Business logic using `flutter_bloc`           |
| **Model**    | `Task` model to map task data                 |
| **Services** | Firestore and SQLite DB access                |
| **Utils**    | Helpers for CSV/JSON import/export            |
| **Theme**    | `theme_provider.dart` using Provider          |

###  Data Flow

* UI → Events → BLoC → Local DB (SQLite) → Cloud (Firestore)
* Firestore snapshot listener updates local DB
* Pagination + filtering done locally for speed

---

##  Testing Information

###  Manual Tests Performed

*  Add, update, delete tasks
*  Filter by category and status
*  Pagination works on large datasets
*  Import and export functionality tested
*  Tested on both emulator and real device
*  Firestore and SQLite sync verified (online/offline)

###  Suggested Manual Tests

| Test Case                  | Expected Result                      |
| -------------------------- | ------------------------------------ |
| Create a task              | Task appears in list and saved in DB |
| Delete a task              | Task is removed locally and in cloud |
| Filter by "Pending" status | Only pending tasks are shown         |
| Import from JSON           | Tasks from file are inserted         |
| Export to CSV              | File saved to local storage          |
| Toggle dark mode           | App switches to dark theme           |

---

##  Author

* **Name:** A K Kavan
* **Email/GitHub:** kavankulal2254@gmail.com/

---

##  License

Open source for academic use only.
