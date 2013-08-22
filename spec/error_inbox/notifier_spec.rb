require "spec_helper"

describe ErrorInbox::Notifier do
  let(:ex) { double("exception", :message => "some message", :backtrace => ["a.rb:10", "b.rb:11"]) }

  around do |example|
    Timecop.travel(2013, 8, 21, 11, 57, 0) do
      example.run
    end
  end

  it "sends rack exceptions" do
    ErrorInbox.stub(:configuration => double("configuration", :username => "foo", :password => "bar"))

    stub_request(:post, "http://foo:bar@oops.errorinbox.com").
      with(
        :body => "{\"type\":\"RSpec::Mocks::Mock\",\"message\":\"some message\",\"backtrace\":\"a.rb:10\\nb.rb:11\",\"environmentName\":null,\"occurredAt\":\"2013-08-21T11:57:00-03:00\",\"request\":{\"url\":\"://::0\"},\"environment\":{\"foo\":\"bar\"}}",
        :headers => { "Content-Type" => "application/json" }
      ).
      to_return(
        :status => 201,
        :body => "{\"id\":1}",
        :headers => { "Content-Type" => "application/json" }
      )

    notifier = described_class.new(:rack_env => { :foo => "bar" })
    expect(notifier.save(ex)).to eq(1)
  end

  it "raises an error if credentials are missing" do
    ErrorInbox.stub(:configuration => double("configuration", :username => nil, :password => nil))

    notifier = described_class.new(:rack_env => { :foo => "bar" })
    expect { notifier.save(ex) }.to raise_error(ErrorInbox::MissingCredentialsError)
  end

  it "raises an error if credentials are invalid" do
    ErrorInbox.stub(:configuration => double("configuration", :username => "foo", :password => "bar"))

    stub_request(:post, "http://foo:bar@oops.errorinbox.com").
      with(
        :body => "{\"type\":\"RSpec::Mocks::Mock\",\"message\":\"some message\",\"backtrace\":\"a.rb:10\\nb.rb:11\",\"environmentName\":null,\"occurredAt\":\"2013-08-21T11:57:00-03:00\",\"request\":{\"url\":\"://::0\"},\"environment\":{\"foo\":\"bar\"}}",
        :headers => { 'Content-Type'=>'application/json' }
      ).
      to_return(
        :status => 403,
        :body => "{\"error\":\"forbidden\"}",
        :headers => { "Content-Type" => "application/json" }
      )

    notifier = described_class.new(:rack_env => { :foo => "bar" })
    expect { notifier.save(ex) }.to raise_error(ErrorInbox::InvalidCredentialsError)
  end
end
