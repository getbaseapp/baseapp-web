class CreateRegistrations < ActiveRecord::Migration
  def self.up
    create_table :registrations do |t|
      t.primary_key   :id
      t.string        :transaction
      t.string        :serial_num
      t.string        :email
      t.timestamps
    end
  end

  def self.down
  end
end
