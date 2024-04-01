# require_relative "../mixin/which"

module TargetIO
  class HTTP
    SUPPORTED_COMMANDS = %w[curl wget]

    def initialize(_); end

    def method_missing(verb, url, headers = {})
      cmd = nil
      SUPPORTED_COMMANDS.each do |name|
        executable = which(name).chop
        next unless executable

        cmd = self.send(name.to_sym, executable, verb.to_s.upcase, url, headers)
        break
      end

      raise "Target needs one of #{SUPPORTED_COMMANDS.join('/')} for HTTP requests to work" unless cmd

      connection = Chef.run_context&.transport_connection
      connection.run_command(cmd).stdout
    end

    def curl(cmd, verb, url, headers)
      cmd += headers.map { |name, value| " --header '#{name}: #{value}'"}.join
      cmd += " --request #{verb} "
      cmd += url
    end

    def wget(cmd, verb, url, headers)
      cmd += headers.map { |name, value| " --header '#{name}: #{value}'"}.join
      cmd += " --method #{verb}"
      cmd += " --output-document=- "
      cmd += url
    end

    # extend Chef::Mixin::Which
    def which(cmd)
      connection = Chef.run_context&.transport_connection
      connection.run_command("which #{cmd}").stdout
    end
  end
end
