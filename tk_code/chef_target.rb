#
# Author:: Thomas Heinen (<thomas.heinen@gmail.com>)
#
# Copyright (C) 2023, Thomas Heinen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "chef_infra"

module Kitchen
  module Provisioner
    # Chef Target provisioner.
    #
    # @author Thomas Heinen <thomas.heinen@gmail.com>
    class ChefTarget < ChefInfra
      MIN_VERSION_REQUIRED = '18.2.5'.freeze

      # TODO: Theoretically could adapt this to use Habitat for explicit version request
      default_config :install_strategy, "none"
      def install_command
        ""
      end

      def chef_args(client_rb_filename)
        # Dummy execution to initialize and test remote connection (TODO: better?)
        connection = instance.remote_exec('')

        # TODO: Feels like the wrong spot to do this
        check_transport(connection)
        check_local_chef_client

        super.concat([
          "--target #{connection.train_uri}"
        ])
      end

      # TODO
      # - set `instance.transport` to `null` (avoid script execution)
      # - twist execution to run... differently

      def check_transport(connection)
        debug('Checking for active transport')

        unless connection.respond_to? 'train_uri'
          error("Chef Target Mode provisioner requires a Train-based transport like kitchen-transport-train")
          raise
        end

        debug('Kitchen transport responds to train_uri function call, as required')
      end

      def check_local_chef_client
        # - check for `chef-client` locally + right version
        debug('Checking for chef-client version')

        begin
          client_version = `chef-client -v`.chop.split(':')[-1]
        rescue Errno::ENOENT => e
          error("Error determining Chef Infra version: #{e.exception.message}")
          raise
        end

        minimum_version = Gem::Version.new(MIN_VERSION_REQUIRED)
        installed_version = Gem::Version.new(client_version)

        if installed_version < minimum_version
          error("Found Chef Infra version #{installed_version}, but require #{minimum_version} for Target Mode")
          raise
        end

        debug("Chef Infra found and version constraints match")
      end
    end
  end
end
