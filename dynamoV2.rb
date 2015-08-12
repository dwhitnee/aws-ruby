#!/usr/bin/ruby -I/Users/dwhitney/Documents/git/aws-sdk-ruby/lib

#----------------------------------------------------------------------
#  Simple first Dynamo (V2) ruby script that creates and lists Items in a table

# do this first:
#  gem install aws-sdk
#----------------------------------------------------------------------

require 'rubygems'
require 'aws-sdk'
require 'yaml'

#----------------------------------------
def setup
  config_file =
    File.join( File.dirname(__FILE__), "aws.yml")

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
def listUsers
  puts "Customers:"
  items = $dynamo.query( {
                           :table_name => "Customers"
                         });

  puts items.inspect


#  $customers.items.select().each do |customer|
#    puts customer.attributes.to_yaml
# end

  # user.item.attributes.to_h
end

#----------------------------------------
def createUser( id, data )
  puts "Creating ID = #{id}"
  puts "values: " + data.to_yaml

  cust = $customers.items.create( :id => id.to_s)
  cust.attributes.set( data )
end


#----------------------------------------
#  Simple iterate and update
#----------------------------------------

setup()

$dynamo = AWS::DynamoDB::ClientV2.new()

tables = $dynamo.list_tables

$customers = tables['Customers']
# Why do I need to say this again?  I already told you!
$customers.hash_key = [:id, :string]

#createUser( 2, {
#              :name => "Sydney",
#              :species => "canine",
#              :breed => "Golden Retriever" } )

listUsers()

