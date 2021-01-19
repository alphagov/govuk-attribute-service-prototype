class AddTimestampsToClaims < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :claims, default: -> { 'now()' }, null: false
  end
end
