# frozen_string_literal: true

require "zk"
module Shatter
  module Service
    class Discovery
      class << self
        def connection_pool
          @connection_pool ||= ZK::Pool::Bounded.new(Shatter::Config.zookeeper_host)
        end

        def deregister_service(service_url)
          zk = connection_pool.checkout
          if zk.exists?("/shater_service_instances/#{service_url}")
            zk.delete("/shater_service_instances/#{service_url}")
          end
          connection_pool.checkin(zk)
        end

        def register_service(service_url)
          Shatter.logger.info "Registering #{service_url} to zookeeper"
          zk = connection_pool.checkout
          unless zk.exists?("/shater_service_instances/#{service_url}")
            created = zk.create("/shater_service_instances/#{service_url}")
            Shatter.logger.info "Registered #{created}"
          end
          connection_pool.checkin(zk)
        end

        def service_instance_url
          service_instance_urls.sample
        end

        def service_instance_urls
          zk = connection_pool.checkout
          urls = zk.children("/shater_service_instances")
          connection_pool.checkin(zk)
          urls
        end

        def populate_result_location(uuid)
          zk = connection_pool.checkout
          zk.create(Util.zookeeper_response_key(uuid), my_host)
          connection_pool.checkin(zk)
        end

        def my_host
          my_ip = ENV["HOST_NAME"] || "localhost"
          "#{my_ip}:#{Shatter::Config.service_port}"
        end

        def service_instance_url_for_uuid(uuid)
          key = Util.zookeeper_response_key(uuid)
          zk = connection_pool.checkout
          druby_instance_url = zk.get(key)[0] if zk.exists?(key)
          connection_pool.checkin(zk)
          druby_instance_url
        end
      end
    end
  end
end
