migration 1, :create_pages do
  up do
    create_table :pages do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :pages
  end
end
