# WorkPlan Timesheet Kiosk - API Documentation

## Base Configuration
- **Base URL**: `http://14.99.211.60:9012/`
- **Service Endpoint**: `KioskService.asmx/`
- **Response Format**: XML (converted to JSON in client)
- **HTTP Method**: POST (for all APIs)
- **Response Parsing**: XML is converted to JSON using `org.json.XML` library

---

## 1. Authentication APIs

### 1.1 Validate Timesheet Kiosk Admin Login
**Endpoint**: `/KioskService.asmx/ValidateTSheetKioskAdminLogin`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/ValidateTSheetKioskAdminLogin`

**Used In**: 
- [HomeLoginActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Home/HomeLoginActivity.java)
- [Admin/LoginActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Admin/LoginActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpID | String | Corporation ID from login form | Yes |
| UserName | String | Username from login form | Yes |
| Password | String | User password from login form | Yes |
| DeviceID | String | Android device unique ID (Secure.ANDROID_ID) | Yes |

**Request Example**:
```
POST /KioskService.asmx/ValidateTSheetKioskAdminLogin HTTP/1.1
Content-Type: application/x-www-form-urlencoded

CorpID=arb-kol-dev&UserName=emp001&Password=pass123&DeviceID=abc123def456
```

**Response Format** (XML converted to JSON):
```json
{
  "UserLogin": [
    {
      "UserID": "u123",
      "UserName": "emp001",
      "CompID": "comp1",
      "CorpID": "arb-kol-dev",
      "CompanyName": "ARB Company",
      "SupervisorId": "sup1",
      "UserRole": "ADMIN",
      "AdminYN": "Y",
      "PayableClerkYN": "N",
      "SupervisorYN": "N",
      "PurchaseYN": "N",
      "PayrollClerkYN": "N",
      "EmpName": "John Doe",
      "UserType": "MAIN",
      "EmailId": "john@example.com",
      "PwdSetterId": "pwd1",
      "FinYearID": "2023-24",
      "Msg": "Login successful",
      "EmailServer": "smtp.gmail.com",
      "EmailServerPort": "587",
      "EmailUsername": "noreply@company.com",
      "EmailPassword": "encrypted_password",
      "EmailHostAddress": "company.com",
      "EmployeeCode": "EMP001",
      "Supervisor1": "Supervisor Name",
      "Supervisor2": "Supervisor Name 2",
      "PersonId": 1001
    }
  ],
  "status": "true",
  "message": "Login successful"
}
```

**Response Fields** (stored in UserSingletonModel):
- `UserID`, `UserName`, `CompID`, `CorpID`, `CompanyName`: User and company identification
- `UserRole`, `AdminYN`, `SupervisorYN`, etc.: User permissions and roles
- `EmpName`, `EmployeeCode`, `PersonId`: Employee details
- `Supervisor1`, `Supervisor2`: Reporting manager details
- `EmailServer`, `EmailServerPort`, `EmailUsername`, `EmailPassword`: Email configuration
- `FinYearID`: Financial year identifier
- `Msg`: Additional message

**Stored Locally In** (SharedPreferences):
- Key: `LoginDetails`
- Stores all user information for persistent login

**Error Response**:
```json
{
  "status": "false",
  "message": "Invalid credentials"
}
```

---

## 2. Face Recognition APIs

### 2.1 Recognize Face
**Endpoint**: `/KioskService.asmx/RecognizeFace`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/RecognizeFace`

**Used In**:
- [RecognizeHomeActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognizeHomeActivity.java)
- [RecognizeHomeRealtimeActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognizeHomeRealtimeActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| ImageBase64 | String | Base64 encoded image string from camera | Yes |

**Request Example**:
```
POST /KioskService.asmx/RecognizeFace HTTP/1.1
Content-Type: application/x-www-form-urlencoded

CorpId=arb-kol-dev&ImageBase64=/9j/4AAQSkZJRgABA...
```

**Response (Success)**:
```json
{
  "PersonId": 1001,
  "EmployeeName": "John Doe",
  "EmployeeCode": "EMP001",
  "Supervisor1": "Manager Name",
  "Supervisor2": "Co-Manager Name"
}
```

**Response (Not Recognized)**:
```json
{
  "PersonId": -1,
  "EmployeeName": "",
  "EmployeeCode": "",
  "Supervisor1": "",
  "Supervisor2": ""
}
```

**Notes**:
- Image is captured from camera and compressed/resized before being sent
- Image size is optimized for faster transmission
- If `PersonId` <= 0, face recognition failed
- Retry dialog is shown on failure

---

## 3. Attendance APIs

### 3.1 Get Next Attendance Action
**Endpoint**: `/KioskService.asmx/GetAttendanceNextAction`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/GetAttendanceNextAction`

**Used In**: [RecognitionOptionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognitionOptionActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| UserId | Integer | User/Employee ID (PersonId) | Yes |
| UserType | String | User type (typically "MAIN") | Yes |

**Request Example**:
```
POST /KioskService.asmx/GetAttendanceNextAction HTTP/1.1

CorpId=arb-kol-dev&UserId=1001&UserType=MAIN
```

**Response**:
```json
{
  "status": "true",
  "NextAction": "IN",
  "LastAttendance": "2024-03-25 17:30:00",
  "message": "Next action is punch IN"
}
```

**NextAction Values**:
- `IN`: Employee needs to punch in
- `OUT`: Employee needs to punch out
- `BREAK`: Employee can take a break

---

### 3.2 Save Attendance (Punch In/Out)
**Endpoint**: `/KioskService.asmx/SaveAttendance`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/SaveAttendance`

**Used In**:
- [RecognitionOptionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognitionOptionActivity.java)
- [TaskSelectionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/TaskSelectionActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| UserId | Integer | User/Employee ID (PersonId) | Yes |
| UserType | String | User type (typically "MAIN") | Yes |
| InOut | String | "IN" for punch in, "OUT" for punch out | Yes |
| InOutText | String | Descriptive text (e.g., "Punch In", "Punch Out") | Yes |

**Request Example**:
```
POST /KioskService.asmx/SaveAttendance HTTP/1.1

CorpId=arb-kol-dev&UserId=1001&UserType=MAIN&InOut=IN&InOutText=Punch%20In
```

**Response**:
```json
{
  "attendance_id": "att123456",
  "response": {
    "status": "true",
    "message": "Attendance saved successfully"
  }
}
```

**On Success**:
- `InOut=IN`: Redirects to [AttendanceRecordActivity](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/AttendanceRecordActivity.java)
- `InOut=OUT`: Proceeds to break/punch-out flow via [PunchOutBreakActivity](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/PunchOutBreakActivity.java)

---

## 4. Task Management APIs

### 4.1 Get Employee Daily Task List
**Endpoint**: `/KioskService.asmx/EmployeeTimeSheetDailyTaskList`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/EmployeeTimeSheetDailyTaskList`

**Used In**: [TaskSelectionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/TaskSelectionActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| UserId | Integer | User/Employee ID (PersonId) | Yes |
| UserType | String | User type (typically "MAIN") | Yes |

**Response**:
```json
{
  "EmployeeTimeSheetDetails": [
    {
      "CostType": "Billable",
      "EmployeeAssignmentID": "assign1",
      "Task": "Project A Development",
      "Contract": "CONTRACT-001",
      "Note": "Frontend development",
      "ACSuffix": 1,
      "LaborCategoryID": 101,
      "DefaultTaskYn": 1,
      "TaskID": 1001,
      "LaborCategory": "Development",
      "Hour": "8.00",
      "AccountCode": "ACC-001",
      "CostTypeID": 1,
      "ContractID": 50
    },
    {
      "CostType": "Non-Billable",
      "EmployeeAssignmentID": "assign2",
      "Task": "Training",
      "Contract": "INTERNAL",
      "Note": "Company training",
      "ACSuffix": 0,
      "LaborCategoryID": 102,
      "DefaultTaskYn": 0,
      "TaskID": 1002,
      "LaborCategory": "Training",
      "Hour": "0.00",
      "AccountCode": "ACC-002",
      "CostTypeID": 2,
      "ContractID": 51
    }
  ]
}
```

**Response Fields**:
- `TaskID`: Unique identifier for the task
- `Task`: Task/project name
- `Hour`: Default hours allocated for this task
- `DefaultTaskYn`: 1=default task, 0=optional task
- `LaborCategory`, `CostType`: Classification of work
- `Contract`, `AccountCode`: Billing/accounting information

---

### 4.2 Save Task Hours
**Endpoint**: `/KioskService.asmx/TaskHourSave`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/TaskHourSave`

**Used In**:
- [RecognitionOptionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognitionOptionActivity.java)
- [TaskSelectionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/TaskSelectionActivity.java)
- [AttendanceRecordActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/AttendanceRecordActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| TaskID | Integer | Task identifier | Yes |
| Hour | Decimal | Hours worked on this task | Yes |
| UserId | Integer | User/Employee ID (PersonId) | Yes |

**Response**:
```json
{
  "status": "true",
  "message": "Task hours saved successfully"
}
```

---

### 4.3 Update Task Hours (Break)
**Endpoint**: `/KioskService.asmx/TaskHourUpdate`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/TaskHourUpdate`

**Used In**: [RecognitionOptionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognitionOptionActivity.java)

**Used For**: Saving break start time and updating task hours

**Request Parameters**: Similar to TaskHourSave

---

### 4.4 Submit Task Hours
**Endpoint**: `/KioskService.asmx/TaskHourSubmit`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/TaskHourSubmit`

**Used In**: [RecognitionOptionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognitionOptionActivity.java)

**Purpose**: Submit/finalize timesheet for the day

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| UserId | Integer | User/Employee ID | Yes |
| AttendanceID | String | Attendance record ID | Yes |

---

## 5. Leave Management APIs

### 5.1 Get Leave Balance
**Endpoint**: `/KioskService.asmx/LeaveBalance`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/LeaveBalance`

**Used In**:
- [RecognitionOptionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognitionOptionActivity.java)
- [AttendanceRecordActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/AttendanceRecordActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| UserId | Integer | User/Employee ID | Yes |

**Response**:
```json
{
  "LeaveTypes": [
    {
      "LeaveType": "Casual Leave",
      "Balance": "10.50",
      "Used": "2.50",
      "Total": "13.00"
    },
    {
      "LeaveType": "Sick Leave",
      "Balance": "5.00",
      "Used": "0.00",
      "Total": "5.00"
    }
  ]
}
```

---

## 6. Face Management APIs

### 6.1 List Faces (Employee Images)
**Endpoint**: `/KioskService.asmx/ListFaces`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/ListFaces`

**Used In**: [EmployeeImageSettingsActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Admin/EmployeeImageSettings/EmployeeImageSettingsActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| EmployeeID | Integer | Employee ID | Yes |

**Response**:
```json
{
  "Faces": [
    {
      "FaceID": "face1",
      "FaceURL": "http://..../face1.jpg",
      "UploadDate": "2024-03-20"
    }
  ]
}
```

---

### 6.2 Delete Faces
**Endpoint**: `/KioskService.asmx/DeleteFaces`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/DeleteFaces`

**Used In**: [EmployeeImageSettingsAdapter.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Adapter/EmployeeImageSettingsAdapter.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| FaceID | String | Face identifier to delete | Yes |

---

### 6.3 Index Faces
**Endpoint**: `/KioskService.asmx/IndexFaces`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/IndexFaces`

**Used In**: [EmployeeImageSettingsActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Admin/EmployeeImageSettings/EmployeeImageSettingsActivity.java)

**Purpose**: Index/process faces for face recognition system

---

### 6.4 Create Gallery
**Endpoint**: `/KioskService.asmx/CreateGallery`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/CreateGallery`

**Used In**: [EmployeeImageSettingsActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Admin/EmployeeImageSettings/EmployeeImageSettingsActivity.java)

**Purpose**: Create face collection/gallery for an employee

---

## 7. Kiosk Unit Settings APIs

### 7.1 Save Kiosk Info
**Endpoint**: `/KioskService.asmx/SaveKioskInfo`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/SaveKioskInfo`

**Used In**: [KioskUnitSettingsActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Admin/KioskUnitSettings/KioskUnitSettingsActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| DeviceId | String | Device identifier | Yes |
| UnitName | String | Kiosk unit name | Yes |
| AttendanceYn | String | "Y"/"N" - Enable face attendance? | Yes |
| TaskListYn | String | "Y"/"N" - Enable task list? | Yes |
| LeaveBalanceYn | String | "Y"/"N" - Show leave balance? | Yes |

**Request Example**:
```
POST /KioskService.asmx/SaveKioskInfo HTTP/1.1

CorpId=arb-kol-dev&DeviceId=device123&UnitName=Gate1&AttendanceYn=Y&TaskListYn=Y&LeaveBalanceYn=Y
```

**Response**:
```json
{
  "status": "true",
  "message": "Kiosk settings saved successfully"
}
```

**Stored Locally In** (SharedPreferences):
- Key: `KioskDetails`
- Stores: `UnitName`, `DeviceId`, `AttendanceYN`, `TasklistYN`, `LeaveBalanceYN`

---

### 7.2 Get Kiosk Info
**Endpoint**: `/KioskService.asmx/GetKioskInfo`

**Full URL**: `http://14.99.211.60:9012/KioskService.asmx/GetKioskInfo`

**Used In**: [KioskUnitSettingsActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Admin/KioskUnitSettings/KioskUnitSettingsActivity.java)

**Request Parameters**:
| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| CorpId | String | Corporation ID | Yes |
| DeviceId | String | Device identifier | Yes |

**Response**:
```json
{
  "KioskInfo": {
    "DeviceId": "device123",
    "UnitName": "Gate1",
    "AttendanceYn": "Y",
    "TaskListYn": "Y",
    "LeaveBalanceYn": "Y"
  }
}
```

---

## HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | Request successful |
| 400 | Bad request (missing/invalid parameters) |
| 401 | Authentication failed |
| 500 | Server error |

---

## Error Handling

### Common Error Response Pattern:
```json
{
  "status": "false",
  "message": "Error description here"
}
```

### Client-Side Error Handling:
- Volley library handles HTTP errors
- Network errors show: "Could not connect server"
- Multiple retry attempts with exponential backoff
- Custom Snackbar shows error messages to user

---

## Data Flow

### Login Flow:
1. User enters CorpID, Username, Password on [HomeLoginActivity](app/src/main/java/org/arb/wrkplantimesheetkiosk/Home/HomeLoginActivity.java)
2. Call `ValidateTSheetKioskAdminLogin` API
3. Store response in UserSingletonModel and SharedPreferences
4. Navigate to [RecognitionOptionActivity](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognitionOptionActivity.java)

### Punch In/Out Flow:
1. Employee recognizes face via [RecognizeHomeRealtimeActivity](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognizeHomeRealtimeActivity.java)
2. Call `RecognizeFace` API with base64 image
3. Get PersonId and employee details
4. Call `GetAttendanceNextAction` to determine if IN or OUT
5. Call `SaveAttendance` to record punch
6. Show task list via [TaskSelectionActivity](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/TaskSelectionActivity.java)
7. Call `EmployeeTimeSheetDailyTaskList` to load tasks
8. User selects tasks and hours
9. Call `TaskHourSave` for each task
10. Call `TaskHourSubmit` or `TaskHourUpdate` to finalize

---

## Libraries Used

- **Volley**: HTTP client for making network requests
- **org.json**: JSON/XML parsing and conversion
- **Android SDK**: Device ID retrieval, SharedPreferences, UI

---

## Notes

- All responses are in XML format from server, converted to JSON on client
- All APIs use POST method
- Device ID (ANDROID_ID) is sent with each request for device tracking
- User information is cached locally using SharedPreferences for offline access
- Images are Base64 encoded before transmission
- All timestamps are stored and managed on server side
