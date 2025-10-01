# API Documentation

Complete API specification for Urban Express with authentication, real-time capabilities, and comprehensive error handling.

## API Overview

### Base Configuration
- **Base URL**: `https://your-project.supabase.co/rest/v1`
- **Authentication**: Supabase JWT tokens
- **Content Type**: `application/json`
- **Real-time**: Supabase Realtime WebSocket connections
- **Rate Limiting**: 100 requests per minute per user

### Authentication Headers
```http
Authorization: Bearer <jwt_token>
apikey: <supabase_anon_key>
Content-Type: application/json
Prefer: return=representation
```

## Authentication Endpoints

### Login
```http
POST /auth/v1/token?grant_type=password
Content-Type: application/json

{
  "phone": "0501234567",
  "password": "userpassword"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "user": {
    "id": "uuid",
    "phone": "0501234567",
    "role": "customer",
    "user_metadata": {
      "full_name": "أحمد محمد",
      "branch_id": "uuid"
    }
  }
}
```

### Refresh Token
```http
POST /auth/v1/token?grant_type=refresh_token
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Logout
```http
POST /auth/v1/logout
Authorization: Bearer <jwt_token>
```

## User Management

### Get Current User Profile
```http
GET /users?id=eq.<user_id>&select=*,customers(*)
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "id": "uuid",
  "role": "customer",
  "full_name": "أحمد محمد",
  "whatsapp_number": "0501234567",
  "status": "active",
  "branch_id": "uuid",
  "created_at": "2024-01-15T10:30:00Z",
  "customers": {
    "default_location": {
      "lat": 24.6877,
      "lng": 46.6753,
      "address": "طريق الملك فهد، الرياض",
      "label": "المنزل",
      "verified_at": "2024-01-15T10:30:00Z"
    },
    "terms_version_accepted": "1.0",
    "terms_accepted_at": "2024-01-15T10:30:00Z",
    "qac_enabled": true
  }
}
```

### Update User Profile
```http
PATCH /users?id=eq.<user_id>
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "full_name": "أحمد محمد السالم"
}
```

### Update Customer Default Location
```http
PATCH /customers?user_id=eq.<user_id>
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "default_location": {
    "lat": 24.7136,
    "lng": 46.6753,
    "address": "حي العليا، الرياض",
    "label": "العمل",
    "verified_at": "2024-01-15T14:30:00Z"
  }
}
```

## Order Management

### Create Order
```http
POST /orders
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "customer_id": "uuid",
  "subtotal": 125.50,
  "location_snapshot": {
    "lat": 24.6877,
    "lng": 46.6753,
    "address": "طريق الملك فهد، الرياض",
    "label": "المنزل"
  },
  "scheduled_window": "[2024-01-15T16:00:00Z,2024-01-15T18:00:00Z)",
  "delivery_notes": "الطابق الثاني، شقة رقم 5",
  "payment_method": "cash"
}
```

**Response:**
```json
{
  "id": "uuid",
  "order_number": "UE-20240115-1234",
  "customer_id": "uuid",
  "status": "placed",
  "subtotal": 125.50,
  "delivery_charge": 0,
  "discount": 0,
  "total": 125.50,
  "location_snapshot": {
    "lat": 24.6877,
    "lng": 46.6753,
    "address": "طريق الملك فهد، الرياض",
    "label": "المنزل"
  },
  "scheduled_window": "[2024-01-15T16:00:00Z,2024-01-15T18:00:00Z)",
  "payment_method": "cash",
  "placed_at": "2024-01-15T10:30:00Z",
  "created_at": "2024-01-15T10:30:00Z"
}
```

### Add Order Items
```http
POST /order_items
Authorization: Bearer <jwt_token>
Content-Type: application/json

[
  {
    "order_id": "uuid",
    "sku": "PROD001",
    "name": "لحم مفروم طازج - 1 كيلو",
    "quantity": 2,
    "unit_price": 45.00,
    "notes": "لحم قليل الدهون"
  },
  {
    "order_id": "uuid",
    "sku": "PROD002", 
    "name": "خضار مشكلة - 500 جرام",
    "quantity": 1,
    "unit_price": 15.50
  }
]
```

### Get Customer Orders
```http
GET /orders?customer_id=eq.<user_id>&order=created_at.desc&select=*,order_items(*),route_stops(routes(driver_id,users(full_name)))
Authorization: Bearer <jwt_token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "order_number": "UE-20240115-1234",
    "status": "out_for_delivery",
    "subtotal": 125.50,
    "delivery_charge": 10.00,
    "total": 135.50,
    "location_snapshot": {
      "lat": 24.6877,
      "lng": 46.6753,
      "address": "طريق الملك فهد، الرياض"
    },
    "payment_method": "cash",
    "placed_at": "2024-01-15T10:30:00Z",
    "order_items": [
      {
        "sku": "PROD001",
        "name": "لحم مفروم طازج - 1 كيلو",
        "quantity": 2,
        "unit_price": 45.00,
        "line_total": 90.00
      }
    ],
    "route_stops": [
      {
        "routes": {
          "driver_id": "uuid",
          "users": {
            "full_name": "محمد أحمد"
          }
        }
      }
    ]
  }
]
```

### Update Order Status (Dispatcher/Admin)
```http
PATCH /orders?id=eq.<order_id>
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "status": "confirmed",
  "confirmed_at": "2024-01-15T10:35:00Z"
}
```

### Add Delivery Charge (Dispatcher)
```http
PATCH /orders?id=eq.<order_id>
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "delivery_charge": 15.00,
  "delivery_charge_added_by": "uuid",
  "delivery_charge_added_at": "2024-01-15T11:00:00Z"
}
```

### Customer Accept/Decline Delivery Charge
```http
PATCH /orders?id=eq.<order_id>
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "delivery_charge_accepted_at": "2024-01-15T11:05:00Z"
}
```

## Route Management

### Get Driver Routes
```http
GET /routes?driver_id=eq.<driver_id>&date=eq.2024-01-15&select=*,route_stops(*,orders(*,order_items(*)))
Authorization: Bearer <jwt_token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "date": "2024-01-15",
    "status": "assigned",
    "optimized_at": "2024-01-15T08:00:00Z",
    "assigned_at": "2024-01-15T08:30:00Z",
    "route_stops": [
      {
        "id": "uuid",
        "sequence_number": 1,
        "planned_eta": "2024-01-15T16:00:00Z",
        "status": "pending",
        "orders": {
          "id": "uuid",
          "order_number": "UE-20240115-1234",
          "total": 135.50,
          "location_snapshot": {
            "lat": 24.6877,
            "lng": 46.6753,
            "address": "طريق الملك فهد، الرياض"
          },
          "payment_method": "cash",
          "order_items": [...]
        }
      }
    ]
  }
]
```

### Update Route Stop Status
```http
PATCH /route_stops?id=eq.<stop_id>
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "status": "arrived",
  "actual_arrival_at": "2024-01-15T16:05:00Z"
}
```

### Create Route (Dispatcher)
```http
POST /routes
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "date": "2024-01-15",
  "branch_id": "uuid",
  "dispatcher_id": "uuid",
  "driver_id": "uuid",
  "opening_cash_kit_id": "uuid"
}
```

### Add Orders to Route
```http
POST /route_stops
Authorization: Bearer <jwt_token>
Content-Type: application/json

[
  {
    "route_id": "uuid",
    "order_id": "uuid",
    "sequence_number": 1,
    "planned_eta": "2024-01-15T16:00:00Z"
  },
  {
    "route_id": "uuid", 
    "order_id": "uuid",
    "sequence_number": 2,
    "planned_eta": "2024-01-15T16:30:00Z"
  }
]
```

## Payment Management

### Record Payment (Driver)
```http
POST /payment_receipts
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "order_id": "uuid",
  "drawer_id": "uuid",
  "method": "cash",
  "amount": 135.50,
  "recorded_by": "uuid",
  "location_recorded": "POINT(46.6753 24.6877)"
}
```

### Add Cash Breakdown (for Cash Payments)
```http
POST /payment_cash_breakdown
Authorization: Bearer <jwt_token>
Content-Type: application/json

[
  {
    "receipt_id": "uuid",
    "type": "received",
    "denomination_id": 1,
    "count": 1
  },
  {
    "receipt_id": "uuid",
    "type": "change_given", 
    "denomination_id": 8,
    "count": 1
  }
]
```

### Record Card Payment with Slip
```http
POST /payment_receipts
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "order_id": "uuid",
  "drawer_id": "uuid", 
  "method": "card_pos",
  "amount": 135.50,
  "card_last_four": "1234",
  "slip_photo_url": "https://storage.supabase.co/...",
  "pos_terminal_id": "TERM001",
  "recorded_by": "uuid",
  "location_recorded": "POINT(46.6753 24.6877)"
}
```

## Cash Drawer Management

### Open Cash Drawer
```http
POST /cash_drawers
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "driver_id": "uuid",
  "branch_id": "uuid",
  "route_id": "uuid"
}
```

### Add Opening Denominations
```http
POST /drawer_opening_denominations
Authorization: Bearer <jwt_token>
Content-Type: application/json

[
  {
    "drawer_id": "uuid",
    "denomination_id": 1,
    "count": 2
  },
  {
    "drawer_id": "uuid",
    "denomination_id": 8,
    "count": 10
  }
]
```

### Close Cash Drawer
```http
PATCH /cash_drawers?id=eq.<drawer_id>
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "status": "closing",
  "closed_at": "2024-01-15T20:00:00Z"
}
```

### Add Closing Denominations
```http
POST /drawer_closing_denominations
Authorization: Bearer <jwt_token>
Content-Type: application/json

[
  {
    "drawer_id": "uuid",
    "denomination_id": 1,
    "count": 3
  },
  {
    "drawer_id": "uuid",
    "denomination_id": 8,
    "count": 5
  }
]
```

### Get Drawer Balance Summary
```http
GET /rpc/get_drawer_balance_summary?drawer_id=<drawer_id>
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "opening_total": 1020.00,
  "closing_total": 1450.50,
  "payments_received": 850.00,
  "change_given": 25.50,
  "expected_closing": 1844.50,
  "variance": -394.00,
  "status": "variance"
}
```

## Notification Management

### Get User Notifications
```http
GET /notifications?to_user_id=eq.<user_id>&order=sent_at.desc&limit=50
Authorization: Bearer <jwt_token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "priority": "high",
    "topic": "delivery_charge_added",
    "title_ar": "رسوم توصيل",
    "title_en": "Delivery Charge Added",
    "body_ar": "تم إضافة رسوم توصيل 15 ر.س. الإجمالي 150.50 ر.س",
    "body_en": "Delivery charge SAR 15 added. Total SAR 150.50",
    "deep_link": "/orders/uuid",
    "entity_type": "order",
    "entity_id": "uuid",
    "sent_at": "2024-01-15T11:00:00Z",
    "is_read": false
  }
]
```

### Mark Notification as Read
```http
PATCH /notifications?id=eq.<notification_id>
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "is_read": true,
  "read_at": "2024-01-15T11:05:00Z"
}
```

### Send Notification (Admin/System)
```http
POST /notifications
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "to_user_id": "uuid",
  "template_key": "order_delivered",
  "priority": "normal",
  "topic": "order_delivered",
  "title_ar": "تم تسليم طلبك",
  "title_en": "Order Delivered",
  "body_ar": "تم تسليم طلبك رقم {{order_number}} بنجاح",
  "body_en": "Your order {{order_number}} has been delivered successfully",
  "deep_link": "/orders/uuid",
  "entity_type": "order",
  "entity_id": "uuid"
}
```

## Chat & Messaging

### Get Conversations
```http
GET /conversations?participants=cs.{<user_id>}&select=*,messages(id,body_text,sender_type,sender_id,sent_at)&order=updated_at.desc
Authorization: Bearer <jwt_token>
```

**Response:**
```json
[
  {
    "id": "uuid",
    "type": "order",
    "entity_id": "uuid",
    "participants": ["uuid1", "uuid2"],
    "status": "active",
    "language": "ar",
    "ai_enabled": true,
    "created_at": "2024-01-15T10:30:00Z",
    "messages": [
      {
        "id": "uuid",
        "body_text": "مرحباً، متى سيصل طلبي؟",
        "sender_type": "user",
        "sender_id": "uuid",
        "sent_at": "2024-01-15T10:30:00Z"
      },
      {
        "id": "uuid",
        "body_text": "طلبك في الطريق وسيصل خلال 30 دقيقة تقريباً",
        "sender_type": "ai",
        "sender_id": null,
        "sent_at": "2024-01-15T10:31:00Z"
      }
    ]
  }
]
```

### Send Message
```http
POST /messages
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "conversation_id": "uuid",
  "sender_type": "user",
  "sender_id": "uuid",
  "body_text": "شكراً لكم على الخدمة الممتازة",
  "attachments": []
}
```

### Create New Conversation
```http
POST /conversations
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "type": "support",
  "participants": ["uuid"],
  "language": "ar",
  "ai_enabled": true
}
```

## Real-time Subscriptions

### Order Status Updates
```javascript
const orderSubscription = supabase
  .channel('order-updates')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'orders',
    filter: `customer_id=eq.${userId}`
  }, (payload) => {
    console.log('Order updated:', payload.new);
  })
  .subscribe();
```

### Driver Route Updates
```javascript
const routeSubscription = supabase
  .channel('driver-route')
  .on('postgres_changes', {
    event: '*',
    schema: 'public',
    table: 'route_stops',
    filter: `route_id=eq.${routeId}`
  }, (payload) => {
    console.log('Route updated:', payload);
  })
  .subscribe();
```

### Chat Messages
```javascript
const chatSubscription = supabase
  .channel(`conversation:${conversationId}`)
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'messages',
    filter: `conversation_id=eq.${conversationId}`
  }, (payload) => {
    console.log('New message:', payload.new);
  })
  .subscribe();
```

### Notification Updates
```javascript
const notificationSubscription = supabase
  .channel('user-notifications')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'notifications',
    filter: `to_user_id=eq.${userId}`
  }, (payload) => {
    console.log('New notification:', payload.new);
  })
  .subscribe();
```

## Error Handling

### Standard Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "رقم الهاتف غير صحيح",
    "message_en": "Invalid phone number",
    "details": {
      "field": "whatsapp_number",
      "expected_format": "05XXXXXXXX"
    },
    "timestamp": "2024-01-15T10:30:00Z",
    "request_id": "uuid"
  }
}
```

### Common Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `UNAUTHORIZED` | 401 | Invalid or expired token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `VALIDATION_ERROR` | 400 | Invalid input data |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource already exists |
| `RATE_LIMITED` | 429 | Too many requests |
| `SERVER_ERROR` | 500 | Internal server error |

### Business Logic Errors

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `ORDER_NOT_MODIFIABLE` | 400 | Order cannot be modified in current status |
| `INSUFFICIENT_CASH` | 400 | Not enough cash for change |
| `DELIVERY_CHARGE_REQUIRED` | 400 | Customer must accept delivery charge |
| `LOCATION_OUT_OF_AREA` | 400 | Delivery location outside service area |
| `DRAWER_ALREADY_CLOSED` | 400 | Cash drawer is already closed |
| `PAYMENT_ALREADY_RECORDED` | 409 | Payment already exists for this order |

## Rate Limiting

### Limits by Endpoint Type
- **Authentication**: 10 requests per minute
- **Order operations**: 30 requests per minute  
- **Payment recording**: 20 requests per minute
- **Chat messages**: 60 requests per minute
- **General API**: 100 requests per minute

### Rate Limit Headers
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1642262400
```

## Webhooks

### Order Status Change
```json
{
  "event": "order.status_changed",
  "data": {
    "order_id": "uuid",
    "order_number": "UE-20240115-1234",
    "old_status": "packed",
    "new_status": "out_for_delivery",
    "changed_at": "2024-01-15T14:30:00Z",
    "changed_by": "uuid"
  }
}
```

### Payment Recorded
```json
{
  "event": "payment.recorded", 
  "data": {
    "payment_id": "uuid",
    "order_id": "uuid",
    "amount": 135.50,
    "method": "cash",
    "recorded_at": "2024-01-15T16:15:00Z",
    "recorded_by": "uuid"
  }
}
```

### Drawer Variance Detected
```json
{
  "event": "drawer.variance_detected",
  "data": {
    "drawer_id": "uuid",
    "driver_id": "uuid",
    "variance_amount": -25.50,
    "detected_at": "2024-01-15T20:00:00Z"
  }
}
```

This API documentation provides comprehensive coverage of all Urban Express endpoints with proper authentication, validation, and real-time capabilities. The API is designed to be RESTful, secure, and developer-friendly.