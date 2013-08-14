require "twit/cli"

describe Twit::CLI do

  before do
    @cli = Twit::CLI.new

    # Mock out Twit library to avoid accidentally clobbering anything during
    # testing.
    stub_const("Twit", double('Twit'))
  end

  describe "init" do
    it "calls Twit.init" do
      expect(Twit).to receive(:init)
      @cli.invoke :init
    end
  end

  describe "save" do
    context "need to commit" do
      before do
        Twit.stub(:'nothing_to_commit?') { false }
      end
      it "calls Twit.save" do
        message = "my test commit message"
        expect(Twit).to receive(:save).with(message)
        @cli.invoke :save, [message]
      end
    end
  end

  describe "discard" do
    it "calls Twit.discard" do
      expect(Twit).to receive(:discard)
      @cli.invoke :discard
    end
  end

end
