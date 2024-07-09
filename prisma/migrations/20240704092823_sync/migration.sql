/*
  Warnings:

  - You are about to drop the column `createdAt` on the `role` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `role` table. All the data in the column will be lost.
  - You are about to drop the column `createdAt` on the `workspace` table. All the data in the column will be lost.
  - You are about to drop the column `updatedAt` on the `workspace` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[user_id]` on the table `workspace` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `slug` to the `role` table without a default value. This is not possible if the table is not empty.
  - Added the required column `type` to the `role` table without a default value. This is not possible if the table is not empty.
  - Added the required column `slug` to the `user` table without a default value. This is not possible if the table is not empty.
  - Added the required column `slug` to the `workspace` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "TeamChallengeType" AS ENUM ('meetings', 'quotation_qty', 'quotation_value', 'sales_order_qty', 'sales_order_value');

-- CreateEnum
CREATE TYPE "pricing_plan_interval" AS ENUM ('day', 'week', 'month', 'year');

-- CreateEnum
CREATE TYPE "pricing_type" AS ENUM ('one_time', 'recurring');

-- CreateEnum
CREATE TYPE "subscription_status" AS ENUM ('trialing', 'active', 'canceled', 'incomplete', 'incomplete_expired', 'past_due', 'unpaid');

-- CreateEnum
CREATE TYPE "ContactStatus" AS ENUM ('Active', 'Inactive');

-- CreateEnum
CREATE TYPE "MarketplaceType" AS ENUM ('shopee', 'lazada', 'amazon');

-- CreateEnum
CREATE TYPE "MarketplaceAppType" AS ENUM ('general', 'iam');

-- CreateEnum
CREATE TYPE "RoleType" AS ENUM ('warehouse_staff', 'driver', 'salesperson', 'admin', 'procurement_officer', 'sales_manager', 'finance_manager', 'accounts');

-- CreateEnum
CREATE TYPE "ShippingMethod" AS ENUM ('air_freight', 'air_freight_courier', 'trucking');

-- CreateEnum
CREATE TYPE "QuotationType" AS ENUM ('standard', 'ironmongery');

-- CreateEnum
CREATE TYPE "Currency" AS ENUM ('ARS', 'AUD', 'BHD', 'BBD', 'BRL', 'GBP', 'CAD', 'XAF', 'CLP', 'CNY', 'CYP', 'CZK', 'DKK', 'XCD', 'EGP', 'EEK', 'EUR', 'HKD', 'HUF', 'ISK', 'INR', 'IDR', 'ILS', 'JMD', 'JPY', 'JOD', 'KES', 'LVL', 'LBP', 'LTL', 'MYR', 'MXN', 'MAD', 'NAD', 'NPR', 'NZD', 'NOK', 'OMR', 'PKR', 'PAB', 'PHP', 'PLN', 'QAR', 'RON', 'RUB', 'SAR', 'SGD', 'ZAR', 'KRW', 'LKR', 'SEK', 'CHF', 'THB', 'TRY', 'AED', 'USD', 'VEF', 'XOF');

-- AlterTable
ALTER TABLE "role" DROP COLUMN "createdAt",
DROP COLUMN "updatedAt",
ADD COLUMN     "authentication_success_redirect_route" TEXT,
ADD COLUMN     "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "created_by" UUID,
ADD COLUMN     "slug" TEXT NOT NULL,
ADD COLUMN     "status" TEXT,
ADD COLUMN     "subtitle" TEXT,
ADD COLUMN     "type" "RoleType" NOT NULL,
ADD COLUMN     "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updated_by" UUID,
ADD COLUMN     "valid_subdirectory_pathnames" TEXT[],
ADD COLUMN     "workspace_id" INTEGER;

-- AlterTable
ALTER TABLE "user" ADD COLUMN     "avatar_alt" TEXT,
ADD COLUMN     "avatar_src" TEXT,
ADD COLUMN     "billing_address" JSONB,
ADD COLUMN     "currency_factor_id" "Currency",
ADD COLUMN     "department" TEXT,
ADD COLUMN     "description" TEXT,
ADD COLUMN     "email" TEXT,
ADD COLUMN     "first_name" TEXT,
ADD COLUMN     "full_name" TEXT,
ADD COLUMN     "last_name" TEXT,
ADD COLUMN     "mobile" TEXT,
ADD COLUMN     "module_config" JSONB,
ADD COLUMN     "payment_method" JSONB,
ADD COLUMN     "slug" TEXT NOT NULL,
ADD COLUMN     "status" TEXT,
ADD COLUMN     "subtitle" TEXT;

-- AlterTable
ALTER TABLE "workspace" DROP COLUMN "createdAt",
DROP COLUMN "updatedAt",
ADD COLUMN     "avatar_alt" TEXT,
ADD COLUMN     "avatar_src" TEXT,
ADD COLUMN     "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "created_by" UUID,
ADD COLUMN     "custom_domain" TEXT,
ADD COLUMN     "description" TEXT,
ADD COLUMN     "favicon_ico_alt" TEXT,
ADD COLUMN     "favicon_ico_src" TEXT,
ADD COLUMN     "is_active" BOOLEAN DEFAULT true,
ADD COLUMN     "logo_svg_alt" TEXT,
ADD COLUMN     "logo_svg_src" TEXT,
ADD COLUMN     "primary_color" TEXT,
ADD COLUMN     "secondary_color" TEXT,
ADD COLUMN     "slug" TEXT NOT NULL,
ADD COLUMN     "subtitle" TEXT,
ADD COLUMN     "support_email" TEXT,
ADD COLUMN     "support_mobile" TEXT,
ADD COLUMN     "tier_id" INTEGER,
ADD COLUMN     "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updated_by" UUID,
ADD COLUMN     "user_id" UUID;

-- CreateTable
CREATE TABLE "customer" (
    "id" UUID NOT NULL,
    "stripe_customer_id" TEXT,

    CONSTRAINT "customer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "plan" (
    "id" TEXT NOT NULL,
    "active" BOOLEAN,
    "name" TEXT,
    "description" TEXT,
    "image" TEXT,
    "metadata" JSONB,

    CONSTRAINT "plan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "price" (
    "id" TEXT NOT NULL,
    "plan_id" TEXT,
    "active" BOOLEAN,
    "unit_amount" BIGINT,
    "currency" TEXT,
    "type" "pricing_type",
    "interval" "pricing_plan_interval",
    "interval_count" INTEGER,
    "trial_period_days" INTEGER,
    "metadata" JSONB,

    CONSTRAINT "price_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subscription" (
    "id" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "status" "subscription_status",
    "metadata" JSONB,
    "price_id" TEXT,
    "quantity" INTEGER,
    "cancel_at_period_end" BOOLEAN,
    "created" TIMESTAMPTZ(6) NOT NULL DEFAULT timezone('utc'::text, now()),
    "current_period_start" TIMESTAMPTZ(6) NOT NULL DEFAULT timezone('utc'::text, now()),
    "current_period_end" TIMESTAMPTZ(6) NOT NULL DEFAULT timezone('utc'::text, now()),
    "ended_at" TIMESTAMPTZ(6) DEFAULT timezone('utc'::text, now()),
    "cancel_at" TIMESTAMPTZ(6) DEFAULT timezone('utc'::text, now()),
    "canceled_at" TIMESTAMPTZ(6) DEFAULT timezone('utc'::text, now()),
    "trial_start" TIMESTAMPTZ(6) DEFAULT timezone('utc'::text, now()),
    "trial_end" TIMESTAMPTZ(6) DEFAULT timezone('utc'::text, now()),

    CONSTRAINT "subscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "team_challenge" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "type" "TeamChallengeType" NOT NULL,
    "start_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "end_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "recurring_freq" DOUBLE PRECISION,
    "description" TEXT,
    "target_point" INTEGER DEFAULT 0,
    "start_point" INTEGER DEFAULT 0,
    "min_qty" INTEGER DEFAULT 0,
    "min_total_value" INTEGER DEFAULT 0,
    "min_single_value" INTEGER DEFAULT 0,
    "max_points" INTEGER DEFAULT 0,
    "penalty_per_tier" INTEGER DEFAULT 0,
    "tier_size" INTEGER DEFAULT 0,
    "brand_id" INTEGER,
    "workspace_id" INTEGER,

    CONSTRAINT "team_challenge_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "team_challenge_user" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "points" INTEGER NOT NULL DEFAULT 0,
    "progress" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "last_change_points" INTEGER NOT NULL DEFAULT 0,
    "last_change_progress" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "completed_at" TIMESTAMPTZ,
    "color" TEXT,
    "team_challenge_id" INTEGER NOT NULL,
    "user_id" UUID NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "team_challenge_user_pkey" PRIMARY KEY ("team_challenge_id","user_id")
);

-- CreateTable
CREATE TABLE "role_permission" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "role_id" INTEGER NOT NULL,
    "permission_id" INTEGER NOT NULL,

    CONSTRAINT "role_permission_pkey" PRIMARY KEY ("role_id","permission_id")
);

-- CreateTable
CREATE TABLE "permission" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,

    CONSTRAINT "permission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "avatar_src" TEXT,
    "avatar_alt" TEXT,
    "sku" TEXT,
    "barcode" TEXT,
    "hscode" TEXT,
    "serial_number" TEXT,
    "model_code" TEXT,
    "model_sub_code" TEXT,
    "expired_at" TIMESTAMPTZ,
    "country_of_supply" TEXT,
    "country_of_manufacture" TEXT,
    "country_of_origin" TEXT,
    "width_mm" INTEGER,
    "height_mm" INTEGER,
    "length_mm" INTEGER,
    "weight_kg" DOUBLE PRECISION,
    "color" TEXT,
    "supplier_cost_amount" DOUBLE PRECISION,
    "retail_price" DOUBLE PRECISION,
    "is_itemized_commission" BOOLEAN,
    "commission_rate" DOUBLE PRECISION,
    "commission" DOUBLE PRECISION,
    "is_commission_rate" BOOLEAN,
    "stock_count" INTEGER,
    "restock_count" INTEGER,
    "brand_id" INTEGER,
    "category_id" INTEGER,
    "is_package" BOOLEAN,
    "package" JSONB,
    "is_expired_package_email_sent" BOOLEAN,
    "workspace_id" INTEGER,

    CONSTRAINT "product_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "marketplace_product" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "type" "MarketplaceType" NOT NULL,
    "company_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "marketplace_product_id" TEXT NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "marketplace_product_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "marketplace_sales_order" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "type" "MarketplaceType" NOT NULL,
    "company_id" INTEGER NOT NULL,
    "sales_order_id" INTEGER NOT NULL,
    "marketplace_sales_order_id" TEXT NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "marketplace_sales_order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "marketplace_messaging" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "type" "MarketplaceType" NOT NULL,
    "unread_count" INTEGER NOT NULL DEFAULT 0,
    "account_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "marketplace_messaging_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_gallery_image" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "product_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "product_gallery_image_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_spec_image" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "product_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "product_spec_image_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "product_spec_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "product_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "product_spec_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "brand" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "code" TEXT,
    "discount_limit" DOUBLE PRECISION,
    "margin_limit" DOUBLE PRECISION,
    "coefficient_rate" DOUBLE PRECISION,
    "markup_rate" DOUBLE PRECISION,
    "margin_rate" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "additional_discount_rate" DOUBLE PRECISION,
    "company_discount_rate" DOUBLE PRECISION,
    "costing_rate" DOUBLE PRECISION,
    "is_roundup_to_nearest_dollar" BOOLEAN,
    "is_roundup_to_nearest_dollar_sales_person_cost" BOOLEAN,
    "company_id" INTEGER,
    "currency_factor_id" "Currency",
    "workspace_id" INTEGER,

    CONSTRAINT "brand_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "avatar_src" TEXT,
    "avatar_alt" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "start_at" TIMESTAMPTZ,
    "end_at" TIMESTAMPTZ,
    "blueprint3d" JSONB,
    "location_name" TEXT,
    "architects" TEXT,
    "interior_designer" TEXT,
    "no_of_units" INTEGER,
    "estimated_delivery_date" TIMESTAMPTZ(6),
    "project_category_id" INTEGER,
    "project_group_id" INTEGER,
    "company_id" INTEGER,
    "assignee_id" UUID,
    "contact_id" INTEGER,
    "workspace_id" INTEGER,

    CONSTRAINT "project_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "project_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "project_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_currency_factor" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "buy_rate" DOUBLE PRECISION NOT NULL,
    "project_id" INTEGER NOT NULL,
    "currency_factor_id" "Currency" NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "project_currency_factor_pkey" PRIMARY KEY ("project_id","currency_factor_id")
);

-- CreateTable
CREATE TABLE "project_brand" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "coefficient_rate" DOUBLE PRECISION,
    "markup_rate" DOUBLE PRECISION,
    "margin_rate" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "additional_discount_rate" DOUBLE PRECISION,
    "company_discount_rate" DOUBLE PRECISION,
    "handling_rate" DOUBLE PRECISION,
    "is_roundup_to_nearest_dollar" BOOLEAN,
    "project_id" INTEGER NOT NULL,
    "brand_id" INTEGER NOT NULL,
    "currency_factor_id" "Currency" NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "project_brand_pkey" PRIMARY KEY ("project_id","brand_id")
);

-- CreateTable
CREATE TABLE "project_category" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "workspace_id" INTEGER,

    CONSTRAINT "project_category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_group" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "workspace_id" INTEGER,

    CONSTRAINT "project_group_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_product" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "supplier_cost_amount" DOUBLE PRECISION,
    "coefficient_rate" DOUBLE PRECISION,
    "markup_rate" DOUBLE PRECISION,
    "margin_rate" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "additional_discount_rate" DOUBLE PRECISION,
    "company_discount_rate" DOUBLE PRECISION,
    "handling_rate" DOUBLE PRECISION,
    "is_roundup_to_nearest_dollar" BOOLEAN,
    "project_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "brand_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "project_product_pkey" PRIMARY KEY ("project_id","product_id")
);

-- CreateTable
CREATE TABLE "currency_factor" (
    "id" "Currency" NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "buy_rate" DOUBLE PRECISION NOT NULL,
    "sell_rate" DOUBLE PRECISION NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "currency_factor_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "category" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subcategory" TEXT,
    "description" TEXT,
    "workspace_id" INTEGER,

    CONSTRAINT "category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "quotation" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "type" "QuotationType" NOT NULL DEFAULT 'standard',
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "extra_contact_info" JSONB,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "counter" INTEGER,
    "version" INTEGER,
    "last_sent_email_hash" TEXT,
    "published_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "terms" TEXT,
    "payment_terms" TEXT,
    "currency_rate" DOUBLE PRECISION,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "discount" DOUBLE PRECISION,
    "is_discount_rate" BOOLEAN,
    "shipping" DOUBLE PRECISION,
    "tax_rate" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "project_contact_id" INTEGER,
    "contact_id" INTEGER,
    "order_id" INTEGER,
    "currency_factor_id" "Currency",
    "workspace_id" INTEGER,

    CONSTRAINT "quotation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "quotation_ironmongery_room" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "door_location" TEXT,
    "quantity" INTEGER,
    "width" INTEGER,
    "thickness" INTEGER,
    "height" INTEGER,
    "door" TEXT,
    "door_type" TEXT NOT NULL,
    "door_material" TEXT NOT NULL,
    "door_hardware" TEXT NOT NULL,
    "quotation_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "quotation_ironmongery_room_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "quotation_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "location_code" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "requested_discount_rate" DOUBLE PRECISION,
    "discount" JSONB,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "retail_price" DOUBLE PRECISION NOT NULL,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "total" DOUBLE PRECISION,
    "sales_person_cost" DOUBLE PRECISION,
    "quotation_id" INTEGER NOT NULL,
    "product_id" INTEGER,
    "room_id" INTEGER,
    "workspace_id" INTEGER,
    "product_details" JSONB,

    CONSTRAINT "quotation_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "quotation_attachment_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "quotation_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "quotation_attachment_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "workspace_id" INTEGER,

    CONSTRAINT "order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sales_order" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "extra_contact_info" JSONB,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "remarks" TEXT,
    "published_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "terms" TEXT,
    "payment_terms" TEXT,
    "currency_rate" DOUBLE PRECISION,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "discount" DOUBLE PRECISION,
    "is_discount_rate" BOOLEAN,
    "shipping" DOUBLE PRECISION,
    "tax_rate" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "performance_bond" DOUBLE PRECISION,
    "retention_fee" DOUBLE PRECISION,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "project_contact_id" INTEGER,
    "contact_id" INTEGER,
    "quotation_id" INTEGER,
    "currency_factor_id" "Currency",
    "workspace_id" INTEGER,

    CONSTRAINT "sales_order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sales_order_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "location_code" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "discount" JSONB,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "retail_price" DOUBLE PRECISION NOT NULL,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "total" DOUBLE PRECISION,
    "sales_person_cost" DOUBLE PRECISION,
    "sales_order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,
    "product_details" JSONB,

    CONSTRAINT "sales_order_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sales_order_attachment_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "sales_order_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "sales_order_attachment_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "marketplace_account" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "type" "MarketplaceType" NOT NULL,
    "company_id" INTEGER NOT NULL,
    "marketplace_account_id" TEXT NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "marketplace_account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_order" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "ship_via" TEXT,
    "ready_at" TIMESTAMPTZ,
    "shipped_at" TIMESTAMPTZ,
    "arrived_at" TIMESTAMPTZ,
    "completed_at" TIMESTAMPTZ,
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "extra_contact_info" JSONB,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "currency_rate" DOUBLE PRECISION,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "discount" DOUBLE PRECISION,
    "is_discount_rate" BOOLEAN,
    "shipping" DOUBLE PRECISION,
    "tax_rate" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "project_id" INTEGER,
    "assignee_id" UUID,
    "company_id" INTEGER,
    "project_contact_id" INTEGER,
    "contact_id" INTEGER,
    "warehouse_id" INTEGER,
    "currency_factor_id" "Currency",
    "workspace_id" INTEGER,

    CONSTRAINT "purchase_order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "purchase_order_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "shelving_location" TEXT,
    "row_number" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "workspace_id" INTEGER,
    "purchase_order_id" INTEGER NOT NULL,
    "product_id" INTEGER,
    "order_form_line_id" INTEGER,

    CONSTRAINT "purchase_order_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_order" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "delivery_at" TIMESTAMPTZ,
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "extra_contact_info" JSONB,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "published_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "terms" TEXT,
    "payment_terms" TEXT,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "shipping" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "driver_name" TEXT,
    "driver_contact" TEXT,
    "vehicle_number" TEXT,
    "delivered_on" TIMESTAMPTZ,
    "received_by" TEXT,
    "customer_contact" TEXT,
    "signature_url" TEXT,
    "assignee_id" UUID,
    "driver_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "contact_id" INTEGER,
    "sales_order_id" INTEGER,
    "loan_form_id" INTEGER,
    "goods_return_note_id" INTEGER,
    "goods_transfer_form_id" INTEGER,
    "workspace_id" INTEGER,

    CONSTRAINT "delivery_order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_order_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "location_code" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "delivered_quantity" INTEGER,
    "unit_price" DOUBLE PRECISION,
    "reason" TEXT,
    "remark" TEXT,
    "delivery_order_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "delivery_order_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_order_attachment_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "delivery_order_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "delivery_order_attachment_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_instruction" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "pick_up_at" TIMESTAMPTZ,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "delivery_order_id" INTEGER,
    "warehouse_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "delivery_instruction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "delivery_instruction_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "quantity" INTEGER NOT NULL,
    "packed_quantity" INTEGER,
    "note" TEXT,
    "delivery_instruction_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "delivery_instruction_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "payment_status" TEXT,
    "type" TEXT NOT NULL,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "shipping_method" "ShippingMethod",
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "extra_contact_info" JSONB,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "invoice_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "due_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "terms" TEXT,
    "payment_terms" TEXT,
    "currency_rate" DOUBLE PRECISION,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "shipping" DOUBLE PRECISION,
    "tax_rate" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "is_mutable" BOOLEAN DEFAULT true,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "contact_id" INTEGER,
    "sales_order_id" INTEGER,
    "currency_factor_id" "Currency",
    "workspace_id" INTEGER,

    CONSTRAINT "invoice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "location_code" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "unit_price" DOUBLE PRECISION,
    "subtotal" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "invoice_id" INTEGER NOT NULL,
    "product_id" INTEGER,
    "workspace_id" INTEGER,

    CONSTRAINT "invoice_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invoice_payment" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "amount" DOUBLE PRECISION NOT NULL,
    "currency" TEXT NOT NULL,
    "rate" DOUBLE PRECISION DEFAULT 1,
    "type" TEXT NOT NULL,
    "paid_at" TIMESTAMPTZ NOT NULL,
    "paid_to" TEXT NOT NULL,
    "note" TEXT,
    "invoice_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "invoice_payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_invoice" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "reference" TEXT,
    "due_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "currency_rate" DOUBLE PRECISION,
    "subtotal" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "contact_id" INTEGER,
    "currency_factor_id" "Currency",
    "workspace_id" INTEGER,

    CONSTRAINT "supplier_invoice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_invoice_attachment_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "supplier_invoice_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "supplier_invoice_attachment_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_invoice_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "supplier_invoice_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "purchase_order_line_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "supplier_invoice_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_invoice_payment" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "amount" DOUBLE PRECISION NOT NULL,
    "currency" TEXT NOT NULL,
    "rate" DOUBLE PRECISION DEFAULT 1,
    "type" TEXT NOT NULL,
    "paid_at" TIMESTAMPTZ NOT NULL,
    "paid_to" TEXT NOT NULL,
    "note" TEXT,
    "workspace_id" INTEGER,
    "supplier_invoice_id" INTEGER NOT NULL,

    CONSTRAINT "supplier_invoice_payment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "credit_note" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "published_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "shipping" DOUBLE PRECISION,
    "tax_rate" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "contact_id" INTEGER,
    "user_id" UUID,
    "invoice_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "credit_note_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "credit_note_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "location_code" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "credit_note_id" INTEGER NOT NULL,
    "product_id" INTEGER,
    "invoice_line_id" INTEGER,
    "workspace_id" INTEGER,

    CONSTRAINT "credit_note_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "debit_note" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "extra_contact_info" JSONB,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "published_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "terms" TEXT,
    "payment_terms" TEXT,
    "currency_rate" DOUBLE PRECISION,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "shipping" DOUBLE PRECISION,
    "tax_rate" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "contact_id" INTEGER,
    "supplier_invoice_id" INTEGER,
    "currency_factor_id" "Currency",
    "workspace_id" INTEGER,

    CONSTRAINT "debit_note_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "debit_note_attachment_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "workspace_id" INTEGER,
    "debit_note_id" INTEGER NOT NULL,

    CONSTRAINT "debit_note_attachment_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "debit_note_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "workspace_id" INTEGER,
    "debit_note_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,

    CONSTRAINT "debit_note_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "goods_return_note" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "extra_contact_info" JSONB,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "published_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "terms" TEXT,
    "payment_terms" TEXT,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "shipping" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "workspace_id" INTEGER,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "contact_id" INTEGER,
    "invoice_id" INTEGER,
    "warehouse_id" INTEGER,

    CONSTRAINT "goods_return_note_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "goods_return_note_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "note" TEXT,
    "location_code" TEXT,
    "quantity" INTEGER NOT NULL,
    "unit_price" DOUBLE PRECISION,
    "workspace_id" INTEGER,
    "goods_return_note_id" INTEGER NOT NULL,
    "invoice_line_id" INTEGER,
    "product_id" INTEGER NOT NULL,

    CONSTRAINT "goods_return_note_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loan_form" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "due_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "extra_contact_info" JSONB,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "published_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "terms" TEXT,
    "payment_terms" TEXT,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "shipping" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "workspace_id" INTEGER,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "contact_id" INTEGER,

    CONSTRAINT "loan_form_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "loan_form_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "shelving_location" TEXT,
    "row_number" TEXT,
    "discount_rate" DOUBLE PRECISION,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "workspace_id" INTEGER,
    "loan_form_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "warehouse_id" INTEGER NOT NULL,

    CONSTRAINT "loan_form_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "goods_transfer_form" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "transfer_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "workspace_id" INTEGER,
    "assignee_id" UUID,
    "contact_id" INTEGER,
    "source_warehouse_id" INTEGER,
    "target_warehouse_id" INTEGER,

    CONSTRAINT "goods_transfer_form_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "goods_transfer_form_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "quantity" INTEGER,
    "product_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,
    "goods_transfer_form_id" INTEGER NOT NULL,

    CONSTRAINT "goods_transfer_form_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "feedback" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "workspace_id" INTEGER,

    CONSTRAINT "feedback_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "company" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "type" TEXT,
    "avatar_src" TEXT,
    "avatar_alt" TEXT,
    "email" TEXT,
    "mobile" TEXT,
    "phone" TEXT,
    "fax" TEXT,
    "website" TEXT,
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "documents" TEXT,
    "workspace_id" INTEGER,

    CONSTRAINT "company_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "company_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "company_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "company_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "company_brand" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "company_id" INTEGER NOT NULL,
    "brand_id" INTEGER NOT NULL,
    "coefficient_rate" DOUBLE PRECISION,
    "markup_rate" DOUBLE PRECISION,
    "margin_rate" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "additional_discount_rate" DOUBLE PRECISION,
    "company_discount_rate" DOUBLE PRECISION,
    "handling_rate" DOUBLE PRECISION,
    "is_roundup_to_nearest_dollar" BOOLEAN,
    "workspace_id" INTEGER,

    CONSTRAINT "company_brand_pkey" PRIMARY KEY ("company_id","brand_id")
);

-- CreateTable
CREATE TABLE "contact" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" "ContactStatus",
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "avatar_src" TEXT,
    "avatar_alt" TEXT,
    "lead_status" TEXT,
    "first_name" TEXT,
    "last_name" TEXT,
    "full_name" TEXT,
    "salutation" TEXT,
    "email" TEXT,
    "mobile" TEXT,
    "phone" TEXT,
    "fax" TEXT,
    "website" TEXT,
    "shipping_address_line_1" TEXT,
    "shipping_address_line_2" TEXT,
    "shipping_address_postal_code" TEXT,
    "shipping_address_city" TEXT,
    "shipping_address_country" TEXT,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "is_billing_address_same_as_shipping_address" BOOLEAN,
    "workspace_id" INTEGER,
    "company_id" INTEGER,
    "assignee_id" UUID,

    CONSTRAINT "contact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contact_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "contact_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "contact_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "memo" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "title" TEXT,
    "content" TEXT,
    "priority" TEXT,
    "lat" TEXT,
    "lng" TEXT,
    "location" TEXT,
    "workspace_id" INTEGER,
    "contact_id" INTEGER,
    "company_id" INTEGER,
    "project_id" INTEGER,
    "user_id" UUID,
    "assignee_id" UUID,

    CONSTRAINT "memo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "todo" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "content" TEXT NOT NULL,
    "is_done" BOOLEAN DEFAULT false,
    "workspace_id" INTEGER,
    "contact_id" INTEGER,
    "company_id" INTEGER,

    CONSTRAINT "todo_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "warehouse" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "address_line_1" TEXT,
    "address_line_2" TEXT,
    "address_postal_code" TEXT,
    "address_city" TEXT,
    "address_country" TEXT,
    "workspace_id" INTEGER,

    CONSTRAINT "warehouse_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "warehouse_product" (
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "min_stock_balance" INTEGER,
    "warehouse_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "warehouse_product_pkey" PRIMARY KEY ("warehouse_id","product_id")
);

-- CreateTable
CREATE TABLE "warehouse_product_stock_alert" (
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "min_stock_balance" INTEGER,
    "warehouse_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "warehouse_product_stock_alert_pkey" PRIMARY KEY ("warehouse_id","product_id")
);

-- CreateTable
CREATE TABLE "inventory" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "in" INTEGER NOT NULL DEFAULT 0,
    "out" INTEGER NOT NULL DEFAULT 0,
    "ref_no" TEXT,
    "workspace_id" INTEGER,
    "warehouse_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "sales_order_line_id" INTEGER,
    "purchase_order_line_id" INTEGER,
    "loan_form_line_id" INTEGER,
    "goods_return_note_line_id" INTEGER,
    "goods_transfer_form_line_id" INTEGER,

    CONSTRAINT "inventory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reservation" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "in" INTEGER NOT NULL DEFAULT 0,
    "out" INTEGER NOT NULL DEFAULT 0,
    "workspace_id" INTEGER,
    "warehouse_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "order_form_line_id" INTEGER,
    "marketplace_sales_order_id" INTEGER,
    "purchase_order_line_id" INTEGER,
    "goods_transfer_form_line_id" INTEGER,

    CONSTRAINT "reservation_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "service" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "model_code" TEXT,
    "amount" DOUBLE PRECISION,
    "service_date" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "brand_id" INTEGER,
    "category_id" INTEGER,
    "workspace_id" INTEGER,
    "contact_id" INTEGER,

    CONSTRAINT "service_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_form" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "counter" INTEGER,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "due_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "project_id" INTEGER,
    "workspace_id" INTEGER,
    "assignee_id" UUID,
    "company_id" INTEGER,
    "sales_order_id" INTEGER,

    CONSTRAINT "order_form_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "order_form_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "note" TEXT,
    "quantity" INTEGER NOT NULL,
    "workspace_id" INTEGER,
    "order_form_id" INTEGER,
    "product_id" INTEGER,

    CONSTRAINT "order_form_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "progressive_claim" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "claim_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "billing_address_line_1" TEXT,
    "billing_address_line_2" TEXT,
    "billing_address_postal_code" TEXT,
    "billing_address_city" TEXT,
    "billing_address_country" TEXT,
    "external_notes" TEXT,
    "internal_notes" TEXT,
    "counter" INTEGER,
    "subtotal" DOUBLE PRECISION,
    "discount_rate" DOUBLE PRECISION,
    "shipping" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "tax_rate" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "workspace_id" INTEGER,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "project_group_id" INTEGER,
    "company_id" INTEGER,
    "contact_id" INTEGER,
    "user_id" UUID,

    CONSTRAINT "progressive_claim_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "progressive_claim_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "location_code" TEXT,
    "quantity" INTEGER NOT NULL,
    "approved_quantity" INTEGER DEFAULT 0,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "workspace_id" INTEGER,
    "progressive_claim_id" INTEGER NOT NULL,
    "sales_order_line_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,

    CONSTRAINT "progressive_claim_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "progressive_claim_extra_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "location_code" TEXT,
    "quantity" INTEGER NOT NULL,
    "approved_quantity" INTEGER DEFAULT 0,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "workspace_id" INTEGER,
    "sales_order_line_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,

    CONSTRAINT "progressive_claim_extra_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "progressive_claim_attachment_file" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "src" TEXT NOT NULL,
    "alt" TEXT,
    "name" TEXT,
    "size" INTEGER,
    "type" TEXT,
    "position" DOUBLE PRECISION,
    "workspace_id" INTEGER,
    "progressive_claim_id" INTEGER NOT NULL,

    CONSTRAINT "progressive_claim_attachment_file_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "receipt" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "cart_items" JSONB,
    "subtotal" DOUBLE PRECISION,
    "tax" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "payment_method" TEXT,
    "paid" DOUBLE PRECISION,
    "customer" JSONB,
    "src" TEXT,
    "workspace_id" INTEGER,

    CONSTRAINT "receipt_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "xero_token" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "token" TEXT NOT NULL,
    "user_id" UUID NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "xero_token_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "marketplace_token" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "refresh_token" TEXT NOT NULL,
    "access_token" TEXT NOT NULL,
    "expires_in" INTEGER NOT NULL,
    "type" "MarketplaceType" NOT NULL,
    "app_type" "MarketplaceAppType" NOT NULL DEFAULT 'general',
    "company_id" INTEGER NOT NULL,
    "workspace_id" INTEGER,
    "account_id" INTEGER NOT NULL,

    CONSTRAINT "marketplace_token_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dashboard_section_order" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "sales_tab_order" TEXT,
    "finance_tab_order" TEXT,
    "procurement_tab_order" TEXT,
    "user_id" UUID NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "dashboard_section_order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tier" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,

    CONSTRAINT "tier_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tier_feature" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "tier_id" INTEGER NOT NULL,
    "feature_id" INTEGER NOT NULL,

    CONSTRAINT "tier_feature_pkey" PRIMARY KEY ("id","tier_id","feature_id")
);

-- CreateTable
CREATE TABLE "feature" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,

    CONSTRAINT "feature_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "project_registration" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "status" TEXT,
    "developer_detail" TEXT,
    "project_id" INTEGER,
    "company_id" INTEGER,

    CONSTRAINT "project_registration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_discount_form" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "subtitle" TEXT,
    "description" TEXT,
    "discount_type" TEXT NOT NULL,
    "discount_rate" TEXT NOT NULL,
    "counter" INTEGER,
    "version" INTEGER,
    "last_sent_email_hash" TEXT,
    "published_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "submitted_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "assignee_id" UUID,
    "project_id" INTEGER,
    "company_id" INTEGER,
    "contact_id" INTEGER,
    "currency_factor_id" "Currency",
    "quotation_id" INTEGER,

    CONSTRAINT "supplier_discount_form_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "supplier_discount_form_line" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "status" TEXT,
    "position" INTEGER,
    "title" TEXT,
    "slug" TEXT,
    "subtitle" TEXT,
    "description" TEXT,
    "location_code" TEXT,
    "standard_discount_rate" DOUBLE PRECISION,
    "additional_discount_rate" DOUBLE PRECISION,
    "special_unit_rate" DOUBLE PRECISION,
    "requested_discount_rate" DOUBLE PRECISION,
    "requested_additional_discount_rate" DOUBLE PRECISION,
    "counter_discount_rate" DOUBLE PRECISION,
    "additional_counter_discount_rate" DOUBLE PRECISION,
    "requested_special_unit_rate" DOUBLE PRECISION,
    "counter_special_unit_rate" DOUBLE PRECISION,
    "quantity" INTEGER NOT NULL,
    "retail_price" DOUBLE PRECISION NOT NULL,
    "unit_price" DOUBLE PRECISION NOT NULL,
    "total" DOUBLE PRECISION,
    "sales_person_cost" DOUBLE PRECISION,
    "supplier_discount_form_id" INTEGER NOT NULL,
    "product_id" INTEGER,

    CONSTRAINT "supplier_discount_form_line_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "one_drive_account" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "drive_id" TEXT NOT NULL,
    "drive_type" TEXT NOT NULL,
    "workspace_id" INTEGER,

    CONSTRAINT "one_drive_account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "one_drive_token" (
    "id" SERIAL NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" UUID,
    "updated_by" UUID,
    "refresh_token" TEXT NOT NULL,
    "access_token" TEXT NOT NULL,
    "expires_in" INTEGER NOT NULL,
    "ext_expires_in" INTEGER NOT NULL,
    "token_type" TEXT NOT NULL,
    "scope" TEXT NOT NULL,
    "workspace_id" INTEGER,
    "account_id" INTEGER NOT NULL,

    CONSTRAINT "one_drive_token_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "permission_title_key" ON "permission"("title");

-- CreateIndex
CREATE INDEX "product_is_package_idx" ON "product"("is_package");

-- CreateIndex
CREATE INDEX "product_model_code_idx" ON "product"("model_code");

-- CreateIndex
CREATE INDEX "product_title_idx" ON "product"("title");

-- CreateIndex
CREATE UNIQUE INDEX "product_brand_id_model_code_key" ON "product"("brand_id", "model_code");

-- CreateIndex
CREATE UNIQUE INDEX "marketplace_sales_order_sales_order_id_key" ON "marketplace_sales_order"("sales_order_id");

-- CreateIndex
CREATE UNIQUE INDEX "marketplace_messaging_type_account_id_key" ON "marketplace_messaging"("type", "account_id");

-- CreateIndex
CREATE INDEX "brand_code_idx" ON "brand"("code");

-- CreateIndex
CREATE UNIQUE INDEX "marketplace_account_company_id_type_key" ON "marketplace_account"("company_id", "type");

-- CreateIndex
CREATE UNIQUE INDEX "purchase_order_line_order_form_line_id_key" ON "purchase_order_line"("order_form_line_id");

-- CreateIndex
CREATE UNIQUE INDEX "inventory_loan_form_line_id_key" ON "inventory"("loan_form_line_id");

-- CreateIndex
CREATE UNIQUE INDEX "reservation_goods_transfer_form_line_id_key" ON "reservation"("goods_transfer_form_line_id");

-- CreateIndex
CREATE UNIQUE INDEX "dashboard_section_order_user_id_key" ON "dashboard_section_order"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "tier_feature_id_tier_id_feature_id_key" ON "tier_feature"("id", "tier_id", "feature_id");

-- CreateIndex
CREATE UNIQUE INDEX "one_drive_account_updated_by_key" ON "one_drive_account"("updated_by");

-- CreateIndex
CREATE UNIQUE INDEX "one_drive_token_account_id_key" ON "one_drive_token"("account_id");

-- CreateIndex
CREATE UNIQUE INDEX "workspace_user_id_key" ON "workspace"("user_id");

-- AddForeignKey
ALTER TABLE "customer" ADD CONSTRAINT "customer_id_fkey" FOREIGN KEY ("id") REFERENCES "user"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "price" ADD CONSTRAINT "price_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "plan"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "subscription" ADD CONSTRAINT "subscription_price_id_fkey" FOREIGN KEY ("price_id") REFERENCES "price"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "subscription" ADD CONSTRAINT "subscription_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "team_challenge" ADD CONSTRAINT "team_challenge_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brand"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_challenge" ADD CONSTRAINT "team_challenge_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_challenge_user" ADD CONSTRAINT "team_challenge_user_team_challenge_id_fkey" FOREIGN KEY ("team_challenge_id") REFERENCES "team_challenge"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_challenge_user" ADD CONSTRAINT "team_challenge_user_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_challenge_user" ADD CONSTRAINT "team_challenge_user_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user" ADD CONSTRAINT "user_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role" ADD CONSTRAINT "role_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permission" ADD CONSTRAINT "role_permission_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "role"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permission" ADD CONSTRAINT "role_permission_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permission"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brand"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product" ADD CONSTRAINT "product_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_product" ADD CONSTRAINT "marketplace_product_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_product" ADD CONSTRAINT "marketplace_product_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_product" ADD CONSTRAINT "marketplace_product_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_sales_order" ADD CONSTRAINT "marketplace_sales_order_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_sales_order" ADD CONSTRAINT "marketplace_sales_order_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "sales_order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_sales_order" ADD CONSTRAINT "marketplace_sales_order_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_messaging" ADD CONSTRAINT "marketplace_messaging_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "marketplace_account"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_messaging" ADD CONSTRAINT "marketplace_messaging_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_gallery_image" ADD CONSTRAINT "product_gallery_image_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_gallery_image" ADD CONSTRAINT "product_gallery_image_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_spec_image" ADD CONSTRAINT "product_spec_image_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_spec_image" ADD CONSTRAINT "product_spec_image_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_spec_file" ADD CONSTRAINT "product_spec_file_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "product_spec_file" ADD CONSTRAINT "product_spec_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "brand" ADD CONSTRAINT "brand_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "brand" ADD CONSTRAINT "brand_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "brand" ADD CONSTRAINT "brand_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project" ADD CONSTRAINT "project_project_category_id_fkey" FOREIGN KEY ("project_category_id") REFERENCES "project_category"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project" ADD CONSTRAINT "project_project_group_id_fkey" FOREIGN KEY ("project_group_id") REFERENCES "project_group"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project" ADD CONSTRAINT "project_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project" ADD CONSTRAINT "project_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project" ADD CONSTRAINT "project_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project" ADD CONSTRAINT "project_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_file" ADD CONSTRAINT "project_file_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_file" ADD CONSTRAINT "project_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_currency_factor" ADD CONSTRAINT "project_currency_factor_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_currency_factor" ADD CONSTRAINT "project_currency_factor_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_currency_factor" ADD CONSTRAINT "project_currency_factor_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_brand" ADD CONSTRAINT "project_brand_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_brand" ADD CONSTRAINT "project_brand_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brand"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_brand" ADD CONSTRAINT "project_brand_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_brand" ADD CONSTRAINT "project_brand_project_id_currency_factor_id_fkey" FOREIGN KEY ("project_id", "currency_factor_id") REFERENCES "project_currency_factor"("project_id", "currency_factor_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_brand" ADD CONSTRAINT "project_brand_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_category" ADD CONSTRAINT "project_category_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_group" ADD CONSTRAINT "project_group_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_product" ADD CONSTRAINT "project_product_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_product" ADD CONSTRAINT "project_product_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_product" ADD CONSTRAINT "project_product_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brand"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_product" ADD CONSTRAINT "project_product_project_id_brand_id_fkey" FOREIGN KEY ("project_id", "brand_id") REFERENCES "project_brand"("project_id", "brand_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_product" ADD CONSTRAINT "project_product_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "currency_factor" ADD CONSTRAINT "currency_factor_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "category" ADD CONSTRAINT "category_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation" ADD CONSTRAINT "quotation_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation" ADD CONSTRAINT "quotation_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation" ADD CONSTRAINT "quotation_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation" ADD CONSTRAINT "quotation_project_contact_id_fkey" FOREIGN KEY ("project_contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation" ADD CONSTRAINT "quotation_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation" ADD CONSTRAINT "quotation_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "order"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation" ADD CONSTRAINT "quotation_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation" ADD CONSTRAINT "quotation_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation_ironmongery_room" ADD CONSTRAINT "quotation_ironmongery_room_quotation_id_fkey" FOREIGN KEY ("quotation_id") REFERENCES "quotation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation_ironmongery_room" ADD CONSTRAINT "quotation_ironmongery_room_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation_line" ADD CONSTRAINT "quotation_line_quotation_id_fkey" FOREIGN KEY ("quotation_id") REFERENCES "quotation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation_line" ADD CONSTRAINT "quotation_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation_line" ADD CONSTRAINT "quotation_line_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "quotation_ironmongery_room"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation_line" ADD CONSTRAINT "quotation_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation_attachment_file" ADD CONSTRAINT "quotation_attachment_file_quotation_id_fkey" FOREIGN KEY ("quotation_id") REFERENCES "quotation"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quotation_attachment_file" ADD CONSTRAINT "quotation_attachment_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order" ADD CONSTRAINT "order_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order" ADD CONSTRAINT "sales_order_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order" ADD CONSTRAINT "sales_order_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order" ADD CONSTRAINT "sales_order_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order" ADD CONSTRAINT "sales_order_project_contact_id_fkey" FOREIGN KEY ("project_contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order" ADD CONSTRAINT "sales_order_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order" ADD CONSTRAINT "sales_order_quotation_id_fkey" FOREIGN KEY ("quotation_id") REFERENCES "quotation"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order" ADD CONSTRAINT "sales_order_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order" ADD CONSTRAINT "sales_order_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order_line" ADD CONSTRAINT "sales_order_line_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "sales_order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order_line" ADD CONSTRAINT "sales_order_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order_line" ADD CONSTRAINT "sales_order_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order_attachment_file" ADD CONSTRAINT "sales_order_attachment_file_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "sales_order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sales_order_attachment_file" ADD CONSTRAINT "sales_order_attachment_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_account" ADD CONSTRAINT "marketplace_account_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_account" ADD CONSTRAINT "marketplace_account_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_project_contact_id_fkey" FOREIGN KEY ("project_contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouse"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order" ADD CONSTRAINT "purchase_order_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_line" ADD CONSTRAINT "purchase_order_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_line" ADD CONSTRAINT "purchase_order_line_purchase_order_id_fkey" FOREIGN KEY ("purchase_order_id") REFERENCES "purchase_order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_line" ADD CONSTRAINT "purchase_order_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "purchase_order_line" ADD CONSTRAINT "purchase_order_line_order_form_line_id_fkey" FOREIGN KEY ("order_form_line_id") REFERENCES "order_form_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_driver_id_fkey" FOREIGN KEY ("driver_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "sales_order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_loan_form_id_fkey" FOREIGN KEY ("loan_form_id") REFERENCES "loan_form"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_goods_return_note_id_fkey" FOREIGN KEY ("goods_return_note_id") REFERENCES "goods_return_note"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_goods_transfer_form_id_fkey" FOREIGN KEY ("goods_transfer_form_id") REFERENCES "goods_transfer_form"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order" ADD CONSTRAINT "delivery_order_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order_line" ADD CONSTRAINT "delivery_order_line_delivery_order_id_fkey" FOREIGN KEY ("delivery_order_id") REFERENCES "delivery_order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order_line" ADD CONSTRAINT "delivery_order_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order_line" ADD CONSTRAINT "delivery_order_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order_attachment_file" ADD CONSTRAINT "delivery_order_attachment_file_delivery_order_id_fkey" FOREIGN KEY ("delivery_order_id") REFERENCES "delivery_order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_order_attachment_file" ADD CONSTRAINT "delivery_order_attachment_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_instruction" ADD CONSTRAINT "delivery_instruction_delivery_order_id_fkey" FOREIGN KEY ("delivery_order_id") REFERENCES "delivery_order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_instruction" ADD CONSTRAINT "delivery_instruction_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouse"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_instruction" ADD CONSTRAINT "delivery_instruction_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_instruction_line" ADD CONSTRAINT "delivery_instruction_line_delivery_instruction_id_fkey" FOREIGN KEY ("delivery_instruction_id") REFERENCES "delivery_instruction"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_instruction_line" ADD CONSTRAINT "delivery_instruction_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "delivery_instruction_line" ADD CONSTRAINT "delivery_instruction_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice" ADD CONSTRAINT "invoice_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice" ADD CONSTRAINT "invoice_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice" ADD CONSTRAINT "invoice_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice" ADD CONSTRAINT "invoice_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice" ADD CONSTRAINT "invoice_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "sales_order"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice" ADD CONSTRAINT "invoice_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice" ADD CONSTRAINT "invoice_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_line" ADD CONSTRAINT "invoice_line_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_line" ADD CONSTRAINT "invoice_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_line" ADD CONSTRAINT "invoice_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_payment" ADD CONSTRAINT "invoice_payment_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "invoice_payment" ADD CONSTRAINT "invoice_payment_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice" ADD CONSTRAINT "supplier_invoice_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice" ADD CONSTRAINT "supplier_invoice_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice" ADD CONSTRAINT "supplier_invoice_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice" ADD CONSTRAINT "supplier_invoice_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice" ADD CONSTRAINT "supplier_invoice_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice" ADD CONSTRAINT "supplier_invoice_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_attachment_file" ADD CONSTRAINT "supplier_invoice_attachment_file_supplier_invoice_id_fkey" FOREIGN KEY ("supplier_invoice_id") REFERENCES "supplier_invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_attachment_file" ADD CONSTRAINT "supplier_invoice_attachment_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_line" ADD CONSTRAINT "supplier_invoice_line_supplier_invoice_id_fkey" FOREIGN KEY ("supplier_invoice_id") REFERENCES "supplier_invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_line" ADD CONSTRAINT "supplier_invoice_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_line" ADD CONSTRAINT "supplier_invoice_line_purchase_order_line_id_fkey" FOREIGN KEY ("purchase_order_line_id") REFERENCES "purchase_order_line"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_line" ADD CONSTRAINT "supplier_invoice_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_payment" ADD CONSTRAINT "supplier_invoice_payment_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_invoice_payment" ADD CONSTRAINT "supplier_invoice_payment_supplier_invoice_id_fkey" FOREIGN KEY ("supplier_invoice_id") REFERENCES "supplier_invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note" ADD CONSTRAINT "credit_note_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note_line" ADD CONSTRAINT "credit_note_line_credit_note_id_fkey" FOREIGN KEY ("credit_note_id") REFERENCES "credit_note"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note_line" ADD CONSTRAINT "credit_note_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note_line" ADD CONSTRAINT "credit_note_line_invoice_line_id_fkey" FOREIGN KEY ("invoice_line_id") REFERENCES "invoice_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "credit_note_line" ADD CONSTRAINT "credit_note_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note" ADD CONSTRAINT "debit_note_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note" ADD CONSTRAINT "debit_note_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note" ADD CONSTRAINT "debit_note_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note" ADD CONSTRAINT "debit_note_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note" ADD CONSTRAINT "debit_note_supplier_invoice_id_fkey" FOREIGN KEY ("supplier_invoice_id") REFERENCES "supplier_invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note" ADD CONSTRAINT "debit_note_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note" ADD CONSTRAINT "debit_note_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note_attachment_file" ADD CONSTRAINT "debit_note_attachment_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note_attachment_file" ADD CONSTRAINT "debit_note_attachment_file_debit_note_id_fkey" FOREIGN KEY ("debit_note_id") REFERENCES "debit_note"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note_line" ADD CONSTRAINT "debit_note_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note_line" ADD CONSTRAINT "debit_note_line_debit_note_id_fkey" FOREIGN KEY ("debit_note_id") REFERENCES "debit_note"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "debit_note_line" ADD CONSTRAINT "debit_note_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note" ADD CONSTRAINT "goods_return_note_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note" ADD CONSTRAINT "goods_return_note_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note" ADD CONSTRAINT "goods_return_note_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note" ADD CONSTRAINT "goods_return_note_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note" ADD CONSTRAINT "goods_return_note_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note" ADD CONSTRAINT "goods_return_note_invoice_id_fkey" FOREIGN KEY ("invoice_id") REFERENCES "invoice"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note" ADD CONSTRAINT "goods_return_note_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouse"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note_line" ADD CONSTRAINT "goods_return_note_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note_line" ADD CONSTRAINT "goods_return_note_line_goods_return_note_id_fkey" FOREIGN KEY ("goods_return_note_id") REFERENCES "goods_return_note"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note_line" ADD CONSTRAINT "goods_return_note_line_invoice_line_id_fkey" FOREIGN KEY ("invoice_line_id") REFERENCES "invoice_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_return_note_line" ADD CONSTRAINT "goods_return_note_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_form" ADD CONSTRAINT "loan_form_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_form" ADD CONSTRAINT "loan_form_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_form" ADD CONSTRAINT "loan_form_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_form" ADD CONSTRAINT "loan_form_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_form" ADD CONSTRAINT "loan_form_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_form_line" ADD CONSTRAINT "loan_form_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_form_line" ADD CONSTRAINT "loan_form_line_loan_form_id_fkey" FOREIGN KEY ("loan_form_id") REFERENCES "loan_form"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_form_line" ADD CONSTRAINT "loan_form_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "loan_form_line" ADD CONSTRAINT "loan_form_line_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouse"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_transfer_form" ADD CONSTRAINT "goods_transfer_form_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_transfer_form" ADD CONSTRAINT "goods_transfer_form_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_transfer_form" ADD CONSTRAINT "goods_transfer_form_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_transfer_form" ADD CONSTRAINT "goods_transfer_form_source_warehouse_id_fkey" FOREIGN KEY ("source_warehouse_id") REFERENCES "warehouse"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_transfer_form" ADD CONSTRAINT "goods_transfer_form_target_warehouse_id_fkey" FOREIGN KEY ("target_warehouse_id") REFERENCES "warehouse"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_transfer_form_line" ADD CONSTRAINT "goods_transfer_form_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_transfer_form_line" ADD CONSTRAINT "goods_transfer_form_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "goods_transfer_form_line" ADD CONSTRAINT "goods_transfer_form_line_goods_transfer_form_id_fkey" FOREIGN KEY ("goods_transfer_form_id") REFERENCES "goods_transfer_form"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "feedback" ADD CONSTRAINT "feedback_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "company" ADD CONSTRAINT "company_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "company_file" ADD CONSTRAINT "company_file_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "company_file" ADD CONSTRAINT "company_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "company_brand" ADD CONSTRAINT "company_brand_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "company_brand" ADD CONSTRAINT "company_brand_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brand"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "company_brand" ADD CONSTRAINT "company_brand_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contact" ADD CONSTRAINT "contact_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contact" ADD CONSTRAINT "contact_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contact" ADD CONSTRAINT "contact_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contact_file" ADD CONSTRAINT "contact_file_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contact_file" ADD CONSTRAINT "contact_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "memo" ADD CONSTRAINT "memo_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "memo" ADD CONSTRAINT "memo_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "memo" ADD CONSTRAINT "memo_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "memo" ADD CONSTRAINT "memo_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "memo" ADD CONSTRAINT "memo_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "memo" ADD CONSTRAINT "memo_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "todo" ADD CONSTRAINT "todo_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "todo" ADD CONSTRAINT "todo_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "todo" ADD CONSTRAINT "todo_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse" ADD CONSTRAINT "warehouse_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_product" ADD CONSTRAINT "warehouse_product_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouse"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_product" ADD CONSTRAINT "warehouse_product_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_product" ADD CONSTRAINT "warehouse_product_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_product_stock_alert" ADD CONSTRAINT "warehouse_product_stock_alert_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_product_stock_alert" ADD CONSTRAINT "warehouse_product_stock_alert_warehouse_id_fkey" FOREIGN KEY ("warehouse_id") REFERENCES "warehouse"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_product_stock_alert" ADD CONSTRAINT "warehouse_product_stock_alert_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "warehouse_product_stock_alert" ADD CONSTRAINT "warehouse_product_stock_alert_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory" ADD CONSTRAINT "inventory_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory" ADD CONSTRAINT "inventory_sales_order_line_id_fkey" FOREIGN KEY ("sales_order_line_id") REFERENCES "sales_order_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory" ADD CONSTRAINT "inventory_warehouse_id_product_id_fkey" FOREIGN KEY ("warehouse_id", "product_id") REFERENCES "warehouse_product"("warehouse_id", "product_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory" ADD CONSTRAINT "inventory_purchase_order_line_id_fkey" FOREIGN KEY ("purchase_order_line_id") REFERENCES "purchase_order_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory" ADD CONSTRAINT "inventory_loan_form_line_id_fkey" FOREIGN KEY ("loan_form_line_id") REFERENCES "loan_form_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory" ADD CONSTRAINT "inventory_goods_return_note_line_id_fkey" FOREIGN KEY ("goods_return_note_line_id") REFERENCES "goods_return_note_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "inventory" ADD CONSTRAINT "inventory_goods_transfer_form_line_id_fkey" FOREIGN KEY ("goods_transfer_form_line_id") REFERENCES "goods_transfer_form_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reservation" ADD CONSTRAINT "reservation_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reservation" ADD CONSTRAINT "reservation_warehouse_id_product_id_fkey" FOREIGN KEY ("warehouse_id", "product_id") REFERENCES "warehouse_product"("warehouse_id", "product_id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reservation" ADD CONSTRAINT "reservation_order_form_line_id_fkey" FOREIGN KEY ("order_form_line_id") REFERENCES "order_form_line"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reservation" ADD CONSTRAINT "reservation_marketplace_sales_order_id_fkey" FOREIGN KEY ("marketplace_sales_order_id") REFERENCES "marketplace_sales_order"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reservation" ADD CONSTRAINT "reservation_purchase_order_line_id_fkey" FOREIGN KEY ("purchase_order_line_id") REFERENCES "purchase_order_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reservation" ADD CONSTRAINT "reservation_goods_transfer_form_line_id_fkey" FOREIGN KEY ("goods_transfer_form_line_id") REFERENCES "goods_transfer_form_line"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "service" ADD CONSTRAINT "service_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "brand"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "service" ADD CONSTRAINT "service_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "category"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "service" ADD CONSTRAINT "service_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "service" ADD CONSTRAINT "service_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_form" ADD CONSTRAINT "order_form_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_form" ADD CONSTRAINT "order_form_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_form" ADD CONSTRAINT "order_form_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_form" ADD CONSTRAINT "order_form_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_form" ADD CONSTRAINT "order_form_sales_order_id_fkey" FOREIGN KEY ("sales_order_id") REFERENCES "sales_order"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_form_line" ADD CONSTRAINT "order_form_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_form_line" ADD CONSTRAINT "order_form_line_order_form_id_fkey" FOREIGN KEY ("order_form_id") REFERENCES "order_form"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "order_form_line" ADD CONSTRAINT "order_form_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim" ADD CONSTRAINT "progressive_claim_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim" ADD CONSTRAINT "progressive_claim_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim" ADD CONSTRAINT "progressive_claim_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim" ADD CONSTRAINT "progressive_claim_project_group_id_fkey" FOREIGN KEY ("project_group_id") REFERENCES "project_group"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim" ADD CONSTRAINT "progressive_claim_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim" ADD CONSTRAINT "progressive_claim_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim" ADD CONSTRAINT "progressive_claim_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim_line" ADD CONSTRAINT "progressive_claim_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim_line" ADD CONSTRAINT "progressive_claim_line_progressive_claim_id_fkey" FOREIGN KEY ("progressive_claim_id") REFERENCES "progressive_claim"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim_line" ADD CONSTRAINT "progressive_claim_line_sales_order_line_id_fkey" FOREIGN KEY ("sales_order_line_id") REFERENCES "sales_order_line"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim_line" ADD CONSTRAINT "progressive_claim_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim_extra_line" ADD CONSTRAINT "progressive_claim_extra_line_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim_extra_line" ADD CONSTRAINT "progressive_claim_extra_line_sales_order_line_id_fkey" FOREIGN KEY ("sales_order_line_id") REFERENCES "sales_order_line"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim_extra_line" ADD CONSTRAINT "progressive_claim_extra_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim_attachment_file" ADD CONSTRAINT "progressive_claim_attachment_file_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "progressive_claim_attachment_file" ADD CONSTRAINT "progressive_claim_attachment_file_progressive_claim_id_fkey" FOREIGN KEY ("progressive_claim_id") REFERENCES "progressive_claim"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "receipt" ADD CONSTRAINT "receipt_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "xero_token" ADD CONSTRAINT "xero_token_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "xero_token" ADD CONSTRAINT "xero_token_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_token" ADD CONSTRAINT "marketplace_token_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_token" ADD CONSTRAINT "marketplace_token_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "marketplace_token" ADD CONSTRAINT "marketplace_token_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "marketplace_account"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dashboard_section_order" ADD CONSTRAINT "dashboard_section_order_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dashboard_section_order" ADD CONSTRAINT "dashboard_section_order_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tier_feature" ADD CONSTRAINT "tier_feature_feature_id_fkey" FOREIGN KEY ("feature_id") REFERENCES "feature"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tier_feature" ADD CONSTRAINT "tier_feature_tier_id_fkey" FOREIGN KEY ("tier_id") REFERENCES "tier"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workspace" ADD CONSTRAINT "workspace_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workspace" ADD CONSTRAINT "workspace_tier_id_fkey" FOREIGN KEY ("tier_id") REFERENCES "tier"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_registration" ADD CONSTRAINT "project_registration_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "project_registration" ADD CONSTRAINT "project_registration_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_discount_form" ADD CONSTRAINT "supplier_discount_form_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "user"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_discount_form" ADD CONSTRAINT "supplier_discount_form_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_discount_form" ADD CONSTRAINT "supplier_discount_form_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "company"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_discount_form" ADD CONSTRAINT "supplier_discount_form_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "contact"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_discount_form" ADD CONSTRAINT "supplier_discount_form_currency_factor_id_fkey" FOREIGN KEY ("currency_factor_id") REFERENCES "currency_factor"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_discount_form" ADD CONSTRAINT "supplier_discount_form_quotation_id_fkey" FOREIGN KEY ("quotation_id") REFERENCES "quotation"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_discount_form_line" ADD CONSTRAINT "supplier_discount_form_line_supplier_discount_form_id_fkey" FOREIGN KEY ("supplier_discount_form_id") REFERENCES "supplier_discount_form"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "supplier_discount_form_line" ADD CONSTRAINT "supplier_discount_form_line_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "product"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "one_drive_account" ADD CONSTRAINT "one_drive_account_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "one_drive_token" ADD CONSTRAINT "one_drive_token_workspace_id_fkey" FOREIGN KEY ("workspace_id") REFERENCES "workspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "one_drive_token" ADD CONSTRAINT "one_drive_token_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "one_drive_account"("id") ON DELETE CASCADE ON UPDATE CASCADE;
