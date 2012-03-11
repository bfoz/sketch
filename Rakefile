require "bundler/gem_tasks"

task :trim_whitespace do
  system(%Q[git status --short | awk '{if ($1 != "D" && $1 != "R") print $2}' | grep -e '.*\.rb$' | xargs sed -i '' -e 's/[ \t]*$//g;'])
end
