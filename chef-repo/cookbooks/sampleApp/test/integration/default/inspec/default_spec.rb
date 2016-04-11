
# describe port(9000) do
#   it { should be_listening }
#   its('protocols') { should eq ['tcp'] }
# end

describe command('wget -qO- http://localhost:9000') do
  its('stdout') { should match (/This is request [0-9]/) }
end