execute "apt-get update -y"
execute "apt-get upgrade -y"

packages = %w{
  bison
  build-essential
  curl
  exuberant-ctags
  flex
  g++
  git-core
  gperf
  libcurl4-openssl-dev
  libffi-dev
  libfontconfig1-dev
  libfreetype6
  libicu-dev
  libjpeg-dev
  libpng-dev
  libreadline-dev
  libsqlite3-dev
  libssl-dev
  libx11-dev
  libxext-dev
  libxml2-dev
  libxslt1-dev
  libyaml-dev
  memcached
  perl
  python
  python-software-properties
  redis-server
  software-properties-common
  sqlite3
  unzip
  zlib1g-dev
}

package packages

phantomjs = "phantomjs-1.9.8-linux-x86_64"
remote_file "/tmp/#{phantomjs}.tar.bz2" do
  source "https://bitbucket.org/ariya/phantomjs/downloads/#{phantomjs}.tar.bz2"
  action :create
end

bash "install_phantomjs" do
  cwd "/tmp"
  not_if { ::Dir.exist?("/usr/local/share/#{phantomjs}") }
  code <<-SCRIPT
    tar xvjf #{phantomjs}.tar.bz2
    mv #{phantomjs} /usr/local/share
  SCRIPT
end

link "/usr/local/bin/phantomjs" do
  to "/usr/local/share/#{phantomjs}/bin/phantomjs"
end

bash "install postgres" do
  user "root"
  not_if { ::File.exist?("/etc/apt/sources.list.d/pgdg.list") }
  code <<-SCRIPT
    echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      | apt-key add -
    apt-get update -y
    apt-get install -y postgresql-9.4 libpq-dev \
      postgresql-contrib-9.4 postgresql-client-common
  SCRIPT
end

execute "curl -sL https://deb.nodesource.com/setup | bash -"
package "nodejs"

sql = "SELECT 1 FROM pg_roles WHERE rolname='vagrant'"
create_user = "createuser -s -e -w vagrant"
execute "psql postgres -tAc \"#{sql}\" | grep -q 1 || #{create_user}" do
  user "postgres"
end

sql = "SELECT 1 FROM pg_roles WHERE rolname='vagrant'"
execute "createdb" do
  user "vagrant"
  not_if { "psql postgres -tAc \"#{sql}\" | grep -q 1" }
end

git "/usr/local/rbenv" do
  repository "https://github.com/sstephenson/rbenv.git"
end

file "/etc/profile.d/rbenv.sh" do
  content <<-CONTENT
export RBENV_ROOT="/usr/local/rbenv"
export PATH="/usr/local/rbenv/bin:$PATH"
eval "$(rbenv init -)"
CONTENT
end

directory "/usr/local/rbenv/plugins"
git "/usr/local/rbenv/plugins/ruby-build" do
  repository "https://github.com/sstephenson/ruby-build.git"
end

ruby_version = `cat .ruby-version`.strip
bash "install_ruby" do
  user "root"
  not_if { ::Dir.exist?("/usr/local/rbenv/versions/#{ruby_version}") }
  code <<-EOH
source /etc/profile.d/rbenv.sh
rbenv install #{ruby_version}
rbenv global #{ruby_version}
EOH
end

bash "install_bundler" do
  user "root"
  code <<-EOH
source /etc/profile.d/rbenv.sh
gem install bundler --no-ri --no-rdoc
EOH
end

execute "cp .env.example .env.local" do
  user "vagrant"
  cwd "/vagrant"
  not_if { ::File.exist?("/vagrant/.env.local") }
end

["redis-server", "postgresql"].each do |service_name|
  service service_name do
    action [:enable, :start]
  end
end
