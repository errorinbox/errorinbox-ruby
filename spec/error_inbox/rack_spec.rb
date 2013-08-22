require "spec_helper"
require "error_inbox/rack"

describe ErrorInbox::Rack do
  let(:app) { double("app") }
  subject { described_class.new(app) }

  it "sends exception raised by app#call" do
    app.
      should_receive(:call).
      with({}).
      and_raise(RuntimeError)

    ErrorInbox.
      should_receive(:notify).
      with(an_instance_of(RuntimeError), {}).
      once

    expect { subject.call({}) }.to raise_error(RuntimeError)
  end

  it "sends exception stored in rack.exception env variable" do
    error = double("error")
    env = { "rack.exception" => error }

    app.
      should_receive(:call).
      with(env).
      and_return("response")

    ErrorInbox.
      should_receive(:notify).
      with(error, env).
      once

    expect(subject.call(env)).to eq("response")
  end

  it "sends exception stored in action_dispatch.exception env variable" do
    error = double("error")
    env = { "action_dispatch.exception" => error }

    app.
      should_receive(:call).
      with(env).
      and_return("response")

    ErrorInbox.
      should_receive(:notify).
      with(error, env).
      once

    expect(subject.call(env)).to eq("response")
  end

  it "sends exception stored in sinatra.error env variable" do
    error = double("error")
    env = { "sinatra.error" => error }

    app.
      should_receive(:call).
      with(env).
      and_return("response")

    ErrorInbox.
      should_receive(:notify).
      with(error, env).
      once

    expect(subject.call(env)).to eq("response")
  end

  it "does nothing if no errors at all" do
    app.
      should_receive(:call).
      with({}).
      and_return("response")

    expect(subject.call({})).to eq("response")
  end
end
