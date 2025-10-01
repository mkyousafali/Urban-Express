# Project Structure

This is a comprehensive development kit for Urban Express delivery system. Below is the complete project structure that will be created.

```
urban-express/
├── apps/
│   ├── customer/                    # Customer PWA
│   │   ├── src/
│   │   │   ├── routes/
│   │   │   │   ├── +layout.svelte
│   │   │   │   ├── +page.svelte
│   │   │   │   ├── auth/
│   │   │   │   │   ├── login/
│   │   │   │   │   ├── signup/
│   │   │   │   │   └── terms/
│   │   │   │   ├── products/
│   │   │   │   ├── cart/
│   │   │   │   ├── orders/
│   │   │   │   ├── profile/
│   │   │   │   ├── notifications/
│   │   │   │   └── chat/
│   │   │   ├── lib/
│   │   │   ├── app.html
│   │   │   └── service-worker.js
│   │   ├── static/
│   │   ├── package.json
│   │   └── vite.config.js
│   │
│   ├── driver/                      # Driver PWA
│   │   ├── src/
│   │   │   ├── routes/
│   │   │   │   ├── +layout.svelte
│   │   │   │   ├── +page.svelte
│   │   │   │   ├── auth/
│   │   │   │   ├── shift/
│   │   │   │   ├── route/
│   │   │   │   ├── payments/
│   │   │   │   ├── drawer/
│   │   │   │   ├── notifications/
│   │   │   │   └── chat/
│   │   │   ├── lib/
│   │   │   │   ├── offline/
│   │   │   │   └── camera/
│   │   │   └── service-worker.js
│   │   ├── static/
│   │   ├── package.json
│   │   └── vite.config.js
│   │
│   └── admin/                       # Admin Console PWA
│       ├── src/
│       │   ├── routes/
│       │   │   ├── +layout.svelte
│       │   │   ├── +page.svelte
│       │   │   ├── auth/
│       │   │   ├── orders/
│       │   │   ├── routing/
│       │   │   ├── users/
│       │   │   ├── drivers/
│       │   │   ├── charges/
│       │   │   ├── notifications/
│       │   │   ├── chat/
│       │   │   ├── ai/
│       │   │   ├── reports/
│       │   │   └── settings/
│       │   ├── lib/
│       │   │   └── components/
│       │   └── service-worker.js
│       ├── static/
│       ├── package.json
│       └── vite.config.js
│
├── packages/
│   ├── ui/                          # Design System
│   │   ├── src/
│   │   │   ├── components/
│   │   │   │   ├── Button.svelte
│   │   │   │   ├── Input.svelte
│   │   │   │   ├── Card.svelte
│   │   │   │   ├── Modal.svelte
│   │   │   │   ├── PaymentKeypad.svelte
│   │   │   │   ├── QACKeypad.svelte
│   │   │   │   └── index.ts
│   │   │   ├── styles/
│   │   │   │   ├── tokens.css
│   │   │   │   ├── components.css
│   │   │   │   └── utilities.css
│   │   │   └── utils/
│   │   ├── package.json
│   │   └── vite.config.js
│   │
│   ├── data/                        # Supabase Integration
│   │   ├── src/
│   │   │   ├── client.ts
│   │   │   ├── types/
│   │   │   │   ├── database.ts
│   │   │   │   ├── entities.ts
│   │   │   │   └── supabase.ts
│   │   │   ├── api/
│   │   │   │   ├── auth.ts
│   │   │   │   ├── orders.ts
│   │   │   │   ├── payments.ts
│   │   │   │   ├── notifications.ts
│   │   │   │   └── chat.ts
│   │   │   └── realtime/
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── logic/                       # Business Logic
│   │   ├── src/
│   │   │   ├── validation/
│   │   │   │   └── schemas.ts
│   │   │   ├── rules/
│   │   │   │   ├── orders.ts
│   │   │   │   ├── payments.ts
│   │   │   │   └── cash.ts
│   │   │   ├── machines/
│   │   │   │   ├── order.ts
│   │   │   │   ├── payment.ts
│   │   │   │   └── drawer.ts
│   │   │   └── utils/
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── i18n/                        # Internationalization
│   │   ├── src/
│   │   │   ├── locales/
│   │   │   │   ├── ar.json
│   │   │   │   └── en.json
│   │   │   ├── formatters.ts
│   │   │   ├── rtl.ts
│   │   │   └── index.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── notifications/               # Notification System
│   │   ├── src/
│   │   │   ├── push.ts
│   │   │   ├── templates.ts
│   │   │   └── center.ts
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   └── chat/                        # AI Chat System
│       ├── src/
│       │   ├── ai.ts
│       │   ├── escalation.ts
│       │   └── threads.ts
│       ├── package.json
│       └── tsconfig.json
│
├── database/
│   ├── migrations/                  # Supabase Migrations
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_add_rls_policies.sql
│   │   ├── 003_add_functions.sql
│   │   └── 004_add_indexes.sql
│   ├── seed/                        # Initial Data
│   │   ├── denominations.sql
│   │   ├── templates.sql
│   │   └── branches.sql
│   └── functions/                   # Edge Functions
│       ├── password-reset/
│       ├── delivery-charge/
│       └── ai-chat/
│
├── docs/                            # Documentation
│   ├── master-plan.md
│   ├── technical-specs.md
│   ├── database-schema.md
│   ├── design-system.md
│   ├── api.md
│   ├── deployment.md
│   ├── user-journeys.md
│   ├── testing-strategy.md
│   └── implementation-guide.md
│
├── scripts/                         # Build & Deploy Scripts
│   ├── build.sh
│   ├── deploy.sh
│   ├── setup-dev.sh
│   └── generate-types.sh
│
├── .github/                         # GitHub Configuration
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── deploy.yml
│   │   └── test.yml
│   └── copilot-instructions.md
│
├── package.json                     # Root Package Config
├── tsconfig.json                    # TypeScript Config
├── .env.example                     # Environment Template
├── .gitignore                       # Git Ignore Rules
├── README.md                        # Main Documentation
├── CHANGELOG.md                     # Version History
└── LICENSE                          # License Information
```

## Key Files & Configurations

### Root Package.json
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
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@typescript-eslint/eslint-plugin": "^6.0.0",
    "@typescript-eslint/parser": "^6.0.0",
    "concurrently": "^8.2.0",
    "eslint": "^8.45.0",
    "eslint-plugin-svelte": "^2.30.0",
    "prettier": "^3.0.0",
    "prettier-plugin-svelte": "^3.0.0",
    "typescript": "^5.0.0",
    "husky": "^8.0.0",
    "lint-staged": "^13.0.0"
  }
}
```

### TypeScript Configuration
```json
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

### Environment Template
```bash
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

# Development Ports
VITE_CUSTOMER_PORT=3000
VITE_DRIVER_PORT=3001
VITE_ADMIN_PORT=3002

# Push Notifications
VITE_VAPID_PUBLIC_KEY=your-vapid-public-key
VAPID_PRIVATE_KEY=your-vapid-private-key
```

## Implementation Phases

### Phase 1: Foundation (Weeks 1-4)
- Set up monorepo structure
- Implement shared packages (UI, data, i18n)
- Create database schema and migrations
- Build authentication system
- Implement basic customer app

### Phase 2: Core Features (Weeks 5-8)
- Complete customer ordering flow
- Build driver payment system
- Implement admin order management
- Add real-time notifications
- Create cash drawer reconciliation

### Phase 3: Advanced Features (Weeks 9-12)
- AI chat integration
- Route optimization
- Advanced reporting
- Performance optimization
- Full testing suite

### Phase 4: Deployment & Polish (Weeks 13-16)
- Production deployment
- Performance monitoring
- User training
- Bug fixes and optimizations
- Documentation completion

## Development Guidelines

### Code Standards
- TypeScript strict mode enabled
- ESLint and Prettier for code formatting
- Conventional commits for version control
- Comprehensive unit and integration tests
- Accessibility compliance (WCAG AA)

### Component Architecture
- Atomic design principles
- Reusable UI components in shared package
- Business logic separated from UI
- Type-safe API integration
- Real-time state management

### Security Considerations
- Row Level Security (RLS) in database
- JWT token authentication
- Input validation and sanitization
- HTTPS-only in production
- Secure file uploads

### Performance Optimization
- Code splitting and lazy loading
- Image optimization and CDN
- Service worker caching
- Bundle size monitoring
- Core Web Vitals optimization

This project structure provides a solid foundation for building the Urban Express delivery system with scalability, maintainability, and developer experience in mind.