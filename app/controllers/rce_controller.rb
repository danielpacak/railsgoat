class RceController < ApplicationController
  def index
    puts "lets run some commands", params[:cmd]
    @cmd = params[:cmd]
    @output = `#{@cmd}`
    puts "command output", @output
  end
end
