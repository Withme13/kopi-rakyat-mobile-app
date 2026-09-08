# Database Schema

## products
- id
- name
- slug
- description
- price
- image_url
- category_id
- is_active
- stock
- created_at
- updated_at

## categories
- id
- name
- slug
- created_at

## stores
- id
- name
- address
- latitude
- longitude
- is_active

## banners
- id
- title
- image_url
- link
- is_active

## promos
- id
- code
- description
- discount_amount
- is_active
- valid_from
- valid_to

## orders
- id
- customer_id
- store_id
- status
- total
- payment_method
- fulfilment_mode
- created_at

## order_items
- id
- order_id
- product_id
- product_name
- qty
- price
