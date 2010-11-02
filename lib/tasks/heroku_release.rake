desc "Tag and push master branch to heroku"
task :heroku_release => ['heroku_release:tag', 'heroku_release:push']

namespace :heroku_release do
  HerokuRelease::Task.tasks.each do |task_name, description|
    desc(description) if description
    task task_name do
      HerokuRelease::Task.new.send(task_name)
    end
  end
end
