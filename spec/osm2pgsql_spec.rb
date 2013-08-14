require 'spec_helper'
require 'parosm'

def db_infos
  { :user => 'parosm', :password => 'parosm', :db => 'parosm' }
end

describe Parosm::Osm2PgsqlLoader do
  before(:all) do
    cmd = "osm2pgsql -s -U #{db_infos[:user]} -d #{db_infos[:db]} -l spec/spec.osm > /dev/null 2>&1"
    raise "Couldn't reset sandbox db with test data" unless system({'PGPASSWORD' => db_infos[:password]}, cmd)
  end

  def common_specs(loader)
    loader.nodes.keys.size.should eq 534
    loader.ways.keys.size.should  eq 135

    loader.routing[:cycle].keys.size.should eq 240
    loader.routing[:car].keys.size.should   eq 240
    loader.routing[:train].keys.size.should eq 0
    loader.routing[:foot].keys.size.should  eq 281
    loader.routing[:horse].keys.size.should eq 216
  end

  describe "whitout cache" do
    before :each do
      @loader = Parosm::Osm2PgsqlLoader.new db_infos
    end

    it "should load the correct data" do
      common_specs @loader
    end

    it "should have the correct nodes" do
      map = { "448193026" => 1, "448193243" => 1, "448193220" => 1, "318099173" => 1 }
      @loader.routing[:foot]["448193024"].should eq(map)
    end
  end

  describe "with cache" do
    it "should exists the cached version" do
      @loader = Parosm::Osm2PgsqlLoader.new db_infos, :cache => true
      File.exists?(@loader.cache_filename).should eq true
      File.zero?(@loader.cache_filename).should eq false
    end

    it "should let change the cache dir" do
      cache_dir = File.join File.dirname(__FILE__), "..", "cache"
      Parosm::Osm2PgsqlLoader.cache_dir = cache_dir
      @loader = Parosm::Osm2PgsqlLoader.new db_infos, :cache => true
      # define how is named the cache file
      #cache_filename = File.join Parosm::Osm2PgsqlLoader.cache_dir, File.basename(spec_osm_file) + ".pstore"
      #@loader.cache_filename.should eq cache_filename
    end

    it "should have stored the same data" do
      @without_cache = Parosm::Osm2PgsqlLoader.new db_infos
      @with_cache    = Parosm::Osm2PgsqlLoader.new db_infos, :cache => true

      common_specs @without_cache
      common_specs @with_cache

      @without_cache.nodes.should eq @with_cache.nodes
      @without_cache.ways.should  eq @with_cache.ways
      @without_cache.routing.should eq @with_cache.routing
      @without_cache.routeable_nodes.should eq @with_cache.routeable_nodes
    end

  end

end
