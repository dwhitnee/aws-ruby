#!/usr/bin/ruby
#----------------------------------------------------------------------#
#  Simple IAM ruby script that creates a user and gets a private key
#----------------------------------------------------------------------

require 'rubygems'
require 'aws-sdk'
require 'yaml'

AWS.eager_autoload!

#require 'time'   # weird, why?
#----------------------------------------
def listUsers
  puts "IAM users:"

  summary = $iam.account_summary

  puts "Num users: #{summary[:users]} of quota #{summary[:users_quota]}"

  puts "IAM Groups:"
  $iam.groups.each do |group|
    puts " " + group.name
  end

  puts "IAM Users:"
  $iam.users.each do |user|
    puts " " + user.name
  end

#  access_key = u.access_keys.create
#  access_key.credentials

  # get your current access key
#  old_access_key = $iam.access_keys.first
#  puts "My access keys: " + $iam.access_keys.to_yaml
#  puts "My access keys: " + old_access_key
end

#----------------------------------------
def createUser( name, group )
  puts "Creating user #{name} ..."

  begin
    user = $iam.users.create( name )
    puts "Created #{ user.name }"
  rescue AWS::IAM::Errors::EntityAlreadyExists => e
    puts "#{name} already exists"
  rescue Exception => e 
    puts "Crap: #{e}"
  end

  # go get him again
  user = $iam.users[name]

  cred = user.access_keys.create
  puts "Creds: #{cred.credentials.to_yaml}"

  if group
    user.groups.add( group )
    puts "Added to #{group}"
  end

  # create a new access key
  #new_access_key = iam.access_keys.create
  #new_access_key.credentials
  #=> { :access_key_id => 'ID', :secret_access_key => 'SECRET' }

  # go rotate your keys/credentials ...

  # now disable the old access key
  #old_access_key.deactivate!

  # go make sure everything still works ...

  # all done, lets clean up
  #old_access_key.delete
end

#----------------------------------------
def setup
  config_file =
    File.join( File.dirname(__FILE__), "aws-iam.yml")

  unless File.exist?(config_file)
    puts <<END
Need aws.yml config file with
access_key_id: YOUR_ACCESS_KEY_ID
secret_access_key: YOUR_SECRET_ACCESS_KEY
END
    exit 1
  end

  AWS.config( YAML.load( File.read( config_file )))
end



#----------------------------------------
#  Simple iterate and update
#----------------------------------------

setup()

$iam = AWS::IAM.new()

#createUser("Freddy2","Test")

listUsers()

