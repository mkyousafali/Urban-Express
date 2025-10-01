import { writable } from 'svelte/store';

// Delivery fee tiers configuration
// Admin can modify these values
export const deliveryFeeTiers = writable([
  { minAmount: 0, maxAmount: 99.99, fee: 20 },
  { minAmount: 100, maxAmount: 199.99, fee: 15 },
  { minAmount: 200, maxAmount: 299.99, fee: 10 },
  { minAmount: 300, maxAmount: 399.99, fee: 10 },
  { minAmount: 400, maxAmount: 499.99, fee: 10 },
  { minAmount: 500, maxAmount: Infinity, fee: 0 }
]);

// Function to calculate delivery fee based on order total
export function calculateDeliveryFee(orderTotal, tiers) {
  const applicableTier = tiers.find(tier => 
    orderTotal >= tier.minAmount && orderTotal <= tier.maxAmount
  );
  
  return applicableTier ? applicableTier.fee : 15; // Default to 15 SAR if no tier found
}

// Admin functions to manage delivery fee tiers
export const deliveryFeeActions = {
  // Update a specific tier
  updateTier(index, newTier) {
    deliveryFeeTiers.update(tiers => {
      tiers[index] = { ...tiers[index], ...newTier };
      return [...tiers];
    });
  },

  // Add a new tier
  addTier(tier) {
    deliveryFeeTiers.update(tiers => {
      const newTiers = [...tiers, tier];
      // Sort tiers by minAmount
      return newTiers.sort((a, b) => a.minAmount - b.minAmount);
    });
  },

  // Remove a tier
  removeTier(index) {
    deliveryFeeTiers.update(tiers => {
      return tiers.filter((_, i) => i !== index);
    });
  },

  // Reset to default tiers
  resetToDefault() {
    deliveryFeeTiers.set([
      { minAmount: 0, maxAmount: 99.99, fee: 20 },
      { minAmount: 100, maxAmount: 199.99, fee: 15 },
      { minAmount: 200, maxAmount: 299.99, fee: 10 },
      { minAmount: 300, maxAmount: 399.99, fee: 10 },
      { minAmount: 400, maxAmount: 499.99, fee: 10 },
      { minAmount: 500, maxAmount: Infinity, fee: 0 }
    ]);
  },

  // Bulk update all tiers
  setTiers(newTiers) {
    deliveryFeeTiers.set(newTiers.sort((a, b) => a.minAmount - b.minAmount));
  }
};

// Helper function to get delivery fee description for UI
export function getDeliveryFeeDescription(orderTotal, tiers, language = 'en') {
  const fee = calculateDeliveryFee(orderTotal, tiers);
  const tier = tiers.find(t => orderTotal >= t.minAmount && orderTotal <= t.maxAmount);
  
  if (fee === 0) {
    return language === 'ar' ? 'توصيل مجاني' : 'Free Delivery';
  }
  
  const currency = language === 'ar' ? 'ريال' : 'SAR';
  const feeText = `${fee.toFixed(2)} ${currency}`;
  
  if (tier && tier.maxAmount !== Infinity) {
    const nextTier = tiers.find(t => t.minAmount > tier.maxAmount);
    if (nextTier && nextTier.fee < fee) {
      const needed = nextTier.minAmount - orderTotal;
      const savings = fee - nextTier.fee;
      if (language === 'ar') {
        return `${feeText} - أضف ${needed.toFixed(2)} ريال لتوفير ${savings.toFixed(2)} ريال`;
      } else {
        return `${feeText} - Add ${needed.toFixed(2)} SAR to save ${savings.toFixed(2)} SAR`;
      }
    }
  }
  
  return feeText;
}