class ActiveRecord::Base
  
  def self.generate_sql(identifier, &blk)
    sql_generator = ContinuousThinking::SQL::Generator.for(identifier)
    yield sql_generator
    sql_generator.to_sql_statements
  end
  
  def self.import(*args)
    instances, invalid_instances = nil, []
    options = { :validate => true }
    
    if args.size == 1
      columns = column_names.dup
      instances = args.first
    elsif args.size == 2 && args.last.is_a?(Array)
      if args.last.first.kind_of?(ActiveRecord::Base)
        columns, instances = args
      else
        columns, values = args
      end
    elsif args.size == 2 && args.last.is_a?(Hash)
      options.merge! args.pop
      columns = column_names.dup
      instances = args.first
    elsif args.size == 3 && args.last.is_a?(Hash)
      if args[1].first.kind_of?(ActiveRecord::Base)
        options.merge! args.pop
        columns, instances = args
      else
        options.merge! args.pop
        columns, values = args
      end
    end

    if options[:validate]
      if instances.nil?
        instances = []
        values.each do |rows|
          attrs = {}
          rows.each_with_index do |value, index|
            attrs[columns[index]] = value
          end
          instances << new(attrs)
        end
      end
      invalid_instances = instances.select{ |instance| !instance.valid? }
      instances -= invalid_instances
    end
    
    if instances
      if instances.any?
        values = instances.map{ |model| columns.map{ |column| model.attributes[column.to_s] } }
      else
        return ContinuousThinking::SQL::Result.new(:num_inserts => 0, :failed_instances => invalid_instances)
      end
    end
    
    sql_statements = generate_sql :insert_into do |sql|
      sql.table = quoted_table_name
      sql.columns = columns.map{ |name| connection.quote_column_name(name) }
      sql.values = values.map{ |rows| rows.map{ |field| connection.quote(field, columns_hash[columns[rows.index(field)]]) } }
      sql.options = options
    end

    sql_statements.each { |statement| connection.execute statement }
    ContinuousThinking::SQL::Result.new(:num_inserts => values.size, :failed_instances => invalid_instances)
  end
  
end