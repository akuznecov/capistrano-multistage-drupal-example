namespace :git do

task :default do
  git.list
end

desc "Git :: get information about branches and tags "
task :get do
  set :tags, `git ls-remote --tags #{repository} | sed 's?.*refs/tags/??' | sed "s/\\^{}//g" | sort -u -t . -k 1,1n -k 2,2n -k 3,3n`
  set :branches, `git ls-remote --heads #{repository} | sed 's?.*refs/heads/??'`
end

desc "Git :: list all available branches and tags"
task :list do
  git.get
  puts "Branches:\n#{branches}"
  puts "\n"
  puts "Tags:\n#{tags}"
end

desc "Git :: list 10 recent available branches and tags"
task :list10 do
  git.get
  puts "Branches:\n#{branches.split("\n").last(10).join("\n")}"
  puts "\n"
  puts "Tags:\n#{tags.split("\n").last(10).join("\n")}"
end

end #namespace :git