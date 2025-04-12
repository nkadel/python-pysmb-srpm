# Force python38 for RHEL 8, which has python 3.6 by default
%if 0%{?el8} || 0%{?el9}
%global python3_version 3.12
%global python3_pkgversion 3.12
# For RHEL 'platform python' insanity: Simply put, no.
%global __python3 %{_bindir}/python%{python3_version}
%endif

# Created by pyp2rpm-3.3.10
%global pypi_name pysmb
%global pypi_version 1.2.11

Name:           python-%{pypi_name}
Version:        %{pypi_version}
Release:        1%{?dist}
Summary:        pysmb is an experimental SMB/CIFS library written in Python to support file sharing between Windows and Linux machines

License:        zlib/libpng
URL:            https://miketeo.net/projects/pysmb
Source0:        %{pypi_source %{pypi_name} %{version} zip}
BuildArch:      noarch

BuildRequires:  python%{python3_pkgversion}-devel
BuildRequires:  python3dist(pyasn1)
BuildRequires:  python3dist(setuptools)
BuildRequires:  python3dist(tqdm)

%description
pysmb is an experimental SMB/CIFS library written in Python. It implements the
client-side SMB/CIFS protocol which allows your Python application to access
and transfer files to/from SMB/CIFS shared folders like your Windows file
sharing and Samba folders.

%package -n     python%{python3_pkgversion}-%{pypi_name}
Summary:        %{summary}
%{?python_provide:%python_provide python%{python3_pkgversion}-%{pypi_name}}

Requires:       python3dist(pyasn1)
Requires:       python3dist(tqdm)
%description -n python%{python3_pkgversion}-%{pypi_name}
pysmb is an experimental SMB/CIFS library written in Python. It implements the
client-side SMB/CIFS protocol which allows your Python application to access
and transfer files to/from SMB/CIFS shared folders like your Windows file
sharing and Samba folders.


%prep
%autosetup -n %{pypi_name}-%{pypi_version}
# Remove bundled egg-info
rm -rf %{pypi_name}.egg-info

%build
%py3_build

%install
%py3_install

%check
%{__python3} setup.py test

%files -n python%{python3_pkgversion}-%{pypi_name}
%license LICENSE
%doc README.txt python3/tests/README.md python2/tests/README.md python2/smb/utils/README.txt
%{python3_sitelib}/nmb
%{python3_sitelib}/smb
%{python3_sitelib}/%{pypi_name}-%{pypi_version}-py%{python3_version}.egg-info

%changelog
* Sat Apr 12 2025 Nico Kadel-Garcia <nkadelg@mail.com> - 1.2.11-1
- Initial package.
