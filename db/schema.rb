# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_13_193151) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_players", force: :cascade do |t|
    t.integer "player_total_money", default: 0
    t.integer "player_order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "game_id"
    t.bigint "user_id"
    t.index ["game_id"], name: "index_game_players_on_game_id"
    t.index ["user_id"], name: "index_game_players_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "over", default: false
    t.integer "current_round_id"
  end

  create_table "round_players", force: :cascade do |t|
    t.integer "player_money", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "round_id"
    t.bigint "user_id"
    t.index ["round_id"], name: "index_round_players_on_round_id"
    t.index ["user_id"], name: "index_round_players_on_user_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.integer "game_id"
    t.boolean "over", default: false
    t.string "topic"
    t.string "sentence"
    t.text "opened_letters", default: [], array: true
    t.text "text", default: [], array: true
    t.integer "current_player_id"
    t.integer "order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

end
