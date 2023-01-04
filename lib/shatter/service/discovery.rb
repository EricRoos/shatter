module Shatter
  module Service
    class Discovery
      class << self

        def deregister_service(service_url)
          zk = ZK.new (Shatter::Config.zookeeper_host)
          if zk.exists?("/shater_service_instances/#{service_url}")
            zk.delete("/shater_service_instances/#{service_url}")
          end
          zk.close
        end

        def register_service(service_url)
          Shatter.logger.info "Registering #{service_url} to zookeeper"
          zk = ZK.new (Shatter::Config.zookeeper_host)
          unless zk.exists?("/shater_service_instances/#{service_url}")
            created = zk.create("/shater_service_instances/#{service_url}")
            Shatter.logger.info "Registered #{created}"
          end
          puts zk.children("/shater_service_instances")
          zk.close
        end

        def service_instance_url
          service_instance_urls.sample
        end

        def service_instance_urls
          zk = ZK.new (Shatter::Config.zookeeper_host)
          urls = zk.children("/shater_service_instances")
          zk.close
          urls
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