module MigrationHelper
  def pgt_updated_at(table_name)
    function_name = "#{table_name}_set_updated_at".to_sym
    Sequel.migration do
      up do
        if DB.adapter_scheme == :postgres
          pgt_updated_at(
            table_name.to_sym,
            :updated_at,
            function_name: function_name,
            trigger_name:  :set_updated_at
          )
        end
      end

      down do
        if DB.adapter_scheme == :postgres
          drop_trigger(table_name.to_sym, :set_updated_at)
          drop_function(function_name)
        end
      end
    end
  end
end
