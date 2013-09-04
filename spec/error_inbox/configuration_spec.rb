require "spec_helper"

describe ErrorInbox::Configuration do
  it "appends the block in the ignores attribute" do
    expect { subject.ignore_if { true } }.to change{ subject.ignores.size }.from(0).to(1)
  end
end
