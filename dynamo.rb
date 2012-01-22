#!/usr/bin/ruby
#----------------------------------------------------------------------#
#  Simple first Dynamo ruby script that creates and lists Items in a table
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
Need aws.yml with
access_key_id: YOUR_ACCESS_KEY_ID
secret_access_key: YOUR_SECRET_ACCESS_KEY
END
    exit 1
  end

  AWS.config( YAML.load(File.read(config_file)))
end


#----------------------------------------
def listUsers
#    puts "TABLE" + customers.to_yaml
#    puts "ITEMS:" + customers.items.to_yaml

  puts "Customers:"
  $customers.items.select().each do |customer|
    puts customer.attributes.to_yaml
  end

  # user.item.attributes.to_h
end

#----------------------------------------
def createUser( id, data )
  # puts "TABLE" + customers.to_yaml

  puts "Creating ID = #{id}"
  puts "values: " + data.to_yaml

  cust = $customers.items.create( :id => id.to_s)

  cust.attributes.set( data )
end





#----------------------------------------
#  Simple iterate and update
#----------------------------------------

setup

$dynamo = AWS::DynamoDB.new()

$customers = $dynamo.tables['Customers']
$customers.hash_key = [:id, :string]

#createUser( 2, { :name => "Sydney", :species => "canine",
#                 :breed => "Golden Retriever" } )

listUsers

