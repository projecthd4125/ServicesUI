# Service Request Workflow - Phase 1

## 📋 Workflow Overview

This document describes the phased workflow implementation for service request management.

---

## 🎯 Phase 1: Initial Review & Acceptance

### Status Flow

```
Client Submits Request
         ↓
   [PENDING] (Initial State)
         ↓
    Admin Reviews
         ↓
    ┌─────────┬─────────────┐
    ↓         ↓             ↓
[IN REVIEW] [NEED MORE INFO] [ACCEPTED]
```

### Status Definitions

#### 1. **Pending** 
- **Color**: Orange
- **Icon**: ⏳ Pending Actions
- **Description**: Initial state when client submits a request
- **Visibility**: System-assigned, not changeable by admin in Phase 1
- **Next Actions**: Admin reviews and changes to Phase 1 status

#### 2. **In Review** (Phase 1)
- **Color**: Blue 🔵
- **Icon**: 📋 Review
- **Description**: Request is being actively reviewed by admin
- **Admin Action**: Admin is examining the request details
- **Next Steps**: 
  - More info needed → "Need More Information"
  - Ready to proceed → "Accepted"

#### 3. **Need More Information** (Phase 1)
- **Color**: Amber 🟡
- **Icon**: ℹ️ Info
- **Description**: Admin needs additional details from client
- **Admin Action**: Request clarification or additional documentation
- **Next Steps**:
  - After client provides info → "In Review"
  - If satisfactory → "Accepted"

#### 4. **Accepted** (Phase 1)
- **Color**: Green 🟢
- **Icon**: ✅ Check Circle
- **Description**: Request has passed initial review and is accepted
- **Admin Action**: Request meets requirements and is approved for next phase
- **Next Steps**: Ready for Phase 2 workflow (assignment, scheduling, etc.)

---

## 📊 Admin Dashboard Statistics

### Summary Cards (Phase 1)

| Card | Count | Color | Icon | Description |
|------|-------|-------|------|-------------|
| **Total** | All requests | Primary Blue | 📄 | Total number of requests |
| **In Review** | Count | Blue 🔵 | 📋 | Requests being reviewed |
| **Need More Info** | Count | Amber 🟡 | ℹ️ | Requests awaiting clarification |
| **Accepted** | Count | Green 🟢 | ✅ | Requests accepted for next phase |

---

## 🔄 Status Update Dialog

### Phase 1 Options
When admin clicks on a request, they see:

```
┌─────────────────────────────────┐
│  Update Request Status          │
├─────────────────────────────────┤
│  Current Status: Pending        │
│                                 │
│  Select new status:             │
│  ○ In Review                    │
│  ○ Need More Information        │
│  ○ Accepted                     │
│                                 │
│  [Cancel]  [Update]             │
└─────────────────────────────────┘
```

---

## 🎨 Visual Design

### Status Badge Colors

- **Pending**: Orange `#FF9800` (System default)
- **In Review**: Blue `#2196F3`
- **Need More Information**: Amber `#FFC107`
- **Accepted**: Green `#4CAF50`

### Summary Card Icons

- **Total**: `Icons.request_page` 📄
- **In Review**: `Icons.rate_review` 📋
- **Need More Info**: `Icons.info_outline` ℹ️
- **Accepted**: `Icons.check_circle` ✅

---

## 🔮 Future Phases (Planned)

### Phase 2: Assignment & Scheduling
- Assign to service provider
- Schedule service date/time
- Status: **Scheduled**

### Phase 3: Service Execution
- In progress
- On hold
- Status: **In Progress**, **On Hold**

### Phase 4: Completion & Review
- Completed
- Client review/rating
- Status: **Completed**, **Reviewed**

### Phase 5: Payment & Closure
- Payment processing
- Invoicing
- Status: **Paid**, **Closed**

---

## 💻 Implementation Details

### Model Changes

```dart
enum RequestStatus {
  pending,          // Initial state
  inReview,        // Phase 1
  needMoreInfo,    // Phase 1
  accepted,        // Phase 1
  approved,        // Phase 2+ (future)
  rejected,        // Phase 2+ (future)
  completed,       // Phase 4+ (future)
}
```

### Admin Screen Changes

1. **Status Dialog**: Shows only Phase 1 statuses (In Review, Need More Info, Accepted)
2. **Summary Cards**: Displays Phase 1 statistics
3. **Filter Chips**: All statuses available for filtering
4. **Color Coding**: Consistent across badges and cards

---

## ✅ Phase 1 Checklist

- [x] Add new status enums (inReview, needMoreInfo, accepted)
- [x] Update status display names
- [x] Update status badge colors
- [x] Update admin dialog to show Phase 1 statuses only
- [x] Update summary cards to show Phase 1 statistics
- [x] Update icons for each status
- [x] Test status updates
- [x] Verify color consistency

---

## 🧪 Testing Scenarios

### Scenario 1: New Request Review
1. Client submits request (Status: Pending)
2. Admin opens request from dashboard
3. Admin clicks to update status
4. Admin selects "In Review"
5. ✅ Status badge changes to blue
6. ✅ "In Review" card count increments

### Scenario 2: Request More Information
1. Admin reviewing request (Status: In Review)
2. Admin needs clarification
3. Admin updates to "Need More Information"
4. ✅ Status badge changes to amber
5. ✅ "Need More Info" card count increments
6. Client can see status and provide info

### Scenario 3: Accept Request
1. Admin has all needed information
2. Admin reviews request thoroughly
3. Admin updates to "Accepted"
4. ✅ Status badge changes to green
5. ✅ "Accepted" card count increments
6. Request ready for Phase 2 assignment

---

## 📈 Benefits

### For Admin
- ✅ Clear workflow stages
- ✅ Easy status tracking
- ✅ Dashboard visibility of review pipeline
- ✅ Organized request management

### For Client
- ✅ Transparent process
- ✅ Clear status updates
- ✅ Know when more info needed
- ✅ Understand request progress

### For System
- ✅ Scalable workflow
- ✅ Easy to add future phases
- ✅ Consistent status handling
- ✅ Maintainable code structure

---

## 🚀 Next Steps

1. **Test Phase 1** - Verify all status transitions work correctly
2. **Gather Feedback** - Collect admin/client feedback on workflow
3. **Plan Phase 2** - Design assignment and scheduling features
4. **Implement Phase 2** - Add service provider assignment
5. **Continue Iteration** - Add remaining phases based on requirements

---

## 📝 Notes

- Pending status kept for backward compatibility and initial state
- Old statuses (approved, rejected, completed) remain in enum for future phases
- Filter chips show all statuses for flexibility
- Dialog only shows active Phase 1 statuses to keep UI clean

---

**Phase Status**: ✅ **PHASE 1 COMPLETE**  
**Last Updated**: January 23, 2026  
**Next Phase**: Assignment & Scheduling (TBD)
