#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "java"

case node["platform"]
when "centos","redhat","fedora"
  node.set["tomcat"]["user"] = "tomcat"
  node.set["tomcat"]["group"] = "tomcat"
  node.set["tomcat"]["home"] = "/usr/share/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["base"] = "/usr/share/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["config_dir"] = "/etc/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["log_dir"] = "/var/log/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["tmp_dir"] = "/var/cache/tomcat#{node['tomcat']['base_version']}/temp"
  node.set["tomcat"]["work_dir"] = "/var/cache/tomcat#{node['tomcat']['base_version']}/work"
  node.set["tomcat"]["context_dir"] = "#{node['tomcat']["config_dir"]}/Catalina/localhost"
  node.set["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{node['tomcat']['base_version']}/webapps"
when "debian","ubuntu"
  node.set["tomcat"]["user"] = "tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["group"] = "tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["home"] = "/usr/share/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["base"] = "/var/lib/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["config_dir"] = "/etc/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["log_dir"] = "/var/log/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["tmp_dir"] = "/tmp/tomcat#{node['tomcat']['base_version']}-tmp"
  node.set["tomcat"]["work_dir"] = "/var/cache/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["context_dir"] = "#{node['tomcat']["config_dir"]}/Catalina/localhost"
  node.set["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{node['tomcat']['base_version']}/webapps"
else
  node.set["tomcat"]["user"] = "tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["group"] = "tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["home"] = "/usr/share/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["base"] = "/var/lib/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["config_dir"] = "/etc/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["log_dir"] = "/var/log/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["tmp_dir"] = "/tmp/tomcat#{node['tomcat']['base_version']}-tmp"
  node.set["tomcat"]["work_dir"] = "/var/cache/tomcat#{node['tomcat']['base_version']}"
  node.set["tomcat"]["context_dir"] = "#{node['tomcat']["config_dir"]}/Catalina/localhost"
  node.set["tomcat"]["webapp_dir"] = "/var/lib/tomcat#{node['tomcat']['base_version']}/webapps"
end

tomcat_pkgs = value_for_platform(
  ["debian","ubuntu"] => {
    "default" => ["tomcat#{node["tomcat"]["base_version"]}","tomcat#{node["tomcat"]["base_version"]}-admin"]
  },
  ["centos","redhat","fedora"] => {
    "default" => ["tomcat#{node["tomcat"]["base_version"]}","tomcat#{node["tomcat"]["base_version"]}-admin-webapps"]
  },
  "default" => ["tomcat#{node["tomcat"]["base_version"]}"]
)

tomcat_pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

service "tomcat" do
  service_name "tomcat#{node["tomcat"]["base_version"]}"
  case node["platform"]
  when "centos","redhat","fedora"
    supports :restart => true, :status => true
  when "debian","ubuntu"
    supports :restart => true, :reload => true, :status => true
  end
  action [:enable, :start]
end

case node["platform"]
when "centos","redhat","fedora"
  template "/etc/sysconfig/tomcat#{node["tomcat"]["base_version"]}" do
    source "sysconfig_tomcat6.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "tomcat")
  end
else
  template "/etc/default/tomcat#{node["tomcat"]["base_version"]}" do
    source "default_tomcat6.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "tomcat")
  end
end

template "#{node["tomcat"]["config_dir"]}/server.xml" do
  source "server.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "tomcat")
end

template "#{node["tomcat"]["config_dir"]}/context.xml" do
  source "context.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "tomcat")
end
