module Shatter
  module Service
    class Discovery
      class << self

        def deregister_service(service_url)
          zk = ZK.new (Shatter::Config.zookeeper_host)
          unless zk.exists?("/shater_service_instances/#{service_url}")
            zk.delete("/shater_service_instances/#{service_url}")
          end
        end

        def register_service(service_url)
          zk = ZK.new (Shatter::Config.zookeeper_host)
          unless zk.exists?("/shater_service_instances/#{service_url}")
            zk.create("/shater_service_instances/#{service_url}")
          end
        end

        def service_instance_url
          zk = ZK.new (Shatter::Config.zookeeper_host)
          url = zk.children("/shater_service_instances").sample
          zk.close
          url
        end

        def service_instance_url_for_uuid(uuid)
          druby_instance_url = nil
          key = Util.zookeeper_response_key(uuid)
          zk = ZK.new(Shatter::Config.zookeeper_host)
          druby_instance_url = zk.get(key)[0] if zk.exists?(key)
          zk.close
          Shatter.logger.debug "Service instance url for #{uuid} - #{druby_instance_url}"

          druby_instance_url
        end
      end
    end
  end
end