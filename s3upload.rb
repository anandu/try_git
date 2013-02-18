#!/bin/ruby
# creates s3 bucket
# copies your local file to newly created s3 bucket
# Please put .fog file with the cloud credentials in home directory
require 'rubygems'
require  'fog'
s3 =  Fog::Storage.new(:provider => 'AWS', :aws_access_key_id => Fog.credentials[:aws_access_key_id_rstemp], :aws_secret_access_key => Fog.credentials[:aws_secret_access_key_rstemp])

directory = s3.directories.create(
  :key    => "solr4-src", # globally unique name
  :public => true
)
  
file = directory.files.create(
  :key    => 'apache-solr-4.0.0.tgz',
  :body   => File.open("/tmp/apache-solr-4.0.0.tgz"),
  :public => true
)
puts "start sharing the file @"  
puts file.public_url
