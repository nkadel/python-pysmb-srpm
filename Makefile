#
# Build mock and local RPM versions of tools for kube
#

# Assure that sorting is case sensitive
LANG=C

#MOCKS+=centos-stream+epel-8-x86_64
MOCKS+=centos-stream+epel-9-x86_64
MOCKS+=centos-stream+epel-10-x86_64
#MOCKS+=fedora-41-x86_64
#MOCKS+=amazonlinux-2023-x86_64

REPOBASEDIR:=`/bin/pwd`/repo

SPEC := `ls *.spec`

all:: $(MOCKS)

.PHONY: getsrc
getsrc::
	spectool -g $(SPEC)

srpm:: src.rpm

#.PHONY:: src.rpm
src.rpm:: Makefile
	@rm -rf rpmbuild
	@rm -f $@
	@echo "Building SRPM with $(SPEC)"
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--define '_sourcedir $(PWD)' \
		-bs $(SPEC) --nodeps
	mv rpmbuild/SRPMS/*.src.rpm src.rpm

.PHONY: build
build:: src.rpm
	rpmbuild --define '_topdir $(PWD)/rpmbuild' \
		--rebuild $?

.PHONY: $(MOCKS)
$(MOCKS)::
	@if [ -e $@ -a -n "`find $@ -name '*.rpm' ! -name '*.src.rpm' 2>/dev/null`" ]; then \
		echo "	Skipping RPM populated $@"; \
	else \
		echo "Building $(SPEC) in $@"; \
		rm -rf $@; \
		mock -q -r /etc/mock/$@.cfg \
		    --sources $(PWD) --spec $(SPEC) \
		    --resultdir=$(PWD)/$@; \
	fi

mock:: $(MOCKS)

install:: $(MOCKS)
	@for repo in $(MOCKS); do \
	    echo Installing $$repo; \
	    case $$repo in \
		amazonlinux-2023-x86_64) yumrelease=amazon/2023; yumarch=x86_64; ;; \
		*-amz2023-x86_64) yumrelease=amazon/2023; yumarch=x86_64; ;; \
		*-8-x86_64) yumrelease=el/8; yumarch=x86_64; ;; \
		*-9-x86_64) yumrelease=el/9; yumarch=x86_64; ;; \
		*-10-x86_64) yumrelease=el/10; yumarch=x86_64; ;; \
		*-41-x86_64) yumrelease=fedora/41; yumarch=x86_64; ;; \
		*-f41-x86_64) yumrelease=fedora/41; yumarch=x86_64; ;; \
		*-rawhide-x86_64) yumrelease=fedora/rawhide; yumarch=x86_64; ;; \
		*) echo "Unrecognized release for $$repo, exiting" >&2; exit 1; ;; \
	    esac; \
	    rpmdir=$(REPOBASEDIR)/$$yumrelease/$$yumarch; \
	    srpmdir=$(REPOBASEDIR)/$$yumrelease/SRPMS; \
	    install -d $$rpmdir $$srpmdir; \
	    echo "Pushing SRPMS to $$srpmdir"; \
	    rsync -av $$repo/*.src.rpm --no-owner --no-group $$repo/*.src.rpm $$srpmdir/. || exit 1; \
	    createrepo_c -q $$srpmdir/.; \
	    echo "Pushing RPMS to $$rpmdir"; \
	    rsync -av $$repo/*.rpm --exclude=*.src.rpm --exclude=*debuginfo*.rpm --no-owner --no-group $$repo/*.rpm $$rpmdir/. || exit 1; \
	    createrepo_c -q $$rpmdir/.; \
	done

clean::
	rm -rf */
	rm -f *.out
	rm -f *.rpm

realclean distclean:: clean
