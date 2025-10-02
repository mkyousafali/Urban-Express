import { writable, derived } from 'svelte/store';

// Cart store
export const cartStore = writable([]);

// Cart count derived store
export const cartCount = derived(cartStore, items => 
  items.reduce((total, item) => total + (item.quantity || 0), 0)
);

// Cart total derived store with price validation
export const cartTotal = derived(cartStore, items => 
  items.reduce((sum, item) => {
    const price = item.basePrice || item.price || 0;
    const quantity = item.quantity || 0;
    return sum + (price * quantity);
  }, 0)
);

// Functions to manage cart
export const cartActions = {
  addItem(product, quantity = 1) {
    cartStore.update(items => {
      const existingItem = items.find(item => String(item.id) === String(product.id));
      
      if (existingItem) {
        existingItem.quantity += quantity;
        return items;
      } else {
        return [...items, { ...product, quantity }];
      }
    });
  },

  removeItem(productId) {
    cartStore.update(items => items.filter(item => String(item.id) !== String(productId)));
  },

  updateQuantity(productId, quantity) {
    if (quantity <= 0) {
      this.removeItem(productId);
      return;
    }
    
    cartStore.update(items => {
      const item = items.find(item => String(item.id) === String(productId));
      if (item) {
        item.quantity = quantity;
      } else {
        // If item doesn't exist, find the product and add it
        const allProducts = [
          // Add your products here or pass them as parameter
        ];
        const product = allProducts.find(p => String(p.id) === String(productId));
        if (product) {
          items.push({ ...product, quantity });
        }
      }
      return items;
    });
  },

  setItemQuantity(product, quantity) {
    if (quantity <= 0) {
      this.removeItem(product.id);
      return;
    }
    
    cartStore.update(items => {
      const existingItemIndex = items.findIndex(item => String(item.id) === String(product.id));
      
      if (existingItemIndex !== -1) {
        // Create new array with updated item to trigger reactivity
        const newItems = [...items];
        newItems[existingItemIndex] = { ...newItems[existingItemIndex], quantity };
        return newItems;
      } else {
        // Add new item
        return [...items, { ...product, quantity }];
      }
    });
  },

  clearCart() {
    cartStore.set([]);
  }
};