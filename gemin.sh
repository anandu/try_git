#!/bin/sh -e

cd /tmp
tsocks git clone http://github.com/robertcarr/RightAPI.git
cd RightAPI
cat <<EOF > ./right_api.gemspec
Gem::Specification.new do |s|
  s.name = %q{right_api}
  s.version = "0.1.1"
  s.date = %q{2010-10-07}
  s.authors = ["Robert Carr"]
  s.email = %q{support@rightscale.com}
  s.summary = %q{An abstraction class for interacting with the RightScale API.}
  s.homepage = %q{http://rightscale.com/}
  s.description = %q{An abstraction class for interacting with the RightScale API.}
  s.files = [ "README", "LICENSE", "RightAPI.rb"]
end
EOF
gem build right_api.gemspec && \
gem install ./right_api-0.1.1.gem
