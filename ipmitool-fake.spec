Name:           ipmitool-fake
Version:        0.1
#Release:        1%{?dist}
Release:        1
Summary:        ipmitool-fake for testing STONITH configuration on KVM environment

Group:          System Environment/Base
License:        GPL
URL:            http://osdn.jp/projects/linux-ha/
#Source0:        %{name}-%{version}-%{release}.%{_arch}.tar.gz
Source0:        ipmitool-fake.tar.gz
BuildArch: noarch

#BuildRequires:  
Requires:       ipmitool

%description
ipmitool-fake for testing STONITH configuration on KVM environment

%prep
%setup -q -n ipmitool-fake


%build


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%dir /usr/share/ipmitool-fake
/usr/share/ipmitool-fake/*
%doc


%post
/usr/share/ipmitool-fake/install-fake.sh -i

%preun
/usr/share/ipmitool-fake/install-fake.sh -u


%changelog
