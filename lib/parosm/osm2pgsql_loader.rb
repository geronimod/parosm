require 'pg'

module Parosm
  class Osm2PgsqlLoader < Loader

    def initialize(db_infos, options = {})
      @options = options

      @db = db_infos[:db]
      @db_user = db_infos[:user]
      @db_password = db_infos[:password]

      @nodes = {}
      @ways = {}

      @routing = {}
      @routeable_nodes = {}

      Loader.route_types.each do |type|
        @routing[type] = {}
        @routeable_nodes[type] = {}
      end

      @options[:cache] ? load_cached : parse
    end

    def cache_filename
      File.join Loader.cache_dir, File.basename(@db) + ".pstore"
    end

    private
    def parse
      unless @pg ||= PG::Connection.new(:dbname => @db, :user => @db_user, :password => @db_password)
        raise "Could not connect to DB '#{@db}' with user '#{@user}'"
      end

      load_nodes(@pg)
      load_ways(@pg)
    end

    def load_nodes(db)
      db.exec("select * from planet_osm_nodes").each do |node|
        @nodes[node['id']] = {
          lat: node['lat'].to_f,
          lon: node['lon'].to_f,
          tags: {}
        }

        key = nil
        odd = true
        unless node['tags'].nil?
          node['tags'][1,node['tags'].size-2].split(',').each do |tag|
            if odd
              key = tag.to_sym
              odd = false
            else
              @nodes[node['id']][:tags][key] = tag unless useless_tags.include?(key)
              odd = true
            end
          end
        end
      end
    end

    def load_ways(db)
      db.exec("select * from planet_osm_ways").each do |way|
        @ways[way['id']] = {
          nodes: way['nodes'][1,way['nodes'].size-2].split(','),
          tags: {}
        }

        key = nil
        odd = true
        unless way['tags'].nil?
          way['tags'][1,way['tags'].size-2].split(',').each do |tag|
            if odd
              key = tag.to_sym
              odd = false
            else
              @ways[way['id']][:tags][key] = tag unless useless_tags.include?(key)
              odd = true
            end
          end
        end

        store_way @ways[way['id']]
      end
    end
  end
end
