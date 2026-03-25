# Login API - Detailed Network Flow Analysis

## Overview
This document provides step-by-step analysis of the login API call during the login process with all network details, parameters, responses, and data handling.

---

## Login Screen

**Activity**: [HomeLoginActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Home/HomeLoginActivity.java)

**UI Components**:
- `edtCorpId` - EditText for Corporation ID (User ID)
- `edtUsername` - EditText for Username
- `edtPassword` - EditText for Password
- `btnLogin` - Login button

**Validation Before API Call**:
```java
if(edtCorpId.getText().toString().isEmpty() || 
   edtUsername.getText().toString().isEmpty() || 
   edtPassword.getText().toString().isEmpty()) {
    // Show error snackbar
    return;
}
```

---

## Step 1: Prepare Request

### Get Android Device ID
```java
String android_id = Settings.Secure.getString(
    getApplicationContext().getContentResolver(),
    Settings.Secure.ANDROID_ID
);
```
- This gets the unique identifier of the Android device
- Used to track device usage and prevent unauthorized device access

### Build URL
```java
String loginURL = Config.BaseUrl + "KioskService.asmx/ValidateTSheetKioskAdminLogin";
// Results in: http://14.99.211.60:9012/KioskService.asmx/ValidateTSheetKioskAdminLogin
```

### Prepare Parameters
```java
Map<String, String> params = new HashMap<>();
params.put("CorpID", edtCorpId.getText().toString());        // e.g., "arb-kol-dev"
params.put("UserName", edtUsername.getText().toString());    // e.g., "emp001"
params.put("Password", edtPassword.getText().toString());    // e.g., "password123"
params.put("DeviceID", android_id);                          // e.g., "a1b2c3d4e5f6g7h8"
```

---

## Step 2: Network Request

### HTTP POST Request
```
POST /KioskService.asmx/ValidateTSheetKioskAdminLogin HTTP/1.1
Host: 14.99.211.60:9012
Content-Type: application/x-www-form-urlencoded
Content-Length: 150

CorpID=arb-kol-dev&UserName=emp001&Password=password123&DeviceID=a1b2c3d4e5f6g7h8
```

### Network Library Used
- **Volley StringRequest** (Android HTTP library)
- Handles async HTTP requests with callback methods
- Includes automatic retry with exponential backoff

### Progress Dialog
```java
ProgressDialog loading = ProgressDialog.show(
    HomeLoginActivity.this, 
    "Authenticating", 
    "Please wait while logging", 
    false, 
    false
);
```
- Shows loading indicator to user during network request

---

## Step 3: Server Response Processing

### Raw Response (XML from Server)
```xml
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope ...>
  <soap:Body>
    <ValidateTSheetKioskAdminLoginResponse>
      <ValidateTSheetKioskAdminLoginResult>
        <content>{"status":"true","UserLogin":[{...}]}</content>
      </ValidateTSheetKioskAdminLoginResult>
    </ValidateTSheetKioskAdminLoginResponse>
  </soap:Body>
</soap:Envelope>
```

### XML to JSON Conversion
```java
JSONObject jsonObj = XML.toJSONObject(response);  // Convert XML to JSON
String responseData = jsonObj.toString();
JSONObject resobj = new JSONObject(responseData);
Iterator<?> keys = resobj.keys();

while(keys.hasNext()) {
    String key = (String)keys.next();
    if (resobj.get(key) instanceof JSONObject) {
        JSONObject xx = new JSONObject(resobj.get(key).toString());
        String val = xx.getString("content");  // Extract "content" field
        JSONObject jsonObject = new JSONObject(val);
        String status = jsonObject.getString("status");
        // ... continue processing
    }
}
```

### Parsed JSON Response (ON SUCCESS)
```json
{
  "status": "true",
  "UserLogin": [
    {
      "UserID": "u123",
      "UserName": "emp001",
      "CompID": "comp1",
      "CorpID": "arb-kol-dev",
      "CompanyName": "ARB Company",
      "PersonId": 1001,
      "EmployeeCode": "EMP001",
      "EmpName": "John Doe",
      "SupervisorId": "sup1",
      "Supervisor1": "Supervisor Name",
      "Supervisor2": "Co-Manager Name",
      "UserRole": "ADMIN",
      "AdminYN": "Y",
      "PayableClerkYN": "N",
      "SupervisorYN": "N",
      "PurchaseYN": "N",
      "PayrollClerkYN": "N",
      "UserType": "MAIN",
      "EmailId": "john.doe@company.com",
      "PwdSetterId": "pwd1",
      "FinYearID": "2023-24",
      "Msg": "Login successful",
      "EmailServer": "smtp.gmail.com",
      "EmailServerPort": "587",
      "EmailUsername": "noreply@company.com",
      "EmailPassword": "encoded_password",
      "EmailHostAddress": "company.com"
    }
  ],
  "message": "Login successful"
}
```

### Response Field Explanations

**User Identification:**
- `UserID`: System user identifier
- `UserName`: Login username
- `CompID`: Company ID
- `CorpID`: Corporation/Client ID
- `PersonId`: Employee person ID (used in subsequent API calls)
- `EmployeeCode`: Employee code
- `EmpName`: Full employee name

**User Permissions & Roles:**
- `UserRole`: User's role in system (ADMIN, SUPERVISOR, etc.)
- `AdminYN`: Is admin? (Y/N)
- `SupervisorYN`: Is supervisor? (Y/N)
- `PayableClerkYN`: Can process payables? (Y/N)
- `PurchaseYN`: Can make purchases? (Y/N)
- `PayrollClerkYN`: Can manage payroll? (Y/N)
- `UserType`: Type of user (MAIN, TEMPORARY, etc.)

**Contact & Company Info:**
- `CompanyName`: Company name
- `EmailId`: Employee email
- `Supervisor1`, `Supervisor2`: Supervisor names
- `SupervisorId`: Manager ID

**Financial & System Info:**
- `FinYearID`: Financial year (e.g., "2023-24")
- `PwdSetterId`: Password manager ID
- `Msg`: Additional message

**Email Configuration (for internal email system):**
- `EmailServer`: SMTP server address
- `EmailServerPort`: SMTP port
- `EmailUsername`: Email sending account
- `EmailPassword`: Email password (usually encrypted)
- `EmailHostAddress`: Organization domain

---

## Step 4: Response Success Processing

### On Success (status = "true")

#### 1. Extract Data into Static Variables
```java
HomeLoginActivity.EmployeeName = jsonObject1.getString("EmpName");
HomeLoginActivity.EmployeeCode = jsonObject1.getString("EmployeeCode");
HomeLoginActivity.PersonId = jsonObject1.getInt("PersonId");
HomeLoginActivity.Supervisor1 = jsonObject1.getString("Supervisor1");
HomeLoginActivity.Supervisor2 = jsonObject1.getString("Supervisor2");
```

#### 2. Store in UserSingletonModel
```java
UserSingletonModel userSingletonModel = UserSingletonModel.getInstance();
userSingletonModel.setUserID(jsonObject1.getString("UserID"));
userSingletonModel.setUserName(jsonObject1.getString("UserName"));
userSingletonModel.setCompID(jsonObject1.getString("CompID"));
userSingletonModel.setCorpID(jsonObject1.getString("CorpID"));
userSingletonModel.setCompanyName(jsonObject1.getString("CompanyName"));
userSingletonModel.setSupervisorId(jsonObject1.getString("SupervisorId"));
userSingletonModel.setUserRole(jsonObject1.getString("UserRole"));
userSingletonModel.setAdminYN(jsonObject1.getString("AdminYN"));
// ... and many more fields (see class for complete list)
```

#### 3. Store in SharedPreferences (Persistent Local Storage)
```java
SharedPreferences sharedPreferences = getApplication()
    .getSharedPreferences("LoginDetails", Context.MODE_PRIVATE);
SharedPreferences.Editor editor = sharedPreferences.edit();

editor.putString("UserID", userSingletonModel.getUserID());
editor.putString("UserName", userSingletonModel.getUserName());
editor.putString("CorpID", userSingletonModel.getCorpID());
// ... store all fields
editor.commit();
```

**SharedPreferences Benefits**:
- Persistent storage on device
- Survives app restart
- Allows auto-login on next session
- Used for offline access to user data

#### 4. Save Corporation ID for Next Login
```java
editor.putString("CorpIdForUserAutofill", edtCorpId.getText().toString());
editor.commit();
```
- Auto-fills CorpID on next login screen

#### 5. Navigate to Next Screen
```java
Intent intent = new Intent(HomeLoginActivity.this, RecognitionOptionActivity.class);
intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
startActivity(intent);
loading.dismiss();
finish();
```

**Activity Navigation**:
- Clears activity stack with `FLAG_ACTIVITY_CLEAR_TASK`
- Opens new task with `FLAG_ACTIVITY_NEW_TASK`
- Closes login activity with `finish()`
- Dismisses loading dialog

---

## Step 5: Response Error Processing

### On Failure (status = "false")

```java
else if(status.equalsIgnoreCase("false")) {
    loading.dismiss();
    String message = jsonObject.getString("message");
    
    // Show error via Snackbar
    View v = findViewById(R.id.relativeLayout);
    new Snackbar(message, v);  // Custom snackbar at bottom
    
    // Re-enable login button
    btnLogin.setEnabled(true);
    btnLogin.setClickable(true);
    btnLogin.setAlpha(1.0f);
}
```

### Common Error Messages:
```
"Invalid credentials"
"User not found"
"Invalid corporation ID"
"Account locked"
"Password expired"
```

---

## Step 6: Network Error Handling

### If Network Request Fails

```java
@Override
public void onErrorResponse(VolleyError error) {
    loading.dismiss();
    btnLogin.setEnabled(true);
    btnLogin.setClickable(true);
    btnLogin.setAlpha(1.0f);
    
    String message = "Could not connect server";
    View v = findViewById(R.id.relativeLayout);
    new Snackbar(message, v);
    
    Log.d("Volley Error", error.toString());
}
```

### Error Types:
1. **TimeoutError**: Network took too long
2. **NoConnectionError**: No internet connection
3. **AuthFailureError**: 401/403 Auth failed
4. **ServerError**: 500+ Server errors
5. **NetworkError**: General network failure

### Retry Policy
```java
stringRequest.setRetryPolicy(
    new DefaultRetryPolicy(
        10000,                                    // timeout (ms)
        3,                                        // max retries
        DefaultRetryPolicy.DEFAULT_BACKOFF_MULT   // backoff multiplier
    )
);
```

---

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. USER ENTERS LOGIN CREDENTIALS                               │
│    - CorpID (Corporation/User ID)                              │
│    - Username                                                  │
│    - Password                                                  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. VALIDATION                                                    │
│    - Check all fields not empty                                │
│    - Get Android Device ID                                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. HTTP POST REQUEST                                             │
│    POST /KioskService.asmx/ValidateTSheetKioskAdminLogin       │
│    Params: CorpID, UserName, Password, DeviceID               │
│    Server: 14.99.211.60:9012                                   │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
                    ▼                 ▼
        ┌───────────────────┐  ┌───────────────────┐
        │ SUCCESS           │  │ FAILURE           │
        │ (status=true)     │  │ (status=false)    │
        └────────┬──────────┘  └────────┬──────────┘
                 │                      │
                 ▼                      ▼
        ┌──────────────────────┐ ┌──────────────────┐
        │ EXTRACT USER DATA    │ │ SHOW ERROR MSG   │
        └────────┬─────────────┘ │ RE-ENABLE BUTTON │
                 │               └──────────────────┘
                 ▼
        ┌──────────────────────┐
        │ STORE IN             │
        │ - Singleton Model    │
        │ - SharedPreferences  │
        │ - Static Variables   │
        └────────┬─────────────┘
                 │
                 ▼
        ┌──────────────────────┐
        │ NAVIGATE TO          │
        │ RecognitionOption    │
        │ Activity             │
        └──────────────────────┘
```

---

## Key Variables & Constants

| Variable | Type | Value | Usage |
|----------|------|-------|-------|
| `BaseUrl` | String | `http://14.99.211.60:9012/` | Base server URL (in Config.java) |
| `android_id` | String | Device unique ID | Sent with every request |
| `PersonId` (Static) | Integer | Employee person ID | Used in all subsequent APIs |
| `EmployeeName` (Static) | String | Employee full name | Display in UI |
| `EmployeeCode` (Static) | String | Employee code | Display/logging |

---

## Security Considerations

1. **Password Transmission**: Sent over HTTP (not HTTPS) - **Security Risk**
   - Should use HTTPS in production

2. **Device ID Tracking**: Android Device ID sent with each request
   - Used to prevent unauthorized access from different devices
   - Can be reset if user clears app data

3. **Local Storage**: User data stored in SharedPreferences
   - Not encrypted (security concern)
   - Accessible to other apps with FILE permission

4. **Session Management**: No explicit session timeout
   - User data persists until manual logout or app uninstall

5. **Email Credentials**: Stored locally in plain text
   - High security risk if device is compromised

---

## Testing the Login API

### Using cURL (command line):
```bash
curl -X POST http://14.99.211.60:9012/KioskService.asmx/ValidateTSheetKioskAdminLogin \
  -d "CorpID=arb-kol-dev" \
  -d "UserName=emp001" \
  -d "Password=password123" \
  -d "DeviceID=test-device-123"
```

### Using Postman:
1. Method: **POST**
2. URL: `http://14.99.211.60:9012/KioskService.asmx/ValidateTSheetKioskAdminLogin`
3. Body (form-data):
   - `CorpID`: arb-kol-dev
   - `UserName`: emp001
   - `Password`: password123
   - `DeviceID`: test-device-123
4. Send and check response

---

## Related Source Files

- **Main Login Activity**: [HomeLoginActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Home/HomeLoginActivity.java)
- **Admin Login Activity**: [Admin/LoginActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Admin/LoginActivity.java)
- **Config File**: [Config.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Config/Config.java)
- **User Model**: [UserSingletonModel.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Model/UserSingletonModel.java)
- **Next Activity**: [RecognitionOptionActivity.java](app/src/main/java/org/arb/wrkplantimesheetkiosk/Recognize/RecognitionOptionActivity.java)

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| "Could not connect server" | Network error or server down | Check internet connection, verify server IP |
| "Invalid credentials" | Wrong username/password | Verify credentials are correct |
| Login hangs | Long network timeout | Check network speed, try again |
| No response | Server not responding | Verify server is running, check firewall |
| Response parsing error | Unexpected response format | Check server API response, review logs |

---

## API Response Status Codes

| Status | Meaning | User Action |
|--------|---------|-------------|
| "true" | Login successful | Proceed to next activity |
| "false" | Login failed | Show error message, allow retry |

