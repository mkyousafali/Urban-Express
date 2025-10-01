# Complete SQL Schema for Urban Express

-- Run this SQL script in your Supabase SQL editor to create the complete database schema

-- =====================================================
-- CUSTOM TYPES AND ENUMS
-- =====================================================

-- User management types
CREATE TYPE user_role AS ENUM ('customer', 'driver', 'dispatcher', 'admin');
CREATE TYPE user_status AS ENUM ('pending', 'active', 'suspended', 'inactive');

-- Order lifecycle types  
CREATE TYPE order_status AS ENUM (
  'placed',           -- Order submitted by customer
  'confirmed',        -- Order confirmed by system
  'picking',          -- Items being picked
  'packed',           -- Order packed and ready
  'ready_to_route',   -- Ready for route assignment
  'out_for_delivery', -- Assigned to driver and out
  'delivered',        -- Successfully delivered
  'cancelled',        -- Cancelled by customer/admin
  'exception'         -- Delivery exception/failed
);

-- Payment types
CREATE TYPE payment_method AS ENUM ('cash', 'card_pos');
CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');

-- Cash drawer management
CREATE TYPE drawer_status AS ENUM ('open', 'closing', 'closed', 'variance');

-- Communication types
CREATE TYPE notification_priority AS ENUM ('low', 'normal', 'high', 'critical');
CREATE TYPE conversation_type AS ENUM ('order', 'support', 'drawer', 'registration');
CREATE TYPE conversation_status AS ENUM ('active', 'resolved', 'escalated', 'archived');

-- Route and delivery types
CREATE TYPE route_status AS ENUM ('planning', 'optimized', 'assigned', 'in_progress', 'completed');
CREATE TYPE delivery_status AS ENUM ('pending', 'arrived', 'delivered', 'exception');

-- =====================================================
-- CONFIGURATION & MASTER DATA
-- =====================================================

-- Branch/store locations
CREATE TABLE branches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,
  
  -- Location
  address TEXT NOT NULL,
  location POINT NOT NULL,
  timezone TEXT NOT NULL DEFAULT 'Asia/Riyadh',
  
  -- Contact information
  phone TEXT,
  manager_id UUID,
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- SAR denomination master data
CREATE TABLE cash_denominations (
  id SERIAL PRIMARY KEY,
  value DECIMAL(10,2) NOT NULL UNIQUE CHECK (value > 0),
  is_coin BOOLEAN NOT NULL DEFAULT FALSE,
  display_order INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Service area polygons
CREATE TABLE service_areas (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID NOT NULL REFERENCES branches(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  polygon POLYGON NOT NULL,
  
  -- Delivery configuration
  is_active BOOLEAN DEFAULT TRUE,
  delivery_fee_default DECIMAL(10,2) DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Delivery charge configuration
CREATE TABLE delivery_charge_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  branch_id UUID NOT NULL REFERENCES branches(id),
  service_area_id UUID REFERENCES service_areas(id),
  
  -- Charge rules
  default_charge DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (default_charge >= 0),
  min_charge DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (min_charge >= 0),
  max_charge DECIMAL(10,2) NOT NULL CHECK (max_charge >= min_charge),
  
  -- Conditions
  min_order_amount DECIMAL(10,2) DEFAULT 0,
  free_delivery_threshold DECIMAL(10,2),
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  effective_from TIMESTAMPTZ DEFAULT NOW(),
  effective_to TIMESTAMPTZ,
  
  created_by UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CHECK (effective_to IS NULL OR effective_to > effective_from)
);

-- =====================================================
-- IDENTITY & AUTHENTICATION
-- =====================================================

-- Core user table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role user_role NOT NULL DEFAULT 'customer',
  full_name TEXT NOT NULL CHECK (length(full_name) >= 2),
  whatsapp_number TEXT UNIQUE NOT NULL CHECK (whatsapp_number ~ '^05[0-9]{8}$'),
  password_hash TEXT NOT NULL,
  status user_status NOT NULL DEFAULT 'pending',
  branch_id UUID REFERENCES branches(id),
  last_login_at TIMESTAMPTZ,
  password_changed_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Customer-specific information
CREATE TABLE customers (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  default_location JSONB NOT NULL CHECK (
    default_location ? 'lat' AND 
    default_location ? 'lng' AND 
    default_location ? 'address'
  ),
  terms_version_accepted TEXT,
  terms_accepted_at TIMESTAMPTZ,
  qac_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Terms and conditions management
CREATE TABLE terms_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  version TEXT UNIQUE NOT NULL,
  ar_content TEXT NOT NULL,
  en_content TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  go_live_at TIMESTAMPTZ,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Track T&C acceptance by users
CREATE TABLE terms_acceptance (
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  version TEXT NOT NULL,
  language TEXT NOT NULL CHECK (language IN ('ar', 'en')),
  ip_address INET,
  accepted_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, version)
);

-- =====================================================
-- COMMERCE & ORDERS
-- =====================================================

-- Main orders table
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number TEXT UNIQUE NOT NULL,
  customer_id UUID NOT NULL REFERENCES users(id),
  status order_status NOT NULL DEFAULT 'placed',
  
  -- Financial calculations
  subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
  delivery_charge DECIMAL(10,2) DEFAULT 0 CHECK (delivery_charge >= 0),
  discount DECIMAL(10,2) DEFAULT 0 CHECK (discount >= 0),
  total DECIMAL(10,2) GENERATED ALWAYS AS (subtotal + delivery_charge - discount) STORED,
  
  -- Delivery information
  scheduled_window TSTZRANGE,
  location_snapshot JSONB NOT NULL, -- Immutable after checkout
  delivery_notes TEXT,
  
  -- Payment
  payment_method payment_method,
  payment_status payment_status DEFAULT 'pending',
  
  -- Delivery charge workflow
  delivery_charge_added_by UUID REFERENCES users(id),
  delivery_charge_added_at TIMESTAMPTZ,
  delivery_charge_accepted_at TIMESTAMPTZ,
  delivery_charge_declined_at TIMESTAMPTZ,
  
  -- Timestamps
  placed_at TIMESTAMPTZ DEFAULT NOW(),
  confirmed_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  CHECK (
    (status = 'cancelled' AND cancelled_at IS NOT NULL) OR
    (status != 'cancelled' AND cancelled_at IS NULL)
  ),
  CHECK (
    (status = 'delivered' AND delivered_at IS NOT NULL) OR
    (status != 'delivered' AND delivered_at IS NULL)
  )
);

-- Order line items
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  sku TEXT NOT NULL,
  name TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  line_total DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  substitutions JSONB DEFAULT '[]',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- ROUTING & DELIVERY
-- =====================================================

-- Pre-defined cash kits for drivers
CREATE TABLE cash_kits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  is_default BOOLEAN DEFAULT FALSE,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cash kit denomination breakdown
CREATE TABLE cash_kit_denominations (
  kit_id UUID NOT NULL REFERENCES cash_kits(id) ON DELETE CASCADE,
  denomination_id INTEGER NOT NULL REFERENCES cash_denominations(id),
  count INTEGER NOT NULL CHECK (count >= 0),
  PRIMARY KEY (kit_id, denomination_id)
);

-- Daily routes
CREATE TABLE routes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  branch_id UUID NOT NULL REFERENCES branches(id),
  dispatcher_id UUID NOT NULL REFERENCES users(id),
  driver_id UUID REFERENCES users(id),
  status route_status NOT NULL DEFAULT 'planning',
  
  -- Route optimization
  optimized_at TIMESTAMPTZ,
  optimization_data JSONB, -- Store optimization parameters and results
  
  -- Cash management
  opening_cash_kit_id UUID REFERENCES cash_kits(id),
  
  -- Timestamps
  assigned_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(date, driver_id) -- One route per driver per day
);

-- Individual stops on routes
CREATE TABLE route_stops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  route_id UUID NOT NULL REFERENCES routes(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES orders(id),
  sequence_number INTEGER NOT NULL,
  
  -- Timing
  planned_eta TIMESTAMPTZ,
  actual_arrival_at TIMESTAMPTZ,
  actual_departure_at TIMESTAMPTZ,
  
  -- Status
  status delivery_status NOT NULL DEFAULT 'pending',
  exception_code TEXT,
  exception_note TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(route_id, sequence_number),
  UNIQUE(route_id, order_id)
);

-- Delivery execution details
CREATE TABLE deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id),
  route_stop_id UUID NOT NULL REFERENCES route_stops(id),
  driver_id UUID NOT NULL REFERENCES users(id),
  
  -- Delivery process
  status delivery_status NOT NULL DEFAULT 'pending',
  arrived_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  
  -- Exception handling
  exception_code TEXT,
  exception_note TEXT,
  retry_count INTEGER DEFAULT 0,
  
  -- Location verification
  delivery_location POINT, -- GPS coordinates when delivered
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- PAYMENT & CASH MANAGEMENT
-- =====================================================

-- Driver cash drawer sessions
CREATE TABLE cash_drawers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  driver_id UUID NOT NULL REFERENCES users(id),
  branch_id UUID NOT NULL REFERENCES branches(id),
  route_id UUID REFERENCES routes(id),
  
  -- Session timing
  opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  closed_at TIMESTAMPTZ,
  
  -- Status and approvals
  status drawer_status NOT NULL DEFAULT 'open',
  variance_amount DECIMAL(10,2) DEFAULT 0,
  variance_note TEXT,
  approved_by UUID REFERENCES users(id),
  approved_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CHECK (
    (status = 'closed' AND closed_at IS NOT NULL) OR
    (status != 'closed' AND closed_at IS NULL)
  )
);

-- Opening cash denominations
CREATE TABLE drawer_opening_denominations (
  drawer_id UUID NOT NULL REFERENCES cash_drawers(id) ON DELETE CASCADE,
  denomination_id INTEGER NOT NULL REFERENCES cash_denominations(id),
  count INTEGER NOT NULL CHECK (count >= 0),
  PRIMARY KEY (drawer_id, denomination_id)
);

-- Closing cash denominations  
CREATE TABLE drawer_closing_denominations (
  drawer_id UUID NOT NULL REFERENCES cash_drawers(id) ON DELETE CASCADE,
  denomination_id INTEGER NOT NULL REFERENCES cash_denominations(id),
  count INTEGER NOT NULL CHECK (count >= 0),
  PRIMARY KEY (drawer_id, denomination_id)
);

-- Payment receipts
CREATE TABLE payment_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id),
  drawer_id UUID REFERENCES cash_drawers(id),
  method payment_method NOT NULL,
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  
  -- Card payment specifics
  card_last_four CHAR(4) CHECK (
    (method = 'card_pos' AND card_last_four IS NOT NULL) OR
    (method = 'cash' AND card_last_four IS NULL)
  ),
  slip_photo_url TEXT CHECK (
    (method = 'card_pos' AND slip_photo_url IS NOT NULL) OR
    (method = 'cash' AND slip_photo_url IS NULL)
  ),
  pos_terminal_id TEXT,
  
  -- Metadata
  recorded_by UUID NOT NULL REFERENCES users(id),
  recorded_at TIMESTAMPTZ DEFAULT NOW(),
  location_recorded POINT, -- GPS location when payment recorded
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cash payment denomination breakdown
CREATE TABLE payment_cash_breakdown (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  receipt_id UUID NOT NULL REFERENCES payment_receipts(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('received', 'change_given')),
  denomination_id INTEGER NOT NULL REFERENCES cash_denominations(id),
  count INTEGER NOT NULL CHECK (count >= 0),
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- COMMUNICATION & NOTIFICATIONS
-- =====================================================

-- Notification templates
CREATE TABLE notification_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  
  -- Bilingual content
  ar_title TEXT NOT NULL,
  ar_body TEXT NOT NULL,
  en_title TEXT NOT NULL,
  en_body TEXT NOT NULL,
  
  -- Configuration
  priority_default notification_priority NOT NULL DEFAULT 'normal',
  variables JSONB DEFAULT '[]', -- Array of variable names
  is_enabled BOOLEAN DEFAULT TRUE,
  
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User notifications
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  to_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  template_key TEXT REFERENCES notification_templates(key),
  
  -- Priority and categorization
  priority notification_priority NOT NULL DEFAULT 'normal',
  topic TEXT NOT NULL,
  category TEXT,
  
  -- Bilingual content (resolved from template)
  title_ar TEXT NOT NULL,
  title_en TEXT NOT NULL,
  body_ar TEXT NOT NULL,
  body_en TEXT NOT NULL,
  
  -- Navigation
  deep_link TEXT,
  entity_type TEXT,
  entity_id UUID,
  
  -- Delivery tracking
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  delivered_at TIMESTAMPTZ,
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMPTZ,
  
  -- Push notification
  push_sent BOOLEAN DEFAULT FALSE,
  push_sent_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conversation threads
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type conversation_type NOT NULL,
  entity_id UUID, -- Links to order, drawer, etc.
  
  -- Participants
  participants UUID[] NOT NULL DEFAULT '{}',
  
  -- Status and metadata
  status conversation_status NOT NULL DEFAULT 'active',
  language TEXT NOT NULL DEFAULT 'ar' CHECK (language IN ('ar', 'en')),
  branch_id UUID REFERENCES branches(id),
  
  -- AI assistance
  ai_enabled BOOLEAN DEFAULT TRUE,
  ai_escalated BOOLEAN DEFAULT FALSE,
  ai_escalated_at TIMESTAMPTZ,
  
  -- Resolution
  resolved_by UUID REFERENCES users(id),
  resolved_at TIMESTAMPTZ,
  resolution_note TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat messages
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  
  -- Sender information
  sender_type TEXT NOT NULL CHECK (sender_type IN ('user', 'ai', 'system')),
  sender_id UUID REFERENCES users(id), -- NULL for AI/system messages
  
  -- Message content
  body_text TEXT NOT NULL,
  attachments JSONB DEFAULT '[]',
  
  -- AI metadata
  ai_model TEXT, -- e.g., 'gpt-4'
  ai_confidence DECIMAL(3,2), -- 0.00-1.00
  ai_escalation_triggered BOOLEAN DEFAULT FALSE,
  
  -- Message status
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMPTZ,
  is_deleted BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMPTZ,
  
  sent_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI knowledge base
CREATE TABLE ai_knowledge_docs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  language TEXT NOT NULL CHECK (language IN ('ar', 'en')),
  content TEXT NOT NULL,
  
  -- Organization
  tags TEXT[] DEFAULT '{}',
  category TEXT,
  
  -- Scope and validity
  branch_scope UUID[] DEFAULT '{}', -- Empty array = all branches
  valid_from TIMESTAMPTZ DEFAULT NOW(),
  valid_to TIMESTAMPTZ,
  
  -- Status
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  
  -- Management
  created_by UUID NOT NULL REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- AI configuration
CREATE TABLE ai_policies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  
  -- AI behavior rules
  rules JSONB NOT NULL DEFAULT '{}',
  system_prompt TEXT NOT NULL,
  style_guide TEXT,
  escalation_keywords TEXT[] DEFAULT '{}',
  
  -- Model configuration
  model_name TEXT DEFAULT 'gpt-4',
  temperature DECIMAL(3,2) DEFAULT 0.7 CHECK (temperature BETWEEN 0 AND 1),
  max_tokens INTEGER DEFAULT 1000,
  
  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  
  updated_by UUID NOT NULL REFERENCES users(id),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- AUDIT & LOGGING
-- =====================================================

-- Complete audit trail
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Actor information
  actor_id UUID REFERENCES users(id),
  actor_role user_role,
  
  -- Action details
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID NOT NULL,
  
  -- Data changes
  before_data JSONB,
  after_data JSONB,
  
  -- Context
  ip_address INET,
  user_agent TEXT,
  session_id TEXT,
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to relevant tables
CREATE TRIGGER users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER customers_updated_at BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER orders_updated_at BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER routes_updated_at BEFORE UPDATE ON routes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER route_stops_updated_at BEFORE UPDATE ON route_stops
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER conversations_updated_at BEFORE UPDATE ON conversations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Generate unique order numbers
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
  new_number TEXT;
  exists_check BOOLEAN;
BEGIN
  LOOP
    -- Format: UE-YYYYMMDD-NNNN
    new_number := 'UE-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || 
                  LPAD((FLOOR(RANDOM() * 9999) + 1)::TEXT, 4, '0');
    
    SELECT EXISTS(SELECT 1 FROM orders WHERE order_number = new_number) INTO exists_check;
    
    IF NOT exists_check THEN
      EXIT;
    END IF;
  END LOOP;
  
  RETURN new_number;
END;
$$ LANGUAGE plpgsql;

-- Auto-generate order numbers
CREATE OR REPLACE FUNCTION set_order_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
    NEW.order_number := generate_order_number();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_set_number_trigger
  BEFORE INSERT ON orders
  FOR EACH ROW EXECUTE FUNCTION set_order_number();

-- Order status transition validation
CREATE OR REPLACE FUNCTION validate_order_status_transition()
RETURNS TRIGGER AS $$
BEGIN
  -- Define valid status transitions
  IF OLD.status = 'placed' AND NEW.status NOT IN ('confirmed', 'cancelled') THEN
    RAISE EXCEPTION 'Invalid status transition from % to %', OLD.status, NEW.status;
  END IF;
  
  IF OLD.status = 'confirmed' AND NEW.status NOT IN ('picking', 'cancelled') THEN
    RAISE EXCEPTION 'Invalid status transition from % to %', OLD.status, NEW.status;
  END IF;
  
  IF OLD.status = 'picking' AND NEW.status NOT IN ('packed', 'cancelled') THEN
    RAISE EXCEPTION 'Invalid status transition from % to %', OLD.status, NEW.status;
  END IF;
  
  IF OLD.status = 'packed' AND NEW.status NOT IN ('ready_to_route', 'cancelled') THEN
    RAISE EXCEPTION 'Invalid status transition from % to %', OLD.status, NEW.status;
  END IF;
  
  IF OLD.status = 'ready_to_route' AND NEW.status NOT IN ('out_for_delivery', 'cancelled') THEN
    RAISE EXCEPTION 'Invalid status transition from % to %', OLD.status, NEW.status;
  END IF;
  
  IF OLD.status = 'out_for_delivery' AND NEW.status NOT IN ('delivered', 'exception') THEN
    RAISE EXCEPTION 'Invalid status transition from % to %', OLD.status, NEW.status;
  END IF;
  
  -- Terminal statuses cannot be changed
  IF OLD.status IN ('delivered', 'cancelled') THEN
    RAISE EXCEPTION 'Cannot change status from terminal state %', OLD.status;
  END IF;
  
  -- Set appropriate timestamps
  CASE NEW.status
    WHEN 'confirmed' THEN NEW.confirmed_at := NOW();
    WHEN 'delivered' THEN NEW.delivered_at := NOW();
    WHEN 'cancelled' THEN NEW.cancelled_at := NOW();
    ELSE -- Keep existing timestamps
  END CASE;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_status_transition_trigger
  BEFORE UPDATE ON orders
  FOR EACH ROW 
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION validate_order_status_transition();

-- Sensitive operation logging
CREATE OR REPLACE FUNCTION log_sensitive_operation()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_logs (
    actor_id,
    action,
    entity_type,
    entity_id,
    before_data,
    after_data,
    created_at
  ) VALUES (
    COALESCE(current_setting('app.current_user_id', true)::UUID, NULL),
    TG_OP,
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE to_jsonb(OLD) END,
    CASE WHEN TG_OP = 'INSERT' THEN to_jsonb(NEW) ELSE to_jsonb(NEW) END,
    NOW()
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Apply audit logging to sensitive tables
CREATE TRIGGER users_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON users
  FOR EACH ROW EXECUTE FUNCTION log_sensitive_operation();

CREATE TRIGGER orders_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON orders  
  FOR EACH ROW EXECUTE FUNCTION log_sensitive_operation();

CREATE TRIGGER payment_receipts_audit_trigger
  AFTER INSERT OR UPDATE OR DELETE ON payment_receipts
  FOR EACH ROW EXECUTE FUNCTION log_sensitive_operation();

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- User lookups
CREATE INDEX idx_users_whatsapp ON users(whatsapp_number);
CREATE INDEX idx_users_role_status ON users(role, status);
CREATE INDEX idx_users_branch ON users(branch_id) WHERE branch_id IS NOT NULL;

-- Order queries
CREATE INDEX idx_orders_customer ON orders(customer_id, created_at DESC);
CREATE INDEX idx_orders_status ON orders(status, created_at);
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_date ON orders(DATE(created_at));

-- Route and delivery optimization  
CREATE INDEX idx_routes_date_branch ON routes(date, branch_id);
CREATE INDEX idx_routes_driver ON routes(driver_id, date);
CREATE INDEX idx_route_stops_route ON route_stops(route_id, sequence_number);
CREATE INDEX idx_route_stops_order ON route_stops(order_id);

-- Payment and cash management
CREATE INDEX idx_cash_drawers_driver ON cash_drawers(driver_id, opened_at DESC);
CREATE INDEX idx_payment_receipts_order ON payment_receipts(order_id);
CREATE INDEX idx_payment_receipts_drawer ON payment_receipts(drawer_id);

-- Communication
CREATE INDEX idx_notifications_user ON notifications(to_user_id, sent_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(to_user_id, is_read, priority);
CREATE INDEX idx_conversations_type_entity ON conversations(type, entity_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id, sent_at);

-- Audit and reporting
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id, created_at);
CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id, created_at);
CREATE INDEX idx_audit_logs_action ON audit_logs(action, created_at);

-- Spatial indexes for location-based queries
CREATE INDEX idx_branches_location ON branches USING GIST(location);
CREATE INDEX idx_service_areas_polygon ON service_areas USING GIST(polygon);

-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE routes ENABLE ROW LEVEL SECURITY;
ALTER TABLE route_stops ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_drawers ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Customer policies
CREATE POLICY "Customers can view own profile" ON users
  FOR SELECT USING (auth.uid() = id AND role = 'customer');

CREATE POLICY "Customers can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id AND role = 'customer')
  WITH CHECK (
    auth.uid() = id AND 
    role = 'customer' AND
    whatsapp_number = (SELECT whatsapp_number FROM users WHERE id = auth.uid()) -- Cannot change WhatsApp
  );

CREATE POLICY "Customers can view own customer data" ON customers
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Customers can update own customer data" ON customers
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Customers can view own orders" ON orders
  FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "Customers can view own order items" ON order_items
  FOR SELECT USING (
    order_id IN (SELECT id FROM orders WHERE customer_id = auth.uid())
  );

CREATE POLICY "Customers can view own notifications" ON notifications
  FOR SELECT USING (to_user_id = auth.uid());

CREATE POLICY "Customers can update own notifications" ON notifications
  FOR UPDATE USING (to_user_id = auth.uid())
  WITH CHECK (to_user_id = auth.uid());

-- Driver policies
CREATE POLICY "Drivers can view assigned routes" ON routes
  FOR SELECT USING (
    driver_id = auth.uid() AND
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'driver')
  );

CREATE POLICY "Drivers can view assigned route stops" ON route_stops
  FOR SELECT USING (
    route_id IN (
      SELECT id FROM routes WHERE driver_id = auth.uid()
    )
  );

CREATE POLICY "Drivers can view assigned orders" ON orders
  FOR SELECT USING (
    id IN (
      SELECT rs.order_id FROM route_stops rs
      JOIN routes r ON rs.route_id = r.id
      WHERE r.driver_id = auth.uid()
    )
  );

CREATE POLICY "Drivers can manage own cash drawer" ON cash_drawers
  FOR ALL USING (
    driver_id = auth.uid() AND
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'driver')
  );

CREATE POLICY "Drivers can create payment receipts" ON payment_receipts
  FOR INSERT WITH CHECK (
    recorded_by = auth.uid() AND
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'driver') AND
    drawer_id IN (SELECT id FROM cash_drawers WHERE driver_id = auth.uid())
  );

-- Dispatcher policies  
CREATE POLICY "Dispatchers have branch access to orders" ON orders
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid() 
        AND u.role IN ('dispatcher', 'admin')
        AND (u.role = 'admin' OR u.branch_id = (
          SELECT o.branch_id FROM orders o WHERE o.id = orders.id
        ))
    )
  );

CREATE POLICY "Dispatchers can manage routes" ON routes
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
        AND u.role IN ('dispatcher', 'admin')
        AND (u.role = 'admin' OR u.branch_id = branch_id)
    )
  );

CREATE POLICY "Dispatchers can view driver drawers" ON cash_drawers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users u
      WHERE u.id = auth.uid()
        AND u.role IN ('dispatcher', 'admin')
        AND (u.role = 'admin' OR u.branch_id = branch_id)
    )
  );

-- Admin policies
CREATE POLICY "Admins have full access" ON users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins have full order access" ON orders
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Public read access for reference data
CREATE POLICY "Public can read branches" ON branches FOR SELECT USING (true);
CREATE POLICY "Public can read denominations" ON cash_denominations FOR SELECT USING (true);
CREATE POLICY "Public can read terms" ON terms_documents FOR SELECT USING (status = 'published');

-- =====================================================
-- INITIAL DATA SEED
-- =====================================================

-- Insert SAR denominations
INSERT INTO cash_denominations (value, is_coin, display_order) VALUES
(500.00, false, 1),
(200.00, false, 2),
(100.00, false, 3),
(50.00, false, 4),
(20.00, false, 5),
(10.00, false, 6),
(5.00, false, 7),
(1.00, false, 8),
(2.00, true, 9),
(1.00, true, 10),
(0.50, true, 11),
(0.25, true, 12),
(0.10, true, 13),
(0.05, true, 14),
(0.01, true, 15);

-- Create default notification templates
INSERT INTO notification_templates (key, name, ar_title, ar_body, en_title, en_body, priority_default, created_by) VALUES
('order_placed', 'Order Placed', 'تم تأكيد طلبك', 'تم تأكيد طلبك رقم {{order_number}} بنجاح', 'Order Confirmed', 'Your order {{order_number}} has been confirmed', 'normal', (SELECT id FROM users WHERE role = 'admin' LIMIT 1)),
('order_out_for_delivery', 'Out for Delivery', 'طلبك في الطريق', 'طلبك رقم {{order_number}} في الطريق إليك', 'Order Out for Delivery', 'Your order {{order_number}} is out for delivery', 'high', (SELECT id FROM users WHERE role = 'admin' LIMIT 1)),
('delivery_charge_added', 'Delivery Charge Added', 'رسوم توصيل', 'تم إضافة رسوم توصيل {{charge}} ر.س. الإجمالي {{total}} ر.س', 'Delivery Charge Added', 'Delivery charge SAR {{charge}} added. Total SAR {{total}}', 'high', (SELECT id FROM users WHERE role = 'admin' LIMIT 1)),
('password_reset', 'Password Reset', 'إعادة تعيين كلمة المرور', 'تم إعادة تعيين كلمة المرور الخاصة بك', 'Password Reset', 'Your password has been reset', 'critical', (SELECT id FROM users WHERE role = 'admin' LIMIT 1));

-- Create default AI policy
INSERT INTO ai_policies (key, name, rules, system_prompt, escalation_keywords, updated_by) VALUES
('default', 'Default AI Assistant', '{}', 
'You are a helpful assistant for Urban Express delivery service. Answer questions about orders, delivery, and payments. Escalate sensitive topics to human agents.',
ARRAY['password', 'refund', 'complaint', 'manager'], (SELECT id FROM users WHERE role = 'admin' LIMIT 1));

-- Create sample branch
INSERT INTO branches (name, code, address, location, phone) VALUES
('Main Branch', 'MAIN', 'King Fahd Road, Riyadh', POINT(46.6753, 24.6877), '+966501234567');

-- Create admin user (update with your actual data)
-- INSERT INTO users (role, full_name, whatsapp_number, password_hash, status) VALUES
-- ('admin', 'System Administrator', '0501234567', 'hashed_password_here', 'active');

-- Comment: Remember to create your first admin user and set proper password hash
-- You can do this through Supabase dashboard or using proper authentication flow