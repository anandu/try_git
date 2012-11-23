#!/bin/ruby
# Destroys s3 buckets
# Please put .fog file with the cloud credentials in home directory
require 'rubygems'
require  'fog'
s3 =  Fog::Storage.new(:provider => 'AWS', :aws_access_key_id => Fog.credentials[:aws_access_key_id_rstemp], :aws_secret_access_key => Fog.credentials[:aws_secret_access_key_rstemp])
a=1
while a < 5 do
  s3_bucket = s3.directories.all.select{|buckets| buckets.key =~ /test-secondary-container/}.first
  s3.directories.get("#{s3_bucket.key}").files.all.each{|file1| file1.destroy}
  s3.directories.get("#{s3_bucket.key}").destroy
  a +=1
end
