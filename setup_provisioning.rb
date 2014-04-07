#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'foreman_api'
require 'facter'
require 'ipaddr'
require './foreman.rb'

##ANSWERS_FILE = '/etc/foreman/foreman-installer-answers.yaml'
#ANSWERS_FILE = 'tmp/answers.yml'
#answers = YAML.load_file(ANSWERS_FILE)

DOMAIN = Facter.value :domain
FQDN = Facter.value :fqdn
FOREMAN_URL = "https://#{FQDN}"

# These should be later configurable from Kafo (answers file)
ENVIRONMENT = 'production'
USERNAME = 'admin'
PASSWORD = 'changeme'

# Foreman singleton instance
foreman = Foreman.new(:base_url => FOREMAN_URL, :username => USERNAME, :password => PASSWORD)

# we'll get specific interface later from script ran before kafo, now we detect all and select first
interfaces = (Facter.value :interfaces || '').split(',').reject { |i| i == 'lo' }.inject({}) do |ifaces, i|
  ip = Facter.value "ipaddress_#{i}"
  network = Facter.value "network_#{i}"
  netmask = Facter.value "netmask_#{i}"
  if ip && network && netmask
    cidr = "#{network}/#{IPAddr.new(netmask).to_i.to_s(2).count('1')}"
    from = IPAddr.new(ip).succ.to_s
    to = IPAddr.new(cidr).to_range.last.to_s
    ifaces[i] = {:ip => ip, :mask => netmask, :network => network, :cidr => cidr, :from => from, :to => to}
  end
  ifaces
end
interface = interfaces['eth0']

# setup part
default_proxy = foreman.smart_proxy.show! 'id' => FQDN,
                                          :error_message => "smart proxy #{FQDN} haven't been registered in foreman yet, installer failure?"
default_environment = foreman.environment.show! 'id' => ENVIRONMENT,
                                                :error_message => "environment #{ENVIRONMENT} not found in foreman, puppet haven't run yet?"
foreman_host = foreman.host.show! 'id' => FQDN,
                                  :error_message => "host #{FQDN} not found in foreman, puppet haven't run yet?"
os = foreman.operating_system.show! 'id' => foreman_host['operatingsystem_id'],
                                    :error_message => "operating system for #{FQDN} not found, DB inconsitency?"
medium = foreman.installation_medium.index('search' => "name ~ #{os['name']}").first

if os['architectures'].nil?
  foreman.operating_system.update 'id' => os['id'],
                                  'operatingsystem' => {'architecture_ids' => [foreman_host['architecture_id']]}
end

if os['media'].nil?
  foreman.operating_system.update 'id' => os['id'], 'operatingsystem' => {'medium_ids' => [medium['id']]}
end

default_domain = foreman.domain.show_or_ensure({'id' => DOMAIN},
                                               {'name' => DOMAIN,
                                                'fullname' => 'Default domain used for provisioning',
                                                'dns_id' => default_proxy['id']})

# we can't easily detect correct gateway, default gateway of this machine does not have
# to be necessarily gateway for provisioned machines, we should use custom --parameters for this
# otherwise default to nil
default_subnet = foreman.subnet.show_or_ensure({'id' => 'default'},
                                               {'name' => 'default',
                                                'mask' => interface[:mask],
                                                'network' => interface[:network],
                                                'dns_primary' => interface[:ip],
                                                'from' => interface[:from],
                                                'to' => interface[:to],
                                                'domain_ids' => [default_domain['id']],
                                                'dns_id' => default_proxy['id'],
                                                'dhcp_id' => default_proxy['id'],
                                                'tftp_id' => default_proxy['id']})

name = 'PXELinux global default'
template = <<EOS
DEFAULT menu
PROMPT 0
MENU TITLE PXE Menu
TIMEOUT 200
TOTALTIMEOUT 6000
ONTIMEOUT discovery

LABEL discovery
MENU LABEL Foreman Discovery
KERNEL boot/discovery-vmlinuz
APPEND rootflags=loop initrd=boot/discovery-initrd.img root=live:/foreman.iso rootfstype=auto ro rd.live.image rd.live.check rd.lvm=0 rootflags=ro crashkernel=128M elevator=deadline max_loop=256 rd.luks=0 rd.md=0 rd.dm=0 foreman.url=#{FOREMAN_URL} nomodeset selinux=0 stateless
EOS

foreman.config_template.show_or_ensure({'id' => name},
                                       {'template' => template})

foreman.config_template.build_pxe_default

# Default values used for provision template searching, some were renamed after 1.4
if os['family'] == 'Redhat'
  tmpl_name = 'Kickstart default'
  provision_tmpl_name = os['name'] == 'Redhat' ? 'Kickstart RHEL default' : tmpl_name
  ipxe_tmpl_name = 'Kickstart'
  ptable_name = foreman.version_14? ? 'Kickstart default' : 'RedHat default'
elsif os['family'] == 'Debian'
  tmpl_name = provision_tmpl_name = 'Preseed'
  ipxe_tmpl_name = nil
  ptable_name = foreman.version_14? ? 'Preseed default' : 'Ubuntu default'
end

ipxe_kind = foreman.version_14? ? 'iPXE' : 'gPXE'
{'provision' => provision_tmpl_name, 'PXELinux' => tmpl_name, ipxe_kind => ipxe_tmpl_name}.each do |kind_name, tmpl_name|
  next if tmpl_name.nil?
  kinds = foreman.template_kind.index
  kind = kinds.detect { |k| k['name'] == kind_name }

  # we prefer foreman_bootdisk templates
  tmpls = foreman.config_template.search "name ~ \"#{tmpl_name}*\" and kind = #{kind_name}"
  tmpl = tmpls.detect { |t| t['name'] =~ /.*sboot disk.*s/ } || tmpls.first
  raise StandardError, "no template found by search 'name ~ \"#{tmpl_name}*\"'" if tmpl.nil?

  # if there's no provisioning template for this os found it means, it's not associated so we add relation
  assigned_tmpl = foreman.config_template.first %Q(name ~ "#{tmpl_name}*" and kind = #{kind_name} and operatingsystem = "#{os['name']}")
  if assigned_tmpl.nil?
    foreman.config_template.update 'id' => tmpl['id'], 'config_template' => {'operatingsystem_ids' => [os['id']]}
  end

  # finally we setup default template from possible values we assigned in previous steps
  os_tmpls = foreman.os_default_template.index 'operatingsystem_id' => os['id']
  os_tmpl = os_tmpls.detect { |t| t['template_kind_name'] == kind_name }
  if os_tmpl.nil?
    foreman.os_default_template.create 'os_default_template' => {'config_template_id' => tmpl['id'], 'template_kind_id' => kind['id']},
                                       'operatingsystem_id' => os['id']
  end
end

ptable = foreman.partition_table.first! %Q(name ~ "#{ptable_name}*")

if os['ptables'].nil?
  foreman.partition_table.update 'id' => ptable['id'], 'ptable' => {'operatingsystem_ids' => [os['id']]}
end


default_hostgroup = foreman.hostgroup.show_or_ensure({'id' => 'base'},
                                                     {'name' => 'base',
                                                      'architecture_id' => foreman_host['architecture_id'],
                                                      'domain_id' => default_domain['id'],
                                                      'environment_id' => default_environment['id'],
                                                      'medium_id' => medium['id'],
                                                      'operatingsystem_id' => os['id'],
                                                      'ptable_id' => ptable['id'],
                                                      'puppet_ca_proxy_id' => default_proxy['id'],
                                                      'puppet_proxy_id' => default_proxy['id'],
                                                      'subnet_id' => default_subnet['id']})

foreman.setting.show_or_ensure({'id' => 'base_hostgroup'},
                               {'value' => default_hostgroup['name']})

puts "Your system is ready to provision using '#{default_hostgroup['name']}' hostgroup"
