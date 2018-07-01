# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170507092451) do

  create_table "orders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "subscription_id"
    t.string "customer_name"
    t.string "customer_phone"
    t.string "deal_source"
    t.string "project_name"
    t.datetime "sub_date"
    t.integer "customer_type", limit: 2
    t.decimal "commision_price", precision: 12, scale: 2
    t.decimal "amout_price", precision: 12, scale: 2
    t.decimal "reduce_price", precision: 12, scale: 2
    t.decimal "reduced_price", precision: 12, scale: 2
    t.decimal "no_reduced_price", precision: 12, scale: 2
    t.decimal "real_price", precision: 12, scale: 2
    t.string "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_type"], name: "index_orders_on_customer_type"
    t.index ["sub_date"], name: "index_orders_on_sub_date"
  end

  create_table "orders_sales", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "order_id"
    t.integer "sale_id"
    t.decimal "rate", precision: 10, scale: 4
    t.integer "primary_sale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_orders_sales_on_order_id"
    t.index ["primary_sale"], name: "index_orders_sales_on_primary_sale"
    t.index ["sale_id"], name: "index_orders_sales_on_sale_id"
  end

  create_table "payments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "order_id"
    t.decimal "money", precision: 20, scale: 2
    t.datetime "pay_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
    t.index ["pay_date"], name: "index_payments_on_pay_date"
  end

  create_table "report_settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "year"
    t.integer "month"
    t.text "yml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sale_reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "year"
    t.integer "month"
    t.text "data_yml"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sales", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.integer "level"
    t.integer "leader_type"
    t.string "alias_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "customer_name"
    t.string "customer_phone"
    t.string "deal_source"
    t.string "project_name"
    t.datetime "sub_date"
    t.integer "customer_type", limit: 2
    t.decimal "commision_price", precision: 12, scale: 2
    t.decimal "amout_price", precision: 12, scale: 2
    t.decimal "reduce_price", precision: 12, scale: 2
    t.decimal "reduced_price", precision: 12, scale: 2
    t.decimal "no_reduced_price", precision: 12, scale: 2
    t.decimal "real_price", precision: 12, scale: 2
    t.string "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_type"], name: "index_subscriptions_on_customer_type"
    t.index ["sub_date"], name: "index_subscriptions_on_sub_date"
  end

  create_table "subscriptions_sales", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "subscription_id"
    t.integer "sale_id"
    t.decimal "rate", precision: 10, scale: 4
    t.integer "primary_sale"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["primary_sale"], name: "index_subscriptions_sales_on_primary_sale"
    t.index ["sale_id"], name: "index_subscriptions_sales_on_sale_id"
    t.index ["subscription_id"], name: "index_subscriptions_sales_on_subscription_id"
  end

  create_table "team_sales", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "team_id"
    t.integer "sale_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_sets", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["end_time"], name: "index_team_sets_on_end_time"
    t.index ["start_time"], name: "index_team_sets_on_start_time"
  end

  create_table "teams", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "team_set_id"
    t.integer "leader_id"
    t.integer "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "leader_type"
  end

end
