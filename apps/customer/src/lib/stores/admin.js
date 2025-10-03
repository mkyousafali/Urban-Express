import { writable } from 'svelte/store';

// Categories store
const defaultCategories = [
  { id: 1, nameAr: 'خضروات وفواكه', nameEn: 'Fruits & Vegetables', isActive: true },
  { id: 2, nameAr: 'منتجات الألبان', nameEn: 'Dairy Products', isActive: true },
  { id: 3, nameAr: 'اللحوم والدواجن', nameEn: 'Meat & Poultry', isActive: true },
  { id: 4, nameAr: 'المخبوزات', nameEn: 'Bakery', isActive: true },
  { id: 5, nameAr: 'التوابل والبهارات', nameEn: 'Spices & Seasonings', isActive: true }
];

// Units store
const defaultUnits = [
  { id: 1, nameAr: 'كيلوجرام', nameEn: 'Kilogram', shortAr: 'كجم', shortEn: 'kg', isActive: true },
  { id: 2, nameAr: 'جرام', nameEn: 'Gram', shortAr: 'جم', shortEn: 'g', isActive: true },
  { id: 3, nameAr: 'قطعة', nameEn: 'Piece', shortAr: 'قطعة', shortEn: 'pc', isActive: true },
  { id: 4, nameAr: 'عبوة', nameEn: 'Pack', shortAr: 'عبوة', shortEn: 'pack', isActive: true },
  { id: 5, nameAr: 'لتر', nameEn: 'Liter', shortAr: 'لتر', shortEn: 'L', isActive: true },
  { id: 6, nameAr: 'مليلتر', nameEn: 'Milliliter', shortAr: 'مل', shortEn: 'ml', isActive: true }
];

// Branches store
const defaultBranches = [
  { 
    id: 1, 
    nameAr: 'فرع الرياض الرئيسي', 
    nameEn: 'Riyadh Main Branch',
    addressAr: 'الرياض، حي العليا، شارع الملك فهد',
    addressEn: 'Riyadh, Olaya District, King Fahd Road',
    phone: '+966 11 123 4567',
    latitude: '24.7136',
    longitude: '46.6753',
    pickupService: {
      isActive: true,
      isAvailable24Hours: false,
      startTime: '08:00',
      endTime: '22:00',
      displayAr: '8:00 ص - 10:00 م',
      displayEn: '8:00 AM - 10:00 PM'
    },
    deliveryService: {
      isActive: true,
      isAvailable24Hours: false,
      startTime: '08:00',
      endTime: '23:00',
      displayAr: '8:00 ص - 11:00 م',
      displayEn: '8:00 AM - 11:00 PM',
      deliveryRadius: 15,
      deliveryFee: 15,
      minimumOrder: 50
    },
    staff: {
      pickupStaff: [
        { id: 1, name: 'أحمد محمد', phone: '+966501111111', isActive: true },
        { id: 2, name: 'سارة أحمد', phone: '+966501111112', isActive: true }
      ],
      deliveryBoys: [
        { id: 3, name: 'محمد علي', phone: '+966501111113', isActive: true },
        { id: 4, name: 'عبدالله سالم', phone: '+966501111114', isActive: true },
        { id: 5, name: 'فهد الشهري', phone: '+966501111115', isActive: true }
      ]
    },
    isActive: true,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  { 
    id: 2, 
    nameAr: 'فرع جدة', 
    nameEn: 'Jeddah Branch',
    addressAr: 'جدة، حي الروضة، شارع الأمير سلطان',
    addressEn: 'Jeddah, Al Rawda District, Prince Sultan Street',
    phone: '+966 12 234 5678',
    latitude: '21.4858',
    longitude: '39.1925',
    pickupService: {
      isActive: true,
      isAvailable24Hours: false,
      startTime: '09:00',
      endTime: '21:00',
      displayAr: '9:00 ص - 9:00 م',
      displayEn: '9:00 AM - 9:00 PM'
    },
    deliveryService: {
      isActive: true,
      isAvailable24Hours: false,
      startTime: '09:00',
      endTime: '22:00',
      displayAr: '9:00 ص - 10:00 م',
      displayEn: '9:00 AM - 10:00 PM',
      deliveryRadius: 12,
      deliveryFee: 18,
      minimumOrder: 60
    },
    staff: {
      pickupStaff: [
        { id: 6, name: 'نورا عبدالله', phone: '+966502222221', isActive: true }
      ],
      deliveryBoys: [
        { id: 7, name: 'خالد أحمد', phone: '+966502222222', isActive: true },
        { id: 8, name: 'يوسف محمد', phone: '+966502222223', isActive: true }
      ]
    },
    isActive: true,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];

// Products store
const defaultProducts = [];

// Orders store
const defaultOrders = [
  {
    id: 1,
    orderNumber: 'ORD-001',
    branchId: 1,
    customer: {
      name: 'أحمد محمد',
      phone: '+966501234567',
      address: 'شارع الملك فهد، الرياض',
      latitude: '24.7136',
      longitude: '46.6753'
    },
    items: [
      { id: 1, nameAr: 'تفاح أحمر', nameEn: 'Red Apple', quantity: 2, price: 12.5 },
      { id: 2, nameAr: 'موز', nameEn: 'Banana', quantity: 1, price: 8.0 }
    ],
    total: 33.0,
    status: 'confirmed',
    type: 'delivery',
    paymentMethod: 'cash',
    deliveryBoy: {
      id: 3,
      name: 'محمد علي',
      phone: '+966501111113',
      assignedAt: new Date().toISOString(),
      estimatedTime: 30
    },
    notes: 'يرجى التوصيل للباب الرئيسي',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  },
  {
    id: 2,
    orderNumber: 'ORD-002',
    branchId: 1,
    customer: {
      name: 'فاطمة علي',
      phone: '+966507654321',
      address: 'حي النرجس، الرياض'
    },
    items: [
      { id: 3, nameAr: 'خبز', nameEn: 'Bread', quantity: 3, price: 5.0 }
    ],
    total: 15.0,
    status: 'ready',
    type: 'pickup',
    paymentMethod: 'card',
    pickupStaff: {
      id: 1,
      name: 'أحمد محمد',
      phone: '+966501111111',
      assignedAt: new Date(Date.now() - 1800000).toISOString(),
      estimatedTime: 15
    },
    createdAt: new Date(Date.now() - 3600000).toISOString(),
    updatedAt: new Date(Date.now() - 1800000).toISOString()
  },
  {
    id: 3,
    orderNumber: 'ORD-003',
    branchId: 2,
    customer: {
      name: 'عبدالرحمن سالم',
      phone: '+966503456789',
      address: 'شارع التحلية، جدة',
      latitude: '21.4858',
      longitude: '39.1925'
    },
    items: [
      { id: 1, nameAr: 'تفاح أحمر', nameEn: 'Red Apple', quantity: 1, price: 12.5 },
      { id: 4, nameAr: 'حليب', nameEn: 'Milk', quantity: 2, price: 6.0 }
    ],
    total: 24.5,
    status: 'pending',
    type: 'delivery',
    paymentMethod: 'cash',
    createdAt: new Date(Date.now() - 600000).toISOString(),
    updatedAt: new Date(Date.now() - 600000).toISOString()
  }
];

// Stock store (per branch, per product unit)
const defaultStock = new Map(); // branchId-productId-unitId -> quantity

// Notifications store
const defaultNotifications = [];

// Load from localStorage if available
function loadFromStorage(key, defaultValue) {
  if (typeof window !== 'undefined') {
    const saved = localStorage.getItem(key);
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (e) {
        console.error(`Failed to parse ${key} from localStorage:`, e);
      }
    }
  }
  return defaultValue;
}

// Save to localStorage
function saveToStorage(key, value) {
  if (typeof window !== 'undefined') {
    localStorage.setItem(key, JSON.stringify(value));
  }
}

// Create stores
export const categories = writable(loadFromStorage('admin_categories', defaultCategories));
export const units = writable(loadFromStorage('admin_units', defaultUnits));
export const branches = writable(loadFromStorage('admin_branches', defaultBranches));
export const products = writable(loadFromStorage('admin_products', defaultProducts));
export const orders = writable(loadFromStorage('admin_orders', defaultOrders));
export const stock = writable(loadFromStorage('admin_stock', defaultStock));
export const notifications = writable(loadFromStorage('admin_notifications', defaultNotifications));

// Subscribe to changes and save to localStorage
categories.subscribe(value => saveToStorage('admin_categories', value));
units.subscribe(value => saveToStorage('admin_units', value));
branches.subscribe(value => saveToStorage('admin_branches', value));
products.subscribe(value => saveToStorage('admin_products', value));
orders.subscribe(value => saveToStorage('admin_orders', value));
stock.subscribe(value => saveToStorage('admin_stock', value));
notifications.subscribe(value => saveToStorage('admin_notifications', value));

// Helper functions
export const adminActions = {
  // Branch actions
  addBranch: (branchData) => {
    const newBranch = {
      ...branchData,
      id: Date.now(),
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      isActive: true
    };
    branches.update(branches => [...branches, newBranch]);
    return newBranch.id;
  },
  
  updateBranch: (id, updates) => {
    branches.update(branches => branches.map(branch => 
      branch.id === id ? { ...branch, ...updates, updatedAt: new Date().toISOString() } : branch
    ));
  },
  
  deleteBranch: (id) => {
    branches.update(branches => branches.filter(branch => branch.id !== id));
  },

  // Category actions
  addCategory: (category) => {
    categories.update(cats => [...cats, { ...category, id: Date.now() }]);
  },
  
  updateCategory: (id, updates) => {
    categories.update(cats => cats.map(cat => cat.id === id ? { ...cat, ...updates } : cat));
  },
  
  // Unit actions
  addUnit: (unit) => {
    units.update(units => [...units, { ...unit, id: Date.now() }]);
  },
  
  updateUnit: (id, updates) => {
    units.update(units => units.map(unit => unit.id === id ? { ...unit, ...updates } : unit));
  },
  
  // Product actions
  addProduct: (product) => {
    const newProduct = {
      ...product,
      id: Date.now(),
      createdAt: new Date().toISOString(),
      isActive: true
    };
    products.update(prods => [...prods, newProduct]);
    return newProduct.id;
  },
  
  updateProduct: (id, updates) => {
    products.update(prods => prods.map(prod => prod.id === id ? { ...prod, ...updates } : prod));
  },
  
  deactivateProduct: (id) => {
    products.update(prods => prods.map(prod => prod.id === id ? { ...prod, isActive: false } : prod));
  },
  
  // Stock actions
  updateStock: (branchId, productId, unitId, quantity) => {
    stock.update(stockMap => {
      const key = `${branchId}-${productId}-${unitId}`;
      const newMap = new Map(stockMap);
      newMap.set(key, Math.max(0, quantity));
      return newMap;
    });
  },
  
  getStock: (stockMap, branchId, productId, unitId) => {
    const key = `${branchId}-${productId}-${unitId}`;
    return stockMap.get(key) || 0;
  },
  
  // Order actions
  addOrder: (order) => {
    const newOrder = {
      ...order,
      id: Date.now(),
      orderNumber: `ORD-${String(Date.now()).slice(-6)}`,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      status: 'pending'
    };
    orders.update(orders => [...orders, newOrder]);
    
    // Add notification
    adminActions.addNotification({
      type: 'new_order',
      title: 'New Order Received',
      titleAr: 'طلب جديد',
      message: `Order #${newOrder.orderNumber} from ${order.customer?.name}`,
      messageAr: `طلب رقم ${newOrder.orderNumber} من ${order.customer?.name}`,
      orderId: newOrder.id,
      isRead: false
    });
    
    return newOrder.id;
  },
  
  updateOrder: (id, updates) => {
    orders.update(orders => orders.map(order => 
      order.id === id ? { ...order, ...updates, updatedAt: new Date().toISOString() } : order
    ));
  },
  
  updateOrderStatus: (id, status) => {
    orders.update(orders => orders.map(order => 
      order.id === id ? { ...order, status, updatedAt: new Date().toISOString() } : order
    ));
  },
  
  assignStaffToOrder: (orderId, staffType, staffData) => {
    orders.update(orders => orders.map(order => {
      if (order.id === orderId) {
        const update = { updatedAt: new Date().toISOString() };
        if (staffType === 'pickup') {
          update.pickupStaff = staffData;
        } else if (staffType === 'delivery') {
          update.deliveryBoy = staffData;
        }
        return { ...order, ...update };
      }
      return order;
    }));
  },
  
  // Notification actions
  addNotification: (notification) => {
    const newNotification = {
      ...notification,
      id: Date.now(),
      createdAt: new Date().toISOString()
    };
    notifications.update(notifs => [newNotification, ...notifs]);
    
    // Send push notification if supported
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification(notification.title, {
        body: notification.message,
        icon: '/logo.png'
      });
    }
  },
  
  markNotificationAsRead: (id) => {
    notifications.update(notifs => notifs.map(notif => notif.id === id ? { ...notif, isRead: true } : notif));
  },
  
  // WhatsApp sharing
  shareOrderToWhatsApp: (order, phoneNumber) => {
    const orderDetails = `
*New Order #${order.id}*

*Customer:* ${order.customerName}
*Phone:* ${order.customerPhone}
*Type:* ${order.type === 'delivery' ? 'Delivery' : 'Pickup'}
*Address:* ${order.address || 'N/A'}

*Items:*
${order.items.map(item => `• ${item.name} - ${item.quantity} x ${item.price} SAR`).join('\n')}

*Total:* ${order.total} SAR
*Payment:* ${order.paymentMethod}

*Order Time:* ${new Date(order.createdAt).toLocaleString()}
    `.trim();
    
    const whatsappUrl = `https://wa.me/${phoneNumber.replace(/[^0-9]/g, '')}?text=${encodeURIComponent(orderDetails)}`;
    window.open(whatsappUrl, '_blank');
  }
};