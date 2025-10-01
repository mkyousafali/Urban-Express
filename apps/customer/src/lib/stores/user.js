import { writable, get } from 'svelte/store';

// User information store
export const userStore = writable({
  name: null,
  phone: null,
  isAuthenticated: false
});

// User actions
export const userActions = {
  // Set user information after login
  setUser(userData) {
    userStore.set({
      name: userData.name,
      phone: userData.phone,
      isAuthenticated: true
    });
    
    // Save to localStorage for persistence
    localStorage.setItem('userName', userData.name || '');
    localStorage.setItem('userPhone', userData.phone || '');
    localStorage.setItem('isAuthenticated', 'true');
  },

  // Update user name
  updateName(name) {
    userStore.update(user => ({
      ...user,
      name: name
    }));
    localStorage.setItem('userName', name || '');
  },

  // Update user phone
  updatePhone(phone) {
    userStore.update(user => ({
      ...user,
      phone: phone
    }));
    localStorage.setItem('userPhone', phone || '');
  },

  // Load user from localStorage
  loadFromStorage() {
    const name = localStorage.getItem('userName');
    const phone = localStorage.getItem('userPhone');
    const isAuthenticated = localStorage.getItem('isAuthenticated') === 'true';

    if (name || phone || isAuthenticated) {
      userStore.set({
        name: name,
        phone: phone,
        isAuthenticated: isAuthenticated
      });
    }
  },

  // Logout user
  logout() {
    userStore.set({
      name: null,
      phone: null,
      isAuthenticated: false
    });
    
    localStorage.removeItem('userName');
    localStorage.removeItem('userPhone');
    localStorage.removeItem('isAuthenticated');
  },

  // Get display name (prioritize name, fallback to phone, then 'Guest')
  getDisplayName() {
    const user = get(userStore);
    return user.name || user.phone || 'Guest';
  }
};

// Helper function to get current user state
export function getCurrentUser() {
  return get(userStore);
}