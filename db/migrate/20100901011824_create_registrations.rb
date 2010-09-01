class CreateRegistrations < ActiveRecord::Migration
  def self.up
    create_table :registrations do |t|
      t.string :transaction
      t.string :serial_num
      t.string :email
    end
  end

  def self.down
  end
end
