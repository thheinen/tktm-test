# README

TODO

## Logging in `client.rb`

```ruby
    def run_ohai
      filter = Chef::Config[:minimal_ohai] ? %w{fqdn machinename hostname platform platform_version ohai_time os os_version init_package} : nil
      if Chef::Config.target_mode?
        ohai.transport_connection = transport_connection
        logger.warn('Running remote Ohai... please wait')
      end
      ohai.all_plugins(filter)
      events.ohai_completed(node)
    end
```