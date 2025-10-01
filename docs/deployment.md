# Urban Express Deployment Guide

This guide covers deploying Urban Express to production with Supabase, Vercel, and other cloud services.

## Prerequisites

- [Supabase](https://supabase.com) project
- [Vercel](https://vercel.com) account
- [GitHub](https://github.com) repository
- Domain name (optional)
- SSL certificate (handled by Vercel)

## Environment Setup

### 1. Supabase Configuration

#### Create New Project
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Click "New Project"
3. Choose organization and set project details:
   - **Name**: Urban Express
   - **Database Password**: Generate strong password
   - **Region**: Choose closest to Saudi Arabia (e.g., ap-southeast-1)

#### Configure Database
1. Go to SQL Editor in Supabase dashboard
2. Run the complete schema from `/database/complete-schema.sql`
3. Verify all tables and functions are created

#### Set Environment Variables
1. Go to Project Settings → API
2. Copy the following values:
   - Project URL
   - Anon public key
   - Service role key (keep secret)

#### Configure Authentication
1. Go to Authentication → Settings
2. Disable email confirmation (we use WhatsApp)
3. Set custom JWT expiry (recommended: 1 hour)
4. Configure redirect URLs for production domains

#### Setup Storage
1. Go to Storage
2. Create bucket: `urban-express-uploads`
3. Configure policies for POS slip uploads:

```sql
-- Allow drivers to upload slip photos
CREATE POLICY "Drivers can upload slip photos" ON storage.objects
FOR INSERT WITH CHECK (
  auth.role() = 'authenticated' AND
  bucket_id = 'urban-express-uploads' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow viewing uploaded slips
CREATE POLICY "Allow viewing slip photos" ON storage.objects
FOR SELECT USING (
  bucket_id = 'urban-express-uploads' AND
  auth.role() = 'authenticated'
);
```

### 2. External API Setup

#### Google Maps API
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project or select existing
3. Enable the following APIs:
   - Maps JavaScript API
   - Geocoding API
   - Places API
   - Roads API
4. Create API key and restrict to your domains
5. Set up billing (required for production usage)

#### OpenAI API
1. Go to [OpenAI Platform](https://platform.openai.com)
2. Create API key
3. Set usage limits and monitoring
4. Configure organization settings

#### WhatsApp Business API
1. Set up WhatsApp Business Account
2. Get API access through Facebook Developer
3. Configure webhook endpoints
4. Set up templates for password resets

### 3. Vercel Deployment

#### Project Setup
1. Connect GitHub repository to Vercel
2. Configure build settings for monorepo:

```bash
# Root Directory: apps/customer (or apps/driver, apps/admin)
# Build Command: npm run build
# Output Directory: dist
# Install Command: npm install
```

#### Environment Variables
Set the following in Vercel dashboard for each app:

```bash
# Supabase
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# External APIs
VITE_GOOGLE_MAPS_API_KEY=your-maps-key
OPENAI_API_KEY=your-openai-key
WHATSAPP_BUSINESS_API_TOKEN=your-whatsapp-token

# App Configuration
VITE_APP_ENV=production
VITE_API_BASE_URL=https://your-project.supabase.co
VITE_DEFAULT_LOCALE=ar

# Push Notifications
VITE_VAPID_PUBLIC_KEY=your-vapid-public-key
VAPID_PRIVATE_KEY=your-vapid-private-key
```

#### Domain Configuration
1. Add custom domains in Vercel:
   - `customer.urbanexpress.sa` → Customer app
   - `driver.urbanexpress.sa` → Driver app  
   - `admin.urbanexpress.sa` → Admin app
2. Configure DNS records:
   - Add CNAME records pointing to Vercel
3. SSL certificates are automatically provisioned

### 4. Production Optimization

#### Performance Settings
```javascript
// vite.config.js
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['svelte', '@supabase/supabase-js'],
          ui: ['@urban-express/ui'],
          maps: ['google-maps']
        }
      }
    },
    chunkSizeWarningLimit: 1000
  },
  
  // PWA Configuration
  plugins: [
    VitePWA({
      registerType: 'autoUpdate',
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/.*\.supabase\.co\/.*$/,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'supabase-api',
              expiration: {
                maxEntries: 100,
                maxAgeSeconds: 60 * 60 * 24 // 24 hours
              }
            }
          }
        ]
      }
    })
  ]
});
```

#### Security Headers
Configure in `vercel.json`:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Strict-Transport-Security",
          "value": "max-age=31536000; includeSubDomains"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-XSS-Protection",
          "value": "1; mode=block"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        },
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self' 'unsafe-eval' *.google.com *.supabase.co; style-src 'self' 'unsafe-inline' *.google.com; img-src 'self' data: *.supabase.co *.google.com; font-src 'self' data:; connect-src 'self' *.supabase.co *.google.com wss:; worker-src 'self' blob:;"
        }
      ]
    }
  ]
}
```

## Monitoring & Analytics

### 1. Error Tracking
Setup Sentry for error monitoring:

```bash
npm install @sentry/svelte
```

```javascript
// app.js
import * as Sentry from '@sentry/svelte';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.VITE_APP_ENV,
  tracesSampleRate: 0.1
});
```

### 2. Performance Monitoring
```javascript
// Web Vitals tracking
import { getCLS, getFID, getFCP, getLCP, getTTFB } from 'web-vitals';

function sendToAnalytics(metric) {
  // Send to your analytics service
  console.log(metric);
}

getCLS(sendToAnalytics);
getFID(sendToAnalytics);
getFCP(sendToAnalytics);
getLCP(sendToAnalytics);
getTTFB(sendToAnalytics);
```

### 3. Database Monitoring
Monitor Supabase metrics:
- Query performance
- Connection pool usage
- Storage usage
- API request patterns

### 4. Uptime Monitoring
Set up monitoring with services like:
- Pingdom
- UptimeRobot
- StatusPage

## Backup & Recovery

### Database Backup
```bash
# Automated daily backups
supabase db dump --remote > backup-$(date +%Y%m%d).sql

# Point-in-time recovery available in Supabase Pro
```

### Code Backup
- GitHub repository with branch protection
- Vercel automatic deployments from Git
- Local development environment backup

## Security Checklist

### Production Security
- [ ] All API keys are in environment variables
- [ ] Database RLS policies are enabled and tested
- [ ] HTTPS is enforced on all domains
- [ ] Security headers are configured
- [ ] Input validation is implemented
- [ ] SQL injection prevention is in place
- [ ] XSS protection is enabled
- [ ] CSRF protection is implemented
- [ ] Rate limiting is configured
- [ ] Authentication flows are secured

### Compliance
- [ ] Data retention policies are implemented
- [ ] Audit logging is enabled
- [ ] Privacy policy is updated
- [ ] Terms of service are current
- [ ] GDPR compliance (if applicable)
- [ ] Saudi data protection compliance

## Scaling Considerations

### Database Scaling
1. **Read Replicas**: For read-heavy workloads
2. **Connection Pooling**: Optimize database connections
3. **Indexing**: Monitor and optimize query performance
4. **Partitioning**: For large tables (orders, messages)

### Application Scaling
1. **CDN**: Use Vercel's global CDN
2. **Caching**: Implement intelligent caching strategies
3. **Code Splitting**: Optimize bundle sizes
4. **Lazy Loading**: Load components on demand

### Infrastructure Scaling
1. **Multiple Regions**: Deploy in multiple geographic regions
2. **Load Balancing**: Distribute traffic efficiently
3. **Auto Scaling**: Handle traffic spikes automatically

## Deployment Checklist

### Pre-deployment
- [ ] All tests pass
- [ ] Code review completed
- [ ] Environment variables configured
- [ ] Database migrations tested
- [ ] Performance benchmarks met
- [ ] Security scan completed
- [ ] Accessibility audit passed

### Deployment
- [ ] Deploy to staging environment
- [ ] Run smoke tests
- [ ] Deploy to production
- [ ] Verify all apps are accessible
- [ ] Test critical user flows
- [ ] Monitor error rates
- [ ] Check performance metrics

### Post-deployment
- [ ] Update documentation
- [ ] Notify stakeholders
- [ ] Monitor system health
- [ ] Update status page
- [ ] Schedule post-deployment review

## Rollback Procedure

### Quick Rollback
1. **Vercel**: Use instant rollback to previous deployment
2. **Database**: Point-in-time recovery if needed
3. **DNS**: Update records if domain issues

### Emergency Contacts
- DevOps team
- Database administrator
- External service providers
- Stakeholder notification list

## Maintenance Windows

### Scheduled Maintenance
- **Time**: 2-4 AM Saudi time (low traffic)
- **Frequency**: Monthly for updates
- **Communication**: 48-hour advance notice
- **Duration**: Maximum 2 hours

### Emergency Maintenance
- **Response Time**: Within 30 minutes
- **Escalation**: Automatic after 1 hour
- **Communication**: Real-time updates

This deployment guide ensures Urban Express is deployed securely, efficiently, and with proper monitoring in place for production operations.