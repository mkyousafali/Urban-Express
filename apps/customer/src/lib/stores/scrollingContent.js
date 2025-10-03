import { writable } from 'svelte/store';

// Default scrolling content - 4 slots with English and Arabic versions
const defaultScrollingContent = [
  {
    id: 1,
    isActive: true,
    contentAr: 'جميع الأسعار تتضمن ضريبة القيمة المضافة',
    contentEn: 'All prices inclusive VAT'
  },
  {
    id: 2,
    isActive: true,
    contentAr: 'توصيل مجاني للطلبات فوق 100 ريال',
    contentEn: 'Free delivery for orders above 100 SAR'
  },
  {
    id: 3,
    isActive: true,
    contentAr: 'خدمة عملاء 24/7',
    contentEn: '24/7 customer service'
  },
  {
    id: 4,
    isActive: false,
    contentAr: 'ضمان الجودة والطازجة',
    contentEn: 'Quality and freshness guarantee'
  }
];

// Load from localStorage if available, otherwise use defaults
function loadScrollingContent() {
  if (typeof window !== 'undefined') {
    const saved = localStorage.getItem('scrollingContent');
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (e) {
        console.error('Failed to parse scrolling content from localStorage:', e);
      }
    }
  }
  return defaultScrollingContent;
}

// Create the store
export const scrollingContent = writable(loadScrollingContent());

// Subscribe to changes and save to localStorage
if (typeof window !== 'undefined') {
  scrollingContent.subscribe(content => {
    localStorage.setItem('scrollingContent', JSON.stringify(content));
  });
}

// Actions for managing scrolling content
export const scrollingContentActions = {
  // Update a specific content slot
  updateContent: (id, updates) => {
    scrollingContent.update(content => {
      return content.map(item => 
        item.id === id ? { ...item, ...updates } : item
      );
    });
  },

  // Toggle active status of a content slot
  toggleActive: (id) => {
    scrollingContent.update(content => {
      return content.map(item => 
        item.id === id ? { ...item, isActive: !item.isActive } : item
      );
    });
  },

  // Get active content for display
  getActiveContent: (currentContent, currentLanguage) => {
    return currentContent
      .filter(item => item.isActive)
      .map(item => currentLanguage === 'ar' ? item.contentAr : item.contentEn)
      .filter(text => text && text.trim() !== '');
  },

  // Reset to defaults
  resetToDefaults: () => {
    scrollingContent.set(defaultScrollingContent);
  }
};