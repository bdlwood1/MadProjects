# In-Class Activity 08 - Local Storage Lab

## Fall Festival Roster

This Flutter app uses SQLite to store a small Fall Festival guest roster. The app allows users to add, edit, delete, and refresh guest records. Each guest has a database-generated ID, name, and age.

## Manual Test Results

| Test | Action / Input | Expected Result | Observed Result | Pass/Fail |
|---|---|---|---|---|
| T1 - Empty | Refreshed the roster with no saved guests | Count 0 and empty-state message | Record count was 0 and "No festival guests yet." was displayed | Pass |
| T2 - Create | Added River age 21 and River age 34 | Count 2 with two different generated IDs | River age 21 received ID 1 and River age 34 received ID 2. Count was 2 | Pass |
| T3 - Identity | Changed ID 2 from age 34 to 99 and canceled, then edited ID 2 to age 35 and saved | Cancel should leave age at 34. Save should update only ID 2 | Cancel kept ID 2 at age 34. Saving changed ID 2 to age 35 while ID 1 stayed age 21. Count stayed 2 | Pass |
| T4 - Restart | Stopped the app process and reopened the same installed app | Same IDs, names, ages, and count should remain | ID 1 was still River age 21 and ID 2 was still River age 35. Count remained 2 | Pass |
| T5 - Delete | Started deletion of ID 1 and canceled, then deleted ID 1 and refreshed | Cancel should keep count 2. Confirmed delete should leave only ID 2 and count 1 | Cancel left both records. Confirmed deletion removed ID 1. ID 2 remained and count became 1 | Pass |
| T6 - Validation | Tested blank name/21, Maple/abc, Maple/1.5, Maple/-1, Maple/131, Acorn/0, and Oak/130 | Invalid inputs should not save. Ages 0 and 130 should save | All five invalid inputs were rejected and count stayed 1. Acorn age 0 received ID 3 and Oak age 130 received ID 4. Final count was 3 | Pass |

## T6 Validation Details

- Spaces-only name with age 21: Rejected with "Enter a name." Count stayed 1.
- Maple with age abc: Rejected with "Age must be a whole number." Count stayed 1.
- Maple with age 1.5: Rejected with "Age must be a whole number." Count stayed 1.
- Maple with age -1: Rejected with "Age must be from 0 through 130." Count stayed 1.
- Maple with age 131: Rejected with "Age must be from 0 through 130." Count stayed 1.
- Acorn with age 0: Accepted as ID 3. Count became 2.
- Oak with age 130: Accepted as ID 4. Final count became 3.

## Prompt 1 - The Disappearing-Data Mystery

Before T4, I predicted that both River records would still be there after restarting the app because they were saved in the SQLite database instead of only being stored in widget state. Before the restart, ID 1 was River age 21 and ID 2 was River age 35 with a count of 2. I stopped the Flutter app process and reopened the same installed app from the Android emulator. After reopening it, the same IDs, values, and count were still displayed.

The app calls `DatabaseHelper.init()` before displaying the roster. When the roster screen starts, it loads the rows from the database and displays the returned records in the list. If the records disappeared after restarting or the list returned with a count of 0, that would disprove my claim that SQLite restored the saved data.

Evidence: `evidence/T4_before.png` and `evidence/T4_after.png`.

## Prompt 2 - Two Rivers, One Wrong Edit

The two River records show why the name cannot be used as a reliable identifier. Both records had the name River, but SQLite gave them different IDs: ID 1 and ID 2. When I updated ID 2 from age 34 to age 35, the update affected that specific ID while ID 1 stayed age 21.

My update call includes `DatabaseHelper.columnId` with the selected ID, so the database knows exactly which row to change. If I selected records using their list position instead, sorting the list could move a guest to a different position and cause the wrong record to be updated.

## Prompt 3 - My Usability Walkthrough

During testing, the app made it easy to see which guest I was changing because every row displayed its ID, name, and age with separate Edit and Delete buttons. I also noticed that canceling an edit or deletion did not change the saved data.

One small improvement I would make is displaying a more noticeable success message after an update or deletion. The tradeoff is that adding more messages or UI elements could make the simple screen feel more crowded.

During T6, the app showed specific validation messages when I entered an invalid name or age. The record count stayed at 1 during all five rejected attempts, which showed that none of the invalid inputs were saved to the database.

## Evidence

- `evidence/T4_before.png` - Roster before stopping the app process
- `evidence/T4_after.png` - Same roster after reopening the app
- `evidence/T6_invalid.png` - Example of rejected invalid input
- `evidence/analysis_output.txt` - Final Flutter analyzer output