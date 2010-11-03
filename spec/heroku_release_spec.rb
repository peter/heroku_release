require 'spec_helper'

describe HerokuRelease do
  before(:each) do
    @config_before = HerokuRelease.config.dup
  end
  
  after(:each) do
    HerokuRelease.config = @config_before
  end
  
  describe "config" do
    it "defaults heroku_remote to heroku" do
      config.heroku_remote.should == "heroku"
    end
    
    it "can set heroku_remote" do
      config.heroku_remote = "production"
      config.heroku_remote.should == "production"
    end
    
    it "defaults version_file_path to nil" do
      config.version_file_path.should be_nil
    end
    
    it "can set version_file_path" do
      config.version_file_path = "public/system/version"
      config.version_file_path.should == "public/system/version"
    end
    
    it "defaults changelog_path to nil" do
      config.changelog_path.should be_nil
    end
    
    it "can set changelog_path" do
      config.changelog_path = "CHANGELOG"
      config.changelog_path.should == "CHANGELOG"
    end
  end
  
  def config
    HerokuRelease.config
  end
end
