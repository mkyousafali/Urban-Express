import { writable } from 'svelte/store';

// Cancellation settings store - admin configurable
export const cancellationSettings = writable({
  allowedTimeSeconds: 60, // Default 60 seconds (admin can change this)
  isEnabled: true, // Admin can enable/disable cancellation feature
  warningMessage: {
    ar: 'يمكن إلغاء الطلب خلال 60 ثانية فقط من وقت تأكيد الطلب',
    en: 'Order cancellation is only allowed within 60 seconds of placing the order'
  }
});

// Admin actions to manage cancellation settings
export const cancellationActions = {
  // Set cancellation time (in seconds)
  setCancellationTime(seconds) {
    cancellationSettings.update(settings => ({
      ...settings,
      allowedTimeSeconds: seconds,
      warningMessage: {
        ar: `يمكن إلغاء الطلب خلال ${seconds} ثانية فقط من وقت تأكيد الطلب`,
        en: `Order cancellation is only allowed within ${seconds} seconds of placing the order`
      }
    }));
    
    // Save to localStorage for persistence
    localStorage.setItem('cancellationTimeSeconds', seconds.toString());
  },

  // Enable/disable cancellation feature
  toggleCancellation(enabled) {
    cancellationSettings.update(settings => ({
      ...settings,
      isEnabled: enabled
    }));
    
    localStorage.setItem('cancellationEnabled', enabled.toString());
  },

  // Load settings from localStorage
  loadFromStorage() {
    const savedTime = localStorage.getItem('cancellationTimeSeconds');
    const savedEnabled = localStorage.getItem('cancellationEnabled');
    
    if (savedTime || savedEnabled !== null) {
      const timeSeconds = savedTime ? parseInt(savedTime) : 60;
      const isEnabled = savedEnabled !== null ? savedEnabled === 'true' : true;
      
      cancellationSettings.set({
        allowedTimeSeconds: timeSeconds,
        isEnabled: isEnabled,
        warningMessage: {
          ar: `يمكن إلغاء الطلب خلال ${timeSeconds} ثانية فقط من وقت تأكيد الطلب`,
          en: `Order cancellation is only allowed within ${timeSeconds} seconds of placing the order`
        }
      });
    }
  },

  // Reset to defaults
  resetToDefaults() {
    cancellationSettings.set({
      allowedTimeSeconds: 60,
      isEnabled: true,
      warningMessage: {
        ar: 'يمكن إلغاء الطلب خلال 60 ثانية فقط من وقت تأكيد الطلب',
        en: 'Order cancellation is only allowed within 60 seconds of placing the order'
      }
    });
    
    localStorage.removeItem('cancellationTimeSeconds');
    localStorage.removeItem('cancellationEnabled');
  },

  // Preset time options for admin
  setPresetTime(preset) {
    const presets = {
      '30sec': 30,
      '60sec': 60,
      '90sec': 90,
      '2min': 120,
      '3min': 180,
      '5min': 300
    };
    
    if (presets[preset]) {
      this.setCancellationTime(presets[preset]);
    }
  }
};

// Helper function to get current settings
export function getCurrentCancellationSettings() {
  let currentSettings;
  cancellationSettings.subscribe(settings => currentSettings = settings)();
  return currentSettings;
}