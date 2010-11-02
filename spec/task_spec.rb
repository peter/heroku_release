require 'spec_helper'
require 'fileutils'

describe HerokuRelease::Task do
  before(:each) do
    @task = HerokuRelease::Task.new
    @config = HerokuRelease.config
    @config_before = HerokuRelease.config.dup
  end

  after(:each) do
    HerokuRelease.config = @config_before
  end
  
  describe "tasks" do
    it "is a Hash" do
      HerokuRelease::Task.tasks.is_a?(Hash).should be_true
    end
    
    it "corresponds to public instance methods" do
      HerokuRelease::Task.tasks.keys.map(&:to_s).sort.should == task_instance_methods      
    end
    
    def task_instance_methods
      HerokuRelease::Task.public_instance_methods(false).map(&:to_s).sort
    end
  end
  
  describe "push" do
    it "should execute a git push to heroku remote" do
      @task.expects(:execute).with("git push #{@config.heroku_remote} master")
      @task.push
    end
  end

  describe "tag" do
    it "create git tag with release name and comment and pushes it to origin and to heroku" do
      ENV['COMMENT'] = "the comment"
      @task.expects(:get_release_name).returns("release-123")
      @task.expects(:commit_version_file).never
      git = sequence('git')
      @task.expects(:execute).with("git tag -a release-123 -m 'the comment'").in_sequence(git)
      @task.expects(:execute).with("git push --tags origin").in_sequence(git)
      @task.expects(:execute).with("git push --tags #{@config.heroku_remote}").in_sequence(git)

      @task.tag
    end
    
    it "commits version file if version_file_path is set" do
      ENV['COMMENT'] = nil
      @config.version_file_path = "public/version"
      @task.expects(:get_release_name).returns("release-123")
      @task.expects(:commit_version_file).with("release-123")
      git = sequence('git')
      @task.expects(:execute).with("git tag -a release-123 -m 'Tagged release'").in_sequence(git)
      @task.expects(:execute).with("git push --tags origin").in_sequence(git)
      @task.expects(:execute).with("git push --tags #{@config.heroku_remote}").in_sequence(git)

      @task.tag
    end
  end

  describe "log" do
    it "outputs a changelog from the git tags and their comments" do
      git_tags = <<-END
      release-20101026-143729 Initial release
      release-20101027-225442 Some improvements
      release-20101029-085937 Major new feature
      END
      @task.expects(:git_tags_with_comments).returns(git_tags)
      @task.expects(:output).with(<<-END

- release-20101029-085937

Major new feature

- release-20101027-225442

Some improvements

- release-20101026-143729

Initial release

      END
      )

      @task.log
    end
  end

  describe "current_release" do
    it "should output latest release" do
      @task.expects(:releases).returns(%w(release-20100922-115151 release-20100922-122313))
      @task.expects(:output).with("release-20100922-122313")
      @task.current_release
    end
  end

  describe "previous_release" do
    it "outputs previous release if there is one" do
      @task.stubs(:releases).returns(%w(release-20100922-115151 release-20100922-122313))
      @task.expects(:output).with("release-20100922-115151")
      @task.previous_release
    end
    
    it "says there is no previous release if there is none" do
      @task.stubs(:releases).returns(%w(release-20100922-122313))
      @task.expects(:output).with("no previous release found")
      @task.previous_release      
    end
  end

  describe "pending" do
    it "executes a git log between current release and HEAD" do
      @task.expects(:current_release_version).returns("release-123")
      @task.expects(:execute).with("git log release-123..HEAD")
      @task.pending
    end
  end

  describe "rollback" do
    it "pushes previous release tag to heroku and deletes current release tag" do
      git = sequence('git')
      @task.expects(:previous_release_version).returns("release-previous")
      @task.expects(:current_release_version).returns("release-current")
      @task.expects(:execute).with("git push -f #{@config.heroku_remote} release-previous:master").in_sequence(git)
      @task.expects(:execute).with("git tag -d release-current").in_sequence(git)
      @task.expects(:execute).with("git push #{@config.heroku_remote} :refs/tags/release-current").in_sequence(git)
      @task.expects(:execute).with("git push origin :refs/tags/release-current").in_sequence(git)
      
      @task.rollback
    end
  end

  describe "output" do
    it "invokes puts with message" do
      @task.expects(:puts).with("a message")
      @task.send(:output, "a message")
    end
  end
  
  describe "execute" do
    it "executes a command and outputs the result" do
      @task.expects(:output).with("foobar")
      @task.send(:execute, "echo foobar")
    end

    it "outputs empty line if there is no output" do
      @task.expects(:output).with("")
      @task.send(:execute, "echo")
    end
  end
      
  describe "get_release_name" do
    it "generates a timestamped tag name" do
      @task.send(:get_release_name).should =~ /release-\d\d\d\d\d\d\d\d-\d\d\d\d\d\d/
    end
  end
  
  describe "commit_version_file(release_name)" do
    before(:each) do
      @path = "spec/version"      
    end
    
    after(:each) do
      FileUtils.rm_f(@path)
    end
    
    it "writes release_name to version_file_path and commits that file" do
      git = sequence('git')
      @task.expects(:execute).with("git add #{@path}").in_sequence(git)
      @task.expects(:execute).with("git commit -m 'Updated version file to release-123'").in_sequence(git)
      @task.expects(:execute).with("git push origin master").in_sequence(git)

      HerokuRelease.config.version_file_path = @path
      @task.send(:commit_version_file, "release-123")

      File.read(@path).should == "release-123"
    end
  end

  describe "git_tags_with_comments" do
    it "works" do
      @task.send(:git_tags_with_comments)
    end
  end

  describe "releases" do
    it "parses out list of releases from git tags" do
      @task.expects(:git_tags).returns(<<-END
release-20100922-115151
release-20100922-122313
foobar
release-20100926-173016
      END
      )
      
      @task.send(:releases).should == %w(release-20100922-115151 release-20100922-122313 release-20100926-173016)
    end
  end

  describe "git_tags" do
    it "works" do
      @task.send(:git_tags)
    end
  end
end
