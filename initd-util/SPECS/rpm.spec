
# Parametrage du numero de version
%if %{?MYAPP_REL:1}%{!?MYAPP_REL:0}
%define myapp_rel    %{MYAPP_REL}
%else
%define myapp_rel    1.0.0
%endif

# Parametrage du numero de build
%if %{?MYAPP_BUILD:1}%{!?MYAPP_BUILD:0}
%define myapp_build  %{MYAPP_BUILD}
%else
%define myapp_build  1
%endif

Name        : initd-util
Version     : %{myapp_rel}
Release     : %{myapp_build}
Summary     : Outils shell
Group       : Applications/Communications
URL         : https://github.com/smougenot/tomcat2service
Vendor      : smougenot
Packager    : smougenot
License     : Apache 2
BuildArch   : noarch

# ne pas utiliser %{_lib} car il pointe sur /lib64 même pour un rpm noarch
%define myappdir           /lib/%{name}

BuildRoot: %{_tmppath}/build-%{name}-%{version}-%{release}

Source0: lib

%description
Outils pour le shell. Version %{myapp_rel} 

%prep
%setup -q -c -T

%build

%install
# Faire du propre
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{myappdir}

# Construction
cp -r %{SOURCE0}/* $RPM_BUILD_ROOT%{myappdir}
# Ajustement du répertoire de déploiement
sed -i "s|@@SKEL_APPDIR@@|%{myappdir}|g" \
		$RPM_BUILD_ROOT%{myappdir}/functions

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%attr(0755,root,root) %dir %{myappdir}/*

%changelog
* Fri Jun 20 2014 sylvain.mougenot 1.0.0
- Initial RPM