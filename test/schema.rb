ActiveRecord::Schema.define(:version => 1) do

  create_table :mixins, :force => true do |t|
    t.column :flags,       :string
    t.column :positions,   :string
    t.column :blank_flags, :string
  end

end
