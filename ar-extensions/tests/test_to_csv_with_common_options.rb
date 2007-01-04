require File.join( File.dirname( __FILE__ ), 'boot')
require 'fileutils'
require 'fastercsv'

class Developer < ActiveRecord::Base
  include ActiveRecord::Extensions::FindToCSV
end

class Address < ActiveRecord::Base
  include ActiveRecord::Extensions::FindToCSV
end

class TestToCSVWithCommonOptions < Test::Unit::TestCase
  self.fixture_path = File.join( File.dirname( __FILE__ ), 'fixtures/unit/to_csv_with_common_options' )
  fixtures 'developers', 'addresses'

  def setup
    @developer = Developer.find( 1 )
    @address = Address.find( 1 )
  end
  
  def teardown
    Developer.delete_all
  end
  
  def parse_csv( csv )
    parsed_csv = FasterCSV.parse( csv )
    headers = parsed_csv.first
    data = parsed_csv[1..-1]
    OpenStruct.new :headers=>headers, :data=>data, :size=>parsed_csv.size
  end    

  def test_find_to_csv_with_no_headers
    csv = @developer.to_csv( :headers=>false )
    parsed_csv = FasterCSV.parse( csv )
    actual_data = parsed_csv.first
    assert_equal 1, parsed_csv.size

    expected_data = '', '1', 'Zach Dennis', '1', ''
    assert_equal expected_data, actual_data
  end

  def test_find_to_csv_with_headers
    csv = @developer.to_csv( :headers=>true )
    parsed_csv = parse_csv( csv )
    assert 2, parsed_csv.size
    
    expected_headers = %w( created_at id name salary updated_at )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = '', '1', 'Zach Dennis', '1', ''
    assert_equal expected_data, parsed_csv.data.first
  end

  def test_find_to_csv_with_headers_as_array_of_symbols
    csv = @developer.to_csv( :headers=>[ :name, :id ] )
    parsed_csv = parse_csv( csv )
    assert 2, parsed_csv.size
    
    assert_equal 2, parsed_csv.size
    
    expected_headers = %w( name id )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = 'Zach Dennis', '1'
    assert_equal expected_data, parsed_csv.data.first
  end

  def test_find_to_csv_with_headers_as_array_of_strings
    csv = @developer.to_csv( :headers=>[ 'id', 'name' ] )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size
    
    expected_headers = %w( id name )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = '1', 'Zach Dennis'
    assert_equal expected_data, parsed_csv.data.first
  end

  def test_find_to_csv_with_specified_fields_only_as_array_of_strings
    csv = @developer.to_csv( :only=>[ 'id', 'name' ] )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size
    
    expected_headers = %w( id name )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = '1', 'Zach Dennis'
    assert_equal expected_data, parsed_csv.data.first
  end

  def test_find_to_csv_with_excluded_fields_only_as_array_of_strings
    csv = @developer.to_csv( :except=>[ 'id', 'name' ] )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size
    
    expected_headers = %w( created_at salary updated_at )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = '', '1', ''
    assert_equal expected_data, parsed_csv.data.first
  end
  
  def test_find_to_csv_for_a_belongs_to_association_with_include_option_as_array_of_symbols
    csv = @address.to_csv( :include=>[ :developer ] )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( address city developer_id id state zip 
                           developer[created_at] developer[id] 
                           developer[name] developer[salary] developer[updated_at] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.address, @address.city, @address.developer_id, 
                      @address.id, @address.state, @address.zip, 
                      @address.developer.created_at, @address.developer.id, 
                      @address.developer.name, @address.developer.salary, 
                      @address.developer.updated_at ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_a_belongs_to_association_with_include_option_as_array_of_strings
    csv = @address.to_csv( :include=>[ 'developer' ] )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( address city developer_id id state zip 
                           developer[created_at] developer[id] 
                           developer[name] developer[salary] developer[updated_at] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.address, @address.city, @address.developer_id, 
                      @address.id, @address.state, @address.zip, 
                      @address.developer.created_at, @address.developer.id, 
                      @address.developer.name, @address.developer.salary, 
                      @address.developer.updated_at ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_a_belongs_to_association_with_include_option_as_array_of_symbols
    csv = @address.to_csv( :include=>[ :developer ] )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( address city developer_id id state zip 
                           developer[created_at] developer[id] 
                           developer[name] developer[salary] developer[updated_at] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.address, @address.city, @address.developer_id, 
                      @address.id, @address.state, @address.zip, 
                      @address.developer.created_at, @address.developer.id, 
                      @address.developer.name, @address.developer.salary, 
                      @address.developer.updated_at ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_a_belongs_to_association_with_include_option_as_empty_hash
    csv = @address.to_csv( :include=>{ :developer=>{} } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( address city developer_id id state zip 
                           developer[created_at] developer[id] 
                           developer[name] developer[salary] developer[updated_at] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.address, @address.city, @address.developer_id, 
                      @address.id, @address.state, @address.zip, 
                      @address.developer.created_at, @address.developer.id, 
                      @address.developer.name, @address.developer.salary, 
                      @address.developer.updated_at ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_a_belongs_to_association_with_an_options_hash_of_specified_fields_as_array_of_symbols
    csv = @address.to_csv( :include=>{ :developer=>{ :only=>[:name,:salary] } } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( address city developer_id id state zip 
                           developer[name] developer[salary] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.address, @address.city, @address.developer_id, 
                      @address.id, @address.state, @address.zip, 
                      @address.developer.name, @address.developer.salary ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_a_belongs_to_association_with_an_options_hash_of_specified_fields_as_array_of_strings
    csv = @address.to_csv( :include=>{ :developer=>{ :only=>['name','salary'] } } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( address city developer_id id state zip 
                           developer[name] developer[salary] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.address, @address.city, @address.developer_id, 
                      @address.id, @address.state, @address.zip, 
                      @address.developer.name, @address.developer.salary ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_a_belongs_to_association_with_an_options_hash_of_specified_fields_as_array_of_symbols2
    csv = @address.to_csv( :only=>[:city, :state], 
                           :include=>{ :developer=>{ :only=>[:name,:salary] } } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( city state developer[name] developer[salary] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.city, @address.state,  
                      @address.developer.name, @address.developer.salary ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end
  
  def test_find_to_csv_for_a_belongs_to_association_with_an_options_hash_of_specified_fields_as_array_of_strings2
    csv = @address.to_csv( :only=>%W( city state ), :include=>{ :developer=>{ :only=>%W( name salary ) } } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( city state developer[name] developer[salary] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.city, @address.state,  
                      @address.developer.name, @address.developer.salary ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_a_belongs_to_association_with_an_options_hash_of_excluded_fields_as_array_of_strings
    csv = @address.to_csv( :except=>%W( id developer_id address zip ) )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( city state )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.city, @address.state ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end
  
  def test_find_to_csv_for_a_belongs_to_association_with_an_options_hash_of_excluded_fields_as_array_of_symbols
    csv = @address.to_csv( :except=>[ :id, :developer_id, :address, :zip ] )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( city state )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.city, @address.state ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  
  def test_find_to_csv_for_a_belongs_to_association_with_an_options_hash_of_excluded_fields_as_array_of_strings2
    csv = @address.to_csv( :except=>%W( id developer_id address zip ), 
                           :include=>{ :developer=>{ :except=>%W( id created_at updated_at ) } } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( city state developer[name] developer[salary] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.city, @address.state,  
                      @address.developer.name, @address.developer.salary ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_a_belongs_to_association_with_an_options_hash_of_excluded_fields_as_array_of_symbols2
    csv = @address.to_csv( :except=>[ :id, :developer_id, :address, :zip ], 
                           :include=>{ :developer=>{ :except=>[ :id, :created_at, :updated_at ] } } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( city state developer[name] developer[salary] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.city, @address.state,  
                      @address.developer.name, @address.developer.salary ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_with_custom_header_names
    csv = @address.to_csv( :headers=>{ :city=>"DeveloperCity", :state=>"DeveloperState" } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( DeveloperCity DeveloperState )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.city, @address.state ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end
  
  def test_find_to_csv_for_with_custom_header_names_with_a_belongs_to_association
    csv = @address.to_csv( :headers=>{ :city=>"DeveloperCity", :state=>"DeveloperState" },
                           :include=>{ :developer=>{ :only=>[:id] } } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( DeveloperCity DeveloperState developer[id] )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.city, @address.state, @address.developer.id ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end

  def test_find_to_csv_for_with_custom_header_names_for_a_belongs_to_association
    csv = @address.to_csv( :headers=>{ :city=>"DeveloperCity", :state=>"DeveloperState" },
                           :include=>{ :developer=>{ :headers=>{ :id=>"MYID" } } } )
    parsed_csv = parse_csv( csv )
    assert_equal 2, parsed_csv.size

    expected_headers = %W( DeveloperCity DeveloperState MYID )
    assert_equal expected_headers, parsed_csv.headers
    
    expected_data = [ @address.city, @address.state, @address.developer.id ]
    assert_equal expected_data.map{ |e| e.to_s }, parsed_csv.data.first
  end
  
  
end