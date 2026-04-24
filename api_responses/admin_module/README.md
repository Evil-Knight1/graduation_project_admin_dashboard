# Admin Module - Frontend Integration Guide

This document provides the technical specifications for the Admin Dashboard API. All responses follow a standard `ApiResponse<T>` wrapper.

## Standard Response Wrapper
All endpoints return the following structure:

```typescript
interface ApiResponse<T> {
  success: boolean;    // Indicates if the request was successful
  message: string | null; // Feedback message for the user/developer
  data: T;             // The actual payload (DTO)
  errors: string[] | null; // List of error messages if success is false
}
```

---

## 1. Dashboard Metrics
**Endpoint:** `GET /api/Admin/dashboard`  
**Example:** [dashboard.json](./dashboard.json)

### `DashboardDto`
| Property | Type | Description |
| :--- | :--- | :--- |
| `totalUsers` | `number` | Total number of registered users (Patients + Doctors) |
| `activeUsers` | `number` | Users who have logged in recently |
| `pendingDoctors` | `number` | Doctors awaiting admin approval |
| `totalRevenue` | `number` | Cumulative revenue from all payments |
| `todayRevenue` | `number` | Revenue generated since the start of the current day |
| `totalAppointments` | `number` | Total number of appointments scheduled in the system |

---

## 2. Statistics & Analytics

### User Growth
**Endpoint:** `GET /api/Admin/statistics/user-growth?year=2026`  
**Example:** [user_growth.json](./user_growth.json)

#### `UserGrowthDto[]`
| Property | Type | Description |
| :--- | :--- | :--- |
| `year` | `number` | The year of the record |
| `quarter` | `number` | Quarter (1-4) |
| `quarterName` | `string` | Human-readable name (e.g., "Q1", "Q2") |
| `newPatients` | `number` | Count of patients registered in this quarter |
| `newDoctors` | `number` | Count of doctors registered in this quarter |
| `totalNewUsers` | `number` | Combined count of new users |

### Revenue Breakdown
| Feature | Endpoint | Example |
| :--- | :--- | :--- |
| **Total** | `GET /api/Admin/statistics/revenue` | [revenue.json](./revenue.json) |
| **Monthly** | `GET /api/Admin/statistics/monthly-revenue?year=2026` | [monthly_revenue.json](./monthly_revenue.json) |
| **Daily** | `GET /api/Admin/statistics/daily-revenue?year=2026&month=4` | [daily_revenue.json](./daily_revenue.json) |

#### `MonthlyRevenueDto`
| Property | Type | Description |
| :--- | :--- | :--- |
| `year` | `number` | The year of the record |
| `month` | `number` | Month (1-12) |
| `monthName` | `string` | Month name (e.g., "January") |
| `revenue` | `number` | Total revenue for that month |

#### `DailyRevenueDto` | `date: string (ISO)`, `revenue: number` |

---

## 3. User Management (Paginated)
Endpoints return a paginated object containing an array of items.

| Feature | Endpoint | Example |
| :--- | :--- | :--- |
| **Doctors** | `GET /api/Admin/doctors` | [doctors.json](./doctors.json) |
| **Patients** | `GET /api/Admin/patients` | [patients.json](./patients.json) |

### `PaginatedResult<T>`
- `items`: `T[]` (List of Doctor/Patient objects)
- `totalCount`: `number`
- `pageNumber`: `number`
- `pageSize`: `number`

---

## 4. Admin Notifications
**Endpoint:** `GET /api/Admin/notifications`  
**Example:** [notifications.json](./notifications.json)

### `AdminNotificationDto`
| Property | Type | Description |
| :--- | :--- | :--- |
| `id` | `number` | Unique identifier |
| `title` | `string` | Short title of the notification |
| `message` | `string` | Detailed message content |
| `type` | `string` | Categorization (e.g., "DoctorRegistration", "System") |
| `isRead` | `boolean` | Read/Unread status |
| `createdAt` | `string` | Creation timestamp (ISO) |
| `readAt` | `string \| null`| Timestamp when marked as read |
| `relatedEntityId`| `string \| null`| ID for navigation (e.g., DoctorID to view profile) |

### Unread Count
**Endpoint:** `GET /api/Admin/notifications/unread-count`  
**Response:** `ApiResponse<number>`

---

## 5. Quick Actions (Post/Put)
These endpoints typically return `ApiResponse<boolean>`.

- **Approve Doctor:** `POST /api/Admin/doctors/{id}/approve`
- **Reject Doctor:** `POST /api/Admin/doctors/{id}/reject`
- **Delete User:** `DELETE /api/Admin/users/{id}`
- **Mark Notification Read:** `PUT /api/Admin/notifications/{id}/read`
