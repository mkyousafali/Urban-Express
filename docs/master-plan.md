# Urban Express Master Plan

## Executive Summary

Urban Express is a comprehensive delivery management system designed for the Saudi Arabian market, featuring bilingual support (Arabic RTL/English LTR), cash-heavy operations, and WhatsApp-based authentication. The system consists of three Progressive Web Apps (PWAs) serving customers, drivers, and administrators.

## Ground Rules (Non-Negotiable)

### Payment Model
- **Cash or Card-on-Delivery ONLY**
- Card payments: POS slip photo + last 4 digits (no integrated processing)
- Cash payments: Full denomination tracking + change calculation + drawer reconciliation

### Identity & Authentication
- **WhatsApp number (05xxxxxxxx) + password** (no OTP, no email)
- Password reset: WhatsApp redirect → Admin manual reset → WhatsApp reply
- Only Admin can change WhatsApp numbers
- User-based security (no device ID storage)
- Optional 4-digit QAC (Quick Access Code) per device (local storage only)

### Operational Requirements
- Default delivery location required at first login
- Per-order location snapshot is immutable after checkout
- Delivery charges set by Dispatcher with customer acceptance required
- All communication in-app except WhatsApp password resets
- Full bilingual support: Arabic RTL / English LTR
- Currency: Saudi Riyal (SAR)
- Timezone: Asia/Riyadh
- Mobile-first PWA design for all applications

## Architecture Overview

### Application Structure
```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   Customer PWA  │  │   Driver PWA    │  │ Admin Console   │
│                 │  │                 │  │      PWA        │
│ • Shopping      │  │ • Route Mgmt    │  │ • Dashboard     │
│ • Order Track   │  │ • Payments      │  │ • Order Board   │
│ • Chat/Support  │  │ • Cash Handling │  │ • User Mgmt     │
│ • Notifications │  │ • Offline Queue │  │ • Analytics     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
         │                     │                     │
         └─────────────────────┼─────────────────────┘
                               │
                    ┌─────────────────┐
                    │    Supabase     │
                    │                 │
                    │ • Database      │
                    │ • Auth          │
                    │ • Realtime      │
                    │ • Storage       │
                    │ • Edge Functions│
                    └─────────────────┘
```

### Shared Libraries
- **UI Components**: Design system with brand colors, typography, bilingual support
- **Data Layer**: Supabase client, TypeScript types, business logic
- **i18n**: Translation management with RTL/LTR support
- **Notifications**: Push notifications + in-app notification center
- **Chat System**: AI-powered chat with human escalation
- **PWA Utilities**: Service workers, offline capabilities, installable features

## User Roles & Permissions

### Customer
- **Account**: Sign up (request-based), login, profile management
- **Shopping**: Browse catalog, add to cart, checkout with COD
- **Orders**: Place orders, track delivery, view receipts, reorder
- **Communication**: Receive notifications, chat support
- **Security**: Optional QAC setup, session management

### Driver  
- **Shift Management**: Open/close shifts with cash reconciliation
- **Route Execution**: View assigned stops, navigate, update status
- **Payment Collection**: Handle cash (denominations) and card (slip photos)
- **Communication**: Receive alerts, order-specific chat
- **Offline Support**: Queue payments and messages when offline

### Dispatcher
- **Order Management**: View orders board, assign to routes, add delivery charges
- **Route Planning**: Cluster orders, optimize routes, assign drivers
- **Cash Management**: Set opening cash kits, approve drawer closings
- **Delivery Charges**: Configure and apply charges within allowed ranges
- **Communication**: Monitor chat queues, join conversations

### Admin
- **User Management**: Approve registrations, reset passwords, change WhatsApp numbers
- **System Configuration**: Manage branches, service areas, delivery charges
- **Content Management**: Update T&C, manage AI knowledge base
- **Analytics**: View reports, KPIs, performance metrics
- **Chat Operations**: AI training, escalation rules, template management

## Critical User Journeys

### 1. Customer Registration & First Order
1. **Sign Up Request**
   - Choose default location (map pin or link)
   - Enter: Full name, WhatsApp (05xxxxxxxx), Password
   - Accept Terms & Conditions → Submit Request (Status: Pending)

2. **Admin Approval**
   - Admin reviews and approves registration
   - Customer receives approval notification

3. **First Login & Setup**
   - Login with WhatsApp + Password
   - Prompt: "Enable Quick Access Code?" (4 digits, local only)
   - Browse catalog and place first order (COD only)

4. **Order Processing**
   - Dispatcher may add delivery charge
   - Customer notification: "Total SAR X including delivery charge SAR Y. Accept to proceed?"
   - Customer accepts → Order continues to routing
   - Customer declines → Order auto-cancels

5. **Delivery & Payment**
   - Driver arrives, collects payment (cash or card)
   - Order marked delivered, receipt available
   - Support available via in-app chat

### 2. Driver Shift Operations
1. **Shift Opening**
   - Confirm opening cash denominations
   - System records opening balance

2. **Route Execution**
   - View route with optimized stop sequence
   - Navigate to each stop (Google Maps integration)
   - Update delivery status

3. **Payment Collection Per Stop**
   - **Card Payment**: Enter amount + last 4 digits + mandatory slip photo
   - **Cash Payment**: Enter received denominations → System calculates change → Enter change given denominations
   - System validates: Received - Change = Order total

4. **Shift Closing**
   - Enter closing denominations
   - System reconciles: Opening + Total Received - Total Change - Petty Cash = Expected Closing
   - Flag variances → Submit for approval
   - Admin/Dispatcher approves or investigates

### 3. Dispatcher Delivery Charge Management
1. **Order Assessment**
   - Order reaches "Packed" or "Ready to Route" status
   - Dispatcher reviews order details and delivery location

2. **Charge Application**
   - Add delivery charge (default or manual within allowed range)
   - System recalculates: Total = Items + Delivery Charge
   - Preview customer notification

3. **Customer Notification & Response**
   - Customer receives notification + modal prompt
   - "Total SAR {{total}} including delivery charge SAR {{fee}}. Accept to proceed?"
   - **Accept**: Order continues to route assignment
   - **Decline**: Order auto-cancels, dispatcher notified

4. **Audit Trail**
   - Record: Who added charge, old/new amounts, timestamp, customer response
   - Available in delivery charge audit reports

### 4. Password Reset via WhatsApp
1. **Customer Initiates Reset**
   - Login screen → "Forgot Password" 
   - Opens WhatsApp with pre-filled message to official number

2. **Admin Verification & Reset**
   - Admin receives WhatsApp message
   - Verifies customer identity
   - Sets temporary password in system
   - Replies to customer via WhatsApp with temp password

3. **Password Update**
   - Customer logs in with temporary password
   - System forces password change on first login
   - All existing QACs invalidated until new password set

## Technology Stack

### Frontend Applications
- **Framework**: Svelte + TypeScript + Vite
- **PWA**: Service Workers, Web App Manifest, Offline Support
- **UI**: Custom design system with Arabic RTL support
- **State Management**: Svelte stores + Supabase realtime
- **Maps**: Google Maps API integration
- **Camera**: Web Camera API for POS slip photos

### Backend Services
- **Database**: Supabase PostgreSQL with Row Level Security
- **Authentication**: Supabase Auth (custom implementation for WhatsApp)
- **Realtime**: Supabase Realtime subscriptions
- **Storage**: Supabase Storage for POS slips and attachments
- **Edge Functions**: Supabase Edge Functions for business logic

### External Integrations
- **AI Chat**: OpenAI API for customer support
- **WhatsApp**: WhatsApp Business API for password resets
- **Maps**: Google Maps API for navigation and geocoding
- **Push Notifications**: Web Push API + Supabase

### Development Tools
- **Monorepo**: Lerna or Nx for package management
- **Code Quality**: ESLint + Prettier + TypeScript strict mode
- **Testing**: Vitest + Playwright for E2E
- **CI/CD**: GitHub Actions
- **Documentation**: TypeDoc + Storybook for components

## Data Architecture

### Core Entities

#### Identity & Legal
- **users**: Core user information (id, role, name, whatsapp, password_hash, status, branch)
- **customers**: Customer-specific data (default_location, terms_acceptance)
- **terms_documents**: Version-controlled T&C in Arabic/English
- **terms_acceptance**: User acceptance tracking

#### Commerce & Operations
- **orders**: Order header (customer, status, totals, location_snapshot, timing)
- **order_items**: Line items with substitution tracking
- **routes**: Daily route planning (date, branch, dispatcher, optimization)
- **route_stops**: Individual stops with sequence and timing
- **deliveries**: Delivery execution (driver, status, timestamps, exceptions)

#### Payments & Cash Management
- **cash_denominations**: SAR currency denominations (notes and coins)
- **cash_drawers**: Driver cash drawer sessions
- **drawer_opening_denoms**: Opening cash breakdown
- **drawer_closing_denoms**: Closing cash breakdown  
- **payment_receipts**: Payment records (method, amount, metadata)
- **payment_cash_breakdown**: Cash denomination details
- **payment_card_slips**: Card payment slip photos and metadata

#### Communications
- **notifications**: User notifications with i18n content
- **notification_templates**: Reusable notification templates
- **conversations**: Chat threads (order, support, drawer, registration)
- **messages**: Individual chat messages with AI/human attribution
- **ai_knowledge_docs**: AI knowledge base (bilingual, branch-scoped)
- **ai_policies**: AI behavior configuration

#### Configuration
- **branches**: Store locations and operational areas
- **service_areas**: Delivery zone polygons
- **audit_logs**: Complete audit trail for sensitive operations

### Security Model (Row Level Security)

#### Customer Policies
- Read/write own profile, addresses, orders, conversations
- Read current terms and conditions
- Cannot modify WhatsApp number (admin-only)

#### Driver Policies  
- Read assigned routes, orders, and own cash drawers
- Write payment records and drawer denominations
- Read driver-specific notifications
- Participate in assigned order conversations

#### Dispatcher Policies
- Branch-scoped access to orders, routes, driver assignments
- Add delivery charges and approve route operations
- Read driver drawer status, approve closings
- Participate in operational conversations

#### Admin Policies
- Full system access for user management
- Password resets and WhatsApp number changes
- System configuration and content management
- AI training and template management
- Complete audit trail access

## Brand & Design System

### Color Palette
- **Primary (Urban Green)**: #10B981
- **Ink (Text/Dark)**: #0F172A  
- **Surface (Light)**: #F8FAFC
- **Info**: #3B82F6 | **Warning**: #F59E0B | **Danger**: #EF4444 | **Success**: #16A34A

### Typography
- **English**: Inter or system font stack
- **Arabic**: Tajawal or system Arabic font
- **Scale**: Display 32px, H1 24px, H2 20px, Body 16px/14px
- **Line Height**: 1.4-1.6 for optimal readability

### Component Standards
- **Buttons**: Primary (filled), Secondary (outline), Tertiary (ghost)
- **Inputs**: 48px minimum height, appropriate keyboards for input types
- **Cards**: rounded-xl corners, soft shadows, clear content hierarchy
- **Navigation**: Context-appropriate (bottom nav for mobile, tabs for drivers, responsive sidebar for admin)

### Accessibility Requirements
- **WCAG AA** contrast compliance
- **Touch Targets**: 44-48px minimum
- **Focus States**: Clear keyboard navigation
- **Screen Readers**: Proper ARIA labels in both languages
- **RTL Support**: Complete right-to-left layout for Arabic

## PWA Implementation

### Core PWA Features
- **Installability**: Web App Manifest with branded icons
- **Offline Support**: Service Worker with intelligent caching
- **Push Notifications**: Web Push API integration
- **Background Sync**: Queue critical operations when offline

### App-Specific PWA Behavior

#### Customer App
- **Offline**: Browse cached products, view order history
- **Notifications**: Order status updates, delivery charges, chat messages
- **Installation**: Home screen shortcut with brand icon

#### Driver App  
- **Offline Queue**: Store payments, slip photos, status updates
- **Background Sync**: Sync queued data when connection restored
- **Critical Notifications**: New route assignments, urgent alerts
- **Location Services**: Background location for route optimization

#### Admin Console
- **Real-time Dashboard**: Live KPI updates via WebSocket
- **Offline Reports**: Cache recent data for offline viewing
- **Notifications**: System alerts, registration requests, chat escalations

## Notification & Communication System

### Notification Center
- **Priority Levels**: Critical (sticky), High, Normal, Low
- **Deduplication**: Prevent spam with time windows
- **Quiet Hours**: User-configurable do-not-disturb
- **Deep Linking**: Direct navigation to relevant app sections
- **Bilingual Templates**: Arabic/English with variable substitution

### In-App Chat System
- **AI Assistant**: OpenAI-powered FAQ responses and order assistance
- **Human Escalation**: Automatic escalation for sensitive topics
- **Thread Types**: Order-specific, General Support, Drawer Issues, Registration
- **Real-time**: WebSocket-based instant messaging
- **Attachments**: Photo support for POS slips and issue documentation

### AI Training & Management
- **Knowledge Base**: Bilingual documentation with branch-specific content
- **Escalation Rules**: Automatic handoff triggers for complex issues  
- **Quality Monitoring**: Response quality tracking and human review
- **Template Management**: Editable response templates with variable support

## Quality Assurance Framework

### Testing Strategy
- **Unit Tests**: Business logic and utility functions
- **Component Tests**: UI component behavior and accessibility
- **Integration Tests**: API interactions and data flow
- **E2E Tests**: Complete user journeys across all apps
- **Performance Tests**: PWA metrics, load times, offline behavior
- **Accessibility Tests**: WCAG compliance, screen reader compatibility

### Key Test Scenarios
- **Registration Flow**: Out-of-area prevention, approval workflow
- **Delivery Charges**: Addition, customer notification, acceptance/decline
- **Payment Validation**: Card slip requirements, cash denomination math
- **Drawer Reconciliation**: Opening/closing balance validation, variance handling
- **Offline Behavior**: Queue management, sync on reconnect
- **Bilingual Support**: RTL layouts, number formatting, currency display
- **PWA Features**: Installation, notifications, offline functionality

### Performance Targets
- **Initial Load**: < 3 seconds on 3G connection
- **Time to Interactive**: < 5 seconds  
- **Notification Delivery**: < 3 seconds 99% of the time
- **Offline Sync**: Complete within 30 seconds of reconnection
- **Battery Usage**: Minimal background battery drain

## Security & Compliance

### Data Protection
- **Personal Data**: Minimal collection, purpose-limited usage
- **Payment Data**: No card numbers stored, POS slips encrypted
- **Location Data**: Per-order snapshots only, no continuous tracking
- **Communication**: End-to-end encryption for sensitive conversations

### Access Control
- **Authentication**: Strong password requirements, session management
- **Authorization**: Role-based access with principle of least privilege
- **Audit Trail**: Complete logging of sensitive operations
- **Data Retention**: Configurable retention periods for different data types

### Operational Security
- **Environment Isolation**: Separate development, staging, production
- **Secret Management**: Secure configuration and API key handling
- **Backup & Recovery**: Automated backups with point-in-time recovery
- **Monitoring**: Real-time security event detection and alerting

## Deployment Architecture

### Environment Strategy
- **Development**: Local development with Supabase local setup
- **Staging**: Full feature testing environment
- **Production**: High-availability production environment

### Hosting & CDN
- **Apps**: Vercel or Netlify with global CDN
- **Database**: Supabase managed PostgreSQL with regional deployment
- **Storage**: Supabase Storage with CDN for static assets
- **Monitoring**: Comprehensive logging and performance monitoring

### CI/CD Pipeline
- **Code Quality**: Automated linting, type checking, security scanning
- **Testing**: Automated test suite execution on all pull requests
- **Deployment**: Automated deployment with approval gates
- **Rollback**: Quick rollback capability for production issues

## Success Metrics & KPIs

### Business Metrics
- **Registration Conversion**: Sign-up request to approval rate
- **Order Completion**: Successful delivery rate
- **Payment Efficiency**: Cash reconciliation accuracy, card slip compliance
- **Customer Satisfaction**: In-app rating, support chat resolution
- **Operational Efficiency**: Orders per driver hour, route optimization

### Technical Metrics  
- **App Performance**: Load times, error rates, crash frequency
- **PWA Adoption**: Installation rates, offline usage patterns
- **Notification Engagement**: Open rates, click-through rates
- **Chat Effectiveness**: AI containment rate, escalation frequency
- **System Reliability**: Uptime, response times, data consistency

### Compliance Metrics
- **Security**: Successful logins, failed attempts, suspicious activity
- **Accessibility**: WCAG compliance score, user feedback
- **Data Quality**: Order accuracy, payment reconciliation variances
- **Audit Compliance**: Complete audit trails, regulatory reporting

This master plan provides the complete foundation for developing Urban Express. The next phase involves detailed technical specifications, database schema design, and implementation roadmaps for each development team.