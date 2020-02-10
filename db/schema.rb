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

ActiveRecord::Schema.define(version: 2020_02_10_151331) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blocks", force: :cascade do |t|
    t.text "sentence"
    t.datetime "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subtitle_id"
    t.string "start_timestamp"
    t.index ["subtitle_id"], name: "index_blocks_on_subtitle_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "name"
    t.integer "book_frequency"
    t.boolean "star"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_books_on_user_id"
  end

  create_table "cards", force: :cascade do |t|
    t.text "phrase"
    t.text "phrase_translated"
    t.boolean "memorized"
    t.boolean "bookmark"
    t.integer "view_count"
    t.integer "card_frequency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "block_id"
    t.bigint "book_id"
    t.index ["block_id"], name: "index_cards_on_block_id"
    t.index ["book_id"], name: "index_cards_on_book_id"
  end

  create_table "forums", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.string "image"
    t.index ["user_id"], name: "index_forums_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "forum_id"
    t.string "title"
    t.text "comment"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["forum_id"], name: "index_posts_on_forum_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "subtitles", force: :cascade do |t|
    t.string "video_title"
    t.string "video_id"
    t.string "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "url_id"
    t.text "language_list", array: true
    t.index ["user_id"], name: "index_subtitles_on_user_id"
  end

  create_table "translations", force: :cascade do |t|
    t.string "video_title"
    t.string "video_id"
    t.string "language"
    t.string "url_id"
    t.bigint "subtitle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subtitle_id"], name: "index_translations_on_subtitle_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.string "user_name"
    t.boolean "guest", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "blocks", "subtitles"
  add_foreign_key "books", "users"
  add_foreign_key "cards", "blocks"
  add_foreign_key "cards", "books"
  add_foreign_key "forums", "users"
  add_foreign_key "posts", "forums"
  add_foreign_key "posts", "users"
  add_foreign_key "subtitles", "users"
  add_foreign_key "translations", "subtitles"
end
