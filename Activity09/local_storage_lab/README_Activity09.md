
# In-Class Activity 09 - SQLite Card Catalogue

## Project Overview

For Activity 09, I expanded my Fall Festival Roster Flutter app by adding a Card Catalogue that uses SQLite for local storage. The app allows users to create folders, add cards, edit records, delete records, and keep saved information after restarting the app.

I upgraded the database from version 1 to version 2 and added two tables named `folders` and `cards`. Each card has a `folder_id` that connects it to a folder. I also added a foreign key with `ON DELETE CASCADE` so cards are automatically removed when their parent folder is deleted.

The original Fall Festival Roster still works, and its saved records were preserved during the upgrade.

## Manual Test Results

| Test | Action / Input | Expected Result | Actual Result | Status |
|---|---|---|---|---|
| T1 - Migration | Upgraded the existing SQLite database from version 1 to version 2 | Preserve original roster data and create new tables | Original guest records remained, database version became 2, foreign keys were enabled, and new tables and index were created | Pass - existing upgrade |
| T2 - Create | Created Atlas and Harbor, then added two Compass cards to Atlas and one Signal card to Harbor | Three unique card IDs, Atlas count 2, Harbor count 1 | Compass received IDs 1 and 2. Signal received ID 3. All cards had suit Signals | Pass |
| T3 - Edit and Cancel | Edited Compass ID 1 and saved, then edited Compass ID 2 and canceled | Only ID 1 changes; counts remain unchanged | ID 1 became Compass revised. ID 2 remained Compass. Counts stayed Atlas 2 and Harbor 1 | Pass |
| T4 - Persistence | Stopped Flutter, force-stopped the Android app, and reopened the same installation | Saved folders, cards, IDs, and values remain | All three cards remained with their original IDs and values. No duplicate records appeared | Pass |
| T5 - Delete | Canceled and confirmed card deletion, then canceled and confirmed folder deletion | Cancel preserves data; confirmed deletion removes selected records and cascades | Compass ID 2 was deleted. Deleting Atlas removed the remaining Atlas card. Harbor and Signal ID 3 remained | Pass |
| T6 - Validation | Tested missing image reference, blank card title, blank folder name, and duplicate folder name | Missing images show fallback; invalid inputs do not create records | Signal displayed Image: None. Blank card title was rejected. Duplicate Harbor was rejected by SQLite. Blank-folder validation is implemented in the app | Pass for verified checks |

The separate fresh-install portion of T1 was not performed on another emulator.

## T1 - Database Migration

I upgraded my existing SQLite database without uninstalling the application or clearing its storage.

The original Fall Festival Roster records were preserved:

| Guest ID | Name | Age |
|---|---|---|
| 2 | River | 35 |
| 3 | Acorn | 0 |
| 4 | Oak | 130 |

After upgrading, the database showed:

- Database version: `2`
- Foreign keys enabled: `1`
- Original table: `my_table`
- New tables: `folders` and `cards`
- Foreign key relationship from cards to folders
- Index for looking up cards by folder

The original roster data remained unchanged.

**Result:** The database migration worked correctly on the existing installation.

## T2 - Creating Folders and Cards

I created the following folders:

| Folder ID | Folder Name |
|---|---|
| 1 | Atlas |
| 2 | Harbor |

I then added three cards:

| Card ID | Title | Suit | Folder | Notes |
|---|---|---|---|---|
| 1 | Compass | Signals | Atlas | First compass card |
| 2 | Compass | Signals | Atlas | Second compass card |
| 3 | Signal | Signals | Harbor | Harbor signal card |

Atlas contained two cards, and Harbor contained one card.

Both Compass cards had the same title, but SQLite assigned them different IDs. This allowed me to work with each card separately.

**Result:** Pass.

## T3 - Editing and Canceling

I edited Compass ID 1 in Atlas and changed its title to `Compass revised`. I also updated its notes to `Updated compass card`.

After saving, the changes appeared in the catalogue.

Next, I opened Compass ID 2 and temporarily changed its title. I pressed Cancel instead of Save.

Compass ID 2 kept its original title, and the card counts remained unchanged.

This showed that the app correctly updates records by their database IDs instead of their titles.

**Result:** Pass.

## T4 - Restart and Persistence

I tested whether the saved folders and cards would remain after restarting the application.

First, I stopped the Flutter process in VS Code.

Then I used Android Debug Bridge to force-stop the application:

`~/Library/Android/sdk/platform-tools/adb shell am force-stop com.example.local_storage_lab`

I reopened the same installed application using:

`flutter run`

After restarting, I checked the Card Catalogue.

Atlas still contained:

- Compass revised - ID 1
- Compass - ID 2

Harbor still contained:

- Signal - ID 3

All three cards still had the suit `Signals`.

The saved IDs, titles, notes, and counts remained unchanged. No duplicate cards appeared.

This confirmed that the records were stored in SQLite instead of only being kept in temporary Flutter widget state.

**Result:** Pass.

## T5 - Delete and Cascade Delete

I tested deleting an individual card and deleting an entire folder.

First, I selected the Delete button for Compass ID 2 and pressed Cancel in the confirmation dialog. The card remained in Atlas.

I selected Delete again and confirmed it. Compass ID 2 was removed, leaving Compass revised ID 1.

Next, I selected Delete for Atlas and pressed Cancel. The folder remained.

I opened the confirmation again and deleted Atlas.

Afterward, Atlas disappeared from the catalogue, and Harbor still contained Signal ID 3.

This behavior was consistent with the `ON DELETE CASCADE` relationship in SQLite.

**Result:** Pass based on the displayed records.

## T6 - Validation and Missing Images

I tested how the app handles missing image references and invalid inputs.

### Missing Image Reference

Signal ID 3 had no image reference.

The app displayed:

- Title: Signal
- Suit: Signals
- Notes: Harbor signal card
- Image: None

The missing image reference did not prevent the other information from displaying.

### Blank Card Title

I attempted to save a card with a whitespace-only title.

The app displayed:

`Title and suit are required.`

No invalid card was added.

### Blank Folder Name

The folder form includes validation that rejects empty names with the message:

`Enter a folder name.`

### Duplicate Folder Name

I attempted to create another folder named Harbor.

SQLite rejected the insertion with:

`UNIQUE constraint failed: folders.name`

The existing Harbor folder remained unchanged, and no duplicate was added.

**Result:** The observed validation checks passed. Blank-folder behavior is implemented but was not separately confirmed in the screenshots.

## Additional Folder Check

After completing the deletion tests, I created Atlas again to check that the catalogue could still create folders normally.

The new Atlas folder received ID 4, while Harbor kept ID 2.

This demonstrated that the database continued assigning new IDs after earlier records were deleted.

The folder list displayed:

| Folder ID | Folder Name |
|---|---|
| 2 | Harbor |
| 4 | Atlas |

The recreated Atlas folder is separate from the original Atlas folder used during T2-T5.

## Flutter Analyzer Results

I ran:

`flutter analyze 2>&1 | tee evidence/analysis_output.txt`

The terminal reported:

`No issues found! (ran in 1.1s)`

The analyzer output was saved in the evidence folder.

**Result:** Pass.

## Activity 09 Evidence

- `evidence/activity09_beforemigration.png` - Evidence collected during migration testing.
- `evidence/activity09_migration.png` - SQLite database version 2 verification.
- `evidence/T2_cards1.png` - Atlas containing Compass cards with IDs 1 and 2.
- `evidence/T2_cards2.png` - Harbor containing Signal ID 3.
- `evidence/activity09_invalid.png` - Blank card title validation.
- `evidence/activity09_invalid2.png` - Duplicate Harbor folder validation.
- `evidence/activity09_folders.png` - Harbor ID 2 and recreated Atlas ID 4 after the deletion tests.
- `evidence/analysis_output.txt` - Flutter analyzer output.

The original Activity 08 evidence is kept separately:

- `evidence/T4_before.png` - Original Fall Festival Roster before restart.
- `evidence/T4_after.png` - Original Fall Festival Roster after restart.
- `evidence/T6_invalid.png` - Original roster validation.

These older screenshots are not being used as Activity 09 catalogue evidence.

## What I Learned

This activity helped me understand how to upgrade an existing SQLite database without losing saved information. I was able to add new tables while keeping the original Fall Festival Roster records.

I also learned why database-generated IDs are important. The two Compass cards had the same title, but their different IDs allowed me to edit and delete them independently.

Another important part was learning how foreign keys connect tables. Deleting Atlas removed its remaining card while Harbor and Signal stayed intact.

The validation tests showed how Flutter and SQLite work together to prevent invalid data. Flutter rejected blank card titles, and SQLite prevented duplicate folder names.

Overall, I learned more about database migrations, relationships between tables, persistent storage, and handling errors in Flutter applications.
