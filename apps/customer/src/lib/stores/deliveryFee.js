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
  // Ensure orderTotal is a valid number
  const validTotal = orderTotal || 0;
  
  // Ensure tiers is an array
  if (!Array.isArray(tiers) || tiers.length === 0) {
    return 15; // Default delivery fee
  }
  
  const applicableTier = tiers.find(tier => 
    validTotal >= (tier.minAmount || 0) && validTotal <= (tier.maxAmount || Infinity)
  );
  
  return applicableTier ? (applicableTier.fee || 0) : 15; // Default to 15 SAR if no tier found
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
  // Ensure orderTotal is a valid number
  const validTotal = orderTotal || 0;
  
  // Ensure tiers is an array
  if (!Array.isArray(tiers) || tiers.length === 0) {
    const currency = language === 'ar' ? 'ريال' : 'SAR';
    return `15.00 ${currency}`; // Default delivery fee
  }
  
  const fee = calculateDeliveryFee(validTotal, tiers);
  const tier = tiers.find(t => validTotal >= (t.minAmount || 0) && validTotal <= (t.maxAmount || Infinity));
  
  if (fee === 0) {
    return language === 'ar' ? 'توصيل مجاني' : 'Free Delivery';
  }
  
  const currency = language === 'ar' ? 'ريال' : 'SAR';
  const feeText = `${(fee || 0).toFixed(2)} ${currency}`;
  
  if (tier && tier.maxAmount !== Infinity) {
    const nextTier = tiers.find(t => (t.minAmount || 0) > (tier.maxAmount || 0));
    if (nextTier && (nextTier.fee || 0) < fee) {
      const needed = (nextTier.minAmount || 0) - validTotal;
      const savings = fee - (nextTier.fee || 0);
      if (language === 'ar') {
        return `${feeText} - أضف ${needed.toFixed(2)} ريال لتوفير ${savings.toFixed(2)} ريال`;
      } else {
        return `${feeText} - Add ${needed.toFixed(2)} SAR to save ${savings.toFixed(2)} SAR`;
      }
    }
  }
  
  return feeText;
}