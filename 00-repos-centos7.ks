repo --name=centos --mirrorlist=http://mirrorlist.centos.org/?release=7&arch=$basearch&repo=os
repo --name=centos-updates --mirrorlist=http://mirrorlist.centos.org/?release=7&arch=$basearch&repo=updates
repo --name=scl-ruby193-el7 --noverifyssl --baseurl=https://www.softwarecollections.org/repos/rhscl/ruby193/epel-7-x86_64
repo --name=scl-v8314-el7 --noverifyssl --baseurl=https://www.softwarecollections.org/repos/rhscl/v8314/epel-7-x86_64
repo --name=epel7 --mirrorlist=http://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch
repo --name=foreman-el7 --baseurl=http://yum.theforeman.org/nightly/el7/$basearch/
repo --name=foreman-plugins-el7 --baseurl=http://yum.theforeman.org/plugins/nightly/el7/x86_64/
