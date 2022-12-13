Summary: XawPlus widget set development package
%define AppProgram neXtaw
%define AppVersion 0.15.1
%define AppRelease 20221213
# $XTermId: neXtaw.spec,v 1.13 2022/12/13 12:19:54 tom Exp $
Name: %{AppProgram}
Version: %{AppVersion}
Release: %{AppRelease}
License: X11
Group: Applications/Development
URL: ftp://invisible-island.net/%{AppProgram}
Source0: %{AppProgram}-%{AppVersion}-%{AppRelease}.tgz
Packager: Thomas Dickey <dickey@invisible-island.net>

%description
This is neXtaw, a modified version of the Athena Widgets with N*XTSTEP
appearance. It is based on the Xaw3d 1.5 library by Kaleb S. Keithley.
%prep

%define debug_package %{nil}

%setup -q -n %{AppProgram}-%{AppVersion}-%{AppRelease}

%build

INSTALL_PROGRAM='${INSTALL}' \
	./configure \
		--target %{_target_platform} \
		--prefix=%{_prefix} \
		--bindir=%{_bindir} \
		--libdir=%{_libdir} \
		--mandir=%{_mandir} \
		--with-shared \
		--disable-rpath-hack

make

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

make install		   DESTDIR=$RPM_BUILD_ROOT
# libtool --finish %{_libdir} 

chmod 755 $RPM_BUILD_ROOT%{_libdir}/lib%{AppProgram}.so.*.*.*
rm -f $RPM_BUILD_ROOT%{_libdir}/lib%{AppProgram}.la

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_includedir}/X11/%{AppProgram}
%{_libdir}/lib%{AppProgram}.*

%changelog
# each patch should add its ChangeLog entries here

* Wed Jan 07 2015 Thomas Dickey
- initial version
