# Demo Videos for Urban Express

## Current Demo Videos

### 1. Big Buck Bunny (Demo Video 1)
- **Source**: Google Cloud Storage Sample Videos
- **Duration**: ~15 seconds (trimmed for demo)
- **Resolution**: 1080 × 1920 (9:16 aspect ratio optimized)
- **Format**: MP4
- **Content**: High-quality animation suitable for testing
- **Arabic Title**: عرض تجريبي - منتجات Urban Express
- **English Title**: Demo - Urban Express Products

### 2. Elephant's Dream (Demo Video 2)
- **Source**: Google Cloud Storage Sample Videos
- **Duration**: ~12 seconds (trimmed for demo)
- **Resolution**: 1080 × 1920 (9:16 aspect ratio optimized)
- **Format**: MP4
- **Content**: Creative animation content
- **Arabic Title**: منتجات الألبان الطازجة
- **English Title**: Fresh Dairy Products

### 3. For Bigger Blazes (Demo Video 3)
- **Source**: Google Cloud Storage Sample Videos
- **Duration**: ~18 seconds (trimmed for demo)
- **Resolution**: 1080 × 1920 (9:16 aspect ratio optimized)
- **Format**: MP4
- **Content**: Dynamic visual content
- **Arabic Title**: خصومات كبيرة على جميع المنتجات
- **English Title**: Big Discounts on All Products

## Features Implemented

### Video Rotation System
- Automatic rotation based on video duration + 2 second buffer
- Manual navigation with next button
- Seamless looping through all demo videos

### Error Handling
- Fallback content when videos fail to load
- Graceful degradation with styled placeholder
- Maintains LED screen aesthetic even with errors

### User Controls
- Next button for manual video switching
- Hide/Show functionality with localStorage persistence
- Click-to-action navigation to products page

### Technical Specifications
- **Aspect Ratio**: 9:16 (vertical mobile-first)
- **Auto-play**: Enabled with mute for browser compatibility
- **Loop**: Videos loop continuously
- **Responsive**: Scales appropriately across devices
- **Performance**: Optimized loading with error recovery

## Admin Integration Notes

When implementing the admin panel, these demo videos can be replaced with:
1. Upload interface for admin to add custom videos
2. Video management system with CRUD operations
3. Video processing to ensure 9:16 aspect ratio
4. File size validation (recommended under 50MB)
5. Duration limits (20 seconds maximum as specified)

## Browser Compatibility
- Modern browsers with HTML5 video support
- Progressive loading for slower connections
- Fallback content for unsupported scenarios
- Touch-friendly controls for mobile devices