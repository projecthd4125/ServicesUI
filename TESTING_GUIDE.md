# Testing Guide: Client Request Visibility to Admin

## How It Works
All service requests created by clients are stored in a **shared local storage** that is accessible to all users (admin, clients, and service providers). This means:

- When a **client** creates a request, it's saved to SharedPreferences
- When an **admin** logs in, they load ALL requests from the same SharedPreferences
- Requests persist across different user logins

## Step-by-Step Testing

### Test 1: Create Request as Client
1. Login as client: `client@gmail.com` / `test123`
2. Click the "New" button (floating action button)
3. Fill in the service request form:
   - Select start date: Today
   - Select end date: Tomorrow
   - Location: "123 Main St, Test City"
   - Description: "Need plumbing service"
4. Click "Submit Request"
5. You should see the request appear in "My Service Requests"
6. Note the Request ID (e.g., Request #1769199617598)
7. **Logout** (click logout button in top-right)

### Test 2: View Request as Admin
1. Login as admin: `admin@gmail.com` / `test123`
2. You should see "All Service Requests" screen
3. **Check the summary cards at the top:**
   - Total: Should show 1 (or more if you created multiple)
   - Pending: Should show 1 (new requests are pending by default)
   - Approved: Should show 0
4. **Scroll down** to see the request list
5. You should see the request you created as client:
   - Same Request ID
   - Client email: client@gmail.com
   - Status: PENDING (orange badge)
   - Same dates, location, and description
6. Click on the request to see full details
7. Try clicking "Approve" or "Reject" to change the status

### Test 3: Verify Updated Status as Client
1. Logout from admin
2. Login back as client: `client@gmail.com` / `test123`
3. Your request should now show the updated status (APPROVED or REJECTED)

## Troubleshooting

### If admin doesn't see the request:

1. **Check the browser console** for any errors (F12 → Console tab)
2. **Try refreshing** - Click the refresh icon in the admin screen
3. **Clear browser cache** and restart the app:
   ```
   - Close the browser tab
   - In terminal, stop the app (press 'q')
   - Run: flutter run -d chrome
   ```

### If data isn't persisting:

1. **Browser storage might be disabled** - Check browser settings
2. **Incognito/Private mode** - SharedPreferences may not work in private browsing
3. **Try a different browser** - Some browsers have stricter storage policies

## Expected Behavior

✅ **What Should Happen:**
- Client creates request → Saved to SharedPreferences
- Admin logs in → Loads from SharedPreferences → Sees client's request
- Admin approves/rejects → Updates SharedPreferences
- Client logs back in → Sees updated status

✅ **Key Points:**
- All users share the same storage
- Data persists across logouts
- Data persists across app restarts (as long as browser storage isn't cleared)
- Changes made by one user are visible to all other users

## Debug Mode

If you want to verify the data is being saved:

1. Open browser DevTools (F12)
2. Go to "Application" tab (Chrome) or "Storage" tab (Firefox)
3. Click "Local Storage" → Your localhost URL
4. Look for key: `flutter.service_requests`
5. You should see JSON data with all the requests

## Current Limitations

⚠️ **Browser-Based Storage:**
- Data is stored in the browser's local storage
- If you clear browser data, requests will be deleted
- Different browsers have separate storage (Chrome vs Firefox)
- Private/Incognito mode may not persist data

This is by design for testing. When you integrate with your backend API, these limitations will be removed.
