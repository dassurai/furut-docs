-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.account_audit_logs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL,
  event text NOT NULL,
  actor_id uuid,
  metadata jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT account_audit_logs_pkey PRIMARY KEY (id),
  CONSTRAINT account_audit_logs_account_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id),
  CONSTRAINT account_audit_logs_actor_fkey FOREIGN KEY (actor_id) REFERENCES public.users(id)
);
CREATE TABLE public.account_business_profiles (
  account_id uuid NOT NULL,
  legal_name text,
  registration_number text,
  tax_id text,
  support_email text,
  support_phone text,
  registered_address_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT account_business_profiles_pkey PRIMARY KEY (account_id),
  CONSTRAINT account_business_profiles_account_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id)
);
CREATE TABLE public.account_kyc_documents (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL,
  document_type text NOT NULL,
  document_url text NOT NULL,
  verification_status text NOT NULL DEFAULT 'PENDING'::text CHECK (verification_status = ANY (ARRAY['PENDING'::text, 'VERIFIED'::text, 'REJECTED'::text])),
  uploaded_at timestamp with time zone DEFAULT now(),
  verified_at timestamp with time zone,
  rejected_reason text,
  verified_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT account_kyc_documents_pkey PRIMARY KEY (id),
  CONSTRAINT account_kyc_documents_account_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id),
  CONSTRAINT account_kyc_documents_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.users(id)
);
CREATE TABLE public.account_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['OWNER'::text, 'MEMBER'::text])),
  status text NOT NULL DEFAULT 'ACTIVE'::text CHECK (status = ANY (ARRAY['INVITED'::text, 'ACTIVE'::text, 'SUSPENDED'::text])),
  joined_at timestamp with time zone DEFAULT now(),
  CONSTRAINT account_members_pkey PRIMARY KEY (id),
  CONSTRAINT account_members_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id),
  CONSTRAINT account_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.account_partners (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  host_account_id uuid NOT NULL,
  partner_account_id uuid NOT NULL,
  commission_rate numeric NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'ACTIVE'::text CHECK (status = ANY (ARRAY['ACTIVE'::text, 'SUSPENDED'::text, 'TERMINATED'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT account_partners_pkey PRIMARY KEY (id),
  CONSTRAINT account_partners_host_fkey FOREIGN KEY (host_account_id) REFERENCES public.accounts(id),
  CONSTRAINT account_partners_partner_fkey FOREIGN KEY (partner_account_id) REFERENCES public.accounts(id)
);
CREATE TABLE public.account_payout_profiles (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL,
  account_holder_name text NOT NULL,
  bank_name text NOT NULL,
  account_number text NOT NULL,
  ifsc_code text NOT NULL,
  currency text NOT NULL DEFAULT 'INR'::text,
  is_active boolean NOT NULL DEFAULT true,
  verification_status text NOT NULL DEFAULT 'PENDING'::text CHECK (verification_status = ANY (ARRAY['PENDING'::text, 'VERIFIED'::text, 'REJECTED'::text])),
  created_at timestamp with time zone DEFAULT now(),
  verified_at timestamp with time zone,
  CONSTRAINT account_payout_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT account_payout_profiles_account_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id)
);
CREATE TABLE public.account_subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL,
  plan_id uuid NOT NULL,
  billing_cycle text NOT NULL DEFAULT 'MONTHLY'::text CHECK (billing_cycle = ANY (ARRAY['MONTHLY'::text, 'YEARLY'::text])),
  status text NOT NULL DEFAULT 'ACTIVE'::text CHECK (status = ANY (ARRAY['ACTIVE'::text, 'PAST_DUE'::text, 'CANCELLED'::text, 'EXPIRED'::text])),
  started_at timestamp with time zone DEFAULT now(),
  expires_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT account_subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT account_subscriptions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id),
  CONSTRAINT account_subscriptions_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id)
);
CREATE TABLE public.accounts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'::text),
  type text NOT NULL CHECK (type = ANY (ARRAY['INDIVIDUAL'::text, 'BUSINESS'::text, 'AGENCY'::text])),
  status text NOT NULL DEFAULT 'PENDING_COMPLIENCE'::text CHECK (status = ANY (ARRAY['PENDING_COMPLIENCE'::text, 'ACTIVE'::text, 'SUSPENDED'::text, 'CLOSED'::text])),
  country text NOT NULL DEFAULT 'India'::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT accounts_pkey PRIMARY KEY (id)
);
CREATE TABLE public.addresses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  country text NOT NULL,
  state text NOT NULL,
  district text,
  city text,
  locality text,
  postal_code text,
  line1 text,
  line2 text,
  latitude numeric,
  longitude numeric,
  created_at timestamp with time zone DEFAULT now(),
  location USER-DEFINED,
  created_by uuid,
  g_place_id text,
  google_place_types ARRAY,
  label text,
  CONSTRAINT addresses_pkey PRIMARY KEY (id),
  CONSTRAINT addresses_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id)
);
CREATE TABLE public.amenity_catalog (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  category text,
  icon text,
  applies_to text,
  CONSTRAINT amenity_catalog_pkey PRIMARY KEY (id)
);
CREATE TABLE public.cancellation_policies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  name text NOT NULL,
  policy_type text NOT NULL CHECK (policy_type = ANY (ARRAY['FLEXI'::text, 'MODERATE'::text, 'STRICT'::text, 'CUSTOM'::text])),
  full_refund_days integer NOT NULL,
  partial_refund_start integer,
  partial_refund_end integer,
  partial_refund_percent integer,
  advance_percent integer NOT NULL DEFAULT 30,
  advance_non_refundable boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT cancellation_policies_pkey PRIMARY KEY (id),
  CONSTRAINT cancellation_policies_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id)
);
CREATE TABLE public.entity_rules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  entity_type text NOT NULL CHECK (entity_type = ANY (ARRAY['PROPERTY'::text, 'UNIT'::text, 'EXPERIENCE'::text])),
  entity_id uuid NOT NULL,
  rule_id uuid NOT NULL,
  is_enabled boolean DEFAULT true,
  value_override jsonb,
  custom_text text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT entity_rules_pkey PRIMARY KEY (id),
  CONSTRAINT fk_entity_rule_rule FOREIGN KEY (rule_id) REFERENCES public.rules(id)
);
CREATE TABLE public.experience_properties (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  experience_id uuid NOT NULL,
  property_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT experience_properties_pkey PRIMARY KEY (id),
  CONSTRAINT fk_exp_prop_exp FOREIGN KEY (experience_id) REFERENCES public.experiences(id),
  CONSTRAINT fk_exp_prop_property FOREIGN KEY (property_id) REFERENCES public.properties(id)
);
CREATE TABLE public.experience_units (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  experience_id uuid NOT NULL,
  unit_id uuid NOT NULL,
  role text CHECK (role = ANY (ARRAY['VENUE'::text, 'STAY'::text, 'SUPPORT'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT experience_units_pkey PRIMARY KEY (id),
  CONSTRAINT fk_exp_unit_exp FOREIGN KEY (experience_id) REFERENCES public.experiences(id),
  CONSTRAINT fk_exp_unit_unit FOREIGN KEY (unit_id) REFERENCES public.property_units(id)
);
CREATE TABLE public.experiences (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  host_account_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  duration_minutes integer,
  experience_type text,
  status text DEFAULT 'DRAFT'::text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT experiences_pkey PRIMARY KEY (id),
  CONSTRAINT fk_experience_host FOREIGN KEY (host_account_id) REFERENCES public.accounts(id)
);
CREATE TABLE public.facility_catalog (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  icon text,
  category text,
  is_popular boolean DEFAULT false,
  sort_order integer DEFAULT 0,
  CONSTRAINT facility_catalog_pkey PRIMARY KEY (id)
);
CREATE TABLE public.media_assets (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL,
  url text NOT NULL,
  media_type text NOT NULL CHECK (media_type = ANY (ARRAY['IMAGE'::text, 'VIDEO'::text, 'DOCUMENT'::text])),
  size_bytes bigint,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT media_assets_pkey PRIMARY KEY (id),
  CONSTRAINT media_assets_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id)
);
CREATE TABLE public.media_links (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  media_id uuid NOT NULL,
  entity_type text NOT NULL CHECK (entity_type = ANY (ARRAY['PROPERTY'::text, 'UNIT'::text, 'ADDON'::text, 'EXPERIENCE'::text, 'FACILITY'::text])),
  entity_id uuid NOT NULL,
  sort_order integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT media_links_pkey PRIMARY KEY (id),
  CONSTRAINT media_links_media_id_fkey FOREIGN KEY (media_id) REFERENCES public.media_assets(id)
);
CREATE TABLE public.plan_limits (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  plan_id uuid NOT NULL,
  feature_key text NOT NULL,
  feature_value text NOT NULL,
  CONSTRAINT plan_limits_pkey PRIMARY KEY (id),
  CONSTRAINT plan_limits_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.subscription_plans(id)
);
CREATE TABLE public.properties (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  account_id uuid NOT NULL,
  address_id uuid NOT NULL,
  name text NOT NULL,
  slug text NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'::text),
  google_place_types ARRAY DEFAULT '{}'::text[],
  status text NOT NULL DEFAULT 'DRAFT'::text CHECK (status = ANY (ARRAY['DRAFT'::text, 'VERIFICATION_PENDING'::text, 'PUBLISHED'::text, 'SUSPENDED'::text, 'DELETED'::text])),
  description text,
  location USER-DEFINED,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  google_place_id text,
  has_google_place boolean DEFAULT false,
  created_by uuid,
  listing_source text CHECK (listing_source = ANY (ARRAY['HOST'::text, 'PARTNER'::text, 'ADMIN'::text])),
  ownership_status text DEFAULT 'OWNED'::text CHECK (ownership_status = ANY (ARRAY['OWNED'::text, 'CLAIM_REQUESTED'::text, 'UNVERIFIED'::text])),
  creation_step smallint DEFAULT 0 CHECK (creation_step >= 0 AND creation_step <= 6),
  canonical_property_id uuid,
  deleted_at timestamp with time zone,
  is_google_business boolean DEFAULT false,
  metadata jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT properties_pkey PRIMARY KEY (id),
  CONSTRAINT properties_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id),
  CONSTRAINT properties_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id),
  CONSTRAINT properties_address_id_fkey FOREIGN KEY (address_id) REFERENCES public.addresses(id),
  CONSTRAINT properties_canonical_fkey FOREIGN KEY (canonical_property_id) REFERENCES public.properties(id)
);
CREATE TABLE public.property_addons (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  name text NOT NULL,
  description text,
  addon_type text NOT NULL CHECK (addon_type = ANY (ARRAY['SERVICE'::text, 'EQUIPMENT'::text, 'TRANSPORT'::text])),
  pricing_type text NOT NULL CHECK (pricing_type = ANY (ARRAY['PER_PERSON'::text, 'PER_UNIT'::text, 'QUANTITY'::text])),
  status text NOT NULL DEFAULT 'DRAFT'::text CHECK (status = ANY (ARRAY['DRAFT'::text, 'PUBLISHED'::text, 'SUSPENDED'::text])),
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT property_addons_pkey PRIMARY KEY (id),
  CONSTRAINT property_addons_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id)
);
CREATE TABLE public.property_claims (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid,
  user_id uuid,
  status text CHECK (status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text])),
  created_at timestamp with time zone DEFAULT now(),
  resolved_at timestamp with time zone,
  resolved_by uuid,
  CONSTRAINT property_claims_pkey PRIMARY KEY (id),
  CONSTRAINT property_claims_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id)
);
CREATE TABLE public.property_facilities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  facility_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT property_facilities_pkey PRIMARY KEY (id),
  CONSTRAINT property_facilities_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id),
  CONSTRAINT property_facilities_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES public.facility_catalog(id)
);
CREATE TABLE public.property_google_data (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid,
  google_place_id text NOT NULL,
  name text,
  formatted_address text,
  latitude double precision,
  longitude double precision,
  rating numeric,
  user_ratings_total integer,
  types ARRAY,
  raw jsonb,
  last_synced_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT property_google_data_pkey PRIMARY KEY (id),
  CONSTRAINT property_google_data_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id)
);
CREATE TABLE public.property_members (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['HOST'::text, 'CO_HOST'::text, 'STEWARD'::text])),
  status text NOT NULL DEFAULT 'ACTIVE'::text CHECK (status = ANY (ARRAY['INVITED'::text, 'ACTIVE'::text, 'SUSPENDED'::text])),
  joined_at timestamp with time zone DEFAULT now(),
  CONSTRAINT property_members_pkey PRIMARY KEY (id),
  CONSTRAINT property_members_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id),
  CONSTRAINT property_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.property_seasons (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  season text NOT NULL,
  highlight text,
  created_at timestamp with time zone DEFAULT now(),
  tags ARRAY,
  notes text,
  image text,
  CONSTRAINT property_seasons_pkey PRIMARY KEY (id),
  CONSTRAINT property_seasons_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id)
);
CREATE TABLE public.property_terrains (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  terrain_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT property_terrains_pkey PRIMARY KEY (id),
  CONSTRAINT property_terrains_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id),
  CONSTRAINT property_terrains_terrain_id_fkey FOREIGN KEY (terrain_id) REFERENCES public.terrain_catalog(id)
);
CREATE TABLE public.property_transfers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  from_account_id uuid NOT NULL,
  to_account_id uuid NOT NULL,
  initiated_by uuid NOT NULL,
  accepted_by uuid,
  status text NOT NULL CHECK (status = ANY (ARRAY['INITIATED'::text, 'APPROVED'::text, 'COMPLETED'::text, 'CANCELLED'::text])),
  reason text,
  created_at timestamp with time zone DEFAULT now(),
  completed_at timestamp with time zone,
  CONSTRAINT property_transfers_pkey PRIMARY KEY (id),
  CONSTRAINT property_transfers_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id),
  CONSTRAINT property_transfers_from_account_id_fkey FOREIGN KEY (from_account_id) REFERENCES public.accounts(id),
  CONSTRAINT property_transfers_to_account_id_fkey FOREIGN KEY (to_account_id) REFERENCES public.accounts(id),
  CONSTRAINT property_transfers_initiated_by_fkey FOREIGN KEY (initiated_by) REFERENCES public.users(id),
  CONSTRAINT property_transfers_accepted_by_fkey FOREIGN KEY (accepted_by) REFERENCES public.users(id)
);
CREATE TABLE public.property_transport_hubs (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  hub_type text NOT NULL CHECK (hub_type = ANY (ARRAY['AIRPORT'::text, 'RAILWAY_STATION'::text, 'BUS_STATION'::text, 'PORT'::text, 'TAXI_STAND'::text])),
  name text NOT NULL,
  distance_km numeric,
  travel_time_minutes integer,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT property_transport_hubs_pkey PRIMARY KEY (id),
  CONSTRAINT property_transport_hubs_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id)
);
CREATE TABLE public.property_units (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  name text NOT NULL,
  unit_count integer,
  description text,
  status text NOT NULL DEFAULT 'ACTIVE'::text CHECK (status = ANY (ARRAY['ACTIVE'::text, 'INACTIVE'::text])),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  unit_type_id uuid NOT NULL CHECK (unit_type_id IS NOT NULL),
  is_sleep_enabled boolean DEFAULT true,
  is_bookable boolean DEFAULT true,
  CONSTRAINT property_units_pkey PRIMARY KEY (id),
  CONSTRAINT property_units_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id),
  CONSTRAINT property_units_unit_type_fkey FOREIGN KEY (unit_type_id) REFERENCES public.unit_types(id)
);
CREATE TABLE public.property_verifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  property_id uuid NOT NULL,
  verification_status text NOT NULL CHECK (verification_status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text])),
  verified_by uuid,
  notes text,
  verified_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT property_verifications_pkey PRIMARY KEY (id),
  CONSTRAINT property_verifications_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id),
  CONSTRAINT property_verifications_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES public.users(id)
);
CREATE TABLE public.rule_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT rule_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.rule_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  applies_to text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT rule_templates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.rules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  category_id uuid NOT NULL,
  key text NOT NULL UNIQUE,
  label text NOT NULL,
  type text NOT NULL,
  default_value jsonb,
  description text,
  is_locked boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT rules_pkey PRIMARY KEY (id),
  CONSTRAINT fk_rule_category FOREIGN KEY (category_id) REFERENCES public.rule_categories(id)
);
CREATE TABLE public.subscription_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text,
  monthly_price numeric DEFAULT 0,
  yearly_price numeric DEFAULT 0,
  currency text DEFAULT 'INR'::text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT subscription_plans_pkey PRIMARY KEY (id)
);
CREATE TABLE public.template_rules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  template_id uuid NOT NULL,
  rule_id uuid NOT NULL,
  is_enabled boolean DEFAULT true,
  default_value jsonb,
  custom_text text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT template_rules_pkey PRIMARY KEY (id),
  CONSTRAINT fk_template FOREIGN KEY (template_id) REFERENCES public.rule_templates(id),
  CONSTRAINT fk_template_rule FOREIGN KEY (rule_id) REFERENCES public.rules(id)
);
CREATE TABLE public.terrain_catalog (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text,
  icon text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT terrain_catalog_pkey PRIMARY KEY (id)
);
CREATE TABLE public.unit_amenities (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  unit_id uuid NOT NULL,
  amenity_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_amenities_pkey PRIMARY KEY (id),
  CONSTRAINT unit_amenities_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.property_units(id),
  CONSTRAINT unit_amenities_amenity_id_fkey FOREIGN KEY (amenity_id) REFERENCES public.amenity_catalog(id)
);
CREATE TABLE public.unit_availability_exceptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  unit_id uuid NOT NULL,
  date date NOT NULL,
  open_time time without time zone,
  close_time time without time zone,
  is_closed boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_availability_exceptions_pkey PRIMARY KEY (id),
  CONSTRAINT unit_availability_exceptions_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.property_units(id)
);
CREATE TABLE public.unit_availability_schedules (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  unit_id uuid NOT NULL,
  day_of_week integer NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
  open_time time without time zone NOT NULL,
  close_time time without time zone NOT NULL,
  is_closed boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_availability_schedules_pkey PRIMARY KEY (id),
  CONSTRAINT unit_availability_schedules_unit_fkey FOREIGN KEY (unit_id) REFERENCES public.property_units(id)
);
CREATE TABLE public.unit_cancellation_policies (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  unit_id uuid NOT NULL,
  policy_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_cancellation_policies_pkey PRIMARY KEY (id),
  CONSTRAINT unit_cancellation_policies_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.property_units(id),
  CONSTRAINT unit_cancellation_policies_policy_id_fkey FOREIGN KEY (policy_id) REFERENCES public.cancellation_policies(id)
);
CREATE TABLE public.unit_categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  image_url text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.unit_context (
  unit_id uuid NOT NULL,
  primary_intent text CHECK (primary_intent = ANY (ARRAY['stay'::text, 'event'::text, 'food'::text, 'work'::text, 'experience'::text])),
  usage_mode text CHECK (usage_mode = ANY (ARRAY['overnight'::text, 'hourly'::text, 'full_day'::text, 'multi_day'::text])),
  space_shape text CHECK (space_shape = ANY (ARRAY['atomic'::text, 'segmented'::text, 'distributed'::text, 'open'::text])),
  sleep_distribution text CHECK (sleep_distribution = ANY (ARRAY['none'::text, 'single_point'::text, 'multi_point'::text, 'shared_pool'::text])),
  bathroom_distribution text CHECK (bathroom_distribution = ANY (ARRAY['none'::text, 'single_private'::text, 'multiple_private'::text, 'shared_block'::text, 'external_basic'::text])),
  kitchen_model text CHECK (kitchen_model = ANY (ARRAY['none'::text, 'private'::text, 'shared'::text])),
  access_model text CHECK (access_model = ANY (ARRAY['bookable'::text, 'ticketed'::text, 'open_access'::text])),
  availability_model text CHECK (availability_model = ANY (ARRAY['always_open'::text, 'time_slot'::text, 'scheduled'::text])),
  privacy_model text CHECK (privacy_model = ANY (ARRAY['private'::text, 'semi_private'::text, 'shared'::text, 'open'::text])),
  experience_type text CHECK (experience_type = ANY (ARRAY['standard'::text, 'homely'::text, 'experiential'::text, 'raw'::text])),
  is_composable boolean DEFAULT false,
  is_primary_unit boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_context_pkey PRIMARY KEY (unit_id),
  CONSTRAINT unit_context_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.property_units(id)
);
CREATE TABLE public.unit_food_options (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  unit_id uuid NOT NULL,
  meal_types ARRAY NOT NULL,
  is_included boolean NOT NULL DEFAULT true,
  serving_types ARRAY,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_food_options_pkey PRIMARY KEY (id),
  CONSTRAINT unit_food_options_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.property_units(id)
);
CREATE TABLE public.unit_pricing_components (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  pricing_plan_id uuid NOT NULL,
  component_type text NOT NULL CHECK (component_type = ANY (ARRAY['BASE'::text, 'EXTRA_GUEST'::text, 'ADULT'::text, 'CHILD'::text, 'SLOT'::text, 'LONG_STAY_DISCOUNT'::text])),
  label text,
  price numeric NOT NULL,
  metadata jsonb,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_pricing_components_pkey PRIMARY KEY (id),
  CONSTRAINT fk_pricing_plan FOREIGN KEY (pricing_plan_id) REFERENCES public.unit_pricing_plans(id)
);
CREATE TABLE public.unit_pricing_plans (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  unit_id uuid NOT NULL,
  name text NOT NULL,
  pricing_model text NOT NULL CHECK (pricing_model = ANY (ARRAY['PER_NIGHT'::text, 'PER_PERSON'::text, 'PER_EVENT'::text, 'PER_HOUR'::text, 'HALF_DAY'::text, 'FULL_DAY'::text])),
  currency text NOT NULL DEFAULT 'INR'::text,
  is_default boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  start_date date,
  end_date date,
  created_at timestamp with time zone DEFAULT now(),
  is_food_included boolean NOT NULL DEFAULT false,
  pricing_behavior text,
  CONSTRAINT unit_pricing_plans_pkey PRIMARY KEY (id),
  CONSTRAINT unit_pricing_plans_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.property_units(id)
);
CREATE TABLE public.unit_space_configs (
  unit_id uuid NOT NULL,
  opens_at time without time zone,
  closes_at time without time zone,
  min_hours integer DEFAULT 1,
  max_capacity integer,
  created_at timestamp with time zone DEFAULT now(),
  usage_type text,
  CONSTRAINT unit_space_configs_pkey PRIMARY KEY (unit_id),
  CONSTRAINT fk_unit_space FOREIGN KEY (unit_id) REFERENCES public.property_units(id)
);
CREATE TABLE public.unit_stay_configs (
  unit_id uuid NOT NULL,
  check_in_time time without time zone,
  check_out_time time without time zone,
  min_nights integer DEFAULT 1,
  max_nights integer,
  max_guests integer,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_stay_configs_pkey PRIMARY KEY (unit_id),
  CONSTRAINT fk_unit_stay FOREIGN KEY (unit_id) REFERENCES public.property_units(id)
);
CREATE TABLE public.unit_type_catalog (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  category_id uuid NOT NULL,
  key text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  image_url text,
  booking_mode text NOT NULL CHECK (booking_mode = ANY (ARRAY['PER_NIGHT'::text, 'PER_PERSON'::text, 'PER_EVENT'::text, 'PER_HOUR'::text, 'HALF_DAY'::text, 'FULL_DAY'::text])),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT unit_type_catalog_pkey PRIMARY KEY (id),
  CONSTRAINT unit_type_catalog_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.unit_categories(id)
);
CREATE TABLE public.unit_types (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  label text NOT NULL,
  description text,
  created_at timestamp with time zone DEFAULT now(),
  default_intent text,
  default_space_shape text,
  default_sleep_distribution text,
  CONSTRAINT unit_types_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_profiles (
  user_id uuid NOT NULL,
  full_name text NOT NULL,
  about text,
  languages ARRAY,
  alternative_phone text,
  user_type ARRAY,
  app_source text,
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  avatar character varying,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  firebase_uid text NOT NULL UNIQUE,
  email text NOT NULL UNIQUE CHECK (POSITION(('@'::text) IN (email)) > 1),
  phone text NOT NULL UNIQUE,
  phone_verified boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);