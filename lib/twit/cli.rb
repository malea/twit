require 'thor'
require 'twit'

module Twit

  # Automatically-built command-line interface (using Thor).
  class CLI < Thor
    include Thor::Actions

    desc "init", "Create an empty repository in the current directory"
    # See {Twit::init}
    def init
      begin
        if Twit.is_repo?
          say "You are already in a repository! (Root directory: #{Twit.repo.root})"
          return
        end
        Twit.init
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "save [DESCRIBE_CHANGES]", "Take a snapshot of all files"
    # See {Twit::Repo#save}.
    def save message = nil
      begin
        if Twit.nothing_to_commit?
          say "No new edits to save"
          return
        end
        while message.nil? || message.strip == ""
          message = ask "Please supply a message describing your changes:"
        end
        Twit.save message
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "saveas [NEW_BRANCH] [DESCRIBE_CHANGES]", "Save snapshot to new branch"
    # See {Twit::Repo#saveas}.
    def saveas branch = nil, message = nil
      while branch.nil? || branch.strip == ""
        branch = ask "Please supply the name for your new branch:"
      end
      begin
        if (not Twit.nothing_to_commit?) && message.nil?
          message = ask "Please supply a message describing your changes:"
        end
        begin
          Twit.saveas branch, message
        rescue InvalidParameter => e
          if /already exists/.match e.message
            say "Cannot saveas to existing branch. See \"twit help include_into\""
          else
            say "Error: #{e.message}"
          end
        end
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

    desc "open [BRANCH]", "Open a branch"
    # See {Twit::Repo#open}.
    def open branch = nil
      while branch.nil? || branch.strip == ""
        branch = ask "Please enter the name of the branch to open:"
      end
      begin
        Twit.open branch
      rescue Error => e
        say "Error: #{e.message}"
      else
        say "Opened #{branch}."
      end
    end

    desc "list", "Display a list of branches"
    # See {Twit::Repo#list} and {Twit::Repo#current_branch}
    def list
      begin
        @current = Twit.current_branch
        @others = Twit.list.reject { |b| b == @current }
      rescue Error => e
        say "Error: #{e.message}"
        return
      end
      say "Current branch: #{@current}"
      say "Other branches:"
      @others.each do |branch|
        say "- #{branch}"
      end
    end

    desc "include", "Integrate changes from another branch"
    # See {Twit::Repo#include}.
    def include other_branch = nil
      while other_branch.nil? || other_branch.strip == ""
        other_branch = ask "Please enter the name of the branch to pull changes from:"
      end
      begin
        @success = Twit.include other_branch
      rescue Error => e
        say "Error: #{e.message}"
        return
      end
      if @success
        say "Changes from #{other_branch} successfully included into #{Twit.current_branch}."
        say "Use \"twit save\" to save them."
      else
        say "Conflicts detected! Fix them, then use \"twit save\" to save the changes."
      end
    end

    desc "include_into", "Integrate changes into another branch"
    # See {Twit::Repo#include}.
    def include_into other_branch = nil
      while other_branch.nil? || other_branch.strip == ""
        other_branch = ask "Please enter the name of the branch to push changes into:"
      end
      begin
        @original = Twit.current_branch
        @success = Twit.include_into other_branch
      rescue Error => e
        say "Error: #{e.message}"
        return
      end
      if @success
        say "Changes from #{@original} successfully included into #{other_branch}."
        say "Use \"twit save\" to save them."
      else
        say "Conflicts detected! Fix them, then use \"twit save\" to save the changes."
      end
    end

    desc "discard", "PERMANTENTLY delete all changes since last save"
    # See {Twit::Repo#discard}.
    def discard
      begin
        Twit.discard
      rescue Error => e
        say "Error: #{e.message}"
      end
    end

  end

end
