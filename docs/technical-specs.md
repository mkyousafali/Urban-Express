# Technical Specifications

## Development Environment Setup

### Prerequisites
- Node.js 18+ 
- npm 9+
- Git
- VS Code (recommended)
- Supabase CLI

### Monorepo Structure
```
urban-express/
├── apps/
│   ├── customer/                 # Customer PWA (Svelte + Vite)
│   ├── driver/                   # Driver PWA (Svelte + Vite)  
│   └── admin/                    # Admin Console PWA (Svelte + Vite)
├── packages/
│   ├── ui/                       # Design system components
│   ├── data/                     # Supabase client & types
│   ├── logic/                    # Business logic & validation
│   ├── i18n/                     # Internationalization
│   ├── notifications/            # Notification management
│   └── chat/                     # AI chat system
├── database/
│   ├── migrations/               # Supabase migrations
│   ├── seed/                     # Initial data
│   └── functions/                # Edge functions
├── docs/                         # Documentation
├── scripts/                      # Build & deployment
├── .github/                      # GitHub workflows
├── package.json                  # Root package.json
├── tsconfig.json                 # TypeScript config
├── .env.example                  # Environment template
└── README.md                     # Main documentation
```

### Package Manager Configuration
```json
{
  "name": "urban-express",
  "private": true,
  "workspaces": [
    "apps/*",
    "packages/*"
  ],
  "scripts": {
    "dev": "concurrently \"npm run dev:customer\" \"npm run dev:driver\" \"npm run dev:admin\"",
    "dev:customer": "cd apps/customer && npm run dev -- --port 3000",
    "dev:driver": "cd apps/driver && npm run dev -- --port 3001", 
    "dev:admin": "cd apps/admin && npm run dev -- --port 3002",
    "build": "npm run build --workspaces",
    "test": "npm run test --workspaces",
    "lint": "eslint . --ext .ts,.svelte",
    "format": "prettier --write .",
    "db:migrate": "supabase db push",
    "db:reset": "supabase db reset",
    "db:seed": "supabase db seed"
  }
}
```

## Application Architecture

### Customer PWA (`/apps/customer`)
```
customer/
├── src/
│   ├── routes/                   # SvelteKit routes
│   │   ├── +layout.svelte       # Root layout with nav
│   │   ├── +page.svelte         # Home page
│   │   ├── auth/                # Authentication pages
│   │   ├── products/            # Product catalog
│   │   ├── cart/                # Shopping cart
│   │   ├── orders/              # Order tracking
│   │   ├── profile/             # User profile
│   │   ├── notifications/       # Notification center
│   │   └── chat/                # Support chat
│   ├── lib/
│   │   ├── components/          # Page-specific components
│   │   ├── stores/              # Svelte stores
│   │   ├── utils/               # Utility functions
│   │   └── types/               # TypeScript types
│   ├── app.html                 # HTML template
│   ├── app.css                  # Global styles
│   └── service-worker.js        # PWA service worker
├── static/                      # Static assets
├── vite.config.js              # Vite configuration
├── package.json                # Dependencies
└── tsconfig.json               # TypeScript config
```

### Driver PWA (`/apps/driver`)
```
driver/
├── src/
│   ├── routes/
│   │   ├── +layout.svelte       # Root layout with tabs
│   │   ├── +page.svelte         # Dashboard
│   │   ├── auth/                # Authentication
│   │   ├── shift/               # Shift management
│   │   ├── route/               # Route & stops
│   │   ├── payments/            # Payment collection
│   │   ├── drawer/              # Cash drawer
│   │   ├── notifications/       # Alerts & notifications
│   │   └── chat/                # Order chat
│   ├── lib/
│   │   ├── components/
│   │   ├── stores/
│   │   ├── offline/             # Offline queue management
│   │   └── camera/              # POS slip photo capture
│   └── service-worker.js        # Enhanced offline support
```

### Admin Console (`/apps/admin`)
```
admin/
├── src/
│   ├── routes/
│   │   ├── +layout.svelte       # Responsive layout
│   │   ├── +page.svelte         # Dashboard
│   │   ├── auth/                # Admin authentication
│   │   ├── orders/              # Order management
│   │   ├── routing/             # Route planning
│   │   ├── users/               # User management
│   │   ├── drivers/             # Driver & drawer mgmt
│   │   ├── charges/             # Delivery charges
│   │   ├── notifications/       # Notification management
│   │   ├── chat/                # Chat operations
│   │   ├── ai/                  # AI training
│   │   ├── reports/             # Analytics & reports
│   │   └── settings/            # System configuration
│   ├── lib/
│   │   ├── components/
│   │   │   ├── dashboard/       # Dashboard widgets
│   │   │   ├── kanban/          # Order board
│   │   │   ├── forms/           # Admin forms
│   │   │   └── charts/          # Analytics charts
│   │   └── stores/
```

## Shared Packages

### UI Package (`/packages/ui`)
```typescript
// Design system exports
export { Button, type ButtonProps } from './Button.svelte';
export { Input, type InputProps } from './Input.svelte';
export { Card, type CardProps } from './Card.svelte';
export { Modal, type ModalProps } from './Modal.svelte';
export { NotificationToast } from './NotificationToast.svelte';
export { ChatBubble } from './ChatBubble.svelte';
export { PaymentKeypad } from './PaymentKeypad.svelte';
export { QACKeypad } from './QACKeypad.svelte';
export { OrderStatusBadge } from './OrderStatusBadge.svelte';
export { LocationCard } from './LocationCard.svelte';

// Design tokens
export { theme } from './theme.js';
export { breakpoints } from './breakpoints.js';
export { animations } from './animations.js';

// Utilities
export { cn } from './utils/classNames.js';
export { formatCurrency } from './utils/currency.js';
export { formatPhoneNumber } from './utils/phone.js';
```

### Data Package (`/packages/data`)
```typescript
// Supabase client
export { supabase } from './client.js';
export { createClient } from './factory.js';

// Database types (generated from Supabase)
export type { Database } from './types/database.js';
export type { Tables, Views, Functions } from './types/supabase.js';

// Business entity types
export type {
  User, Customer, Driver, Admin,
  Order, OrderItem, OrderStatus,
  Route, RouteStop, Delivery,
  Payment, CashDrawer, PaymentMethod,
  Notification, Conversation, Message,
  Branch, ServiceArea
} from './types/entities.js';

// API functions
export * from './api/auth.js';
export * from './api/orders.js';
export * from './api/payments.js';
export * from './api/notifications.js';
export * from './api/chat.js';
```

### Business Logic Package (`/packages/logic`)
```typescript
// Validation schemas (Zod)
export {
  userRegistrationSchema,
  orderSchema,
  paymentSchema,
  deliveryChargeSchema
} from './validation/schemas.js';

// Business rules
export {
  calculateOrderTotal,
  validateCashPayment,
  calculateDrawerBalance,
  canAddDeliveryCharge,
  isLocationInServiceArea
} from './rules/index.js';

// State machines
export {
  orderStateMachine,
  paymentStateMachine,
  drawerStateMachine
} from './machines/index.js';

// Utilities
export {
  formatSAR,
  parsePhoneNumber,
  calculateDistance,
  generateOrderNumber
} from './utils/index.js';
```

### i18n Package (`/packages/i18n`)
```typescript
// Translation management
export { t, locale, locales } from './index.js';
export { setLocale, getLocale } from './locale.js';
export { formatNumber, formatCurrency, formatDate } from './formatters.js';

// RTL utilities
export { isRTL, getDirection, mirrorClassName } from './rtl.js';

// Translation keys (type-safe)
export type { TranslationKey } from './types.js';

// Language resources
import ar from './locales/ar.json';
import en from './locales/en.json';
export { ar, en };
```

## Database Schema Implementation

### Core Tables Structure

```sql
-- Identity & Authentication
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role user_role NOT NULL DEFAULT 'customer',
  full_name TEXT NOT NULL,
  whatsapp_number TEXT UNIQUE NOT NULL CHECK (whatsapp_number ~ '^05[0-9]{8}$'),
  password_hash TEXT NOT NULL,
  status user_status NOT NULL DEFAULT 'pending',
  branch_id UUID REFERENCES branches(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Customer-specific data
CREATE TABLE customers (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  default_location JSONB NOT NULL, -- {lat, lng, address, label, verified_at}
  terms_version_accepted TEXT,
  terms_accepted_at TIMESTAMPTZ,
  qac_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders and commerce
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT UNIQUE NOT NULL,
  customer_id UUID NOT NULL REFERENCES users(id),
  status order_status NOT NULL DEFAULT 'placed',
  subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
  delivery_charge DECIMAL(10,2) DEFAULT 0 CHECK (delivery_charge >= 0),
  discount DECIMAL(10,2) DEFAULT 0 CHECK (discount >= 0),
  total DECIMAL(10,2) GENERATED ALWAYS AS (subtotal + delivery_charge - discount) STORED,
  scheduled_window TSTZRANGE,
  location_snapshot JSONB NOT NULL, -- Immutable after checkout
  payment_method payment_method,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payment and cash management
CREATE TABLE cash_denominations (
  id SERIAL PRIMARY KEY,
  value DECIMAL(10,2) NOT NULL UNIQUE,
  is_coin BOOLEAN NOT NULL DEFAULT FALSE,
  display_order INTEGER NOT NULL
);

CREATE TABLE cash_drawers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES users(id),
  branch_id UUID NOT NULL REFERENCES branches(id),
  opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  status drawer_status NOT NULL DEFAULT 'open',
  variance_minor DECIMAL(10,2) DEFAULT 0,
  variance_note TEXT,
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ
);

-- Notifications and communication
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  to_user_id UUID NOT NULL REFERENCES users(id),
  priority notification_priority NOT NULL DEFAULT 'normal',
  topic TEXT NOT NULL,
  title_ar TEXT NOT NULL,
  title_en TEXT NOT NULL,
  body_ar TEXT NOT NULL,
  body_en TEXT NOT NULL,
  deep_link TEXT,
  entity_type TEXT,
  entity_id UUID,
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ
);

CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type conversation_type NOT NULL,
  entity_id UUID, -- Order ID, drawer ID, etc.
  participants UUID[] NOT NULL DEFAULT '{}',
  status conversation_status NOT NULL DEFAULT 'active',
  language TEXT NOT NULL DEFAULT 'ar',
  branch_id UUID REFERENCES branches(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Enums and Types

```sql
-- User roles
CREATE TYPE user_role AS ENUM ('customer', 'driver', 'dispatcher', 'admin');
CREATE TYPE user_status AS ENUM ('pending', 'active', 'suspended', 'inactive');

-- Order lifecycle
CREATE TYPE order_status AS ENUM (
  'placed', 'confirmed', 'picking', 'packed', 
  'ready_to_route', 'out_for_delivery', 'delivered', 
  'cancelled', 'exception'
);

-- Payment methods
CREATE TYPE payment_method AS ENUM ('cash', 'card_pos');

-- Drawer management
CREATE TYPE drawer_status AS ENUM ('open', 'closing', 'closed', 'variance');

-- Communication
CREATE TYPE notification_priority AS ENUM ('low', 'normal', 'high', 'critical');
CREATE TYPE conversation_type AS ENUM ('order', 'support', 'drawer', 'registration');
CREATE TYPE conversation_status AS ENUM ('active', 'resolved', 'escalated');
```

### Row Level Security Policies

```sql
-- Customer access policies
CREATE POLICY "Customers can view own data" ON users
  FOR SELECT USING (auth.uid() = id AND role = 'customer');

CREATE POLICY "Customers can update own profile" ON users  
  FOR UPDATE USING (auth.uid() = id AND role = 'customer')
  WITH CHECK (whatsapp_number = OLD.whatsapp_number); -- Cannot change WhatsApp

CREATE POLICY "Customers can view own orders" ON orders
  FOR SELECT USING (customer_id = auth.uid());

-- Driver access policies  
CREATE POLICY "Drivers can view assigned routes" ON route_stops
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM routes r 
      WHERE r.id = route_id AND r.driver_id = auth.uid()
    )
  );

CREATE POLICY "Drivers can manage own drawer" ON cash_drawers
  FOR ALL USING (driver_id = auth.uid());

-- Admin/Dispatcher policies
CREATE POLICY "Admins have full access" ON users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users u 
      WHERE u.id = auth.uid() AND u.role IN ('admin', 'dispatcher')
    )
  );
```

## Real-time Implementation

### Supabase Realtime Subscriptions

```typescript
// Order status updates
const orderSubscription = supabase
  .channel('order-updates')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'orders',
    filter: `customer_id=eq.${userId}`
  }, (payload) => {
    // Update order status in real-time
    orderStore.update(payload.new);
  })
  .subscribe();

// Driver route updates
const routeSubscription = supabase
  .channel('driver-route')
  .on('postgres_changes', {
    event: '*',
    schema: 'public', 
    table: 'route_stops',
    filter: `route_id=eq.${routeId}`
  }, (payload) => {
    // Update route progress
    routeStore.update(payload);
  })
  .subscribe();

// Chat messages
const chatSubscription = supabase
  .channel(`conversation:${conversationId}`)
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'messages',
    filter: `conversation_id=eq.${conversationId}`
  }, (payload) => {
    // Add new message to chat
    messagesStore.add(payload.new);
  })
  .subscribe();
```

### Offline Queue Implementation (Driver App)

```typescript
// Offline queue store
interface OfflineAction {
  id: string;
  type: 'payment' | 'status_update' | 'message';
  data: any;
  timestamp: number;
  retries: number;
}

class OfflineQueue {
  private queue: OfflineAction[] = [];
  
  async enqueue(action: Omit<OfflineAction, 'id' | 'timestamp' | 'retries'>) {
    const item: OfflineAction = {
      ...action,
      id: crypto.randomUUID(),
      timestamp: Date.now(),
      retries: 0
    };
    
    this.queue.push(item);
    await this.saveToLocalStorage();
    
    // Try to sync immediately if online
    if (navigator.onLine) {
      this.syncQueue();
    }
  }
  
  async syncQueue() {
    const pendingItems = this.queue.filter(item => item.retries < 3);
    
    for (const item of pendingItems) {
      try {
        await this.processAction(item);
        this.queue = this.queue.filter(q => q.id !== item.id);
      } catch (error) {
        item.retries++;
        console.error(`Failed to sync action ${item.id}:`, error);
      }
    }
    
    await this.saveToLocalStorage();
  }
  
  private async processAction(action: OfflineAction) {
    switch (action.type) {
      case 'payment':
        return await this.syncPayment(action.data);
      case 'status_update':
        return await this.syncStatusUpdate(action.data);
      case 'message':
        return await this.syncMessage(action.data);
    }
  }
}

// Service worker background sync
self.addEventListener('sync', (event) => {
  if (event.tag === 'driver-queue-sync') {
    event.waitUntil(
      // Sync offline queue when connection restored
      self.registration.sync.register('driver-queue-sync')
    );
  }
});
```

## PWA Implementation

### Service Worker Strategy

```javascript
// service-worker.js
import { precacheAndRoute, cleanupOutdatedCaches } from 'workbox-precaching';
import { registerRoute } from 'workbox-routing';
import { CacheFirst, NetworkFirst, StaleWhileRevalidate } from 'workbox-strategies';

// Precache app shell
precacheAndRoute(self.__WB_MANIFEST);
cleanupOutdatedCaches();

// API calls - Network First with fallback
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new NetworkFirst({
    cacheName: 'api-cache',
    networkTimeoutSeconds: 10,
    plugins: [{
      cacheKeyWillBeUsed: async ({ request }) => {
        // Add user context to cache key
        return `${request.url}-${getUserId()}`;
      }
    }]
  })
);

// Static assets - Cache First
registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({
    cacheName: 'images',
    plugins: [{
      cacheableResponse: {
        statuses: [0, 200]
      }
    }]
  })
);

// Background sync for driver app
self.addEventListener('sync', async (event) => {
  if (event.tag === 'driver-data-sync') {
    event.waitUntil(syncDriverData());
  }
});

// Push notifications
self.addEventListener('push', (event) => {
  const data = event.data?.json() ?? {};
  
  event.waitUntil(
    self.registration.showNotification(data.title, {
      body: data.body,
      icon: '/icons/icon-192x192.png',
      badge: '/icons/badge-72x72.png',
      data: data.deepLink,
      actions: data.actions || []
    })
  );
});

// Notification click handling
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  event.waitUntil(
    clients.openWindow(event.notification.data || '/')
  );
});
```

### Web App Manifest

```json
{
  "name": "Urban Express",
  "short_name": "Urban Express",
  "description": "Delivery management system",
  "start_url": "/",
  "display": "standalone",
  "orientation": "portrait",
  "theme_color": "#10B981",
  "background_color": "#F8FAFC",
  "icons": [
    {
      "src": "/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-96x96.png", 
      "sizes": "96x96",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-128x128.png",
      "sizes": "128x128", 
      "type": "image/png"
    },
    {
      "src": "/icons/icon-144x144.png",
      "sizes": "144x144",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-152x152.png",
      "sizes": "152x152",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-384x384.png",
      "sizes": "384x384",
      "type": "image/png"
    },
    {
      "src": "/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ],
  "shortcuts": [
    {
      "name": "New Order",
      "short_name": "Order",
      "description": "Place a new order",
      "url": "/orders/new",
      "icons": [{"src": "/icons/shortcut-order.png", "sizes": "96x96"}]
    },
    {
      "name": "Track Order", 
      "short_name": "Track",
      "description": "Track your order",
      "url": "/orders/track",
      "icons": [{"src": "/icons/shortcut-track.png", "sizes": "96x96"}]
    }
  ],
  "categories": ["food", "shopping", "business"],
  "lang": "ar",
  "dir": "rtl"
}
```

## Development Workflow

### Environment Configuration

```bash
# .env.example
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# External APIs
VITE_GOOGLE_MAPS_API_KEY=your-google-maps-key
OPENAI_API_KEY=your-openai-key
WHATSAPP_BUSINESS_API_TOKEN=your-whatsapp-token

# App Configuration
VITE_APP_ENV=development
VITE_API_BASE_URL=http://localhost:54321
VITE_DEFAULT_LOCALE=ar
VITE_SUPPORTED_LOCALES=ar,en

# Push Notifications
VITE_VAPID_PUBLIC_KEY=your-vapid-public-key
VAPID_PRIVATE_KEY=your-vapid-private-key

# Development Ports
VITE_CUSTOMER_PORT=3000
VITE_DRIVER_PORT=3001
VITE_ADMIN_PORT=3002
```

### TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "preserve",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "skipLibCheck": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@urban-express/ui": ["./packages/ui/src/index.ts"],
      "@urban-express/data": ["./packages/data/src/index.ts"],
      "@urban-express/logic": ["./packages/logic/src/index.ts"],
      "@urban-express/i18n": ["./packages/i18n/src/index.ts"],
      "@urban-express/notifications": ["./packages/notifications/src/index.ts"],
      "@urban-express/chat": ["./packages/chat/src/index.ts"]
    }
  },
  "include": [
    "apps/*/src/**/*",
    "packages/*/src/**/*",
    "*.config.js"
  ],
  "exclude": ["node_modules", "dist", "build"]
}
```

### Build & Deployment Scripts

```json
// package.json scripts
{
  "scripts": {
    "dev": "concurrently -n customer,driver,admin -c blue,green,yellow \"npm run dev:customer\" \"npm run dev:driver\" \"npm run dev:admin\"",
    "dev:customer": "cd apps/customer && vite dev --port 3000",
    "dev:driver": "cd apps/driver && vite dev --port 3001",
    "dev:admin": "cd apps/admin && vite dev --port 3002",
    
    "build": "npm run build:packages && npm run build:apps",
    "build:packages": "npm run build --workspace=packages/*",
    "build:apps": "npm run build --workspace=apps/*",
    
    "test": "vitest",
    "test:e2e": "playwright test",
    "test:coverage": "vitest --coverage",
    
    "lint": "eslint . --ext .ts,.svelte --fix",
    "format": "prettier --write .",
    "type-check": "tsc --noEmit",
    
    "db:start": "supabase start",
    "db:stop": "supabase stop", 
    "db:reset": "supabase db reset",
    "db:migrate": "supabase db push",
    "db:generate-types": "supabase gen types typescript --local > packages/data/src/types/database.ts",
    
    "prepare": "husky install",
    "preview": "npm run preview --workspace=apps/*"
  }
}
```

This technical specification provides the complete foundation for implementing Urban Express. The next steps involve creating the detailed UI components, implementing the business logic, and setting up the deployment pipeline.