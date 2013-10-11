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
Need aws.yml config file with
access_key_id: YOUR_ACCESS_KEY_ID
secret_access_key: YOUR_SECRET_ACCESS_KEY
END
    exit 1
  end

  AWS.config( YAML.load( File.read( config_file )))
end

def batchReadFromDynamo( tableName, primary, secondary )

  table = @@dynamo.tables[ tableName.to_s ]

  # we have to tell Dynamo our schema
  table.hash_key  = { :id => :string }
  table.range_key = { :id2 => :string }


  # batch_get.table( tableName, :all, items)

  items = []
  begin
    result = table.items.query(
                         :select => :all,
                         :hash_value => primary,
                         :range_value => secondary )

    # make array of objects
    return result.select.map { |i| i.attributes }

  rescue Exception => e # Requested resource not found
    logger.error "Oops: #{e}"
    logger.error e.backtrace.join("\n")
  end
end

#----------------------------------------
#  So how do I query by Realm?
# Get all DeliveryDates for a Dept
# Get all DeliveryDates for a Program
#----------------------------------------

setup()

db = AWS::DynamoDB.new()

items = db.batchReadFromDynamo("Test2", "ec2", nil)

@data = {}
@items.each do |item|
  milestone = item['id2']
  team = item['id']

  @data[team] = {} if @data[team] == nil

  @data[team][milestone] = {
    :note => item['comment'],
    :status => item['status'],
    :date => item['date']
  }

end

puts @data.inspect
