require 'active_record'

# ActsAsBits
module ActsAsBits
  def self.rails2?
    ActiveRecord::Base.respond_to?(:sanitize_sql_hash_for_conditions)
  end

  def self.rails3?
     Rails.version >= '3.0.0'
  rescue
    false
  end

  def self.append_features(base)
    base.extend ClassMethods
    return if rails3?

    base.extend(rails2? ? Rails2x : Rails1x)
    base.class_eval do
      def self.sanitize_sql_hash(*args)
        sanitize_sql_hash_with_aab(*args)
      end

      def self.sanitize_sql_hash_for_conditions(*args)
        sanitize_sql_hash_with_aab(*args)
      end
    end
  end

  module Rails1x
    def sanitize_sql_hash_with_aab(attrs)
      values = []
      conditions = attrs.map do |attr, value|
        if bit_column = bit_columns_hash[attr.to_s]
          flag = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
          "#{bit_column} %s '1'" % (flag ? '=' : '<>')
        else
          values << value
          prefix = "#{table_name}." rescue ''
          "#{prefix}#{connection.quote_column_name(attr)} #{attribute_condition(value)}"
        end
      end.join(' AND ')
      replace_bind_variables(conditions, expand_range_bind_variables(values))
    end
  end

  module Rails2x
    def sanitize_sql_hash_with_aab(attrs, default_table_name = nil)
      values = []
      conditions = attrs.keys.map do |key|
        value = attrs[key]
        attr  = key.to_s

        # Extract table name from qualified attribute names.
        if attr.include?('.')
          table_name, attr = attr.split('.', 2)
          table_name = connection.quote_table_name(table_name)
        else
          table_name = default_table_name || quoted_table_name
        end

        if bit_column = bit_columns_hash[attr]
          flag = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
          "#{bit_column} %s '1'" % (flag ? '=' : '<>')
        else
          values << value
          case ActiveRecord::Base.method(:attribute_condition).arity
          when 1                # Rails 2.0-2.2
            "#{table_name}.#{connection.quote_column_name(attr)} #{attribute_condition(value)}"
          when 2                # Rails 2.3-
            attribute_condition("#{table_name}.#{connection.quote_column_name(attr)}", value)
          else
            raise NotImplementedError, "unknown AR::Base#attribute_condition type"
          end
        end
      end.join(' AND ')
      replace_bind_variables(conditions, expand_range_bind_variables(values))
    end
  end

  module ClassMethods
    def bit_columns_hash
      @bit_columns_hash ||= {}
    end

    def acts_as_bits(part_id, bit_names, options = {})
      composed_name = part_id.id2name
      singular_name = composed_name.singularize

      delegate "#{singular_name}_names", :to=>"self.class"

      if options[:prefix]
        bit_names = bit_names.map do |(name, label)|
          name = "%s_%s" % [singular_name, name]
          [name, label]
        end
      end

      # true/false fills all values by itself
      module_eval <<-end_eval
        def #{composed_name}=(value)
          case value
          when true  then super("1"*#{singular_name}_names.size)
          when false then super("0"*#{singular_name}_names.size)
          else            super
          end
        end
      end_eval

      bit_names.each_with_index do |(name, label), index|
        next if name.blank?

        # register bit column
        column_name = "COALESCE(SUBSTRING(%s.%s,%d,1),'')" % [table_name, connection.quote_column_name(composed_name), index+1]
        (@bit_columns_hash ||= {})[name.to_s] = column_name

        module_eval <<-end_eval
              def #{name}
                #{name}?
              end

              unless label.blank?
                def self.#{name}_label
                  #{label.inspect}
                end
              end

              def #{name}?
                #{composed_name}.to_s[#{index}] == ?1
              end

              def #{name}=(v)
                v = ActiveRecord::ConnectionAdapters::Column.value_to_boolean(v) ? ?1 : ?0

                # expand target string automatically
                if #{composed_name}.size < #{singular_name}_names.size
                   #{composed_name} << "0" * (#{singular_name}_names.size - #{composed_name}.size)
                end

                value = #{composed_name}.dup
                value[#{index}] = v
                write_attribute("#{composed_name}", value)
                return v
              end
        end_eval

        compacted_bit_names = bit_names.select{|(i,_)| !i.blank?}
        column_names = compacted_bit_names.map{|(i,_)| i.to_s}
        label_names  = compacted_bit_names.map{|(n,i)| i.to_s}

        module_eval <<-end_eval
            def self.#{singular_name}_names
              #{column_names.inspect}
            end

          if options[:prefix]

            def #{singular_name}?(name = nil)
              if name
                __send__ "#{singular_name}_" + name.to_s
              else
                #{composed_name}.to_s.include?('1')
              end
            end

          else

            def #{singular_name}?(name = nil)
              if name
                __send__ name
              else
                #{composed_name}.to_s.include?('1')
              end
            end

          end

            def #{composed_name}
              self.#{composed_name} = "0" * #{column_names.size} if super.blank?
              super
            end

            def #{composed_name}_hash
              HashWithIndifferentAccess[*#{singular_name}_names.map{|i| [i,__send__(i)]}.flatten]
            end
        end_eval

        module_eval <<-end_eval
            def self.#{singular_name}_labels
              #{label_names.inspect}
            end

            def self.#{singular_name}_names_with_labels
              #{bit_names.inspect}
            end
        end_eval
      end
    end
  end # ClassMethods
end

ActiveRecord::Base.class_eval do
  include ActsAsBits
end

