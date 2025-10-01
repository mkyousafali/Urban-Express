# Urban Express Development Instructions

This is a comprehensive delivery system with Customer, Driver, and Admin PWAs built with Svelte, TypeScript, and Supabase.

## Project Overview
- **Architecture**: Mono-repo with 3 PWA apps (customer, driver, admin/dispatcher console)
- **Tech Stack**: Svelte + TypeScript + Supabase
- **Languages**: Bilingual (Arabic RTL / English LTR)
- **Currency**: SAR (Saudi Riyal)
- **Timezone**: Asia/Riyadh
- **Security**: User-based (no device ID), WhatsApp authentication
- **Payments**: Cash or Card-on-Delivery only

## Key Features
- WhatsApp-based authentication with password
- Real-time order tracking and notifications
- In-app chat with AI assistance
- Cash drawer reconciliation for drivers
- Delivery charge management with customer acceptance
- PWA capabilities with offline support
- Comprehensive admin panel

## Development Guidelines
- Mobile-first responsive design
- WCAG AA accessibility compliance
- Real-time updates via Supabase
- Strict TypeScript with shared types
- Component-based UI system
- Comprehensive audit logging

## Getting Started
1. Review the complete project structure in `/docs/`
2. Set up Supabase instance with provided schema
3. Configure environment variables
4. Install dependencies: `npm install`
5. Start development: `npm run dev`

For detailed implementation guides, see the documentation in `/docs/`.