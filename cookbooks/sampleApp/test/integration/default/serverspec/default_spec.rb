require 'spec_helper'

describe port(9000) do
  it { should be_listening }
  it { should be_listening.with('tcp') }
end

# unicorn directly
describe command('wget -qO- http://localhost:9000') do
  its('stdout') { should match (/This page has been accessed [0-9]+ times/) }
end

# and nginx
describe command('wget -qO- http://localhost:80') do
  its('stdout') { should match (/This page has been accessed [0-9]+ times/) }
end
