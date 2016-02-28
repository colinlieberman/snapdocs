require "#{ENV['APPROOT']}/app/app"
require 'logger'

logger = Logger.new( "#{ENV['APPROOT']}/log/applog" )
use Rack::CommonLogger, logger

run SnapdocsExercise

