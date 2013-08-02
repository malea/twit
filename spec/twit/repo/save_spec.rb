require 'tmpdir'
require 'securerandom'

require 'twit/repo'

describe Twit::Repo, "#save" do

  before do
    @tmpdir = Dir.mktmpdir
    @repo = Twit.init @tmpdir
    @oldwd = Dir.getwd
    Dir.chdir @tmpdir
  end

  after do
    Dir.chdir @oldwd
    FileUtils.remove_entry @tmpdir
  end

  context "files in working tree" do
    before do
      3.times do |i|
        File.open("file#{i}.txt", 'w') { |f| f.write("file#{i} contents\n") }
      end
    end
    it "commits the entire working tree" do
      @repo.save "created three files"
      expect(`git status`).to include('working directory clean')
    end
    it "makes a commit" do
      msg = "commit msg #{SecureRandom.hex(4)}"
      @repo.save msg
      expect(`git log`).to include(msg)
    end
  end

end