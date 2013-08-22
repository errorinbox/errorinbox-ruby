require "spec_helper"

describe ErrorInbox do
  describe ".notify" do
    let(:ex) { double("exception") }
    let(:env) { { :foo => "bar" } }

    it "calls notifier to handle the exception" do
      ErrorInbox::Notifier.
        should_receive(:new).
        with(env).
        and_return(notifier = double("notifier"))

      notifier.
        should_receive(:save).
        with(ex).
        and_return(true)

      expect(described_class.notify(ex, env)).to eq(true)
    end
  end
end
