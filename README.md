# Urban Express Delivery System

A comprehensive bilingual delivery management system with Customer, Driver, and Admin PWAs.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Set up environment
cp .env.example .env.local
# Edit .env.local with your Supabase credentials

# Run database migrations
npm run db:migrate

# Start development server (all apps on different ports)
npm run dev

# Individual app development
npm run dev:customer    # Port 3000
npm run dev:driver      # Port 3001  
npm run dev:admin       # Port 3002
```

## 🏗️ Architecture

### Apps
- **Customer PWA** (`/apps/customer`) - Shopping, orders, tracking
- **Driver PWA** (`/apps/driver`) - Route management, payments, cash handling
- **Admin Console** (`/apps/admin`) - Orders, routing, user management, analytics

### Shared Libraries
- **UI Components** (`/packages/ui`) - Design system components
- **Data Layer** (`/packages/data`) - Supabase client, types, schemas
- **Business Logic** (`/packages/logic`) - Shared business rules
- **i18n** (`/packages/i18n`) - Arabic/English translations
- **Notifications** (`/packages/notifications`) - Push notifications, in-app alerts
- **Chat** (`/packages/chat`) - AI-powered chat system

## 🛠️ Tech Stack

- **Frontend**: Svelte + TypeScript + Vite
- **Backend**: Supabase (Database, Auth, Realtime, Storage)
- **UI**: Custom design system with Arabic RTL support
- **PWA**: Service workers, offline support, installable
- **AI**: OpenAI integration for chat assistance
- **Maps**: Google Maps integration
- **Payments**: Cash handling + Card-on-Delivery (POS photo capture)

## 🌍 Internationalization

- **Arabic (RTL)**: Primary language with right-to-left layout
- **English (LTR)**: Secondary language
- **Currency**: Saudi Riyal (SAR)
- **Timezone**: Asia/Riyadh

## 🔐 Security Model

- **Authentication**: WhatsApp number + password (no OTP)
- **Password Reset**: WhatsApp redirect only
- **User Security**: No device ID storage, optional local 4-digit QAC
- **Authorization**: Role-based with Row Level Security (RLS)

## 📱 Key Features

### Customer App
- Location-based shopping with default address
- COD-only checkout with delivery charge acceptance
- Real-time order tracking with live ETA
- In-app chat with AI support
- QAC (Quick Access Code) for convenience

### Driver App
- Shift management with cash reconciliation
- Route optimization and navigation
- Payment capture (cash denominations + card slip photos)
- Offline queue for payments and messages
- Real-time communication

### Admin Console
- Comprehensive dashboard with KPIs
- Kanban-style order management
- Route planning and driver assignment
- User registration approvals
- Delivery charge configuration
- AI chat training and monitoring
- Detailed reporting and analytics

## 📊 Business Rules

### Payments
- **Cash**: Denominations tracking, change calculation, drawer reconciliation
- **Card**: POS slip photo + last 4 digits (mandatory)
- No integrated payment processing

### Delivery Charges
- Configurable by dispatcher within allowed ranges
- Customer must accept updated total before order proceeds
- Full audit trail of all changes

### User Management
- Admin-only WhatsApp number changes
- Password resets via WhatsApp verification
- Role-based access control (Customer, Driver, Dispatcher, Admin)

## 📁 Project Structure

```
urban-express/
├── apps/
│   ├── customer/          # Customer PWA
│   ├── driver/            # Driver PWA
│   └── admin/             # Admin Console PWA
├── packages/
│   ├── ui/                # Design system
│   ├── data/              # Supabase integration
│   ├── logic/             # Business logic
│   ├── i18n/              # Translations
│   ├── notifications/     # Notification system
│   └── chat/              # AI chat system
├── docs/                  # Documentation
├── database/              # Supabase migrations & schemas
└── scripts/               # Build & deployment scripts
```

## 🚧 Development Status

This is a development kit with complete specifications. Implementation phases:

1. **Phase 1**: MVP with core auth, ordering, and payment flows
2. **Phase 2**: Advanced operations and AI integration  
3. **Phase 3**: Analytics, optimization, and scaling features

## 📋 Getting Started Checklist

- [ ] Review complete specifications in `/docs/`
- [ ] Set up Supabase project
- [ ] Configure environment variables
- [ ] Run database migrations
- [ ] Start development servers
- [ ] Review design system in Storybook
- [ ] Begin with Phase 1 implementation

## 📚 Documentation

- [Complete Master Plan](./docs/master-plan.md)
- [Technical Specifications](./docs/technical-specs.md)
- [API Documentation](./docs/api.md)
- [Design System](./docs/design-system.md)
- [Database Schema](./docs/database-schema.md)
- [Deployment Guide](./docs/deployment.md)

## 🤝 Contributing

Please refer to the development guidelines and coding standards in the documentation before contributing.

---

**Urban Express** - Delivering excellence, one order at a time 🚚